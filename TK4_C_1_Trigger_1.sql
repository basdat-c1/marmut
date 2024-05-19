-- Trigger untuk Fitur Wajib

set search_path to marmut;

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

-- 2. trigger pendaftaran pengguna baru ditetapkan sebagai non-premium
CREATE OR REPLACE FUNCTION set_pengguna_baru_sebagai_nonpremium()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO marmut.NONPREMIUM VALUES (NEW.email);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_pengguna_baru_sebagai_nonpremium_trigger
    AFTER INSERT ON marmut.AKUN
    FOR EACH ROW
EXECUTE FUNCTION set_pengguna_baru_sebagai_nonpremium();

-- Procedur untuk check dan update status premium pengguna
CREATE OR REPLACE PROCEDURE check_and_update_subscription_status(email_akun VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM premium p
        JOIN TRANSACTION t ON t.email = p.email
        WHERE p.email = email_akun
        AND t.timestamp_berakhir < current_timestamp
    ) THEN
        DELETE FROM premium WHERE email = email_akun;
        INSERT INTO nonpremium (email) VALUES (email_akun) ON CONFLICT (email) DO NOTHING;
    END IF;
END;
$$;