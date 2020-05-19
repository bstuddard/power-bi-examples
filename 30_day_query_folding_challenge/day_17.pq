let
    // Initial Source
    Source = Sql.Databases("localhost", [CreateNavigationProperties=false]),
    AdventureWorksDW2017 = Source{[Name="AdventureWorksDW2017"]}[Data],
    dbo_FactCallCenter = AdventureWorksDW2017{[Schema="dbo",Item="FactCallCenter"]}[Data],

    // Total Time computed column
    total_time = Table.AddColumn(dbo_FactCallCenter, "TotalTime", each [Calls] * [AverageTimePerIssue], type number),

    // PM Shift Only
    pm_only = Table.SelectRows(total_time, each Text.Contains([Shift], "PM")),

    // Top and bottom 10
    maxn = List.MaxN(Table.Column(pm_only, "TotalTime"), 10),
    minn = List.MinN(Table.Column(pm_only, "TotalTime"), 10),
    unioned = List.Union({maxn, minn}),
    filtered = Table.SelectRows(pm_only, each List.Contains(unioned, [TotalTime])),

    // Select and order
    selected_columns = Table.SelectColumns(filtered, {"DateKey", "Shift", "Calls", "AverageTimePerIssue", "TotalTime"}),
    sorted_columns = Table.Sort(selected_columns, {"TotalTime", Order.Ascending})

in
    sorted_columns