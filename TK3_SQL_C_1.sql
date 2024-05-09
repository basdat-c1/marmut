-- Query untuk membuat setiap tabel

CREATE SCHEMA marmut;

SET search_path TO marmut;

CREATE TABLE AKUN (
    email                   VARCHAR(50)     PRIMARY KEY,
    password                VARCHAR(50)     NOT NULL,
    nama                    VARCHAR(100)    NOT NULL,
    gender                  INT             NOT NULL CHECK (gender IN (0, 1)),
    tempat_lahir            VARCHAR(50)     NOT NULL,
    tanggal_lahir           DATE            NOT NULL,
    is_verified             BOOLEAN         NOT NULL,
    kota_asal               VARCHAR(50)     NOT NULL
);

CREATE TABLE PAKET (
    jenis                   VARCHAR(50)     PRIMARY KEY,
    harga                   INT             NOT NULL
);

CREATE TABLE TRANSACTION (
    id                      UUID,
    jenis_paket             VARCHAR(50),
    email                   VARCHAR(50),
    timestamp_dimulai       TIMESTAMP       NOT NULL,
    timestamp_berakhir      TIMESTAMP       NOT NULL,
    metode_bayar            VARCHAR(50)     NOT NULL,
    nominal                 INT             NOT NULL,
    PRIMARY KEY (id, jenis_paket, email),
    FOREIGN KEY (jenis_paket) REFERENCES PAKET (jenis) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (email) REFERENCES AKUN (email) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PREMIUM (
    email                   VARCHAR(50)     PRIMARY KEY,
    FOREIGN KEY (email) REFERENCES AKUN (email) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE NONPREMIUM (
    email                   VARCHAR(50)     PRIMARY KEY,
    FOREIGN KEY (email) REFERENCES AKUN (email) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE KONTEN (
    id                      UUID            PRIMARY KEY,
    judul                   VARCHAR(100)    NOT NULL,
    tanggal_rilis           DATE            NOT NULL,
    tahun                   INT             NOT NULL,
    durasi                  INT             NOT NULL
);

CREATE TABLE GENRE (
    id_konten               UUID,
    genre                   VARCHAR(50),
    PRIMARY KEY (id_konten, genre),
    FOREIGN KEY (id_konten) REFERENCES KONTEN (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PODCASTER (
    email                   VARCHAR(50)     PRIMARY KEY,
    FOREIGN KEY (email) REFERENCES AKUN (email) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PODCAST (
    id_konten               UUID            PRIMARY KEY,
    email_podcaster         VARCHAR(50),
    FOREIGN KEY (id_konten) REFERENCES KONTEN (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (email_podcaster) REFERENCES PODCASTER (email) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE EPISODE (
    id_episode              UUID            PRIMARY KEY,
    id_konten_podcast       UUID,
    judul                   VARCHAR(100)    NOT NULL,
    deskripsi               VARCHAR(500)    NOT NULL,
    durasi                  INT NOT NULL,
    tanggal_rilis           DATE NOT NULL,
    FOREIGN KEY (id_konten_podcast) REFERENCES PODCAST (id_konten) ON UPDATE CASCADE ON DELETE CASCADE
);  

CREATE TABLE PEMILIK_HAK_CIPTA (
    id                      UUID            PRIMARY KEY,
    rate_royalti            INT             NOT NULL
);

CREATE TABLE ARTIST (
    id                      UUID            PRIMARY KEY,
    email_akun              VARCHAR(50),
    id_pemilik_hak_cipta    UUID,
    FOREIGN KEY (email_akun) REFERENCES AKUN (email) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_pemilik_hak_cipta) REFERENCES PEMILIK_HAK_CIPTA (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE LABEL (
    id                      UUID            PRIMARY KEY,
    nama                    VARCHAR(100)    NOT NULL,
    email                   VARCHAR(50)     NOT NULL,
    password                VARCHAR(50)     NOT NULL,
    kontak                  VARCHAR(50)     NOT NULL,
    id_pemilik_hak_cipta    UUID,
    FOREIGN KEY (id_pemilik_hak_cipta) REFERENCES PEMILIK_HAK_CIPTA (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE ALBUM (
    id                      UUID            PRIMARY KEY,
    judul                   VARCHAR(100)    NOT NULL,
    jumlah_lagu             INT NOT NULL    DEFAULT 0,
    id_label                UUID,
    total_durasi            INT NOT NULL    DEFAULT 0,
    FOREIGN KEY (id_label) REFERENCES LABEL (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE SONGWRITER (
    id                      UUID            PRIMARY KEY,
    email_akun              VARCHAR(50),
    id_pemilik_hak_cipta    UUID,
    FOREIGN KEY (email_akun) REFERENCES AKUN (email) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_pemilik_hak_cipta) REFERENCES PEMILIK_HAK_CIPTA (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE SONG (
    id_konten               UUID            PRIMARY KEY,
    id_artist               UUID,
    id_album                UUID,
    total_play              INT             NOT NULL DEFAULT 0,
    total_download          INT             NOT NULL DEFAULT 0,
    FOREIGN KEY (id_konten) REFERENCES KONTEN (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_artist) REFERENCES ARTIST (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_album) REFERENCES ALBUM (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE SONGWRITER_WRITE_SONG (
    id_songwriter           UUID,
    id_song                 UUID,
    PRIMARY KEY (id_songwriter, id_song),
    FOREIGN KEY (id_songwriter) REFERENCES SONGWRITER (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_song) REFERENCES SONG (id_konten) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE DOWNLOADED_SONG (
    id_song                 UUID,
    email_downloader        VARCHAR(50),
    PRIMARY KEY (id_song, email_downloader),
    FOREIGN KEY (id_song) REFERENCES KONTEN (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (email_downloader) REFERENCES PREMIUM (email) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PLAYLIST (
    id                      UUID            PRIMARY KEY
);

CREATE TABLE CHART (
    tipe                    VARCHAR(50)     PRIMARY KEY,
    id_playlist              UUID,
    FOREIGN KEY (id_playlist) REFERENCES PLAYLIST (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE USER_PLAYLIST (
    email_pembuat           VARCHAR(50),
    id_user_playlist        UUID,
    judul                   VARCHAR(100)    NOT NULL,
    deskripsi               VARCHAR(500)    NOT NULL,
    jumlah_lagu             INT             NOT NULL,
    tanggal_dibuat          DATE            NOT NULL,
    id_playlist             UUID,
    total_durasi            INT             NOT NULL DEFAULT 0,
    PRIMARY KEY (email_pembuat, id_user_playlist),
    FOREIGN KEY (email_pembuat) REFERENCES AKUN (email) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_playlist) REFERENCES PLAYLIST (id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE ROYALTI (
    id_pemilik_hak_cipta    UUID,
    id_song                 UUID,
    jumlah                  INT             NOT NULL,
    PRIMARY KEY (id_pemilik_hak_cipta, id_song),
    FOREIGN KEY (id_pemilik_hak_cipta) REFERENCES PEMILIK_HAK_CIPTA (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_song) REFERENCES SONG (id_konten) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE AKUN_PLAY_USER_PLAYLIST (
    email_pemain            VARCHAR(50),
    id_user_playlist        UUID,
    email_pembuat           VARCHAR(50),
    waktu                   TIMESTAMP,
    PRIMARY KEY (email_pemain, id_user_playlist, email_pembuat, waktu),
    FOREIGN KEY (email_pemain) REFERENCES AKUN (email) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_user_playlist, email_pembuat) REFERENCES USER_PLAYLIST (id_user_playlist, email_pembuat) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE AKUN_PLAY_SONG (
    email_pemain            VARCHAR(50),
    id_song                 UUID,
    waktu                   TIMESTAMP,
    PRIMARY KEY (email_pemain, id_song, waktu),
    FOREIGN KEY (email_pemain) REFERENCES AKUN (email) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_song) REFERENCES SONG (id_konten) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PLAYLIST_SONG (
    id_playlist             UUID,
    id_song                 UUID,
    PRIMARY KEY (id_playlist, id_song),
    FOREIGN KEY (id_playlist) REFERENCES PLAYLIST (id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_song) REFERENCES SONG (id_konten) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Query untuk insert dummy data pada setiap tabel

INSERT INTO AKUN VALUES
('uhill@hotmail.com', 'z!4U)paDsW0L', 'Sharon Hughes', 1, 'Palmerville', '1962-04-03', true, 'Montesville'),
('lesliemcdonald@hotmail.com', '^S1gccioo)5H', 'Kristen Lutz', 0, 'North Peterborough', '1978-06-05', true, 'Weeksfurt'),
('samuelspears@yahoo.com', '@4^OlDR2(aJH', 'Gabrielle Smith', 1, 'Stephanieville', '1982-09-01', true, 'Paultown'),
('monicacase@hotmail.com', 'lW)yFxAoWk+0', 'Christina Flores', 0, 'Matthewchester', '1961-09-25', true, 'Port Cynthia'),
('shaffertonya@hotmail.com', 'X5D0L&zEGQ(4', 'Holly Byrd', 1, 'Hartshire', '1963-04-06', true, 'Sosastad'),
('zmartin@yahoo.com', 'A35&AXl)@knW', 'Laurie Lamb', 0, 'Tonymouth', '2006-03-27', true, 'Lake Jennifer'),
('kirklaura@hotmail.com', '8V0e9OyD_Y55', 'Karen Sosa', 0, 'Lake Richardton', '2005-05-08', true, 'Woodsbury'),
('tshelton@yahoo.com', '1$9CuAi(Y#q%', 'Jonathan Graves', 0, 'Mcdanielfurt', '1995-10-30', true, 'Jamesside'),
('david32@yahoo.com', '+9$v3FjoE1nX', 'James Myers', 1, 'Aliceton', '1996-12-01', true, 'Steveton'),
('sweeneyalfred@gmail.com', '^BZHo+k+5iLv', 'William Herman', 0, 'Nicholsonbury', '1971-02-24', true, 'Smithborough'),
('michael72@hotmail.com', '87gHMpjl&Nne', 'Kristen Noble', 0, 'Tiffanyshire', '1979-04-23', true, 'North Michael'),
('brownscott@hotmail.com', '*UTV5Nwf^4l@', 'Rebecca Benton', 1, 'Leeland', '1954-12-29', true, 'Nicholasberg'),
('mooreralph@gmail.com', 'xTkg6Wm#i#kp', 'Carla Reed', 0, 'Millerhaven', '1998-10-18', true, 'South Rebecca'),       
('enunez@hotmail.com', 'nOPStwlg_*)8', 'Tracy Miller', 0, 'West Jeremy', '2005-09-17', true, 'Guerrashire'),
('freed@yahoo.com', '1A88^hUbu$)S', 'Kimberly May', 0, 'New Jared', '2002-01-11', true, 'Lake Kimberlyshire'),       
('andrewmejia@hotmail.com', 'Dq^6TqiicoL#', 'Patrick Barrett', 0, 'Danielton', '1955-08-01', true, 'East Cindy'),    
('thomas11@hotmail.com', '_3zkp(NF3@lU', 'Lori Walker', 1, 'Lake Christophertown', '2004-01-09', true, 'Johnsonchester'),
('mjohnson@gmail.com', '&QC0yD8k0epj', 'Gabriel Newman', 0, 'Jamieshire', '1954-09-03', true, 'New Joshua'),
('smithmargaret@yahoo.com', 'pp+&&s0c!8Dh', 'Anthony Wright', 0, 'New Karenbury', '1974-08-02', true, 'East Justinchester'),
('sgreer@gmail.com', '45CYEqCW#c+6', 'Heather Griffith', 1, 'South Arielmouth', '1958-06-06', true, 'Jeremychester'),
('swansonallison@gmail.com', 'WZj50Jcvf!qs', 'Jason Miller', 0, 'Lake Mary', '1973-12-07', true, 'West Timothyview'),
('jonathan28@yahoo.com', '&%DFMEM)r4YF', 'Jacqueline Smith', 1, 'South Timothy', '1963-03-10', true, 'Bernardbury'), 
('rodriguezchristopher@gmail.com', '5xhjR!$vwt_8', 'Jonathan Johnson', 1, 'New Michael', '1993-06-23', true, 'Laurenfort'),
('yyoung@hotmail.com', 'A^qp3Q&avRjn', 'Cathy Allen', 1, 'South Steven', '1977-03-12', true, 'Milesfurt'),
('jeremy32@yahoo.com', '0f$X8Q_yReN&', 'Tracey Bennett', 1, 'Elizabethmouth', '1961-06-28', true, 'Port Jerry'),     
('smithbryan@hotmail.com', 'ag3#5Obw!lPU', 'Megan Berg', 1, 'South Mistybury', '1996-09-06', true, 'New Meredithfort'),
('austinandrea@hotmail.com', '(AKHqpv^p5bB', 'Christine Vega', 1, 'South Matthew', '1968-04-03', true, 'West Juliemouth'),
('lsmith@gmail.com', 't%9UNkwwZ3H_', 'Matthew Garcia', 1, 'Jeffreymouth', '1960-08-01', true, 'Port Marissa'),       
('ruben83@hotmail.com', '+V@x3ISuSJ8s', 'Jamie Wood', 1, 'Blanchardborough', '1966-03-14', true, 'Johnsonfurt'),     
('lori81@hotmail.com', '*F$EB#fWU3a(', 'Jordan Turner', 1, 'South Christopherborough', '1978-01-17', true, 'New Robin'),
('uphelps@gmail.com', 'T61LxBw3X%G8', 'Andrew Smith', 1, 'North Michael', '1973-10-14', true, 'Andersonchester'),    
('bradfordtony@yahoo.com', '&SAm82Xd4^%b', 'Clifford Smith', 0, 'Matthewberg', '1958-11-14', true, 'Port Michelle'), 
('ghart@gmail.com', 'e$V!r0tt$Cu6', 'Judy Kelly', 1, 'Wilsonfurt', '1957-02-07', true, 'Port Crystal'),
('brandon16@hotmail.com', 'zT+^(Xfn^D7_', 'Leslie Miller', 1, 'New Cindyshire', '1962-06-17', true, 'Port April'),   
('ashley86@gmail.com', '!aG1vyQ_t+pz', 'Holly Ramos', 1, 'Jamesburgh', '1993-11-30', true, 'North Randy'),
('abell@hotmail.com', '(pnhT#tSZ2Tm', 'Zachary Wallace', 0, 'Alexandriaside', '1980-06-16', false, 'Port Heather'),  
('carla75@hotmail.com', 'MS5M&Dw32(1D', 'Andrew Mullen', 1, 'Meaganfort', '2003-04-03', false, 'Morenoville'),       
('gutierrezkenneth@gmail.com', 'b^LmfVezfi(4', 'Edward Thomas', 0, 'Lake Joyceshire', '1972-09-17', false, 'Lake Natalie'),
('gpeterson@yahoo.com', 'T5Uranw__K#*', 'Wesley Miller', 0, 'Lake Jonathanmouth', '2000-09-23', false, 'Warrenburgh'),
('melvin22@hotmail.com', 'qFJ#T%gX!M72', 'Benjamin Andrews', 0, 'New Jose', '1968-01-31', false, 'South Christina'), 
('david33@yahoo.com', 'LlxW2HOr4*s6', 'Marissa Blair', 0, 'Brownland', '1989-01-21', false, 'Wilsonton'),
('htorres@hotmail.com', 'q8QCDsFx&o2l', 'Christopher Lee', 1, 'Hendersonstad', '1979-10-18', false, 'Lake Heather'), 
('danielle77@yahoo.com', '(DC^MjGe3cGZ', 'John Long', 1, 'New Thomas', '1975-09-25', false, 'North Heather'),        
('brenda20@gmail.com', '3M2fGXQxS@^_', 'Sharon Warren', 0, 'North Karenville', '2002-04-30', false, 'Brianastad'),   
('tgray@yahoo.com', '*kOqCiap$0Ff', 'Derrick Davis', 0, 'South Austin', '1992-10-22', false, 'Port Olivia'),
('yjohnson@yahoo.com', '^9EBuDXrr^0Y', 'Alyssa Day', 0, 'East Michaeltown', '1955-09-01', false, 'Simontown'),       
('thomasbush@hotmail.com', '%tSNoRPFGS6!', 'Victoria Stevenson', 0, 'New Tiffanyfort', '1972-01-11', false, 'Amberfurt'),
('obonilla@yahoo.com', '3cLfDf6W&JJ0', 'Timothy Montgomery', 0, 'South Teresa', '1969-01-16', false, 'East David'),  
('zflores@hotmail.com', 'z7a&Sa4_&%3@', 'James Goodwin', 1, 'Sarahstad', '1989-11-28', false, 'North Brooke'),       
('dianadavis@gmail.com', 'L@KxohrK*8A4', 'Sandra Williams', 1, 'Tannershire', '1962-03-26', false, 'Wrightville');   

INSERT INTO PAKET VALUES
('1 bulan', 25000),
('3 bulan', 65000),
('6 bulan', 115000),
('1 tahun', 200000);

INSERT INTO TRANSACTION VALUES
('2bf2bdf5-5c3e-4e46-b39d-ea22b89fa642', '6 bulan', 'brownscott@hotmail.com', '2023-11-14T16:57:13.817590', '2023-11-20T16:57:13.817590', 'Bitcoin', 115000),
('e6572ea1-5714-4b70-8b54-8f27bf0cd335', '1 tahun', 'uphelps@gmail.com', '2023-11-02T16:57:13.818665', '2023-11-06T16:57:13.818665', 'PayPal', 200000),
('f49c7f9a-3b1b-4016-94f1-d25cd1b3092e', '6 bulan', 'jeremy32@yahoo.com', '2023-10-06T16:57:13.818665', '2023-10-08T16:57:13.818665', 'PayPal', 115000),
('2caffbb7-7485-45fc-a4d8-b23fc19b0a19', '3 bulan', 'ghart@gmail.com', '2024-03-25T16:57:13.818665', '2024-04-02T16:57:13.818665', 'Bitcoin', 65000),
('2efdd869-d3b6-4bda-9f4c-5b9c30d7f904', '1 tahun', 'mjohnson@gmail.com', '2024-01-06T16:57:13.818665', '2024-01-12T16:57:13.818665', 'Credit Card', 200000);

INSERT INTO PREMIUM VALUES
('jeremy32@yahoo.com'),
('brownscott@hotmail.com'),
('mjohnson@gmail.com'),
('ghart@gmail.com'),
('uphelps@gmail.com');

INSERT INTO NONPREMIUM VALUES
('uhill@hotmail.com'),
('tshelton@yahoo.com'),
('gutierrezkenneth@gmail.com'),
('lsmith@gmail.com'),
('andrewmejia@hotmail.com'),
('freed@yahoo.com'),
('brandon16@hotmail.com'),
('lori81@hotmail.com'),
('rodriguezchristopher@gmail.com'),
('samuelspears@yahoo.com'),
('shaffertonya@hotmail.com'),
('htorres@hotmail.com'),
('ashley86@gmail.com'),
('thomas11@hotmail.com'),
('danielle77@yahoo.com'),
('smithmargaret@yahoo.com'),
('carla75@hotmail.com'),
('jonathan28@yahoo.com'),
('enunez@hotmail.com'),
('lesliemcdonald@hotmail.com'),
('abell@hotmail.com'),
('thomasbush@hotmail.com'),
('sgreer@gmail.com'),
('brenda20@gmail.com'),
('yjohnson@yahoo.com');

INSERT INTO KONTEN VALUES
('504b8aac-31d1-491f-806e-b3e86587c884', 'Staff market manager also can', '2016-02-17', 1985, 64),
('8fb16fb8-ae69-40af-abf0-f0bba005c98b', 'Because possible along summer', '2020-05-31', 2017, 83),
('e3ab1934-40a0-42f1-a8e5-7d38e770d051', 'Performance this ability fill', '2020-02-25', 1999, 169),
('271765eb-5f5c-4a9e-b420-37ea61e9df1e', 'Just same need high heart', '2019-12-26', 1973, 60),
('a0f2e3d7-7048-456b-bf3b-eb599ad0c497', 'Wind inside base', '2018-11-20', 2004, 105),
('c9a97f2d-d740-4241-80f5-0d521d7bd088', 'Major gun nature office music', '2019-01-01', 1975, 29),
('97c7dba5-5cca-4442-9f76-c9f82dbddea4', 'Try cup mother point instead', '2023-12-06', 2009, 149),
('4c351ecc-4e70-44ae-a7c1-aa0174e005a5', 'Various role organization', '2015-08-07', 2019, 50),
('8414f842-24e1-4173-a4a0-708234087c7a', 'Television name happy sort college', '2022-12-14', 1993, 75),
('34ef5fb9-af0b-478d-b9f7-c72b11f7ec4b', 'Money operation court', '2024-01-07', 1977, 85),
('1f7df1d9-4fec-453c-bab6-edd7dfe120ad', 'Foot support phone', '2021-09-29', 1971, 25),
('8dc90a8d-91ce-4786-b80f-001f0ff593b0', 'And involve', '2017-10-16', 1966, 18),
('e4a1aff3-caa8-4dc2-8c9d-71b2349fd4de', 'Language receive fight clear', '2020-10-07', 1983, 140),
('47469dc4-5c43-4e0f-b153-63fb5004a471', 'People group relate', '2014-10-16', 1984, 22),
('9398b231-35aa-4ff1-bdd3-d8cad8c86ddb', 'Experience follow', '2015-04-26', 1980, 40),
('ed75eaf9-bdbd-4c14-add1-0786bffbb452', 'Card live yes various', '2017-02-20', 1962, 14),
('a5c759a2-cb02-4765-be31-7ea514b4218e', 'Break similar task affect then', '2023-03-08', 1994, 40),
('bd9b1f12-31ff-4d36-9472-33c41a9ff9ef', 'Window camera few foot', '2021-11-06', 1972, 162),
('267629ec-7334-4089-8dae-409b2d09884b', 'My enough effort about', '2016-04-25', 1997, 67),
('72530e93-c69f-406a-9c5d-6f261327ae82', 'Health around opportunity', '2021-08-13', 1998, 122),
('fbcb1132-39ee-4675-bef0-2ca4b91758c0', 'Law ahead break kid', '2015-12-07', 1983, 104),
('e3d614c6-db2a-4196-a613-d92caf301f00', 'Whole health matter', '2022-08-07', 1991, 13),
('9517cc23-85d5-4082-9e35-ece3edfa4eba', 'Value billion', '2023-06-27', 2009, 104),
('9846644b-e03b-4b9c-ad16-3cca53c318b1', 'College cover meeting area', '2020-09-26', 2015, 153),
('788b56c3-3a16-42cb-a38a-cbd1999f3e1e', 'Play sign describe fly', '2017-09-05', 2011, 17),
('9447cf25-5dfd-4ae4-90b4-e3bad465ddd0', 'Table card', '2019-04-05', 1971, 59),
('98dadb8f-dbe8-42a9-ad58-ea4470282561', 'I floor item term administration', '2015-03-06', 1972, 169),
('53ffbd1f-a19d-4618-a73e-b1c27a9e3e69', 'First choice', '2019-01-06', 2012, 76),
('4a93fc48-9c63-43b4-8cab-e6ddb380598b', 'Sort of individual shake', '2014-05-21', 1979, 170),
('046110b2-9815-4b13-b90a-b28db25a8142', 'Edge away race heavy development', '2015-06-27', 1975, 79),
('eab230c4-0953-4729-8746-7294d82c1f27', 'Really PM college left', '2015-05-29', 1985, 18),
('6762c249-0d4a-4053-8156-960084f07d27', 'Consumer fine', '2016-06-11', 2020, 96),
('aefef70a-7d90-48bf-8e7a-d95ea315ac2b', 'History public', '2016-03-28', 1964, 81),
('8f9b554c-7bde-4a0b-ba25-92adaca3a1c8', 'Wonder character', '2015-11-29', 2017, 22),
('99c217cd-0767-4e41-a65d-97fb8aa098ab', 'Level conference interest', '2023-03-26', 1988, 178),
('9c56bd40-224f-428d-add2-c0ab2e925a8a', 'Next action simply must small', '2020-03-31', 1979, 99),
('d1344557-59a6-4ad8-9a0d-ed8053542e54', 'Still kind dark cold wait', '2018-05-17', 2024, 113),
('bbb5e27f-f0c7-4635-9c3c-3670d6b102f5', 'Admit value well south', '2014-07-06', 1972, 94),
('02f059cc-042e-4fe1-aa46-aa32bdd13302', 'Kind quite', '2019-12-30', 1974, 165),
('6d62c1e0-1bbf-4a0e-84a2-c08b578796d5', 'View others church idea', '2021-09-02', 1979, 103),
('7b1184ce-202b-4593-b7ee-5808b6fe6913', 'Commercial condition yes', '2017-06-15', 2015, 25),
('3b1a696b-017e-4c93-a968-5039288a430f', 'Should local case series', '2015-05-26', 1975, 59),
('2421924c-d0ac-4d6f-a89c-5ddd3a08c1b9', 'Require back well', '2021-12-22', 2016, 145),
('99506dd7-08ec-4237-8fa3-a524fdbec3e1', 'Your growth', '2016-08-15', 1994, 142),
('2373d3a4-ac65-4b28-bd14-0cf90ee5c1c0', 'Home consumer attack public', '2024-02-26', 2000, 75),
('61c8576d-f1b4-41a5-9345-b08cade1fb29', 'Apply third interview', '2024-03-02', 1989, 144),
('3e20a42b-40d9-4b34-ac5b-69555182d131', 'Sense program attorney agent', '2019-03-22', 1977, 18),
('c8836601-03c9-4f52-a934-4d8246b429f6', 'Miss power keep', '2015-12-25', 1971, 161),
('276e8cac-d72e-416e-84dd-052e54abdac2', 'Beyond media list shake argue', '2018-06-12', 1968, 16),
('2d824b04-a2c0-4cd0-a8cb-5a6195792a55', 'Once defense', '2017-03-01', 1997, 154),
('d43a8c9b-cbd3-47bc-8876-925706027456', 'Structure father recent make', '2015-01-21', 1975, 129),
('145d1096-501b-4489-b446-8d5acdc89492', 'Sense far stage answer', '2022-12-23', 2002, 85),
('2a4f1977-3ea0-4562-b6f8-2d6f3399c80d', 'Market bit such according read', '2016-04-24', 2015, 48),
('724e4f65-cf98-48a4-b24f-ad76fc64e2a4', 'Care result', '2021-01-04', 1962, 25),
('976c61f8-ce12-4635-b898-c66830e2e72b', 'Decade teach kitchen', '2022-01-22', 1981, 5);

INSERT INTO GENRE VALUES
('504b8aac-31d1-491f-806e-b3e86587c884', 'Rock'),
('8fb16fb8-ae69-40af-abf0-f0bba005c98b', 'Country'),
('e3ab1934-40a0-42f1-a8e5-7d38e770d051', 'Country'),
('271765eb-5f5c-4a9e-b420-37ea61e9df1e', 'Classical'),
('a0f2e3d7-7048-456b-bf3b-eb599ad0c497', 'Classical'),
('c9a97f2d-d740-4241-80f5-0d521d7bd088', 'Jazz'),
('97c7dba5-5cca-4442-9f76-c9f82dbddea4', 'R&B'),
('4c351ecc-4e70-44ae-a7c1-aa0174e005a5', 'Classical'),
('8414f842-24e1-4173-a4a0-708234087c7a', 'R&B'),
('34ef5fb9-af0b-478d-b9f7-c72b11f7ec4b', 'Pop'),
('1f7df1d9-4fec-453c-bab6-edd7dfe120ad', 'Pop'),
('8dc90a8d-91ce-4786-b80f-001f0ff593b0', 'Rock'),
('e4a1aff3-caa8-4dc2-8c9d-71b2349fd4de', 'Hip Hop'),
('47469dc4-5c43-4e0f-b153-63fb5004a471', 'Classical'),
('9398b231-35aa-4ff1-bdd3-d8cad8c86ddb', 'R&B'),
('ed75eaf9-bdbd-4c14-add1-0786bffbb452', 'Country'),
('a5c759a2-cb02-4765-be31-7ea514b4218e', 'R&B'),
('bd9b1f12-31ff-4d36-9472-33c41a9ff9ef', 'Rock'),
('267629ec-7334-4089-8dae-409b2d09884b', 'Hip Hop'),
('72530e93-c69f-406a-9c5d-6f261327ae82', 'Classical'),
('fbcb1132-39ee-4675-bef0-2ca4b91758c0', 'Hip Hop'),
('e3d614c6-db2a-4196-a613-d92caf301f00', 'Country'),
('9517cc23-85d5-4082-9e35-ece3edfa4eba', 'Pop'),
('9846644b-e03b-4b9c-ad16-3cca53c318b1', 'Rock'),
('788b56c3-3a16-42cb-a38a-cbd1999f3e1e', 'Country'),
('9447cf25-5dfd-4ae4-90b4-e3bad465ddd0', 'Jazz'),
('98dadb8f-dbe8-42a9-ad58-ea4470282561', 'Pop'),
('53ffbd1f-a19d-4618-a73e-b1c27a9e3e69', 'Rock'),
('4a93fc48-9c63-43b4-8cab-e6ddb380598b', 'Classical'),
('046110b2-9815-4b13-b90a-b28db25a8142', 'Rock'),
('eab230c4-0953-4729-8746-7294d82c1f27', 'Jazz'),
('6762c249-0d4a-4053-8156-960084f07d27', 'R&B'),
('aefef70a-7d90-48bf-8e7a-d95ea315ac2b', 'Country'),
('8f9b554c-7bde-4a0b-ba25-92adaca3a1c8', 'Hip Hop'),
('99c217cd-0767-4e41-a65d-97fb8aa098ab', 'Rock'),
('9c56bd40-224f-428d-add2-c0ab2e925a8a', 'Rock'),
('d1344557-59a6-4ad8-9a0d-ed8053542e54', 'Country'),
('bbb5e27f-f0c7-4635-9c3c-3670d6b102f5', 'Jazz'),
('02f059cc-042e-4fe1-aa46-aa32bdd13302', 'Jazz'),
('6d62c1e0-1bbf-4a0e-84a2-c08b578796d5', 'Rock'),
('7b1184ce-202b-4593-b7ee-5808b6fe6913', 'Horror'),
('3b1a696b-017e-4c93-a968-5039288a430f', 'Horror'),
('2421924c-d0ac-4d6f-a89c-5ddd3a08c1b9', 'Comedy'),
('99506dd7-08ec-4237-8fa3-a524fdbec3e1', 'Horror'),
('2373d3a4-ac65-4b28-bd14-0cf90ee5c1c0', 'Horror'),
('61c8576d-f1b4-41a5-9345-b08cade1fb29', 'Comedy'),
('3e20a42b-40d9-4b34-ac5b-69555182d131', 'Horror'),
('c8836601-03c9-4f52-a934-4d8246b429f6', 'Horror'),
('276e8cac-d72e-416e-84dd-052e54abdac2', 'Motivation'),
('2d824b04-a2c0-4cd0-a8cb-5a6195792a55', 'Horror'),
('d43a8c9b-cbd3-47bc-8876-925706027456', 'Horror'),
('145d1096-501b-4489-b446-8d5acdc89492', 'Motivation'),
('2a4f1977-3ea0-4562-b6f8-2d6f3399c80d', 'Motivation'),
('724e4f65-cf98-48a4-b24f-ad76fc64e2a4', 'Comedy'),
('976c61f8-ce12-4635-b898-c66830e2e72b', 'Comedy'),
('145d1096-501b-4489-b446-8d5acdc89492', 'Country'),
('d43a8c9b-cbd3-47bc-8876-925706027456', 'Hip Hop'),
('9517cc23-85d5-4082-9e35-ece3edfa4eba', 'Rock'),
('9846644b-e03b-4b9c-ad16-3cca53c318b1', 'Jazz'),
('72530e93-c69f-406a-9c5d-6f261327ae82', 'Motivation');

INSERT INTO PODCASTER VALUES
('sweeneyalfred@gmail.com'),
('ruben83@hotmail.com'),
('thomas11@hotmail.com'),
('gpeterson@yahoo.com'),
('yyoung@hotmail.com'),
('ashley86@gmail.com'),
('uhill@hotmail.com'),
('shaffertonya@hotmail.com'),
('mjohnson@gmail.com'),
('lori81@hotmail.com');

INSERT INTO PODCAST VALUES
('504b8aac-31d1-491f-806e-b3e86587c884', 'uhill@hotmail.com'),
('8fb16fb8-ae69-40af-abf0-f0bba005c98b', 'uhill@hotmail.com'),
('e3ab1934-40a0-42f1-a8e5-7d38e770d051', 'sweeneyalfred@gmail.com'),
('271765eb-5f5c-4a9e-b420-37ea61e9df1e', 'shaffertonya@hotmail.com'),
('a0f2e3d7-7048-456b-bf3b-eb599ad0c497', 'ashley86@gmail.com');

INSERT INTO EPISODE VALUES
('7fbd843b-c409-4e93-9476-d6cecaa0aa98', '504b8aac-31d1-491f-806e-b3e86587c884', 'It machine happen', 'Really book check production deep recognize. Also learn cover. Financial base nation improve look social send line.', 166, '2024-04-27'),
('86781289-dc4b-4644-90c9-1748b64000b5', 'e3ab1934-40a0-42f1-a8e5-7d38e770d051', 'Receive must business', 'Wait where entire year around. Score could eight deal so provide class. Tv foreign exactly unit example simply have.', 66, '2024-04-26'),
('05c054fe-df98-4788-b495-204861d50c49', 'e3ab1934-40a0-42f1-a8e5-7d38e770d051', 'First at participant', 'Identify wall expect heavy hair message step. Reason economy race process.', 111, '2024-04-25'),
('a5a0bd93-dcc4-45ba-a02e-f569858c756b', '8fb16fb8-ae69-40af-abf0-f0bba005c98b', 'Or PM big', 'Drug phone with class whom act entire. Clear TV expert open truth human.', 43, '2024-04-24'),
('0e84ce2a-6636-4084-8e38-5c8207d86986', '504b8aac-31d1-491f-806e-b3e86587c884', 'Generation radio', 'Training throw trip quite end end. She picture difference book.', 174, '2024-04-23'),
('2f84448e-db2f-41bb-b110-7de2c4e9fd72', '8fb16fb8-ae69-40af-abf0-f0bba005c98b', 'Move', 'Per use just go society state. Send ready man support.', 172, '2024-04-22'),
('4709a30d-d083-4f8b-a875-4140904c4713', 'e3ab1934-40a0-42f1-a8e5-7d38e770d051', 'Nice mother', 'There social race morning strategy. Onto since room painting myself. Get between career teacher without television student.', 130, '2024-04-21'),
('f76c45fc-ad7a-45e4-bd5e-4231356c35e9', 'a0f2e3d7-7048-456b-bf3b-eb599ad0c497', 'Race deep', 'When place our she see law. Wonder according though Mrs miss. Hit clearly moment less.', 52, '2024-04-20'),
('28da1fa1-816b-4f86-af89-e782850fbe48', '271765eb-5f5c-4a9e-b420-37ea61e9df1e', 'President happy', 'After and garden fill gas perform. Green direction town social. Bill war minute half level own change. Action tend his process hot hold.', 112, '2024-04-19'),
('ba6d4e13-8131-43dc-a547-a7fb4c913fad', '271765eb-5f5c-4a9e-b420-37ea61e9df1e', 'Assume movement woman rather', 'Example practice executive before its east represent. Age store sport media matter professor least.', 148, '2024-04-18');

INSERT INTO PEMILIK_HAK_CIPTA VALUES
('de920323-5188-4a1e-8bbe-348f23b47c85', 510),
('6b41392f-77b8-412a-b237-b21289a90e09', 670),
('c270a663-5697-44cf-abe6-86b9a3dc07ff', 765),
('89874632-b668-42f6-8dd5-e6a5c0f814e0', 796),
('f419a029-babd-4187-adb5-3fe70e679ecd', 842),
('9b1fd25f-9736-4bc4-af17-47b22ae5f0a9', 739),
('c3740d4c-66f2-490e-aae9-9c3478d79974', 845),
('5e192714-4251-473c-902b-29136093a6e4', 880),
('1f715ad1-2128-4d2f-80a7-ff3730df7f17', 722),
('4829e825-723e-4873-82f1-2a304daad3c6', 794),
('4cfffc78-7043-4bea-afee-abf704431393', 746),
('16a1ab22-8e4b-452a-ac21-cd7ff4bc86f3', 852),
('9b233ebd-80ec-4d84-b1eb-ba3bf7ecc438', 726),
('f3a228a5-430e-4a33-ae10-f12b1de8e4b0', 775),
('2b7a0f96-1800-459e-8278-0d5e72787c1f', 827),
('c1b3e4a3-18ea-416c-b0c9-77f3f61ec58f', 530),
('f83192ac-7647-4fdf-9ba0-d73c4824edaa', 640),
('f047202f-9edb-4082-b59d-662da23e9a0d', 535),
('d7a7996d-6ccc-42e7-9d97-da9cd71c70ca', 737),
('80978615-bacc-4db4-abce-969e2ecdbfbd', 608),
('8535c3b0-12cb-4c6b-9e20-2814a0765edc', 882),
('ac5e28fd-69ca-4d62-9e78-8a99da9836d9', 848),
('5fd427cb-5068-49c1-a915-779bd4a0d985', 658),
('2a0c204f-2fa7-4c21-b290-471cd5b1a7c9', 605),
('c39f30a3-fec9-4924-a818-c1a421abfb5d', 581);

INSERT INTO ARTIST VALUES
('b0915464-7af4-4a60-a5c0-476889f7bcc6', 'obonilla@yahoo.com', 'f83192ac-7647-4fdf-9ba0-d73c4824edaa'),
('01e9de1c-aacc-439c-a6fb-a74b5bb97d6d', 'smithbryan@hotmail.com', '5fd427cb-5068-49c1-a915-779bd4a0d985'),
('c2ae5735-e819-41c9-ba12-484d2f0e0fb2', 'bradfordtony@yahoo.com', '9b233ebd-80ec-4d84-b1eb-ba3bf7ecc438'),
('f5dbe79e-9326-403a-a666-97ef82992724', 'uphelps@gmail.com', 'f419a029-babd-4187-adb5-3fe70e679ecd'),
('7177f883-9964-49eb-8030-92edf0ac7534', 'thomasbush@hotmail.com', '8535c3b0-12cb-4c6b-9e20-2814a0765edc'),
('de5b43a0-f8a0-4f53-baeb-246ac124ad19', 'tgray@yahoo.com', 'f3a228a5-430e-4a33-ae10-f12b1de8e4b0'),
('fada00a8-aff5-4484-adf8-2859dea79484', 'dianadavis@gmail.com', 'c1b3e4a3-18ea-416c-b0c9-77f3f61ec58f'),
('2a5a519e-3510-49f5-b1ce-af5d3006f9f8', 'kirklaura@hotmail.com', '89874632-b668-42f6-8dd5-e6a5c0f814e0'),
('c1709a0f-aa7f-4861-8d0a-a4cbe49052f2', 'sweeneyalfred@gmail.com', 'c1b3e4a3-18ea-416c-b0c9-77f3f61ec58f'),
('2c886c1e-6a40-465e-a20a-fb5724fd7a7d', 'freed@yahoo.com', '2a0c204f-2fa7-4c21-b290-471cd5b1a7c9');

INSERT INTO LABEL VALUES
('e39fd481-1d7b-4601-81a3-d55e6891fffc', 'Duncan Inc', 'gloria68@gmail.com', '#*!EbEvV07%^', '699.502.4881', 'f047202f-9edb-4082-b59d-662da23e9a0d'),
('9ef50e6f-75fe-4b97-84a9-d48e9f77eb4d', 'Shaw, Gonzalez and Brown', 'turnerjody@hotmail.com', 'x3y*eIAV#7Vo', '001-597-603-5934x94832', 'c3740d4c-66f2-490e-aae9-9c3478d79974'),
('e3fdb218-3ef4-4a79-adea-0c79da18669b', 'Chavez Ltd', 'manningchristopher@hotmail.com', 'TwQccIP_$6Ue', '001-431-819-3572x0392', 'c1b3e4a3-18ea-416c-b0c9-77f3f61ec58f'),
('b1f7351f-aca9-4b51-b815-e6b36e13c9e8', 'Olson, Holland and Mcdonald', 'wjohnson@yahoo.com', '3_I)n*Z_Tj$B', '(890)533-5351x21420', '80978615-bacc-4db4-abce-969e2ecdbfbd'),
('c855730b-bcbb-4cf6-b951-424f8c97b15d', 'Wilson and Sons', 'trobertson@gmail.com', 'DDZ$(r1zOb4M', '+1-481-837-5010x98864', '6b41392f-77b8-412a-b237-b21289a90e09');

INSERT INTO ALBUM VALUES
('ddaf20cb-a9d6-4b89-84c9-264b578ef4b2', 'Horizontal 5thgeneration matrices', 99, 'e39fd481-1d7b-4601-81a3-d55e6891fffc', 402),
('1817e9bd-2b6e-4836-a5eb-2b19508d6379', 'User-centric discrete standardization', 66, '9ef50e6f-75fe-4b97-84a9-d48e9f77eb4d', 191),
('eb30c5aa-f3fc-4719-bad3-5554b6517ae8', 'Total holistic encoding', 24, 'e3fdb218-3ef4-4a79-adea-0c79da18669b', 404),
('a2ad6a94-f760-47fc-b75c-b5ab3977a341', 'Universal solution-oriented monitoring', 28, 'b1f7351f-aca9-4b51-b815-e6b36e13c9e8', 243),
('adc9cf65-e7a9-4b22-a003-5f4da4039081', 'Managed bi-directional Graphical User Interface', 12, 'c855730b-bcbb-4cf6-b951-424f8c97b15d', 373);

INSERT INTO SONGWRITER VALUES
('31fb9aa6-cd37-43c1-9332-0baefd2c1164', 'brownscott@hotmail.com', '5fd427cb-5068-49c1-a915-779bd4a0d985'),
('871df8d1-b718-4a9d-8a5f-143672728b91', 'thomas11@hotmail.com', 'c270a663-5697-44cf-abe6-86b9a3dc07ff'),
('3cfdb40a-cfac-4222-90ed-0ad9f5fb59f4', 'andrewmejia@hotmail.com', 'f419a029-babd-4187-adb5-3fe70e679ecd'),
('033fdc38-1dc9-4239-997b-483e270dfc7d', 'kirklaura@hotmail.com', 'c39f30a3-fec9-4924-a818-c1a421abfb5d'),
('6fa49047-0c29-4fc8-aa09-0f5c91037a74', 'danielle77@yahoo.com', '80978615-bacc-4db4-abce-969e2ecdbfbd'),
('d01634e6-95bf-4bda-8833-c94a776f53cc', 'zmartin@yahoo.com', '4829e825-723e-4873-82f1-2a304daad3c6'),
('2f7ea27b-5780-4920-a3cd-3eca0e32c30c', 'david32@yahoo.com', '2b7a0f96-1800-459e-8278-0d5e72787c1f'),
('a5b5c975-6a87-4678-9a03-c16f4ef1b4b3', 'thomasbush@hotmail.com', '80978615-bacc-4db4-abce-969e2ecdbfbd'),
('a81ce133-a745-44dc-a52c-9d51c06b82ed', 'gpeterson@yahoo.com', '4829e825-723e-4873-82f1-2a304daad3c6'),
('5bea6d78-11a1-4637-ad78-4f8b00caba30', 'bradfordtony@yahoo.com', '16a1ab22-8e4b-452a-ac21-cd7ff4bc86f3');

INSERT INTO SONG VALUES
('504b8aac-31d1-491f-806e-b3e86587c884', '01e9de1c-aacc-439c-a6fb-a74b5bb97d6d', 'ddaf20cb-a9d6-4b89-84c9-264b578ef4b2', 75564156, 51231322),
('8fb16fb8-ae69-40af-abf0-f0bba005c98b', 'fada00a8-aff5-4484-adf8-2859dea79484', '1817e9bd-2b6e-4836-a5eb-2b19508d6379', 96243184, 61651351),
('e3ab1934-40a0-42f1-a8e5-7d38e770d051', 'f5dbe79e-9326-403a-a666-97ef82992724', 'a2ad6a94-f760-47fc-b75c-b5ab3977a341', 46821247, 20593408),
('271765eb-5f5c-4a9e-b420-37ea61e9df1e', 'c1709a0f-aa7f-4861-8d0a-a4cbe49052f2', 'a2ad6a94-f760-47fc-b75c-b5ab3977a341', 53774418, 28349846),
('a0f2e3d7-7048-456b-bf3b-eb599ad0c497', 'c2ae5735-e819-41c9-ba12-484d2f0e0fb2', 'ddaf20cb-a9d6-4b89-84c9-264b578ef4b2', 10446132, 956872),
('c9a97f2d-d740-4241-80f5-0d521d7bd088', 'f5dbe79e-9326-403a-a666-97ef82992724', 'eb30c5aa-f3fc-4719-bad3-5554b6517ae8', 30055395, 22431034),
('97c7dba5-5cca-4442-9f76-c9f82dbddea4', 'f5dbe79e-9326-403a-a666-97ef82992724', 'ddaf20cb-a9d6-4b89-84c9-264b578ef4b2', 43975944, 43749369),
('4c351ecc-4e70-44ae-a7c1-aa0174e005a5', '2a5a519e-3510-49f5-b1ce-af5d3006f9f8', 'adc9cf65-e7a9-4b22-a003-5f4da4039081', 76679303, 42186085),
('8414f842-24e1-4173-a4a0-708234087c7a', 'f5dbe79e-9326-403a-a666-97ef82992724', 'a2ad6a94-f760-47fc-b75c-b5ab3977a341', 48300616, 45074570),
('34ef5fb9-af0b-478d-b9f7-c72b11f7ec4b', '2c886c1e-6a40-465e-a20a-fb5724fd7a7d', '1817e9bd-2b6e-4836-a5eb-2b19508d6379', 93707398, 58968140),
('1f7df1d9-4fec-453c-bab6-edd7dfe120ad', 'fada00a8-aff5-4484-adf8-2859dea79484', 'adc9cf65-e7a9-4b22-a003-5f4da4039081', 93054329, 62004946),
('8dc90a8d-91ce-4786-b80f-001f0ff593b0', 'b0915464-7af4-4a60-a5c0-476889f7bcc6', 'a2ad6a94-f760-47fc-b75c-b5ab3977a341', 81506768, 44494412),
('e4a1aff3-caa8-4dc2-8c9d-71b2349fd4de', 'c2ae5735-e819-41c9-ba12-484d2f0e0fb2', 'ddaf20cb-a9d6-4b89-84c9-264b578ef4b2', 64729232, 15709516),
('47469dc4-5c43-4e0f-b153-63fb5004a471', 'c2ae5735-e819-41c9-ba12-484d2f0e0fb2', 'eb30c5aa-f3fc-4719-bad3-5554b6517ae8', 46824548, 46025591),
('9398b231-35aa-4ff1-bdd3-d8cad8c86ddb', 'f5dbe79e-9326-403a-a666-97ef82992724', 'a2ad6a94-f760-47fc-b75c-b5ab3977a341', 22849091, 22341973),
('ed75eaf9-bdbd-4c14-add1-0786bffbb452', 'de5b43a0-f8a0-4f53-baeb-246ac124ad19', 'a2ad6a94-f760-47fc-b75c-b5ab3977a341', 99393440, 80676699),
('a5c759a2-cb02-4765-be31-7ea514b4218e', '2c886c1e-6a40-465e-a20a-fb5724fd7a7d', 'eb30c5aa-f3fc-4719-bad3-5554b6517ae8', 61528920, 21913842),
('bd9b1f12-31ff-4d36-9472-33c41a9ff9ef', 'de5b43a0-f8a0-4f53-baeb-246ac124ad19', 'a2ad6a94-f760-47fc-b75c-b5ab3977a341', 60233213, 34254744),
('267629ec-7334-4089-8dae-409b2d09884b', '01e9de1c-aacc-439c-a6fb-a74b5bb97d6d', 'eb30c5aa-f3fc-4719-bad3-5554b6517ae8', 61441040, 16870580),
('72530e93-c69f-406a-9c5d-6f261327ae82', '2a5a519e-3510-49f5-b1ce-af5d3006f9f8', '1817e9bd-2b6e-4836-a5eb-2b19508d6379', 58794730, 4987562),
('fbcb1132-39ee-4675-bef0-2ca4b91758c0', 'b0915464-7af4-4a60-a5c0-476889f7bcc6', 'eb30c5aa-f3fc-4719-bad3-5554b6517ae8', 37535431, 36626076),
('e3d614c6-db2a-4196-a613-d92caf301f00', 'f5dbe79e-9326-403a-a666-97ef82992724', 'eb30c5aa-f3fc-4719-bad3-5554b6517ae8', 18651261, 228276),
('9517cc23-85d5-4082-9e35-ece3edfa4eba', '01e9de1c-aacc-439c-a6fb-a74b5bb97d6d', '1817e9bd-2b6e-4836-a5eb-2b19508d6379', 20394216, 9960924),
('9846644b-e03b-4b9c-ad16-3cca53c318b1', 'b0915464-7af4-4a60-a5c0-476889f7bcc6', 'ddaf20cb-a9d6-4b89-84c9-264b578ef4b2', 82691749, 2613720),
('788b56c3-3a16-42cb-a38a-cbd1999f3e1e', '2c886c1e-6a40-465e-a20a-fb5724fd7a7d', 'adc9cf65-e7a9-4b22-a003-5f4da4039081', 44133088, 1109933),
('9447cf25-5dfd-4ae4-90b4-e3bad465ddd0', '2a5a519e-3510-49f5-b1ce-af5d3006f9f8', 'ddaf20cb-a9d6-4b89-84c9-264b578ef4b2', 57498141, 18650161),
('98dadb8f-dbe8-42a9-ad58-ea4470282561', 'c2ae5735-e819-41c9-ba12-484d2f0e0fb2', 'a2ad6a94-f760-47fc-b75c-b5ab3977a341', 24996995, 10854638),
('53ffbd1f-a19d-4618-a73e-b1c27a9e3e69', '2c886c1e-6a40-465e-a20a-fb5724fd7a7d', 'adc9cf65-e7a9-4b22-a003-5f4da4039081', 7971648, 158442),
('4a93fc48-9c63-43b4-8cab-e6ddb380598b', 'de5b43a0-f8a0-4f53-baeb-246ac124ad19', 'eb30c5aa-f3fc-4719-bad3-5554b6517ae8', 26725433, 15367766),
('046110b2-9815-4b13-b90a-b28db25a8142', 'f5dbe79e-9326-403a-a666-97ef82992724', '1817e9bd-2b6e-4836-a5eb-2b19508d6379', 37747326, 25817504),
('eab230c4-0953-4729-8746-7294d82c1f27', '01e9de1c-aacc-439c-a6fb-a74b5bb97d6d', 'eb30c5aa-f3fc-4719-bad3-5554b6517ae8', 26800711, 23344074),
('6762c249-0d4a-4053-8156-960084f07d27', '01e9de1c-aacc-439c-a6fb-a74b5bb97d6d', '1817e9bd-2b6e-4836-a5eb-2b19508d6379', 92241044, 39185273),
('aefef70a-7d90-48bf-8e7a-d95ea315ac2b', 'c2ae5735-e819-41c9-ba12-484d2f0e0fb2', 'ddaf20cb-a9d6-4b89-84c9-264b578ef4b2', 83091930, 40815237),
('8f9b554c-7bde-4a0b-ba25-92adaca3a1c8', 'de5b43a0-f8a0-4f53-baeb-246ac124ad19', 'a2ad6a94-f760-47fc-b75c-b5ab3977a341', 69396384, 38854131),
('99c217cd-0767-4e41-a65d-97fb8aa098ab', '01e9de1c-aacc-439c-a6fb-a74b5bb97d6d', '1817e9bd-2b6e-4836-a5eb-2b19508d6379', 44136014, 16004147),
('9c56bd40-224f-428d-add2-c0ab2e925a8a', 'c1709a0f-aa7f-4861-8d0a-a4cbe49052f2', 'adc9cf65-e7a9-4b22-a003-5f4da4039081', 3438550, 2347902),
('d1344557-59a6-4ad8-9a0d-ed8053542e54', 'de5b43a0-f8a0-4f53-baeb-246ac124ad19', '1817e9bd-2b6e-4836-a5eb-2b19508d6379', 52205426, 41858944),
('bbb5e27f-f0c7-4635-9c3c-3670d6b102f5', 'f5dbe79e-9326-403a-a666-97ef82992724', '1817e9bd-2b6e-4836-a5eb-2b19508d6379', 63416207, 19669962),
('02f059cc-042e-4fe1-aa46-aa32bdd13302', 'de5b43a0-f8a0-4f53-baeb-246ac124ad19', '1817e9bd-2b6e-4836-a5eb-2b19508d6379', 5877937, 2378012),
('6d62c1e0-1bbf-4a0e-84a2-c08b578796d5', '2a5a519e-3510-49f5-b1ce-af5d3006f9f8', '1817e9bd-2b6e-4836-a5eb-2b19508d6379', 46297967, 36140488),
('7b1184ce-202b-4593-b7ee-5808b6fe6913', '2a5a519e-3510-49f5-b1ce-af5d3006f9f8', 'ddaf20cb-a9d6-4b89-84c9-264b578ef4b2', 37325113, 11175154),
('3b1a696b-017e-4c93-a968-5039288a430f', 'f5dbe79e-9326-403a-a666-97ef82992724', 'ddaf20cb-a9d6-4b89-84c9-264b578ef4b2', 28266250, 2077785),
('2421924c-d0ac-4d6f-a89c-5ddd3a08c1b9', 'f5dbe79e-9326-403a-a666-97ef82992724', 'a2ad6a94-f760-47fc-b75c-b5ab3977a341', 23582727, 2724434),
('99506dd7-08ec-4237-8fa3-a524fdbec3e1', '01e9de1c-aacc-439c-a6fb-a74b5bb97d6d', '1817e9bd-2b6e-4836-a5eb-2b19508d6379', 67430277, 15069075),
('2373d3a4-ac65-4b28-bd14-0cf90ee5c1c0', 'f5dbe79e-9326-403a-a666-97ef82992724', 'eb30c5aa-f3fc-4719-bad3-5554b6517ae8', 34719377, 14320497),
('61c8576d-f1b4-41a5-9345-b08cade1fb29', 'c1709a0f-aa7f-4861-8d0a-a4cbe49052f2', 'ddaf20cb-a9d6-4b89-84c9-264b578ef4b2', 16041911, 13002015),
('3e20a42b-40d9-4b34-ac5b-69555182d131', '2c886c1e-6a40-465e-a20a-fb5724fd7a7d', 'ddaf20cb-a9d6-4b89-84c9-264b578ef4b2', 87205927, 36536197),
('c8836601-03c9-4f52-a934-4d8246b429f6', 'b0915464-7af4-4a60-a5c0-476889f7bcc6', '1817e9bd-2b6e-4836-a5eb-2b19508d6379', 41476646, 41080474),
('276e8cac-d72e-416e-84dd-052e54abdac2', 'de5b43a0-f8a0-4f53-baeb-246ac124ad19', '1817e9bd-2b6e-4836-a5eb-2b19508d6379', 75764114, 12051022),
('2d824b04-a2c0-4cd0-a8cb-5a6195792a55', 'fada00a8-aff5-4484-adf8-2859dea79484', 'a2ad6a94-f760-47fc-b75c-b5ab3977a341', 60018598, 54934735);

INSERT INTO SONGWRITER_WRITE_SONG VALUES
('871df8d1-b718-4a9d-8a5f-143672728b91', '8414f842-24e1-4173-a4a0-708234087c7a'),
('6fa49047-0c29-4fc8-aa09-0f5c91037a74', 'bd9b1f12-31ff-4d36-9472-33c41a9ff9ef'),
('5bea6d78-11a1-4637-ad78-4f8b00caba30', '3e20a42b-40d9-4b34-ac5b-69555182d131'),
('033fdc38-1dc9-4239-997b-483e270dfc7d', '99c217cd-0767-4e41-a65d-97fb8aa098ab'),
('31fb9aa6-cd37-43c1-9332-0baefd2c1164', '4c351ecc-4e70-44ae-a7c1-aa0174e005a5'),
('871df8d1-b718-4a9d-8a5f-143672728b91', '8fb16fb8-ae69-40af-abf0-f0bba005c98b'),
('a5b5c975-6a87-4678-9a03-c16f4ef1b4b3', 'eab230c4-0953-4729-8746-7294d82c1f27'),
('2f7ea27b-5780-4920-a3cd-3eca0e32c30c', '6762c249-0d4a-4053-8156-960084f07d27'),
('033fdc38-1dc9-4239-997b-483e270dfc7d', '504b8aac-31d1-491f-806e-b3e86587c884'),
('033fdc38-1dc9-4239-997b-483e270dfc7d', '3b1a696b-017e-4c93-a968-5039288a430f'),
('a81ce133-a745-44dc-a52c-9d51c06b82ed', '2373d3a4-ac65-4b28-bd14-0cf90ee5c1c0'),
('5bea6d78-11a1-4637-ad78-4f8b00caba30', '276e8cac-d72e-416e-84dd-052e54abdac2'),
('5bea6d78-11a1-4637-ad78-4f8b00caba30', '9517cc23-85d5-4082-9e35-ece3edfa4eba'),
('3cfdb40a-cfac-4222-90ed-0ad9f5fb59f4', '8414f842-24e1-4173-a4a0-708234087c7a'),
('871df8d1-b718-4a9d-8a5f-143672728b91', '2421924c-d0ac-4d6f-a89c-5ddd3a08c1b9'),
('2f7ea27b-5780-4920-a3cd-3eca0e32c30c', '267629ec-7334-4089-8dae-409b2d09884b'),
('871df8d1-b718-4a9d-8a5f-143672728b91', '9c56bd40-224f-428d-add2-c0ab2e925a8a'),
('033fdc38-1dc9-4239-997b-483e270dfc7d', '1f7df1d9-4fec-453c-bab6-edd7dfe120ad'),
('3cfdb40a-cfac-4222-90ed-0ad9f5fb59f4', '99506dd7-08ec-4237-8fa3-a524fdbec3e1'),
('033fdc38-1dc9-4239-997b-483e270dfc7d', '4c351ecc-4e70-44ae-a7c1-aa0174e005a5'),
('a81ce133-a745-44dc-a52c-9d51c06b82ed', '6d62c1e0-1bbf-4a0e-84a2-c08b578796d5'),
('033fdc38-1dc9-4239-997b-483e270dfc7d', '9398b231-35aa-4ff1-bdd3-d8cad8c86ddb'),
('5bea6d78-11a1-4637-ad78-4f8b00caba30', '53ffbd1f-a19d-4618-a73e-b1c27a9e3e69'),
('a5b5c975-6a87-4678-9a03-c16f4ef1b4b3', 'ed75eaf9-bdbd-4c14-add1-0786bffbb452'),
('3cfdb40a-cfac-4222-90ed-0ad9f5fb59f4', '6762c249-0d4a-4053-8156-960084f07d27'),
('2f7ea27b-5780-4920-a3cd-3eca0e32c30c', '1f7df1d9-4fec-453c-bab6-edd7dfe120ad'),
('31fb9aa6-cd37-43c1-9332-0baefd2c1164', 'bd9b1f12-31ff-4d36-9472-33c41a9ff9ef'),
('033fdc38-1dc9-4239-997b-483e270dfc7d', '7b1184ce-202b-4593-b7ee-5808b6fe6913'),
('033fdc38-1dc9-4239-997b-483e270dfc7d', '02f059cc-042e-4fe1-aa46-aa32bdd13302'),
('5bea6d78-11a1-4637-ad78-4f8b00caba30', 'e4a1aff3-caa8-4dc2-8c9d-71b2349fd4de'),
('31fb9aa6-cd37-43c1-9332-0baefd2c1164', 'e3d614c6-db2a-4196-a613-d92caf301f00'),
('d01634e6-95bf-4bda-8833-c94a776f53cc', '8f9b554c-7bde-4a0b-ba25-92adaca3a1c8'),
('033fdc38-1dc9-4239-997b-483e270dfc7d', 'c8836601-03c9-4f52-a934-4d8246b429f6'),
('2f7ea27b-5780-4920-a3cd-3eca0e32c30c', '34ef5fb9-af0b-478d-b9f7-c72b11f7ec4b'),
('3cfdb40a-cfac-4222-90ed-0ad9f5fb59f4', 'bbb5e27f-f0c7-4635-9c3c-3670d6b102f5'),
('2f7ea27b-5780-4920-a3cd-3eca0e32c30c', '02f059cc-042e-4fe1-aa46-aa32bdd13302'),
('871df8d1-b718-4a9d-8a5f-143672728b91', '8dc90a8d-91ce-4786-b80f-001f0ff593b0'),
('6fa49047-0c29-4fc8-aa09-0f5c91037a74', '2421924c-d0ac-4d6f-a89c-5ddd3a08c1b9'),
('a5b5c975-6a87-4678-9a03-c16f4ef1b4b3', '72530e93-c69f-406a-9c5d-6f261327ae82'),
('3cfdb40a-cfac-4222-90ed-0ad9f5fb59f4', '276e8cac-d72e-416e-84dd-052e54abdac2'),
('5bea6d78-11a1-4637-ad78-4f8b00caba30', '6d62c1e0-1bbf-4a0e-84a2-c08b578796d5'),
('31fb9aa6-cd37-43c1-9332-0baefd2c1164', '6762c249-0d4a-4053-8156-960084f07d27'),
('a5b5c975-6a87-4678-9a03-c16f4ef1b4b3', 'aefef70a-7d90-48bf-8e7a-d95ea315ac2b'),
('871df8d1-b718-4a9d-8a5f-143672728b91', '99506dd7-08ec-4237-8fa3-a524fdbec3e1'),
('6fa49047-0c29-4fc8-aa09-0f5c91037a74', 'aefef70a-7d90-48bf-8e7a-d95ea315ac2b'),
('5bea6d78-11a1-4637-ad78-4f8b00caba30', '8414f842-24e1-4173-a4a0-708234087c7a'),
('d01634e6-95bf-4bda-8833-c94a776f53cc', 'bbb5e27f-f0c7-4635-9c3c-3670d6b102f5'),
('5bea6d78-11a1-4637-ad78-4f8b00caba30', 'ed75eaf9-bdbd-4c14-add1-0786bffbb452'),
('3cfdb40a-cfac-4222-90ed-0ad9f5fb59f4', '4c351ecc-4e70-44ae-a7c1-aa0174e005a5'),
('6fa49047-0c29-4fc8-aa09-0f5c91037a74', 'a5c759a2-cb02-4765-be31-7ea514b4218e'),
('a5b5c975-6a87-4678-9a03-c16f4ef1b4b3', '99c217cd-0767-4e41-a65d-97fb8aa098ab'),
('5bea6d78-11a1-4637-ad78-4f8b00caba30', '4a93fc48-9c63-43b4-8cab-e6ddb380598b'),
('5bea6d78-11a1-4637-ad78-4f8b00caba30', '97c7dba5-5cca-4442-9f76-c9f82dbddea4'),
('3cfdb40a-cfac-4222-90ed-0ad9f5fb59f4', 'eab230c4-0953-4729-8746-7294d82c1f27'),
('2f7ea27b-5780-4920-a3cd-3eca0e32c30c', '99506dd7-08ec-4237-8fa3-a524fdbec3e1'),
('871df8d1-b718-4a9d-8a5f-143672728b91', 'c9a97f2d-d740-4241-80f5-0d521d7bd088'),
('d01634e6-95bf-4bda-8833-c94a776f53cc', '4c351ecc-4e70-44ae-a7c1-aa0174e005a5'),
('5bea6d78-11a1-4637-ad78-4f8b00caba30', '72530e93-c69f-406a-9c5d-6f261327ae82'),
('a81ce133-a745-44dc-a52c-9d51c06b82ed', '1f7df1d9-4fec-453c-bab6-edd7dfe120ad'),
('3cfdb40a-cfac-4222-90ed-0ad9f5fb59f4', '7b1184ce-202b-4593-b7ee-5808b6fe6913');

INSERT INTO DOWNLOADED_SONG VALUES
('8f9b554c-7bde-4a0b-ba25-92adaca3a1c8', 'mjohnson@gmail.com'),
('fbcb1132-39ee-4675-bef0-2ca4b91758c0', 'mjohnson@gmail.com'),
('9447cf25-5dfd-4ae4-90b4-e3bad465ddd0', 'uphelps@gmail.com'),
('046110b2-9815-4b13-b90a-b28db25a8142', 'uphelps@gmail.com'),
('7b1184ce-202b-4593-b7ee-5808b6fe6913', 'uphelps@gmail.com'),
('bd9b1f12-31ff-4d36-9472-33c41a9ff9ef', 'brownscott@hotmail.com'),
('e4a1aff3-caa8-4dc2-8c9d-71b2349fd4de', 'uphelps@gmail.com'),
('34ef5fb9-af0b-478d-b9f7-c72b11f7ec4b', 'uphelps@gmail.com'),
('c9a97f2d-d740-4241-80f5-0d521d7bd088', 'uphelps@gmail.com'),
('7b1184ce-202b-4593-b7ee-5808b6fe6913', 'mjohnson@gmail.com');

INSERT INTO PLAYLIST VALUES
('96e2ddfb-1851-4c80-aecf-494ddb16bf3a'),
('c8e3a7f6-50d0-4b0a-b676-cb06c402bddd'),
('88fdfb46-a804-40a7-8004-5260c2c1d01c'),
('4bfcd49a-34ed-44ae-b38b-22f8270cfa06'),
('90ace3e1-9380-49ed-a8ff-4ad80295de22'),
('66c7edf1-45f2-467b-b62e-4917509bae4a'),
('60e2e0e7-648e-4a4a-957d-1308cae9c55e'),
('ddd406d3-2478-48b5-b712-f5af43dcac8d'),
('0378fc1b-557c-4be4-8949-171fa7de7fcb'),
('ea310c96-df8d-4b12-aedc-6701db8f0eca');

INSERT INTO CHART VALUES
('Daily Top 20', 'c8e3a7f6-50d0-4b0a-b676-cb06c402bddd'),
('Weekly Top 20', '96e2ddfb-1851-4c80-aecf-494ddb16bf3a'),
('Monthly Top 20', '88fdfb46-a804-40a7-8004-5260c2c1d01c'),
('Yearly Top 20', '60e2e0e7-648e-4a4a-957d-1308cae9c55e');

INSERT INTO USER_PLAYLIST VALUES
('htorres@hotmail.com', '94475c98-f586-42f3-b243-d26190fd7899', 'Blood professor later', 'Interest amount policy religious crime price. Home discover those six director spend action follow. Animal determine yard parent cause.
Under which seat main but individual entire.
Play because close attack TV upon. Oil phone base sometimes fall attack. Congress new matter must very plant television.
Box present according building. Political national pull really radio successful. Attack trade win by heavy special mouth.', 34, '2022-10-28', '96e2ddfb-1851-4c80-aecf-494ddb16bf3a', 4879),
('zflores@hotmail.com', '6331230a-e9c8-49a3-83c3-033fd92a521a', 'Never concern candidate than', 'Door dinner put real. Speech few rule against kid.
Visit stay major skin religious watch. Game contain force expert what. House out why majority million various.
Realize unit kind player close offer. Great amount law reveal operation. Certain draw body charge life.
Give officer near admit type billion century. Dream give subject reduce better. Police view quickly practice save practice push increase. Something decide mission carry money.', 17, '2022-05-11', 'ea310c96-df8d-4b12-aedc-6701db8f0eca', 4635),
('freed@yahoo.com', '50603cc1-0c71-46c7-b911-ad330a6586ee', 'Million sort', 'Light back itself everybody. Language cover answer threat of. College culture week help resource assume.
Paper and wrong save rise response head. Expect region beyond become not.
Wall south style value under school. Whose glass hospital loss force.
Seem value offer almost star. Since democratic what. Risk front our understand establish hear.
Ready help shoulder civil half foot. So instead suffer fast indicate impact difficult. Special find campaign teacher evening relate their.', 26, '2019-05-06', '66c7edf1-45f2-467b-b62e-4917509bae4a', 4078),
('mjohnson@gmail.com', '798b4f03-7773-4748-825d-b72ba8c2e9f7', 'Factor technology brother', 'Car old reality job himself. Yeah lay evening result join. Officer simple star else. Goal area half visit interest campaign already go.      
Sister method everyone from item draw experience part.
Congress forward remain dream agent unit keep. Project program decade compare myself. Democratic bring mean want. When enough quite north degree.', 83, '2022-08-16', '0378fc1b-557c-4be4-8949-171fa7de7fcb', 3000),
('tgray@yahoo.com', 'b7da728f-5986-4b8c-ba7f-62d5e7de7f75', 'Director realize street', 'Receive citizen defense impact. Television full ready student note only. Father high cover most television debate reality.
Baby read attorney. Laugh quickly strategy thank so could image. Cup several amount medical concern.
Business tax keep each follow identify unit. Positive a be money safe.
Various expert chair decision candidate. Several career relationship wonder. That product thing apply story step.    
Or list view describe forget. Star sound successful talk increase may want.', 64, '2024-02-21', 'ddd406d3-2478-48b5-b712-f5af43dcac8d', 4964);

INSERT INTO ROYALTI VALUES
('80978615-bacc-4db4-abce-969e2ecdbfbd', 'e3d614c6-db2a-4196-a613-d92caf301f00', 62450380),
('9b1fd25f-9736-4bc4-af17-47b22ae5f0a9', '4a93fc48-9c63-43b4-8cab-e6ddb380598b', 51536181),
('c3740d4c-66f2-490e-aae9-9c3478d79974', '9846644b-e03b-4b9c-ad16-3cca53c318b1', 39958845),
('16a1ab22-8e4b-452a-ac21-cd7ff4bc86f3', 'e4a1aff3-caa8-4dc2-8c9d-71b2349fd4de', 86970851),
('d7a7996d-6ccc-42e7-9d97-da9cd71c70ca', '9447cf25-5dfd-4ae4-90b4-e3bad465ddd0', 18349505),
('f047202f-9edb-4082-b59d-662da23e9a0d', 'fbcb1132-39ee-4675-bef0-2ca4b91758c0', 18136513),
('f83192ac-7647-4fdf-9ba0-d73c4824edaa', 'd1344557-59a6-4ad8-9a0d-ed8053542e54', 58805771),
('2b7a0f96-1800-459e-8278-0d5e72787c1f', 'ed75eaf9-bdbd-4c14-add1-0786bffbb452', 73828805),
('f047202f-9edb-4082-b59d-662da23e9a0d', 'a0f2e3d7-7048-456b-bf3b-eb599ad0c497', 84763534),
('8535c3b0-12cb-4c6b-9e20-2814a0765edc', '9c56bd40-224f-428d-add2-c0ab2e925a8a', 46103819),
('ac5e28fd-69ca-4d62-9e78-8a99da9836d9', '504b8aac-31d1-491f-806e-b3e86587c884', 48343583),
('c270a663-5697-44cf-abe6-86b9a3dc07ff', '97c7dba5-5cca-4442-9f76-c9f82dbddea4', 38660964),
('d7a7996d-6ccc-42e7-9d97-da9cd71c70ca', 'e4a1aff3-caa8-4dc2-8c9d-71b2349fd4de', 73650266),
('80978615-bacc-4db4-abce-969e2ecdbfbd', '4c351ecc-4e70-44ae-a7c1-aa0174e005a5', 57711952),
('f83192ac-7647-4fdf-9ba0-d73c4824edaa', '271765eb-5f5c-4a9e-b420-37ea61e9df1e', 57294884),
('c39f30a3-fec9-4924-a818-c1a421abfb5d', '046110b2-9815-4b13-b90a-b28db25a8142', 17716436),
('4829e825-723e-4873-82f1-2a304daad3c6', 'e3ab1934-40a0-42f1-a8e5-7d38e770d051', 32788501),
('c270a663-5697-44cf-abe6-86b9a3dc07ff', '34ef5fb9-af0b-478d-b9f7-c72b11f7ec4b', 97261120),
('5fd427cb-5068-49c1-a915-779bd4a0d985', 'ed75eaf9-bdbd-4c14-add1-0786bffbb452', 460404),
('de920323-5188-4a1e-8bbe-348f23b47c85', '8414f842-24e1-4173-a4a0-708234087c7a', 35716940),
('9b1fd25f-9736-4bc4-af17-47b22ae5f0a9', '9398b231-35aa-4ff1-bdd3-d8cad8c86ddb', 51033063),
('9b1fd25f-9736-4bc4-af17-47b22ae5f0a9', '1f7df1d9-4fec-453c-bab6-edd7dfe120ad', 62011631),
('8535c3b0-12cb-4c6b-9e20-2814a0765edc', '47469dc4-5c43-4e0f-b153-63fb5004a471', 82305801),
('9b1fd25f-9736-4bc4-af17-47b22ae5f0a9', '2373d3a4-ac65-4b28-bd14-0cf90ee5c1c0', 95845897),
('9b233ebd-80ec-4d84-b1eb-ba3bf7ecc438', '4a93fc48-9c63-43b4-8cab-e6ddb380598b', 67954575);

INSERT INTO AKUN_PLAY_USER_PLAYLIST VALUES
('uphelps@gmail.com', '798b4f03-7773-4748-825d-b72ba8c2e9f7', 'mjohnson@gmail.com', '2023-09-04 18:25:35'),
('brandon16@hotmail.com', '50603cc1-0c71-46c7-b911-ad330a6586ee', 'freed@yahoo.com', '2024-02-02 12:38:52'),
('rodriguezchristopher@gmail.com', '94475c98-f586-42f3-b243-d26190fd7899', 'htorres@hotmail.com', '2024-02-14 16:46:59'),
('sweeneyalfred@gmail.com', 'b7da728f-5986-4b8c-ba7f-62d5e7de7f75', 'tgray@yahoo.com', '2023-08-29 13:17:57'),
('abell@hotmail.com', '798b4f03-7773-4748-825d-b72ba8c2e9f7', 'mjohnson@gmail.com', '2024-03-25 02:11:16'),
('sgreer@gmail.com', 'b7da728f-5986-4b8c-ba7f-62d5e7de7f75', 'tgray@yahoo.com', '2023-10-24 12:25:09'),
('kirklaura@hotmail.com', 'b7da728f-5986-4b8c-ba7f-62d5e7de7f75', 'tgray@yahoo.com', '2024-04-02 13:54:50'),
('zmartin@yahoo.com', '798b4f03-7773-4748-825d-b72ba8c2e9f7', 'mjohnson@gmail.com', '2023-12-30 20:05:54'),
('monicacase@hotmail.com', '94475c98-f586-42f3-b243-d26190fd7899', 'htorres@hotmail.com', '2023-07-31 18:25:48'),
('lesliemcdonald@hotmail.com', '94475c98-f586-42f3-b243-d26190fd7899', 'htorres@hotmail.com', '2023-05-31 16:39:07'),
('tshelton@yahoo.com', '50603cc1-0c71-46c7-b911-ad330a6586ee', 'freed@yahoo.com', '2023-05-08 00:45:20'),
('jeremy32@yahoo.com', 'b7da728f-5986-4b8c-ba7f-62d5e7de7f75', 'tgray@yahoo.com', '2023-08-27 15:02:16'),
('david32@yahoo.com', '798b4f03-7773-4748-825d-b72ba8c2e9f7', 'mjohnson@gmail.com', '2024-02-01 11:09:57'),
('smithbryan@hotmail.com', 'b7da728f-5986-4b8c-ba7f-62d5e7de7f75', 'tgray@yahoo.com', '2024-04-18 07:16:25'),        
('tshelton@yahoo.com', '798b4f03-7773-4748-825d-b72ba8c2e9f7', 'mjohnson@gmail.com', '2024-03-03 12:45:15');

INSERT INTO AKUN_PLAY_SONG VALUES
('david32@yahoo.com', '9846644b-e03b-4b9c-ad16-3cca53c318b1', '2024-01-27 02:59:08'),
('austinandrea@hotmail.com', 'bbb5e27f-f0c7-4635-9c3c-3670d6b102f5', '2023-06-08 08:11:46'),
('brandon16@hotmail.com', 'e3ab1934-40a0-42f1-a8e5-7d38e770d051', '2023-11-06 13:54:20'),
('michael72@hotmail.com', '8414f842-24e1-4173-a4a0-708234087c7a', '2023-12-10 02:11:19'),
('jeremy32@yahoo.com', '9c56bd40-224f-428d-add2-c0ab2e925a8a', '2024-03-23 21:32:32'),
('freed@yahoo.com', 'e3d614c6-db2a-4196-a613-d92caf301f00', '2023-09-17 22:12:02'),
('yyoung@hotmail.com', '788b56c3-3a16-42cb-a38a-cbd1999f3e1e', '2023-09-23 12:45:13'),
('bradfordtony@yahoo.com', '2373d3a4-ac65-4b28-bd14-0cf90ee5c1c0', '2023-06-01 22:56:01'),
('andrewmejia@hotmail.com', '3e20a42b-40d9-4b34-ac5b-69555182d131', '2023-06-19 22:36:22'),
('lori81@hotmail.com', '267629ec-7334-4089-8dae-409b2d09884b', '2023-05-20 11:21:40'),
('monicacase@hotmail.com', '3e20a42b-40d9-4b34-ac5b-69555182d131', '2023-11-16 07:04:37'),
('gutierrezkenneth@gmail.com', '8f9b554c-7bde-4a0b-ba25-92adaca3a1c8', '2023-05-05 07:58:32'),
('austinandrea@hotmail.com', '99506dd7-08ec-4237-8fa3-a524fdbec3e1', '2024-03-29 13:24:26'),
('monicacase@hotmail.com', '72530e93-c69f-406a-9c5d-6f261327ae82', '2023-05-26 03:41:44'),
('yjohnson@yahoo.com', '97c7dba5-5cca-4442-9f76-c9f82dbddea4', '2023-11-01 01:16:03'),
('carla75@hotmail.com', '9447cf25-5dfd-4ae4-90b4-e3bad465ddd0', '2023-08-25 21:17:24'),
('danielle77@yahoo.com', 'fbcb1132-39ee-4675-bef0-2ca4b91758c0', '2023-11-18 23:15:40'),
('dianadavis@gmail.com', '4c351ecc-4e70-44ae-a7c1-aa0174e005a5', '2024-01-21 11:50:16'),
('tshelton@yahoo.com', '2373d3a4-ac65-4b28-bd14-0cf90ee5c1c0', '2023-09-12 07:33:13'),
('tgray@yahoo.com', '504b8aac-31d1-491f-806e-b3e86587c884', '2023-06-01 07:08:58'),
('lori81@hotmail.com', '9447cf25-5dfd-4ae4-90b4-e3bad465ddd0', '2023-07-16 00:02:36'),
('lesliemcdonald@hotmail.com', 'aefef70a-7d90-48bf-8e7a-d95ea315ac2b', '2024-01-05 20:07:12'),
('freed@yahoo.com', 'ed75eaf9-bdbd-4c14-add1-0786bffbb452', '2023-12-10 14:01:39'),
('freed@yahoo.com', 'c8836601-03c9-4f52-a934-4d8246b429f6', '2024-04-07 18:20:19'),
('yyoung@hotmail.com', 'd1344557-59a6-4ad8-9a0d-ed8053542e54', '2023-10-31 13:22:43'),
('samuelspears@yahoo.com', 'ed75eaf9-bdbd-4c14-add1-0786bffbb452', '2023-07-15 18:08:53'),
('brownscott@hotmail.com', '8dc90a8d-91ce-4786-b80f-001f0ff593b0', '2023-10-28 12:23:37'),
('sgreer@gmail.com', '9517cc23-85d5-4082-9e35-ece3edfa4eba', '2023-07-13 06:48:08'),
('thomas11@hotmail.com', '6762c249-0d4a-4053-8156-960084f07d27', '2024-02-07 07:18:04'),
('lesliemcdonald@hotmail.com', 'aefef70a-7d90-48bf-8e7a-d95ea315ac2b', '2023-12-16 00:59:39'),
('uhill@hotmail.com', '97c7dba5-5cca-4442-9f76-c9f82dbddea4', '2023-07-25 00:04:39'),
('htorres@hotmail.com', '046110b2-9815-4b13-b90a-b28db25a8142', '2023-08-25 19:53:13'),
('rodriguezchristopher@gmail.com', '99c217cd-0767-4e41-a65d-97fb8aa098ab', '2024-03-08 05:44:33'),
('thomas11@hotmail.com', 'bbb5e27f-f0c7-4635-9c3c-3670d6b102f5', '2023-09-02 01:45:58'),
('jonathan28@yahoo.com', '276e8cac-d72e-416e-84dd-052e54abdac2', '2023-06-04 22:09:31'),
('sgreer@gmail.com', '61c8576d-f1b4-41a5-9345-b08cade1fb29', '2024-03-10 22:39:51'),
('obonilla@yahoo.com', '4c351ecc-4e70-44ae-a7c1-aa0174e005a5', '2023-09-03 12:54:37'),
('thomasbush@hotmail.com', 'aefef70a-7d90-48bf-8e7a-d95ea315ac2b', '2023-11-12 23:20:50'),
('jeremy32@yahoo.com', 'ed75eaf9-bdbd-4c14-add1-0786bffbb452', '2023-08-27 06:17:23'),
('ruben83@hotmail.com', '4c351ecc-4e70-44ae-a7c1-aa0174e005a5', '2024-01-26 17:49:13'),
('gpeterson@yahoo.com', '1f7df1d9-4fec-453c-bab6-edd7dfe120ad', '2023-05-14 13:14:41'),
('smithmargaret@yahoo.com', '9846644b-e03b-4b9c-ad16-3cca53c318b1', '2023-12-13 18:26:40'),
('smithbryan@hotmail.com', '99506dd7-08ec-4237-8fa3-a524fdbec3e1', '2023-07-31 05:55:31'),
('yyoung@hotmail.com', '6d62c1e0-1bbf-4a0e-84a2-c08b578796d5', '2023-05-11 18:42:33'),
('yyoung@hotmail.com', '2d824b04-a2c0-4cd0-a8cb-5a6195792a55', '2024-02-03 11:23:50'),
('monicacase@hotmail.com', '6d62c1e0-1bbf-4a0e-84a2-c08b578796d5', '2023-05-29 17:09:48'),
('smithbryan@hotmail.com', 'bbb5e27f-f0c7-4635-9c3c-3670d6b102f5', '2023-12-13 10:30:31'),
('abell@hotmail.com', '61c8576d-f1b4-41a5-9345-b08cade1fb29', '2024-01-19 13:11:26'),
('brenda20@gmail.com', '2421924c-d0ac-4d6f-a89c-5ddd3a08c1b9', '2024-02-22 12:18:53'),
('danielle77@yahoo.com', '267629ec-7334-4089-8dae-409b2d09884b', '2023-06-19 20:57:25'),
('htorres@hotmail.com', '99c217cd-0767-4e41-a65d-97fb8aa098ab', '2023-09-21 04:07:25'),
('david32@yahoo.com', '97c7dba5-5cca-4442-9f76-c9f82dbddea4', '2023-10-20 07:53:06'),
('jeremy32@yahoo.com', '267629ec-7334-4089-8dae-409b2d09884b', '2023-09-17 02:10:38'),
('lsmith@gmail.com', '34ef5fb9-af0b-478d-b9f7-c72b11f7ec4b', '2023-07-09 12:03:16'),
('carla75@hotmail.com', '53ffbd1f-a19d-4618-a73e-b1c27a9e3e69', '2024-02-16 11:23:28'),
('freed@yahoo.com', 'eab230c4-0953-4729-8746-7294d82c1f27', '2024-02-24 21:24:51'),
('lesliemcdonald@hotmail.com', '97c7dba5-5cca-4442-9f76-c9f82dbddea4', '2023-11-18 05:48:47'),
('david33@yahoo.com', '267629ec-7334-4089-8dae-409b2d09884b', '2023-09-13 09:47:42'),
('gpeterson@yahoo.com', '34ef5fb9-af0b-478d-b9f7-c72b11f7ec4b', '2024-01-23 13:54:14'),
('sgreer@gmail.com', '8414f842-24e1-4173-a4a0-708234087c7a', '2023-11-04 09:07:13'),
('swansonallison@gmail.com', 'c9a97f2d-d740-4241-80f5-0d521d7bd088', '2023-11-14 00:32:30'),
('yjohnson@yahoo.com', '2373d3a4-ac65-4b28-bd14-0cf90ee5c1c0', '2023-11-02 17:55:53'),
('rodriguezchristopher@gmail.com', '8dc90a8d-91ce-4786-b80f-001f0ff593b0', '2024-01-24 09:16:59'),
('brownscott@hotmail.com', '9447cf25-5dfd-4ae4-90b4-e3bad465ddd0', '2023-11-17 20:39:45'),
('smithbryan@hotmail.com', '4c351ecc-4e70-44ae-a7c1-aa0174e005a5', '2023-08-23 14:41:24'),
('freed@yahoo.com', '99c217cd-0767-4e41-a65d-97fb8aa098ab', '2023-08-19 19:13:03'),
('yyoung@hotmail.com', 'd1344557-59a6-4ad8-9a0d-ed8053542e54', '2023-07-14 14:10:54'),
('yyoung@hotmail.com', 'e3ab1934-40a0-42f1-a8e5-7d38e770d051', '2023-10-05 19:35:52'),
('freed@yahoo.com', '02f059cc-042e-4fe1-aa46-aa32bdd13302', '2023-06-12 03:00:06'),
('ruben83@hotmail.com', '271765eb-5f5c-4a9e-b420-37ea61e9df1e', '2023-09-12 22:03:11'),
('thomas11@hotmail.com', '9447cf25-5dfd-4ae4-90b4-e3bad465ddd0', '2023-10-14 18:08:43'),
('jeremy32@yahoo.com', '1f7df1d9-4fec-453c-bab6-edd7dfe120ad', '2024-01-15 07:41:08'),
('brownscott@hotmail.com', '504b8aac-31d1-491f-806e-b3e86587c884', '2024-01-29 09:15:59'),
('brenda20@gmail.com', 'e3d614c6-db2a-4196-a613-d92caf301f00', '2023-07-02 06:04:48'),
('jeremy32@yahoo.com', 'bbb5e27f-f0c7-4635-9c3c-3670d6b102f5', '2023-05-31 08:48:56'),
('mjohnson@gmail.com', '47469dc4-5c43-4e0f-b153-63fb5004a471', '2023-08-25 11:18:34'),
('smithmargaret@yahoo.com', '53ffbd1f-a19d-4618-a73e-b1c27a9e3e69', '2023-11-24 07:42:29'),
('gpeterson@yahoo.com', '276e8cac-d72e-416e-84dd-052e54abdac2', '2023-06-23 22:01:02'),
('melvin22@hotmail.com', '9846644b-e03b-4b9c-ad16-3cca53c318b1', '2024-03-31 09:38:45'),
('ghart@gmail.com', '267629ec-7334-4089-8dae-409b2d09884b', '2023-11-30 12:08:17'),
('andrewmejia@hotmail.com', '4a93fc48-9c63-43b4-8cab-e6ddb380598b', '2024-01-20 20:18:24'),
('obonilla@yahoo.com', 'fbcb1132-39ee-4675-bef0-2ca4b91758c0', '2023-06-07 15:34:27'),
('brenda20@gmail.com', '4c351ecc-4e70-44ae-a7c1-aa0174e005a5', '2023-10-02 10:34:35'),
('jonathan28@yahoo.com', 'c9a97f2d-d740-4241-80f5-0d521d7bd088', '2023-11-14 01:19:12'),
('freed@yahoo.com', 'aefef70a-7d90-48bf-8e7a-d95ea315ac2b', '2023-08-22 17:40:39'),
('jonathan28@yahoo.com', '3b1a696b-017e-4c93-a968-5039288a430f', '2024-04-15 10:36:23'),
('david32@yahoo.com', '271765eb-5f5c-4a9e-b420-37ea61e9df1e', '2023-06-13 12:29:55'),
('david32@yahoo.com', '98dadb8f-dbe8-42a9-ad58-ea4470282561', '2023-05-23 14:16:43'),
('thomasbush@hotmail.com', '6d62c1e0-1bbf-4a0e-84a2-c08b578796d5', '2024-04-06 23:48:07'),
('smithbryan@hotmail.com', '47469dc4-5c43-4e0f-b153-63fb5004a471', '2023-10-05 02:31:30'),
('tgray@yahoo.com', '3b1a696b-017e-4c93-a968-5039288a430f', '2024-02-09 08:37:43'),
('tgray@yahoo.com', 'bd9b1f12-31ff-4d36-9472-33c41a9ff9ef', '2024-04-27 04:56:39'),
('tshelton@yahoo.com', 'bbb5e27f-f0c7-4635-9c3c-3670d6b102f5', '2023-05-14 18:06:31'),
('michael72@hotmail.com', '788b56c3-3a16-42cb-a38a-cbd1999f3e1e', '2024-02-06 18:48:18'),
('shaffertonya@hotmail.com', '3e20a42b-40d9-4b34-ac5b-69555182d131', '2023-12-23 13:28:32'),
('yjohnson@yahoo.com', 'aefef70a-7d90-48bf-8e7a-d95ea315ac2b', '2023-11-30 09:13:29'),
('gpeterson@yahoo.com', '7b1184ce-202b-4593-b7ee-5808b6fe6913', '2024-04-03 06:39:16'),
('rodriguezchristopher@gmail.com', 'd1344557-59a6-4ad8-9a0d-ed8053542e54', '2024-03-23 05:23:47'),
('brownscott@hotmail.com', '2421924c-d0ac-4d6f-a89c-5ddd3a08c1b9', '2023-12-28 13:36:08'),
('david33@yahoo.com', '6d62c1e0-1bbf-4a0e-84a2-c08b578796d5', '2023-08-22 16:24:44');

INSERT INTO PLAYLIST_SONG VALUES
('66c7edf1-45f2-467b-b62e-4917509bae4a', '9398b231-35aa-4ff1-bdd3-d8cad8c86ddb'),
('c8e3a7f6-50d0-4b0a-b676-cb06c402bddd', '2373d3a4-ac65-4b28-bd14-0cf90ee5c1c0'),
('c8e3a7f6-50d0-4b0a-b676-cb06c402bddd', '61c8576d-f1b4-41a5-9345-b08cade1fb29'),
('ea310c96-df8d-4b12-aedc-6701db8f0eca', '9398b231-35aa-4ff1-bdd3-d8cad8c86ddb'),
('66c7edf1-45f2-467b-b62e-4917509bae4a', '788b56c3-3a16-42cb-a38a-cbd1999f3e1e'),
('90ace3e1-9380-49ed-a8ff-4ad80295de22', 'c8836601-03c9-4f52-a934-4d8246b429f6'),
('ddd406d3-2478-48b5-b712-f5af43dcac8d', '61c8576d-f1b4-41a5-9345-b08cade1fb29'),
('ea310c96-df8d-4b12-aedc-6701db8f0eca', '6762c249-0d4a-4053-8156-960084f07d27'),
('90ace3e1-9380-49ed-a8ff-4ad80295de22', '8fb16fb8-ae69-40af-abf0-f0bba005c98b'),
('ddd406d3-2478-48b5-b712-f5af43dcac8d', '8414f842-24e1-4173-a4a0-708234087c7a'),
('4bfcd49a-34ed-44ae-b38b-22f8270cfa06', '9447cf25-5dfd-4ae4-90b4-e3bad465ddd0'),
('ea310c96-df8d-4b12-aedc-6701db8f0eca', '99506dd7-08ec-4237-8fa3-a524fdbec3e1'),
('90ace3e1-9380-49ed-a8ff-4ad80295de22', '6762c249-0d4a-4053-8156-960084f07d27'),
('96e2ddfb-1851-4c80-aecf-494ddb16bf3a', 'fbcb1132-39ee-4675-bef0-2ca4b91758c0'),
('60e2e0e7-648e-4a4a-957d-1308cae9c55e', 'fbcb1132-39ee-4675-bef0-2ca4b91758c0'),
('0378fc1b-557c-4be4-8949-171fa7de7fcb', '267629ec-7334-4089-8dae-409b2d09884b'),
('c8e3a7f6-50d0-4b0a-b676-cb06c402bddd', '34ef5fb9-af0b-478d-b9f7-c72b11f7ec4b'),
('96e2ddfb-1851-4c80-aecf-494ddb16bf3a', '02f059cc-042e-4fe1-aa46-aa32bdd13302'),
('ddd406d3-2478-48b5-b712-f5af43dcac8d', '271765eb-5f5c-4a9e-b420-37ea61e9df1e'),
('88fdfb46-a804-40a7-8004-5260c2c1d01c', 'e3ab1934-40a0-42f1-a8e5-7d38e770d051'),
('90ace3e1-9380-49ed-a8ff-4ad80295de22', 'e3d614c6-db2a-4196-a613-d92caf301f00'),
('88fdfb46-a804-40a7-8004-5260c2c1d01c', '504b8aac-31d1-491f-806e-b3e86587c884'),
('c8e3a7f6-50d0-4b0a-b676-cb06c402bddd', 'e4a1aff3-caa8-4dc2-8c9d-71b2349fd4de'),
('88fdfb46-a804-40a7-8004-5260c2c1d01c', '1f7df1d9-4fec-453c-bab6-edd7dfe120ad'),
('66c7edf1-45f2-467b-b62e-4917509bae4a', '97c7dba5-5cca-4442-9f76-c9f82dbddea4'),
('ddd406d3-2478-48b5-b712-f5af43dcac8d', 'a0f2e3d7-7048-456b-bf3b-eb599ad0c497'),
('96e2ddfb-1851-4c80-aecf-494ddb16bf3a', '9447cf25-5dfd-4ae4-90b4-e3bad465ddd0'),
('c8e3a7f6-50d0-4b0a-b676-cb06c402bddd', '267629ec-7334-4089-8dae-409b2d09884b'),
('ea310c96-df8d-4b12-aedc-6701db8f0eca', '99c217cd-0767-4e41-a65d-97fb8aa098ab'),
('ddd406d3-2478-48b5-b712-f5af43dcac8d', '9846644b-e03b-4b9c-ad16-3cca53c318b1'),
('ddd406d3-2478-48b5-b712-f5af43dcac8d', 'd1344557-59a6-4ad8-9a0d-ed8053542e54'),
('0378fc1b-557c-4be4-8949-171fa7de7fcb', '47469dc4-5c43-4e0f-b153-63fb5004a471'),
('88fdfb46-a804-40a7-8004-5260c2c1d01c', '4a93fc48-9c63-43b4-8cab-e6ddb380598b'),
('88fdfb46-a804-40a7-8004-5260c2c1d01c', '046110b2-9815-4b13-b90a-b28db25a8142'),
('c8e3a7f6-50d0-4b0a-b676-cb06c402bddd', 'e3ab1934-40a0-42f1-a8e5-7d38e770d051'),
('c8e3a7f6-50d0-4b0a-b676-cb06c402bddd', '53ffbd1f-a19d-4618-a73e-b1c27a9e3e69'),
('66c7edf1-45f2-467b-b62e-4917509bae4a', 'd1344557-59a6-4ad8-9a0d-ed8053542e54'),
('ea310c96-df8d-4b12-aedc-6701db8f0eca', '276e8cac-d72e-416e-84dd-052e54abdac2'),
('4bfcd49a-34ed-44ae-b38b-22f8270cfa06', '276e8cac-d72e-416e-84dd-052e54abdac2'),
('88fdfb46-a804-40a7-8004-5260c2c1d01c', 'aefef70a-7d90-48bf-8e7a-d95ea315ac2b'),
('66c7edf1-45f2-467b-b62e-4917509bae4a', 'c9a97f2d-d740-4241-80f5-0d521d7bd088'),
('4bfcd49a-34ed-44ae-b38b-22f8270cfa06', '267629ec-7334-4089-8dae-409b2d09884b'),
('96e2ddfb-1851-4c80-aecf-494ddb16bf3a', 'eab230c4-0953-4729-8746-7294d82c1f27'),
('ddd406d3-2478-48b5-b712-f5af43dcac8d', '2421924c-d0ac-4d6f-a89c-5ddd3a08c1b9'),
('60e2e0e7-648e-4a4a-957d-1308cae9c55e', 'e3d614c6-db2a-4196-a613-d92caf301f00'),
('ea310c96-df8d-4b12-aedc-6701db8f0eca', '02f059cc-042e-4fe1-aa46-aa32bdd13302'),
('ddd406d3-2478-48b5-b712-f5af43dcac8d', '7b1184ce-202b-4593-b7ee-5808b6fe6913'),
('90ace3e1-9380-49ed-a8ff-4ad80295de22', '53ffbd1f-a19d-4618-a73e-b1c27a9e3e69'),
('c8e3a7f6-50d0-4b0a-b676-cb06c402bddd', '788b56c3-3a16-42cb-a38a-cbd1999f3e1e'),
('c8e3a7f6-50d0-4b0a-b676-cb06c402bddd', '9447cf25-5dfd-4ae4-90b4-e3bad465ddd0');