let
    Source = Sql.Database("<server_url>", "<database_name>", 
    [
        Query = "
            SELECT an.*
            FROM <table_name> er
            JOIN <annotation_table> an
                ON er.<id_column> = an.<object_column>
            WHERE er.<primary_case_column> = '" & Text.From(<ParameterName>) & "'
        "
    ]
)
in
    Source
