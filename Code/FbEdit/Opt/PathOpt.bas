
'PathOpt.dlg
#Define IDD_DLGPATHOPTION					5400
#Define IDC_EDTOPTCOMPILERPATH			1003
#Define IDC_EDTOPTPROJECTPATH				1005
#Define IDC_EDTOPTHELPPATH					5402
#Define IDC_BTNOPTPROJECTPATH				1007
#Define IDC_BTNOPTCOMPILERPATH			1008
#Define IDC_BTNOPTHELPPATH					5401
#Define IDC_EDTOPTINCPATH					5405
#Define IDC_BTNOPTINCPATH					5406

Function PathOptDlgProc(ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_DLGPATHOPTION)
			CenterOwner(hWin)
			GetPrivateProfileString(StrPtr("Project"),StrPtr("Path"),@szNULL,@buff,260,@ad.IniFile)
			SetDlgItemText(hWin,IDC_EDTOPTPROJECTPATH,@buff)
			GetPrivateProfileString(StrPtr("Make"),StrPtr("fbcPath"),@szNULL,@buff,260,@ad.IniFile)
			SetDlgItemText(hWin,IDC_EDTOPTCOMPILERPATH,@buff)
			GetPrivateProfileString(StrPtr("Help"),StrPtr("Path"),@szNULL,@buff,260,@ad.IniFile)
			SetDlgItemText(hWin,IDC_EDTOPTHELPPATH,@buff)
			GetPrivateProfileString(StrPtr("Include"),StrPtr("Path"),@szNULL,@buff,260,@ad.IniFile)
			SetDlgItemText(hWin,IDC_EDTOPTINCPATH,@buff)
			'
		Case WM_CLOSE
			EndDialog(hWin, 0)
			'
		Case WM_COMMAND
			Select Case LoWord(wParam)
				Case IDOK
					GetDlgItemText(hWin,IDC_EDTOPTPROJECTPATH,@ad.DefProjectPath,260)
					WritePrivateProfileString(StrPtr("Project"),StrPtr("Path"),@ad.DefProjectPath,@ad.IniFile)
					If Asc(ad.DefProjectPath)=Asc("\") Then
						ad.DefProjectPath=Left(ad.AppPath,2) & ad.DefProjectPath
					EndIf
					FixPath(ad.DefProjectPath)
					GetDlgItemText(hWin,IDC_EDTOPTCOMPILERPATH,@ad.fbcPath,260)
					WritePrivateProfileString(StrPtr("Make"),StrPtr("fbcPath"),@ad.fbcPath,@ad.IniFile)
					If Asc(ad.fbcPath)=Asc("\") Then
						ad.fbcPath=Left(ad.AppPath,2) & ad.fbcPath
					EndIf
					FixPath(ad.fbcPath)
					GetDlgItemText(hWin,IDC_EDTOPTHELPPATH,@ad.HelpPath,260)
					WritePrivateProfileString(StrPtr("Help"),StrPtr("Path"),@ad.HelpPath,@ad.IniFile)
					If Asc(ad.HelpPath)=Asc("\") Then
						ad.HelpPath=Left(ad.AppPath,2) & ad.HelpPath
					EndIf
					FixPath(ad.HelpPath)
					GetDlgItemText(hWin,IDC_EDTOPTINCPATH,@ad.IncPath,260)
					WritePrivateProfileString(StrPtr("Include"),StrPtr("Path"),@ad.IncPath,@ad.IniFile)
					If Asc(ad.IncPath)=Asc("\") Then
						ad.IncPath=Left(ad.AppPath,2) & ad.IncPath
					EndIf
					FixPath(ad.IncPath)
					GetMakeOption
					EndDialog(hWin, 0)
					'
				Case IDCANCEL
					EndDialog(hWin, 0)
					'
				Case IDC_BTNOPTPROJECTPATH
					BrowseFolder(hWin,IDC_EDTOPTPROJECTPATH)
					'
				Case IDC_BTNOPTCOMPILERPATH
					BrowseFolder(hWin,IDC_EDTOPTCOMPILERPATH)
					'
				Case IDC_BTNOPTHELPPATH
					BrowseFolder(hWin,IDC_EDTOPTHELPPATH)
					'
				Case IDC_BTNOPTINCPATH
					BrowseFolder(hwin,IDC_EDTOPTINCPATH)
					'
			End Select
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function
