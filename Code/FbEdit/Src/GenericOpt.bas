

#Include Once "windows.bi"
#Include Once "win\commdlg.bi"

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAProperty.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\Environment.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\Language.bi"
#Include Once "Inc\Misc.bi"
#Include Once "Inc\SpecHandling.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\GenericOpt.bi"


#Define IDC_LST_ITEMS						3201
#Define IDC_EDT_ITEMNAME					3207
#Define IDC_EDT_CMDLINE						3208
#Define IDC_BTN_UP							3202
#Define IDC_BTN_DOWN						3204
#Define IDC_BTN_INSERT					    3205
#Define IDC_BTN_DELETE						3206
#Define IDC_BTN_EXPLORE						3203
#Define IDC_BTN_IMPORT						3209


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
	SetDlgItemText hWin, IDC_EDT_ITEMNAME, EntryName
	SetDlgItemText hWin, IDC_EDT_CMDLINE, EntryItem
    fListUpdate = TRUE

End Sub

Sub EditUpdate (ByVal hWin As HWND)
	
	Dim Current As Integer     = Any
	Dim pBuffB  As ZString Ptr = Any
	
    Current = SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_GETCURSEL, 0, 0)
	If Current <> LB_ERR Then
		SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_GETTEXT, Current, Cast (LPARAM, @buff)
		SplitStr buff, VK_TAB, pBuffB
    	EditSet hWin, @buff, pBuffB
	EndIf

End Sub

Sub ListUpdate (ByVal hWin As HWND)
	
	Dim i As UInteger = Any
    Dim n As Integer  = Any

    If fListUpdate Then
    	GetDlgItemText hWin, IDC_EDT_ITEMNAME, @buff, SizeOf (GOD_EntryName)
    	TrimWhiteSpace buff
    	ZStrReplaceChar @buff, Asc (","), Asc ("-")           ' forbidden char
    	n = lstrlen (buff)
    	buff[n] = VK_TAB
    	GetDlgItemText hWin, IDC_EDT_CMDLINE, @buff[n + 1], SizeOf (GOD_EntryData)
    	TrimWhiteSpace *Cast (ZString Ptr, @buff[n + 1])

    	i = SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_GETCURSEL, 0, 0)
    	If i = LB_ERR Then i = 0
    	
    	SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_DELETESTRING, i, 0
    	SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_INSERTSTRING, i, Cast (LPARAM, @buff)
    	SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_SETCURSEL, i, 0
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
	'	nInx = SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_GETCURSEL, 0, 0)
   	'	If nInx = LB_ERR Then nInx = 0
	'	x = GetPrivateProfileInt  (@"Make",     @"Module",    0,                              @ad.IniFile)
	'	GetPrivateProfileString    @"Make",     @"fbcPath",   NULL, @sItem, SizeOf (sItem),   @ad.IniFile
	'	WritePrivateProfileSection @"Make",     @buff,                                        @ad.IniFile
	'	WritePrivateProfileString  @"Make",     @"Current",         Str (nInx + 1),           @ad.IniFile
	'	WritePrivateProfileString  @"Make",     @"Module",          Str (x),                  @ad.IniFile
	'	WritePrivateProfileString  @"Make",     @"fbcPath",         @sItem,                   @ad.IniFile
	'Case GODM_MakeOptProject
	'	nInx = SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_GETCURSEL, 0, 0)
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
        n = SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_GETTEXT, i - 1, Cast (LPARAM, @buff))
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
	'Do While SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_GETTEXT, nInx, Cast (LPARAM, @buff)) <> LB_ERR
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
	
	Dim id      As Long
	Dim Event   As Long
	Dim nInx    As Integer
	Dim nMax    As Integer
	Dim x       As Integer
	Dim sItem   As GOD_EntryName
	Dim sCmd    As GOD_EntryData
	Dim CmdLine As ZString * (32 * 1024)
	Dim ArgList As ZString * MAX_PATH
	Dim pBuff   As ZString Ptr
	Dim ofn     As OPENFILENAME
    Dim i       As Integer               = Any
    Dim n       As Integer               = Any
    Dim Success As BOOL                  = Any
    Dim TabStop As Const Integer         = 140     ' separates name and command (listbox width)

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_DLG_GENERICOPTION)
			CenterOwner(hWin)
			SendDlgItemMessage hWin, IDC_EDT_ITEMNAME, EM_LIMITTEXT, SizeOf (sItem), 0
			SendDlgItemMessage hWin, IDC_EDT_CMDLINE,  EM_LIMITTEXT, SizeOf (sCmd) , 0
    		SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_SETTABSTOPS, 1, Cast (LPARAM, @TabStop)
    		
			SendDlgItemMessage hWin, IDC_BTN_UP  , BM_SETIMAGE, IMAGE_ICON, Cast (LPARAM, ImageList_GetIcon (ah.hmnuiml, 2, ILD_NORMAL))
			SendDlgItemMessage hWin, IDC_BTN_DOWN, BM_SETIMAGE, IMAGE_ICON, Cast (LPARAM, ImageList_GetIcon (ah.hmnuiml, 3, ILD_NORMAL))
			nType = lParam
			Select Case nType
			Case GODM_ToolsMenu
				buff=GetInternalString(IS_TOOLS_MENU_OPTION)
			Case GODM_HelpMenu
				buff=GetInternalString(IS_HELP_MENU_OPTION)
			Case GODM_MakeOptCollection
				buff=GetInternalString(IS_BUILD_OPTIONS)
			Case GODM_MakeOptProject
				buff=GetInternalString(IS_PROJECT_BUILD_OPTIONS)
				ShowDlgItem (hWin, IDC_BTN_IMPORT, SW_SHOW)
			Case GODM_MakeOptImport
				buff=GetInternalString(IS_IMPORT_BUILD_OPTION)
				ShowDlgItem (hWin, IDC_BTN_INSERT, SW_HIDE)
				ShowDlgItem (hWin, IDC_BTN_DELETE, SW_HIDE)
				ShowDlgItem (hWin, IDC_BTN_DOWN, SW_HIDE)
				ShowDlgItem (hWin, IDC_BTN_UP, SW_HIDE)
				EnableDlgItem(hWin,IDC_EDT_CMDLINE,FALSE)
				EnableDlgItem(hWin,IDC_EDT_ITEMNAME,FALSE)
				EnableDlgItem(hWin,IDC_BTN_EXPLORE,FALSE)
			Case GODM_RegExLib
			    buff = GetInternalString (IS_REGEX_LIB)
   				ShowDlgItem (hWin, IDC_BTN_EXPLORE, SW_HIDE)          ' remove explore button
			Case GODM_MakeOptModule
				buff=GetInternalString(IS_MODULE_BUILD_OPTIONS)
				ShowDlgItem (hWin, IDC_BTN_IMPORT, SW_SHOW)
			End Select
			SetWindowText(hWin,@buff)
			
			i = 1
			Do
				Select Case nType
				Case GODM_ToolsMenu
					GetPrivateProfileString @"Tools", Str (i), NULL, @buff,SizeOf (sCmd), @ad.IniFile
				Case GODM_HelpMenu
					GetPrivateProfileString @"Help", Str (i), NULL, @buff, SizeOf (sCmd), @ad.IniFile
				Case GODM_MakeOptCollection, GODM_MakeOptImport
					GetPrivateProfileString @"Make", Str (i), NULL, @buff, SizeOf (sCmd), @ad.IniFile
				Case GODM_MakeOptProject, GODM_MakeOptModule
					GetPrivateProfileString @"Make", Str (i), NULL, @buff, SizeOf (sCmd), @ad.ProjectFile
				Case GODM_RegExLib
				    GetPrivateProfileString @"RegExLib", Str (i), NULL, @buff, SizeOf (sCmd), @ad.IniFile
				End Select

				If IsZStrNotEmpty (buff) Then
	    			ReplaceChar1stHit buff, Asc (","), VK_TAB
					SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_ADDSTRING, 0, Cast (LPARAM, @buff)
				Else
				    Exit Do
				EndIf
			    i += 1
			Loop
			
			Select Case nType
			Case GODM_MakeOptCollection
				nInx = GetPrivateProfileInt (@"Make", @"Current", 1, @ad.IniFile) - 1
			Case GODM_MakeOptProject
				nInx = GetPrivateProfileInt (@"Make", @"Current", 1, @ad.ProjectFile) - 1
			Case Else
			    nInx = 0
			End Select

			SendDlgItemMessage(hWin,IDC_LST_ITEMS,LB_SETCURSEL,nInx,0)
			EditUpdate(hWin)
			'
		Case WM_CLOSE
			EndDialog hWin, 0
			'
		Case WM_COMMAND
			id    = LoWord (wParam)
			Event = HiWord (wParam)
			Select Case Event
				Case BN_CLICKED
					Select Case id
						Case IDOK
							GenericOptSave hWin
							i = SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_GETCURSEL, 0, 0)
							EndDialog hWin, i + 1
							'Select Case nType
							'Case GODM_MakeOptImport
							'	nInx=SendDlgItemMessage(hWin,IDC_LST_ITEMS,LB_GETCURSEL,0,0)
							'	EndDialog(hWin,nInx+1)
							'Case GODM_RegExLib
							'    GenericOptSave hWin
					    	'	GetDlgItemText hWin, IDC_EDT_CMDLINE, @buff, SizeOf (sCmd)
                            '    EndDialog hWin, Cast (Integer, @buff)
							'Case Else
							'	GenericOptSave hWin
							'	nInx = SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_GETCURSEL, 0, 0)
							'	EndDialog hWin, nInx + 1
							'End Select
							'
						Case IDCANCEL
                			EndDialog hWin, 0
							'
					    Case IDC_BTN_UP
							i = SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_GETCURSEL, 0, 0)
							If i > 0 Then
								SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_GETTEXT, i, Cast (LPARAM, @buff)
								SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_DELETESTRING, i, 0
								i -= 1
								SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_INSERTSTRING, i, Cast (LPARAM, @buff)
								SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_SETCURSEL, i, 0
							EndIf
							'
					    Case IDC_BTN_DOWN
							i = SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_GETCURSEL, 0, 0)
							n = SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_GETCOUNT , 0, 0)
							If i < (n - 1) Then
								SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_GETTEXT, i, Cast (LPARAM, @buff)
								SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_DELETESTRING, i, 0
								i += 1
								SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_INSERTSTRING, i, Cast (LPARAM, @buff)
								SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_SETCURSEL, i, 0
							EndIf
							'
					    Case IDC_BTN_IMPORT
							n = SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_GETCOUNT, 0, 0)
							If n < GOD_MaxItems Then
    							x = nType
    							i = DialogBoxParam (hInstance, MAKEINTRESOURCE (IDD_DLG_GENERICOPTION), hWin, @GenericOptDlgProc, GODM_MakeOptImport)
    							nType = x
							    If i Then
    								GetPrivateProfileString @"Make", Str (i), NULL, @buff, GOD_EntrySize, @ad.IniFile
									ReplaceChar1stHit buff, Asc (","), VK_TAB
    								i = SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_GETCURSEL, 0, 0)
    								If i = LB_ERR Then i = 0
    								SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_INSERTSTRING, i, Cast (LPARAM, @buff)
    								SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_SETCURSEL, i, 0
    								EditUpdate hWin
    							EndIf
							Else
							    TextToOutput "*** no more space ***", &hFFFFFFFF
							EndIf
							'
					    Case IDC_BTN_INSERT
							i = SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_GETCOUNT, 0, 0)
							If i < GOD_MaxItems Then
    							nInx = SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_GETCURSEL, 0, 0)
    							If nInx = LB_ERR Then nInx = 0
    							SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_INSERTSTRING, nInx, Cast (LPARAM, @!"\t")
    							SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_SETCURSEL, nInx, 0
    							SetDlgItemText hWin, IDC_EDT_CMDLINE, @""
    							SetDlgItemText hWin, IDC_EDT_ITEMNAME, @""
							Else
							    TextToOutput "*** no more space ***", &hFFFFFFFF
							EndIf
							'
					    Case IDC_BTN_DELETE
							EditSet hWin, @"", @""
							i = SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_GETCURSEL, 0, 0)
							If i <> LB_ERR Then
								SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_DELETESTRING, i, 0
							    If SendDlgItemMessage (hWin, IDC_LST_ITEMS, LB_SETCURSEL, i, 0) = LB_ERR Then
									i -= 1
									SendDlgItemMessage hWin, IDC_LST_ITEMS, LB_SETCURSEL, i, 0
								EndIf
								EditUpdate hWin
							EndIf
							'
					    Case IDC_BTN_EXPLORE
							
							GetDlgItemText hWin, IDC_EDT_CMDLINE, @CmdLine, SizeOf (sCmd)
							
							Select Case nType
							Case GODM_HelpMenu
								CmdLineSubstExeUI CmdLine, hWin, @HLPFilterString
							Case Else
								CmdLineSubstExeUI CmdLine, hWin, @EXEFilterString
							End Select
							
	                        If lstrlen (CmdLine) >= SizeOf (sCmd) Then 						
                                CmdLine[SizeOf (sCmd) - 1] = 0                       ' trunc
                                TextToOutput "*** commandline too long - substitution failed ***", MB_ICONHAND
                                TextToOutput CmdLine
	                        EndIf	
							SetDlgItemText hWin, IDC_EDT_CMDLINE, @CmdLine
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
