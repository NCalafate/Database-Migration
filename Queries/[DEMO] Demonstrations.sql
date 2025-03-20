/*
	Este ficheiro é responsável pela demonstração das funcionalidades do projeto.
	É o quinto a ser executado e não deverá ser executado em conjunto.
*/

USE AdventureWorks;

-- QS4

/*
	Query 1 | Total monetário de vendas por ano
*/
SELECT 
    YEAR(O.OrderDate) AS SalesYear,
    SUM(OP.SalesAmount) AS TotalSales
FROM Orders.Sale O
	JOIN Orders.OrderedProducts OP 
		ON O.SaleKey = OP.SaleKey
GROUP BY YEAR(O.OrderDate);

/*
	Query 2 | Total monetário de vendas por Product SubCategory por Sales Territory country
*/
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

/*
	Query 3 | Total monetario de vendas por Sales Territory country
*/
SELECT 
    ST.SalesTerritoryCountry,
    SUM(OP.SalesAmount) AS TotalSales
FROM Orders.Sale S
	JOIN Orders.OrderedProducts OP 
		ON S.SaleKey = OP.SaleKey
	JOIN Defaults.SaleTerritory ST 
		ON S.SaleTerritoryKey = ST.SaleTerritoryKey
GROUP BY ST.SalesTerritoryCountry;

/*
	Query 4 | Numero de produtos vendidos por SubCategory por Sales Territory Country
*/
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

Select * from Logs.RecoveryEmail

Select * from Users.CustomerAccount

Select * from Logs.ErrorHandling

EXEC sp_AddAccount 1, 'Cão', 2, 11007;

EXEC sp_NewPassword 100, 2,'Cão'; -- msg de erro

EXEC sp_NewPassword 1, 1,'Cão';

EXEC sp_UpdateAccess 1, 'mpt'; -- msg de erro

EXEC sp_UpdateAccess 1, 'admin';

/*
	Espaço ocupado por cada registo nas respetivas tabelas.
*/
EXEC sp_CalculateRecordSize
    @SchemaName = 'Defaults',
    @TableName = 'AccessLevel';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Defaults',
    @TableName = 'Commute';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Defaults',
    @TableName = 'Currency';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Defaults',
    @TableName = 'Education';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Defaults',
    @TableName = 'Occupation';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Defaults',
    @TableName = 'Question';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Defaults',
    @TableName = 'SaleTerritory';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Logs',
    @TableName = 'Administrator';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Logs',
    @TableName = 'AdministratorEdit';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Logs',
    @TableName = 'ErrorHandling';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Logs',
    @TableName = 'RecoveryEmail';


EXEC sp_CalculateRecordSize
    @SchemaName = 'Orders',
    @TableName = 'OrderedProducts';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Orders',
    @TableName = 'Sale';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Products',
    @TableName = 'Product';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Products',
    @TableName = 'ProductCategory';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Products',
    @TableName = 'ProductModel';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Products',
    @TableName = 'ProductSize';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Users',
    @TableName = 'Customer';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Users',
    @TableName = 'CustomerAccount';

EXEC sp_CalculateRecordSize
    @SchemaName = 'Users',
    @TableName = 'DeliveryAddress';