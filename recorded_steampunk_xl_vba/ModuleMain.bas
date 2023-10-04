Attribute VB_Name = "ModuleMain"

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

Function TimestampMsToDate(timestampMs As Double) As Date 
    TimestampMsToDate = DateAdd("s", timestampMs / 1000, #1/1/1970#)
End Function

Sub UploadToServer()
    Sheets("Test Record").Select
    
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
    
    Set DatesRange = CellRangeUnderTitle("Date")
    Set TitlesRange = CellRangeUnderTitle("Title")
    Set SubjectsRange = CellRangeUnderTitle("Subject")
    Set TopicsRange = CellRangeUnderTitle("Topic")
    Set TotalMarksRange = CellRangeUnderTitle("Total Marks")
    Set MarksObtainedRange = CellRangeUnderTitle("Marks Obtained")
    
    Dates = CellRangeToStringArray(DatesRange)
    Titles = CellRangeToStringArray(TitlesRange)
    Subjects = CellRangeToStringArray(SubjectsRange)
    Topics = CellRangeToStringArray(TopicsRange)
    TotalMarks = CellRangeToStringArray(TotalMarksRange)
    MarksObtained = CellRangeToStringArray(MarksObtainedRange)
    
    ' The HTTP part
    Dim Data As New Dictionary
    Dim TestRecordData() As Dictionary
    
    Data.CompareMode = CompareMethod.TextCompare
    
    Dim numTests As Integer
    numTests = DatesRange.Rows.Count
    
    ReDim TestRecordData(1 To numTests)
    
    Dim i As Integer
    For i = 1 To numTests
        Set TestRecordData(i) = New Dictionary
        
        TestRecordData(i).CompareMode = CompareMethod.TextCompare
        
        TestRecordData(i)("date") = Dates(i)
        TestRecordData(i)("title") = Titles(i)
        TestRecordData(i)("subject") = Subjects(i)
        TestRecordData(i)("topic") = Topics(i)
        TestRecordData(i)("total-marks") = TotalMarks(i)
        TestRecordData(i)("marks-obtained") = MarksObtained(i)
        
    Next i
    
    Debug.Print JsonConverter.ConvertToJson(TestRecordData)
    
    Data("tests") = TestRecordData
    
    Dim xmlHttp As Object
    Set xmlHttp = CreateObject("MSXML2.serverXMLHTTP")
    
    xmlHttp.Open "PUT", "http://localhost:5000/test-record", False
    xmlHttp.setRequestHeader "Content-Type", "application/json"
    xmlHttp.Send JsonConverter.ConvertToJson(Data)
    
    Dim responseJson As New Dictionary
    Set responseJson = JsonConverter.ParseJson(xmlHttp.responseText)
    
    If responseJson.Exists("message") Then
        MsgBox responseJson("message"), vbInformation
    ElseIf responseJson.Exists("error") Then
        MsgBox responseJson("error"), vbCritical
    Else
        MsgBox "Unkwon response from server as follows:\n" & JsonConverter.ConvertToJson(responseJson), vbExclamation
    End If
End Sub

Sub DownloadFromServer()
    Dim tests() As Dictionary

    Dim req As Object
    Dim response As New Dictionary

    Dim currentPage As Integer
    Dim testsPerPage As Integer
    Dim numPages As Integer
    Dim numTests As Integer

    currentPage = 0

    Set req = CreateObject("MSXML2.serverXMLHTTP")

    req.Open "GET", "http://localhost:5000/test-record/" & currentPage, False
    req.setRequestHeader "Content-Type", "application/json"
    req.Send "{" & Chr(34) & "str-dates" & Chr(34) & ": true}"

    Set response = JsonConverter.ParseJson(req.responseText)

    testsPerPage = response("tests-per-page")
    numPages = response("num-pages")
    numTests = response("num-tests")

    ReDim tests(1 To testsPerPage * numPages)

    Dim i As Integer
    For i = 1 To numTests
        Set tests(i + testsPerPage * currentPage) = response("tests")(i)
    Next i

    While currentPage + 1 < numPages
        Set req = CreateObject("MSXML2.serverXMLHTTP")

        req.Open "GET", "http://localhost:5000/test-record/" & currentPage + 1, False
        req.setRequestHeader "Content-Type", "application/json"
        req.Send "{" & Chr(34) & "str-dates" & Chr(34) & ": true}"

        Set response = JsonConverter.ParseJson(req.responseText)

        numTests = response("num-tests")

        For i = 1 To numTests
            Set tests(i + testsPerPage * (currentPage + 1)) = response("tests")(i)
        Next i

        currentPage = response("current-page")
    Wend

    For i = 1 To UBound(tests)
        Dim test As New Dictionary
        Set test = tests(i)

        Debug.Print test("date")
        Debug.Print TimestampMsToDate(test("date"))

        Cells(i + 1, 1).Value = Format(TimestampMsToDate(test("date")), "dd-mm-yyyy")
        Cells(i + 1, 2).Value = test("title")
        Cells(i + 1, 3).Value = test("subject")
        Cells(i + 1, 4).Value = test("topic")
        Cells(i + 1, 5).Value = test("total-marks")
        Cells(i + 1, 6).Value = test("marks-obtained")
    Next i
End Sub

Function ClearAddTestForm()
    AddTestForm.AddTestFormSubjectDropdown.AddItem("Science")
    AddTestForm.AddTestFormSubjectDropdown.AddItem("Maths")
    AddTestForm.AddTestFormSubjectDropdown.AddItem("SST")
    AddTestForm.AddTestFormSubjectDropdown.AddItem("Hindi")
    AddTestForm.AddTestFormSubjectDropdown.AddItem("Punjabi")
    AddTestForm.AddTestFormSubjectDropdown.AddItem("English")

    AddTestForm.AddNewTestDateInput.Text = ""
    AddTestForm.AddNewTestTitleInput.Text = ""
    AddTestForm.AddTestFormSubjectDropdown.Text = ""
    AddTestForm.AddNewTestTopicInput.Text = ""
    AddTestForm.AddNewTestTotalMarksInput.Text = "0"
    AddTestForm.AddNewTestMarksObtainedInput.Text = "0"

    AddTestForm.AddNewTestTotalMarksSpinBtn.Value = 0
    AddTestForm.AddNewTestMarksObtainedSpinBtn.Value = 0
End Function

Sub OpenAddTestForm()
    Call ClearAddTestForm()
    AddTestForm.Show
End Sub