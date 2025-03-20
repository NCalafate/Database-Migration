/*
Index on OrderDate column in Orders.Sale table
*/

CREATE INDEX idx_OrderDate ON Orders.Sale(OrderDate);

/*
Index on CategoryKey column in Products.Product table
*/
CREATE INDEX idx_CategoryKey ON Products.Product(CategoryKey);

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
