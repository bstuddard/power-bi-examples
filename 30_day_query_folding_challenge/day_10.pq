let
    // Source
    Source = Sql.Databases("localhost"),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    Dimension_Employee = WideWorldImportersDW{[Schema="Dimension",Item="Employee"]}[Data],

    // Distinct employees
    #"Removed Other Columns" = Table.SelectColumns(Dimension_Employee,{"Employee", "WWI Employee ID"}),
    #"Removed Duplicates" = Table.Distinct(#"Removed Other Columns"),

    // Teammate 
    teammates = Table.AddColumn(#"Removed Duplicates", "Teammate", each 
        if [WWI Employee ID] = 0 then 2 else
        Number.Mod([WWI Employee ID],2) + [WWI Employee ID],
        type number
    ),

    // Join
    joined_columns = Table.NestedJoin(teammates, "Teammate", teammates, "Teammate", "Teammate2"),
    expanded = Table.ExpandTableColumn(joined_columns, "Teammate2", {"Employee"}, {"TeammateName.Employee"}),
    removed_other = Table.RemoveColumns(expanded,{"WWI Employee ID", "Teammate"}),

    // Filter
    filtered_table = Table.SelectRows(removed_other, each [Employee] <> [TeammateName.Employee])

in
    filtered_table