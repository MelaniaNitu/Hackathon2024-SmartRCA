let
    Source = Sql.Database("<server_url>", "<database_name>",
    [
        Query = "
            SELECT 
                icm.<title_column>,
                icm.<url_column>,
                icm.<id_column>,
                emailmap.<email_body_column>,
                emailmap.<email_subject_column>,
                emailmap.<mapping_id_column>
            FROM 
                <incident_table> i
            JOIN 
                <icm_incident_table> icm_inc
                ON i.<incident_id_column> = icm_inc.<incident_id_column>
            JOIN 
                <icm_table> icm
                ON icm_inc.<icm_id_column> = icm.<icm_id_column>
            LEFT JOIN 
                <email_mapping_table> emailmap
                ON icm.<icm_id_column> = emailmap.<icm_id_column>
            WHERE 
                i.<primary_case_column> = '" & Text.From(<ParameterName>) & "';
        "
    ])
in
    Source
