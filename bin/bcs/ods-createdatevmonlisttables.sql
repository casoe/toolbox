DROP TABLE IF EXISTS monlist_projekte;
DROP TABLE IF EXISTS monlist_buchungen;
DROP TABLE IF EXISTS monlist_personal;
DROP TABLE IF EXISTS monlist_deckblaetter;
DROP TABLE IF EXISTS monlist_urlaub;
DROP TABLE IF EXISTS datev_kosten;
DROP TABLE IF EXISTS datev_umsatz;
DROP TABLE IF EXISTS datev_honorare;

CREATE TABLE monlist_projekte (
    Nummer int PRIMARY KEY UNIQUE,
    IsOld SMALLINT,
    Beschreibung CHARACTER VARYING,
    LastChanges CHARACTER VARYING);

CREATE TABLE monlist_buchungen (
    ID INT PRIMARY KEY UNIQUE,
    Nummer INT,
    Tag INT,
    Monat INT,
    Jahr INT,
    Stunden NUMERIC,
    Projekt INT,
    Beschreibung CHARACTER VARYING);

CREATE TABLE monlist_personal(
    Nummer INT PRIMARY KEY UNIQUE,
    Name CHARACTER VARYING,
    UebStdReg NUMERIC,
    StdPerWeek NUMERIC,
    JahresUrlaub NUMERIC,
    StdPerVacation NUMERIC,
    GB CHARACTER VARYING,
    isDeleted SMALLINT,
		BCS INT);

CREATE TABLE monlist_deckblaetter(
    ID INT PRIMARY KEY UNIQUE,
    Nummer INT,
    Monat INT,
    Jahr INT,
    OvertimeOld NUMERIC,
	OvertimeNew NUMERIC,
	PaidOvertime NUMERIC,
	StdPerWeek NUMERIC,
	UebStdReg NUMERIC,
    IsOpen SMALLINT);

CREATE TABLE monlist_urlaub(
    ID INT PRIMARY KEY UNIQUE,
    Nummer INT,
    Monat INT,
    Jahr INT,
    OldHoliday NUMERIC,
	Holiday NUMERIC,
	NewHoliday NUMERIC,
	HoursPerHoliday NUMERIC);

CREATE TABLE datev_kosten(
    Firma INT,
    Jahr INT,
    Monat INT,
    Kontonummer INT,
    Datum DATE,
	GegenKonto INT,
	Umsatz NUMERIC,
	SH CHARACTER VARYING,
	Buchungstext CHARACTER VARYING,
	Beleg1 CHARACTER VARYING,
	Beleg2 CHARACTER VARYING,
	Kost1 INT,
	Kost2 INT,
	Kontenbeschriftung CHARACTER VARYING,
	Gegenkontenbeschriftung CHARACTER VARYING,
	Quelle CHARACTER VARYING);

CREATE TABLE datev_umsatz(
    Firma INT,
    Jahr INT,
    Monat INT,
    Kontonummer INT,
    Datum DATE,
	GegenKonto INT,
	Umsatz NUMERIC,
	SH CHARACTER VARYING,
	Buchungstext CHARACTER VARYING,
	Beleg1 CHARACTER VARYING,
	Beleg2 CHARACTER VARYING,
	Kost1 INT,
	Kost2 INT,
	Kontenbeschriftung CHARACTER VARYING,
	Gegenkontenbeschriftung CHARACTER VARYING,
	Quelle CHARACTER VARYING);

CREATE TABLE datev_honorare(
    Firma INT,
    Jahr INT,
    Monat INT,
    Kontonummer INT,
    Datum DATE,
	GegenKonto INT,
	Umsatz NUMERIC,
	SH CHARACTER VARYING,
	Buchungstext CHARACTER VARYING,
	Beleg1 CHARACTER VARYING,
	Beleg2 CHARACTER VARYING,
	Kost1 INT,
	Kost2 INT,
	Kontenbeschriftung CHARACTER VARYING,
	Gegenkontenbeschriftung CHARACTER VARYING,
	Quelle CHARACTER VARYING);

ALTER TABLE monlist_projekte OWNER TO bcs;
ALTER TABLE monlist_buchungen OWNER TO bcs;
ALTER TABLE monlist_personal OWNER TO bcs;
ALTER TABLE monlist_deckblaetter OWNER TO bcs;
ALTER TABLE monlist_urlaub OWNER TO bcs;
ALTER TABLE datev_kosten OWNER TO bcs;
ALTER TABLE datev_umsatz OWNER TO bcs;
ALTER TABLE datev_honorare OWNER TO bcs;
