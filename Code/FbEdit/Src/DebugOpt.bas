

#Include Once "windows.bi"
#Include Once "win\commdlg.bi"

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAProperty.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\GenericOpt.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\Language.bi"
#Include Once "Inc\Misc.bi"

#Include Once "Inc\DebugOpt.bi"


Function DebugOptDlgProc(ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
	Dim As Long id, Event
	Dim ofn As OPENFILENAME

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_DLG_DEBUGOPTION)
			CenterOwner(hWin)
			SetDlgItemText(hWin,IDC_EDTDEBUGOPT,@ad.smakerundebug)
			SetDlgItemText(hWin,IDC_EDTQUICKRUN,@ad.smakequickrun)
			'
		Case WM_CLOSE
			EndDialog(hWin, 0)
			'
		Case WM_COMMAND
			id=LoWord(wParam)
			Event=HiWord(wParam)
			Select Case id
				Case IDOK
					GetDlgItemText(hWin,IDC_EDTDEBUGOPT,@ad.smakerundebug,SizeOf(ad.smakerundebug))
					WritePrivateProfileString(StrPtr("Debug"),StrPtr("Debug"),@ad.smakerundebug,@ad.IniFile)
					GetDlgItemText(hWin,IDC_EDTQUICKRUN,@ad.smakequickrun,SizeOf(ad.smakequickrun))
					WritePrivateProfileString(StrPtr("Make"),StrPtr("QuickRun"),@ad.smakequickrun,@ad.IniFile)
					EndDialog(hWin, 0)
					'
				Case IDCANCEL
					EndDialog(hWin, 0)
					'
				Case IDC_BTNDEBUGOPT
					'RtlZeroMemory(@ofn,SizeOf(ofn))
					ofn.lStructSize=SizeOf(ofn)
					ofn.hwndOwner=hWin
					ofn.hInstance=hInstance
					ofn.lpstrFilter=@EXEFilterString
					ofn.lpstrFile=@buff
					GetDlgItemText(hWin,IDC_EDTDEBUGOPT,@buff,256)
					ofn.nMaxFile=256
					ofn.Flags=OFN_EXPLORER Or OFN_FILEMUSTEXIST Or OFN_HIDEREADONLY Or OFN_PATHMUSTEXIST
					If GetOpenFileNameUI (@ofn) Then
						SetDlgItemText(hWin,IDC_EDTDEBUGOPT,@buff)
					EndIf
					'
				Case IDC_BTNQUICKRUN
					id = DialogBoxParam (hInstance, MAKEINTRESOURCE (IDD_DLG_GENERICOPTION), hWin, @GenericOptDlgProc, GODM_MakeOptImport)
					If id Then
						GetPrivateProfileString(StrPtr("Make"),Str(id),NULL,@buff,GOD_EntrySize,@ad.IniFile)
						SetDlgItemText hWin, IDC_EDTQUICKRUN, @buff[InStr (buff, ",")]
					EndIf
					'
			End Select
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function
