let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    Dimension_City = WideWorldImportersDW{[Schema="Dimension",Item="City"]}[Data],

    // Filter characters
    values = Table.Column(Dimension_City, "City"),
    filtered_values = List.Select(values, each Text.Contains(_, "A") and Text.Contains(_, "d") and Text.Contains(_, "C")),
    filtered_results = Table.SelectRows(Dimension_City, each List.Contains(filtered_values, [City])),

    // Final columns
    columns = Table.SelectColumns(filtered_results, {"City Key", "City", "State Province", "Sales Territory"})
in
    columns