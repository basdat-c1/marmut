from django.urls import path
from song.views import *
app_name = 'song'

urlpatterns = [
    path('play/', play_song, name='play_song'),
    path('add-to-playlist/', add_song_to_playlist, name='add_song_to_playlist'),
    path('add-to-playlist-success/', add_song_to_playlist_success, name='add_song_to_playlist_success'),
    path('download/', download_song, name='download_song'),
    path('create_album/', create_album, name='create_album'),
    path('list_album/', list_album, name='list_album'),
    path('list_songs/<uuid:album_id>/', list_songs, name='list_songs'),
    path('create_song/', create_song, name='create_song'),
    path('label_list_album/', label_list_album, name='label_list_album'),
    path('label_list_song/', label_list_song, name='label_list_song'),
    path('delete_song/<uuid:song_id>/', delete_song, name='delete_song'),
]