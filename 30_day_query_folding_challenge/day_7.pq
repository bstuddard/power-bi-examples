let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    AdventureWorksDW2017 = Source{[Name="AdventureWorksDW2017"]}[Data],
    dbo_DimEmployee = AdventureWorksDW2017{[Schema="dbo",Item="DimEmployee"]}[Data],

    // Find valid columns
    column_list = List.Select(Table.ColumnNames(dbo_DimEmployee), each not Text.Contains(_, "Key")),

    // Select valid columns
    final_result = Table.SelectColumns(dbo_DimEmployee, column_list)

in
    final_result