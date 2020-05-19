let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    Fact_Sale = WideWorldImportersDW{[Schema="Fact",Item="Sale"]}[Data],

    // Invoice Dateparts
    invoice_year = Table.AddColumn(Fact_Sale, "Invoice Year", each 
        Number.From(Date.Year([Invoice Date Key])),
        type number
    ),
    invoice_month = Table.AddColumn(invoice_year, "Invoice Month", each 
        Number.From(Date.Month([Invoice Date Key])),
        type text
    ),

    // This month last month
    this_month = Table.AddColumn(invoice_month, "This Month Date", each
        Text.From([Invoice Year]) &
        (if ([Invoice Month] <= 9) then "0" else "") &
        Text.From([Invoice Month]),
        type text
    ),
    // This month last month
    last_month = Table.AddColumn(this_month, "Last Month Date", each
        Text.From(if [Invoice Month] = 1 then [Invoice Year] - 1 else [Invoice Year]) &
        (if ([Invoice Month] <= 10 and [Invoice Month] > 1) then "0" else "") &
        Text.From(if [Invoice Month] = 1 then 12 else [Invoice Month] - 1),
        type text
    ),

    // Total Profit (This Month and Last Month)
    grouped = Table.Group(last_month, {"This Month Date", "Last Month Date"}, {{"Total Profit", each List.Sum([Profit]), type number}}),
    last_month_grouped = Table.SelectColumns(grouped, {"This Month Date", "Total Profit"}),
    last_month_grouped_renamed = Table.RenameColumns(last_month_grouped, 
        {{"This Month Date", "Last Month Date Join"}, {"Total Profit", "Last Month Profit"}}),
    last_month_totals = Table.Join(grouped, "Last Month Date", last_month_grouped_renamed, "Last Month Date Join", JoinKind.Inner),

    // Change %
    change_percentage = Table.AddColumn(last_month_totals, "Change Percentage", each 
        [Total Profit] / [Last Month Profit] - 1, Percentage.Type),
    selected_columns = Table.SelectColumns(change_percentage, {"This Month Date", "Total Profit", "Change Percentage"})

in
    selected_columns