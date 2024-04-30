from django.urls import path
from main.views import *
app_name = 'main'

urlpatterns = [
    path('', show_dashboard, name='show_dashboard'),
    path('song/play/', play_song, name='play_song'),
    path('song/add-to-playlist/', add_song_to_playlist, name='add_song_to_playlist'),
    path('song/add-to-playlist-success/', add_song_to_playlist_success, name='add_song_to_playlist_success'),
    path('song/download/', download_song, name='download_song'),
    path('playlist/play/', play_playlist, name='play_playlist'),
    path('playlist/', manage_playlist, name='manage_playlist'),
    path('playlist/create/', create_playlist, name='create_playlist'),
    path('playlist/edit/', edit_playlist, name='edit_playlist'),
    path('playlist/delete/', delete_playlist, name='delete_playlist'),
    path('playlist/detail/', playlist_detail, name='playlist_detail'),
    path('playlist/detail/delete-song/', playlist_delete_song, name='playlist_delete_song'),
    path('playlist/detail/add-song/', playlist_add_song, name='playlist_add_song'),
    path('login/', login_page, name='login'),
    path('login-or-register/', login_register_page, name='login_register'),
    path('podcast/play', play_podcast, name='play_podcast'),
    path('chart/', chart_list, name="chart_list"),
    path('chart/detail/', chart_detail, name="chart_detail"),
]