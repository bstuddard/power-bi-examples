let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    dim_stock_item = WideWorldImportersDW{[Schema="Dimension",Item="Stock Item"]}[Data],

    // Schema
    schema_table = Table.Schema(dim_stock_item),

    // List of column names
    cols = Table.Column(Table.SelectRows(schema_table, each [TypeName] = "Text.Type"), "Name"),

    // Select valid columns
    selection = Table.SelectColumns(dim_stock_item, cols)

in
    selection