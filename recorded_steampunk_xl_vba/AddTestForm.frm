VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} AddTestForm 
   Caption         =   "Add New Test"
   ClientHeight    =   4845
   ClientLeft      =   120
   ClientTop       =   465
   ClientWidth     =   4440
   OleObjectBlob   =   "AddTestForm.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "AddTestForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Function PostTestDataFromFormToServer() As Dictionary
    ' defining variables
    Dim testDate As String
    Dim testTitle As String
    Dim testSubject As String
    Dim testTopic As String
    Dim testTotalMarks As String
    Dim testMarksObtained As String

    Dim testData As New Dictionary
    Dim reqData As New Dictionary
    Dim req As Object

    ' defining the function result
    Dim funcRes As New Dictionary
    
    ' getting form data
    testDate = AddNewTestDateInput.Text
    testTitle = AddNewTestTitleInput.Text
    testSubject = AddTestFormSubjectDropdown.Text
    testTopic = AddNewTestTopicInput.Text
    testTotalMarks = AddNewTestTotalMarksInput.Text
    testMarksObtained = AddNewTestMarksObtainedInput.Text

    ' checking data and setting it afterwards
    If IsDate(testDate) Then
        testData("date") = Format(DateValue(testDate), "dd-mm-yyyy")
    Else
        funcRes("success") = 2
        funcRes("show_msg") = "Date not in correct format."

        Set PostTestDataFromFormToServer = funcRes
        Exit Function
    End If
    testData("title") = testTitle
    testData("subject") = testSubject
    testData("topic") = testTopic
    If IsNumeric(testTotalMarks) Then
        testData("total-marks") = CDbl(testTotalMarks)
    Else        
        funcRes("success") = 2
        funcRes("show_msg") = "Total marks should be a number."

        Set PostTestDataFromFormToServer = funcRes
        Exit Function
    End If
    If IsNumeric(MarksObtained) Then
        testData("marks-obtained") = CDbl(testMarksObtained)
    Else
        funcRes("success") = 2
        funcRes("show_msg") =  "Marks obtainedshould be a number."

        Set PostTestDataFromFormToServer = funcRes
        Exit Function
    End If

    ' setting request data
    reqData("multiple") = False
    Set reqData("test") = testData

    ' creating and sending the request
    Set req = CreateObject("MSXML2.serverXMLHTTP")
    
    req.Open "POST", "http://localhost:5000/test-record", False
    req.setRequestHeader "Content-Type", "application/json"
    req.Send JsonConverter.ConvertToJson(reqData)

    ' getting the response
    Dim res As New Dictionary
    Set res = JsonConverter.ParseJson(req.responseText)

    ' checking the response
    If res.Exists("message") Then
        ' adding new test to the spreadsheet
        Dim testI As Integer
        testI = res("index") + 1

        Cells(testI + 1, 1).Value = res("test")("date")
        Cells(testI + 1, 2).Value = res("test")("title")
        Cells(testI + 1, 3).Value = res("test")("subject")
        Cells(testI + 1, 4).Value = res("test")("topic")
        Cells(testI + 1, 5).Value = res("test")("total-marks")
        Cells(testI + 1, 6).Value = res("test")("marks-obtained")

        ' setting the function result
        funcRes("success") = 0
        funcRes("show_msg") = res("message")

        ' hiding the form
        AddTestForm.Hide
    ElseIf res.Exists("error") Then
        ' setting the function result
        funcRes("success") = 2
        funcRes("show_msg") = res("error")
    Else
        ' setting the function result
        funcRes("success") = 1
        funcRes("show_msg") = "Unkwon response from server as follows:\n" & JsonConverter.ConvertToJson(res)
    End If

    Set PostTestDataFromFormToServer = funcRes
End Function

Private Sub AddNewTestSubmitAndAddMoreBtn_Click()
    Dim res As New Dictionary
    
    Set res = PostTestDataFromFormToServer()

    If res("success") = 0 Then
        MsgBox res("show_msg"), vbInformation
        Call ModuleMain.ClearAddTestForm()
    ElseIf res("success") = 1 Then
        MsgBox res("show_msg"), vbExclamation
    Else
        MsgBox res("show_msg"), vbCritical
    End If
End Sub

Private Sub AddNewTestSubmitAndCloseBtn_Click()
    Dim res As New Dictionary
    
    Set res = PostTestDataFromFormToServer()

    ' res("success") == 0 ==> success
    ' res("success") == 1 ==> (kinda) warning
    ' res("success") == 2 ==> error
    If res("success") = 0 Then
        MsgBox res("show_msg"), vbInformation
        AddTestForm.Hide
    ElseIf res("success") = 1 Then
        MsgBox res("show_msg"), vbExclamation
    Else
        MsgBox res("show_msg"), vbCritical
    End if
End Sub

Private Sub AddNewTestCancelBtn_Click()
    AddTestForm.Hide
End Sub

Private Sub AddNewTestTotalMarksSpinBtn_Change()
    AddNewTestTotalMarksInput.Text = AddNewTestTotalMarksSpinBtn.Value
End Sub

Private Sub AddNewTestMarksObtainedSpinBtn_Change()
    AddNewTestMarksObtainedInput.Text = AddNewTestMarksObtainedSpinBtn.Value
End Sub