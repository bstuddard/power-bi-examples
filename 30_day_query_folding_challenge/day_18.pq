let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    Dimension_City = WideWorldImportersDW{[Schema="Dimension",Item="City"]}[Data],

    // Find applicable cities
    values = List.Distinct(Table.Column(Dimension_City, "City")),
    filtered_values = List.Select(values, each 
            Text.Contains(_, "A", Comparer.Ordinal) 
        and Text.Contains(_, "d", Comparer.Ordinal) 
        and Text.Contains(_, "C", Comparer.Ordinal)),

    // Filter down cities
    filtered_results = Table.SelectRows(Dimension_City, each List.Contains(filtered_values, [City]))
    
in
    filtered_results