/*
	Este ficheiro é responsável pela migração dos dados da base de dados antiga "AdventureWorksOld" para a nova.
	É o quarto a ser executado.
*/

USE AdventureWorks;
GO

/*
	Migramos as distâncias dos clientes para uma tabela dedicada.
*/
BEGIN TRY
	PRINT '[Migração] Migração das distâncias dos clientes a ocorrer.'
	INSERT INTO Defaults.Commute
	(
		CommuteRange
	)
	SELECT
        CommuteDistance
	FROM AdventureWorksOld.dbo.Customer
	GROUP BY CommuteDistance
	ORDER BY CASE
		WHEN CommuteDistance = '0-1 Miles' THEN 1
		WHEN CommuteDistance = '1-2 Miles' THEN 2
		WHEN CommuteDistance = '2-5 Miles' THEN 3
		WHEN CommuteDistance = '5-10 Miles' THEN 4
		ELSE 5
	END;
END TRY  
BEGIN CATCH 
    PRINT '[ERRO] Migração das distâncias dos clientes falhou.'
	EXEC sp_ErrorHandling
END CATCH

/*
	Migramos os territórios de venda.
*/
BEGIN TRY
	PRINT '[Migração] Migração dos territórios de vendas a ocorrer.'
	INSERT INTO Defaults.SaleTerritory
		(
			SalesTerritoryRegion,
			SalesTerritoryCountry,
			SalesTerritoryGroup
		)
	SELECT DISTINCT
        SalesTerritoryRegion,
        SalesTerritoryCountry,
        SalesTerritoryGroup
	FROM AdventureWorksOld.dbo.SalesTerritory;
END TRY  
BEGIN CATCH  
    PRINT '[ERRO] Migração dos territórios de vendas falhou.'
	EXEC sp_ErrorHandling
END CATCH

/*
	Migramos os tipos de moeda.
*/
BEGIN TRY
	PRINT '[Migração] Migração dos tipos de moeda a ocorrer.'
	INSERT INTO Defaults.Currency 
	(
		CurrencyName,
		CurrencyCode
	)
	SELECT DISTINCT 
		CurrencyName,
		CurrencyAlternateKey
	FROM AdventureWorksOld.dbo.Currency;
END TRY  
BEGIN CATCH  
    PRINT '[ERRO] Migração dos tipos de moeda falhou.'
	EXEC sp_ErrorHandling
END CATCH

/*
	 Migramos os endereços de entrega dos clientes para uma tabela dedicada.
*/
BEGIN TRY 
	PRINT '[Migração] Migração dos endereços de entrega a ocorrer.'
	INSERT INTO Users.DeliveryAddress
	(
		DeliveryAddressKey,
		AddressLine1,
		AddressLine2,
		City,
		PostalCode,
		StateProvinceCode,
		StateProvinceName,
		CountryRegionCode, 
		CountryRegionName,
		CommuteRangeKey,
		SaleTerritoryKey
	)
	SELECT DISTINCT
		CustomerKey,
		AddressLine1,
		AddressLine2,
		City,
		PostalCode,
		StateProvinceCode,
		StateProvinceName,
		CountryRegionCode,
		CountryRegionName,
		B.CommuteRangeKey,
		SalesTerritoryKey
	FROM AdventureWorksOld.dbo.Customer as A
	JOIN Defaults.Commute as B
		ON A.CommuteDistance = B.CommuteRange
END TRY  
BEGIN CATCH  
    PRINT '[ERRO] Migração dos endereços de entrega falhou.'
	EXEC sp_ErrorHandling
END CATCH

/*
	Migração das educações dos clientes para uma tabela dedicada.
*/
BEGIN TRY  
	PRINT '[Migração] Migração das educações a ocorrer.'
	INSERT INTO Defaults.Education
	SELECT DISTINCT
		CustomerSelection.Education
	FROM AdventureWorksOld.dbo.Customer CustomerSelection;
END TRY  
BEGIN CATCH  
    PRINT '[ERRO] Migração das educações falhou.'
	EXEC sp_ErrorHandling
END CATCH

/*
	Migramos as ocupações dos clientes para uma tabela dedicada.
*/
BEGIN TRY
	PRINT '[Migração] Migração das ocupações a ocorrer.'
	INSERT INTO Defaults.Occupation
	SELECT DISTINCT 
		CustomerSelection.Occupation
	FROM AdventureWorksOld.dbo.Customer CustomerSelection;
END TRY  
BEGIN CATCH  
    PRINT '[ERRO] Migração das ocupações falhou.'
	EXEC sp_ErrorHandling
END CATCH

/*
	Migramos as categorias dos produtos para uma tabela dedicada.
*/
BEGIN TRY  
	PRINT '[Migração] Migração das categorias primárias dos produtos a ocorrer.'
	INSERT INTO Products.ProductCategory 
	(
		ParentCategory,
		EnglishName,
		SpanishName,
		FrenchName
	) 
	SELECT DISTINCT
		NULL,
		EnglishProductCategoryName,
		SpanishProductCategoryName,
		FrenchProductCategoryName
	FROM AdventureWorksOld.dbo.Products;
END TRY  
BEGIN CATCH  
    PRINT '[ERRO] Migração das categorias primárias dos produtos falhou.'
	EXEC sp_ErrorHandling
END CATCH

/*
	Migramos as subcategorias dos produtos.
*/
BEGIN TRY  
	PRINT '[Migração] Migração das subcategorias dos produtos a ocorrer.'
	INSERT INTO Products.ProductCategory 
	(
		ParentCategory,
		EnglishName,
		SpanishName,
		FrenchName
	) 
	SELECT DISTINCT
		C.CategoryKey,
		EnglishProductSubcategoryName,
		SpanishProductSubcategoryName,
		FrenchProductSubcategoryName
	FROM AdventureWorksOld.dbo.ProductSubCategory AS A
	JOIN AdventureWorksOld.dbo.Products AS B
		ON A.ProductSubcategoryKey = B.ProductSubcategoryKey
	JOIN AdventureWorks.Products.ProductCategory AS C
		ON C.EnglishName = B.EnglishProductCategoryName
END TRY  
BEGIN CATCH  
    PRINT '[ERRO] Migração das subcategorias dos produtos falhou.'
	EXEC sp_ErrorHandling
END CATCH

/*
	Migramos os modelos dos produtos para uma tabela dedicada.
*/
BEGIN TRY 
	PRINT '[Migração] Migração dos modelos dos produtos a ocorrer.'
	INSERT INTO Products.ProductModel 
	(
		ModelName,
		Color,     
		Style,      
		ProductLine, 
		Class
	) 
	SELECT DISTINCT
		ModelName,
		Color,
		Style,
		ProductLine,
		Class
	FROM AdventureWorksOld.dbo.Products;
END TRY  
BEGIN CATCH  
    PRINT '[ERRO] Migração dos modelos dos produtos falhou.'
	EXEC sp_ErrorHandling
END CATCH

/*
	Migramos os tamanhos dos produtos para uma tabela dedicada.
*/
BEGIN TRY 
	PRINT '[Migração] Migração dos tamanhos dos produtos a ocorrer.'
	INSERT INTO Products.ProductSize 
	(
		SizeCode,
		ActualSize,
		SizeRange    
	) 
	SELECT
		SizeUnitMeasureCode,
		Size,
		SizeRange
	FROM AdventureWorksOld.dbo.Products
	GROUP BY 
		Size,
		SizeRange,
		SizeUnitMeasureCode
	ORDER BY CASE
		WHEN Size = 'S' THEN 1
		WHEN Size = 'M' THEN 2
		WHEN Size = 'L' THEN 3
		WHEN Size = 'XL' THEN 4
		ELSE 5
	END;
END TRY  
BEGIN CATCH  
    PRINT '[ERRO] Migração dos tamanhos dos produtos falhou.'
	EXEC sp_ErrorHandling
END CATCH

/*
	Migramos os clientes e os seus dados específicos.
*/
BEGIN TRY
	PRINT '[Migração] Migração dos clientes a ocorrer.'
	INSERT INTO Users.Customer 
	(
		CustomerKey,
		Title,
		FirstName,
		MiddleName,
		LastName,
		BirthDate,          
		MaritalStatus,       
		Gender,             
		EmailAddress,         
		YearlyIncome,       
		TotalChildren,     
		NumberChildrenAtHome, 
		HomeOwnerFlag,       
		NumberCarsOwned,     
		Phone,                  
		FirstPurchase,
		OccupationKey,
		EducationKey,
		DeliveryAddressKey
		
	) 
	SELECT DISTINCT
		CustomerKey,
		Title,
		FirstName,
		MiddleName,
		LastName,
		BirthDate,          
		MaritalStatus,       
		Gender,             
		EmailAddress,         
		YearlyIncome,       
		TotalChildren,     
		NumberChildrenAtHome, 
		HouseOwnerFlag,       
		NumberCarsOwned,     
		Phone,            
		DateFirstPurchase,
		B.OccupationKey,
		C.EducationKey,
		D.DeliveryAddressKey
		
	FROM AdventureWorksOld.dbo.Customer as A
	JOIN Defaults.Occupation as B
		ON A.Occupation = B.Occupation
	JOIN Defaults.Education as C 
		ON A.Education = C.Education
	JOIN Users.DeliveryAddress as D
		ON A.CustomerKey = D.DeliveryAddressKey
END TRY  
BEGIN CATCH 
    PRINT '[ERRO] Migração dos clientes falhou.'
	EXEC sp_ErrorHandling
END CATCH

/*
	Migramos os produtos.
*/
BEGIN TRY
		DECLARE @DefaultSizeKey INT;
		SELECT @DefaultSizeKey = SizeKey FROM Products.ProductSize WHERE SizeCode = 'NA';

	PRINT '[Migração] Migração dos produtos a ocorrer.'

	INSERT INTO Products.Product
	(
		ProductKey,
		CurrStatus,
		EnglishName,
		EnglishDescription,
		FrenchName,
		FrenchDescription,  
		SpanishName,    
		SpanishDescription,
		ListPrice,     
		Cost,         
		FinishedFlag,      
		SafetyStockLevel,
		ManufacturingTime,
		ActualWeight,
		WeightCode,
		DealerPrice,
		ModelKey,
		CategoryKey,
		SizeKey
	)
	SELECT DISTINCT
		ProductKey,
		[Status],
        EnglishProductName,
		EnglishDescription,
		FrenchProductName,
		FrenchDescription,
		SpanishProductName,
		NULL,
		ListPrice,
		StandardCost,
		FinishedGoodsFlag,
		SafetyStockLevel,
		DaysToManufacture,
		[Weight],
		WeightUnitMeasureCode,
		DealerPrice,
		B.ModelKey,
		C.CategoryKey,
		ISNULL(D.SizeKey, @DefaultSizeKey)
	FROM AdventureWorksOld.dbo.Products AS A
	
	LEFT JOIN AdventureWorks.Products.ProductModel AS B
		ON A.ModelName = B.ModelName
			AND A.Color = B.Color
	LEFT JOIN AdventureWorks.Products.ProductCategory AS C
		ON C.CategoryKey = A.ProductSubcategoryKey

	LEFT JOIN AdventureWorks.Products.ProductSize AS D
		 ON A.SizeUnitMeasureCode = D.SizeCode 
		 AND A.Size = D.ActualSize
       

END TRY  
BEGIN CATCH  
    PRINT '[ERRO] Migração dos produtos falhou.'
	EXEC sp_ErrorHandling
END CATCH

/*
	Migramos as vendas.
*/
BEGIN TRY
	PRINT '[Migração] Migração das vendas a ocorrer.'
	INSERT INTO Orders.Sale
	(
		OrderNumber,
		RevisionNumber,       
		CustomerPONumber,
		LineNumber,          
		CarrierTrackingNumber,    
		OrderDate,             
		DueDate,         
		ShipDate,
		CustomerKey,
		SaleTerritoryKey
	)
	SELECT DISTINCT
		SalesOrderNumber,
		RevisionNumber,
		CustomerPONumber,
		SalesOrderLineNumber,
		CarrierTrackingNumber,
		OrderDate,
		DueDate,
		ShipDate,
		CustomerKey,
		SalesTerritoryKey
	FROM AdventureWorksOld.dbo.Sales5 AS A
END TRY  
BEGIN CATCH  
    PRINT '[ERRO] Migração das vendas falhou.'
	EXEC sp_ErrorHandling
END CATCH

/*
	Migramos os produtos encomendados.
*/
BEGIN TRY
	PRINT '[Migração] Migração dos produtos encomendados a ocorrer.'
	INSERT INTO Orders.OrderedProducts
	(
		OrderNumber,        
		ProductStandardCost,
		OrderQuantity,
		SalesAmount,
		ExtendedAmount,     
		UnitPrice,          
		UnitPriceDiscount,   
		Freight,			
		Tax,                
		SaleKey,	
		ProductKey, 
		CurrencyKey 
	)
	SELECT DISTINCT
		SalesOrderNumber,
		ProductStandardCost,
		OrderQuantity,
		SalesAmount,
		ExtendedAmount,
		UnitPrice,
		UnitPriceDiscountPct,
		Freight,
		TaxAmt,
		B.SaleKey,
		A.ProductKey,
		A.CurrencyKey
	FROM AdventureWorksOld.dbo.Sales5 AS A
	JOIN AdventureWorks.Orders.Sale AS B 
		ON A.SalesOrderNumber = B.OrderNumber
END TRY  
BEGIN CATCH  
    PRINT '[ERRO] Migração dos produtos encomendados falhou.'
	EXEC sp_ErrorHandling
END CATCH