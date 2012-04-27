
#Define IDD_BLOCKDLG							5200
#Define IDC_EDTBLOCKINSERT					5201
#Define IDC_STCBLOCKINSERT					5202

Function BlockDlgProc(ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_BLOCKDLG)
			'
		Case WM_CLOSE
			EndDialog(hWin, 0)
			'
		Case WM_COMMAND
			Select Case LoWord(wParam)
				Case IDOK
					SendDlgItemMessage(hWin,IDC_EDTBLOCKINSERT,WM_GETTEXT,SizeOf(buff),Cast(Integer,@buff))
					SendMessage(ah.hred,REM_BLOCKINSERT,0,Cast(Integer,@buff))
					EndDialog(hWin, 0)
					'
				Case IDCANCEL
					EndDialog(hWin, 0)
					'
			End Select
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function
