--Trigger untuk fitur biru

-- 1. Trigger dan function untuk update total play song
CREATE OR REPLACE FUNCTION update_total_play_song()
    RETURNS TRIGGER AS $$
    BEGIN
        UPDATE SONG
        SET total_play = total_play + 1
        WHERE id_konten = NEW.id_song;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_total_play_song
AFTER INSERT ON PLAYLIST_SONG
FOR EACH ROW
EXECUTE FUNCTION update_total_play_song();

-- 2. Trigger dan function untuk update total download count
CREATE OR REPLACE FUNCTION update_download_count()
RETURNS TRIGGER AS $$
BEGIN
     IF (TG_OP = 'INSERT') THEN
         UPDATE SONG SET total_download = total_download + 1
         WHERE id_konten = NEW.id_song;

     ELSIF (TG_OP = 'DELETE') THEN
         UPDATE SONG SET total_download = total_download - 1
         WHERE id_konten = OLD.id_song;
     END IF;
     RETURN NEW;
 END;
$$ LANGUAGE plpgsql;

create trigger add_download_song
after insert on downloaded_song
for each row
execute function update_download_count();

create trigger decrement_download_count
after delete on downloaded_song
for each row
execute function update_download_count();