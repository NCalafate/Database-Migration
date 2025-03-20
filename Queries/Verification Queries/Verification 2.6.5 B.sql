/*
	Query para verificar se o 2.6.5 B - "List by Product the "sales history" purchased by city" está correto.
*/
SELECT
	COUNT(*) AS TotalQuantity,
	SUM(OP.ProductStandardCost * OP.OrderQuantity) AS TotalAmount
FROM 
	Orders.OrderedProducts OP
JOIN 
	Orders.Sale S
ON 
	S.SaleKey = OP.SaleKey
WHERE 
	YEAR(S.OrderDate) = 2013 
	AND 
	OP.ProductKey = 214 
	AND 
	MONTH(S.OrderDate) = 1