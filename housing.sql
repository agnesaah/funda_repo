--cd Funda
--psql test -f housing.sql
DROP TABLE housing;
DROP TABLE cbs_migration;

---------- CREATE COLUMNS AND TABLES ------------
CREATE TABLE housing (
globalId text,
publicatieDatum timestamp without time zone,
postcode text,
koopPrijs text,
volledigeOmschrijving text,
soortWoning text,
categorieObject text,
bouwjaar text,
indTuin text,
perceelOppervlakte text,
kantoor_naam_MD5hash text,
aantalKamers text,
aantalBadkamers text,
energielabelKlasse text,
globalId_1 text,
oppervlakte text,
datum_ondertekening timestamp without time zone
);

\copy housing FROM '/home/pi/Funda/housing_data.csv' with (format csv, header true, delimiter ',');

CREATE TABLE cbs_migration (
ID text,
Geslacht text,
Migratieachtergrond text,
Postcode text,
Perioden text,
Bevolking_omvang text
);

\copy cbs_migration FROM '/home/pi/Funda/cbs_migration.csv' with (format csv, header true, delimiter ';', encoding 'UTF8');




-------------- ADD/ALTER COLUMNS -------------

-- column koopPrijs (from text to int)
UPDATE housing
SET koopPrijs = '0'
WHERE koopPrijs = 'NULL';

ALTER TABLE housing
ALTER COLUMN koopPrijs TYPE integer
USING (koopPrijs::integer);


-- column timeOnMarket
ALTER TABLE housing 
ADD COLUMN timeOnMarket interval;

UPDATE housing 
SET timeOnMarket = datum_ondertekening - publicatieDatum;



------------- TIME ON MARKET ----------------

-- average days of timeOnMarket
SELECT AVG(timeOnMarket) AS average_time_on_market
FROM housing;

-- show column timeOnMarket next to dates
--SELECT publicatieDatum, datum_ondertekening, timeOnMarket 
--FROM housing;



------ VARIABLE 1: TERMS USED IN SUMMARY ------

-- Separate words
ALTER TABLE housing 
ADD lexemesWording tsvector;

UPDATE housing 
SET lexemesWording = to_tsvector(volledigeOmschrijving);

-- 'mooie'

SELECT AVG(koopPrijs) 
FROM housing 
WHERE lexemesWording @@ to_tsquery('mooie');

SELECT AVG(koopPrijs) 
FROM housing 
WHERE NOT lexemesWording @@ to_tsquery('mooie');

-- shows id and price of all objects that DO NOT contain the term 'mooie' in the description
--SELECT globalID, koopPrijs FROM housing WHERE NOT lexemesWording @@ to_tsquery('mooie');

-- average selling price
--SELECT AVG(koopPrijs)
--FROM housing

--SELECT AVG ()
--FROM housing
--WHERE lexemesWording @@ to_tsquery('mooie');

--SELECT AVG ()
--FROM housing
--WHERE NOT lexemesWording @@ to_tsquery('mooie');
