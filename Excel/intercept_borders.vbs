REM Table copy-pasted from pdf, non-uniform formatting of merged cells. Unable to filter data using CTRL+SHIFT+L
REM Intercepting borders to extract data in a uniform formatted, regular cell format

Sub Extract_btn_Click()
    Dim rng         As Range
    Set rng = Selection
    
    Dim borderStyle As Border
    
    Set borderStyle = rng.Borders(xlEdgeTop)
    
    Dim startRow    As Integer
    Dim endRow      As Integer
    startRow = rng.Row
    endRow = rng.Row + rng.Rows.Count - 1
    
    Dim startColumn As Integer
    Dim endColumn   As Integer
    startColumn = rng.Column
    endColumn = rng.Column + rng.Columns.Count - 1
    
    Dim currentRowNum As Integer
    Dim startCell   As Integer
    Dim endCell     As Integer
    
    Dim borderTop   As Border
    Dim borderBottom As Border
    
    Dim scanStart   As Integer
    Dim scanEnd     As Integer
    
    REM Scan rows and extract to array
    For currentRowNum = startRow To endRow
        
        Set borderTop = Cells(currentRowNum, startColumn).Borders(xlEdgeTop)
        
        If borderTop.LineStyle = xlContinuous Then
            scanStart = currentRowNum
            
            For i = 0 To 10
                Set borderBottom = Cells(currentRowNum + i, startColumn).Borders(xlEdgeBottom)
                
                If borderBottom.LineStyle = xlContinuous Then
                    scanEnd = currentRowNum + i
                    currentRowNum = currentRowNum + i
                    GoTo scanComplete
                End If
            Next i
            
            scanComplete:
            Dim result(1 To 200, 1 To 200) As String
            
            For c = startColumn To endColumn
                For r = scanStart To scanEnd
                    If result(scanStart, c) = "" Then
                        result(scanStart, c) = Cells(r, c).Text
                    Else
                        
                        result(scanStart, c) = result(scanStart, c) + Cells(r, c).Text
                    End If
                Next r
            Next c
            
        End If
        
    Next currentRowNum
    
    REM Create sheet based on extracted array
	Sheets.Add After:=Sheets(Sheets.Count)
    
    Dim r2          As Integer
    Dim c2          As Integer
    Dim data        As String
    
    r2 = 1
    c2 = 1
    
    For c1 = startColumn To endColumn
        For r1 = startRow To endRow
            data = result(r1, c1)
            If data = vbNullString Or data = "" Or Len(data) = 0 Then
            Else
                Cells(r2, c2).Value = result(r1, c1)
                r2 = r2 + 1
            End If
        Next r1
        r2 = 1
        c2 = c2 + 1
    Next c1
    
    With ActiveSheet
        .Columns("A:I").AutoFit
    End With
End Sub