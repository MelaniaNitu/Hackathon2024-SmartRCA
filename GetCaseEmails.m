let
    FetchEmailContent = (activityid as text) as nullable text =>
    let
        Url = "https://<api_url>/api/data/v9.2/emails(" & activityid & ")/description/$value",
        Source = try Web.Contents(Url) otherwise null,
        TextContent = if Source <> null then 
            try Text.FromBinary(Source) otherwise null
        else
            "Failed to fetch data"
    in
        TextContent,

    Source = Sql.Database("<server_url>", "<database_name>", 
    [
        Query = "
            SELECT an.activityid
            FROM <table_name> er
            JOIN <email_table> an
                ON er.<id_column> = an.<regarding_object_column>
            WHERE er.<primary_case_column> = '" & Text.From(<ParameterName>) & "'"
    ]),

    AddContentColumn = Table.AddColumn(Source, "EmailContent", each FetchEmailContent([activityid]), type text)

in
    AddContentColumn
