from django.urls import path
from main.views import *
app_name = 'main'

urlpatterns = [
    path('', show_dashboard, name='show_dashboard'),
    path('login/', login_page, name='login'),
    path('login-or-register/', login_register_page, name='login_register'),
    path('register/', register, name='register'),
    path('pengguna_form/', pengguna_form, name='pengguna_form'),
    path('label_form/', label_form, name='label_form'),
]