/*
	Este ficheiro � respons�vel pela cria��o de Views.
	� o terceiro a ser executado.
*/

USE AdventureWorks
GO

/* 
	View para as compras de um dado cliente. 
*/
CREATE VIEW Business.CustomerPurchases 
AS
	SELECT
		C.CustomerKey,
		CONCAT(C.FirstName,' ', C.LastName) AS CustomerName,
		S.SaleKey,
		S.OrderNumber,
		S.OrderDate,
		P.EnglishName AS ProductName,
		OP.OrderQuantity*OP.UnitPrice AS TotalPrice
	FROM
		Users.Customer C
	JOIN
		Orders.Sale S ON C.CustomerKey = S.CustomerKey
	JOIN
		Orders.OrderedProducts OP ON S.SaleKey = OP.SaleKey
	JOIN
		Products.Product P ON OP.ProductKey = P.ProductKey;
GO

/*
	Total de vendas por ano ordenadas por ano.
*/
CREATE VIEW Business.TotalSalesPerYearByYear
AS 
	SELECT 
		YEAR(O.OrderDate) AS SalesYear,
		SUM(OP.SalesAmount) AS TotalSales
	FROM Orders.Sale O
		JOIN Orders.OrderedProducts OP 
			ON O.SaleKey = OP.SaleKey
	GROUP BY YEAR(O.OrderDate)
GO

/*
	Total de vendas por categoria de produto por territ�rio de vendas.
*/
CREATE VIEW Business.TotalSalesPerCategoryPerTerritory
AS 
	SELECT 
		PC.EnglishName AS SubCategoryName,
		T.SalesTerritoryCountry,
		SUM(OP.SalesAmount) AS TotalSales
	FROM Orders.OrderedProducts OP
		JOIN Orders.Sale S 
			ON OP.SaleKey = S.SaleKey
		JOIN Products.Product P 
			ON OP.ProductKey = P.ProductKey
		JOIN Products.ProductCategory PC 
			ON P.CategoryKey = PC.CategoryKey
		JOIN Defaults.SaleTerritory T 
			ON S.SaleTerritoryKey = T.SaleTerritoryKey
	GROUP BY PC.EnglishName, T.SalesTerritoryCountry;
GO

/*
	Total de vendas por categoria de produto por pa�s.
*/
CREATE VIEW Business.SalesPerCategoryPerCountry
AS
	SELECT 
		PC.EnglishName AS SubCategoryName,
		T.SalesTerritoryCountry,
		COUNT(OP.ProductKey) AS NumberOfProductsSold
	FROM Orders.OrderedProducts OP
		JOIN Orders.Sale S 
			ON OP.SaleKey = S.SaleKey
		JOIN Products.Product P 
			ON OP.ProductKey = P.ProductKey
		JOIN Products.ProductCategory PC 
			ON P.CategoryKey = PC.CategoryKey
		JOIN Defaults.SaleTerritory T 
			ON S.SaleTerritoryKey = T.SaleTerritoryKey
	GROUP BY PC.EnglishName, T.SalesTerritoryCountry;
GO

/*
	View para verificar as mudan�as mais recentes num Schema.
*/
CREATE VIEW Monitoring.LatestSchemaChangesView
AS
	WITH LatestChangeCTE AS (
		SELECT
			ChangeID,
			ExecutionTime,
			ChangeDescription,
			ROW_NUMBER() OVER (ORDER BY ExecutionTime DESC) AS RowNum
		FROM Monitoring.SchemaChanges
	)
	SELECT
		ChangeID,
		ExecutionTime,
		ChangeDescription
	FROM LatestChangeCTE
	WHERE RowNum = 1;
GO

/*
	View para o territ�rio Southeast
*/
CREATE VIEW Business.SoutheastSales AS
SELECT * FROM Orders.Sale
WHERE SaleTerritoryKey IN (
    SELECT SaleTerritoryKey FROM Defaults.SaleTerritory
    WHERE SalesTerritoryRegion = 'Southeast' );
GO