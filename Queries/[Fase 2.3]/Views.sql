
/*
	View para o territorio Southeast
*/
CREATE VIEW Business.SoutheastSales AS
SELECT * FROM Orders.Sale
WHERE SaleTerritoryKey IN (
    SELECT SaleTerritoryKey FROM Defaults.SaleTerritory
    WHERE SalesTerritoryRegion = 'Southeast' );
GO