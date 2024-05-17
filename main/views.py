from django.contrib import messages
from django.http import HttpResponseRedirect
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.views.decorators.csrf import csrf_exempt
from utils.query import query
from utils.decorator import custom_login_required
# from .forms import RegisterForm
@csrf_exempt
def login(request):
    if request.method == 'POST':
        email = request.POST.get('email')
        password = request.POST.get('password')
        user = query(f"SELECT * FROM AKUN WHERE email = '{email}' AND password = '{password}'")
        if user:
            user_info = query(f"SELECT nama FROM AKUN WHERE email = '{email}' AND password = '{password}'")
            if user_info:
                nama = user_info[0].nama
            else:
                nama = None
            print(nama)
            print("Saya user")
            is_podcaster = False
            is_artist = False
            is_songwriter = False
            # is_label = False
            is_premium = check_is_premium(email)
            request.session['is_premium'] = is_premium
            roles = get_roles(email)

            request.session["email"] = email
            request.session["nama"] =  nama
            request.session["password"] = password
            
            is_podcaster = "podcaster" in roles
            is_artist = "artist" in roles
            is_songwriter = "songwriter" in roles
            # is_label = "label" in roles
            print(is_podcaster)
            print(is_artist)
            print(is_songwriter)

            request.session['is_podcaster'] = is_podcaster
            request.session['is_artist'] = is_artist
            request.session['is_songwriter'] = is_songwriter
            # request.session['is_label'] = is_label
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
    # user = query(f"SELECT * FROM LABEL WHERE email = '{email}'")
    # if user:
    #     roles.append("label")
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
# @csrf_exempt
def show_dashboard(request):
    user = request.user
    # # if isinstance(user, Label):
    data_album = query(
        """
        SELECT A.judul, L.nama as nama_label, A.jumlah_lagu, A.total_durasi
        FROM ALBUM A
        JOIN LABEL L ON L.id = A.id_label;
        """)
    
    # context = {
    #     'nama': user.username,
    #     'email': user.email,
    #     'kontak': user.kontak,
    #     'daftar_album': user.daftar_album
    #     # 'last_login': request.COOKIES['last_login'],
    # }

    # # else: # bukan label
    # context = {
    #     'nama': user.nama,
    #     'email': user.email,
    #     'kota_asal': user.kota_asal,
    #     'gender': user.gender,
    #     'tempat_lahir': user.tempat_lahir,
    #     'tanggal_lahir': user.tanggal_lahir,
    #     'roles': user.roles,
    #     # 'last_login': request.COOKIES['last_login'],
    # }

    # if "pengguna_biasa" in user.roles or user.roles:
    #     context['specific_role_data'] = user.daftar_playlist
    # else:
        # if "artist" in user.roles or 'songwriter' in user.roles:
        #     context['specific_role_data'] = user.daftar_playlist
    
    data_lagu = query(
        """
        SELECT * FROM SONG;
        """)
    
        # if "podcaster" in user.roles:
        #     context['specific_role_data'] = user.daftar_podcast
    data_podcast = query(
        """
        SELECT * FROM PODCAST;
        """)
    
        # else (pengguna biasa)
    data_playlist = query(
        """
        SELECT * FROM PLAYLIST;
        """)
    
    context = {
        "data_album" : data_album,
        "data_lagu" : data_lagu,
        "data_podcast" : data_podcast,
        "data_playlist" : data_playlist,
    }

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
