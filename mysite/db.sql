BEGIN TRANSACTION;
DROP TABLE IF EXISTS "lekarz";
CREATE TABLE IF NOT EXISTS "lekarz" (
	"doctorID"	INTEGER,
	"login"	TEXT,
	"haslo"	TEXT,
	"imie"	TEXT,
	"nazwisko"	TEXT,
	"nr_telefonu"	TEXT,
	PRIMARY KEY("doctorID")
);
DROP TABLE IF EXISTS "pacjent";
CREATE TABLE IF NOT EXISTS "pacjent" (
	"pacjentID"	INTEGER,
	"haslo"	TEXT,
	"login"	TEXT,
	"imie"	TEXT,
	"nazwisko"	TEXT,
	"adres"	TEXT,
	"rodzaj_choroby"	TEXT,
	"nazwa_badnia"	TEXT,
	"plec"	TEXT,
	"data_ur"	TEXT,
	PRIMARY KEY("pacjentID")
);
DROP TABLE IF EXISTS "placowka";
CREATE TABLE IF NOT EXISTS "placowka" (
	"nr"	INTEGER,
	"nazwa_pl"	TEXT,
	"adres"	TEXT,
	"nr_tel"	TEXT,
	PRIMARY KEY("nr")
);
DROP TABLE IF EXISTS "lekarz_b_lab";
CREATE TABLE IF NOT EXISTS "lekarz_b_lab" (
	"b_lab_ID"	INTEGER,
	"doctorID"	TEXT
);
DROP TABLE IF EXISTS "lekarz_b_lek";
CREATE TABLE IF NOT EXISTS "lekarz_b_lek" (
	"b_lek_ID"	INTEGER,
	"doctorID"	TEXT
);
DROP TABLE IF EXISTS "lekarz_diag";
CREATE TABLE IF NOT EXISTS "lekarz_diag" (
	"diagnoza_ID"	INTEGER,
	"doctorID"	TEXT
);
DROP TABLE IF EXISTS "pacjent_b_lab";
CREATE TABLE IF NOT EXISTS "pacjent_b_lab" (
	"b_lab_ID"	INTEGER,
	"pacjentID"	TEXT
);
DROP TABLE IF EXISTS "pacjent_b_lek";
CREATE TABLE IF NOT EXISTS "pacjent_b_lek" (
	"b_lek_ID"	INTEGER,
	"pacjentID"	TEXT
);
DROP TABLE IF EXISTS "pacjent_diag";
CREATE TABLE IF NOT EXISTS "pacjent_diag" (
	"diagnoza_ID"	INTEGER,
	"pacjentID"	TEXT
);
DROP TABLE IF EXISTS "badanie_lab";
CREATE TABLE IF NOT EXISTS "badanie_lab" (
	"b_lab_ID"	INTEGER,
	"nazwa_badania"	TEXT,
	"wyniki"	TEXT,
	"data"	TEXT,
	"nr"	INTEGER,
	PRIMARY KEY("b_lab_ID"),
	FOREIGN KEY("nr") REFERENCES "placowka"("nr")
);
DROP TABLE IF EXISTS "badanie_lek";
CREATE TABLE IF NOT EXISTS "badanie_lek" (
	"b_lek_ID"	INTEGER,
	"data"	TEXT,
	"nazwa_badania"	TEXT,
	"nr"	INTEGER,
	PRIMARY KEY("b_lek_ID"),
	FOREIGN KEY("nr") REFERENCES "placowka"("nr")
);
DROP TABLE IF EXISTS "diagnoza";
CREATE TABLE IF NOT EXISTS "diagnoza" (
	"diagnoza_ID"	INTEGER,
	"data"	TEXT,
	"opis"	TEXT,
	"nr"	INTEGER,
	PRIMARY KEY("diagnoza_ID"),
	FOREIGN KEY("nr") REFERENCES "placowka"("nr")
);
DROP VIEW IF EXISTS "db";
CREATE VIEW "db" AS SELECT*
FROM pacjent
INNER JOIN pacjent_diag
ON pacjent_diag.pacjentID = pacjent.pacjentID
INNER JOIN diagnoza
ON diagnoza.diagnoza_ID = pacjent_diag.diagnoza_ID;
COMMIT;
