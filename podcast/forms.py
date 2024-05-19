from django.shortcuts import render, redirect
from django import forms
from utils.query import query

class PodcastForm(forms.Form):
    judul = forms.CharField(max_length=200, label='Judul')
    genre = forms.MultipleChoiceField(
        label='Genre',
        widget=forms.SelectMultiple
    )

class EpisodeForm(forms.Form):
    judul = forms.CharField(max_length=200, label='Judul Episode', widget=forms.TextInput(attrs={'class': 'form-control', 'required': 'required'}))
    deskripsi = forms.CharField(label='Deskripsi', widget=forms.Textarea(attrs={'class': 'form-control', 'rows': 3, 'required': 'required'}))
    durasi = forms.IntegerField(label='Durasi (Dalam menit)')