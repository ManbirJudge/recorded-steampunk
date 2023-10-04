Attribute VB_Name = "ModuleMain"

' utility functions
Function CellRangeUnderTitle(ByVal Title As String) As Range
    Dim ColI As Long
    Dim LastRow As Long
    
    ColI = 0
    
    For ColI = 1 To Cells(1, Columns.Count).End(xlToLeft).Column
        If Cells(1, ColI).Value = Title Then
            Exit For
        End If
    Next ColI
    
    LastRow = Cells(Rows.Count, ColI).End(xlUp).Row
    
    If LastRow > 1 Then
        ' Select the entire column except the title cell
        Set CellRangeUnderTitle = Range(Cells(2, ColI), Cells(LastRow, ColI))
    Else
        MsgBox "Column '" & Title & "' has only one cell.", vbExclamation
    End If
End Function

Function CellRangeToStringArray(ByVal cellRange As Range) As String()
    Dim stringArr() As String
    
    Dim rowCount As Integer
    rowCount = cellRange.Rows.Count
    
    ReDim stringArr(1 To rowCount)

    Dim i As Integer
    For i = 1 To cellRange.Rows.Count
        Dim cellVal As String
        cellVal = cellRange.Cells(i, 1).Value
        
        stringArr(i) = cellVal
    Next i
    
    CellRangeToStringArray = stringArr
End Function

Public Function TimestampToDate(ByVal timestamp As LongLong) As Date
    TimestampToDate = DateAdd("s", timestamp / 1000, #1/1/1970#)
End Function

Public Function DateToTimestamp(ByVal dt As Date) As LongLong
    DateToTimestamp = DateDiff("s", #1/1/1970#, dt) * 1000
End Function

' button macros
Sub UploadToServer()
    Sheets("Test Record").Select
    
    ' defining vars
    Dim DatesRange As Range
    Dim TitlesRange As Range
    Dim SubjectsRange As Range
    Dim TopicsRange As Range
    Dim TotalMarksRange As Range
    Dim MarksObtainedRange As Range
    
    Dim Dates() As String
    Dim Titles() As String
    Dim Subjects() As String
    Dim Topics() As String
    Dim TotalMarks() As String
    Dim MarksObtained() As String

    Dim numTests As Integer
    
    ' getting ranges
    Set DatesRange = CellRangeUnderTitle("Date")
    Set TitlesRange = CellRangeUnderTitle("Title")
    Set SubjectsRange = CellRangeUnderTitle("Subject")
    Set TopicsRange = CellRangeUnderTitle("Topic")
    Set TotalMarksRange = CellRangeUnderTitle("Total Marks")
    Set MarksObtainedRange = CellRangeUnderTitle("Marks Obtained")
    
    ' getting values from ranges
    Dates = CellRangeToStringArray(DatesRange)
    Titles = CellRangeToStringArray(TitlesRange)
    Subjects = CellRangeToStringArray(SubjectsRange)
    Topics = CellRangeToStringArray(TopicsRange)
    TotalMarks = CellRangeToStringArray(TotalMarksRange)
    MarksObtained = CellRangeToStringArray(MarksObtainedRange)

    numTests = DatesRange.Rows.Count
    
    ' preparing request body data
    Dim reqBody As New Dictionary
    Dim testRecord() As Dictionary
    
    ReDim testRecord(1 To numTests)
    
    Dim i As Integer
    For i = 1 To numTests
        Set testRecord(i) = New Dictionary
        
        testRecord(i)("date") = DateToTimestamp(DateValue(Dates(i)))
        testRecord(i)("title") = Titles(i)
        testRecord(i)("subject") = Subjects(i)
        testRecord(i)("topic") = Topics(i)
        testRecord(i)("total-marks") = TotalMarks(i)
        testRecord(i)("marks-obtained") = MarksObtained(i)
    Next i
    
    reqBody("tests") = testRecord
    
    ' creating and sending the request
    Dim req As Object
    Set req = CreateObject("MSXML2.serverXMLHTTP")
    
    req.Open "PUT", "http://localhost:5000/test-record", False
    req.setRequestHeader "Content-Type", "application/json"
    req.Send JsonConverter.ConvertToJson(reqBody)
    
    ' getting response
    Dim res As New Dictionary
    Set res = JsonConverter.ParseJson(req.responseText)
    
    ' showing result
    If res("status") = 0 Then
        MsgBox res("message"), vbInformation
    ElseIf res("status") = 1 Then
        MsgBox res("message"), vbExclamation
    ElseIf res("status") = 2 Then
        MsgBox res("message"), vbCritical
    ElseIf res("status") = -1 Then
        MsgBox "Unknown response from server:\n" & res("message"), vbExclamation
    Else
        MsgBox "Unkwon response format:\n" & JsonConverter.ConvertToJson(res), vbExclamation
    End If
End Sub

' form utils
Function ResetDownloadOptionsForm()
    DownloadOptionsForm.DownLoadOptionsSortByDateOption.Value = True
    DownloadOptionsForm.DownLoadOptionsSortOrderDescOption.Value = True
End Function

Function ResetAddTestForm()
    AddTestForm.AddTestFormSubjectDropdown.AddItem ("Science")
    AddTestForm.AddTestFormSubjectDropdown.AddItem ("Maths")
    AddTestForm.AddTestFormSubjectDropdown.AddItem ("SST")
    AddTestForm.AddTestFormSubjectDropdown.AddItem ("Hindi")
    AddTestForm.AddTestFormSubjectDropdown.AddItem ("Punjabi")
    AddTestForm.AddTestFormSubjectDropdown.AddItem ("English")

    AddTestForm.AddNewTestDateInput.Text = ""
    AddTestForm.AddNewTestTitleInput.Text = ""
    AddTestForm.AddTestFormSubjectDropdown.Text = ""
    AddTestForm.AddNewTestTopicInput.Text = ""
    AddTestForm.AddNewTestTotalMarksInput.Text = "0"
    AddTestForm.AddNewTestMarksObtainedInput.Text = "0"

    AddTestForm.AddNewTestTotalMarksSpinBtn.Value = 0
    AddTestForm.AddNewTestMarksObtainedSpinBtn.Value = 0
End Function

' form opening macros
Sub OpenDownloadOptionsForm()
    Call ResetDownloadOptionsForm
    DownloadOptionsForm.Show
End Sub

Sub OpenAddTestForm()
    Call ResetAddTestForm
    AddTestForm.Show
End Sub


