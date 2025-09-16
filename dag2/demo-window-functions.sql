-- **************************************************************
-- Deel 1: focus op WINDOW en functions zoals RANK() en NTILE().
-- Deel 2: focus op FRAMING.
-- Deel 3: focus op PARTITIONING.
-- Deel 4: WINDOW function vs Subquery
-- **************************************************************

-- ******************************************************
-- 0. Voorbereiding: aanmaken database en 1 simpele tabel
-- ******************************************************
USE master;
GO

DROP DATABASE IF EXISTS DemoWindowFunctions;

CREATE DATABASE DemoWindowFunctions;
GO

USE DemoWindowFunctions;
GO

DROP TABLE IF EXISTS dbo.bestellingen;
DROP TABLE IF EXISTS dbo.categorie_bestellingen;
GO

CREATE TABLE bestellingen
(
	datum	date NOT NULL,
	aantal	int NULL
);
GO

INSERT INTO bestellingen
VALUES
(DATEADD(day, -5, SYSDATETIME()), 70),
(DATEADD(day, -4, SYSDATETIME()), 100),
(DATEADD(day, -3, SYSDATETIME()), 80),
(DATEADD(day, -2, SYSDATETIME()), 80),
(DATEADD(day, -1, SYSDATETIME()), 50),
(DATEADD(day, 0, SYSDATETIME()), 300);
GO

-- *************************************************************
-- Deel 1: focus op WINDOW en functions zoals RANK() en NTILE().
-- *************************************************************

-- In elke rij het totaal laten zien kan dankzij deze window function: SUM() OVER ()
SELECT 
	datum 
	, aantal
	, SUM(aantal) OVER () AS totaal
FROM bestellingen;

-- Wat handig is als je percentages over het totaal wilt ophalen
SELECT 
	datum
	, aantal
	, aantal / SUM(aantal) OVER () AS perc
	, (aantal * 1.) / SUM(aantal) OVER () AS perc
	, CAST((aantal * 1.) / SUM(aantal) OVER () AS DECIMAL(3,2)) AS perc
FROM bestellingen;

-- Terug naar wat we hadden
SELECT 
	datum 
	, aantal
	, SUM(aantal) OVER () AS totaal
FROM bestellingen;

-- OVER () betekent OVER ALLE RIJEN
-- OVER (ORDER BY datum) laat de WINDOW function cumulatief/running rekenen
-- Je krijgt hier dus een running total als je enkel ORDER BY gebruikt!
-- De reden waarom komt straks voorbij
SELECT 
	datum 
	, aantal
	, SUM(aantal) OVER (ORDER BY datum) AS running_total
FROM bestellingen

-- + RANK()
SELECT 
	datum 
	, aantal
	, SUM(aantal) OVER (ORDER BY datum ASC)		AS running_total
	, RANK() OVER (ORDER BY aantal DESC)		AS rank_aantal
FROM bestellingen
ORDER BY datum;

-- + DENSE_RANK()
SELECT 
	datum 
	, aantal
	, SUM(aantal) OVER (ORDER BY datum)			AS running_total
	, RANK() OVER (ORDER BY aantal DESC)		AS rank_aantal
	, DENSE_RANK() OVER (ORDER BY aantal DESC)	AS denserank_aantal
FROM bestellingen
ORDER BY datum;

-- + ROW_NUMBER()
SELECT 
	datum 
	, aantal
	, SUM(aantal) OVER (ORDER BY datum)			AS running_total
	, RANK() OVER (ORDER BY aantal DESC)		AS rank_aantal
	, DENSE_RANK() OVER (ORDER BY aantal DESC)	AS denserank_aantal
	, ROW_NUMBER() OVER (ORDER BY datum)		AS rownumber_datum
	, ROW_NUMBER() OVER (ORDER BY aantal)		AS rownumber_aantal
FROM bestellingen
ORDER BY datum;

-- + NTILE()
SELECT 
	datum 
	, aantal
	, SUM(aantal) OVER (ORDER BY datum)			AS running_total
	, RANK() OVER (ORDER BY aantal DESC)		AS rank_aantal
	, DENSE_RANK() OVER (ORDER BY aantal DESC)	AS denserank_aantal
	, ROW_NUMBER() OVER (ORDER BY datum)		AS rownumber_datum
	, ROW_NUMBER() OVER (ORDER BY aantal)		AS rownumber_aantal
	, NTILE(3) OVER (ORDER BY aantal)			AS ntile_aantal
FROM bestellingen
--ORDER BY datum;

-- Terug naar enkel Running total
SELECT 
	datum 
	, aantal
	, SUM(aantal) OVER (ORDER BY datum)		AS running_total
FROM bestellingen;

-- *************************
-- Deel 2: focus op FRAMING.
-- *************************

-- Standaard framing option als je niets opgeeft:
-- RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

SELECT 
	datum
	, aantal
	, SUM(aantal) OVER (
					ORDER BY datum
					ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
				  ) AS running_total
FROM bestellingen;

SELECT 
	datum 
	, aantal
	, SUM(aantal) OVER (
	                ORDER BY datum
				    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
				  ) AS running_aantal
FROM bestellingen;

SELECT 
	datum
	, aantal
	, SUM(aantal) OVER (
	                ORDER BY datum
				    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
				  ) AS running_aantal
FROM bestellingen;

SELECT 
	datum, 
	aantal,
	SUM(aantal) OVER (
	              ORDER BY datum
				  ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING
				) AS ander_aantal
FROM bestellingen;

SELECT 
	datum 
	, aantal
	, SUM(aantal) OVER (
	                ORDER BY datum
				    ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
				  ) AS ander_aantal
FROM bestellingen
-- ORDER BY datum ASC;

-- Terug naar enkel Running total
SELECT 
	datum 
	, aantal
	, SUM(aantal) OVER (ORDER BY datum) AS running_total
FROM bestellingen;

-- ======================================================
-- Optioneel: verschil tussen RANGE en ROWS

-- Twee records voor dezelfde dag:
INSERT INTO bestellingen
VALUES
(DATEADD(day, -3, SYSDATETIME()), 50);

SELECT * FROM bestellingen ORDER BY datum;

-- Running totals worden op LOGISCHE wijze berekend:
SELECT 
	datum 
	, aantal
	, SUM(aantal) OVER (ORDER BY datum) AS running_total
FROM bestellingen;

-- Dit komt door de default framing: RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
SELECT 
	datum
	, aantal
	, SUM(aantal) OVER (
					ORDER BY datum
					RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
				  ) AS ander_aantal
FROM bestellingen
ORDER BY datum ASC;

-- 'RANGE' dwingt een 'LOGISCHE' benadering af.
-- 'ROWS' daarentegen dwingt een 'FYSIEKE' benadering af.
SELECT 
	datum
	, aantal
	, SUM(aantal) OVER (
					ORDER BY datum
					ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
				  ) AS ander_aantal
FROM bestellingen
ORDER BY datum ASC;

-- ======================================================

-- LAG LEAD FIRST_VALUE en LAST_VALUE
SELECT
	datum
	, aantal
	, LAG(aantal) OVER (ORDER BY datum)			 AS vorigewaarde
	, aantal - LAG(aantal) OVER (ORDER BY datum) AS [verschil met vorige dag]
	, LEAD(aantal) OVER (ORDER BY datum)		 AS volgendewaarde
	, FIRST_VALUE(aantal) OVER (ORDER BY datum)	 AS eerstewaarde
	, LAST_VALUE(aantal) OVER (
							ORDER BY datum 
							ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
						 )						 AS laatstewaarde
FROM bestellingen;

-- ******************************
-- Deel 3: focus op PARTITIONING.
-- ******************************

CREATE TABLE categorie_bestellingen
(
	datum		date NOT NULL,
	categorie	nvarchar(25) NOT NULL,
	aantal		int NULL
);
GO

INSERT INTO categorie_bestellingen
VALUES
(DATEADD(day, -4, SYSDATETIME()), 'pc', 25),
(DATEADD(day, -4, SYSDATETIME()), 'cable', 75),
(DATEADD(day, -3, SYSDATETIME()), 'cable', 75),
(DATEADD(day, -3, SYSDATETIME()), 'pc', 75),
(DATEADD(day, -2, SYSDATETIME()), 'pc', 0),
(DATEADD(day, -2, SYSDATETIME()), 'cable', 75),
(DATEADD(day, -1, SYSDATETIME()), 'cable', 40),
(DATEADD(day, -1, SYSDATETIME()), 'pc', 10),
(DATEADD(day, 0, SYSDATETIME()), 'cable', 200),
(DATEADD(day, 0, SYSDATETIME()), 'pc', 100);
GO

SELECT datum, categorie, aantal 
FROM categorie_bestellingen;

-- OVER icm partitioning
-- Ook hier weer: gebruik je ORDER BY dan krijg je standaard een running total!
-- Wat gebeurt er als je 'ORDER BY datum' weghaalt uit de query?
SELECT 
	datum
	, categorie
	, aantal
	, SUM(aantal) OVER (
					PARTITION BY categorie 
					ORDER BY datum
				  ) AS running_aantal
FROM categorie_bestellingen;

-- Hoe zal de RANK er hier uitzien?
SELECT 
	datum
	, categorie
	, aantal
	, SUM(aantal) OVER (
					PARTITION BY categorie 
					ORDER BY datum
				  ) AS running_aantal
	, RANK() OVER (
			   PARTITION BY categorie 
			   ORDER BY aantal
			 ) AS rank_aantal
FROM categorie_bestellingen
ORDER BY categorie, datum;

-- Alle opties
SELECT 
	datum, 
	categorie, 
	aantal,
	SUM(aantal) OVER (
				  PARTITION BY categorie 
				  ORDER BY datum
				  ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
				) AS running_aantal
FROM categorie_bestellingen;

-- ***********************************
-- Deel 4: WINDOW function vs Subquery
-- ***********************************
-- Als Window Function
SELECT
	datum
	, aantal
	, SUM(aantal) OVER (ORDER BY datum) AS perc
FROM bestellingen;

-- Als Subquery
SELECT
    b.datum,
    b.aantal,
    (
		SELECT SUM(b2.aantal) 
		FROM bestellingen b2 
		WHERE b2.datum <= b.datum
	) AS perc
FROM bestellingen b;

-- Bij meer data presteert de Window Function (veel) beter
-- Onderstaand script geeft de Bestellingen tabel meer rijen
-- Herhaal daarna bovenstaande 2 queries en vergelijk
TRUNCATE TABLE Bestellingen;

WITH Numbers AS (
    SELECT TOP (2500)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects a
    CROSS JOIN sys.objects b
)
INSERT INTO bestellingen (Datum, Aantal)
SELECT 
    DATEADD(DAY, n, '2020-01-01')		 AS Datum,  -- Startdatum
    ABS(CHECKSUM(NEWID(), n)) % 300 + 1  AS Aantal  -- Random aantal tussen 1 en 300
FROM Numbers;
GO

SELECT datum, aantal FROM bestellingen;	-- 2500 rijen ipv 6
