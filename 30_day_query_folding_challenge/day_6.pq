let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    dim_stock_item = WideWorldImportersDW{[Schema="Dimension",Item="Stock Item"]}[Data],

    // Filter, Stock Item Key is Even and Color is not N/A
    filtered_data = Table.SelectRows(dim_stock_item, each
            Number.Mod([Stock Item Key], 2) = 0
        and [Color] <> "N/A"
    ),

    // Select only necessary columns
    final_columns = Table.SelectColumns(filtered_data, {"Stock Item Key", "Stock Item", "Color"})
    
in
    final_columns