USE adventureworks;
GO

/*
1. Which customers have got at least one order?
   Rewrite next query to optimize performance
   Provide evidence
*/

SELECT DISTINCT c.LastName
FROM SalesLT.Customer c
INNER JOIN SalesLT.SalesOrderHeader o 
ON c.CustomerID = o.CustomerId;

SELECT c.LastName
FROM SalesLT.Customer c
WHERE EXISTS
(
	SELECT 1
	FROM SalesLT.SalesOrderHeader
	WHERE CustomerID = c.CustomerID
);


/*
2. Next query returns the product with the most recent productid and its category.
   Rewrite the query in a way that per category the product with the most recent productid is returned.
   Use a correlated subquery for good performance:
*/

SELECT 
    pc.Name			AS Categorie,
    p.Name			AS Product,
    p.ProductID		AS ProductID
FROM SalesLT.ProductCategory AS pc
INNER JOIN SalesLT.Product AS p
ON pc.ProductCategoryID = p.ProductCategoryID
WHERE p.ProductID = 
(
	SELECT MAX(ProductID)
	FROM SalesLT.Product
);

SELECT 
    pc.Name			AS Categorie,
    p.Name			AS Product,
    p.ProductID		AS ProductID
FROM SalesLT.ProductCategory AS pc
INNER JOIN SalesLT.Product AS p
ON pc.ProductCategoryID = p.ProductCategoryID
WHERE p.ProductID = 
(
	SELECT MAX(ProductID)
	FROM SalesLT.Product
	WHERE ProductCategoryID = pc.ProductCategoryID	-- 👈 add
);

/*
3. Next query returns the 3 most expensive products and their categories.
   Rewrite the query in a way that per category the 2 most expensive products are shown.
   Assume you don't have write access on the database
   For good performance, APPLY a derived table (not seen before ...)

   Fine tuning: 
   - If not done already, also show the categories without any product
   - If prices of more than 3 products are identical, show more than 3 products
*/

SELECT TOP(3)
	pc.Name			AS Categorie
	, p.Name		AS Product
	, p.ListPrice	AS Price
FROM SalesLT.ProductCategory AS pc
INNER JOIN SalesLT.Product AS p
ON pc.ProductCategoryID = p.ProductCategoryID
ORDER BY p.ListPrice DESC;

SELECT
	pc.Name			AS Categorie
	, p.Name		AS Product
	, p.ListPrice	AS Price
FROM SalesLT.ProductCategory AS pc
OUTER APPLY				-- 👈 Toon ook categorieën zónder product
(
	SELECT TOP(2) WITH TIES		-- 👈 Maak de TOP wat 'eerlijker', zie bijv. categorie 'Mountain Frames'
		*
	FROM SalesLT.Product AS p
	WHERE p.ProductCategoryID = pc.ProductCategoryID
	ORDER BY p.ListPrice DESC
) AS p
ORDER BY
	Categorie
	, Product;

