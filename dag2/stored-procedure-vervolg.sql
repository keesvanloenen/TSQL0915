USE adventureworks;
GO

CREATE OR ALTER PROCEDURE SalesLT.DetailsForOrder 
	@OrderId AS int = 71780,
	@Aantal AS int OUT
AS
BEGIN
	SET NOCOUNT, XACT_ABORT ON;

	IF (@OrderId < 10)
	BEGIN
		THROW 50001, 'Gij zult geen OrderId bla bla', 1;
	END;

	SELECT 
		@Aantal = COUNT(*)
	FROM SalesLT.SalesOrderDetail 
	WHERE SalesOrderID = @OrderId;

	SELECT 
		SalesOrderId
		, OrderQty
		, ProductID
	FROM SalesLT.SalesOrderDetail
	WHERE SalesOrderID = @OrderId;
END;

--------------------------------------------------------------------

DECLARE @MijnAantal AS int = 0;

BEGIN TRY
EXECUTE SalesLT.DetailsForOrder @OrderId = 4, @Aantal = @MijnAantal OUT;
END TRY
BEGIN CATCH
	SELECT CASE ERROR_NUMBER()
		WHEN 50001 THEN CONCAT_WS(' ', 'Jammer', ERROR_NUMBER(), ERROR_MESSAGE(), ERROR_SEVERITY())
		WHEN 50002 THEN 'Gebeurt nooit'
		ELSE			'Gebeurt ook nooit'
	END
	--PRINT CONCAT_WS(' ', 'Jammer', ERROR_NUMBER(), ERROR_MESSAGE(), ERROR_SEVERITY());
	THROW
END CATCH

PRINT @MijnAantal;


