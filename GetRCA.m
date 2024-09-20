let
    CaseData = GetCase,
    CaseNotes = GetCaseNotes,
    CaseEmails = GetCaseEmails,

    FirstRow = Table.First(CaseData),

    FormatCaseInfo = (record as record) as text =>
    let
        AccountName = Record.FieldOrDefault(record, "<account_column>", "N/A"),
        Country = Record.FieldOrDefault(record, "<country_column>", "N/A"),
        Title = Record.FieldOrDefault(record, "<title_column>", "N/A"),
        TicketNumber = Record.FieldOrDefault(record, "<ticket_number_column>", "N/A"),
        SupportAreaPath = Record.FieldOrDefault(record, "<support_area_column>", "N/A"),
        Status = Record.FieldOrDefault(record, "<status_column>", "N/A"),
        
        FormattedText = "Account Name: " & AccountName & 
                        "\nCountry: " & Country & 
                        "\nTitle: " & Title & 
                        "\nTicket Number: " & TicketNumber & 
                        "\nSupport Area Path: " & SupportAreaPath & 
                        "\nStatus: " & Status
    in
        FormattedText,

    CaseInfoText = FormatCaseInfo(FirstRow),

    NotesText = Text.Combine(CaseNotes["<note_column>"], " "),

    EmailsText = Text.Combine(CaseEmails["<email_content_column>"], " "),

    FetchGPTResponse = (promptText as text) as text =>
    let
        Url = "https://<openai_api_url>/openai/deployments/gpt-4o/chat/completions?api-version=2024-02-15-preview",
        Body = Json.FromValue([
            messages = {
                [ role = "user", content = promptText ]
            },
            temperature = 0.7,
            top_p = 0.95,
            max_tokens = 2000
        ]),
        Source = Web.Contents(Url, [
            Headers = [
                #"Content-Type" = "application/json",
                #"api-key" = "*" // Replace with your actual API key
            ],
            Content = Body
        ]),
        JsonResponse = Json.Document(Source),
        Choices = JsonResponse[choices],
        ResponseText = if List.Count(Choices) > 0 then Choices{0}[message][content] else "No response available"
    in
        ResponseText,

    Case_Info_Summary = FetchGPTResponse("Case information:\n\n" & CaseInfoText),

    Case_Notes_Summary = FetchGPTResponse("Case notes:\n\n" & NotesText & "\n\nContext from previous: " & Case_Info_Summary),

    Case_Emails_Summary = FetchGPTResponse("Case emails:\n\n" & EmailsText & "\n\nContext from previous: " & Case_Notes_Summary),

    RCA = FetchGPTResponse("Generate 5 WHYs RCA report based on the case information, notes, and emails provided.\n\nContext from previous: " & Case_Info_Summary & Case_Notes_Summary & Case_Emails_Summary),

    Output = [
        Case_Info_Summary = Case_Info_Summary,
        Case_Notes_Summary = Case_Notes_Summary,
        Case_Emails_Summary = Case_Emails_Summary,
        RCA = RCA
    ]
in
    Output
