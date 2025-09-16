USE tempdb;
GO

-- 1. Standaard kunnen we een tabel met sampel data vullen op imperatieve wijze:

DROP TABLE IF EXISTS Nummers;

CREATE TABLE Nummers
(
	Teller int NOT NULL,
	City nvarchar(100)
);
GO

SET NOCOUNT ON;

DECLARE @index AS int = 1;

WHILE @index <= 10
BEGIN
	INSERT INTO Nummers
	(Teller, City)
	VALUES
	(@index, CONCAT_WS(' ', 'City', @index));

	SET @index += 1;
END;
GO

-- 2. Het kan ook op declaratieve wijze

-- SELECT * FROM sys.all_objects 
SELECT COUNT(*) FROM sys.all_objects AS a CROSS JOIN sys.all_objects AS b;
SELECT TOP(10) 'Hoi' AS groet FROM sys.all_objects;
SELECT TOP(10) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS groet FROM sys.all_objects;

INSERT INTO Nummers
(Teller, City)
SELECT TOP(10) 
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
	, CONCAT_WS(' ', 'City', ROW_NUMBER() OVER (ORDER BY (SELECT NULL)))
FROM sys.all_objects;


