import datetime
from django.shortcuts import render
from django.db import connection
from utils.query import query
from django.http import HttpResponseServerError, JsonResponse
from uuid import UUID
from django.shortcuts import render, redirect
from django.http import HttpResponseServerError
from django.views.decorators.csrf import csrf_exempt
# from .models import Album, Song, Konten, Artist, SongwriterWriteSong, Genre, Songwriter  # Adjust imports based on your project structure
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
# from .models import Artist, Songwriter
import uuid
from django.utils import timezone
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
import uuid
from django.utils import timezone


def play_song(request, id):
    lagu = query(
        f"""
        SELECT
            K.judul,
            string_agg(DISTINCT g.genre, ', ') AS genres,
            string_agg(DISTINCT a.email_akun, ',') AS artists,
            string_agg(DISTINCT sw.email_akun, ', ') AS songwriters,
            K.durasi,
            to_char(K.tanggal_rilis, 'DD/MM/YY') AS tanggal_rilis,
            K.tahun AS tahun,
            S.total_play,
            S.total_download,
            ALBUM.judul AS nama_album
        FROM
            KONTEN K
            JOIN SONG S ON K.id = S.id_konten
            LEFT JOIN GENRE G ON K.id = G.id_konten
            LEFT JOIN ARTIST A ON S.id_artist = A.id
            LEFT JOIN SONGWRITER_WRITE_SONG SWS ON S.id_konten = SWS.id_song
            LEFT JOIN SONGWRITER SW ON sws.id_songwriter = SW.id
            LEFT JOIN ALBUM ON S.id_album = ALBUM.id
        WHERE
            K.id = '{id}'
        GROUP BY
            K.judul, K.durasi, K.tanggal_rilis, K.tahun, S.total_play, S.total_download, ALBUM.judul;
        """)[0]

    email_artist = lagu[2]
    artist = query(f"select akun.nama from akun where akun.email = '{email_artist}';")[0][0]

    genres = lagu[1]
    songwriters = lagu[3]
    print(genres)
    print(songwriters)
    if genres:
        genres = [genre.strip() for genre in genres.split(',')]
    if songwriters:
        songwriters = [songwriter.strip() for songwriter in songwriters.split(',')]
    
    is_premium = False
    email = request.session["email"]
    user = query(f"SELECT * FROM PREMIUM WHERE email = '{email}'")
    if user:
        is_premium = True

    context = {}
    context["artist"] = artist
    context["lagu"] = lagu
    context["genres"] = genres
    context["songwriters"] = songwriters
    context["is_premium"] = is_premium
    return render(request, "play_song.html", context)

def increment_play(request, id):
    query(
        f"""
        UPDATE SONG
        SET total_play = total_play + 1
        WHERE id_konten = '{id}';   
        """
        )
    return JsonResponse({'message': 'Play count updated!'})

def add_song_to_playlist(request, id):
    lagu = query(
        f"""
        SELECT
            K.judul,
            string_agg(DISTINCT g.genre, ', ') AS genres,
            string_agg(DISTINCT a.email_akun, ',') AS artists,
            string_agg(DISTINCT sw.email_akun, ', ') AS songwriters,
            K.durasi,
            to_char(K.tanggal_rilis, 'DD/MM/YY') AS tanggal_rilis,
            K.tahun AS tahun,
            S.total_play,
            S.total_download,
            ALBUM.judul AS nama_album
        FROM
            KONTEN K
            JOIN SONG S ON K.id = S.id_konten
            LEFT JOIN GENRE G ON K.id = G.id_konten
            LEFT JOIN ARTIST A ON S.id_artist = A.id
            LEFT JOIN SONGWRITER_WRITE_SONG SWS ON S.id_konten = SWS.id_song
            LEFT JOIN SONGWRITER SW ON sws.id_songwriter = SW.id
            LEFT JOIN ALBUM ON S.id_album = ALBUM.id
        WHERE
            K.id = '{id}'
        GROUP BY
            K.judul, K.durasi, K.tanggal_rilis, K.tahun, S.total_play, S.total_download, ALBUM.judul;
        """)[0]

    email_artist = lagu[2]
    artist = query(f"select akun.nama from akun where akun.email = '{email_artist}';")[0][0]

    data_playlist = query(
        f"""
        SELECT UP.judul, UP.deskripsi, UP.jumlah_lagu, UP.tanggal_dibuat as tanggal_rilis, UP.total_durasi, UP.id_user_playlist, UP.id_playlist
        FROM USER_PLAYLIST UP
        WHERE UP.email_pembuat = '{request.session["email"]}';
        """)

    context = {}
    context["lagu"] = lagu[0]
    context["artist"] = artist
    context["data_playlist"] = data_playlist
    
    return render(request, "add_song_to_playlist.html", context)

def add_song_to_playlist_post(request, id, id_playlist):
    context = {}
    id_lagu = id
    judul_lagu = query(f"""select konten.judul from song, konten 
                    where song.id_konten = konten.id and song.id_konten = '{id_lagu}';""")
    judul_playlist = query(f"""select up.judul from user_playlist up
                    where up.id_playlist = '{id_playlist}';""")
    context["judul_lagu"] = judul_lagu[0][0]
    context["judul_playlist"] = judul_playlist[0][0]
    result = query(f"""INSERT INTO playlist_song (id_playlist, id_song) VALUES ('{id_playlist}', '{id_lagu}');""")
    if isinstance(result, Exception):
        return render(request, "add_song_to_playlist_failed.html", context)
    else:
        return render(request, "add_song_to_playlist_success.html", context)

# def add_song_to_playlist_failed(request, id_lagu, id_playlist):
#     context = {}
#     return render(request, "add_song_to_playlist_failed.html", context)

def download_song_post(request, id):
    id_lagu = id
    judul_lagu = query(f"""select konten.judul from song, konten 
                where song.id_konten = konten.id and song.id_konten = '{id_lagu}';""")[0][0]
    context = { "judul" : judul_lagu }
    result = query(f"INSERT INTO downloaded_song VALUES ('{id_lagu}', '{request.session['email']}');")
    if isinstance(result, Exception):
        return render(request, "download_song_failed.html", context)
    else:
        query(f"UPDATE song SET total_download = total_download + 1 WHERE id_konten = '{id_lagu}';")
        return render(request, "download_song_success.html", context)

def create_album(request):
    return render(request, 'create_album.html')


def list_album(request):
    # Query to fetch album data including label information
    query_str = """
    SELECT a.id, a.judul, l.nama AS label, a.jumlah_lagu, a.total_durasi
    FROM album a
    LEFT JOIN label l ON a.id_label = l.id
    """
    try:
        # Execute the query
        albums = query(query_str)
        
        # Convert album IDs to strings
        albums = [{'id': str(album.id), 'judul': album.judul, 'label': album.label, 
                   'jumlah_lagu': album.jumlah_lagu, 'total_durasi': album.total_durasi} 
                  for album in albums]
    except Exception as e:
        # Return a server error response with the error message
        return HttpResponseServerError(f"An error occurred: {e}")

    # Render the template with the fetched data
    return render(request, 'list_album.html', {'albums': albums})


def list_songs(request, album_id):
    query_str = f"""
    SELECT s.id_konten AS id, k.judul, k.durasi, s.total_play, s.total_download
    FROM song s
    JOIN konten k ON s.id_konten = k.id
    WHERE s.id_album = '{album_id}'
    """
    # Execute the query
    songs = query(query_str)

    # Check if any error occurred during execution
    if isinstance(songs, Exception):
        return render(request, 'error.html', {'error': songs})

    # Render the template with the fetched data
    return render(request, 'list_songs.html', {'songs': songs})

def create_song_if_artis(request):
    return render(request, 'create_song_if_artis.html')



def create_song_if_songwriter(request):
    return render(request, 'create_song_if_songwriter.html')

# @login_required
def label_list_album(request):
    label_id = request.session.get('label_id')  # Adjust this according to your implementation

    # Retrieve albums associated with the label
    albums_query = f"SELECT * FROM album WHERE id_label = '{label_id}'"
    albums = query(albums_query)
    albums = [{'id': str(album.id), 'judul': album.judul, 'label': album.label, 
                   'jumlah_lagu': album.jumlah_lagu, 'total_durasi': album.total_durasi} 
                  for album in albums]

    # Pass the albums data to the template for rendering
    return render(request, 'list_albums.html', {'albums': albums})
    # query_str = """
    # SELECT a.id, a.judul, l.nama AS label, a.jumlah_lagu, a.total_durasi
    # FROM album a
    # LEFT JOIN label l ON a.id_label = l.id
    # """
    # try:
    #     # Execute the query
    #     albums = query(query_str)
        
    #     # Convert album IDs to strings
    #     albums = [{'id': str(album.id), 'judul': album.judul, 'label': album.label, 
    #                'jumlah_lagu': album.jumlah_lagu, 'total_durasi': album.total_durasi} 
    #               for album in albums]
    # except Exception as e:
    #     # Return a server error response with the error message
    #     return HttpResponseServerError(f"An error occurred: {e}")

    # # Render the template with the fetched data
    # return render(request, 'list_album.html', {'albums': albums})

    # return render(request, 'label_list_album.html')


def label_list_song(request):
    return render(request, 'label_list_song.html')



# @login_required
def create_song(request):
    user = request.user
    nama_album = request.GET.get('nama_album')  # Get album name from query parameters

    # Fetch the album ID based on the album name
    album_id_query = f"SELECT id FROM ALBUM WHERE judul = '{nama_album}'"
    album_id = query(album_id_query)
    # print(album_id)
    # print(album_id_result)
    # if not album_id_result:
    #     return render(request, 'error_page.html', {'message': 'Album not found'})  # Handle case when album is not found
    # album_id = album_id_result[0].id

    if request.method == 'POST':
        judul = request.POST['judul']
        durasi = int(request.POST['durasi'])
        genre_ids = request.POST.getlist('genre')

        # UNCOMMAND KALO LOGIN UDH DIIMPLEMENTASI
        if user.role == 'artist':
            artist_id_query = f"SELECT id FROM ARTIST WHERE email_akun = '{user.email}'"
            artist_id_result = query(artist_id_query)
            artist_id = artist_id_result[0].id if artist_id_result else None
            songwriter_ids = request.POST.getlist('songwriter')
        elif user.role == 'songwriter':
            artist_id = request.POST['artist']
            songwriter_id_query = f"SELECT id FROM SONGWRITER WHERE email_akun = '{user.email}'"
            songwriter_id_result = query(songwriter_id_query)
            print(songwriter_id_result)
            # songwriter_ids = [songwriter_id_result[0].id if songwriter_id_result else None]

        id_konten = str(uuid.uuid4())
        song_id = str(uuid.uuid4())

        tanggal_rilis = timezone.now().date()
        tahun = tanggal_rilis.year

        insert_konten_query = f"""
        INSERT INTO KONTEN (id, judul, tanggal_rilis, tahun, durasi)
        VALUES ('{id_konten}', '{judul}', '{tanggal_rilis}', {tahun}, {durasi});
        """
        query(insert_konten_query)

        insert_song_query = f"""
        INSERT INTO SONG (id_konten, id_artist, id_album, total_play, total_download)
        VALUES ('{id_konten}', '{artist_id}', '{album_id}', 0, 0);
        """
        query(insert_song_query)

        for songwriter_id in songwriter_ids:
            insert_songwriter_write_song_query = f"""
            INSERT INTO SONGWRITER_WRITE_SONG (id_songwriter, id_song)
            VALUES ('{songwriter_id}', '{id_konten}');
            """
            query(insert_songwriter_write_song_query)

        for genre in genre_ids:
            insert_genre_query = f"""
            INSERT INTO GENRE (id_konten, genre)
            VALUES ('{id_konten}', '{genre}');
            """
            query(insert_genre_query)

        return redirect(f'/list_songs/{album_id}') 
    songwriters_query = "SELECT id, nama FROM AKUN WHERE email IN (SELECT email_akun FROM SONGWRITER)"
    songwriters = query(songwriters_query)
    
    artists_query = "SELECT id, nama FROM AKUN WHERE email IN (SELECT email_akun FROM ARTIST)"
    artists = query(artists_query)
    
    context = {
        'user': user,
        'songwriters': songwriters,
        'artists': artists,
        'nama_album': nama_album,  # Pass album name to the context
    }
    return render(request, "create_song.html", context)


def delete_song(request, song_id):
    try:
        # Define the DELETE query
        delete_query = f"DELETE FROM SONG WHERE id_konten = '{song_id}';"

        # Execute the DELETE query
        result = query(delete_query)

        if isinstance(result, Exception):
            print("Error while deleting song:", result)
        else:
            print("Song deleted successfully!")
    except Exception as e:
        print("Error:", e)
        

def royalty(request):
    query_str = """
    SELECT k.judul AS judul_lagu, a.judul AS judul_album, s.total_play, s.total_download, 
           r.jumlah AS total_royalti
    FROM song s
    LEFT JOIN album a ON s.id_album = a.id
    LEFT JOIN konten k ON s.id_konten = k.id
    LEFT JOIN royalti r ON s.id_konten = r.id_song
    """
    
    try:
        royalties = query(query_str)
        
        if isinstance(royalties, Exception):
            raise royalties

        royalties = [{'judul_lagu': royalty.judul_lagu, 'judul_album': royalty.judul_album, 
                      'total_play': royalty.total_play, 'total_download': royalty.total_download, 
                      'total_royalti': f"Rp {royalty.total_royalti}"} 
                     for royalty in royalties]
    except Exception as e:
        return HttpResponseServerError(f"An error occurred: {e}")

    return render(request, 'royalty.html', {'royalties': royalties})