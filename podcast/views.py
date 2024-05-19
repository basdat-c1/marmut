from datetime import datetime
from django.http import HttpResponseBadRequest
from django.shortcuts import redirect, render
from utils.query import query
from utils.decorator import custom_login_required
from django.views.decorators.csrf import csrf_exempt
import uuid
from podcast.forms import PodcastForm, EpisodeForm
def play_podcast(request, podcast_id):
    try:
        uuid_obj = uuid.UUID(podcast_id, version=4)
    except ValueError:
        return HttpResponseBadRequest("Invalid podcast ID format.")
    podcast = query(f"SELECT * FROM PODCAST WHERE id_konten = '{podcast_id}'")
    print(podcast)
    if not podcast:
        return redirect("main:show_dashboard")
    nama_podcaster = query(f"SELECT nama FROM AKUN WHERE email = '{podcast[0][1]}'")[0][0]
    konten = query(f"SELECT * FROM KONTEN WHERE id = '{podcast[0][0]}'")
    episodes_query = query(f"SELECT * FROM EPISODE WHERE id_konten_podcast = '{podcast_id}'")
    genre = query(f"SELECT genre FROM GENRE where id_konten = '{konten[0][0]}'")[0][0]
    
    total_durasi = 0
    episodes = []
    for episode in episodes_query:
        episode_dict = dict()
        episode_dict["id_episode"] = episode[0]
        episode_dict["id_konten_podcast"] = episode[1]
        episode_dict["judul"] = episode[2]
        episode_dict["deskripsi"] = episode[3]
        episode_dict["durasi"] = format_duration(episode[4])
        episode_dict["tanggal_rilis"] = episode[5]
        episodes.append(episode_dict)
        total_durasi += episode[4]


    konten_dict = dict()
    # Tuple to dictionary 
    konten_dict["judul"] = konten[0][1]
    konten_dict["genre"] = genre
    konten_dict["id"] = konten[0][0]
    konten_dict["tanggal_rilis"] = konten[0][2]
    konten_dict["tahun"] = konten[0][3]
    konten_dict["durasi"] = format_duration(total_durasi)

    context = {
        "podcast" : konten_dict,
        "episodes": episodes,
        "nama_podcaster" : nama_podcaster
    }

    return render(request, 'play_podcast.html', context)

@custom_login_required
def manage_podcasts(request):
    if (not request.session["is_podcaster"]):
        return redirect("")
    email = request.session["email"]
    podcasts = query(f"SELECT k.id, k.judul, k.tanggal_rilis, k.tahun, k.durasi, count(e.id_konten_podcast) as jumlah_episode FROM podcast p LEFT JOIN konten k on id_konten = id LEFT JOIN episode e on id = id_konten_podcast WHERE email_podcaster = '{email}' GROUP BY k.id")
    if not podcasts:
        return redirect('main:show_dashboard')
    print(podcasts)
    for i in range(len(podcasts)):
        podcast = podcasts[i]
        formatted_duration = format_duration(podcast.durasi)
        podcasts[i] = podcast._replace(durasi=formatted_duration)
    episode_counts = []
    for podcast in podcasts:
        episode_count = query(f"SELECT count(*) from episode where id_konten_podcast = '{podcast[0]}' GROUP BY id_konten_podcast")
        print(episode_count)
        if not episode_count:
            episode_count = 0
        else:
            episode_count = episode_count[0][0]
        episode_counts.append(episode_count)
    context = {
        'podcasts':zip(podcasts,episode_counts)
    }
    return render(request, 'manage_podcasts.html', context)

@csrf_exempt
@custom_login_required
def create_podcast(request):
    genres = query("SELECT DISTINCT genre FROM genre")
    genre_choices = [(genre[0], genre[0]) for genre in genres]
    PodcastForm.base_fields["genre"].choices = genre_choices

    if request.method =='POST' and request.session["is_podcaster"]:
        form = PodcastForm(request.POST)
        if form.is_valid():
            judul = form.cleaned_data['judul']
            selected_genres = form.cleaned_data['genre']
            new_uuid = str(uuid.uuid4())
            email = request.session["email"]
            # Insert into KONTEN
            res = query(
                f"INSERT INTO KONTEN (id, judul, tanggal_rilis, tahun, durasi) "
                f"VALUES ('{new_uuid}', '{judul}', CURRENT_DATE, DATE_PART('year', CURRENT_DATE), 0)"
            )
            print(res)
            # Insert into PODCAST
            res = query(
                f"INSERT INTO PODCAST (id_konten, email_podcaster) "
                f"VALUES ('{new_uuid}', '{email}')"
            )
            print(res)

            # Insert into GENRE
            for genre in selected_genres:
                res = query(
                    f"INSERT INTO GENRE (id_konten, genre) "
                    f"VALUES ('{new_uuid}', '{genre}')"
                )
                print(res)

            return redirect('podcast:manage_podcast')
    else:
        form = PodcastForm()
    return render(request, 'create_podcast.html', {'form':form})
@csrf_exempt
@custom_login_required
def episode_list(request, podcast_id):
    email = query(f"SELECT email_podcaster FROM podcast WHERE id_konten = '{podcast_id}'")
    if not request.session["is_podcaster"] or request.session["email"] != email[0][0]:
        return redirect("main:show_dashboard")
    episodes = query(f"SELECT * FROM episode WHERE id_konten_podcast = '{podcast_id}'")
    judul = query(f"SELECT judul from konten where id = '{podcast_id}'")[0][0]
    for i in range(len(episodes)):
        episode = episodes[i]
        formatted_duration = format_duration(episode.durasi)
        episodes[i] = episode._replace(durasi=formatted_duration)
    return render(request, 'episode_list.html', {'episodes': episodes, 'judul':judul})

@csrf_exempt
@custom_login_required
def create_episode(request, podcast_id):
    podcast = query(f"SELECT * FROM konten WHERE id = '{podcast_id}'")
    email = query(f"SELECT email_podcaster FROM podcast WHERE id_konten = '{podcast_id}'")
    if not podcast or request.session["email"] != email[0][0]:
        return redirect("")
    print(podcast)
    episode_count = query(f"SELECT count(*) from episode where id_konten_podcast = '{podcast_id}' GROUP BY id_konten_podcast")
    if not episode_count:
        episode_count = 0
    else:
        episode_count = episode_count[0][0]
    if request.method == 'POST' and request.session["is_podcaster"]:
        form = EpisodeForm(request.POST)
        if form.is_valid():
            judul = form.cleaned_data['judul']
            deskripsi = form.cleaned_data['deskripsi']
            durasi = form.cleaned_data['durasi']
            new_uuid = str(uuid.uuid4())  # Ensure UUID is a string

            # Insert into EPISODE
            res = query(f"INSERT INTO EPISODE (id_episode, id_konten_podcast, judul, deskripsi, durasi, tanggal_rilis) VALUES ('{new_uuid}', '{podcast_id}', '{judul}', '{deskripsi}', '{durasi}', CURRENT_DATE)")
            print(res)
            return redirect('podcast:episode_list', podcast_id=podcast_id)
    else:
        form = EpisodeForm()
    return render(request, 'create_episode.html', {'form':form, 'podcast': podcast[0], 'jumlah_episode':episode_count})

def format_duration(minute):
    if minute < 60:
        return f"{minute} menit"
    jam, menit = divmod(minute, 60)
    return f"{jam} Jam {menit} menit"

@csrf_exempt
@custom_login_required
def update_podcast(request, podcast_id):
    podcast_details = query(f"SELECT * FROM KONTEN WHERE id = '{podcast_id}'")
    email = query(f"SELECT email_podcaster from podcast where id_konten = '{podcast_id}'")
    podcast_genres = query(f"SELECT genre FROM genre WHERE id_konten = '{podcast_id}'")
    print(podcast_details)
    if not podcast_details or request.session["email"] != email[0][0]:
        return redirect("main")

    genres = query("SELECT DISTINCT genre FROM GENRE")
    genre_choices = [(genre[0], genre[0]) for genre in genres]
    PodcastForm.base_fields["genre"].choices = genre_choices
    if request.method == 'POST' and request.session["is_podcaster"]:
        form = PodcastForm(request.POST)
        if form.is_valid():
            judul = form.cleaned_data['judul']
            selected_genres = form.cleaned_data['genre']

            res = query(
                f"UPDATE KONTEN SET judul = '{judul}' WHERE id = '{podcast_id}'"
            )
            print(res)
            res = query(
                f"DELETE FROM GENRE WHERE id_konten = '{podcast_id}'"
            )
            print(res)
            for genre in selected_genres:
                res = query(
                    f"INSERT INTO GENRE (id_konten, genre) VALUES ('{podcast_id}', '{genre}')"
                )
                print(res)

            return redirect('podcast:manage_podcast')
    else:
        initial_data = {
            'judul': podcast_details[0].judul,
            'genre': [podcast_genre[0] for podcast_genre in podcast_genres],
        }
        form = PodcastForm(initial=initial_data)

    return render(request, 'update_podcast.html', {'form': form})

@csrf_exempt
@custom_login_required
def delete_podcast(request, podcast_id):
    #auth
    email = query(f"SELECT email_podcaster FROM podcast WHERE id_konten = '{podcast_id}'")
    if not email or request.session["email"] != email[0][0]:
        return redirect("")
    
    if request.method == 'POST' and request.session["is_podcaster"]:
        query(f"DELETE FROM Konten WHERE id = '{podcast_id}'")
        return redirect('podcast:manage_podcast')
    
    manage_podcasts(request)

@csrf_exempt
@custom_login_required
def delete_episode(request, episode_id):
    user_email = request.session["email"]
    episode = query(f"SELECT * FROM episode where id_episode = '{episode_id}'")
    email = query(f"SELECT email_podcaster from podcast join episode on id_konten_podcast = id_konten WHERE id_episode = '{episode_id}'")
    if not email or user_email != email[0][0]:
        redirect("main:show_dashboard")
    if request.method == 'POST' and request.session["is_podcaster"]:
        res = query(f"DELETE FROM episode WHERE id_episode = '{episode_id}'")
        print("res:", res)

        return redirect('podcast:episode_list', podcast_id = episode[0].id_konten_podcast)
    episode_list(request)

@csrf_exempt
@custom_login_required
def update_episode(request, episode_id):
    episode = query(f"SELECT * FROM episode WHERE id_episode = '{episode_id}'")
    if not episode:
        return redirect("main:show_dashboard")
    
    podcast_id = episode[0][1] 
    email = query(f"SELECT email_podcaster FROM podcast WHERE id_konten = '{podcast_id}'")
    if request.session["email"] != email[0][0]:
        return redirect("main:show_dashboard")

    if request.method == 'POST' and request.session["is_podcaster"]:
        form = EpisodeForm(request.POST)
        if form.is_valid():
            judul = form.cleaned_data['judul']
            deskripsi = form.cleaned_data['deskripsi']
            new_durasi = form.cleaned_data['durasi']

            old_durasi = episode[0][4] 
            durasi_diff = new_durasi - old_durasi
            res = query(f"UPDATE episode SET judul = '{judul}', deskripsi = '{deskripsi}', durasi = '{new_durasi}' WHERE id_episode = '{episode_id}'")
            print(res)
            res = query(f"UPDATE konten SET durasi = durasi + {durasi_diff} WHERE id = '{podcast_id}'")
            print(res)
            return redirect('podcast:episode_list', podcast_id=podcast_id)
    else:
        form = EpisodeForm(initial={
            'judul': episode[0][2], 
            'deskripsi': episode[0][3], 
            'durasi': episode[0][4]  
        })
    return render(request, 'update_episode.html', {'form': form, 'episode': episode[0]})
