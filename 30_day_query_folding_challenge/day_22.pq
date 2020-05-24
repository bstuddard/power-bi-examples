let

    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    AdventureWorksDW2017 = Source{[Name="AdventureWorksDW2017"]}[Data],
    dbo_FactResellerSales = AdventureWorksDW2017{[Schema="dbo",Item="FactResellerSales"]}[Data],

    // Filter to past 7 years
    current_date = Date.From(DateTime.LocalNow()),
    filtered_results = Table.SelectRows(dbo_FactResellerSales, each 
        Date.From([ShipDate]) >= Date.AddYears(current_date, -7)),

    // Select columns 
    column_typing = Table.TransformColumnTypes(filtered_results, {"ShipDate", type date}),
    select_columns = Table.SelectColumns(column_typing, {"ProductKey", "SalesOrderNumber", "ShipDate", "SalesAmount"})
    
in
    select_columns