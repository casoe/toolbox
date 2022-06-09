DROP TABLE IF EXISTS bcs_akquisen;
DROP TABLE IF EXISTS bcs_akquisen;
DROP TABLE IF EXISTS bcs_auftragsplan;
DROP TABLE IF EXISTS bcs_aufwandsplan;
DROP TABLE IF EXISTS bcs_buchungen;
DROP TABLE IF EXISTS bcs_eingangsrechnungen;
DROP TABLE IF EXISTS bcs_konferenzregistrierung;
DROP TABLE IF EXISTS bcs_mitarbeiter;
DROP TABLE IF EXISTS bcs_organisationen;
DROP TABLE IF EXISTS bcs_projekte;
DROP TABLE IF EXISTS bcs_rechnungen;
DROP TABLE IF EXISTS bcs_sachkosten;
DROP TABLE IF EXISTS bcs_spesen;
DROP TABLE IF EXISTS bcs_stundensaetze;
DROP TABLE IF EXISTS bcs_termine;
DROP TABLE IF EXISTS bcs_zahlungstermine;

CREATE TABLE bcs_akquisen (
	oid CHARACTER VARYING PRIMARY KEY UNIQUE,
	thema CHARACTER VARYING,
	organisation_oid CHARACTER VARYING,
	region CHARACTER VARYING,
	externer_ansprechpartner_nachname CHARACTER VARYING,
	externer_ansprechpartner_vorname CHARACTER VARYING,
	projekt_oid CHARACTER VARYING,
	produkte CHARACTER VARYING,
	gb CHARACTER VARYING,
	vorraussichtlicher_abschluss CHARACTER VARYING,
	status CHARACTER VARYING,
	status_gb CHARACTER VARYING,
	wahrscheinlichkeit CHARACTER VARYING,
	umsatz_volumen CHARACTER VARYING,
	umsatz_eigen CHARACTER VARYING,
	umsatz_eigen_bew CHARACTER VARYING,
	umsatz_eigen_diesesjahr CHARACTER VARYING,
	umsatz_eigen_diesesjahr_bew CHARACTER VARYING,
	aktueller_status CHARACTER VARYING,
	naechste_schritte CHARACTER VARYING,
	challenges CHARACTER VARYING,
	kommerzielles_schema CHARACTER VARYING,
	verantwortlicher_oid CHARACTER VARYING,
	umrechnungskurs_id CHARACTER VARYING,
	waehrung CHARACTER VARYING,
	letzte_aenderung_von CHARACTER VARYING,
	aktualisiert_am CHARACTER VARYING,
	jdbctimestamp DECIMAL(15,0)
);

CREATE TABLE bcs_auftragsplan (
	oid CHARACTER VARYING PRIMARY KEY UNIQUE,
	auftragsdatum CHARACTER VARYING,
	auftrag_oid CHARACTER VARYING,
	auftragsaufwand CHARACTER VARYING,
	auftragswert CHARACTER VARYING,
	waehrung CHARACTER VARYING,
	umrechnungskurs_id CHARACTER VARYING,
	auftragswert_eur CHARACTER VARYING,
	projektnummer CHARACTER VARYING,
	projekt_oid CHARACTER VARYING,
	projekt CHARACTER VARYING,
	zugeordnete_aufgabe CHARACTER VARYING,
	mitarbeiter_oid CHARACTER VARYING,
	letzte_aenderung_von CHARACTER VARYING,
	aktualisiert_am CHARACTER VARYING,
	jdbctimestamp DECIMAL(15,0)
);

CREATE TABLE bcs_aufwandsplan (
	oid CHARACTER VARYING PRIMARY KEY UNIQUE,
	datum CHARACTER VARYING,
	projektnummer CHARACTER VARYING,
	projekt_oid CHARACTER VARYING,
	plan_t CHARACTER VARYING,
	rest_t CHARACTER VARYING,
	zugeordnete_aufgabe CHARACTER VARYING,
	aufwandsplanungsmodell CHARACTER VARYING,
	mitarbeiter_oid CHARACTER VARYING,
	letzte_aenderung_von CHARACTER VARYING,
	aktualisiert_am CHARACTER VARYING,
	jdbctimestamp DECIMAL(15,0)
);

CREATE TABLE bcs_buchungen (
	oid CHARACTER VARYING PRIMARY KEY UNIQUE,
	personalnummer CHARACTER VARYING,
	personal_oid CHARACTER VARYING,
	datum CHARACTER VARYING,
	startzeit CHARACTER VARYING,
	endezeit CHARACTER VARYING,
	dauer CHARACTER VARYING,
	projektnummer CHARACTER VARYING,
	aufgabe CHARACTER VARYING,
	beschreibung CHARACTER VARYING,
	letzte_aenderung_von CHARACTER VARYING,
	aktualisiert_am CHARACTER VARYING,
	jdbctimestamp decimal (15,0)
);

CREATE TABLE bcs_eingangsrechnungen (
	oid CHARACTER VARYING PRIMARY KEY UNIQUE,
	name CHARACTER VARYING,
	beschreibung CHARACTER VARYING,
	rechnungsdatum CHARACTER VARYING,
	waehrung CHARACTER VARYING,
	umsatzsteuersatz CHARACTER VARYING,
	erloeskonto CHARACTER VARYING,
	projekt CHARACTER VARYING,
	lieferant CHARACTER VARYING,
	letzte_aenderung_von CHARACTER VARYING,
	aktualisiert_am CHARACTER VARYING,
	jdbctimestamp DECIMAL(15,0)
);

CREATE TABLE bcs_konferenzregistrierung (
	oid CHARACTER VARYING PRIMARY KEY UNIQUE,
	name CHARACTER VARYING,
	status CHARACTER VARYING,
	person_vorname CHARACTER VARYING,
	person_nachname CHARACTER VARYING,
	organisation_der_person_oid CHARACTER VARYING,
	person_subtyp CHARACTER VARYING,
	person_flag_userconference CHARACTER VARYING,
	person_flag_airlineforum CHARACTER VARYING,
	zugeordnetes_konferenz_projekt CHARACTER VARYING,
	registrierung_bestaetigt CHARACTER VARYING,
	teilnehmergebuehr CHARACTER VARYING,
	teilnahme_gala_dinner CHARACTER VARYING,
	status_konferenz_hotel CHARACTER VARYING,
	in_rechnung_gestellt CHARACTER VARYING,
	rechnungsnummer CHARACTER VARYING,
	teilnahme_eroeffnungsdinner CHARACTER VARYING,
	foto_policy CHARACTER VARYING,
	raumreservierung_bestaetigt CHARACTER VARYING,
	gruppe_site_visit CHARACTER VARYING,
	status_registrierung CHARACTER VARYING,
	rechnungsstellung CHARACTER VARYING,
	vegetarier CHARACTER VARYING,
	ersteller_oid CHARACTER VARYING,
	eingefuegt_am CHARACTER VARYING,
	letzte_aenderung_von CHARACTER VARYING,
	aktualisiert_am CHARACTER VARYING,
	jdbctimestamp DECIMAL (15,0)
);

CREATE TABLE bcs_mitarbeiter (
	oid CHARACTER VARYING PRIMARY KEY UNIQUE,
	subtyp CHARACTER VARYING,
	vorname CHARACTER VARYING,
	nachname CHARACTER VARYING,
	kuerzel CHARACTER VARYING,
	anrede CHARACTER VARYING,
	email CHARACTER VARYING,
	persnr CHARACTER VARYING,
	gb CHARACTER VARYING,
	letzte_aenderung_von CHARACTER VARYING,
	aktualisiert_am CHARACTER VARYING,
	jdbctimestamp DECIMAL(15,0)
);

CREATE TABLE bcs_organisationen (
	oid CHARACTER VARYING PRIMARY KEY UNIQUE,
	name CHARACTER VARYING,
	kuerzel CHARACTER VARYING,
	subtyp CHARACTER VARYING,
	standort_waehrung CHARACTER VARYING,
	uebergeord_objekt CHARACTER VARYING,
	lieferant CHARACTER VARYING,
	branche CHARACTER VARYING,
	strasse CHARACTER VARYING,
	plz CHARACTER VARYING,
	stadt CHARACTER VARYING,
	land_iso CHARACTER VARYING,
	land CHARACTER VARYING,
	postfach CHARACTER VARYING,
	plz_postfach CHARACTER VARYING,
	kategorie CHARACTER VARYING,
	gb_relevanz CHARACTER VARYING,
	account_manager CHARACTER VARYING,
	referenzkunde CHARACTER VARYING,
	erlaubnis_logo_nutzung CHARACTER VARYING,
	beschreibung CHARACTER VARYING,
	letzte_aenderung_von CHARACTER VARYING,
	aktualisiert_am CHARACTER VARYING,
	jdbctimestamp DECIMAL(15,0)
	);

CREATE TABLE bcs_projekte (
	oid CHARACTER VARYING PRIMARY KEY UNIQUE,
	subtyp CHARACTER VARYING,
	name CHARACTER VARYING,
	status CHARACTER VARYING,
	organisation CHARACTER VARYING,
	projektleiter_oid CHARACTER VARYING,
	consultant_oid CHARACTER VARYING,
	abrechnungsart CHARACTER VARYING,
	projektnummer CHARACTER VARYING,
	pn_gesetzt CHARACTER VARYING,
	projektgruppe CHARACTER VARYING,
	uebergeordnetes_element CHARACTER VARYING,
	waehrung CHARACTER VARYING,
	intervall_auftragsplanung CHARACTER VARYING,
	projektkategorie CHARACTER VARYING,
	letzte_aenderung_von CHARACTER VARYING,
	aktualisiert_am CHARACTER VARYING,
	jdbctimestamp DECIMAL(15,0)
	);

CREATE TABLE bcs_rechnungen(
	oid CHARACTER VARYING PRIMARY KEY UNIQUE,
	rechnungsdatum CHARACTER VARYING,
	rechnungsnummer CHARACTER VARYING,
	faelligkeitsdatum CHARACTER VARYING,
	projektnummer CHARACTER VARYING,
	projekt_oid CHARACTER VARYING,
	nettobetrag CHARACTER VARYING,
	waehrung CHARACTER VARYING,
	umrechnungskurs_id CHARACTER VARYING,
	nettobetrag_eur CHARACTER VARYING,
	typ CHARACTER VARYING,
	status CHARACTER VARYING,
	erloes_konto CHARACTER VARYING,
	konto_soll CHARACTER VARYING,
	letzte_aenderung_von CHARACTER VARYING,
	aktualisiert_am CHARACTER VARYING,
	jdbctimestamp DECIMAL(15,0)
);

CREATE TABLE bcs_sachkosten (
	oid CHARACTER VARYING PRIMARY KEY UNIQUE,
	name CHARACTER VARYING,
	subtyp CHARACTER VARYING,
	aufgabe CHARACTER VARYING,
	projektnummer CHARACTER VARYING,
	lieferant CHARACTER VARYING,
	plansachkosten_referenz CHARACTER VARYING,
	einkaufskosten_plan CHARACTER VARYING,
	einkaufskosten_plan_eur CHARACTER VARYING,
	einkaufskosten CHARACTER VARYING,
	einkaufskosten_eur CHARACTER VARYING,
	waehrung CHARACTER VARYING,
	umrechnungskurs_id CHARACTER VARYING,
	eingangsrechnung CHARACTER VARYING,
	rechnungsdatum CHARACTER VARYING,
	letzte_aenderung_von CHARACTER VARYING,
	aktualisiert_am CHARACTER VARYING,
	jdbctimestamp DECIMAL(15,0)
);

CREATE TABLE bcs_spesen (
	oid CHARACTER VARYING PRIMARY KEY UNIQUE,
	personalnummer CHARACTER VARYING,
	personal_oid CHARACTER VARYING,
	buchungsmonat CHARACTER VARYING,
	projektnummer CHARACTER VARYING,
	reisekosten_eur CHARACTER VARYING,
	reisekosten_original CHARACTER VARYING,
	reisekosten_original_waehrung CHARACTER VARYING,
	belegart CHARACTER VARYING,
	letzte_aenderung_von CHARACTER VARYING,
	aktualisiert_am CHARACTER VARYING,
	jdbctimestamp DECIMAL(15,0)
);

CREATE TABLE bcs_stundensaetze (
	oid CHARACTER VARYING PRIMARY KEY UNIQUE,
	lohngruppe CHARACTER VARYING,
	name CHARACTER VARYING,
	beschreibung CHARACTER VARYING,
	gueltig_ab CHARACTER VARYING,
	stundensatz_intern CHARACTER VARYING,
	waehrung CHARACTER VARYING,
	letzte_aenderung_von CHARACTER VARYING,
	aktualisiert_am CHARACTER VARYING,
	jdbctimestamp DECIMAL(15,0)
);

CREATE TABLE bcs_termine (
	oid CHARACTER VARYING PRIMARY KEY UNIQUE,
	personalnummer CHARACTER VARYING,
	personal_oid CHARACTER VARYING,
	datum CHARACTER VARYING,
	projektnummer CHARACTER VARYING,
	ganztaegig CHARACTER VARYING,
	startzeit CHARACTER VARYING,
	endezeit CHARACTER VARYING,
	dauer CHARACTER VARYING,
	terminart CHARACTER VARYING,
	status CHARACTER VARYING,
	jdbctimestamp DECIMAL(15,0)
);

CREATE TABLE bcs_zahlungstermine (
	oid CHARACTER VARYING PRIMARY KEY UNIQUE,
	datum CHARACTER VARYING,
	betrag CHARACTER VARYING,
	waehrung CHARACTER VARYING,
	umrechnungskurs_id CHARACTER VARYING,
	betrag_eur CHARACTER VARYING,
	name CHARACTER VARYING,
	beschreibung CHARACTER VARYING,
	abgenommen CHARACTER VARYING,
	uebergeordnetes_objekt CHARACTER VARYING,
	projektnummer CHARACTER VARYING,
	erloesklasse CHARACTER VARYING,
	projekt_oid CHARACTER VARYING,
	status CHARACTER VARYING,
	zugeordnete_buchung CHARACTER VARYING,
	abgerechnet CHARACTER VARYING,
	erstellt_von CHARACTER VARYING,
	eingefuegt_am CHARACTER VARYING,
	letzte_aenderung_von CHARACTER VARYING,
	aktualisiert_am CHARACTER VARYING,
	jdbctimestamp DECIMAL(15,0)
);

ALTER TABLE bcs_akquisen OWNER TO bcs;
ALTER TABLE bcs_auftragsplan OWNER TO bcs;
ALTER TABLE bcs_aufwandsplan OWNER TO bcs;
ALTER TABLE bcs_buchungen OWNER TO bcs;
ALTER TABLE bcs_eingangsrechnungen OWNER TO bcs;;
ALTER TABLE bcs_konferenzregistrierung OWNER TO bcs;
ALTER TABLE bcs_mitarbeiter OWNER TO bcs;
ALTER TABLE bcs_organisationen OWNER TO bcs;
ALTER TABLE bcs_projekte OWNER TO bcs;
ALTER TABLE bcs_rechnungen OWNER TO bcs;
ALTER TABLE bcs_spesen OWNER TO bcs;
ALTER TABLE bcs_sachkosten OWNER TO bcs;
ALTER TABLE bcs_stundensaetze OWNER TO bcs;
ALTER TABLE bcs_termine OWNER TO bcs;
ALTER TABLE bcs_zahlungstermine OWNER TO bcs;