let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    AdventureWorksDW2017 = Source{[Name="AdventureWorksDW2017"]}[Data],
    dbo_DimCurrency = AdventureWorksDW2017{[Schema="dbo",Item="DimCurrency"]}[Data],

    // Replace text with +1 chars
    distinct_names = List.Distinct(Table.Column(dbo_DimCurrency, "CurrencyName")),
    multiple_e = List.Select(distinct_names, each (Text.Length(Text.Replace(_, "e", "**")) - Text.Length(_)) = 2),
    
    // Select rows
    final_rows = Table.SelectRows(dbo_DimCurrency, each List.Contains(multiple_e, [CurrencyName]))
in
    final_rows