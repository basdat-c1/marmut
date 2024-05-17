from django.shortcuts import render
from datetime import date

def chart_list(request):
    return render(request, 'chart_list.html', {})

def chart_detail(request):
    songs = [
        {
            'judul': 'Lost in the Echo',
            'artist': 'Linkin Park',
            'tanggal_rilis': date(2012, 6, 26),
            'total_plays': 1500000,
        },
        {
            'judul': 'Numb',
            'artist': 'Linkin Park',
            'tanggal_rilis': date(2003, 3, 25),
            'total_plays': 2500000,
        },
        {
            'judul': 'In the End',
            'artist': 'Linkin Park',
            'tanggal_rilis': date(2000, 10, 24),
            'total_plays': 100000,
        },
        {
            'judul': 'Faint',
            'artist': 'Linkin Park',
            'tanggal_rilis': date(2003, 6, 9),
            'total_plays': 1800000,
        }
    ]

    sorted_songs = sorted(songs, key=lambda x: x['total_plays'], reverse=True)

    return render(request, 'chart_detail.html', {"songs":sorted_songs})