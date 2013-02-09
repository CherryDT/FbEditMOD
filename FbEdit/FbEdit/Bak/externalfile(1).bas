

#Include Once "windowsUR.bi"
#Include Once "win\commdlg.bi"
#Include Once "win\commctrlUR.bi"
#Include Once "win\richedit.bi"

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAProperty.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\Language.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\ExternalFile.bi"



Sub SaveExternalFile(ByVal hWin As HWND)
	Dim nInx As Integer
	Dim x As Integer
	Dim sItem As ZString*260
	
	buff=String(32,0)
	WritePrivateProfileSection(StrPtr("Open"),@buff,@ad.IniFile)
	nInx=0
	x=1
	Do While TRUE                    
		If SendDlgItemMessage(hWin,IDC_LSTFILETYPE,LB_GETTEXT,nInx,Cast(Integer,@buff))=LB_ERR Then
			Exit Do
		Else
			If IsZStrNotEmpty (buff) Then
				WritePrivateProfileString(StrPtr("Open"),Str(x),@buff,@ad.IniFile)
				x=x+1
			EndIf
		EndIf
		nInx=nInx+1
	Loop

End Sub

Function ExternalFileDlgProc(ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
	Dim nInx As Integer
	Dim x As Integer
	Dim sItem As ZString*260
	Dim ofn As OPENFILENAME

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_DLGEXTERNALFILE)
			CenterOwner(hWin)
			nInx=1
			Do While TRUE
				GetPrivateProfileString(StrPtr("Open"),Str(nInx),NULL,@buff,SizeOf(buff),@ad.IniFile)
				If IsZStrNotEmpty (buff) Then
					SendDlgItemMessage(hWin,IDC_LSTFILETYPE,LB_ADDSTRING,0,Cast(Integer,@buff))
				Else
					Exit Do
				EndIf
				nInx=nInx+1
			Loop
			SendDlgItemMessage(hWin,IDC_LSTFILETYPE,LB_SETCURSEL,0,0)
			SendMessage(hWin,WM_COMMAND,MAKEWPARAM(IDC_LSTFILETYPE,LBN_SELCHANGE),0)
			'
		Case WM_CLOSE
			EndDialog(hWin, 0)
			'
		Case WM_COMMAND
			Select Case HiWord(wParam)
				Case BN_CLICKED
					Select Case LoWord(wParam)
						Case IDOK
							SaveExternalFile(hWin)
							EndDialog(hWin, 0)
							'
						Case IDCANCEL
							EndDialog(hWin, 0)
							'
						Case IDC_BTNADDFILETYPE
							nInx=SendDlgItemMessage(hWin,IDC_LSTFILETYPE,LB_GETCOUNT,0,0)
							If nInx<20 Then
								SendDlgItemMessage(hWin,IDC_LSTFILETYPE,LB_ADDSTRING,0,Cast(Integer,StrPtr("")))
								SendDlgItemMessage(hWin,IDC_LSTFILETYPE,LB_SETCURSEL,nInx,0)
								SendMessage(hWin,WM_COMMAND,MAKEWPARAM(IDC_LSTFILETYPE,LBN_SELCHANGE),0)
							EndIf
							'
						Case IDC_BTNDELETEFILETYPE
							nInx=SendDlgItemMessage(hWin,IDC_LSTFILETYPE,LB_GETCURSEL,0,0)
							If nInx<>LB_ERR Then
								SendDlgItemMessage(hWin,IDC_LSTFILETYPE,LB_DELETESTRING,nInx,0)
								If SendDlgItemMessage(hWin,IDC_LSTFILETYPE,LB_SETCURSEL,nInx,0)=LB_ERR Then
									SendDlgItemMessage(hWin,IDC_LSTFILETYPE,LB_SETCURSEL,nInx-1,0)
								EndIf
							EndIf
							SendMessage(hWin,WM_COMMAND,MAKEWPARAM(IDC_LSTFILETYPE,LBN_SELCHANGE),0)
							'
						Case IDC_BTNCOMMANDBROWSE
							ofn.lStructSize=SizeOf(ofn)
							ofn.hwndOwner=hWin
							ofn.hInstance=hInstance
							ofn.lpstrInitialDir=@ad.ProjectPath
							ofn.lpstrFilter=@EXEFilterString
							ofn.lpstrDefExt=0
							ofn.lpstrTitle=0
							ofn.lpstrFile=@buff
							GetDlgItemText(hWin,IDC_EDTCOMMAND,@buff,SizeOf(buff))
							ofn.nMaxFile=260
							ofn.Flags=OFN_EXPLORER Or OFN_FILEMUSTEXIST Or OFN_HIDEREADONLY Or OFN_PATHMUSTEXIST
							If GetOpenFileName(@ofn) Then
								SetDlgItemText(hWin,IDC_EDTCOMMAND,@buff)
							EndIf
							'
					End Select
					'
				Case LBN_SELCHANGE
					SetZStrEmpty (buff)
					nInx=SendDlgItemMessage(hWin,IDC_LSTFILETYPE,LB_GETCURSEL,0,0)
					If nInx<>LB_ERR Then
						SendDlgItemMessage(hWin,IDC_LSTFILETYPE,LB_GETTEXT,nInx,Cast(Integer,@buff))
					EndIf
					x=InStr(buff,",")
					sItem=Left(buff,x-1)
					buff=Mid(buff,x+1)
					SetDlgItemText(hWin,IDC_EDTCOMMAND,@buff)
					SetDlgItemText(hWin,IDC_EDTFILETYPE,@sItem)
					'
				Case EN_CHANGE
					GetDlgItemText(hWin,IDC_EDTFILETYPE,@buff,SizeOf(buff))
					sItem="," & szNULL
					lstrcat(@buff,@sItem)
					GetDlgItemText(hWin,IDC_EDTCOMMAND,@sItem,SizeOf(sItem))
					lstrcat(@buff,@sItem)
					nInx=SendDlgItemMessage(hWin,IDC_LSTFILETYPE,LB_GETCURSEL,0,0)
					If nInx<>LB_ERR Then
						SendDlgItemMessage(hWin,IDC_LSTFILETYPE,LB_DELETESTRING,nInx,0)
					Else
						nInx=0
					EndIf
					SendDlgItemMessage(hWin,IDC_LSTFILETYPE,LB_INSERTSTRING,nInx,Cast(Integer,@buff))
					SendDlgItemMessage(hWin,IDC_LSTFILETYPE,LB_SETCURSEL,nInx,0)
					'
			End Select
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function
