let
    // Starting table
    Source = Sql.Databases("localhost"),
    AdventureWorksDW2017 = Source{[Name="AdventureWorksDW2017"]}[Data],
    dbo_DimReseller = AdventureWorksDW2017{[Schema="dbo",Item="DimReseller"]}[Data],

    // Filter down reseller
    filtered_reseller = Table.SelectRows(dbo_DimReseller, each Text.Contains([ResellerName], "Bike") 
                                                            or Text.Contains([ResellerName], "Bicycle")),
    
    // Expand and filter Geo dim (Exclude DE or GB CountryRegionCode)
    expanded_geo = Table.ExpandRecordColumn(filtered_reseller, "DimGeography", {"CountryRegionCode", "EnglishCountryRegionName"}),
    filtered_geo = Table.SelectRows(expanded_geo, each [CountryRegionCode] <> "DE" and [CountryRegionCode] <> "GB"),

    // Select only necessary columns
    final_columns = Table.SelectColumns(filtered_geo, {"ResellerKey", "BusinessType", "ResellerName", "NumberEmployees", 
                                                        "ProductLine", "AnnualRevenue", "EnglishCountryRegionName"})
 
in
    final_columns