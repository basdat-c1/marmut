from uuid import uuid4
from django.http import HttpResponseRedirect, JsonResponse
from django.shortcuts import redirect, render
from django.urls import reverse
from django.views.decorators.csrf import csrf_exempt

from utils.decorator import custom_login_required
from utils.query import query

@csrf_exempt
@custom_login_required
def play_playlist(request):
    if not request.session["is_label"]:
        context = {}
        return render(request, "play_playlist.html", context)

@csrf_exempt
@custom_login_required
def manage_playlist(request):
    if not request.session["is_label"]:
        context = {}
        data_playlist = query(
            f"""
            SELECT UP.judul, UP.deskripsi, UP.jumlah_lagu, UP.tanggal_dibuat as tanggal_rilis, UP.total_durasi, UP.id_playlist, UP.id_user_playlist
            FROM USER_PLAYLIST UP
            WHERE UP.email_pembuat = '{request.session["email"]}';
            """)
        has_playlist = False
        if data_playlist:
            has_playlist = True
        context["has_playlist"] = has_playlist
        context["data_playlist"] = data_playlist
        return render(request, "manage_playlist.html", context)
    
    return HttpResponseRedirect(reverse("main:login"))

@csrf_exempt
@custom_login_required
def create_playlist(request):
    if not request.session["is_label"]:
        return render(request, "create_playlist.html")

@csrf_exempt
@custom_login_required
def create_playlist_post(request):
    if not request.session["is_label"]:
        judul = request.POST.get('judul')
        deskripsi = request.POST.get('deskripsi')
        id_playlist = str(uuid4())
        id_user_playlist = str(uuid4())
        query(f"INSERT INTO playlist VALUES ('{id_playlist}');") 
        query(f"""INSERT INTO user_playlist VALUES ('{request.session["email"]}', '{id_user_playlist}', 
                '{judul}', '{deskripsi}', 0, current_date, '{id_playlist}', 0);""")
        return HttpResponseRedirect("../")
    
    return HttpResponseRedirect(reverse("main:login"))

@csrf_exempt
@custom_login_required
def playlist_detail(request, id):
    if not request.session["is_label"]:
        playlist = query(
            f"""
            SELECT UP.email_pembuat, UP.judul, UP.deskripsi, UP.jumlah_lagu, 
            TO_CHAR(UP.tanggal_dibuat, 'DD/MM/YY') AS tanggal_dibuat,
            UP.total_durasi, UP.id_playlist, UP.id_user_playlist
            FROM USER_PLAYLIST UP
            WHERE up.id_user_playlist = '{id}';
            """)[0]
        pembuat = query(f"select nama from akun where email = '{playlist[0]}';")[0][0]
        id_playlist = playlist[6]
        lagu = query(
            f"""SELECT 
            k.id as id_lagu, k.judul, akun.nama as oleh, k.durasi
            FROM playlist_song as ps, song as s, konten as k, artist as a, akun
            WHERE ps.id_playlist = '{id_playlist}' AND ps.id_song = s.id_konten AND s.id_konten = k.id
                AND s.id_artist = a.id AND akun.email = a.email_akun;
            """)
        
        list_lagu = [0]*len(lagu)
        for i,row in enumerate(lagu):
            durasi = row[3]
            if durasi < 60: durasi_lagu = f"{durasi} menit"
            else: durasi_lagu = f"{durasi // 60} jam {durasi % 60} menit"
            list_lagu[i] = (row[1], row[2], durasi_lagu, row[0])

        durasi = playlist[5]
        if durasi < 60: durasi_playlist = f"{durasi} menit"
        else: durasi_playlist = f"{durasi // 60} jam {durasi % 60} menit"

        context = {
            "playlist" : playlist,
            "lagu" : lagu,
            "durasi_playlist" : durasi_playlist,
            "list_lagu" : list_lagu,
            "pembuat" : pembuat, 
        }

        return render(request, "playlist_detail.html", context)
    
    return HttpResponseRedirect(reverse("main:login"))

@csrf_exempt
@custom_login_required
def playlist_add_song(request, id):
    if not request.session["is_label"]:
        context = {}
        data_lagu = query(
            f"""
            SELECT k.judul, akun.nama AS artist, k.id
            FROM KONTEN k
            JOIN SONG s ON k.id = s.id_konten
            JOIN ARTIST a ON s.id_artist = a.id
            JOIN AKUN ON akun.email = a.email_akun;
            """)
        context["data_lagu"] = data_lagu
        return render(request, "playlist_add_song.html", context)
    
    return HttpResponseRedirect(reverse("main:login"))

@csrf_exempt
@custom_login_required
def playlist_add_song_post(request, id, id_lagu):
    if not request.session["is_label"]:
        playlist = query(
            f"""
            SELECT UP.email_pembuat, UP.judul, UP.deskripsi, UP.jumlah_lagu, 
            TO_CHAR(UP.tanggal_dibuat, 'DD/MM/YY') AS tanggal_dibuat,
            UP.total_durasi, UP.id_playlist, UP.id_user_playlist
            FROM USER_PLAYLIST UP
            WHERE up.id_user_playlist = '{id}';
            """)[0]
        id_playlist = playlist[6]
        context = {}
        judul_lagu = query(f"""select konten.judul from song, konten 
                        where song.id_konten = konten.id and song.id_konten = '{id_lagu}';""")
        judul_playlist = query(f"""select up.judul from user_playlist up
                        where up.id_playlist = '{id_playlist}';""")
        context["judul_lagu"] = judul_lagu[0][0]
        context["judul_playlist"] = judul_playlist[0][0]
        result = query(f"INSERT INTO playlist_song (id_playlist, id_song) VALUES ('{id_playlist}', '{id_lagu}');")
        if isinstance(result, Exception):
            return render(request, "playlist_add_song_failed.html", context)
        else:
            return HttpResponseRedirect("../../")
        
    return HttpResponseRedirect(reverse("main:login"))

@csrf_exempt
@custom_login_required 
def playlist_delete_song_post(request, id, id_lagu):
    if not request.session["is_label"]:
        playlist = query(
            f"""
            SELECT UP.email_pembuat, UP.judul, UP.deskripsi, UP.jumlah_lagu, 
            TO_CHAR(UP.tanggal_dibuat, 'DD/MM/YY') AS tanggal_dibuat,
            UP.total_durasi, UP.id_playlist, UP.id_user_playlist
            FROM USER_PLAYLIST UP
            WHERE up.id_user_playlist = '{id}';
            """)[0]
        id_playlist = playlist[6]
        query(f"DELETE FROM playlist_song WHERE id_playlist = '{id_playlist}' AND id_song = '{id_lagu}';")
        return HttpResponseRedirect("../../")
    
    return HttpResponseRedirect(reverse("main:login"))

@csrf_exempt
@custom_login_required
def edit_playlist(request, id):
    if not request.session["is_label"]:
        id_user_playlist = id
        if request.method == "POST":
            judul = request.POST.get('judul')
            deskripsi = request.POST.get('deskripsi')
            query(f"""UPDATE user_playlist SET judul = '{judul}', deskripsi = '{deskripsi}'
                    WHERE id_user_playlist = '{id_user_playlist}';""")
            return HttpResponseRedirect("../../")
        return render(request, "edit_playlist.html")
    
    return HttpResponseRedirect(reverse("main:login"))

@csrf_exempt
@custom_login_required
def delete_playlist(request, id):
    if not request.session["is_label"]:
        id_user_playlist = id
        playlist = query(
            f"""
            SELECT UP.email_pembuat, UP.judul, UP.deskripsi, UP.jumlah_lagu, 
            TO_CHAR(UP.tanggal_dibuat, 'DD/MM/YY') AS tanggal_dibuat,
            UP.total_durasi, UP.id_playlist, UP.id_user_playlist
            FROM USER_PLAYLIST UP
            WHERE up.id_user_playlist = '{id}';
            """)[0]
        id_playlist = playlist[6]
        query(f"delete from playlist where id = '{id_playlist}';")
        query(f"delete from user_playlist where id_user_playlist = '{id_user_playlist}';")
        query(f"delete from playlist_song where id_playlist = '{id_playlist}';")
        query(f"delete from akun_play_user_playlist where id_user_playlist = '{id_user_playlist}';")
        return HttpResponseRedirect("../../")
    
    return HttpResponseRedirect(reverse("main:login"))

@csrf_exempt
@custom_login_required
def playlist_shuffle_play_post(request, id):
    if not request.session["is_label"]:
        id_user_playlist = id
        playlist = query(
            f"""
            SELECT UP.id_playlist, UP.email_pembuat
            FROM USER_PLAYLIST UP WHERE up.id_user_playlist = '{id}';
            """)[0]
        id_playlist = playlist[0]
        email_pembuat_playlist = playlist[1]
        email_pemain_playlist = request.session['email']
        current_timestamp = query("SELECT current_timestamp::timestamp;")[0][0]
        print(query(f"""insert into akun_play_user_playlist values 
            ('{email_pemain_playlist}', 
            '{id_user_playlist}', 
            '{email_pembuat_playlist}', 
            '{current_timestamp}');
            """))
        
        daftar_lagu = query(
            f"""SELECT 
            k.id as id_lagu, k.judul, akun.nama as oleh, k.durasi
            FROM playlist_song as ps, song as s, konten as k, artist as a, akun
            WHERE ps.id_playlist = '{id_playlist}' AND ps.id_song = s.id_konten AND s.id_konten = k.id
                AND s.id_artist = a.id AND akun.email = a.email_akun;
            """)
        for lagu in daftar_lagu:
            id_lagu = lagu[0]
            print(query(f"""insert into akun_play_song values
                ('{email_pemain_playlist}',
                '{id_lagu}',
                '{current_timestamp}');
                """))
            query(f"UPDATE song SET total_play = total_play + 1 WHERE id_konten = '{id_lagu}';")
        return HttpResponseRedirect("../")
    
    return HttpResponseRedirect(reverse("main:login"))

@csrf_exempt
@custom_login_required
def play_stay_playlist_post(request, id, id_lagu):
    if not request.session["is_label"]:
        id_user_playlist = id
        email = request.session['email']
        query(f"""INSERT INTO akun_play_song (email_pemain, id_song, waktu) VALUES 
            ('{email}', '{id_lagu}', current_timestamp);""")
        query(f"UPDATE song SET total_play = total_play + 1 WHERE id_konten = '{id_lagu}';")
        return HttpResponseRedirect("../../")
    
    return HttpResponseRedirect(reverse("main:login"))