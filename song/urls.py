from django.urls import path
from song.views import *
app_name = 'song'

urlpatterns = [
    path('play/', play_song, name='play_song'),
    path('add-to-playlist/', add_song_to_playlist, name='add_song_to_playlist'),
    path('add-to-playlist-success/', add_song_to_playlist_success, name='add_song_to_playlist_success'),
    path('download/', download_song, name='download_song'),
]