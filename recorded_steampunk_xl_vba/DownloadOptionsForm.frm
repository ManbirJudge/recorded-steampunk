VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} DownloadOptionsForm 
   Caption         =   "Download from Server - Options"
   ClientHeight    =   3960
   ClientLeft      =   120
   ClientTop       =   465
   ClientWidth     =   3315
   OleObjectBlob   =   "DownloadOptionsForm.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "DownloadOptionsForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Function DownloadFromServer(ByVal sortBy As String, ByVal sortOrder As String)
   ' defining variables
   Dim tests() As Dictionary

   Dim req As Object
   Dim res As New Dictionary

   Dim currentPage As Integer
   Dim testsPerPage As Integer
   Dim numPages As Integer
   Dim numTests As Integer

   ' setting current page to one
   currentPage = 0

   ' creating and sending request
   Set req = CreateObject("MSXML2.serverXMLHTTP")

   req.Open "GET", "http://localhost:5000/test-record/" & currentPage & "?sort-by=" & sortBy & "&sort-order=" & sortOrder, False
   
   req.Send

   ' storing the response
   Set res = JsonConverter.ParseJson(req.responseText)

   ' getting the congiuration varibles
   testsPerPage = res("tests-per-page")
   numPages = res("num-pages")
   numTests = res("num-tests")

   ' changing length of tests to the new one
   ReDim tests(1 To testsPerPage * numPages)

   ' adding tests of  current page to the all tests array
   Dim i As Integer
   For i = 1 To numTests
      Set tests(i + testsPerPage * currentPage) = res("tests")(i)
   Next i

   ' retreiving next pages
   While currentPage + 1 < numPages
      ' creating and sending request
      Set req = CreateObject("MSXML2.serverXMLHTTP")

      req.Open "GET", "http://localhost:5000/test-record/" & (currentPage + 1) & "?sort-by=" & sortBy & "&sort-order=" & sortOrder, False

      req.Send

      ' storing the response
      Set res = JsonConverter.ParseJson(req.responseText)
      
      ' getting number of tests on this page (will changed on the last page)
      numTests = res("num-tests")

      ' adding tests of  current page to the all tests array
      For i = 1 To numTests
         Set tests(i + testsPerPage * (currentPage + 1)) = res("tests")(i)
      Next i
      
      ' updaing current page
      currentPage = res("current-page")
   Wend

   ' setting test values in cells
   For i = 1 To UBound(tests)
      Dim test As New Dictionary
      Set test = tests(i)

      Cells(i + 1, 1).Value = Format(TimestampToDate(test("date")), "dd-mm-yyyy")
      ' Cells(i + 1, 1).Value = TimestampToDate(test("date"))
      Cells(i + 1, 2).Value = test("title")
      Cells(i + 1, 3).Value = test("subject")
      Cells(i + 1, 4).Value = test("topic")
      Cells(i + 1, 5).Value = test("total-marks")
      Cells(i + 1, 6).Value = test("marks-obtained")
   Next i
End Function

Private Sub DownloadOptionsFormDownloadBtn_Click()
   Dim sortBy As String: sortBy = "date"
   Dim sortOrder As String: sortOrder = "asc"

   If DownLoadOptionsSortByDateOption.Value = True Then
      sortBy = "date"
   ElseIf DownLoadOptionsSortBySubjectOption.Value = True Then
      sortBy = "subject"
   End If

   If DownLoadOptionsSortOrderAscOption.Value = True Then
      sortOrder = "asc"
   ElseIf DownLoadOptionsSortOrderDescOption.Value = True Then
      sortOrder = "desc"
   End If
   
   DownloadFromServer sortBy, sortOrder

   DownloadOptionsForm.Hide
End Sub

Private Sub DownloadOptionsFormCancelBtn_Click()
   Call ModuleMain.ResetDownloadOptionsForm
   DownloadOptionsForm.Hide
End Sub

