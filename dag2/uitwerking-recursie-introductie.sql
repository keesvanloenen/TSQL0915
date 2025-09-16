USE tempdb;
GO

DROP TABLE IF EXISTS Medewerkers;
GO

CREATE TABLE Medewerkers
(
	Id		int IDENTITY,
	Naam		nvarchar(100) NOT NULL,
	ManagerId	int NULL
);
GO

INSERT INTO Medewerkers 
(Naam, ManagerId) 
VALUES 
('Toon', NULL), -- Id = 1 
('Mirjam', 1),  -- Id = 2
('Bas', 1),	-- Id = 3
('Lammert', 1), -- Id = 4
('Ab', 2),	-- Id = 5
('Bo', 3),	-- Id = 6
('Cas', 4),	-- Id = 7
('Dik', 5),	-- Id = 8
('Fem', 6),	-- Id = 9
('Gabi', 6);	-- Id = 10
GO

-- Een self join om de manager namen te tonen ipv een id
SELECT 
	m.Naam		AS medewerker
	, m2.Naam	AS manager
FROM Medewerkers AS m
LEFT OUTER JOIN Medewerkers AS m2
ON m.ManagerId = m2.Id;

-- Voeg kolom 'Level' toe

WITH MedewerkersManagers AS
(
	-- Anchor/Base member
	SELECT
		Id
		, Naam
		, ManagerId
		, 1 AS Level
	FROM Medewerkers
	WHERE ManagerId IS NULL

	UNION ALL

	-- Recursive member
	SELECT
		m.Id
		, m.Naam
		, m.ManagerId
		, mm.Level + 1
	FROM Medewerkers AS m
	INNER JOIN MedewerkersManagers AS mm
	ON m.ManagerId = mm.Id
)
SELECT 
	* 
FROM MedewerkersManagers
ORDER BY Id;

-- Nu met de self join erbij:

WITH MedewerkersManagers AS
(
	-- Anchor/Base member
	SELECT
		Id
		, Naam
		, ManagerId
		, 1 AS Level
	FROM Medewerkers
	WHERE ManagerId IS NULL

	UNION ALL

	-- Recursive member
	SELECT
		m.Id
		, m.Naam
		, m.ManagerId
		, mm.Level + 1
	FROM Medewerkers AS m
	INNER JOIN MedewerkersManagers AS mm
	ON m.ManagerId = mm.Id
)
SELECT 
	mm.Naam		AS medewerker
	, mm2.Naam	AS manager
FROM MedewerkersManagers AS mm
LEFT OUTER JOIN MedewerkersManagers AS mm2
ON mm.ManagerId = mm2.Id
ORDER BY mm.Id;