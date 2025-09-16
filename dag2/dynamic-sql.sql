SELECT 
    *
FROM SalesLT.CategoryQtyYear
PIVOT 
(
  SUM(Qty) FOR OrderYear IN 
  ([2023], [2024], [2025])
) AS pvt;


DECLARE @columns AS nvarchar(max);

WITH UniekeCategorieen AS
(
    SELECT DISTINCT QUOTENAME(Category) AS CategorieNaam
    FROM SalesLT.CategoryQtyYear
)
--SELECT @columns = CONCAT_WS(N', ', @columns, CategorieNaam)
SELECT @columns = STRING_AGG(CategorieNaam, N', ')
FROM UniekeCategorieen


DECLARE @sql AS nvarchar(max) =
N'
SELECT 
    *
FROM SalesLT.CategoryQtyYear
PIVOT 
(
  SUM(Qty) FOR Category IN 
  (' + @columns + ')
) AS pvt
WHERE OrderYear = @OrderYear;
';

-- EXEC(@sql);

DECLARE @MijnJaar AS int = 2024;  -- untrusted input

--EXEC sp_executesql @sql;

EXEC sp_executesql 
    @sql,
    N'@OrderYear AS int',       -- parameter definitie (typering)
    @MijnJaar