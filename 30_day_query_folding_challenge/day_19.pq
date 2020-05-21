let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    AdventureWorksDW2017 = Source{[Name="AdventureWorksDW2017"]}[Data],
    dbo_FactResellerSales = AdventureWorksDW2017{[Schema="dbo",Item="FactResellerSales"]}[Data],

    // Unix epoch
    unix_epoch = #datetime(1970, 1, 1, 0, 0, 0),

    // Duration to get unix timestamp
    unix_col = Table.AddColumn(dbo_FactResellerSales, "UnixTimestamp", each 
        Duration.TotalSeconds([OrderDate] - unix_epoch)),

    // Final columns
    final_cols = Table.SelectColumns(unix_col, {"SalesOrderNumber", "OrderDate", "ResellerKey", "EmployeeKey", "UnixTimestamp"})
in
    final_cols