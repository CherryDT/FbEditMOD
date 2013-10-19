

    ' example Custom Filter for FbEdit
    
    ' compile as console application
    ' locate executable to: ...\FbEdit\Custom Filter\
    ' restart FbEdit to take account
    
    
    #Include Once "showvars.bi"                   ' only for debugging, use compile option -g to activate
    
    
    ReDim TextLine (0) As String
    Dim   i            As Integer
    Dim   buffer       As String 
    

    
    ' read STDIN
    ' FbEdit pipes selected text from editor to STDIN     
    i = 0
    Open Cons For Input As #1
    Do Until Eof (1)
        Line Input #1, buffer
        If Eof (1) AndAlso buffer = "" Then       ' pipe closed while Line Input while Custom Filter is running
            DebugLog ("EOF")                      ' displayed in FbEdit's ShowVars window
            Exit Do
        Else
            i += 1
            ReDim Preserve TextLine (1 To i) As String
            TextLine (i) = buffer
        EndIf
    Loop
    Close #1


    
    ' modify data
    For i = 1 To UBound (TextLine)
        TextLine(i) = "*" + TextLine(i) + "*"     ' this example ist completly senseless,
    Next                                          ' and totally useless too!
                                                  '    should be changed to complete your task ;-)


    ' write STDOUT
    ' FbEdit will replace selected text with piped STDOUT
    Open Cons For Output As #2
    For i = 1 To UBound (TextLine)
        Print #2, TextLine(i)
    Next
    Close #2


    End 0          
    