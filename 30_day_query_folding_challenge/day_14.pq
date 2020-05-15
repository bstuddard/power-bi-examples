let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    AdventureWorksDW2017 = Source{[Name="AdventureWorksDW2017"]}[Data],
    dbo_DimCustomer = AdventureWorksDW2017{[Schema="dbo",Item="DimCustomer"]}[Data],

    // Filter birth date
    filtered_rows = Table.SelectRows(
        dbo_DimCustomer,
        each not List.Contains({1,7}, Date.DayOfWeek([BirthDate]))
    ),

    // Select columns
    final_result = Table.SelectColumns(filtered_rows, {"CustomerKey", "EmailAddress", "EnglishOccupation", "YearlyIncome"})

in
    final_result