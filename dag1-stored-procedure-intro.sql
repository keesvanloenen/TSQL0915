USE adventureworks;
GO

CREATE OR ALTER PROCEDURE SalesLT.DetailsForOrder 
@OrderId AS int = 71780
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		COUNT(*) AS aantal
	FROM SalesLT.SalesOrderDetail 
	WHERE SalesOrderID = @OrderId;

	SELECT 
		SalesOrderId
		, OrderQty
		, ProductID
	FROM SalesLT.SalesOrderDetail
	WHERE SalesOrderID = @OrderId;
END;

EXECUTE SalesLT.DetailsForOrder --@OrderId = 71780


