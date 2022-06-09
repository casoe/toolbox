-- Geradeziehen alle Jahr- und Monatsspalten, kann bei nachträglichen Buchungen/Stornierungen unterschiedlich sein 
update datev_umsatz set monat=extract(month from datum);
update datev_umsatz set jahr=extract(year from datum);
update datev_kosten set monat=extract(month from datum);
update datev_kosten set jahr=extract(year from datum);
update datev_honorare set monat=extract(month from datum);
update datev_honorare set jahr=extract(year from datum);

-- UMSATZTABELLE
-- Reparatur einzelner inkorrekter Buchungen
-- update datev_umsatz set buchungstext='TEXT' where buchungstext like 'TEXT' and datum='DATUM';
update datev_umsatz set buchungstext='70362 Amazon Web Services, USA, oV - USD 3.458,34' where buchungstext like '70632 Amazon Web Services, USA, oV - USD 3.458,34' and datum='2020-05-02';
update datev_umsatz set buchungstext='70070 Esforay GmbH Geilenkirchen neu' where buchungstext like '70020 Esforay GmbH Geilenkirchen neu' and datum='2018-04-07';

-- Wenn die ersten 5 Zeichen des Buchungstexts numerisch sind, in das Feld kost1 schreiben
update datev_umsatz set kost1=left(buchungstext,5) where left(buchungstext,5) ~ '^[0-9\.]+$';
-- Anschließend noch mal mit Typecast decimal auf die ersten 6 Zeichen, um eine führende 0 und ggf. Leerzeichen loszuwerden
update datev_umsatz set kost1=left(buchungstext,6)::decimal where left(buchungstext,6) ~ '^[0-9\.]+$';

-- Berücksichtigung einzelner Buchungen, bei denen das nicht passt
-- update datev_umsatz set buchungstext='TEXT' where buchungstext like 'TEXT' and datum='DATUM';

-- Alle verbleibenden .0-Endungen in kost1 abschneiden
update datev_umsatz set kost1=left(kost1,5);

-- KOSTENTABELLE
-- Reparatur einzelner inkorrekter Buchungen
-- update datev_kosten set buchungstext='TEXT' where buchungstext like 'TEXT' and datum='DATUM';
update datev_kosten set buchungstext='70010 BDAE Vers. Entsendung Rossa o V' where buchungstext like '700010 BDAE Vers. Entsendung Rossa o V' and datum='2018-06-18';
update datev_kosten set buchungstext='70010 BDAE Vers. Entsendung Rossa o V neu' where buchungstext like '700010 BDAE Vers. Entsendung Rossa o V neu' and datum='2018-06-18';
update datev_kosten set buchungstext='70010 BDAE Vers. Entsendung Rossa o V Storno' where buchungstext like '700010 BDAE Vers. Entsendung Rossa o V Storno' and datum='2018-06-18';

-- Wenn die ersten 5 Zeichen des Buchungstexts numerisch sind, in das Feld kost1 schreiben
update datev_kosten set kost1=left(buchungstext,5) where left(buchungstext,5) ~ '^[0-9\.]+$';

-- Alle verbleibenden .0-Endungen in kost1 abschneiden
update datev_kosten set kost1=left(kost1,5);

-- HONORARTABELLE
-- Reparatur einzelner inkorrekter Buchungen
-- update datev_honorare set buchungstext='TEXT' where buchungstext like 'TEXT' and datum='DATUM';

-- Wenn die ersten 5 Zeichen des Buchungstexts numerisch sind, in das Feld kost1 schreiben
update datev_honorare set kost1=left(buchungstext,5) where left(buchungstext,5) ~ '^[0-9\.]+$';

-- Alle verbleibenden .0-Endungen in kost1 abschneiden
update datev_honorare set kost1=left(kost1,5);