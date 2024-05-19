from django.urls import path
from podcast.views import *
app_name = 'podcast'

urlpatterns = [
    path('play/<podcast_id>', play_podcast, name='play_podcast'),
    path('manage/', manage_podcasts, name="manage_podcast"),
    path('create/', create_podcast, name="create_podcast"),
    path('manage/episode/<podcast_id>', episode_list, name="episode_list"),
    path('manage/episode/create/<podcast_id>', create_episode, name="create_episode"),
    path('update/<podcast_id>', update_podcast, name="update_podcast"),
    path('delete/<podcast_id>', delete_podcast, name="delete_podcast"),
    path('manage/episode/delete/<episode_id>', delete_episode, name="delete_episode"),
    path('manage/episode/updaate/<episode_id>', update_episode, name="update_episode")
]