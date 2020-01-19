-- Ausgabe des Datums von heute
select date_trunc('day', now());

-- Übersicht über alle Types heute
select distinct type from history where 
	date(timestamp) = date_trunc('day', now());

-- Übersicht über Type und Reading für heute
select distinct type,reading from history where 
	date(timestamp) = date_trunc('day', now()) order by type,reading;

-- Anzahl der Datensätze für heute für die verschiedenen Readings
select reading, count(*) from (
	select 	reading 
	from 	history 
	where 	date(timestamp) = date_trunc('day', now())) 
	as reading 
	group by reading
	order by reading;

-- Alle Datensätze von heute 
select * from history where 
	date(timestamp) = date_trunc('day', now())
	order by timestamp;

-- Alle Datensätze von heute mit reading cpufreq
select * from history where 
	(date(timestamp) = date_trunc('day', now())
	and reading='cpufreq') order by timestamp;

-- Alle Datensätze von heute mit reading load
select * from history where 
	(date(timestamp) = date_trunc('day', now())
	and reading='load') order by timestamp;

-- Alle Datensätze von heute mit reading load
select * from history where 
	(date(timestamp) = date_trunc('day', now())
	and reading='temperature') order by timestamp;
