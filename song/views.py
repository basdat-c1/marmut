import datetime
from django.shortcuts import render
from django.db import connection
from utils.query import query
from django.http import HttpResponseServerError
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


def play_song(request):
    context = {}
    return render(request, "play_song.html", context)

def add_song_to_playlist(request):
    context = {}
    return render(request, "add_song_to_playlist.html", context)

def add_song_to_playlist_success(request):
    context = {}
    return render(request, "add_song_to_playlist_success.html", context)

def download_song(request):
    context = {}
    return render(request, "download_song.html", context)

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