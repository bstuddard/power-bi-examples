let
    // Starting Table
    Source = Sql.Databases("localhost"),
    AdventureWorksDW2017 = Source{[Name="AdventureWorksDW2017"]}[Data],
    dbo_DimEmployee = AdventureWorksDW2017{[Schema="dbo",Item="DimEmployee"]}[Data],

    // Filter to BirthDate = 1974
    filtered_year = Table.SelectRows(dbo_DimEmployee, each Date.Year([BirthDate]) = 1974),

    // Null handling before concat to prevent errors
    null_wrap = Table.ReplaceValue(filtered_year, null, "", Replacer.ReplaceValue, {"MiddleName"}),

    // Create new custom column FullName
    concat_name = Table.AddColumn(null_wrap, "FullName", each [FirstName] 
                                                            & (if [MiddleName] <> "" then " " else "")
                                                            & [MiddleName] 
                                                            & " " 
                                                            & [LastName], type text),
    
    // Select only necessary columns
    selected_columns = Table.SelectColumns(concat_name, {"EmployeeKey", "Gender", "BirthDate", "FullName"})

in
    selected_columns