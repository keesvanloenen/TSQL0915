/* 🌶🌶 Exercise 5 - Derived table and Common Table Expression (CTE) */

USE adventureworks;
GO

-- Alles staat in de SalesOrderDetail tabel
SELECT 
    sod.SalesOrderID
    , SUM(sod.OrderQty * sod.UnitPrice * (1 - sod.UnitPriceDiscount)) AS Totaal
FROM SalesLT.SalesOrderDetail AS sod
GROUP BY sod.SalesOrderID;



-- Controle query: komen er evenveel rijen terug
SELECT DISTINCT (SalesOrderId) FROM SalesLT.SalesOrderHeader;

-- Gebruik bovenstaande query als DERIVED TABLE
SELECT 
    soh.CustomerID
    , AVG(OrdersTotalAmount.Totaal) AS gemiddeldeOrderTotaal
    , SUM(OrdersTotalAmount.Totaal) AS somOrderTotaal
FROM
(
    SELECT 
        sod.SalesOrderID
        , SUM(sod.OrderQty * sod.UnitPrice * (1 - sod.UnitPriceDiscount)) AS Totaal
    FROM SalesLT.SalesOrderDetail AS sod
    GROUP BY sod.SalesOrderID
) AS OrdersTotalAmount
INNER JOIN SalesLT.SalesOrderHeader AS soh
ON soh.SalesOrderID = OrdersTotalAmount.SalesOrderID
GROUP BY soh.CustomerID;

-- Nu als CTE

WITH OrdersTotalAmount AS
(
    SELECT 
        sod.SalesOrderID
        , SUM(sod.OrderQty * sod.UnitPrice * (1 - sod.UnitPriceDiscount)) AS Totaal
    FROM SalesLT.SalesOrderDetail AS sod
    GROUP BY sod.SalesOrderID
)
SELECT 
    soh.CustomerID
    , AVG(ota.Totaal) AS gemiddeldeOrderTotaal
    , SUM(ota.Totaal) AS somOrderTotaal
FROM OrdersTotalAmount AS ota
INNER JOIN SalesLT.SalesOrderHeader AS soh
ON soh.SalesOrderID = ota.SalesOrderID
GROUP BY soh.CustomerID;

----------------------------------------------------------------------------

    
