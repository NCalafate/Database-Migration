/*
Index on Color column in Products.ProductModel table
*/
CREATE INDEX idx_Color ON Products.ProductModel(Color);

SELECT
    PM.Color,
    COUNT(P.ProductKey) AS NumberOfProducts
FROM
    Products.Product P
    JOIN Products.ProductModel PM ON P.ModelKey = PM.ModelKey
GROUP BY
    PM.Color;
