from audioop import reverse
from django.http import HttpResponseRedirect
from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.views.decorators.csrf import csrf_exempt

# @login_required(login_url='/login')
# @csrf_exempt
def show_dashboard(request):
    # user = request.user
    # # if isinstance(user, Label):
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
        # if "podcaster" in user.roles:
        #     context['specific_role_data'] = user.daftar_podcast

    context = {}
    return render(request, "dashboard.html", context)

def play_song(request):
    context = {}
    return render(request, "play_song.html", context)

def add_song_to_playlist(request):
    context = {}
    return render(request, "add_song_to_playlist.html", context)

def add_song_to_playlist_success(request):
    context = {}
    return render(request, "add_song_to_playlist_success.html", context)

def download_song(request):
    context = {}
    return render(request, "download_song.html", context)

def play_playlist(request):
    context = {}
    return render(request, "play_playlist.html", context)

def manage_playlist(request):
    context = {}
    return render(request, "manage_playlist.html", context)

def create_playlist(request):
    context = {}
    return render(request, "create_playlist.html", context)

def edit_playlist(request):
    context = {}
    return render(request, "edit_playlist.html", context)

def delete_playlist(request):
    #  delete the playlist
    return HttpResponseRedirect("../")

def playlist_detail(request):
    context = {}
    return render(request, "playlist_detail.html", context)

def playlist_delete_song(request):
    #  delete the song
    return HttpResponseRedirect("../")

def playlist_add_song(request):
    context = {}
    return render(request, "playlist_add_song.html", context)