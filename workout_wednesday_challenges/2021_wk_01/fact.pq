let
    // Import from data.world
    Source = DataWorld.Dataset("jbaucke", "2021-w1-power-bi-wow-ncaa-financials", null),
    finances_fact1 = Source{[tableId="finances_fact"]}[Data],

    /* Remove the following situations
        1) null or FBS Total values in fbs_conference
        2) Conference Medians in NCAA Subdivision
    */
    filtered_rows = Table.SelectRows(
        finances_fact1, each (
                [fbs_conference] <> null 
            and [fbs_conference] <> "FBS Total"
            and [ncaa_subdivision] <> "Conference Median"
        )
    )
in
    filtered_rows