import uuid
from django.contrib import messages
from django.http import HttpResponseRedirect
from django.shortcuts import render, redirect
from django.urls import reverse
from django.views.decorators.csrf import csrf_exempt
from utils.query import query
from django.db import connection

from utils.decorator import custom_login_required
# from .forms import RegisterForm
@csrf_exempt
def login(request):
    if request.method == 'POST':
        email = request.POST.get('email')
        password = request.POST.get('password')
        user = query(f"SELECT * FROM AKUN WHERE email = '{email}' AND password = '{password}'")
        if user:
            print("Saya user")
            is_podcaster = False
            is_artist = False
            is_songwriter = False
            is_premium = check_is_premium(email)
            request.session['is_premium'] = is_premium
            roles = get_roles(email)
            
            request.session["email"] = email
            request.session["password"] = password
            
            
            is_podcaster = "podcaster" in roles
            is_artist = "artist" in roles
            is_songwriter = "songwriter" in roles
            print(is_podcaster)
            print(is_artist)
            print(is_songwriter)

            request.session['is_podcaster'] = is_podcaster
            request.session['is_artist'] = is_artist
            request.session['is_songwriter'] = is_songwriter
            request.session['is_label'] = False
            request.session.set_expiry(0)
            request.session.modified = True

            return redirect("/")
        else:
            print("Saya label")
            label = query(f"SELECT * FROM LABEL WHERE email = '{email}' and password = '{password}'")
            if label:
                is_label = True
                request.session["is_label"] = is_label
                request.session["email"] = email
                request.session["password"] = password
                request.session.set_expiry(0)
                request.session.modified = True

                return redirect("/")
            else:
                messages.error(request, "Email atau Password Salah, silahkan coba lagi")
                return redirect("/login/")
    else:
        return render(request, 'login.html')

def logout(request):
    request.session.flush()
    request.session.clear_expired()
    return redirect("/login-or-register")

def get_roles(email):
    user = query(f"SELECT * FROM PODCASTER WHERE email = '{email}'")
    roles = []
    if user:
        roles.append("podcaster")
    user = query(f"SELECT * FROM ARTIST WHERE email_akun = '{email}'")
    if user:
        roles.append("artist")
    user = query(f"SELECT * FROM SONGWRITER WHERE email_akun = '{email}'")
    if user:
        roles.append("songwriter")
    return roles

def check_is_premium(email):
    user = query(f"SELECT * FROM PREMIUM WHERE email = '{email}'")
    if user:
        return True
    return False
def login_page(request):
    context = {}
    return render(request, 'login.html', context)

def login_register_page(request):
    return render(request, 'login_register.html', {})

@custom_login_required
def show_dashboard(request):
    if 'email' not in request.session:
        return HttpResponseRedirect(reverse("main:login"))
    
    context = {}
    email = request.session["email"]
    
    
    if request.session["is_label"]:
        label = query(f"SELECT * FROM LABEL WHERE email = '{email}'")[0]
        nama = label[1]
        kontak = label[4]

        data_album = query(
            f"""
            SELECT A.judul, L.nama as nama_label, A.jumlah_lagu, A.total_durasi
            FROM ALBUM A
            JOIN LABEL L ON L.id = A.id_label
            WHERE L.email = '{email}';
            """)
        has_album = False
        if data_album:
            has_album = True
        
        context["nama"] = nama
        context["email"] = email
        context["kontak"] = kontak
        context["has_album"] = has_album
        context["data_album"] = data_album
    else:
        user = query(f"SELECT * FROM AKUN WHERE email = '{email}'")[0]
        if user:
                nama = user[2]
                kota_asal = user[7]
                gender = "Female"
                if user[3] == 1: 
                    gender = "Male"
                tempat_lahir = user[4]
                tanggal_lahir = user[5].strftime("%d %B %Y")
                is_verified = user[6]

                status_langganan = "Premium" if request.session["is_premium"] else "Non premium"
                
                data_playlist = query(
                    f"""
                    SELECT UP.judul, UP.deskripsi, UP.jumlah_lagu, 
                    TO_CHAR(UP.tanggal_dibuat, 'DD/MM/YY') AS tanggal_rilis,
                    UP.total_durasi
                    FROM USER_PLAYLIST UP
                    WHERE UP.email_pembuat = '{email}';
                    """)
                has_playlist = False
                if data_playlist:
                    has_playlist = True
                context["has_playlist"] = has_playlist
                context["data_playlist"] = data_playlist

                roles = get_roles(email)
                if not roles:
                    roles = ["Pengguna Biasa"]
                else: 
                    if "artist" in roles or "songwriter" in roles:
                        data_lagu = query(
                            f"""
                            SELECT K.judul, K.tanggal_rilis, K.durasi, S.total_play, S.total_download
                            FROM KONTEN K
                            JOIN SONG S ON S.id_konten = K.id
                            JOIN ARTIST A ON A.id = S.id_artist
                            WHERE A.email_akun = '{email}'
                            UNION
                            SELECT K.judul, K.tanggal_rilis, K.durasi, S.total_play, S.total_download
                            FROM KONTEN K
                            JOIN SONG S ON S.id_konten = K.id
                            JOIN SONGWRITER_WRITE_SONG SWS ON SWS.id_song = S.id_konten
                            JOIN SONGWRITER SW ON SW.id = SWS.id_songwriter
                            WHERE SW.email_akun = '{email}';
                            """)
                        has_lagu = False
                        if data_lagu:
                            has_lagu = True
                        context["has_lagu"] = has_lagu
                        context["data_lagu"] = data_lagu
                        
                    if "podcaster" in roles:
                        data_podcast = query(
                            f"""
                            SELECT K.judul, K.tanggal_rilis, K.durasi, P.email_podcaster
                            FROM PODCAST P
                            JOIN KONTEN K ON K.id = P.id_konten
                            JOIN PODCASTER PC ON PC.email = P.email_podcaster
                            WHERE PC.email = '{email}';
                            """)
                        has_podcast = False
                        if data_podcast:
                            has_podcast = True
                        context["has_podcast"] = has_podcast
                        context["data_podcast"] = data_podcast

                context["nama"] = nama
                context["email"] = email
                context["status_langganan"] = status_langganan
                context["kota_asal"] = kota_asal
                context["gender"] = gender
                context["tempat_lahir"] = tempat_lahir
                context["tanggal_lahir"] = tanggal_lahir
                context["roles"] = ", ".join(role.capitalize() for role in roles)

    return render(request, "dashboard.html", context)


def register(request):
    return render(request, 'register.html')

def pengguna_form(request):
    if request.method == 'POST':
        email = request.POST.get('email')
        email_query = f"SELECT * FROM AKUN WHERE email = '{email}'"
        email_result = query(email_query)
        # cek email di akun
        if email_result:
            messages.error(request, 'Email is already associated with another user account.')
            return redirect('/pengguna_form')
        # cek email di label
        email_query_label = f"SELECT * FROM LABEL WHERE email = '{email}'"
        email_result_label = query(email_query_label)
        if email_result_label:
            messages.error(request, 'Email is already associated with a label account.')
            return redirect('/pengguna_form')
        password = request.POST.get('password')
        nama = request.POST.get('nama')
        gender = request.POST.get('gender')
        if gender == 'L':
            gender = 1
        else:
            gender = 0
        tempat_lahir = request.POST.get('tempat_lahir')
        tanggal_lahir = request.POST.get('tanggal_lahir')
        kota_asal = request.POST.get('kota_asal')
        roles = request.POST.getlist('role')
        
        if roles:
            is_verified = True
            role = ', '.join(roles)
        else:
            is_verified = False
            role = 'Pengguna Biasa'
        
        with connection.cursor() as cursor:
            cursor.execute(
                f"INSERT INTO marmut.AKUN VALUES ('{email}','{password}', '{nama}', '{gender}', '{tempat_lahir}', '{tanggal_lahir}', '{is_verified}', '{kota_asal}'); "
                f"INSERT INTO marmut.NONPREMIUM VALUES ('{email}');"
            )
        return redirect('/login')
    return render(request, 'pengguna_form.html')


def label_form(request):
    if request.method == 'POST':
        email = request.POST.get('email')
        email_query = f"SELECT * FROM LABEL WHERE email = '{email}'"
        email_result = query(email_query)
        if email_result:
            messages.error(request, 'Email is already associated with another label account.')
            return redirect('/label_form')
        email_query_akun = f"SELECT * FROM AKUN WHERE email = '{email}'"
        email_result_akun = query(email_query_akun)
        if email_result_akun:
            messages.error(request, 'Email is already associated with a user account.')
            return redirect('/label_form')
        uuid = generate_unique_uuid()
        password = request.POST.get('password')
        nama = request.POST.get('nama')
        kontak = request.POST.get('kontak')
        
        with connection.cursor() as cursor:
            cursor.execute(
                f"INSERT INTO marmut.LABEL VALUES ('{uuid}','{nama}','{email}','{password}','{kontak}'); "
            )
        return redirect('/login')
    
    return render(request, 'label_form.html')

def generate_unique_uuid():
    while True:
        new_uuid = str(uuid.uuid4())
        query = f"SELECT COUNT(*) FROM marmut.LABEL WHERE id = '{new_uuid}'"
        with connection.cursor() as cursor:
            cursor.execute(query)
            result = cursor.fetchone()
            if result[0] == 0:  
                return new_uuid
