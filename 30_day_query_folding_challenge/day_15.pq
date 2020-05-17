let

    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    Fact_Sale = WideWorldImportersDW{[Schema="Fact",Item="Sale"]}[Data],
    Fact_Order = WideWorldImportersDW{[Schema="Fact",Item="Order"]}[Data],
    Dimension_City = WideWorldImportersDW{[Schema="Dimension",Item="City"]}[Data],

    // Various Joins
    sale_order = Table.NestedJoin(Fact_Sale, {"Description", "Customer Key"}, Fact_Order, {"Description", "Customer Key"}, "order"),
    expanded_sale_order = Table.ExpandTableColumn(sale_order, "order", {"Order Date Key"}, {"order.Order Date Key"}),
    city = Table.NestedJoin(expanded_sale_order, "City Key", Dimension_City, "City Key", "City Table"),
    expanded_city = Table.ExpandTableColumn(city, "City Table", {"City"}, {"City Table.City"}),

    // Duration
    durations = Table.AddColumn(expanded_city, "Duration Days", 
        each Duration.TotalDays([Delivery Date Key] - [order.Order Date Key]), type number),

    // Grouped city averages
    grouped = Table.Group(durations, 
        {"City Key", "City Table.City"}, 
        {{"Avg Days", each List.Average([Duration Days]), type number}}
    ),

    // Ranking
    #"Sorted Rows" = Table.Sort(grouped,{{"Avg Days", Order.Descending}}),
    top = Table.FirstN(#"Sorted Rows", 10)
in
    top