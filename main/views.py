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

def login_page(request):
    context = {}
    return render(request, 'login.html', context)

# from django.shortcuts import render, redirect
# from .forms import RegisterForm

def login_register_page(request):
    return render(request, 'login_register.html', {})

from datetime import datetime,date
def play_podcast(request):
    podcasts = [ {"judul": "Stoicism", "deskripsi": "Membahas filosofi stoikisme", "durasi": "5 jam 0 menit", "tanggal": datetime.strptime("2024-03-05", "%Y-%m-%d")},
    {"judul": "Existentialism", "deskripsi": "Exploring existential philosophy", "durasi": "4 jam 0 menit", "tanggal": datetime.strptime("2024-03-04", "%Y-%m-%d")},
    {"judul": "Platonism", "deskripsi": "Discussion on Plato's theories", "durasi": "6 jam 30 menit", "tanggal": datetime.strptime("2024-03-03", "%Y-%m-%d")}]
    return render(request, 'play_podcast.html', {"podcasts":podcasts})

def chart_list(request):
    return render(request, 'chart_list.html', {})
def chart_detail(request):
    songs = [
        {
            'judul': 'Lost in the Echo',
            'artist': 'Linkin Park',
            'tanggal_rilis':date(2012, 6, 26),
            'total_plays': 1500000,
        },
        {
            'judul': 'Numb',
            'artist': 'Linkin Park',
            'tanggal_rilis': date(2003, 3, 25),
            'total_plays': 2500000,
        },
        {
            'judul': 'In the End',
            'artist': 'Linkin Park',
            'tanggal_rilis': date(2000, 10, 24),
            'total_plays': 100000,
        },
        {
            'judul': 'Faint',
            'artist': 'Linkin Park',
            'tanggal_rilis': date(2003, 6, 9),
            'total_plays': 1800000,
        }
    ]

    sorted_songs = sorted(songs, key=lambda x: x['total_plays'], reverse=True)

    return render(request, 'chart_detail.html', {"songs":sorted_songs})

def manage_podcasts(request):
    # Dummy data to simulate database entries
    podcasts = [
        {'id': 1, 'judul': 'The Daily Stoic', 'jumlah_episode': 10, 'total_durasi': '10:00:00'},
        {'id': 2, 'judul': 'History of Philosophy', 'jumlah_episode': 5, 'total_durasi': '5:00:00'},
    ]
    return render(request, 'manage_podcasts.html', {'podcasts': podcasts})

def create_podcast(request):
    return render(request, 'create_podcast.html', {})

def episode_list(request):
    episodes = [
        {"id": "1", "judul": "Episode 1", "deskripsi": "This is the first episode.", "durasi": "30 mins", "tanggal": "2022-01-01"},
        {"id": "2", "judul": "Episode 2", "deskripsi": "This is the second episode.", "durasi": "45 mins", "tanggal": "2022-01-02"}
    ]
    return render(request, 'episode_list.html', {'episodes': episodes})

def create_episode(request, podcast_id):
    podcast = {
        "judul": "Example Podcast",
        "jumlah_episode": 10,
        "total_durasi": "450 mins"
    }
    return render(request, 'create_episode.html', {'podcast': podcast})