

#Include Once "windows.bi"

#Include Once "Inc\RAProperty.bi"
#Include Once "Inc\RAEdit.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\CoTxEd.bi"
#Include Once "Inc\EditorOpt.bi"
#Include Once "Inc\Language.bi"
#Include Once "Inc\GUIHandling.bi"

#Include Once "Inc\Goto.bi"


#Define IDC_LINENO							1001



Sub Elevator (ByVal hWin As HWND, ByVal Direction As BOOL)
    
    Dim Buff             As ZString * 512
    Dim VCPos1           As Integer   = Any 
    Dim VCPos2           As Integer   = Any
    Dim LineNo           As Integer   = Any
    Dim i                As Integer   = Any
    Dim n                As Integer   = Any 
    Dim chrg             As CHARRANGE = Any 
    Dim SearchRangeStart As Integer   = Any
    Dim SearchRangeEnd   As Integer   = Any
    Dim SearchStep       As Integer   = Any
    
    GetLineUpToCaret hWin, @buff, LineNo
    
    i = 0  :  VCPos1 = 0
    Do                                                         ' get virtual caret position (expanded tabs)
        Select Case buff[i]
        Case VK_TAB
            VCPos1 = (VCPos1 \ edtopt.tabsize + 1) * edtopt.tabsize  ' next tab boarder
            i += 1
        Case 0
            Exit Do
        Case Else
            VCPos1 += 1
            i += 1
        End Select
    Loop
    
    
    Select Case Direction
    Case VK_UP   
        SearchRangeStart = LineNo - 1
        SearchRangeEnd   = 0
        SearchStep       = -1
    Case VK_DOWN    
        SearchRangeStart = LineNo + 1
        SearchRangeEnd   = SendMessage (hWin, EM_GETLINECOUNT, n, 0) - 1
        SearchStep       = +1
    End Select    

             
    For n = SearchRangeStart To SearchRangeEnd Step SearchStep
        GetLineByNo hWin, n, @buff
    
        i = 0  :  VCPos2 = 0
        Do                                                 ' get char from virtual caret pos
            Select Case buff[i]
            Case VK_TAB
                VCPos2 = (VCPos2 \ edtopt.tabsize + 1) * edtopt.tabsize 
            Case VK_SPACE
                VCPos2 += 1
            Case 0
                Exit Do                    
            Case Else
                If VCPos2 = VCPos1 Then                    ' found, stop elevating, set caret
                    SendMessage hWin, REM_SETMODE, FALSE, 0
                	
                	chrg.cpMin = SendMessage (hWin, EM_LINEINDEX, n, 0) + i     ' Setup CHARRANGE
                	chrg.cpMax = chrg.cpMin
                	
                	SendMessage hWin, EM_EXSETSEL, 0, Cast (LPARAM, @chrg)      ' set selection
                	SendMessage hWin, EM_SCROLLCARET, 0, 0                      ' Scroll the caret into view
                    Exit Sub        
                Else 
                    VCPos2 += 1
                EndIf
            End Select
            i += 1
        Loop While VCPos2 <= VCPos1
    Next
End Sub

' ==============================
' MOD 21.1.2012
Sub GotoTextLine (ByVal hWin As HWND, ByVal LineNo As Long, ByVal VCenter As BOOLEAN)
    
    Dim chrg As CHARRANGE = Any 
    
    If hWin AndAlso LineNo >= 0 Then	
        SendMessage hWin, REM_SETMODE, FALSE, 0                     ' MOD 21.1.2012    ADD
    	
    	chrg.cpMin = SendMessage (hWin, EM_LINEINDEX, LineNo, 0)    ' Setup CHARRANGE
    	chrg.cpMax = chrg.cpMin
    	
    	SendMessage hWin, EM_EXSETSEL, 0, Cast (LPARAM, @chrg)      ' set selection
    	If VCenter Then SendMessage hWin, REM_VCENTER, 0, 0
    	SendMessage hWin, EM_SCROLLCARET, 0, 0                      ' Scroll the caret into view
    	SetFocus hWin
    EndIf

End Sub
'===============================

Function GotoDlgProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim As Long id,Event
	Dim chrg As CHARRANGE
	Dim rect As RECT

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_DLG_GOTO)
			gotovisible=hWin
			SetWindowPos(hWin,0,wpos.ptgoto.x,wpos.ptgoto.y,0,0,SWP_NOSIZE)
			'
		Case WM_COMMAND
			id=LoWord(wParam)
			Event=HiWord(wParam)
			If Event=BN_CLICKED Then
				If id=IDOK Then
					' Get line number
					id=GetDlgItemInt(hWin,IDC_LINENO,NULL,FALSE)-1
					If SendMessage(ah.hred,EM_GETLINECOUNT,0,0)>id And id>=0 Then
						GotoTextLine ah.hred, id, FALSE            ' MOD 21.1.2012
						' Set the focus
						SetFocus(ah.hred)
						' Terminate the dialog
						SendMessage(hWin,WM_CLOSE,NULL,NULL)
					Else
						' Line number too big
						TextToOutput "*** line number out of range ***", MB_ICONASTERISK
					EndIf
				ElseIf id=2 Then
					' Terminate the dialog
					SendMessage(hWin,WM_CLOSE,NULL,NULL)
				EndIf
			EndIf
			'
		Case WM_ACTIVATE
			If wParam<>WA_INACTIVE Then
				ah.hfind=hWin
			EndIf
			'
		Case WM_CLOSE
			DestroyWindow(hWin)
			SetFocus(ah.hred)
			'
		Case WM_DESTROY
			GetWindowRect(hWin,@rect)
			wpos.ptgoto.x=rect.left
			wpos.ptgoto.y=rect.top
			ah.hfind=0
			gotovisible=0
			'
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function
