from django.shortcuts import render

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