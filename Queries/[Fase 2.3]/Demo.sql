
EXECUTE AS USER = 'AdminUser';
EXECUTE AS USER = 'SalesPersonUser';
EXECUTE AS USER = 'SalesTerritoryUser';

SELECT TOP 10 * FROM Orders.Sale;
SELECT TOP 10 * FROM Users.Customer;
SELECT TOP 10 * FROM Business.SoutheastSales;

INSERT INTO Defaults.Occupation (Occupation) VALUES ('Test Occupation');

DELETE FROM Defaults.Occupation WHERE Occupation = 'Test Occupation';


REVERT;


EXEC sp_AddAccount 'teste',1, 'Cão', 2, 11007;

EXEC sp_NewPassword 1, 2,'Cão', 'TESTE'; -- msg de erro

EXEC sp_NewPassword 1, 1,'Cão', 'TESTE';