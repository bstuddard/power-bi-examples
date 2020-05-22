let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    Fact_Order = WideWorldImportersDW{[Schema="Fact",Item="Order"]}[Data],

    // Add category column
    category_col = Table.AddColumn(Fact_Order, "Category", each 
             if [Quantity] < 100 then "Less than 100"
        else if [Quantity] < 250 then "Between 100 and 250"
        else "More than 250",
        type text
    ),

    // Select final columns
    final_cols = Table.SelectColumns(category_col, {"Order Key", "Description", "Quantity", "Category"})
in
    final_cols