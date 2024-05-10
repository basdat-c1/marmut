from django.shortcuts import render

def play_podcast(request):
    podcasts = [ {"judul": "Stoicism", "deskripsi": "Membahas filosofi stoikisme", "durasi": "5 jam 0 menit", "tanggal": datetime.strptime("2024-03-05", "%Y-%m-%d")},
    {"judul": "Existentialism", "deskripsi": "Exploring existential philosophy", "durasi": "4 jam 0 menit", "tanggal": datetime.strptime("2024-03-04", "%Y-%m-%d")},
    {"judul": "Platonism", "deskripsi": "Discussion on Plato's theories", "durasi": "6 jam 30 menit", "tanggal": datetime.strptime("2024-03-03", "%Y-%m-%d")}]
    return render(request, 'play_podcast.html', {"podcasts":podcasts})

def manage_podcasts(request):
    # Dummy data to simulate database entries
    podcasts = [
        {'id': 1, 'judul': 'The Daily Stoic', 'jumlah_episode': 10, 'total_durasi': '10:00:00'},
        {'id': 2, 'judul': 'History of Philosophy', 'jumlah_episode': 5, 'total_durasi': '5:00:00'},
    ]
    return render(request, 'manage_podcasts.html', {'podcasts': podcasts})

def create_podcast(request):
    return render(request, 'create_podcast.html', {})

def episode_list(request):
    episodes = [
        {"id": "1", "judul": "Episode 1", "deskripsi": "This is the first episode.", "durasi": "30 mins", "tanggal": "2022-01-01"},
        {"id": "2", "judul": "Episode 2", "deskripsi": "This is the second episode.", "durasi": "45 mins", "tanggal": "2022-01-02"}
    ]
    return render(request, 'episode_list.html', {'episodes': episodes})

def create_episode(request, podcast_id):
    podcast = {
        "judul": "Example Podcast",
        "jumlah_episode": 10,
        "total_durasi": "450 mins"
    }
    return render(request, 'create_episode.html', {'podcast': podcast})