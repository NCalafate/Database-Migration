/*
	Query para verificar se o 2.6.5 C - "List by Model, the products and quantities purchased" está correto.
*/
SELECT 
	COUNT(*)
FROM 
	Products.Product P
JOIN 
	Products.ProductModel PM
ON 
	PM.ModelKey = P.ModelKey
JOIN 
	Orders.OrderedProducts OP
ON 
	P.ProductKey = OP.ProductKey
WHERE 
	PM.ModelName LIKE 'Half-Finger Gloves'