let
    // Initial Connections
    Source = Sql.Database("localhost", "AdventureWorksDW2017", [CreateNavigationProperties=false]),
    dbo_DimProduct = Source{[Schema="dbo",Item="DimProduct"]}[Data],
    dbo_FactResellerSales = Source{[Schema="dbo",Item="FactResellerSales"]}[Data],

    // Add revenue custom calculation (OrderQuantity * UnitPrice)
    revenue_custom = Table.AddColumn(dbo_FactResellerSales, "TotalUnitPrice", each [OrderQuantity] * [UnitPrice], type number),

    // Join Tables on ProductKey
    joined_table = Table.NestedJoin(dbo_DimProduct, "ProductKey", revenue_custom, "ProductKey", "SalesFact", JoinKind.Inner),
    expanded_sales = Table.ExpandTableColumn(joined_table, "SalesFact", {"TotalUnitPrice"}),    
    
    // Aggregate new column by ProductKey and EnglishProductName
    aggregate_revenue = Table.Group(expanded_sales, {"ProductKey", "EnglishProductName"}, {{"TotalRevenue", 
                                        each List.Sum([TotalUnitPrice]), type number}}),

    // Filter to 1m or greater
    filtered_table = Table.SelectRows(aggregate_revenue, each [TotalRevenue] > 1000000)
    
in
    filtered_table


    