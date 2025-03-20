/*
	Exporta os dados das vendas para um ficheiro JSON.
*/
USE AdventureWorks
GO

SELECT 
	S.SaleKey				AS [Key],
	S.OrderDate				AS [Date],
	DA.City					AS [City],
	(	
		SELECT 
			OP.ProductKey			AS [Key],
			OP.OrderQuantity		AS [Quantity],
			OP.ProductStandardCost  AS [Cost]
		FROM 
			Orders.OrderedProducts OP
		WHERE 
			OP.OrderNumber LIKE S.OrderNumber
			AND
			OP.SaleKey = S.SaleKey
		FOR JSON PATH
	) AS [Products]
FROM 
	Orders.Sale S
JOIN 
	Users.Customer C
ON 
	C.CustomerKey = S.CustomerKey
JOIN 
	Users.DeliveryAddress DA
ON 
	DA.DeliveryAddressKey = C.DeliveryAddressKey
ORDER BY 
	S.OrderNumber
FOR JSON PATH;