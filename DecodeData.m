let
    FetchEmailContent = (activityid as text) as nullable text =>
    let
        Url = "https://<api_url>/api/data/v9.2/emails(" & activityid & ")/descriptionblobid/$value",
        Source = try Web.Contents(Url) otherwise null,
        DecodedContent = if Source <> null then
            let
                Base64String = Binary.ToText(Source, BinaryEncoding.Base64),
                BinaryData = Binary.FromText(Base64String, BinaryEncoding.Base64),
                DecodedContentUtf8 = try Text.FromBinary(BinaryData, TextEncoding.Utf8) otherwise null,
                DecodedContentIso = try Text.FromBinary(BinaryData, TextEncoding.Iso8859_1) otherwise null,
                DecodedContentUtf16 = try Text.FromBinary(BinaryData, TextEncoding.Utf16) otherwise null,
                DecodedContent = if DecodedContentUtf8 <> null then DecodedContentUtf8
                                 else if DecodedContentIso <> null then DecodedContentIso
                                 else if DecodedContentUtf16 <> null then DecodedContentUtf16
                                 else "Unable to decode"
            in
                DecodedContent
        else
            "Failed to fetch data"
    in
        DecodedContent,

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
