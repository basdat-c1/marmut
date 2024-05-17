-- trigger update podcast
CREATE OR REPLACE FUNCTION update_podcast_duration()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE KONTEN
        SET durasi = (SELECT SUM(durasi) FROM EPISODE WHERE id_konten_podcast = NEW.id_konten_podcast)
        WHERE id = NEW.id_konten_podcast;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE KONTEN
        SET durasi = (SELECT SUM(durasi) FROM EPISODE WHERE id_konten_podcast = OLD.id_konten_podcast)
        WHERE id = OLD.id_konten_podcast;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_podcast_duration_trigger
AFTER INSERT OR DELETE ON EPISODE
FOR EACH ROW
EXECUTE FUNCTION update_podcast_duration();

-- trigger update album
CREATE OR REPLACE FUNCTION update_album_details()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE ALBUM
        SET total_durasi = (SELECT COALESCE(SUM(durasi), 0) FROM SONG S JOIN KONTEN K ON S.id_konten = K.id WHERE S.id_album = NEW.id_album),
            jumlah_lagu = (SELECT COUNT(*) FROM SONG WHERE id_album = NEW.id_album)
        WHERE id = NEW.id_album;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE ALBUM
        SET total_durasi = (SELECT COALESCE(SUM(durasi), 0) FROM SONG S JOIN KONTEN K ON S.id_konten = K.id WHERE S.id_album = OLD.id_album),
            jumlah_lagu = (SELECT COUNT(*) FROM SONG WHERE id_album = OLD.id_album)
        WHERE id = OLD.id_album;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_album_details_trigger
AFTER INSERT OR DELETE ON SONG
FOR EACH ROW
EXECUTE FUNCTION update_album_details();

-- trigger cek email akun
CREATE OR REPLACE FUNCTION check_email_akun()
    RETURNS TRIGGER AS
$$
DECLARE
    jumlah_email INT;
BEGIN
    jumlah_email = (SELECT COUNT(*) FROM MARMUT.AKUN WHERE LOWER(email) = LOWER(new.email));
    IF (jumlah_email > 0) THEN
        RAISE EXCEPTION 'Email %s sudah terdaftar, silahkan masukan email yang belum terdaftar', new.email;
    END IF;
    RETURN new;
END
$$
    LANGUAGE plpgsql;

CREATE TRIGGER check_email_akun_trigger
    BEFORE INSERT OR UPDATE OF email
    ON akun
    FOR EACH ROW
EXECUTE PROCEDURE check_email_akun();

-- trigger cek email label
CREATE OR REPLACE FUNCTION check_email_label()
    RETURNS TRIGGER AS
$$
DECLARE
    jumlah_email INT;
BEGIN
    jumlah_email = (SELECT COUNT(*) FROM MARMUT.LABEL WHERE LOWER(email) = LOWER(new.email));
    IF (jumlah_email > 0) THEN
        RAISE EXCEPTION 'Email %s sudah terdaftar, silahkan masukan email yang belum terdaftar', new.email;
    END IF;
    RETURN new;
END
$$
    LANGUAGE plpgsql;

CREATE TRIGGER check_email_label_trigger
    BEFORE INSERT OR UPDATE OF email
    ON LABEL
    FOR EACH ROW
EXECUTE PROCEDURE check_email_label();