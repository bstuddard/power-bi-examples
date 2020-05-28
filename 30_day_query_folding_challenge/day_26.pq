let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    AdventureWorksDW2017 = Source{[Name="AdventureWorksDW2017"]}[Data],
    dbo_DimEmployee = AdventureWorksDW2017{[Schema="dbo",Item="DimEmployee"]}[Data],

    // Filter last name
    last_name_values = List.Distinct(Table.Column(dbo_DimEmployee, "LastName")),
    last_name_filtered = List.Select(last_name_values, each not
        List.Contains(
            {"A", "B", "C", "D", "E"},
            Text.Start(_, 1)
        )
    ),

    // Select rows and columns
    final_rows = Table.SelectRows(dbo_DimEmployee, each List.Contains(last_name_filtered, [LastName])),
    final_cols = Table.SelectColumns(final_rows, {"EmployeeKey", "FirstName", "MiddleName", "LastName"})
    
in
    final_cols