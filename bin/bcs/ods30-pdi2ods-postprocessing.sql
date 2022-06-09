-- Geradeziehen alle Jahr- und Monatsspalten, kann bei nachträglichen Buchungen/Stornierungen unterschiedlich sein 
update datev_umsatz set monat=extract(month from datum);
update datev_umsatz set jahr=extract(year from datum);
update datev_kosten set monat=extract(month from datum);
update datev_kosten set jahr=extract(year from datum);
update datev_honorare set monat=extract(month from datum);
update datev_honorare set jahr=extract(year from datum);

-- UMSATZTABELLE
-- Reparatur einzelner inkorrekter Buchungen
-- update datev_umsatz set buchungstext='TEXT' where buchungstext like 'TEXT'and datum='DATUM';
update datev_umsatz set buchungstext='34933 Delta Air Lines, USD 16.338,00' where buchungstext like '94933 Delta Air Lines, USD 16.338,00' and datum='2019-01-23';

-- Wenn die ersten 5 Zeichen des Buchungstexts numerisch sind, in das Feld kost1 schreiben
update datev_umsatz set kost1=left(buchungstext,5) where left(buchungstext,5) ~ '^[0-9\.]+$';
-- Anschließend noch mal mit Typecast decimal auf die ersten 6 Zeichen, um eine führende 0 und ggf. Leerzeichen loszuwerden
update datev_umsatz set kost1=left(buchungstext,6)::decimal where left(buchungstext,6) ~ '^[0-9\.]+$';

-- Berücksichtigung einzelner Buchungen, bei denen das nicht passt
update datev_umsatz set kost1=left(beleg1,5) where left(buchungstext,5) like 'WISAG' and datum='2012-12-14';

-- Alle verbleibenden .0-Endungen in kost1 abschneiden
update datev_umsatz set kost1=left(kost1,5);

-- KOSTENTABELLE
-- Reparatur einzelner inkorrekter Buchungen
-- update datev_kosten set buchungstext='TEXT' where buchungstext like 'TEXT' and datum='DATUM';
update datev_kosten set buchungstext='39000 EC DB Vetter Fremdf' where buchungstext like '3900 EC DB Vetter Fremdf' and datum='2011-02-25';

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