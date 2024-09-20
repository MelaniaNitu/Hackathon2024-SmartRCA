let
    CaseData = GetAnonymizedCase,
    CaseNotes = GetAnonymizedCaseNotes,
    CaseEmails = GetAnonymizedCaseEmails,

    FirstRow = Table.First(CaseData),

    FormatCaseInfo = (record as record) as text =>
    let
        AnonymizedAccountName = Record.FieldOrDefault(record, "AccountNameField", "N/A"),
        AnonymizedCountry = Record.FieldOrDefault(record, "CountryField", "N/A"),
        AnonymizedTitle = Record.FieldOrDefault(record, "TitleField", "N/A"),
        AnonymizedTicketNumber = Record.FieldOrDefault(record, "TicketNumberField", "N/A"),
        AnonymizedSupportAreaPath = Record.FieldOrDefault(record, "SupportAreaPathField", "N/A"),
        AnonymizedStatus = Record.FieldOrDefault(record, "StatusField", "N/A"),
        FormattedText = "Account Name: " & AnonymizedAccountName & 
                        "\nCountry: " & AnonymizedCountry & 
                        "\nTitle: " & AnonymizedTitle & 
                        "\nTicket Number: " & AnonymizedTicketNumber & 
                        "\nSupport Area Path: " & AnonymizedSupportAreaPath & 
                        "\nStatus: " & AnonymizedStatus
    in
        FormattedText,

    CaseInfoText = FormatCaseInfo(FirstRow),

    NotesText = Text.Combine(CaseNotes[AnonymizedNoteField], " "),

    EmailsText = Text.Combine(CaseEmails[AnonymizedEmailField], " "),

    FetchGPTResponse = (promptText as text) as text =>
    let
        Url = "https://api.example.com/openai/deployments/sample/chat/completions?api-version=2024-02-15-preview",
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
                #"api-key" = "YOUR-API-KEY"
            ],
            Content = Body
        ]),
        JsonResponse = Json.Document(Source),
        Choices = JsonResponse[choices],
        ResponseText = if List.Count(Choices) > 0 then Choices{0}[message][content] else "No response available"
    in
        ResponseText,

    Case_Info_Summary = FetchGPTResponse("Anonymized case information:\n\n" & CaseInfoText),

    Case_Notes_Summary = FetchGPTResponse("Anonymized case notes:\n\n" & NotesText & "\n\nContext from previous: " & Case_Info_Summary),

    Case_Emails_Summary = FetchGPTResponse("Anonymized case emails:\n\n" & EmailsText & "\n\nContext from previous: " & Case_Notes_Summary),

    RCA = FetchGPTResponse("Generate anonymized 5 WHYs RCA report based on the case information, notes, and emails provided.\n\nContext from previous: " & Case_Info_Summary & Case_Notes_Summary & Case_Emails_Summary),

    Output = [
        Case_Info_Summary = Case_Info_Summary,
        Case_Notes_Summary = Case_Notes_Summary,
        Case_Emails_Summary = Case_Emails_Summary,
        RCA = RCA
    ]
in
    Output
