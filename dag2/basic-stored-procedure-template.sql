CREATE	Procedure [dbo].[]  --INSERT PROC NAME HERE
AS

BEGIN
SET NOCOUNT, XACT_ABORT ON;

DECLARE @transtate BIT
IF @@TRANCOUNT = 0
BEGIN
	SET @transtate = 1
	BEGIN TRANSACTION; --Don't begin a transaction if there is already a transaction
END
 
BEGIN TRY
 
/*INSERT CODE HERE*/
	
	IF @transtate = 1 
        AND XACT_STATE() = 1
        COMMIT TRANSACTION; --Only commit if this stored procedure started the transaction.
END TRY
BEGIN CATCH
 
   IF @transtate = 1 
   AND XACT_STATE() <> 0
   ROLLBACK TRANSACTION; --Rollback only if this is the stored procedure that started the transaction
 
   THROW --Make sure the error gets thrown so the outer transaction will move into the CATCH
 
END CATCH
END