let
    // Initial Sources
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    WideWorldImportersDW = Source{[Name="WideWorldImportersDW"]}[Data],
    Dimension_Employee = WideWorldImportersDW{[Schema="Dimension",Item="Employee"]}[Data],
    Dimension_Customer = WideWorldImportersDW{[Schema="Dimension",Item="Customer"]}[Data],

    // Select and rename columns for union
    select_employee = Table.SelectColumns(Dimension_Employee, {"Employee"}),
    rename_employee = Table.RenameColumns(select_employee, {{"Employee", "Full Name"}}),
    select_customer = Table.SelectColumns(Dimension_Customer, {"Primary Contact"}),
    rename_customer = Table.RenameColumns(select_customer, {{"Primary Contact", "Full Name"}}),

    // Union Tables
    unioned_tables = Table.Combine({rename_employee, rename_customer}),

    // Distinct names only
    distinct_names = Table.Distinct(unioned_tables),

    // Sort by name
    sorted_names = Table.Sort(distinct_names, {{"Full Name", Order.Ascending}})

in
    sorted_names