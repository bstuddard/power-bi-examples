let
    // Initial source
    Source = Sql.Databases("localhost"),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    Fact_Sale = WideWorldImportersDW{[Schema="Fact",Item="Sale"]}[Data],
    bill_to_customer = Table.ExpandRecordColumn(Fact_Sale, "Dimension.Customer(Bill To Customer Key)", 
        {"Bill To Customer"}, {"Bill To Customer"}),

    // Sort
    sort_col = Table.AddColumn(bill_to_customer, "SortCol", each
        if [Bill To Customer] = "N/A" then 1 else 0,
        type number),
    sorted = Table.Sort(sort_col, {{"SortCol", Order.Ascending}, {"Bill To Customer", Order.Ascending}}),

    // Final Cols
    selectec_cols = Table.SelectColumns(sorted, {"Sale Key", "Salesperson Key", "Description", "Bill To Customer"})
    
in
    selectec_cols