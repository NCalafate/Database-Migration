use "AdventureWorksWeb";

// List by Product the total amount per month/year and the monthly average.
db.Sales.aggregate([
    {
        $match: {
            Products: { $exists: true, $ne: [] }
        }
    },
    {
        $unwind: "$Products"
    },
    {
        
        $group: {
            _id: {
                Year: { $year: { $dateFromString: { dateString: "$Date" } } },
                Month: { $month: { $dateFromString: { dateString: "$Date" } } },
                ProductKey: "$Products.Key"
            },
            TotalAmount: { $sum: "$Products.Cost" },
            TotalQuantity: { $sum: "$Products.Quantity" }
        }
    },
    {
        $project: {
            _id: 0,
            Year: "$_id.Year",
            Month: "$_id.Month",
            ProductKey: "$_id.ProductKey",
            TotalAmount: 1,
            TotalQuantity: 1,
            MonthlyAverage: { $cond: { if: { $ne: ["$TotalQuantity", 0] }, then: { $divide: ["$TotalAmount", "$TotalQuantity"] }, else: 0 } }
        }
    },
    {
        $sort: {
            Month: 1,
            ProductKey: 1,
            Year: 1
        }
    }
])