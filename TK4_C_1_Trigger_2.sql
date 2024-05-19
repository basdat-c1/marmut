-- Trigger untuk Fitur Hijau

set search_path to marmut;

-- 1. Memperbarui Atribut Durasi dan Jumlah Lagu:
CREATE OR REPLACE FUNCTION update_durasi_dan_jumlah_lagu() 
RETURNS TRIGGER AS $$
BEGIN
IF (TG_OP = 'DELETE') THEN
    UPDATE marmut.USER_PLAYLIST
    SET total_durasi = (SELECT COALESCE(SUM(marmut.KONTEN.durasi), 0) 
                        FROM marmut.PLAYLIST_SONG, marmut.KONTEN 
                        WHERE id_playlist = OLD.id_playlist AND id_song = id), 
        jumlah_lagu = (SELECT COUNT(*) 
                        FROM marmut.PLAYLIST_SONG 
                        WHERE id_playlist = OLD.id_playlist)
    WHERE id_playlist = OLD.id_playlist;
ELSIF (TG_OP = 'INSERT') THEN
    UPDATE marmut.USER_PLAYLIST
    SET total_durasi = (SELECT COALESCE(SUM(marmut.KONTEN.durasi), 0) 
                        FROM marmut.PLAYLIST_SONG, marmut.KONTEN 
                        WHERE id_playlist = NEW.id_playlist AND id_song = id), 
        jumlah_lagu = (SELECT COUNT(*) 
                        FROM marmut.PLAYLIST_SONG 
                        WHERE id_playlist = NEW.id_playlist)
    WHERE id_playlist = NEW.id_playlist;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
    
CREATE TRIGGER update_durasi_dan_jumlah_lagu_delete_trigger
AFTER DELETE ON marmut.PLAYLIST_SONG
FOR EACH ROW EXECUTE FUNCTION update_durasi_dan_jumlah_lagu();

CREATE TRIGGER update_durasi_dan_jumlah_lagu_insert_trigger
AFTER INSERT ON marmut.PLAYLIST_SONG
FOR EACH ROW EXECUTE FUNCTION update_durasi_dan_jumlah_lagu();

-- 2. Memeriksa Lagu Ganda pada Playlist:
CREATE OR REPLACE FUNCTION cek_lagu_ganda_di_playlist()
RETURNS TRIGGER AS $$
BEGIN
IF EXISTS (
    SELECT 1
    FROM marmut.PLAYLIST_SONG
    WHERE id_song = NEW.id_song AND id_playlist = NEW.id_playlist
) THEN RAISE EXCEPTION 'Lagu sudah ada di playlist';
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cek_lagu_ganda_di_playlist_trigger
BEFORE INSERT ON marmut.PLAYLIST_SONG
FOR EACH ROW
EXECUTE PROCEDURE cek_lagu_ganda_di_playlist();

-- 3. Memeriksa Lagu Ganda pada Downloaded Song:
CREATE OR REPLACE FUNCTION cek_lagu_ganda_di_downloaded()
RETURNS TRIGGER AS $$
BEGIN
IF EXISTS (
    SELECT *
    FROM marmut.DOWNLOADED_SONG
    WHERE id_song = NEW.id_song AND email_downloader = NEW.email_downloader
) THEN RAISE EXCEPTION 'Lagu sudah pernah di-download';
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cek_lagu_ganda_di_downloaded_trigger
BEFORE INSERT ON marmut.DOWNLOADED_SONG
FOR EACH ROW
EXECUTE PROCEDURE cek_lagu_ganda_di_downloaded();