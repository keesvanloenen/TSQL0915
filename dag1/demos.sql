-- Simpele INNER JOIN
SELECT 
	pc.Name			AS CategorieNaam
	, p.Name		AS ProductNaam
	, p.ListPrice	AS Prijs
FROM SalesLT.Product AS p
INNER JOIN SalesLT.ProductCategory AS pc
ON p.ProductCategoryID = pc.ProductCategoryID;

-- Per CategorieNaam het aantal producten
SELECT 
	LEFT(pc.Name, 3)	AS CategorieNaam
	, COUNT(*)			AS Aantal
	, AVG(p.ListPrice)	AS GemiddeldePrijs
FROM SalesLT.Product AS p
INNER JOIN SalesLT.ProductCategory AS pc
ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY LEFT(pc.Name, 3);

-- Per CategorieNaam het aantal producten (met WHERE en HAVING)
SELECT 
	LEFT(pc.Name, 3)	AS CategorieNaam
	, COUNT(*)			AS Aantal
	, AVG(p.ListPrice)	AS GemiddeldePrijs
FROM SalesLT.Product AS p
INNER JOIN SalesLT.ProductCategory AS pc
ON p.ProductCategoryID = pc.ProductCategoryID
WHERE p.Color <> 'Red'
GROUP BY LEFT(pc.Name, 3)
HAVING COUNT(*) > 25
ORDER BY Aantal DESC;

-- SubQuery 
SELECT 
	pc.Name			AS CategorieNaam
	, p.Name		AS ProductNaam
	, p.ListPrice	AS Prijs
FROM SalesLT.Product AS p
INNER JOIN SalesLT.ProductCategory AS pc
ON p.ProductCategoryID = pc.ProductCategoryID
WHERE p.ListPrice >
(
	SELECT 
		AVG(ListPrice) 
	FROM SalesLT.Product
);

-- SubQuery ook in SELECT (self-contained = apart uitvoerbaar)
SELECT 
	pc.Name			AS CategorieNaam
	, p.Name		AS ProductNaam
	, p.ListPrice	AS Prijs
	, (SELECT SUM(ListPrice) FROM SalesLT.Product)	 AS TotalePrijs
	, p.ListPrice / (SELECT SUM(ListPrice) FROM SalesLT.Product) AS Percentage
FROM SalesLT.Product AS p
INNER JOIN SalesLT.ProductCategory AS pc
ON p.ProductCategoryID = pc.ProductCategoryID;

-- Correlated Subquery
SELECT 
	soh.CustomerID
	, soh.SalesOrderID
	, soh.OrderDate
FROM SalesLT.SalesOrderHeader AS soh
WHERE soh.SalesOrderID =
(
	SELECT 
		MAX(SalesOrderID)
	FROM SalesLT.SalesOrderHeader
	WHERE CustomerID = soh.CustomerID -- 👈 correlatie
);

-- EXISTS
-- Alle Customers die nog geen Order hebben geplaatst:

-- CTRL+M (Estimated Subtree Cost)
SELECT 
	c.CustomerID
FROM SalesLT.Customer AS c
LEFT OUTER JOIN SalesLT.SalesOrderHeader AS soh
ON c.CustomerID = soh.CustomerID
WHERE soh.SalesOrderID IS NULL;


SELECT 
	c.CustomerID
FROM SalesLT.Customer AS c
WHERE NOT EXISTS
(
	SELECT 
		1
	FROM SalesLT.SalesOrderHeader
	WHERE CustomerID = c.CustomerID
);

GO
----------------------------------------------

-- 1. VIEW (één van de 4 Table Expressions)

CREATE OR ALTER VIEW dbo.CustomersWithoutOrders
AS
SELECT 
	c.CustomerID
FROM SalesLT.Customer AS c
WHERE NOT EXISTS
(
	SELECT 
		1
	FROM SalesLT.SalesOrderHeader
	WHERE CustomerID = c.CustomerID
);
GO

------------------------------------------------
-- View zijn in SQL Server ook updatabale indien
-- er één achterliggende tabel gebruikt wordt
-- (dus geen INNER JOIN etc.)

INSERT INTO SalesLT.ProductCategory
(ParentProductCategoryID, Name)
VALUES
(2, 'Fietsbel');
GO

-- Eenvoudig voorbeeld van een updatable VIEW
CREATE OR ALTER VIEW SalesLT.Categorie
AS
SELECT 
	pc.ParentProductCategoryID
	, pc.Name
FROM SalesLT.ProductCategory AS pc;
GO

INSERT INTO SalesLT.Categorie
(ParentProductCategoryID, Name)
VALUES
(2, 'Handrem X');

--------------------------------------------

-- 2. TVF
GO
CREATE OR ALTER FUNCTION SalesLT.ProductenPrijsHogerDan
(@priceBoundary AS decimal(10,2))
RETURNS table
AS
RETURN
SELECT 
	pc.Name			AS CategorieNaam
	, p.Name		AS ProductNaam
	, p.ListPrice	AS Prijs
FROM SalesLT.Product AS p
INNER JOIN SalesLT.ProductCategory AS pc
ON p.ProductCategoryID = pc.ProductCategoryID
WHERE p.ListPrice > @priceBoundary;
GO

SELECT * FROM SalesLT.ProductenPrijsHogerDan(1000);

------------------------------------------------------
-- CROSS APPLY / OUTER APPLY

SELECT * FROM SalesLT.SalesOrderHeader

--DECLARE @customerID AS int;
--SET @customerID = 29741;

GO

CREATE OR ALTER FUNCTION SalesLT.TopOrdersPerCustomer
(@customerID AS int)
RETURNS TABLE
AS
RETURN
SELECT TOP(3)
	*
FROM SalesLT.SalesOrderHeader AS soh
WHERE soh.CustomerID = @customerID
ORDER BY soh.SalesOrderID DESC;
GO

SELECT 
	CONCAT_WS(' ', c.FirstName, c.MiddleName, c.LastName) AS FullName
	, topc.SalesOrderID
FROM SalesLT.Customer AS c
OUTER APPLY SalesLT.TopOrdersPerCustomer(c.CustomerID) AS topc
ORDER BY FullName;

------------------------------------------------------

-- 3. Derived Table (= subquery achter de FROM, denk aan de ALIAS!!!)
SELECT
	plaats
	, provincie
	, COUNT(*)		AS aantal
FROM
(
	SELECT 
		c.LastName				AS klantachternaam
		, a.AddressLine1		AS adresregel
		, a.City				AS plaats
		, a.CountryRegion		AS provincie
	FROM SalesLT.Customer AS c
	INNER JOIN SalesLT.CustomerAddress AS ca
	ON c.CustomerID = ca.CustomerID
	INNER JOIN SalesLT.Address AS a
	ON ca.AddressID = a.AddressID
) AS KlantenLocaties
GROUP BY 
	plaats
	, provincie;

-- 4. Common Table Expression (CTE = 'with statement')

WITH KlantenLocaties AS
(
	SELECT 
		c.LastName				AS klantachternaam
		, a.AddressLine1		AS adresregel
		, a.City				AS plaats
		, a.CountryRegion		AS provincie
	FROM SalesLT.Customer AS c
	INNER JOIN SalesLT.CustomerAddress AS ca
	ON c.CustomerID = ca.CustomerID
	INNER JOIN SalesLT.Address AS a
	ON ca.AddressID = a.AddressID
)
SELECT
	kl.plaats
	, kl.provincie
	, COUNT(*)		AS aantal
FROM KlantenLocaties AS kl
GROUP BY 
	kl.plaats
	, kl.provincie;

