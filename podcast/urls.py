from django.urls import path
from podcast.views import *
app_name = 'podcast'

urlpatterns = [
    path('play', play_podcast, name='play_podcast'),
    path('manage/', manage_podcasts, name="manage_podcast"),
    path('create/', create_podcast, name="create_podcast"),
    path('manage/episode/', episode_list, name="episode_list"),
    path('manage/episode/create/<podcast_id>', create_episode, name="create_episode")
]