

    #Include Once "windowsUR.bi"
    
    #Include Once "Inc\RAHexEd.bi"
    #Include Once "Inc\RAProperty.bi"

    #Include Once "Inc\Addins.bi"
    #Include Once "Inc\FbEdit.bi"
    #Include Once "Inc\CoTxEd.bi"
    #Include Once "Inc\TabTool.bi"
    #Include Once "Inc\ZStringHandling.bi"

    #Include Once "Inc\Statusbar.bi"


    Declare Sub SbarTimerProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal idEvent As UINT, ByVal dwTime As DWORD)

    #Define IDT_STATUSBAR       300              ' timer (statusbar update intervall)

    'Const      MaxPart                   As Integer       = 6
    Dim Shared SbarParts (1 to ...)  As Integer       => { 165, 215, 240, 270, 400, -1 }    ' pixels from left



Sub SbarInit

    SetTimer ah.hwnd, IDT_STATUSBAR, 250, Cast (TIMERPROC, @SbarTimerProc)
    SendMessage ah.hsbr, SB_SETPARTS, UBound (SbarParts), Cast (LPARAM, @SbarParts(1))

End Sub 


Sub SbarSetBuildName (ByVal pBuildName As ZString Ptr)
    
    SendMessage ah.hsbr, SB_SETTEXT, 4, Cast (LPARAM, pBuildName)

End Sub

Sub SbarSetWriteMode ()

	Dim pBuffer As ZString Ptr = Any 
    Dim Mode    As Integer     = Any    

    If EditInfo.AlphaEd Then
        If EditInfo.CoTxEd Then
            Mode = SendMessage (ah.hred, REM_GETMODE, 0, 0)
        ElseIf EditInfo.HexEd Then    
            Mode = SendMessage (ah.hred, HEM_GETMODE, 0, 0)
        EndIf

        If Mode And MODE_OVERWRITE Then
	        pBuffer = @"OVR"
        Else
            pBuffer = @"INS"
        EndIf
    Else
        pBuffer = @"N/A"
    EndIf

    SendMessage ah.hsbr, SB_SETTEXT, 3 Or SBT_NOBORDERS, Cast (LPARAM, pBuffer)
    
End Sub

Sub SbarSetBlockMode ()
	
	Dim pBuffer As ZString Ptr = Any 
    Dim Mode    As Integer     = Any    

	If EditInfo.CoTxEd Then
        Mode = SendMessage (ah.hred, REM_GETMODE, 0, 0)
        If Mode And MODE_BLOCK Then
	        pBuffer = @"BLK"
        Else
            pBuffer = @"LIN"
        EndIf
    Else
        pBuffer = @"N/A"
    EndIf    
    
    SendMessage ah.hsbr, SB_SETTEXT, 2 Or SBT_NOBORDERS, Cast (LPARAM, pBuffer)

End Sub

Sub SbarLabelLockState ()
    
    Dim pBuffer As ZString Ptr = Any
    
    Select Case GetTabLockByCurrTab ()
    Case TRUE 
        pBuffer = @"LOCK"
    Case FALSE 
        pBuffer = @"UNLOCK"
    Case Else               ' INVALID_TABID
        pBuffer = @"-?-"
    End Select
    
    SendMessage ah.hsbr, SB_SETTEXT, 1 Or SBT_NOBORDERS, Cast (LPARAM, pBuffer)
    
End Sub

Sub SbarTimerProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal idEvent As UINT, ByVal dwTime As DWORD)
    
    Dim isinp          As ISINPROC
    Dim OutBuffer      As ZString * 1024 = Any 
    Dim pInBuffer      As ZString Ptr    = Any 
    Static OldLastLine As Integer        = -1 
    Static OldCaretPos As Integer        = -1
    

	If EditInfo.AlphaEd Then
		If     nLastLine <> OldLastLine _
		OrElse nCaretPos <> OldCaretPos Then
		    wsprintf @OutBuffer, @"Line: %d    Pos: %d", nLastLine + 1, nCaretPos + 1
	        SendMessage ah.hsbr, SB_SETTEXT, 0, Cast (LPARAM, @OutBuffer)
	        OldLastLine = nLastLine
	        OldCaretPos = nCaretPos
	    EndIf 
	EndIf
	
    If EditInfo.CodeEd Then
    	isinp.nLine    = nLastLine
    	isinp.lpszType = @"p"
    	isinp.nOwner   = Cast (Integer, ah.hred)

    	pInBuffer = Cast (ZString Ptr, SendMessage (ah.hpr, PRM_ISINPROC, 0, Cast (LPARAM, @isinp)))
    
    	If pInBuffer Then
            FormatFunctionName *pInBuffer, OutBuffer 
    	Else
    		SetZStrEmpty (OutBuffer) 
    	EndIf
    Else
        SetZStrEmpty (OutBuffer)
    EndIf
    SendMessage ah.hsbr, SB_SETTEXT, 5, Cast (LPARAM, @OutBuffer)


End Sub

Sub SbarClear ()
    
    SendMessage ah.hsbr, SB_SETTEXT, 0, Cast (LPARAM, @"")      ' Position
    SendMessage ah.hsbr, SB_SETTEXT, 1, Cast (LPARAM, @"")      ' LOCK / UNLOCK
    SendMessage ah.hsbr, SB_SETTEXT, 2, Cast (LPARAM, @"")      ' BLK / LIN
    SendMessage ah.hsbr, SB_SETTEXT, 3, Cast (LPARAM, @"")      ' OVR / INS
   'SendMessage ah.hsbr, SB_SETTEXT, 4, Cast (LPARAM, @"")      ' BuildName 
    SendMessage ah.hsbr, SB_SETTEXT, 5, Cast (LPARAM, @"")      ' FunctionName

End Sub
