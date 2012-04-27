
'MenuOption.dlg
#Define IDD_DLGOPTMNU						3200
#Define IDC_LSTME								3201
#Define IDC_EDTMEITEM						3207
#Define IDC_EDTMECMND						3208
#Define IDC_BTNMEU							3202
#Define IDC_BTNMED							3204
#Define IDC_BTNMEADD							3205
#Define IDC_BTNMEDEL							3206
#Define IDC_BTNMFILE							3203
#Define IDC_BTNIMPORT						3209

Dim Shared fUpdate As Boolean
Dim Shared nType As Integer

Sub ClearMenu(ByVal hSubMenu As HMENU,ByVal nID As Integer)

	For nID=nID To nID+20
		DeleteMenu(hSubMenu,nID,MF_BYCOMMAND)
	Next nID

End Sub

Sub SetToolMenu(ByVal hWin As HWND)
	Dim hSubMnu As HMENU
	Dim nInx As Integer
	Dim nID As Integer
	Dim sItem As ZString*32
	Dim x As Integer
	Dim mii As MENUITEMINFO

	mii.cbSize=SizeOf(MENUITEMINFO)
	mii.fMask=MIIM_SUBMENU
	GetMenuItemInfo(ah.hmenu,10151,FALSE,@mii)
	hSubMnu=mii.hSubMenu
	nID=11000
	ClearMenu(hSubMnu,nID)
	nInx=1
	Do While nInx<20
		GetPrivateProfileString(StrPtr("Tools"),Str(nInx),@szNULL,@buff,260,@ad.IniFile)
		If Len(buff) Then
			x=InStr(buff,",")
			buff=Left(buff,x-1)
			If buff="-" Then
				AppendMenu(hSubMnu,MF_SEPARATOR,nID,@szNULL)
			Else
				AppendMenu(hSubMnu,MF_STRING,nID,@buff)
			EndIf
			nID=nID+1
		EndIf
		nInx=nInx+1
	Loop

End Sub

Sub SetHelpMenu(ByVal hWin As HWND)
	Dim hSubMnu As HMENU
	Dim nInx As Integer
	Dim nID As Integer
	Dim sItem As ZString*32
	Dim x As Integer
	Dim mii As MENUITEMINFO

	mii.cbSize=SizeOf(MENUITEMINFO)
	mii.fMask=MIIM_SUBMENU
	GetMenuItemInfo(ah.hmenu,10181,FALSE,@mii)
	hSubMnu=mii.hSubMenu
	nID=12000
	ClearMenu(hSubMnu,nID)
	nInx=1
	Do While nInx<20
		GetPrivateProfileString(StrPtr("Help"),Str(nInx),@szNULL,@buff,256,@ad.IniFile)
		If Len(buff) Then
			x=InStr(buff,",")
			buff=Left(buff,x-1)
			If buff="-" Then
				AppendMenu(hSubMnu,MF_SEPARATOR,nID,@szNULL)
			Else
				AppendMenu(hSubMnu,MF_STRING,nID,@buff)
			EndIf
			nID=nID+1
		EndIf
		nInx=nInx+1
	Loop

End Sub

Sub EditGet(ByVal hWin As HWND)
	Dim nInx As Integer
	Dim tmp As ZString*260

	nInx=SendDlgItemMessage(hWin,IDC_LSTME,LB_GETCURSEL,0,0)
	If nInx<>LB_ERR Then
		SendDlgItemMessage(hWin,IDC_LSTME,LB_GETTEXT,nInx,Cast(Integer,@buff))
		nInx=InStr(buff,Chr(9))
		tmp=Mid(buff,nInx+1)
		SendDlgItemMessage(hWin,IDC_EDTMECMND,WM_SETTEXT,0,Cast(Integer,@tmp))
		buff=Left(buff,nInx-1)
		SendDlgItemMessage(hWin,IDC_EDTMEITEM,WM_SETTEXT,0,Cast(Integer,@buff))
	EndIf

End Sub

Sub EditUpdate(ByVal hWin As HWND)
	Dim nInx As Integer

	If fUpdate Then
		GetDlgItemText(hWin,IDC_EDTMEITEM,@buff,32)
		buff=buff & Chr(9)
		GetDlgItemText(hWin,IDC_EDTMECMND,@s,256)
		lstrcat(@buff,@s)
		nInx=SendDlgItemMessage(hWin,IDC_LSTME,LB_GETCURSEL,0,0)
		If nInx=LB_ERR Then
			nInx=0
		EndIf
		SendDlgItemMessage(hWin,IDC_LSTME,LB_DELETESTRING,nInx,0)
		SendDlgItemMessage(hWin,IDC_LSTME,LB_INSERTSTRING,nInx,Cast(Integer,@buff))
		SendDlgItemMessage(hWin,IDC_LSTME,LB_SETCURSEL,nInx,0)
	EndIf

End Sub

Sub MenuOptionSave(ByVal hWin As HWND)
	Dim nInx As Integer
	Dim nID As Integer
	Dim x As Integer
	Dim sItem As ZString*260
	Dim sItem2 As ZString*260

	buff=String(32,0)
	If nType=1 Then
		WritePrivateProfileSection(StrPtr("Tools"),@buff,@ad.IniFile)
	ElseIf nType=2 Then
		WritePrivateProfileSection(StrPtr("Help"),@buff,@ad.IniFile)
		WritePrivateProfileString(Strptr("Help"),Strptr("Path"),@ad.HelpPath,@ad.IniFile)
	ElseIf nType=3 Then
		GetPrivateProfileString(StrPtr("Make"),StrPtr("fbcPath"),@szNULL,@sItem,SizeOf(sItem),@ad.IniFile)
		GetPrivateProfileString(StrPtr("Make"),StrPtr("Module"),StrPtr("Module Build,fbc -c"),@sItem2,SizeOf(sItem2),@ad.IniFile)
		WritePrivateProfileSection(StrPtr("Make"),@buff,@ad.IniFile)
		WritePrivateProfileString(StrPtr("Make"),StrPtr("fbcPath"),@sItem,@ad.IniFile)
		WritePrivateProfileString(StrPtr("Make"),StrPtr("Module"),@sItem2,@ad.IniFile)
		nInx=SendDlgItemMessage(hWin,IDC_LSTME,LB_GETCURSEL,0,0)
		WritePrivateProfileString(StrPtr("Make"),StrPtr("Current"),Str(nInx+1),@ad.IniFile)
	ElseIf nType=4 Then
		GetPrivateProfileString(StrPtr("Make"),StrPtr("Module"),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
		x=GetPrivateProfileInt(StrPtr("Make"),StrPtr("Recompile"),0,@ad.ProjectFile)
		WritePrivateProfileSection(StrPtr("Make"),@buff,@ad.ProjectFile)
		WritePrivateProfileString(StrPtr("Make"),StrPtr("Module"),@sItem,@ad.ProjectFile)
		WritePrivateProfileString(StrPtr("Make"),StrPtr("Recompile"),Str(x),@ad.ProjectFile)
		nInx=SendDlgItemMessage(hWin,IDC_LSTME,LB_GETCURSEL,0,0)
		WritePrivateProfileString(StrPtr("Make"),StrPtr("Current"),Str(nInx+1),@ad.ProjectFile)
	EndIf
	nInx=0
	nID=1
	Do While SendDlgItemMessage(hWin,IDC_LSTME,LB_GETTEXT,nInx,Cast(Integer,@buff))<>LB_ERR
		If Len(buff) Then
			x=InStr(buff,Chr(9))
			buff[x-1]=Asc(",")
			If nType=1 Then
				WritePrivateProfileString(StrPtr("Tools"),Str(nID),@buff,@ad.IniFile)
			ElseIf nType=2 Then
				WritePrivateProfileString(StrPtr("Help"),Str(nID),@buff,@ad.IniFile)
			ElseIf nType=3 Then
				WritePrivateProfileString(StrPtr("Make"),Str(nID),@buff,@ad.IniFile)
			ElseIf nType=4 Then
				WritePrivateProfileString(StrPtr("Make"),Str(nID),@buff,@ad.ProjectFile)
			EndIf
			nID=nID+1
		EndIf
		nInx=nInx+1
	Loop
	If nType=1 Then
		SetToolMenu(ah.hwnd)
		CallAddins(ah.hwnd,AIM_MENUREFRESH,0,0,HOOK_MENUREFRESH)
	ElseIf nType=2 Then
		SetHelpMenu(ah.hwnd)
		CallAddins(ah.hwnd,AIM_MENUREFRESH,0,0,HOOK_MENUREFRESH)
	ElseIf nType=3 Then
		GetMakeOption
	ElseIf nType=4 Then
		GetMakeOption
	EndIf

End Sub

Function MenuOptionDlgProc(ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
	Dim As Long id, Event
	Dim nInx As Integer
	Dim x As Integer
	Dim sItem As ZString*32
	Dim ofn As OPENFILENAME

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_DLGOPTMNU)
			CenterOwner(hWin)
			SendDlgItemMessage(hWin,IDC_EDTMEITEM,EM_LIMITTEXT,32,0)
			SendDlgItemMessage(hWin,IDC_EDTMECMND,EM_LIMITTEXT,128,0)
			nInx=120
			SendDlgItemMessage(hWin,IDC_LSTME,LB_SETTABSTOPS,1,Cast(Integer,@nInx))
			SendDlgItemMessage(hWin,IDC_BTNMEU,BM_SETIMAGE,IMAGE_ICON,Cast(Integer,ImageList_GetIcon(ah.hmnuiml,2,ILD_NORMAL)))
			SendDlgItemMessage(hWin,IDC_BTNMED,BM_SETIMAGE,IMAGE_ICON,Cast(Integer,ImageList_GetIcon(ah.hmnuiml,3,ILD_NORMAL)))
			nType=lParam
			If nType=1 Then
				buff=GetInternalString(IS_TOOLS_MENU_OPTION)
			ElseIf nType=2 Then
				buff=GetInternalString(IS_HELP_MENU_OPTION)
			ElseIf nType=3 Then
				buff=GetInternalString(IS_BUILD_OPTIONS)
			ElseIf nType=4 Then
				buff=GetInternalString(IS_PROJECT_BUILD_OPTIONS)
				ShowWindow(GetDlgItem(hWin,IDC_BTNIMPORT),SW_SHOW)
			ElseIf nType=5 Then
				buff=GetInternalString(IS_IMPORT_BUILD_OPTION)
				ShowWindow(GetDlgItem(hWin,IDC_BTNMEADD),SW_HIDE)
				ShowWindow(GetDlgItem(hWin,IDC_BTNMEDEL),SW_HIDE)
				ShowWindow(GetDlgItem(hWin,IDC_BTNMED),SW_HIDE)
				ShowWindow(GetDlgItem(hWin,IDC_BTNMEU),SW_HIDE)
				EnableWindow(GetDlgItem(hWin,IDC_EDTMECMND),FALSE)
				EnableWindow(GetDlgItem(hWin,IDC_EDTMEITEM),FALSE)
				EnableWindow(GetDlgItem(hWin,IDC_BTNMFILE),FALSE)
			EndIf
			SetWindowText(hWin,@buff)
			nInx=1
			Do While nInx<20
				sItem=Str(nInx)
				If nType=1 Then
					GetPrivateProfileString(StrPtr("Tools"),@sItem,@szNULL,@buff,260,@ad.IniFile)
				ElseIf nType=2 Then
					GetPrivateProfileString(StrPtr("Help"),@sItem,@szNULL,@buff,260,@ad.IniFile)
				ElseIf nType=3 Then
					GetPrivateProfileString(StrPtr("Make"),@sItem,@szNULL,@buff,260,@ad.IniFile)
				ElseIf nType=4 Then
					GetPrivateProfileString(StrPtr("Make"),@sItem,@szNULL,@buff,260,@ad.ProjectFile)
				ElseIf nType=5 Then
					GetPrivateProfileString(StrPtr("Make"),@sItem,@szNULL,@buff,260,@ad.IniFile)
				EndIf
				If Len(buff) Then
					x=InStr(buff,",")
					buff[x-1]=9
					SendDlgItemMessage(hWin,IDC_LSTME,LB_ADDSTRING,0,Cast(Integer,@buff))
				EndIf
				nInx=nInx+1
			Loop
			nInx=0
			If nType=3 Then
				nInx=GetPrivateProfileInt(StrPtr("Make"),StrPtr("Current"),1,@ad.IniFile)-1
			ElseIf nType=4 Then
				nInx=GetPrivateProfileInt(StrPtr("Make"),StrPtr("Current"),1,@ad.ProjectFile)-1
			EndIf
			SendDlgItemMessage(hWin,IDC_LSTME,LB_SETCURSEL,nInx,0)
			fUpdate=FALSE
			EditGet(hWin)
			fUpdate=TRUE
			'
		Case WM_CLOSE
			EndDialog(hWin,0)
			'
		Case WM_COMMAND
			id=LoWord(wParam)
			Event=HiWord(wParam)
			Select Case Event
				Case BN_CLICKED
					Select Case id
						Case IDOK
							If nType=5 Then
								nInx=SendDlgItemMessage(hWin,IDC_LSTME,LB_GETCURSEL,0,0)
								EndDialog(hWin,nInx+1)
							Else
								MenuOptionSave(hWin)
								SendMessage(hWin,WM_CLOSE,0,0)
							EndIf
							'
						Case IDCANCEL
							SendMessage(hWin,WM_CLOSE,0,0)
							'
						Case IDC_BTNMEU
							nInx=SendDlgItemMessage(hWin,IDC_LSTME,LB_GETCURSEL,0,0)
							If nInx>0 Then
								SendDlgItemMessage(hWin,IDC_LSTME,LB_GETTEXT,nInx,Cast(Integer,@buff))
								SendDlgItemMessage(hWin,IDC_LSTME,LB_DELETESTRING,nInx,0)
								nInx=nInx-1
								SendDlgItemMessage(hWin,IDC_LSTME,LB_INSERTSTRING,nInx,Cast(Integer,@buff))
								SendDlgItemMessage(hWin,IDC_LSTME,LB_SETCURSEL,nInx,0)
							EndIf
							'
						Case IDC_BTNMED
							nInx=SendDlgItemMessage(hWin,IDC_LSTME,LB_GETCURSEL,0,0)
							If SendDlgItemMessage(hWin,IDC_LSTME,LB_GETCOUNT,0,0)-1<>nInx Then
								SendDlgItemMessage(hWin,IDC_LSTME,LB_GETTEXT,nInx,Cast(Integer,@buff))
								SendDlgItemMessage(hWin,IDC_LSTME,LB_DELETESTRING,nInx,0)
								nInx=nInx+1
								SendDlgItemMessage(hWin,IDC_LSTME,LB_INSERTSTRING,nInx,Cast(Integer,@buff))
								SendDlgItemMessage(hWin,IDC_LSTME,LB_SETCURSEL,nInx,0)
							EndIf
							'
						Case IDC_BTNIMPORT
							x=nType
							nInx=DialogBoxParam(hInstance,Cast(ZString Ptr,IDD_DLGOPTMNU),hWin,@MenuOptionDlgProc,5)
							nType=x
							If nInx Then
								GetPrivateProfileString(StrPtr("Make"),Str(nInx),@szNULL,@buff,260,@ad.IniFile)
								x=InStr(buff,",")
								buff[x-1]=9
								nInx=SendDlgItemMessage(hWin,IDC_LSTME,LB_GETCURSEL,0,0)
								If nInx=LB_ERR Then
									nInx=0
								EndIf
								SendDlgItemMessage(hWin,IDC_LSTME,LB_INSERTSTRING,nInx,Cast(Integer,@buff))
								SendDlgItemMessage(hWin,IDC_LSTME,LB_SETCURSEL,nInx,0)
								fUpdate=FALSE
								EditGet(hWin)
								fUpdate=TRUE
							EndIf
							'
						Case IDC_BTNMEADD
							nInx=SendDlgItemMessage(hWin,IDC_LSTME,LB_GETCURSEL,0,0)
							If nInx=LB_ERR Then
								nInx=0
							EndIf
							buff=Chr(9) & szNULL
							SendDlgItemMessage(hWin,IDC_LSTME,LB_INSERTSTRING,nInx,Cast(Integer,@buff))
							SendDlgItemMessage(hWin,IDC_LSTME,LB_SETCURSEL,nInx,0)
							SendDlgItemMessage(hWin,IDC_EDTMECMND,WM_SETTEXT,0,Cast(Integer,StrPtr("")))
							SendDlgItemMessage(hWin,IDC_EDTMEITEM,WM_SETTEXT,0,Cast(Integer,StrPtr("")))
							'
						Case IDC_BTNMEDEL
							fUpdate=FALSE
							SendDlgItemMessage(hWin,IDC_EDTMECMND,WM_SETTEXT,0,Cast(Integer,StrPtr("")))
							SendDlgItemMessage(hWin,IDC_EDTMEITEM,WM_SETTEXT,0,Cast(Integer,StrPtr("")))
							nInx=SendDlgItemMessage(hWin,IDC_LSTME,LB_GETCURSEL,0,0)
							If nInx<>LB_ERR Then
								SendDlgItemMessage(hWin,IDC_LSTME,LB_DELETESTRING,nInx,0)
								If SendDlgItemMessage(hWin,IDC_LSTME,LB_SETCURSEL,nInx,0)=LB_ERR Then
									nInx=nInx-1
									SendDlgItemMessage(hWin,IDC_LSTME,LB_SETCURSEL,nInx,0)
								EndIf
								EditGet(hWin)
							EndIf
							fUpdate=TRUE
							'
						Case IDC_BTNMFILE
							RtlZeroMemory(@ofn,SizeOf(ofn))
							ofn.lStructSize=SizeOf(ofn)
							ofn.hwndOwner=hWin
							ofn.hInstance=hInstance
							If nType=1 Or nType=3 Then
								ofn.lpstrFilter=@EXEFilterString
							Else
								ofn.lpstrFilter=@HLPFilterString
							EndIf
							ofn.lpstrFile=@buff
							GetDlgItemText(hWin,IDC_EDTMECMND,@buff,256)
							ofn.nMaxFile=256
							ofn.Flags=OFN_EXPLORER Or OFN_FILEMUSTEXIST Or OFN_HIDEREADONLY Or OFN_PATHMUSTEXIST
							If GetOpenFileName(@ofn) Then
								SetDlgItemText(hWin,IDC_EDTMECMND,@buff)
							EndIf
							'
					End Select
					'
				Case EN_CHANGE
					EditUpdate(hWin)
					'
				Case LBN_SELCHANGE
					fUpdate=FALSE
					EditGet(hWin)
					fUpdate=TRUE
					'
			End Select
			'
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function
