
#Define IDD_GOTODLG							1100
#Define IDC_LINENO							1001

Function GotoDlgProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim As Long id,Event
	Dim chrg As CHARRANGE
	Dim rect As RECT

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_GOTODLG)
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
						' Setup CHARRANGE and set selection
						chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,id,0)
						chrg.cpMax=chrg.cpMin
						SendMessage(ah.hred,EM_EXSETSEL,0,Cast(Integer,@chrg))
						' Scroll the caret into view
						SendMessage(ah.hred,EM_SCROLLCARET,0,0)
						' Set the focus
						SetFocus(ah.hred)
						' Terminate the dialog
						SendMessage(hWin,WM_CLOSE,NULL,NULL)
					Else
						' Line number too big
						MessageBeep(MB_ICONASTERISK)
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
