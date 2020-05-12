let
    // Source
    Source = Sql.Databases("localhost"),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    Dimension_Employee = WideWorldImportersDW{[Schema="Dimension",Item="Employee"]}[Data],

    // Distinct employees
    #"Removed Other Columns" = Table.SelectColumns(Dimension_Employee,{"Employee", "WWI Employee ID"}),
    #"Removed Duplicates" = Table.Distinct(#"Removed Other Columns"),

    // Filter out unknown
    unknown_filter = Table.SelectRows(#"Removed Duplicates", each [Employee] <> "Unknown"),

    // Teammate 
    teammates = Table.AddColumn(unknown_filter, "Teammate", each 
        if [WWI Employee ID] = 0 then 2 else
        Number.Mod([WWI Employee ID],2) + [WWI Employee ID],
        type number
    ),
    duplicate_check = Table.AddColumn(teammates, "dup_flag", each 
        if Number.Mod([WWI Employee ID],2) = 0 then 1
        else 0,
        type number
    ),

    // Join
    joined_columns = Table.NestedJoin(duplicate_check, "Teammate", teammates, "Teammate", "Teammate2"),
    expanded = Table.ExpandTableColumn(joined_columns, "Teammate2", {"Employee"}, {"TeammateName.Employee"}),

    // Filter
    filtered_table = Table.SelectRows(expanded, each [Employee] <> [TeammateName.Employee] and [dup_flag] = 0),
    removed_other = Table.RemoveColumns(filtered_table,{"WWI Employee ID", "Teammate", "dup_flag"})

in
    removed_other