use "AdventureWorksWeb";

// List by Product the "sales history" purchased by city.
db.Sales.aggregate([
    {
        $unwind: "$Products"
    },
    {
        $group: {
            _id: {
                ProductKey: "$Products.Key",
                City: "$City"
            },
            TotalQuantity: { $sum: "$Products.Quantity" },
            TotalCost: { $sum: "$Products.Cost" }
        }
    },
    {
        $project: {
            _id: 0,
            ProductKey: "$_id.ProductKey",
            City: "$_id.City",
            TotalQuantity: 1,
            TotalCost: 1
        }
    },
    {
        $sort: {
            ProductKey: 1
        }
    }
])