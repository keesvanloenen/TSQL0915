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