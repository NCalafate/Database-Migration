/*
Index on City column in Users.DeliveryAddress table
*/
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_City' AND object_id = OBJECT_ID('Users.DeliveryAddress'))
    DROP INDEX idx_City ON Users.DeliveryAddress;

CREATE INDEX idx_City ON Users.DeliveryAddress(City);

/*
Index on OrderDate column in Orders.Sale table
*/
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_OrderDate' AND object_id = OBJECT_ID('Orders.Sale'))
    DROP INDEX idx_OrderDate ON Orders.Sale;

CREATE INDEX idx_OrderDate ON Orders.Sale(OrderDate);

/*
Index on Color column in Products.ProductModel table
*/
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_Color' AND object_id = OBJECT_ID('Products.ProductModel'))
    DROP INDEX idx_Color ON Products.ProductModel;

CREATE INDEX idx_Color ON Products.ProductModel(Color);

/*
Index on CategoryKey column in Products.Product table
*/
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_CategoryKey' AND object_id = OBJECT_ID('Products.Product'))
    DROP INDEX idx_CategoryKey ON Products.Product;

CREATE INDEX idx_CategoryKey ON Products.Product(CategoryKey);


/*
Query city 
*/

SELECT
    DA.City,
    DA.StateProvinceCode,
    ST.SalesTerritoryRegion,
    SUM(OP.SalesAmount) AS TotalSales
FROM
    Users.DeliveryAddress DA
    JOIN Defaults.SaleTerritory ST ON DA.SaleTerritoryKey = ST.SaleTerritoryKey
    JOIN Orders.Sale S ON ST.SaleTerritoryKey = S.SaleTerritoryKey
    JOIN Orders.OrderedProducts OP ON S.SaleKey = OP.SaleKey
GROUP BY
    DA.City, DA.StateProvinceCode, ST.SalesTerritoryRegion;

/*
Query growth rate
*/


SELECT
    YEAR(S1.OrderDate) AS Year,
    PC.EnglishName AS Category,
    SUM(OP1.SalesAmount) AS TotalSales,
    (SUM(OP1.SalesAmount) - LAG(SUM(OP1.SalesAmount), 1, 0) OVER (PARTITION BY PC.CategoryKey ORDER BY YEAR(S1.OrderDate))) / 
        NULLIF(LAG(SUM(OP1.SalesAmount), 1, 1) OVER (PARTITION BY PC.CategoryKey ORDER BY YEAR(S1.OrderDate)), 0) AS GrowthRate
FROM
    Orders.Sale S1
    JOIN Orders.OrderedProducts OP1 ON S1.SaleKey = OP1.SaleKey
    JOIN Products.Product P ON OP1.ProductKey = P.ProductKey
    JOIN Products.ProductCategory PC ON P.CategoryKey = PC.CategoryKey
GROUP BY
    YEAR(S1.OrderDate), PC.EnglishName, PC.CategoryKey;

/*
Query color
*/

SELECT
    PM.Color,
    COUNT(P.ProductKey) AS NumberOfProducts
FROM
    Products.Product P
    JOIN Products.ProductModel PM ON P.ModelKey = PM.ModelKey
GROUP BY
    PM.Color;
