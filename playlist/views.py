from django.http import HttpResponseRedirect
from django.shortcuts import render

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