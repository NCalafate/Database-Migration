use "AdventureWorksWeb";

// List by Model, the products and quantities purchased.
db.Sales.aggregate([
    {
        $unwind: "$Products"
    },
    {
        $lookup: {
            from: "Products",
            localField: "Products.Key",
            foreignField: "Key",
            as: "ProductInfo"
        }
    },
    {
        $unwind: "$ProductInfo"
    },
    {
        $group: {
            _id: {
                ModelName: "$ProductInfo.Model.Name",
                ProductKey: "$Products.Key"
            },
            TotalQuantity: { $sum: "$Products.Quantity" },
        }
    },
    {
        $group: {
            _id: "$_id.ModelName",
            Products: {
                $addToSet: {
                    ProductKey: "$_id.ProductKey",
                    TotalQuantity: "$TotalQuantity",
                }
            }
        }
    },
    {
        $project: {
            _id: 0,
            ModelName: "$_id",
            Products: 1
        }
    },
    {
        $sort: {
            ModelName: 1
        }  
    }
])