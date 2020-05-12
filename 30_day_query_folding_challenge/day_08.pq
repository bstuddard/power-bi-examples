let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    Fact_Sale = WideWorldImportersDW{[Schema="Fact",Item="Sale"]}[Data],

    // Find Start and End Date
    min_date = List.Min(Table.Column(Fact_Sale, "Invoice Date Key")),
    max_date = List.Max(Table.Column(Fact_Sale, "Invoice Date Key")),

    // Generate and filter dates to month end
    date_ct = Duration.TotalDays(max_date - min_date),
    all_dates = List.Dates(min_date, date_ct + 1, #duration(1, 0, 0, 0)),
    month_end_dates = List.Select(all_dates, each _ = Date.EndOfMonth(_)),

    // Filter to list of dates
    filtered_result = Table.SelectRows(Fact_Sale, each List.Contains(month_end_dates, [Invoice Date Key])),

    // Select only necessary columns
    final_result = Table.SelectColumns(filtered_result, {"Sale Key", "Customer Key", "Invoice Date Key",
                                                         "Total Excluding Tax", "Tax Amount", "Profit"})
    
in
    final_result