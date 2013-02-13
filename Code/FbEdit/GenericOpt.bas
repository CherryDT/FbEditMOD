

#Include Once "windows.bi"
#Include Once "win\commdlg.bi"

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAProperty.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\Language.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\GenericOpt.bi"


#Define IDC_LSTME							3201
#Define IDC_EDTMEITEM						3207
#Define IDC_EDTMECMND						3208
#Define IDC_BTNMEU							3202
#Define IDC_BTNMED							3204
#Define IDC_BTNMEADD						3205
#Define IDC_BTNMEDEL						3206
#Define IDC_BTNMFILE						3203
#Define IDC_BTNIMPORT						3209


Dim Shared fListUpdate As Boolean
Dim Shared nType       As Integer


'Sub ClearMenu(ByVal hSubMenu As HMENU,ByVal nID As Integer)
'
'	For nID=nID To nID+20
'		DeleteMenu(hSubMenu,nID,MF_BYCOMMAND)
'	Next 
'
'End Sub

'Sub SetToolMenu(ByVal hWin As HWND)
'	Dim hSubMnu As HMENU
'	Dim nInx As Integer = Any 
'	Dim nID As Integer  = Any 
'	Dim sItem As GOD_EntryName 
'	Dim x As Integer
'	Dim mii As MENUITEMINFO
'
'	mii.cbSize=SizeOf(MENUITEMINFO)
'	mii.fMask=MIIM_SUBMENU
'	GetMenuItemInfo(ah.hmenu,IDM_TOOLS,FALSE,@mii)
'	hSubMnu=mii.hSubMenu
'	nID=11000
'	ClearMenu(hSubMnu,nID)
'
'	For nInx = 1 To 19
'		GetPrivateProfileString @"Tools", Str (nInx), NULL, @buff, EntrySize, @ad.IniFile
'		If IsZStrNotEmpty (buff) Then
'			x=InStr(buff,",")
'            If x Then buff[x - 1] = NULL             ' MOD 3.3.2012   buff=Left(buff,x-1)
'			If buff="-" Then
'				AppendMenu(hSubMnu,MF_SEPARATOR,nID,@szNULL)
'			Else
'				AppendMenu(hSubMnu,MF_STRING,nID,@buff)
'			EndIf
'			nID += 1
'		EndIf
'	Next 
'
'End Sub

'Sub SetHelpMenu(ByVal hWin As HWND)
'	Dim hSubMnu As HMENU
'	Dim nInx As Integer
'	Dim nID As Integer
'	Dim sItem As ZString*32
'	Dim x As Integer
'	Dim mii As MENUITEMINFO
'
'	mii.cbSize=SizeOf(MENUITEMINFO)
'	mii.fMask=MIIM_SUBMENU
'	GetMenuItemInfo(ah.hmenu,IDM_HELP,FALSE,@mii)
'	hSubMnu=mii.hSubMenu
'	nID=12000
'	ClearMenu(hSubMnu,nID)
'	nInx=1
'	Do While nInx<20
'		GetPrivateProfileString(StrPtr("Help"),Str(nInx),NULL,@buff,256,@ad.IniFile)
'		If IsZStrNotEmpty (buff) Then
'			x=InStr(buff,",")
'            If x Then buff[x - 1] = NULL             ' MOD 3.3.2012   buff=Left(buff,x-1)
'			If buff="-" Then
'				AppendMenu(hSubMnu,MF_SEPARATOR,nID,@szNULL)
'			Else
'				AppendMenu(hSubMnu,MF_STRING,nID,@buff)
'			EndIf
'			nID=nID+1
'		EndIf
'		nInx=nInx+1
'	Loop
'
'End Sub

Sub EditSet (ByVal hWin As HWND, ByVal EntryName As ZString Ptr, ByVal EntryItem As ZString Ptr)

	fListUpdate = FALSE                  
	SetDlgItemText hWin, IDC_EDTMEITEM, EntryName
	SetDlgItemText hWin, IDC_EDTMECMND, EntryItem
    fListUpdate = TRUE
    
End Sub

Sub EditUpdate (ByVal hWin As HWND)
	
	Dim Current As Integer     = Any
	Dim pBuffB  As ZString Ptr = Any 
	    
    Current = SendDlgItemMessage (hWin, IDC_LSTME, LB_GETCURSEL, 0, 0)
	If Current <> LB_ERR Then
		SendDlgItemMessage hWin, IDC_LSTME, LB_GETTEXT, Current, Cast (LPARAM, @buff)
		SplitStr buff, VK_TAB, pBuffB
    	EditSet hWin, @buff, pBuffB
	EndIf

End Sub

Sub ListUpdate (ByVal hWin As HWND)
	
	Dim i As UInteger = Any 
    Dim n As Integer  = Any 
    
    If fListUpdate Then 
    	GetDlgItemText hWin, IDC_EDTMEITEM, @buff, SizeOf (GOD_EntryName)
    	TrimWhiteSpace buff
    	ZStrReplaceChar @buff, Asc (","), Asc ("-")           ' forbidden char
    	n = lstrlen (buff)
    	buff[n] = VK_TAB
    	GetDlgItemText hWin, IDC_EDTMECMND, @buff[n + 1], SizeOf (GOD_EntryData)
    	TrimWhiteSpace buff[n + 1]
    
    	i = SendDlgItemMessage (hWin, IDC_LSTME, LB_GETCURSEL, 0, 0)
    	If i = LB_ERR Then i = 0
    	
    	SendDlgItemMessage hWin, IDC_LSTME, LB_DELETESTRING, i, 0
    	SendDlgItemMessage hWin, IDC_LSTME, LB_INSERTSTRING, i, Cast (LPARAM, @buff)
    	SendDlgItemMessage hWin, IDC_LSTME, LB_SETCURSEL, i, 0
    EndIf 

End Sub

Sub GenericOptSave (ByVal hWin As HWND)
	
	'Dim nInx     As Integer     = Any 
	'Dim nID      As Integer     = Any 
	'Dim x        As Integer     = Any 
	'Dim y        As Integer     = Any  
	Dim n        As Integer     = Any 
	Dim i        As Integer     = Any  
	Dim pSection As ZString Ptr = Any 
	Dim pFile    As ZString Ptr = Any
    Dim pBuff    As ZString Ptr = Any
	'Dim sItem    As ZString * GOD_EntrySize
	'Dim sItem2   As ZString * GOD_EntrySize
	'Dim sItem3   As ZString * GOD_EntrySize
	
	'buff[0] = 0                   ' empty array of zstrings
	'buff[1] = 0

	'Select Case nType
	'Case GODM_ToolsMenu 
	'	WritePrivateProfileSection @"Tools",    @buff,                                        @ad.IniFile
	'Case GODM_HelpMenu 
	'	GetPrivateProfileString    @"Help",     @"F1",        NULL, @sItem,  SizeOf (sItem),  @ad.IniFile
	'	GetPrivateProfileString    @"Help",     @"CtrlF1",    NULL, @sItem2, SizeOf (sItem2), @ad.IniFile
	'	GetPrivateProfileString    @"Help",     @"FbEdit",    NULL, @sItem3, SizeOf (sItem3), @ad.IniFile
	'	WritePrivateProfileSection @"Help",     @buff,                                        @ad.IniFile
	'	WritePrivateProfileString  @"Help",     @"Path",            @ad.HelpPath,             @ad.IniFile
	'	WritePrivateProfileString  @"Help",     @"F1",              @sItem,                   @ad.IniFile
	'	WritePrivateProfileString  @"Help",     @"CtrlF1",          @sItem2,                  @ad.IniFile
	'	WritePrivateProfileString  @"Help",     @"FbEdit",          @sItem3,                  @ad.IniFile
	'Case GODM_MakeOptCollection 
	'	nInx = SendDlgItemMessage (hWin, IDC_LSTME, LB_GETCURSEL, 0, 0)
   	'	If nInx = LB_ERR Then nInx = 0
	'	x = GetPrivateProfileInt  (@"Make",     @"Module",    0,                              @ad.IniFile)
	'	GetPrivateProfileString    @"Make",     @"fbcPath",   NULL, @sItem, SizeOf (sItem),   @ad.IniFile
	'	WritePrivateProfileSection @"Make",     @buff,                                        @ad.IniFile
	'	WritePrivateProfileString  @"Make",     @"Current",         Str (nInx + 1),           @ad.IniFile
	'	WritePrivateProfileString  @"Make",     @"Module",          Str (x),                  @ad.IniFile
	'	WritePrivateProfileString  @"Make",     @"fbcPath",         @sItem,                   @ad.IniFile
	'Case GODM_MakeOptProject                                                                                   
	'	nInx = SendDlgItemMessage (hWin, IDC_LSTME, LB_GETCURSEL, 0, 0)                       
	'	If nInx = LB_ERR Then nInx = 0                                                        
	'	x = GetPrivateProfileInt  (@"Make",     @"Recompile", 0,                              @ad.ProjectFile)
	'	y = GetPrivateProfileInt  (@"Make",     @"Module",    0,                              @ad.ProjectFile)
	'	WritePrivateProfileSection @"Make",     @buff,                                        @ad.ProjectFile
	'	WritePrivateProfileString  @"Make",     @"Current",         Str (nInx + 1),           @ad.ProjectFile
	'	WritePrivateProfileString  @"Make",     @"Recompile",       Str (x),                  @ad.ProjectFile
	'	WritePrivateProfileString  @"Make",     @"Module",          Str (y),                  @ad.ProjectFile
	'Case GODM_RegExLib                                                                                    
	'    WritePrivateProfileSection @"RegExLib", @buff,                                        @ad.IniFile
	'End Select
    
	Select Case nType
	Case GODM_ToolsMenu
		pSection = @"Tools"      : pFile = @ad.IniFile
	Case GODM_HelpMenu
		pSection = @"Help"       : pFile = @ad.IniFile
	Case GODM_MakeOptCollection
		pSection = @"Make"       : pFile = @ad.IniFile
	Case GODM_MakeOptProject, GODM_MakeOptModule
		pSection = @"Make"       : pFile = @ad.ProjectFile
	Case GODM_RegExLib 
	    pSection = @"RegExLib"   : pFile = @ad.IniFile
	Case Else
	    Exit Sub 
	End Select 
    
    For i = 1 To GOD_MaxItems
        n = SendDlgItemMessage (hWin, IDC_LSTME, LB_GETTEXT, i - 1, Cast (LPARAM, @buff))
        If n > 0 Then 
            pBuff = @buff
			ReplaceChar1stHit buff, VK_TAB, Asc (",")
        Else
            pBuff = 0       'removes key
        EndIf
        WritePrivateProfileString pSection, Str (i), pBuff, pFile
    Next

	'nInx=0
	'nID=1
	'Do While SendDlgItemMessage (hWin, IDC_LSTME, LB_GETTEXT, nInx, Cast (LPARAM, @buff)) <> LB_ERR
	'	If IsZStrNotEmpty (buff) Then
	'		x = InStr (buff, Chr (9))
	'		If x Then buff[x - 1] = Asc (",")
	'		Select Case nType
	'		Case GODM_ToolsMenu
	'			WritePrivateProfileString @"Tools",    Str (nID), @buff, @ad.IniFile
	'		Case GODM_HelpMenu
	'			WritePrivateProfileString @"Help",     Str (nID), @buff, @ad.IniFile
	'		Case GODM_MakeOptCollection
	'			WritePrivateProfileString @"Make",     Str (nID), @buff, @ad.IniFile
	'		Case GODM_MakeOptProject 
	'			WritePrivateProfileString @"Make",     Str (nID), @buff, @ad.ProjectFile
	'		Case GODM_RegExLib 
	'		    WritePrivateProfileString @"RegExLib", Str (nID), @buff, @ad.IniFile
	'		End Select 
	'		nID += 1
	'	EndIf
	'	nInx += 1
	'Loop
	
	'Select Case nType
	'Case GODM_ToolsMenu   
	'	'SetToolMenu(ah.hwnd)
	'	MakeSubMenu IDM_TOOLS, IDM_TOOLS_USER_1, IDM_TOOLS_USER_LAST, "Tools"
	'	CallAddins(ah.hwnd,AIM_MENUREFRESH,0,0,HOOK_MENUREFRESH)
	'Case GODM_HelpMenu
	'	'SetHelpMenu(ah.hwnd)
	'	MakeSubMenu IDM_HELP, IDM_HELP_USER_1, IDM_HELP_USER_LAST, "Help"
	'	CallAddins(ah.hwnd,AIM_MENUREFRESH,0,0,HOOK_MENUREFRESH)
	''Case GODM_MakeOptCollection, GODM_MakeOptProject
	''	GetMakeOption
	'End Select 

End Sub

Function GenericOptDlgProc(ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
	
	Dim id         As Long 
	Dim EVENT      As Long 
	Dim nInx       As Integer
	Dim x          As Integer
	Dim sItem      As GOD_EntryName
	Dim sCmd       As GOD_EntryData
	Dim ofn        As OPENFILENAME
    Dim Rect1      As RECT          = Any 
    Dim Rect2      As RECT          = Any
    Dim i          As Integer       = Any 
           
	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_DLGOPTMNU)
			CenterOwner(hWin)
			SendDlgItemMessage(hWin,IDC_EDTMEITEM,EM_LIMITTEXT,SizeOf(sItem),0)
			SendDlgItemMessage(hWin,IDC_EDTMECMND,EM_LIMITTEXT,SizeOf(sCmd),0)
			nInx=120
			SendDlgItemMessage(hWin,IDC_LSTME,LB_SETTABSTOPS,1,Cast(Integer,@nInx))
			SendDlgItemMessage(hWin,IDC_BTNMEU,BM_SETIMAGE,IMAGE_ICON,Cast(Integer,ImageList_GetIcon(ah.hmnuiml,2,ILD_NORMAL)))
			SendDlgItemMessage(hWin,IDC_BTNMED,BM_SETIMAGE,IMAGE_ICON,Cast(Integer,ImageList_GetIcon(ah.hmnuiml,3,ILD_NORMAL)))
			nType=lParam
			Select Case nType
			Case GODM_ToolsMenu 
				buff=GetInternalString(IS_TOOLS_MENU_OPTION)
			Case GODM_HelpMenu 
				buff=GetInternalString(IS_HELP_MENU_OPTION)
			Case GODM_MakeOptCollection
				buff=GetInternalString(IS_BUILD_OPTIONS)
			Case GODM_MakeOptProject 
				buff=GetInternalString(IS_PROJECT_BUILD_OPTIONS)
				ShowWindow(GetDlgItem(hWin,IDC_BTNIMPORT),SW_SHOW)
			Case GODM_MakeOptImport 
				buff=GetInternalString(IS_IMPORT_BUILD_OPTION)
				ShowWindow(GetDlgItem(hWin,IDC_BTNMEADD),SW_HIDE)
				ShowWindow(GetDlgItem(hWin,IDC_BTNMEDEL),SW_HIDE)
				ShowWindow(GetDlgItem(hWin,IDC_BTNMED),SW_HIDE)
				ShowWindow(GetDlgItem(hWin,IDC_BTNMEU),SW_HIDE)
				EnableDlgItem(hWin,IDC_EDTMECMND,FALSE)
				EnableDlgItem(hWin,IDC_EDTMEITEM,FALSE)
				EnableDlgItem(hWin,IDC_BTNMFILE,FALSE)
			Case GODM_RegExLib 
			    buff = GetInternalString (IS_REGEX_LIB)
   				ShowWindow GetDlgItem (hWin, IDC_BTNMFILE), SW_HIDE          ' remove explore button and reuse freed space
 			    GetWindowRect GetDlgItem (hWin, IDC_EDTMEITEM), @Rect1       
		        SetWindowPos GetDlgItem (hWin, IDC_EDTMECMND), HWND_TOP, 0, 0, Rect1.right - Rect1.left, Rect1.bottom - Rect1.top, SWP_NOMOVE Or SWP_NOACTIVATE
			Case GODM_MakeOptModule
				buff=GetInternalString(IS_MODULE_BUILD_OPTIONS)
				ShowWindow(GetDlgItem(hWin,IDC_BTNIMPORT),SW_SHOW)
			End Select
			SetWindowText(hWin,@buff)
			
			i = 1
			Do
				Select Case nType
				Case GODM_ToolsMenu
					GetPrivateProfileString(StrPtr("Tools"),Str(i),NULL,@buff,SizeOf(sCmd),@ad.IniFile)
				Case GODM_HelpMenu
					GetPrivateProfileString(StrPtr("Help"),Str(i),NULL,@buff,SizeOf(sCmd),@ad.IniFile)
				Case GODM_MakeOptCollection, GODM_MakeOptImport
					GetPrivateProfileString(StrPtr("Make"),Str(i),NULL,@buff,SizeOf(sCmd),@ad.IniFile)
				Case GODM_MakeOptProject, GODM_MakeOptModule 
					GetPrivateProfileString(StrPtr("Make"),Str(i),NULL,@buff,SizeOf(sCmd),@ad.ProjectFile)
				Case GODM_RegExLib
				    GetPrivateProfileString(StrPtr("RegExLib"),Str(i),NULL,@buff,SizeOf(sCmd),@ad.IniFile)
				End Select

				If IsZStrNotEmpty (buff) Then
	    			ReplaceChar1stHit buff, Asc (","), VK_TAB
					SendDlgItemMessage hWin, IDC_LSTME, LB_ADDSTRING, 0, Cast (LPARAM, @buff)
				Else
				    Exit Do
				EndIf
			    i += 1
			Loop  
			
			Select Case nType
			Case GODM_MakeOptCollection
				nInx=GetPrivateProfileInt(StrPtr("Make"),StrPtr("Current"),1,@ad.IniFile)-1
			Case GODM_MakeOptProject
				nInx=GetPrivateProfileInt(StrPtr("Make"),StrPtr("Current"),1,@ad.ProjectFile)-1
			Case Else
			    nInx=0    
			End Select

			SendDlgItemMessage(hWin,IDC_LSTME,LB_SETCURSEL,nInx,0)
			EditUpdate(hWin)
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
							GenericOptSave hWin
							nInx = SendDlgItemMessage (hWin, IDC_LSTME, LB_GETCURSEL, 0, 0)
							EndDialog hWin, nInx + 1
							'Select Case nType
							'Case GODM_MakeOptImport
							'	nInx=SendDlgItemMessage(hWin,IDC_LSTME,LB_GETCURSEL,0,0)
							'	EndDialog(hWin,nInx+1)
							'Case GODM_RegExLib
							'    GenericOptSave hWin
					    	'	GetDlgItemText hWin, IDC_EDTMECMND, @buff, SizeOf (sCmd)
                            '    EndDialog hWin, Cast (Integer, @buff)
							'Case Else
							'	GenericOptSave hWin
							'	nInx = SendDlgItemMessage (hWin, IDC_LSTME, LB_GETCURSEL, 0, 0)
							'	EndDialog hWin, nInx + 1
							'End Select
							'
						Case IDCANCEL
                			EndDialog hWin, 0
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
							i = SendDlgItemMessage (hWin, IDC_LSTME, LB_GETCOUNT, 0, 0)
							If i < GOD_MaxItems Then 
    							x=nType
    							nInx = DialogBoxParam (hInstance, MAKEINTRESOURCE (IDD_DLGOPTMNU), hWin, @GenericOptDlgProc, GODM_MakeOptImport)
    							nType=x
    							If nInx Then
    								GetPrivateProfileString(StrPtr("Make"),Str(nInx),NULL,@buff,GOD_EntrySize,@ad.IniFile)
									ReplaceChar1stHit buff, Asc (","), VK_TAB
    								nInx=SendDlgItemMessage(hWin,IDC_LSTME,LB_GETCURSEL,0,0)
    								If nInx = LB_ERR Then nInx = 0
    								SendDlgItemMessage(hWin,IDC_LSTME,LB_INSERTSTRING,nInx,Cast(Integer,@buff))
    								SendDlgItemMessage(hWin,IDC_LSTME,LB_SETCURSEL,nInx,0)
    								EditUpdate(hWin)
    							EndIf
							Else
							    TextToOutput "*** no more space ***", &hFFFFFFFF
							EndIf
							'
						Case IDC_BTNMEADD
							i = SendDlgItemMessage (hWin, IDC_LSTME, LB_GETCOUNT, 0, 0)
							If i < GOD_MaxItems Then 
    							nInx = SendDlgItemMessage (hWin, IDC_LSTME, LB_GETCURSEL, 0, 0)
    							If nInx = LB_ERR Then nInx = 0
    							SendDlgItemMessage hWin, IDC_LSTME, LB_INSERTSTRING, nInx, Cast (LPARAM, @!"\t")
    							SendDlgItemMessage hWin, IDC_LSTME, LB_SETCURSEL, nInx, 0
    							SetDlgItemText hWin, IDC_EDTMECMND, @""
    							SetDlgItemText hWin, IDC_EDTMEITEM, @""
							Else
							    TextToOutput "*** no more space ***", &hFFFFFFFF
							EndIf
							'
					Case IDC_BTNMEDEL
							EditSet hWin, @"", @""
							nInx=SendDlgItemMessage(hWin,IDC_LSTME,LB_GETCURSEL,0,0)
							If nInx<>LB_ERR Then
								SendDlgItemMessage(hWin,IDC_LSTME,LB_DELETESTRING,nInx,0)
								If SendDlgItemMessage(hWin,IDC_LSTME,LB_SETCURSEL,nInx,0)=LB_ERR Then
									nInx=nInx-1
									SendDlgItemMessage(hWin,IDC_LSTME,LB_SETCURSEL,nInx,0)
								EndIf
								EditUpdate(hWin)
							EndIf
							'
						Case IDC_BTNMFILE
							'RtlZeroMemory(@ofn,SizeOf(ofn))
							ofn.lStructSize=SizeOf(ofn)
							ofn.hwndOwner=hWin
							ofn.hInstance=hInstance
							Select Case nType
							Case GODM_HelpMenu 
								ofn.lpstrFilter=@HLPFilterString
							Case Else
								ofn.lpstrFilter=@EXEFilterString
							End Select
							ofn.lpstrFile=@buff
							GetDlgItemText(hWin,IDC_EDTMECMND,@buff,SizeOf(sCmd))
							ofn.nMaxFile=SizeOf(sCmd)
							ofn.Flags=OFN_EXPLORER Or OFN_FILEMUSTEXIST Or OFN_HIDEREADONLY Or OFN_PATHMUSTEXIST
							If GetOpenFileName(@ofn) Then
								SetDlgItemText(hWin,IDC_EDTMECMND,@buff)
							EndIf
							'
					End Select
					'
			    Case EN_CHANGE
                    ListUpdate hWin
					'
				Case LBN_SELCHANGE
					EditUpdate hWin 
					'
			End Select
			'
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function
