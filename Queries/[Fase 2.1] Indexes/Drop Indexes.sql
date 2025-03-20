/*
Index on City column in Users.DeliveryAddress table
*/
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_City' AND object_id = OBJECT_ID('Users.DeliveryAddress'))
    DROP INDEX idx_City ON Users.DeliveryAddress;

/*
Index on OrderDate column in Orders.Sale table
*/
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_OrderDate' AND object_id = OBJECT_ID('Orders.Sale'))
    DROP INDEX idx_OrderDate ON Orders.Sale;

/*
Index on Color column in Products.ProductModel table
*/
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_Color' AND object_id = OBJECT_ID('Products.ProductModel'))
    DROP INDEX idx_Color ON Products.ProductModel;

/*
Index on CategoryKey column in Products.Product table
*/
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_CategoryKey' AND object_id = OBJECT_ID('Products.Product'))
    DROP INDEX idx_CategoryKey ON Products.Product;
