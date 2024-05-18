-- Trigger untuk Fitur Wajib

-- 1.1 trigger cek email akun
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

-- 1.2 trigger cek email label
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