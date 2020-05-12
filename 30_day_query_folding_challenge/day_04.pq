let
    // Initial connection
    Source = Sql.Database("localhost", "WideWorldImportersDW", [CreateNavigationProperties=false]),
    Fact_Order = Source{[Schema="Fact",Item="Order"]}[Data],

    // Filter records, Mod of Len(Description) / 10 is equal to 1
    filtered_records = Table.SelectRows(Fact_Order, each Number.Mod(Text.Length([Description]), 10) = 1),

    // Select only necessary columns
    selected_columns = Table.SelectColumns(filtered_records, {"Order Key", "Description"})

in
    selected_columns