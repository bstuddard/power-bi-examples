let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    AdventureWorksDW2017 = Source{[Name="AdventureWorksDW2017"]}[Data],
    dbo_DimPromotion = AdventureWorksDW2017{[Schema="dbo",Item="DimPromotion"]}[Data],

    // Column Logic - Camel to Space
    split_function = Splitter.SplitTextByCharacterTransition({"a".."z"}, {"A".."Z"}),

    // Rename columns 
    renamed = Table.TransformColumnNames(dbo_DimPromotion, each Text.Combine(split_function(_), " "))
    
in
    renamed