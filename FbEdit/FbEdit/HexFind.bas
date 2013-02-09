

#Include Once "windowsUR.bi"
#Include Once "win\commdlg.bi"

#Include Once "Inc\RAHexEd.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\Addins.bi"
#Include Once "Inc\Language.bi"

#Include Once "Inc\HexFind.bi"


Dim Shared fthex          As FINDTEXTEX
Dim Shared frhex          As Integer        = FR_DOWN
Dim Shared freshex        As Integer
Dim Shared hexfindbuff    As ZString * 260
Dim Shared hexreplacebuff As ZString * 260


Sub HexFind(ByVal frType As Integer)
	' Get current selection
	SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@fthex.chrg))
	' Setup find
	if frType And FR_DOWN Then
		If freshex<>-1 Then
			fthex.chrg.cpMin=(fthex.chrg.cpMin And &HFFFFFFFE)+2
		EndIf
		fthex.chrg.cpMax=-1
	Else
		If freshex<>-1 Then
			fthex.chrg.cpMin=(fthex.chrg.cpMin And &HFFFFFFFE)-2
		EndIf
		fthex.chrg.cpMax=0
	EndIf
	fthex.lpstrText=@hexfindbuff
	' Do the find
	freshex=SendMessage(ah.hred,EM_FINDTEXTEX,frType,Cast(LPARAM,@fthex))
	If freshex<>-1 Then
		' Mark the foud text
		SendMessage(ah.hred,EM_EXSETSEL,0,Cast(LPARAM,@fthex.chrgText))
		SendMessage(ah.hred,HEM_VCENTER,0,0)
	Else
		' Region searched
	EndIf

End Sub

Function HexFindDlgProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim As Integer id,Event
	Dim hCtl As HWND
	Dim rect As RECT

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_HEXFINDDLG)
			findvisible=hWin
			SetWindowPos(hWin,0,wpos.ptfind.x,wpos.ptfind.y,0,0,SWP_NOSIZE)
			If lParam Then
				PostMessage(hWin,WM_COMMAND,MAKEWPARAM(IDC_HEXBTN_REPLACE,BN_CLICKED),0)
			EndIf
			' Put text in edit boxes
			SendDlgItemMessage(hWin,IDC_HEXFINDTEXT,EM_LIMITTEXT,255,0)
			SendDlgItemMessage(hWin,IDC_HEXFINDTEXT,WM_SETTEXT,0,Cast(LPARAM,@hexfindbuff))
			SendDlgItemMessage(hWin,IDC_HEXREPLACETEXT,EM_LIMITTEXT,255,0)
			SendDlgItemMessage(hWin,IDC_HEXREPLACETEXT,WM_SETTEXT,0,Cast(LPARAM,@hexreplacebuff))
			' Set find type
			If frhex And FR_HEX Then
				CheckDlgButton(hWin,IDC_HEXRBN_HEX,BST_CHECKED)
			Else
				CheckDlgButton(hWin,IDC_HEXRBN_ASCII,BST_CHECKED)
			EndIf
			' Set find direction
			If frhex And FR_DOWN Then
				 CheckDlgButton(hWin,IDC_HEXRBN_DOWN,BST_CHECKED)
			Else
				 CheckDlgButton(hWin,IDC_HEXRBN_UP,BST_CHECKED)
			EndIf
			'
		Case WM_ACTIVATE
			'
		Case WM_COMMAND
			id=LoWord(wParam)
			Event=HiWord(wParam)
			If Event=BN_CLICKED Then
				Select Case id
					Case IDOK
						' Find the text
						HexFind(frhex)
						'
					Case IDCANCEL
						SendMessage(hWin,WM_CLOSE,0,0)
						'
					Case IDC_HEXBTN_REPLACE
						hCtl=GetDlgItem(hWin,IDC_HEXBTN_REPLACEALL)
						
						If IsWindowEnabled(hCtl)=FALSE Then
							' Enable Replace all button
							EnableWindow(hCtl,TRUE)
							' Set caption to Replace...
							SetWindowText(hWin,"Replace...")
							' Show replace
							
							ShowWindow(GetDlgItem(hWin,IDC_HEXREPLACESTATIC),SW_SHOWNA)
							ShowWindow(GetDlgItem(hWin,IDC_HEXREPLACETEXT),SW_SHOWNA)
						Else
							If freshex<>-1 Then
								SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@fthex.chrg))
								SendMessage(ah.hred,EM_REPLACESEL,(frhex And FR_HEX) Or 1,Cast(LPARAM,@hexreplacebuff))
								id=lstrlen(@hexreplacebuff)
								If frhex And FR_HEX Then
									id=id*2
								EndIf
								id=id-1
								fthex.chrg.cpMin=fthex.chrg.cpMin+id
								fthex.chrg.cpMax=fthex.chrg.cpMin
								SendMessage(ah.hred,EM_EXSETSEL,0,Cast(LPARAM,@fthex.chrg))
							EndIf
							HexFind(frhex)
						EndIf
						'
					Case IDC_HEXBTN_REPLACEALL
						If freshex=-1 Then
							HexFind(frhex)
						EndIf
						While freshex<>-1
							SendMessage(hWin,WM_COMMAND,MAKEWPARAM(IDC_HEXBTN_REPLACE,BN_CLICKED),0)
						Wend
						'
					Case IDC_HEXRBN_HEX
						' Set hex type
						frhex=frhex Or FR_HEX
						freshex=-1
					Case IDC_HEXRBN_ASCII
						' Set ascii type
						frhex=frhex And (-1 Xor FR_HEX)
						freshex=-1
					Case IDC_HEXRBN_DOWN
						' Set find direction to down
						frhex=frhex Or FR_DOWN
						freshex=-1
					Case IDC_HEXRBN_UP
						' Set find direction to up
						frhex=frhex And (-1 Xor FR_DOWN)
						freshex=-1
				End Select
				'
			ElseIf Event=EN_CHANGE Then
				' Update text buffers
				If id=IDC_HEXFINDTEXT Then
					SendDlgItemMessage(hWin,id,WM_GETTEXT,SizeOf(hexfindbuff),Cast(LPARAM,@hexfindbuff))
					freshex=-1
				ElseIf id=IDC_HEXREPLACETEXT Then
					SendDlgItemMessage(hWin,id,WM_GETTEXT,SizeOf(hexreplacebuff),Cast(LPARAM,@hexreplacebuff))
					freshex=-1
				EndIf
			EndIf
			'
		Case WM_CLOSE
			DestroyWindow(hWin)
			SetFocus(ah.hred)
			'
		Case WM_DESTROY
			GetWindowRect(hWin,@rect)
			wpos.ptfind.x=rect.left
			wpos.ptfind.y=rect.top
			ah.hfind=0
			findvisible=0
			'
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function
