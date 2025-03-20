/*
	Query para verificar se o 2.6.5 A - "List by Product the "sales history" purchased by city" está correto.
*/
SELECT 
	COUNT(*) AS TotalQuantity,
	SUM(OP.ProductStandardCost * OP.OrderQuantity) AS TotalAmount
FROM 
	Orders.OrderedProducts OP
JOIN 
	Orders.Sale S 
ON 
	OP.SaleKey = S.SaleKey
JOIN 
	Users.Customer C 
ON 
	S.CustomerKey = C.CustomerKey
JOIN 
	Users.DeliveryAddress DA 
ON 
	DA.DeliveryAddressKey = C.DeliveryAddressKey
WHERE 
	ProductKey = 214 
	AND 
	DA.City LIKE 'Geelong'

