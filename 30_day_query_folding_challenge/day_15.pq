let
    // Initial Source
    Source = Sql.Databases("localhost"),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    Dimension_City = WideWorldImportersDW{[Schema="Dimension",Item="City"]}[Data],

    // Expand City Dim to Order and Sales with Valid Dates
    expnad_order = Table.ExpandTableColumn(Dimension_City, "Fact.Order", {"Order Date Key"}, {"Fact.Order.Order Date Key"}),
    expand_sales = Table.ExpandTableColumn(expnad_order, "Fact.Sale", {"Delivery Date Key"}, {"Fact.Sale.Delivery Date Key"}),
    dates_filtered = Table.SelectRows(expand_sales, each 
            ([Fact.Order.Order Date Key] <> null) 
        and ([Fact.Sale.Delivery Date Key] <> null)
    ),

    // Calc Difference Days
    dif_days = Table.AddColumn(dates_filtered, "Duration Days", 
        each Duration.TotalDays([Fact.Sale.Delivery Date Key] - [Fact.Order.Order Date Key]),
        type number),

    // Averages and ranking
    grouped = Table.Group(dif_days, {"City Key", "City"}, {{"Average Days", each List.Average([Duration Days]), type number}}),
    cutoff = Table.Group(grouped, {}, {{"Max Value", each List.Max([Average Days]), type number}}),
    cutoff_join = Table.AddColumn(cutoff, "cutoff_join", each 1, type number),

    // Rounding and filtering
    rounded = Table.AddColumn(grouped, "Average Duration Days", each Number.Round([Average Days]), type number),
    rounded_join = Table.AddColumn(rounded, "rounded_join", each 1, type number),
    rounded_joined = Table.Join(rounded_join, "rounded_join", cutoff_join, "cutoff_join", JoinKind.Inner),
    filtered_result = Table.SelectRows(rounded_joined, each [Average Duration Days] > ([Max Value] - 10)),

    // Final Select
    orderd_final = Table.Sort(filtered_result, {"Average Duration Days", Order.Descending}),
    selected_columns = Table.SelectColumns(orderd_final, {"City Key", "City", "Average Duration Days"})
in
    selected_columns