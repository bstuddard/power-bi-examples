let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    AdventureWorksDW2017 = Source{[Name="AdventureWorksDW2017"]}[Data],
    dbo_FactInternetSales = AdventureWorksDW2017{[Schema="dbo",Item="FactInternetSales"]}[Data],
    dbo_DimCustomer = AdventureWorksDW2017{[Schema="dbo",Item="DimCustomer"]}[Data],

    // Join Tables on CustomerKey
    joined_table = Table.NestedJoin(dbo_DimCustomer, "CustomerKey", dbo_FactInternetSales, "CustomerKey", "SalesFact", JoinKind.Inner),
    expanded_sales = Table.ExpandTableColumn(joined_table, "SalesFact", {"OrderQuantity"}),

    // Aggregate grain before pivot
    aggregate_order = Table.Group(expanded_sales, 
        {"Gender", "EnglishEducation", "CommuteDistance"}, 
        {{"Totalorders", each List.Sum([OrderQuantity]), type number}}
    ),

    // Pivot so that order quantity values are summed for various commute distances
    pivoted_data = Table.Pivot(aggregate_order, 
        List.Distinct(aggregate_order[CommuteDistance]), "CommuteDistance", 
        "Totalorders", List.Sum
    ),

    // Sort column names
    column_names = Table.FromList(Table.ColumnNames(pivoted_data)),
    split_function = Splitter.SplitTextByAnyDelimiter({"-", "+"}, QuoteStyle.None),
    sort_column = Table.AddColumn(column_names, "sort_column", each
        if [Column1] = "Gender" then -2
        else if [Column1] = "EnglishEducation" then -1
        else Number.FromText(split_function([Column1]){0}),
        type number
    ),
    sorted_column_names = Table.Column(
        Table.Sort(sort_column,{{"sort_column", Order.Ascending}}),
        "Column1"
    ),

    // Reorder columns
    reordered_table = Table.ReorderColumns(pivoted_data, sorted_column_names),

    // Add Sort Column for Rows
    row_sort_order = Table.AddColumn(reordered_table, "row_sort_column", each
        (if [EnglishEducation] = "Partial High School" then 100
        else if [EnglishEducation] = "High School" then 200
        else if [EnglishEducation] = "Partial College" then 300
        else if [EnglishEducation] = "Bachelors" then 400
        else if [EnglishEducation] = "Graduate Degree" then 500
        else 0)
        +
        (if [Gender] = "F" then 1
        else 2),
        type number
    ),

    // Sort Rows
    row_sorted = Table.Sort(row_sort_order, {"row_sort_column", Order.Ascending}),
    final_result = Table.RemoveColumns(row_sorted,{"row_sort_column"})

in
    final_result