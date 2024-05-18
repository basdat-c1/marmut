from django.urls import path
from song.views import *
app_name = 'song'

urlpatterns = [
    path('play/<uuid:id>/', play_song, name='play_song'),
    path('play/<uuid:id>/increment-play/', increment_play, name='increment_play'),
    path('play/<uuid:id>/add-to-playlist/', add_song_to_playlist, name='add_song_to_playlist'),
    path('play/<uuid:id>/add-to-playlist-post/<uuid:id_playlist>/', add_song_to_playlist_post, name='add_song_to_playlist_post'),
    path('play/<uuid:id>/download-post/', download_song_post, name='download_song_post'),
    path('create_album/', create_album, name='create_album'),
    path('list_album/', list_album, name='list_album'),
    path('list_songs/<uuid:album_id>/', list_songs, name='list_songs'),
    path('create_song/<uuid:album_id>/', create_song, name='create_song'),
    path('label_list_album/', label_list_album, name='label_list_album'),
    path('label_list_song/', label_list_song, name='label_list_song'),
    path('delete_song/<uuid:song_id>/', delete_song, name='delete_song'),
    path('delete_album/<uuid:album_id>/', delete_album, name='delete_album'),
    path('royalty/', royalty, name='royalty'),
]