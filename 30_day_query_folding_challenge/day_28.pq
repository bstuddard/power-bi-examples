let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    AdventureWorksDW2017 = Source{[Name="AdventureWorksDW2017"]}[Data],
    dbo_DimProduct = AdventureWorksDW2017{[Schema="dbo",Item="DimProduct"]}[Data],

    // Computed percentage column
    filtered_prices = Table.SelectRows(dbo_DimProduct, each [DealerPrice] <> null),
    total_dealer_price = List.Sum(Table.Column(filtered_prices, "DealerPrice")),
    overall_perc_col = Table.AddColumn(filtered_prices, "OverallPercentage", each [DealerPrice] / total_dealer_price, type number),

    // Final Cols
    cols = Table.SelectColumns(overall_perc_col, {"ProductKey", "ProductAlternateKey", "EnglishProductName", 
        "DealerPrice", "OverallPercentage"})
in
    cols