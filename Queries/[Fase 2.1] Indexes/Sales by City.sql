/*
Index on City column in Users.DeliveryAddress table
*/

CREATE INDEX idx_City ON Users.DeliveryAddress(City);

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

