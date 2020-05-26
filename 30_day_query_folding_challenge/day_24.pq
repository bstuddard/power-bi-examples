let
    // Initial source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    dim_table = WideWorldImportersDW{[Schema="Dimension",Item="Transaction Type"]}[Data],

    // Transaction Types
    transaction_types = Table.Column(dim_table, "Transaction Type"),
    filtered_types = List.Select(transaction_types, each List.Contains({"a", "e", "i", "o", "u", "y", "w"}, Text.Middle(_, 1, 1))),

    // Filter original dim
    filtered_dim = Table.SelectRows(dim_table, each List.Contains(filtered_types, [Transaction Type])),
    selected_cols = Table.SelectColumns(filtered_dim, {"Transaction Type Key", "Transaction Type"})
in
    selected_cols