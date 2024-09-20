let
    Source = Sql.Database("<server_url>", "<database_name>", 
    [
        Query = "
            SELECT an.*
            FROM <table_name> er
            JOIN <email_table> an
                ON er.<id_column> = an.<regarding_object_column>
            WHERE er.<primary_case_column> = '" & Text.From(<ParameterName>) & "'
        "
    ]
)
in
    Source
