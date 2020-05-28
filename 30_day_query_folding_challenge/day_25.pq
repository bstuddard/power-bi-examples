let
    // Initial Source
    Source = Sql.Databases("localhost"),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    Dimension_Supplier = WideWorldImportersDW{[Schema="Dimension",Item="Supplier"]}[Data],

    // Add computed column
    sup_ref = Table.AddColumn(Dimension_Supplier, "Supplier Key Reference", each
        Text.From([Supplier Key]) & "-" &
        [Supplier Reference] &
        [Supplier] &
        [Category] &
        [Primary Contact],
        type text),

    // Filtering
    expanded = Table.ExpandTableColumn(sup_ref, "Fact.Transaction", {"Is Finalized"}, {"Is Finalized"}),
    filtered_rows = Table.SelectRows(expanded, each
        [Supplier] <> "Unknown"
    and [Is Finalized] = false),

    // Final Cols
    cols = Table.SelectColumns(filtered_rows, {"Supplier Key Reference"})

in
    cols