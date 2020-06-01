let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    Fact_Sale = WideWorldImportersDW{[Schema="Fact",Item="Sale"]}[Data],

    // Partition
    year_col = Table.AddColumn(Fact_Sale, "Invoice_Year", each Date.Year([Invoice Date Key]), type number),
    partitions = List.Count(List.Distinct(Table.Column(year_col, "Invoice_Year"))),
    partition_table = Table.Partition(year_col, "Invoice_Year", 4, each _),
    
    // List partitions
    partition_results = Table.Combine({partition_table{0}, partition_table{1}, partition_table{2}, partition_table{3}})
in
    partition_results