from django.shortcuts import render
from datetime import date
from utils.query import query
def chart_list(request):
    chart_q = query(f"SELECT * FROM CHART")
    charts = []
    for chart in chart_q:
        chart_dict = dict()
        chart_dict["tipe"] = chart[0]
        chart_dict["id_playlist"] = chart[1]
        charts.append(chart_dict)
    context = {
        "charts":charts
    }
    return render(request, 'chart_list.html', context)

def chart_detail(request, tipe):
    if tipe == "daily":
        date_filter = "waktu::date >= CURRENT_DATE"
        tipe_chart = "Daily Top 20"
    elif tipe == "weekly":
        date_filter = "waktu >= CURRENT_DATE - INTERVAL '7 days'"
        tipe_chart = "Weekly Top 20"
    elif tipe == "monthly":
        date_filter = "waktu >= CURRENT_DATE - INTERVAL '1 month'"
        tipe_chart = "Monthly Top 20"
    elif tipe == "yearly":
        tipe_chart = "Yearly Top 20"
        date_filter = "waktu >= CURRENT_DATE - INTERVAL '1 year'"

    songs = query(f"""
        SELECT id_song, count(*) as total_play 
        FROM akun_play_song 
        WHERE {date_filter} 
        GROUP BY id_song 
        ORDER BY total_play DESC 
        LIMIT 20
    """)
    song_list = []
    for song in songs:
        song_instance = query(f"SELECT * FROM SONG WHERE id_konten = '{song[0]}'")[0]
        song_detail = query(f"SELECT * FROM konten WHERE id = '{song[0]}'")[0]
        artist = query(f"select nama FROM artist left join akun on email_akun = email WHERE id = '{song_instance[1]}'")
        total_plays = song[1]
        song_dict = dict()
        song_dict["judul"] = song_detail[1]
        song_dict["artist"] = artist[0][0]
        song_dict["tanggal_rilis"] = song_detail[2]
        song_dict["total_plays"] = total_plays
        song_dict["id"] = song[0]
        song_list.append(song_dict)
            
    return render(request, 'chart_detail.html', {"tipe":tipe_chart, "songs":song_list})