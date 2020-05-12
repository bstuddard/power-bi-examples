let
    // Initial source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    AdventureWorksDW2017 = Source{[Name="AdventureWorksDW2017"]}[Data],
    dbo_DimGeography = AdventureWorksDW2017{[Schema="dbo",Item="DimGeography"]}[Data],

    // Customer join
    dim_customer = AdventureWorksDW2017{[Schema="dbo",Item="DimCustomer"]}[Data],
    dim_customer_rename = Table.RenameColumns(dim_customer, {{"GeographyKey", "GeographyKey2"}}),
    join_one = Table.Join(dbo_DimGeography, "GeographyKey", dim_customer_rename, "GeographyKey2", JoinKind.LeftOuter),
    
    // Fact table join
    fact_table = AdventureWorksDW2017{[Schema="dbo",Item="FactInternetSales"]}[Data],
    fact_table_rename = Table.RenameColumns(fact_table, {
        {"SalesTerritoryKey", "SalesTerritoryKey2"}, 
        {"CustomerKey", "CustomerKey2"}
    }),
    join_two = Table.Join(join_one, "CustomerKey", fact_table_rename, "CustomerKey2", JoinKind.LeftOuter),
    
    // Group
    grouped_table = Table.Group(join_two, 
        {"City", "CountryRegionCode", "EnglishCountryRegionName"},
        {{"SalesTotal", each List.Sum([SalesAmount]), type number}}
    ),

    // No sales
    filtered_sales = Table.SelectRows(grouped_table, each
            ([SalesTotal] = null)
        or  ([SalesTotal] = 0.00)
    ),

    //Order rows
    ordered = Table.Sort(filtered_sales, 
        {{"CountryRegionCode", Order.Ascending},
        {"City", Order.Ascending}}
    )

in
    ordered