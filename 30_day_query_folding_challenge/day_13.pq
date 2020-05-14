let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    AdventureWorksDW2017 = Source{[Name="AdventureWorksDW2017"]}[Data],
    dbo_DimEmployee = AdventureWorksDW2017{[Schema="dbo",Item="DimEmployee"]}[Data],

    // Filter on birth date
    filtered_records = Table.SelectRows(dbo_DimEmployee, each [BirthDate] >= #date(1990,01,01) and [BirthDate] <= #date(1990,12,31)),

    // Select necessary columns
    final_results = Table.SelectColumns(filtered_records, {"EmailAddress", "Gender", "BirthDate"})

in
    final_results