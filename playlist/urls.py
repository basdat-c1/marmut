from django.urls import path
from playlist.views import *
app_name = 'playlist'

urlpatterns = [
    path('', manage_playlist, name='manage_playlist'),
    path('create/', create_playlist, name='create_playlist'),
    path('create-post/', create_playlist_post, name='create_playlist_post'),
    path('edit/<uuid:id>/', edit_playlist, name='edit_playlist'),
    path('delete/<uuid:id>/', delete_playlist, name='delete_playlist'),
    path('play/<uuid:id>/', play_playlist, name='play_playlist'),
    path('detail/<uuid:id>/', playlist_detail, name='playlist_detail'),
    path('detail/<uuid:id>/play-stay/<uuid:id_lagu>/', play_stay_playlist_post, name='play_stay_playlist_post'),
    path('detail/<uuid:id>/shuffle-play/', playlist_shuffle_play_post, name='playlist_shuffle_play_post'),
    path('detail/<uuid:id>/add-song/', playlist_add_song, name='playlist_add_song'),
    path('detail/<uuid:id>/add-song/<uuid:id_lagu>/', playlist_add_song_post, name='playlist_add_song_post'),
    path('detail/<uuid:id>/delete-song/<uuid:id_lagu>/', playlist_delete_song_post, name='playlist_delete_song_post'),
]