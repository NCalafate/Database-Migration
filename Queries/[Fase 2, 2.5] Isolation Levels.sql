USE AdventureWorks
GO

/*
	Procedure para adicionar um produto à venda.
	Nível de isolamento da transação de READ COMMITED.
*/
DROP PROCEDURE IF EXISTS sp_AddProductToSale
GO
CREATE PROCEDURE sp_AddProductToSale
    @SaleKey			INT,
    @ProductKey			INT,
	@UnitPriceDiscount	FLOAT,
    @OrderQuantity		TINYINT,
	@OrderNumber        VARCHAR(32),
    @CurrencyKey		INT
AS
	BEGIN TRY 
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
		BEGIN TRANSACTION;
		IF NOT EXISTS (SELECT 1 FROM Products.Product WHERE ProductKey = @ProductKey)
		BEGIN
			RAISERROR ('[Add Product to Sale] O produto especificado não existe.', 18, 1);
			RETURN;
		END
		DECLARE @ProductStandardCost	FLOAT;
		DECLARE @SalesAmount			FLOAT;
		DECLARE @ExtendedAmount			FLOAT;
		DECLARE @UnitPrice				FLOAT;
		DECLARE @Freight				FLOAT;
		DECLARE @Tax					FLOAT;
		SELECT
			@ProductStandardCost = P.Cost,
			@SalesAmount = P.DealerPrice * @OrderQuantity,
			@ExtendedAmount = P.DealerPrice * @OrderQuantity,
			@UnitPrice = P.ListPrice,
			@Freight = P.Cost * 0.20,
			@Tax = P.Cost * 0.10
		FROM
			Products.Product P
		WHERE
			p.ProductKey = @ProductKey;
		INSERT INTO Orders.OrderedProducts 
		(
			SaleKey, 
			ProductKey, 
			OrderQuantity,
			OrderNumber,
			ProductStandardCost, 
			SalesAmount, 
			ExtendedAmount, 
			UnitPrice, 
			UnitPriceDiscount, 
			Freight, 
			Tax, 
			CurrencyKey
		)
		VALUES 
		(
			@SaleKey, 
			@ProductKey, 
			@OrderQuantity, 
			@OrderNumber,
			@ProductStandardCost, 
			@SalesAmount, 
			@ExtendedAmount, 
			@UnitPrice, 
			@UnitPriceDiscount,
			@Freight, 
			@Tax, 
			@CurrencyKey
		);
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		EXEC sp_ErrorHandling
		RAISERROR ('Ocorreu um erro ao criar/executar a PROCEDURE [ sp_AddProductToSale ].', 18, 1);
	END CATCH
GO

/*
	Procedure para atualizar o preço de um produto sem afetar as vendas.
	Nível de isolamento da transação de REPEATABLE READ.
*/
DROP PROCEDURE IF EXISTS sp_UpdateProductPrice
GO
CREATE PROCEDURE sp_UpdateProductPrice
    @ProductKey INT,
    @NewPrice	MONEY
AS
	BEGIN TRY 
		SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
		BEGIN TRANSACTION;
		IF NOT EXISTS (SELECT 1 FROM Products.Product WHERE ProductKey = @ProductKey)
		BEGIN
			RAISERROR ('[Update Product Price] O produto especificado não existe.', 18, 1);
			RETURN;
		END
		UPDATE 
			Products.Product
		SET 
			ListPrice = @NewPrice
		WHERE 
			ProductKey = @ProductKey;
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		EXEC sp_ErrorHandling;
		RAISERROR ('Ocorreu um erro ao criar/executar a PROCEDURE [ sp_UpdateProductPrice ].', 18, 1);
	END CATCH
GO

/*
	Procedure para calcular o total de vendas no ano corrente.
	Nível de isolamento da transação de SERIALIZABLE.
*/
DROP PROCEDURE IF EXISTS sp_CalculateCurrentYearSales
GO
CREATE PROCEDURE sp_CalculateCurrentYearSales
	 @TotalSales MONEY OUTPUT
AS
	BEGIN TRY 
		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
		BEGIN TRANSACTION;
		SELECT 
			@TotalSales = SUM(OP.ProductStandardCost)
		FROM 
			Orders.OrderedProducts OP
		INNER JOIN 
			Orders.Sale S 
		ON 
			OP.SaleKey = S.SaleKey
		WHERE 
			YEAR(S.OrderDate) = YEAR(GETDATE());
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		EXEC sp_ErrorHandling;
		RAISERROR ('Ocorreu um erro ao criar/executar a PROCEDURE [ sp_CalculateCurrentYearSales ].', 18, 1);
	END CATCH
GO

/*
	Procedure para atualizar a conta de um cliente.
	Nível de isolamento da transação de REPEATABLE READ.
*/
DROP PROCEDURE IF EXISTS sp_UpdateCustomerAccount
GO
CREATE PROCEDURE sp_UpdateCustomerAccount
    @CustomerKey			INT,
    @NewEmailAddress		NVARCHAR(128),
    @NewAuthAnswer			NVARCHAR(128),
    @QuestionKey			INT
AS
	BEGIN TRY 
		SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
		BEGIN TRANSACTION;
		UPDATE 
			Users.Customer
		SET 
			EmailAddress = @NewEmailAddress
		WHERE 
			CustomerKey = @CustomerKey;
		UPDATE 
			Users.CustomerAccount
		SET 
			HashedAnswer = @NewAuthAnswer,
			QuestionKey = @QuestionKey
		WHERE 
			CustomerKey = @CustomerKey;
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		EXEC sp_ErrorHandling;
		RAISERROR ('Ocorreu um erro ao criar/executar a PROCEDURE [ sp_UpdateCustomerAccount ].', 18, 1);
	END CATCH
GO

/*
	Procedure para atualizar o nível de stock de um produto.
	Nível de isolamento da transação de SERIALIZABLE.
*/
DROP PROCEDURE IF EXISTS sp_UpdateProductStock
GO
CREATE PROCEDURE sp_UpdateProductStock
    @ProductKey INT,
    @NewStockLevel INT
AS
	BEGIN TRY 
		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
		BEGIN TRANSACTION;
		UPDATE 
			Products.Product
		SET 
			SafetyStockLevel = @NewStockLevel
		WHERE 
			ProductKey = @ProductKey;
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		EXEC sp_ErrorHandling;
		RAISERROR ('Ocorreu um erro ao criar/executar a PROCEDURE [ sp_UpdateProductStock ].', 18, 1);
	END CATCH
GO