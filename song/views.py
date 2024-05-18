import datetime
from django.urls import reverse
from django.shortcuts import render
from django.db import connection
from utils.decorator import custom_login_required
from utils.query import query
from django.http import HttpResponseServerError, JsonResponse
from uuid import UUID
from django.shortcuts import render, redirect
from django.http import HttpResponseServerError
from django.views.decorators.csrf import csrf_exempt
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
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


from django.contrib.auth.decorators import login_required

@custom_login_required
def label_list_album(request):
    if 'is_label' in request.session and request.session['is_label']:
        logged_in_label_email = request.session.get('email')
        
        # Query to fetch album data created by the logged-in label
        query_str = f"""
        SELECT a.id, a.judul, l.nama AS label, a.jumlah_lagu, a.total_durasi
        FROM album a
        LEFT JOIN label l ON a.id_label = l.id
        WHERE l.email = '{logged_in_label_email}'
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
        return render(request, 'label_list_album.html', {'albums': albums})
    else:
        # Redirect to some error page or login page if the user is not a label
        return redirect("/login/")  # Adjust the URL as needed



def label_list_song(request):
    return render(request, 'label_list_song.html')

@custom_login_required
def create_album(request):
    # # nama = request.user.nama
    # nama_album = request.GET.get('nama_album')
    # print(nama_album)
    # album_id_query = f"SELECT id FROM ALBUM WHERE judul = '{nama_album}'"
    album_id = str(uuid.uuid4())
    print(f"id:{album_id}")
    labels = query("SELECT * FROM LABEL")
    songwriters = query("SELECT nama FROM AKUN JOIN SONGWRITER ON AKUN.email = SONGWRITER.email_akun;")
    artists = query("SELECT nama FROM AKUN JOIN ARTIST ON AKUN.email = ARTIST.email_akun;")
    genres = query("SELECT DISTINCT GENRE FROM GENRE")
    genre_names = [result.genre for result in genres]
    print(genre_names)

    if request.method == 'POST':
        judul_album = request.POST['judul_album']
        durasi = int(request.POST['durasi'])
        genre_ids = request.POST.getlist('genre')
        judul_lagu = request.POST['judul_lagu']
        label = request.POST['label']


        # # jgn di komen KALO LOGIN UDH DIIMPLEMENTASI
        if request.session['is_artist'] == True:
            artist_id_query = f"SELECT id FROM ARTIST WHERE email_akun = '{request.session['email']}'"
            artist_id_result = query(artist_id_query)
            artist_id = artist_id_result[0].id if artist_id_result else None
            print(f"artis: {artist_id}")
            songwriter_ids = request.POST.getlist('songwriter')
        elif request.session['is_songwriter'] == True:
            print(f"ini songwriter")
            artist_name = request.POST.get('artist')
            print(f"artistname:{artist_name}")
            artist_id_query = f"""
                SELECT ARTIST.id
                FROM ARTIST
                JOIN AKUN ON ARTIST.email_akun = AKUN.email
                WHERE AKUN.nama = '{artist_name}'
            """
            artist_id_results = query(artist_id_query)
            artist_id = artist_id_results[0].id if artist_id_results else None
            print(f"artistid:{artist_id}")
            songwriter_id_query = f"SELECT id FROM SONGWRITER WHERE email_akun = '{request.session['email']}'"
            songwriter_id_results = query(songwriter_id_query)
            songwriter_ids = [result.id for result in songwriter_id_results] if songwriter_id_results else []

        id_konten = str(uuid.uuid4())


        
        tanggal_rilis = timezone.now().date()
        tahun = tanggal_rilis.year
        
        # tambah trigger ga sih ini
        insert_album_query = f"""
        INSERT INTO ALBUM (id, judul, jumlah_lagu, id_label, total_durasi)
        VALUES ('{album_id}', '{judul_album}', 0, '{label}', 0);
        """
        query(insert_album_query)

        insert_konten_query = f"""
        INSERT INTO KONTEN (id, judul, tanggal_rilis, tahun, durasi)
        VALUES ('{id_konten}', '{judul_lagu}', '{tanggal_rilis}', {tahun}, {durasi});
        """
        query(insert_konten_query)

        insert_song_query = f"""
        INSERT INTO SONG (id_konten, id_artist, id_album, total_play, total_download)
        VALUES ('{id_konten}', '{artist_id}', '{album_id}', 0, 0);
        """
        query(insert_song_query)
        
        # album_id = str(uuid.uuid4())


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

        # return redirect(list_songs, uuid=album_id)
        # print(album_id)
        # album_id_str = str(album_id)
        # album_id_uuid = uuid.UUID(album_id_str)
        return redirect('song:list_songs', album_id)
    
    
    context = {
        'labels': labels,
        'songwriters': songwriters,
        'artists': artists,
        'genres': genre_names
    }
    return render(request, 'create_album.html', context)


@custom_login_required
def create_song(request, album_id):
    nama_album = request.GET.get('nama_album')  # Get album name from query parameters
    print(f"nama album: {nama_album}")

    print("album id:")
    print(album_id)
    genres = query("SELECT DISTINCT GENRE FROM GENRE")
    genre_names = [result.genre for result in genres]
    songwriters = query("SELECT nama FROM AKUN JOIN SONGWRITER ON AKUN.email = SONGWRITER.email_akun;")
    artists = query("SELECT nama FROM AKUN JOIN ARTIST ON AKUN.email = ARTIST.email_akun;")
    # artists = query(f"SELECT id FROM ARTIST WHERE email_akun = '{user.email}'")

    if request.method == 'POST':
        judul = request.POST['judul']
        durasi = int(request.POST['durasi'])
        genre_ids = request.POST.getlist('genre')


        # # jgn di komen KALO LOGIN UDH DIIMPLEMENTASI
        if request.session['is_artist'] == True:
            print(f"ini artis")
            artist_id_query = f"SELECT id FROM ARTIST WHERE email_akun = '{request.session['email']}'"
            artist_id_result = query(artist_id_query)
            artist_id = artist_id_result[0].id if artist_id_result else None
            songwriter_ids = request.POST.getlist('songwriter')
        elif request.session['is_songwriter'] == True:
            print(f"ini songwriter")
            artist_name = request.POST.get('artist')
            print(f"artistname:{artist_name}")
            artist_id_query = f"""
                SELECT ARTIST.id
                FROM ARTIST
                JOIN AKUN ON ARTIST.email_akun = AKUN.email
                WHERE AKUN.nama = '{artist_name}'
            """
            artist_id_results = query(artist_id_query)
            artist_id = artist_id_results[0].id if artist_id_results else None
            print(f"artistid:{artist_id}")
            songwriter_id_query = f"SELECT id FROM SONGWRITER WHERE email_akun = '{request.session['email']}'"
            songwriter_id_results = query(songwriter_id_query)
            songwriter_ids = [result.id for result in songwriter_id_results] if songwriter_id_results else []

        id_konten = str(uuid.uuid4())
        tanggal_rilis = timezone.now().date()
        tahun = tanggal_rilis.year

        insert_konten_query = f"""
        INSERT INTO KONTEN (id, judul, tanggal_rilis, tahun, durasi)
        VALUES ('{id_konten}', '{judul}', '{tanggal_rilis}', {tahun}, {durasi});
        """
        query(insert_konten_query)

        print(f"ini insert into song:")
        # print(f"artis name:{artist_name}")
        print(f"artis id:{artist_id}")
        print(f"konten id:{id_konten}")
        print(f"album id:{album_id}")
        print(f"songwriter: {songwriter_ids}")
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

        # return redirect(list_songs, uuid=album_id)
        print(album_id)
        album_id_str = str(album_id)
        album_id_uuid = uuid.UUID(album_id_str)
        return redirect('song:list_songs', album_id_uuid)
    
    
    context = {
        # 'user': user,
        'songwriters': songwriters,
        'artists': artists,
        'nama_album': nama_album, 
        'genres': genre_names
    }
    return render(request, "create_song.html", context)



def delete_song(request, song_id):
    try:
        # Define the DELETE query for SONG table
        delete_query_song = f"DELETE FROM SONG WHERE id_konten = '{song_id}';"
        
        # Define the DELETE query for KONTEN table
        delete_query_konten = f"DELETE FROM KONTEN WHERE id = '{song_id}';"
        
        # Retrieve the album ID before deleting the song
        album_id_query = f"SELECT id_album FROM SONG WHERE id_konten = '{song_id}';"
        album_id_result = query(album_id_query)
        album_id = album_id_result[0][0]  # Accessing the first element of the first tuple in the result

        # Execute the DELETE query for SONG table
        result_song = query(delete_query_song)

        if isinstance(result_song, Exception):
            print("Error while deleting song from SONG table:", result_song)
        else:
            print("Song deleted successfully from SONG table!")
            
        # Execute the DELETE query for KONTEN table
        result_konten = query(delete_query_konten)

        if isinstance(result_konten, Exception):
            print("Error while deleting song from KONTEN table:", result_konten)
        else:
            print("Song deleted successfully from KONTEN table!")
            
    except Exception as e:
        print("Error:", e)
    
    return redirect('song:list_songs', album_id)

def delete_album(request, album_id):
    try:
        # Define the DELETE query
        delete_query = f"DELETE FROM ALBUM WHERE id = '{album_id}';"

        # Execute the DELETE query
        result = query(delete_query)

        if isinstance(result, Exception):
            print("Error while deleting song:", result)
        else:
            print("Album deleted successfully!")
    except Exception as e:
        print("Error:", e)
    return redirect('/song/list_album/')


@custom_login_required
def royalty(request):
    user_email = request.session['email']
    print(f"email:{user_email}")
    
    # if request.session['is_label'] == True:
    if 'is_label' in request.session and request.session['is_label']:
        query_str = f"""
        SELECT k.judul AS judul_lagu, a.judul AS judul_album, s.total_play, s.total_download, 
               r.jumlah AS total_royalti
        FROM song s
        LEFT JOIN album a ON s.id_album = a.id
        LEFT JOIN konten k ON s.id_konten = k.id
        LEFT JOIN royalti r ON s.id_konten = r.id_song
        WHERE s.id_album IN (
            SELECT id FROM album WHERE id_label = (
                SELECT id FROM label WHERE email = '{user_email}'
            )
        )
        """
    else:
        query_str = ""
        # if request.session['is_songwriter'] == True:
        if 'is_songwriter' in request.session and request.session['is_songwriter']:
            query_str = f"""
            SELECT
                k.judul AS judul_lagu,
                a.judul AS judul_album,
                s.total_play,
                s.total_download,
                r.jumlah AS total_royalti
            FROM
                ROYALTI r
            JOIN
                SONG s ON r.id_song = s.id_konten
            JOIN
                KONTEN k ON s.id_konten = k.id
            JOIN
                SONGWRITER sw ON s.id_konten = sw.id
            JOIN
                ALBUM a ON s.id_album = a.id
            WHERE
                sw.email_akun = '{user_email}';

            """
        # elif request.session['is_artist'] == True:
        elif 'is_artist' in request.session and request.session['is_artist']:
            query_str = f"""
            SELECT k.judul AS judul_lagu, a.judul AS judul_album, s.total_play, s.total_download, r.jumlah AS total_royalti
            FROM ROYALTI r
            JOIN SONG s ON r.id_song = s.id_konten
            JOIN KONTEN k ON s.id_konten = k.id
            JOIN ARTIST artist ON s.id_artist = artist.id
            JOIN ALBUM a ON s.id_album = a.id
            WHERE artist.email_akun = '{user_email}';
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


@custom_login_required
def list_album(request):
    user_email = request.session.get('email')

    try:
        with connection.cursor() as cursor:
            # kalo songwriter
            cursor.execute("""
                SELECT id FROM marmut.songwriter WHERE email_akun = %s
            """, [user_email])
            songwriter_id = cursor.fetchone()

            # kalo artis
            cursor.execute("""
                SELECT id FROM marmut.artist WHERE email_akun = %s
            """, [user_email])
            artist_id = cursor.fetchone()

            if songwriter_id:
                query_str = """
                SELECT DISTINCT a.id, a.judul, l.nama AS label, a.jumlah_lagu, a.total_durasi
                FROM marmut.album a
                LEFT JOIN marmut.label l ON a.id_label = l.id
                JOIN marmut.song s ON a.id = s.id_album
                JOIN marmut.songwriter_write_song sws ON s.id_konten = sws.id_song
                WHERE sws.id_songwriter = %s
                """
                cursor.execute(query_str, [songwriter_id[0]])
            elif artist_id:
                query_str = """
                SELECT DISTINCT a.id, a.judul, l.nama AS label, a.jumlah_lagu, a.total_durasi
                FROM marmut.album a
                LEFT JOIN marmut.label l ON a.id_label = l.id
                JOIN marmut.song s ON a.id = s.id_album
                WHERE s.id_artist = %s
                """
                cursor.execute(query_str, [artist_id[0]])
            else:
                albums = []

            albums = cursor.fetchall()
            # Convert album IDs to strings
            albums = [{'id': str(album[0]), 'judul': album[1], 'label': album[2], 
                       'jumlah_lagu': album[3], 'total_durasi': album[4]} 
                      for album in albums]

    except Exception as e:
        return HttpResponseServerError(f"An error occurred: {e}")

    return render(request, 'list_album.html', {'albums': albums})
