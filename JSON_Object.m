let
    CaseData = GetCase,
    CaseNotes = GetCaseNotes,
    CaseEmails = GetCaseEmails,

    SelectedCaseColumns = Table.SelectColumns(CaseData, {
        "<column_1>", 
        "<column_2>", 
        "<column_3>", 
        "<column_4>", 
        "<primary_case_column>", 
        "<column_5>", 
        "<column_6>", 
        "<column_7>", 
        "<column_8>", 
        "<column_9>", 
        "<column_10>", 
        "<column_11>", 
        "<column_12>"
    }),

    SelectedNotesColumns = Table.SelectColumns(CaseNotes, {"<note_column>"}),

    SelectedEmailsColumns = Table.SelectColumns(CaseEmails, {"<email_content_column>"}),

    CaseRecord = Table.First(SelectedCaseColumns),

    NotesList = Table.ToRecords(SelectedNotesColumns),
    EmailsList = Table.ToRecords(SelectedEmailsColumns),

    CombinedObject = [
        Case = CaseRecord,
        Notes = NotesList,
        Emails = EmailsList
    ],

    ToJSON = Json.FromValue(CombinedObject),
    #"Imported JSON" = Json.Document(ToJSON, 1252)
in
    #"Imported JSON"
