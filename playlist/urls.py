from django.urls import path
from playlist.views import *
app_name = 'playlist'

urlpatterns = [
    path('', manage_playlist, name='manage_playlist'),
    path('play/', play_playlist, name='play_playlist'),
    path('create/', create_playlist, name='create_playlist'),
    path('edit/', edit_playlist, name='edit_playlist'),
    path('delete/', delete_playlist, name='delete_playlist'),
    path('detail/', playlist_detail, name='playlist_detail'),
    path('detail/delete-song/', playlist_delete_song, name='playlist_delete_song'),
    path('detail/add-song/', playlist_add_song, name='playlist_add_song'),
]