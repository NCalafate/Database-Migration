/*
	Exporta os dados dos produtos para um ficheiro JSON.
*/
USE AdventureWorks
GO

SELECT 
	P.ProductKey			AS [Key],
	P.CurrStatus			AS [Status],
	P.EnglishName			AS [Description.EnglishName],
	P.EnglishDescription	AS [Description.EnglishDescription],
	P.FrenchName			AS [Description.FrenchName],
	P.FrenchDescription		AS [Description.FrenchDescription],
	P.SpanishName			AS [Description.SpanishName],
	P.SpanishDescription	AS [Description.SpanishDescription],
	P.ListPrice				AS [Cost.ListPrice],
	P.Cost					AS [Cost.Cost],
	PM.ModelName            AS [Model.Name],
	PM.Color                AS [Model.Color],
	PM.Style                AS [Model.Style],
	PM.Class                AS [Model.Class],
	PM.ProductLine          AS [Model.Line]
FROM 
	Products.Product P
JOIN 
	Products.ProductModel PM
ON 
	P.ModelKey = PM.ModelKey
ORDER BY 
	P.ProductKey
FOR JSON PATH;