let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    Dimension_Employee = WideWorldImportersDW{[Schema="Dimension",Item="Employee"]}[Data],

    // Filter (two conditions)
    filtered_data = Table.SelectRows(Dimension_Employee, each
        (
                [Is Salesperson] = true
            and Date.Year([Valid To]) <> 9999
            and Duration.TotalDays([Valid To] - [Valid From]) > 365
        )
        or
        (
                [Is Salesperson] = false
            and Date.Year([Valid To]) = 9999
        )
    ),

    // Select only necessary columns
    selected_columns = Table.SelectColumns(filtered_data, {"Employee Key", "Employee", "Is Salesperson", "Valid From", "Valid To"})
    
in
    selected_columns