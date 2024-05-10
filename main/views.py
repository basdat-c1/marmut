from django.http import HttpResponseRedirect
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from django.views.decorators.csrf import csrf_exempt
from utils.query import query
# from .forms import RegisterForm

def login_page(request):
    context = {}
    return render(request, 'login.html', context)

def login_register_page(request):
    return render(request, 'login_register.html', {})

# @login_required(login_url='/login')
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