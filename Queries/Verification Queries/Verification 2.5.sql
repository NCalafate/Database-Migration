USE AdventureWorks;
GO

/*
	Verificações dos níveis de isolação.
	Precisam de ser executados em separado.
*/

/*
	Teste 1: sp_AddProductToSale
	Verificar se a procedure adiciona um produto à venda.
*/
EXEC sp_AddProductToSale 52, 212, 20, 10, 'SO51282', 6;

-- Verificar se o produto foi adicionado à tabela.
SELECT * FROM Orders.OrderedProducts WHERE SaleKey = 52 AND ProductKey = 212;

/*
	Teste 2: sp_UpdateProductPrice
	Verificar se a procedure atualiza o preço do produto.
*/
EXEC sp_UpdateProductPrice 210, 499.99;

-- Verificar se o preço do produto foi atualizado na tabela.
SELECT * FROM Products.Product WHERE ProductKey = 210;

/*
	Teste 3: sp_UpdateCustomerAccount
	Verificar se a procedure atualiza as informações da conta do cliente.
*/
EXEC sp_AddAccount 1, 'Gigantium', 2, 11000;
EXEC sp_UpdateCustomerAccount 11000, 'bommail@example.com', 'Elefantium', 1;

-- Verificar se as informações da conta do cliente foram atualizadas nas tabelas.
SELECT * FROM Users.Customer WHERE CustomerKey = 11000;
SELECT * FROM Users.CustomerAccount WHERE CustomerKey = 11000;

/*
	Teste 4: sp_UpdateProductStock
	Verificar se a procedure atualiza o nível de stock do produto corretamente.
*/
EXEC sp_UpdateProductStock 210, 999;

-- Verificar se o nível de stock do produto foi atualizado na tabela.
SELECT * FROM Products.Product WHERE ProductKey = 210;
