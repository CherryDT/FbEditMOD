
/'	FbEdit, by KetilO

	Licence
	-------
	FbEdit and all sources are free to use in any way you see fit.
	Sources for the custom controls used by FbEdit can be found at:
	radasm.110mb.com

'/


#Include Once "windowsUR.bi"
#Include Once "win\richedit.bi"
#Include Once "win\commctrlUR.bi"
#Include Once "win\commdlg.bi"
#Include Once "win\shellapi.bi"
#Include Once "win\shlwapi.bi"
#Include Once "regexUR.bi"                                                 ' MOD 16.2.2012

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAFile.bi"
#Include Once "Inc\RAProperty.bi"
#Include Once "Inc\RACodeComplete.bi"
#Include Once "Inc\RAResEd.bi"
#Include Once "Inc\RAHexEd.bi"
#Include Once "Inc\RAGrid.bi"

#Include Once "Inc\About.bi"
#Include Once "Inc\Addins.bi" 
#Include Once "Inc\BlockInsert.bi"
#Include Once "Inc\CBH_Dialog.bi"
#Include Once "Inc\CodeComplete.bi"
#Include Once "Inc\CreateTemplate.bi"
#Include Once "Inc\DebugOpt.bi"
#Include Once "Inc\CoTxEd.bi"
#Include Once "Inc\EditorOpt.bi"
#Include Once "Inc\Environment.bi"
#Include Once "Inc\Export.bi"
#Include Once "Inc\ExternalFile.bi"
#Include Once "Inc\FileIO.bi"
#Include Once "Inc\FileMonitor.bi"
#Include Once "Inc\Find.bi"
#Include Once "Inc\GenericOpt.bi"
#Include Once "Inc\Goto.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\HexFind.bi"
#Include Once "Inc\IniFile.bi"
#Include Once "Inc\Language.bi"
#Include Once "Inc\LineQueue.bi"
#Include Once "Inc\Make.bi"
#Include Once "Inc\Misc.bi"
#Include Once "Inc\Project.bi"
#Include Once "Inc\Property.bi"
#Include Once "Inc\ResEd.bi"
#Include Once "Inc\ResEdOpt.bi"
#Include Once "Inc\SpecHandling.bi"
#Include Once "Inc\Splash.bi"
#Include Once "Inc\Statusbar.bi"
#Include Once "Inc\TabTool.bi"
#Include Once "Inc\Toolbar.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\FbEdit.bi"
#Include Once "showvarsUR.bi"

#Define IDT_GENERAL     100


Sub TimerAProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal idEvent As UINT, ByVal dwTime As DWORD)
	
	'Dim buffer As ZString*1024
	'Dim chrg As CHARRANGE
	Dim nLn As Integer = Any 
	'Dim tci As TCITEM
	'Dim isinp As ISINPROC
    
    'Dim Mode    As Integer     = Any    
    'Dim pBuffer As ZString Ptr = Any 
    
	'If nSplash Then
	'	nSplash=nSplash-1
	'	If nsplash=0 Then
	'	    SendDlgItemMessage ah.hwnd, IDC_IMGSPLASH, WM_CLOSE, 0, 0
	'	EndIf
	'	Return 0
	'EndIf
	
	If fTimer Then
		fTimer-=1
		If fTimer=0 Then
			EnableMenu
			CheckMenu
			CallAddins(hWin,AIM_MENUENABLE,0,0,HOOK_MENUENABLE)
			
			'If ah.hred Then
            '    tci.mask=TCIF_PARAM
			'	SendMessage(ah.htabtool,TCM_GETITEM,SendMessage(ah.htabtool,TCM_GETCURSEL,0,0),Cast(Integer,@tci))
			'EndIf
			
			'If EditInfo.AlphaEd Then
			'	wsprintf @buffer, @"Line: %d    Pos: %d", nLastLine + 1, nCaretPos + 1
			'Else
			'    SetZStrEmpty (buffer)
			'EndIf
			'SendMessage ah.hsbr, SB_SETTEXT, 0, Cast (LPARAM, @buffer)
			
			'If EditInfo.CodeEd Then
			'	isinp.nLine=nLastLine
			'	isinp.lpszType=StrPtr("p")
			'	'If fProject Then
			'	'	isinp.nOwner=pTABMEM->profileinx
			'	'Else
			'	isinp.nOwner=Cast(Integer,ah.hred)
			'	'EndIf

			'    '=======================================
			'    'MOD 16.Dec.2011
			'    '=======================================
			'	pBuffer = Cast (ZString Ptr, SendMessage (ah.hpr, PRM_ISINPROC, 0, Cast (LPARAM, @isinp)))

			'	If pBuffer Then
            '        Dim s1 As String 
            '        Dim s2 As String 
            '        Dim s3 As String
            '            
            '        s1 = *pBuffer
            '        pBuffer += Len (s1) + 1
            '        s2 = *pBuffer
            '        pBuffer += Len (s2) + 1
            '        s3 = *pBuffer
            '        buffer = s1 + " (" + s2 + ") " + s3
			'	    
			'		'lstrcpy(@buffer,Cast(ZString Ptr,nLn))
			'		'nLn=nLn+Len(*Cast(ZString Ptr,nLn))+1
			'		'lstrcat(@buffer,StrPtr("("))
			'		'lstrcat(@buffer,Cast(ZString Ptr,nLn))
			'		'lstrcat(@buffer,StrPtr(") "))
			'		'nLn=nLn+Len(*Cast(ZString Ptr,nLn))+1
			'		'lstrcat(@buffer,Cast(ZString Ptr,nLn))
			'	Else
			'		SetZStrEmpty (buffer)             'MOD 26.1.2012 
			'	EndIf
			'Else
			'    SetZStrEmpty (buffer)
			'EndIf
			'SendMessage ah.hsbr, SB_SETTEXT, 5, Cast (LPARAM, @buffer)
			
            ' MOD 13.Dec. 2011		
            'If pTABMEM Then
            '    If pTABMEM->locked = TRUE Then
            '        pBuffer = @"LOCK"
            '    Else     
            '        pBuffer = @"UNLOCK"
            '    EndIf
            'Else
            '    pBuffer = @""
            'EndIf 
            'SendMessage ah.hsbr, SB_SETTEXT, 1 Or SBT_NOBORDERS, Cast (LPARAM, pBuffer)
                
            'If EditInfo.CoTxEd Then
            '    Mode = SendMessage (ah.hred, REM_GETMODE, 0, 0)
            'ElseIf EditInfo.HexEd Then    
            '    Mode = SendMessage (ah.hred, HEM_GETMODE, 0, 0)
            'EndIf
            
		    'If EditInfo.CoTxEd Then
            '    If Mode And MODE_BLOCK Then
			'        pBuffer = @"BLK"
            '    Else
            '        pBuffer = @"LIN"
            '    EndIf
            'Else
            '    pBuffer = @""
		    'EndIf    
		    'SendMessage ah.hsbr, SB_SETTEXT, 2 Or SBT_NOBORDERS, Cast (LPARAM, pBuffer)

		    'If EditInfo.AlphaEd Then
            '    If Mode And MODE_OVERWRITE Then
			'        pBuffer = @"OVR"
            '    Else
            '        pBuffer = @"INS"
            '    EndIf
            'Else
            '    pBuffer = @""
            'EndIf
            'SendMessage ah.hsbr, SB_SETTEXT, 3 Or SBT_NOBORDERS, Cast (LPARAM, pBuffer)

			UpdateProperty            ' check all tabs: property
		    'UpdateAllTabs(3)         ' check all tabs: property
			UpdateAllTabs (4)         ' update dirty bit
		EndIf
	EndIf
	
	If nHideOut Then
		nHideOut=nHideOut-1
		If nHideOut=0 Then
			ShowOutput(FALSE)
		EndIf
	EndIf
	
	If (GetKeyState(VK_CONTROL) And &H80)=0 Then
		nLn=SendMessage(ah.htabtool,TCM_GETCURSEL,0,0)
		If nLn<>curtab Then
			prevtab=curtab
			curtab=nLn
		EndIf
	EndIf
	
	'If fChangeNotification=0 Then
	'	UpdateAllTabs(5)          ' check all tabs: external file change   
	'	fChangeNotification=10
	'Else
	'	fChangeNotification-=1
	'EndIf
	
End Sub

Function FullScreenProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim hCld As HWND

	Select Case uMsg
		Case WM_DESTROY
			ah.hfullscreen=0
			hCld=GetWindow(hWin,GW_CHILD)
			SetParent(hCld,ah.hwnd)
			SetFocus(hCld)
			fInUse=0
	End Select
	Return DefWindowProc(hWin,uMsg,wParam,lParam)

End Function

Sub DoCommandLine
     
    Dim i        As Integer = Any 
    Dim FileSpec As ZString * MAX_PATH
    
    ' caution:
    ' this command line will not work: fbedit.exe "File1.ext""File2.ext"
    ' delimiter necessary in between:  fbedit.exe "File1.ext" "File2.ext"
        
    i = 0
    Do
        If CommandLine[i] = 34 Then 
            GetEnclosedStr i, *CommandLine, FileSpec, SizeOf (FileSpec), CUByte (34), CUByte (34)
        Else
            GetSubStr i, *CommandLine, FileSpec, SizeOf (FileSpec), !" \""
        EndIf
        If IsZStrNotEmpty (FileSpec) Then 
            OpenTheFile FileSpec, FOM_STD
        EndIf    
    Loop While i

	If edtopt.autoload Then          ' additional load last project 
		SendMessage ah.hwnd, WM_COMMAND, IDM_FILE_MRUPROJECT_1, 0
	EndIf

    
	'Dim x As Integer
	's=String(16384,szNULL)
	'buff=String(16384,szNULL)
	'lstrcpyn(@s,CommandLine,8192)
	'''' skip whites space
	'''' test ltrim for speed 
	'Do While (Asc(s)=Asc(" ")) Or (Asc(s)=9)
	'	''' avoid mid
	'	''' better use a index
	'	s=Mid(s,2)
	'Loop
	'If Len(s) Then
	'	s=s & " "
	'ElseIf edtopt.autoload Then
	'	' Load last project
	'	SendMessage(ah.hwnd,WM_COMMAND,14001,0)
	'	s=""
	'EndIf
	'x=1
	'Do While Asc(s,x)<>0 ''' szNULL
	'	If Asc(s,x)=34 Then
	'		x=x+1
	'		Do While Asc(s,x)<>34
	'			x=x+1
	'		Loop
	'	EndIf
	'	If Asc(s,x)=Asc(" ") Then
	'		lstrcpyn(@ad.filename,@s,x)
	'		If Asc(ad.filename)=34 Then
	'			ad.filename=Mid(ad.filename,2,InStr(2,ad.filename,Chr(34))-2)
	'		EndIf
	'		' Open single file
	'		OpenTheFile(ad.filename,FALSE)
	'		s=Mid(s,x+1)
	'		x=0
	'	EndIf
	'	x=x+1
	'Loop

End Sub

'Function SplashProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
'	Dim ps As PAINTSTRUCT
'	Dim mDC As HDC
'	Dim rect As RECT
'
'	Select Case uMsg
'		Case WM_PAINT
'			GetClientRect(hWin,@rect)
'			BeginPaint(hWin,@ps)
'			mDC=CreateCompatibleDC(ps.hdc)
'			SelectObject(mDC,hSplashBmp)
'			StretchBlt(ps.hdc,0,0,rect.right,rect.bottom,mDC,0,0,340,188,SRCCOPY)
'			DeleteDC(mDC)
'			FrameRect(ps.hdc,@rect,GetStockObject(BLACK_BRUSH))
'			EndPaint(hWin,@ps)
'			Return 0
'			'
'	    Case WM_CLOSE
'	        DestroyWindow hWin
'   		Return 0
'   			
'	    Case WM_DESTROY 
'			DeleteObject hSplashBmp
'           Return 0
'            
'		Case Else
'			Return CallWindowProc(lpOldSplashProc,hWin,uMsg,wParam,lParam)
'	End Select
'
'End Function

Function MainDlgProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer

	Dim As Long id,x,y,lret,bm,hgt,wdt,tbhgt,twt,prjht,prht,i
	Dim Mode As Long = Any 
	Dim rect As RECT
	Dim rect1 As RECT
	Dim chrg As CHARRANGE
	Dim lpRASELCHANGE As RASELCHANGE Ptr
	Dim lpHESELCHANGE As HESELCHANGE Ptr
	'Dim lpTOOLTIPTEXT As TOOLTIPTEXT Ptr
	Dim lpFBNOTIFY As FBNOTIFY Ptr
	Dim lpRAPNOTIFY As RAPNOTIFY Ptr
	'Dim lpNMTVDISPINFO As  Ptr
	Dim hCtl As HWND
	Dim lfnt As LOGFONT
	Dim tci As TCITEM
	Dim nLine As Integer
	Dim hBmp As HBITMAP = Any 
	Dim sItem As ZString*260
	Dim hMem As HGLOBAL
	Dim lpCOPYDATASTRUCT As COPYDATASTRUCT Ptr
	Dim sFile As String
	Dim FileID As Integer = Any 
	Dim TabId  As Integer = Any 
	Dim hMnu   As HMENU   = Any 
	Dim hTVItem As HTREEITEM 
	Dim pt As Point
	Dim hebm As HEBMK
    Dim pZStr  As ZString Ptr = Any 
    Dim pBuffB As ZString Ptr = Any 

    Static mnuid As Integer = 21000
    Static fQR   As BOOLEAN 
    Static nSize As Integer
    Static hVCur As HCURSOR
    Static hHCur As HCURSOR

	Select Case uMsg
		Case WM_INITDIALOG
			ah.hwnd        = hWin
			ad.lpFBCOLOR   = @fbcol
			ad.lpWINPOS    = @wpos
			ah.hshp        = GetDlgItem (hWin, IDC_SHP)                ' Shape
			ah.hsbr        = GetDlgItem (hWin, IDC_STATUSBAR)          ' Statusbar
			
			' Set close button image
            hBmp = LoadImage (hInstance, MAKEINTRESOURCE (IDB_CLOSE), IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS)
			SendDlgItemMessage hWin, IDM_FILE_CLOSE, BM_SETIMAGE, IMAGE_BITMAP, Cast (LPARAM, hBmp)
            'DeleteObject hBmp
			' Get from ini
			'GetPrivateProfileString(StrPtr("Project"),StrPtr("Path"),StrPtr("\"),@ad.DefProjectPath,SizeOf(ad.DefProjectPath),@ad.IniFile)
			'If ad.DefProjectPath[0]=Asc("\") Then
			'	ad.DefProjectPath=Left(ad.AppPath,2) & ad.DefProjectPath
			'EndIf
			'FixPath(ad.DefProjectPath)
			'GetPrivateProfileString(StrPtr("Make"),StrPtr("fbcPath"),NULL,@ad.fbcPath,SizeOf(ad.fbcPath),@ad.IniFile)
			'If ad.fbcPath[0]=Asc("\") Then
			'	ad.fbcPath=Left(ad.AppPath,2) & ad.fbcPath
			'EndIf
			'FixPath(ad.fbcPath)
			'GetPrivateProfileString(StrPtr("Help"),StrPtr("Path"),NULL,@ad.HelpPath,SizeOf(ad.HelpPath),@ad.IniFile)
			'If ad.HelpPath[0]=Asc("\") Then
			'	ad.HelpPath=Left(ad.AppPath,2) & ad.HelpPath
			'EndIf
			'FixPath(ad.HelpPath)
			' Get handle of build combobox
			ah.hcbobuild=GetDlgItem(hWin,IDC_CBOBUILD)
			' Get handle of ToolBar control
			ad.tbwt=694
			ah.htoolbar=GetDlgItem(hWin,IDC_TOOLBAR)
			DoToolbar ah.htoolbar

			SbarInit

			' Handle of tab tool
			ah.htabtool=GetDlgItem(hWin,IDC_TABSELECT)
			SetWindowLong(ah.htabtool,GWL_ID,IDC_TABSELECT)
			lpOldTabToolProc=Cast(Any Ptr,SetWindowLong(ah.htabtool,GWL_WNDPROC,Cast(Integer,@TabToolProc)))
			' Handle of output window
			ah.hout=GetDlgItem(hWin,IDC_OUTPUT)
			SetWindowLong(ah.hout,GWL_ID,IDC_OUTPUT)
			lpOldOutputProc = Cast(Any Ptr,SetWindowLong(ah.hout,GWL_WNDPROC,Cast(Integer,@OutputProc)))
	    	'lpOldOutputProc = Cast (WNDPROC, SendMessage (ah.hout, REM_SUBCLASS, 0, Cast (LPARAM, @OutputProc)))

			' Handle of immediate window
			ah.himm=GetDlgItem(hWin,IDC_IMMEDIATE)
			SetWindowLong(ah.himm,GWL_ID,IDC_IMMEDIATE)
			lpOldImmediateProc=Cast(Any Ptr,SetWindowLong(ah.himm,GWL_WNDPROC,Cast(Integer,@ImmediateProc)))
			' Handle of debug tab window
			ah.hdbgtab=GetDlgItem(hWin,IDC_TABDEBUG)
			' Create the tabs
			tci.mask=TCIF_TEXT
			tci.pszText=@szReg
			SendMessage(ah.hdbgtab,TCM_INSERTITEM,999,Cast(LPARAM,@tci))
			'SendMessage(ah.hdbgtab,TCM_SETCURSEL,i,0)
			tci.pszText=@szFpu
			SendMessage(ah.hdbgtab,TCM_INSERTITEM,999,Cast(LPARAM,@tci))
			tci.pszText=@szMmx
			SendMessage(ah.hdbgtab,TCM_INSERTITEM,999,Cast(LPARAM,@tci))
			
			ah.hregister=GetDlgItem(hWin,IDC_REGISTER)            ' Handle of register window
			ah.hfpu=GetDlgItem(hWin,IDC_FPU)                      ' Handle of fpu window
			ah.hmmx=GetDlgItem(hWin,IDC_MMX)                      ' Handle of mmx window
			' Handle of font
			'hDlgFnt=Cast(HFONT,SendMessage(ah.htabtool,WM_GETFONT,0,0))
			
			' read ini
			For id = 1 To 15
				thme(id).lpszTheme = @szTheme(id)
				LoadFromIni "Theme", Str (id), "04444444444444444444444444444444444444444444444444444", @thme(id), FALSE
			Next 
			
			GetPrivateProfilePath "Win"        , "Path"         , @ad.IniFile, @szLastDir        , GPP_MustExist
			GetPrivateProfilePath "EnvironPath", "PROJECTS_PATH", @ad.IniFile, @ad.DefProjectPath, GPP_MustExist
			GetPrivateProfilePath "EnvironPath", "FBC_PATH"     , @ad.IniFile, @ad.fbcPath       , GPP_MustExist
			GetPrivateProfilePath "EnvironPath", "FBCINC_PATH"  , @ad.IniFile, @ad.FbcIncPath    , GPP_MustExist
			GetPrivateProfilePath "EnvironPath", "FBCLIB_PATH"  , @ad.IniFile, @ad.FbcLibPath    , GPP_MustExist
			GetPrivateProfilePath "EnvironPath", "HELP_PATH"    , @ad.IniFile, @ad.HelpPath      , GPP_MustExist
			
			GetPrivateProfileString "Make", "QuickRun", "fbc -s console", @ad.smakequickrun, SizeOf (ad.smakequickrun), @ad.IniFile
			LoadFromIni "Edit"    , "EditOpt"   , "444444444444444444444"          , @edtopt , FALSE
			LoadFromIni "Resource", "Export"    , "4440"                           , @nmeexp , FALSE
			LoadFromIni "Resource", "Grid"      , "444444444444"                   , @grdsize, FALSE
			LoadFromIni "Win"     , "Colors"    , "4444444444444444444444444444444", @fbcol  , FALSE
			LoadFromIni "Edit"    , "Colors"    , "444444444444444444444"          , @kwcol  , FALSE
			LoadFromIni "Edit"    , "CustColors", "444444444444444444444"          , @custcol, FALSE
			GetMakeOption
			GetPrivateProfileString(StrPtr("Edit"),StrPtr("CodeFiles"),StrPtr(".bas.bi."),@sCodeFiles,SizeOf(sCodeFiles),@ad.IniFile)
            CharLower sCodeFiles			
			GetPrivateProfileString(StrPtr("Debug"),StrPtr("Debug"),NULL,@ad.smakerundebug,SizeOf(ad.smakerundebug),@ad.IniFile)
			GetPrivateProfileString(StrPtr("Edit"),StrPtr("CaseConvert"),StrPtr("CWPp"),@szCaseConvert,SizeOf(szCaseConvert),@ad.IniFile)
			LoadFindHistory

			' Create fonts
			LoadFromIni "Edit", "EditFont", "44044", @edtfnt, FALSE
			lfnt.lfHeight     = edtfnt.size
			lfnt.lfCharSet    = edtfnt.charset
			lfnt.lfWeight     = edtfnt.weight
			lfnt.lfItalic     = edtfnt.italics
			lfnt.lfFaceName   = *edtfnt.szFont
			ah.rafnt.hFont    = CreateFontIndirect (@lfnt)
			lfnt.lfItalic     = TRUE 
			ah.rafnt.hIFont   = CreateFontIndirect (@lfnt)

			'Font line_number
			LoadFromIni "Edit", "LnrFont", "44044", @lnrfnt, FALSE
			lfnt.lfHeight     = lnrfnt.size
			lfnt.lfCharSet    = lnrfnt.charset
			lfnt.lfWeight     = lnrfnt.weight
			lfnt.lfItalic     = lnrfnt.italics
			lfnt.lfFaceName   = *lnrfnt.szFont
			ah.rafnt.hLnrFont = CreateFontIndirect (@lfnt)

			' Font output window 
			LoadFromIni "Edit", "OutpFont", "44044", @outpfnt, FALSE
			lfnt.lfHeight     = outpfnt.size
			lfnt.lfCharSet    = outpfnt.charset
			lfnt.lfWeight     = outpfnt.weight
			lfnt.lfItalic     = outpfnt.italics
			lfnt.lfFaceName   = *outpfnt.szFont
			ah.hOutFont       = CreateFontIndirect (@lfnt)

			' Font for tools
			LoadFromIni "Edit", "ToolFont", "44044", @toolfnt, FALSE
			lfnt.lfHeight     = toolfnt.size
			lfnt.lfCharSet    = toolfnt.charset
			lfnt.lfWeight     = toolfnt.weight
			lfnt.lfItalic     = toolfnt.italics
			lfnt.lfFaceName   = *toolfnt.szFont
			ah.hToolFont      = CreateFontIndirect (@lfnt)
			
			SendMessage ah.hout, REM_SETCHARTAB, Asc (";"), CT_OPER                               ' Turn off default comment char
			SendMessage ah.hout, REM_SETCHARTAB, Asc ("@"), CT_OPER                               ' Define @ as a operand
			SendMessage ah.hout, REM_SETCHARTAB, Asc ("#"), CT_CHAR                               ' Define # as a character
			SendMessage ah.hout, REM_SETCHARTAB, Asc ("'"), CT_CMNTCHAR                           ' Set comment char
			SendMessage ah.hout, REM_SETCHARTAB, Asc ("/"), CT_CMNTINITCHAR                       ' Set comment block init char
			SendMessage ah.hout, REM_SETCOMMENTBLOCKS, Cast (WPARAM, @"/'"), Cast (LPARAM, @"'/") ' Set comment block definition
			
			For i = 0 To 39
				blk.lpszStart = @szSt(i)                       ' Set code blocks
				blk.lpszEnd   = @szEn(i)
				blk.lpszNot1  = @szNot1
				blk.lpszNot2  = @szNot2
				If LoadFromIni ("Block", Str (i), "00004", @blk, FALSE) Then
					If IsZStrNotEmpty (szSt(i)) Then         ' MOD 27.1.2012  
						BD(i).lpszStart=@szSt(i)
					EndIf
					If IsZStrNotEmpty (szEn(i)) Then         ' MOD 27.1.2012  
						BD(i).lpszEnd=@szEn(i)
					EndIf
					If IsZStrNotEmpty (szNot1) Then          ' MOD 27.1.2012  
						BD(i).lpszNot1=@szNot1
					EndIf
					If IsZStrNotEmpty (szNot2) Then          ' MOD 27.1.2012  
						BD(i).lpszNot2=@szNot2
					EndIf
					BD(i).flag=blk.flag
					SendMessage(ah.hout,REM_ADDBLOCKDEF,0,Cast(Integer,@BD(i)))
					ReplaceChar1stHit szEn(i), Asc ("|"), NULL 
					'x=InStr(szEn(i),"|")
					'If x Then
					'	Mid(szEn(i),x,1)=szNULL
					'EndIf
				EndIf
				autofmt(i).wrd=@szIndent(i)
				LoadFromIni ("AutoFormat", Str (i), "0444", @autofmt(i), FALSE)
			Next

			' Set bracket matching
			If edtopt.bracematch Then
				SendMessage(ah.hout,REM_BRACKETMATCH,0,Cast(Integer,@szBracketMatch))
			Else
				SendMessage(ah.hout,REM_BRACKETMATCH,0,Cast(Integer,StrPtr("")))
			EndIf
			' Menus
			ah.hmenu=GetMenu(hWin)
			ah.hcontextmenu=LoadMenu(hInstance,Cast(ZString Ptr,IDR_CONTEXTMENU))
			GetPrivateProfileString(StrPtr("Language"),StrPtr("Language"),NULL,@Language,SizeOf(Language),@ad.IniFile)
			If IsZStrNotEmpty (Language) Then GetLanguageFile
			
			' Project tab
			ah.htab=GetDlgItem(hWin,IDC_TAB)
			tci.mask=TCIF_TEXT
			buff=GetInternalString(IS_FILE)
			tci.pszText=@buff
			SendMessage(ah.htab,TCM_INSERTITEM,999,Cast(Integer,@tci))
			buff=GetInternalString(IS_PROJECT)
			tci.pszText=@buff
			SendMessage(ah.htab,TCM_INSERTITEM,999,Cast(Integer,@tci))
			' Project browser
			ah.hprj=GetDlgItem(hWin,IDC_TRVPRJ)
			lpOldProjectProc=Cast(Any Ptr,SetWindowLong(ah.hprj,GWL_WNDPROC,Cast(Integer,@ProjectProc)))
			' Create the imagelist
			ah.himl=ImageList_Create(16,16,ILC_MASK Or ILC_COLOR8,16,0)
			hBmp=LoadBitmap(hInstance,Cast(ZString Ptr,IDB_FILES))
			ImageList_AddMasked(ah.himl,hBmp,&HFF00FF)
			DeleteObject(hBmp)
			SendMessage(ah.hprj,TVM_SETIMAGELIST,TVSIL_NORMAL,Cast(Integer,ah.himl))
			SendMessage(ah.htabtool,TCM_SETIMAGELIST,0,Cast(Integer,ah.himl))
			' Setup filebrowser
			ah.hfib=GetDlgItem(hWin,IDC_FILEBROWSER)
			lpOldFileBrowserProc = Cast (WNDPROC, SetWindowLong (ah.hfib, GWL_WNDPROC, Cast (LONG, @FileBrowserProc)))
			SendMessage(ah.hfib,FBM_SETPATH,FALSE,Cast(Integer,@ad.DefProjectPath))
			SendMessage(ah.hfib,FBM_SETFILTERSTRING,FALSE,Cast(Integer,StrPtr(".bas.bi.rc.txt.fbp.")))
			SendMessage(ah.hfib,FBM_SETFILTER,TRUE,TRUE)
			buff=GetInternalString(IS_RAFILE1)
			SendMessage(ah.hfib,FBM_SETTOOLTIP,1,Cast(LPARAM,@buff))
			buff=GetInternalString(IS_RAFILE2)
			SendMessage(ah.hfib,FBM_SETTOOLTIP,2,Cast(LPARAM,@buff))
			' Property definitions
			ah.hpr=GetDlgItem(hWin,IDC_PROPERTY)
			SendMessage(ah.hPr,PRM_SETLANGUAGE,nFREEBASIC,0)
			buff=GetInternalString(IS_RAPROPERTY1)
			SendMessage(ah.hpr,PRM_SETTOOLTIP,1,Cast(LPARAM,@buff))
			buff=GetInternalString(IS_RAPROPERTY2)
			SendMessage(ah.hpr,PRM_SETTOOLTIP,2,Cast(LPARAM,@buff))
			buff=GetInternalString(IS_RAPROPERTY3)
			SendMessage(ah.hpr,PRM_SETTOOLTIP,3,Cast(LPARAM,@buff))
			buff=GetInternalString(IS_RAPROPERTY4)
			SendMessage(ah.hpr,PRM_SETTOOLTIP,4,Cast(LPARAM,@buff))
			buff=GetInternalString(IS_RAPROPERTY5)
			SendMessage(ah.hpr,PRM_SETTOOLTIP,5,Cast(LPARAM,@buff))
			SetupProperty
			' Code complete list
			ah.hcc=CreateWindowEx(NULL,@szCCLBClassName,NULL,WS_POPUP Or WS_THICKFRAME Or WS_CLIPSIBLINGS Or WS_CLIPCHILDREN Or STYLE_USEIMAGELIST,0,0,wpos.ptcclist.x,wpos.ptcclist.y,hWin,NULL,hInstance,0)
			lpOldCCProc=Cast(Any Ptr,SetWindowLong(ah.hcc,GWL_WNDPROC,Cast(Integer,@CCProc)))                
			' Code complete tooltip
			ah.htt=CreateWindowEx(NULL,@szCCTTClassName,NULL,WS_POPUP Or WS_BORDER Or WS_CLIPSIBLINGS Or WS_CLIPCHILDREN Or STYLE_USEPARANTESES,0,0,0,0,hWin,NULL,hInstance,0)
			' Font setting
			SendMessage ah.hcc,       WM_SETFONT, Cast (WPARAM, ah.hToolFont), FALSE
			SendMessage ah.htt,       WM_SETFONT, Cast (WPARAM, ah.hToolFont), FALSE
			SendMessage ah.hpr,       WM_SETFONT, Cast (WPARAM, ah.hToolFont), FALSE
			SendMessage ah.hprj,      WM_SETFONT, Cast (WPARAM, ah.hToolFont), FALSE
			SendMessage ah.hfib,      WM_SETFONT, Cast (WPARAM, ah.hToolFont), FALSE
			SendMessage ah.htab,      WM_SETFONT, Cast (WPARAM, ah.hToolFont), FALSE
			SendMessage ah.htabtool,  WM_SETFONT, Cast (WPARAM, ah.hToolFont), FALSE
			SendMessage ah.hout,      WM_SETFONT, Cast (WPARAM, ah.hOutFont ), FALSE
			SendMessage ah.himm,      WM_SETFONT, Cast (WPARAM, ah.hOutFont ), FALSE
			SendMessage ah.hregister, WM_SETFONT, Cast (WPARAM, ah.hOutFont ), FALSE
			SendMessage ah.hfpu,      WM_SETFONT, Cast (WPARAM, ah.hOutFont ), FALSE
			SendMessage ah.hmmx,      WM_SETFONT, Cast (WPARAM, ah.hOutFont ), FALSE
			' Printer
			LoadFromIni "Printer", "Page", "4444444", @ppage, FALSE
			GetLocaleInfo(GetUserDefaultLCID,LOCALE_IMEASURE,@buff,SizeOf(buff))
			If buff[0] = Asc ("1") Then
				ppage.inch = 1
			Else
				ppage.inch = 0
			EndIf
			psd.ptPaperSize.x   = ppage.page.x
			psd.ptPaperSize.y   = ppage.page.y
			psd.rtMargin.left   = ppage.margin.left
			psd.rtMargin.top    = ppage.margin.top
			psd.rtMargin.right  = ppage.margin.right
			psd.rtMargin.bottom = ppage.margin.bottom
			' Position and size main window
			SetWindowPos(hWin,NULL,wpos.x,wpos.y,wpos.wt,wpos.ht,SWP_NOZORDER)
			If wpos.fmax Then
				ShowWindow(hWin,SW_MAXIMIZE)
			EndIf
			If wpos.fview And VIEW_OUTPUT Then
				ShowWindow(ah.hout,SW_SHOWNA)
				SendMessage(ah.htoolbar,TB_CHECKBUTTON,IDM_VIEW_OUTPUT,TRUE)
			EndIf
			If wpos.fview And VIEW_IMMEDIATE Then
				ShowWindow(ah.himm,SW_SHOWNA)
				SendMessage(ah.htoolbar,TB_CHECKBUTTON,IDM_VIEW_IMMEDIATE,TRUE)
			EndIf
			If wpos.fview And VIEW_PROJECT Then
				ShowWindow(ah.htab,SW_SHOWNA)
				ShowWindow(ah.hfib,SW_SHOWNA)
				SendMessage(ah.htoolbar,TB_CHECKBUTTON,IDM_VIEW_PROJECT,TRUE)
			EndIf
			If wpos.fview And VIEW_PROPERTY Then
				ShowWindow(ah.hpr,SW_SHOWNA)
				SendMessage(ah.htoolbar,TB_CHECKBUTTON,IDM_VIEW_PROPERTY,TRUE)
			EndIf
			If wpos.fview And VIEW_TOOLBAR Then
				ShowWindow(ah.htoolbar,SW_SHOWNA)
				ShowWindow(ah.hcbobuild,SW_SHOWNA)
				hCtl=GetDlgItem(hWin,IDC_DIVIDER2)
				ShowWindow(hCtl,SW_SHOWNA)
			EndIf
			If wpos.fview And VIEW_TABSELECT Then
				ShowWindow(ah.htabtool,SW_SHOWNA)
				hCtl=GetDlgItem(hWin,IDM_FILE_CLOSE)
				ShowWindow(hCtl,SW_SHOWNA)
				hCtl=GetDlgItem(hWin,IDC_DIVIDER)
				ShowWindow(hCtl,SW_SHOWNA)
			EndIf
			If wpos.fview And VIEW_STATUSBAR Then
				ShowWindow(ah.hsbr,SW_SHOWNA)
			EndIf
			ah.hmnuiml=ImageList_Create(16,16,ILC_COLOR4 Or ILC_MASK,4,0)
			hBmp=LoadBitmap(hInstance,Cast(ZString Ptr,IDB_MNUARROW))
			ImageList_AddMasked(ah.hmnuiml,hBmp,&HC0C0C0)
			' Resource editor child dialog
			ah.hres = CreateDialog (hInstance, MAKEINTRESOURCE (IDD_DLGRESED), hWin, @ResEdProc)
			SetWindowLong(ah.hres,GWL_ID,IDC_RESED)             ' MOD 2.2.2012
			SetToolsColors
			MakeSubMenu IDM_TOOLS, IDM_TOOLS_USER_1, IDM_TOOLS_USER_LAST, "Tools"    ' MOD SetToolMenu(hWin)
       		MakeSubMenu IDM_HELP,  IDM_HELP_USER_1,  IDM_HELP_USER_LAST,  "Help"     ' MOD SetHelpMenu(hWin)
			' Syntax hiliting
			SetHiliteWords(ah.hwnd)
			' Add api files
			GetPrivateProfileString(StrPtr("Api"),StrPtr("Api"),NULL,@ApiFiles,SizeOf(ApiFiles),@ad.IniFile)
			GetPrivateProfileString(StrPtr("Api"),StrPtr("DefApi"),NULL,@DefApiFiles,SizeOf(DefApiFiles),@ad.IniFile)
			LoadApiFiles
			SetHiliteWordsFromApi(ah.hwnd)
			SetTimer hWin, IDT_GENERAL, 200, Cast (TIMERPROC, @TimerAProc)
			SetWinCaption
			hVCur=LoadCursor(hInstance,Cast(ZString Ptr,IDC_VSPLIT))
			hHCur=LoadCursor(hInstance,Cast(ZString Ptr,IDC_HSPLIT))
			MakeMenuMruProjects
			MakeMenuMruFiles
			fTimer=1
			LoadAddins
			ShowWindow(ah.htabtool,SW_HIDE)
			'hSplashBmp = LoadBitmap (hInstance, MAKEINTRESOURCE (IDB_SPLASH))
			'lpOldSplashProc=Cast(Any Ptr,SetWindowLong(GetDlgItem(hWin,IDC_IMGSPLASH),GWL_WNDPROC,Cast(Integer,@SplashProc)))
			'frhex=FR_DOWN
			ttmsg.szType="M"
			ttmsg.lpMsgApi(0).nPos=2
			ttmsg.lpMsgApi(0).lpszApi=@"SendMessage"
			ttmsg.lpMsgApi(1).nPos=2
			ttmsg.lpMsgApi(1).lpszApi=@"PostMessage"
			ttmsg.lpMsgApi(2).nPos=3
			ttmsg.lpMsgApi(2).lpszApi=@"SendDlgItemMessage"
			'DefFrameProc,DefWindowProc,DefMDIChildProc,DefDlgProc
			
			' Search Module
			'f.fsearch=1       ' not used, see LoadFindHistory
            
			Return FALSE
			'
		Case WM_CLOSE
			If CallAddins(hWin,AIM_QUERYCLOSE,wParam,lParam,HOOK_QUERYCLOSE) Then
				Return 0
			EndIf
			If fProject Then
				If CloseProject=FALSE Then
					Return 0
				EndIf
			EndIf
			If CloseAllTabs () = TRUE Then 
		   'If CloseAllTabs(fProject,0,edtopt.closeonlocks)=FALSE Then          ' MOD 1.2.2012 removed hWin
				If CallAddins(hWin,AIM_CLOSE,wParam,lParam,HOOK_CLOSE) Then
					Return 0
				EndIf
				KillQuickRun
				GetWindowRect(hWin,@rect)
				If IsIconic(hWin)=FALSE And IsZoomed(hWin)=FALSE Then
					wpos.x=rect.left
					wpos.y=rect.top
					wpos.wt=rect.right-rect.left
					wpos.ht=rect.bottom-rect.top
				EndIf
				wpos.fmax=IsZoomed(hWin)
				'GetWindowRect(ah.hcc,@rect)
				'wpos.ptcclist.x=rect.right-rect.left
				'wpos.ptcclist.y=rect.bottom-rect.top
				DestroyWindow(ah.hcc)
				DestroyWindow(ah.htt)
				SendMessage(ah.hraresed,DEM_GETSIZE,0,Cast(LPARAM,@ressize))
				DestroyWindow(ah.hres)
                ' CBH_Dialog  (ClipBoardHistory)
        		SendMessage hCBHDlg, WM_CLOSE, 0, 0
				Return DefWindowProc(hWin,uMsg,wParam,lParam)
			EndIf
			'
		Case WM_DESTROY
			KillTimer(hWin,200)
			If ad.hLangMem Then
				GlobalFree(ad.hLangMem)
				ad.hLangMem=0
			EndIf
			DeleteObject(Cast(HBITMAP,SendDlgItemMessage(hWin,IDM_FILE_CLOSE,BM_SETIMAGE,IMAGE_BITMAP,0)))
			DeleteObject(ah.rafnt.hFont)
			DeleteObject(ah.rafnt.hIFont)
			DeleteObject(ah.rafnt.hLnrFont)
			DeleteObject(ah.hOutFont)                  'MOD    add
			DeleteObject(ah.hToolFont)
			DestroyIcon(hIcon)
			DestroyCursor(hVCur)
			DestroyCursor(hHCur)
			ImageList_Destroy(ah.hmnuiml)
			ImageList_Destroy(ah.himl)
			DestroyMenu(ah.hcontextmenu)
			SaveFindHistory
			SaveToIni(StrPtr("Win"),StrPtr("Winpos"),"4444444444444444444",@wpos,FALSE)
			SaveToIni(StrPtr("Win"),StrPtr("ressize"),"444444",@ressize,FALSE)
			WritePrivateProfileString(StrPtr("Win"),StrPtr("Path"),@szLastDir,@ad.IniFile)
			DefWindowProc(hWin,uMsg,wParam,lParam)
			PostQuitMessage(NULL)
			'
		Case WM_COMMAND
			If CallAddins(hWin,AIM_COMMAND,wParam,lParam,HOOK_COMMAND) Then
				Return 0
			EndIf
			id=LoWord(wParam)
			Select Case HiWord(wParam)
				Case BN_CLICKED, 1
					Select Case As const id
                        #If __FB_DEBUG__
				        Case IDM_DEBUG_TESTSTART
				            ' test stuff only
				            Print "IDM_DEBUG_TESTSTART:"


						#EndIf

						Case IDM_FILE_NEWPROJECT
							DialogBox(hInstance,Cast(ZString Ptr,IDD_NEWPROJECT),GetOwner,@NewProjectDlgProc)
							fTimer = 1
							'
						Case IDM_FILE_OPENPROJECT
							OpenAProject
							fTimer = 1
							'
						Case IDM_FILE_CLOSEPROJECT
							CloseProject
							fTimer = 1
							'
						Case IDM_FILE_NEW
							hCtl=CreateCodeEd("(Untitled).bas")
							AddTab(hCtl,"(Untitled).bas",ATM_FOREGROUND)   ' MOD 2.2.2012    AddTab(hCtl,"(Untitled).bas",FALSE)
							fTimer = 1
							'
						Case IDM_FILE_NEW_RESOURCE
							                                        ' MOD 2.2.2012    ad.filename="(Untitled).rc"
							hMem=MyGlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,4096)
							'GlobalLock(hMem)                       ' MOD 3.2.2012    FixedMem Lockcount always zero
							SendMessage(ah.hraresed,PRO_OPEN,Cast(Integer,@"(Untitled).rc"),Cast(Integer,hMem))
							                                        ' MOD 2.2.2012    ah.hred=ah.hres
							AddTab(ah.hres,"(Untitled).rc",ATM_FOREGROUND) ' MOD 2.2.2012    AddTab(ah.hred,ad.filename,FALSE)
							fTimer = 1
							'
						Case IDM_FILE_OPEN_STD
							'buff=OpenInclude
							GetIncludeSpec @buff                    ' check cursor position for an valid spec
							If IsZStrNotEmpty (buff) Then
								OpenTheFile buff, FOM_STD
							Else
					            TextToOutput "*** no valid spec found at caret ***", &hFFFFFFFF
								OpenAFile FOM_STD                       ' MOD 2.1.2012   OpenAFile(hWin,FALSE)
							EndIf
							fTimer = 1
							'
						Case IDM_FILE_OPEN_HEX
							OpenAFile(FOM_HEX)                         ' MOD 2.1.2012   OpenAFile(hWin,TRUE)
							fTimer = 1
							'
						Case IDM_FILE_OPEN_TXT
							OpenAFile(FOM_TXT)                         ' MOD 2.1.2012   OpenAFile(hWin,TRUE)
							fTimer = 1
							'
    					Case IDM_FIB_OPEN_STD
    					    SendMessage ah.hfib, FBM_GETSELECTED, 0, Cast (LPARAM, @buff)
    					    If GetFileAttributes (@buff) And FILE_ATTRIBUTE_DIRECTORY Then
    					        ' is DIR, dont load
    					    Else
    					        OpenTheFile buff, FOM_STD
    					        fTimer = 1    
    					    EndIf
    				
    					Case IDM_FIB_OPEN_HEX
       					    SendMessage ah.hfib, FBM_GETSELECTED, 0, Cast (LPARAM, @buff)
    					    If GetFileAttributes (@buff) And FILE_ATTRIBUTE_DIRECTORY Then
    					        ' is DIR, dont load
    					    Else
    					        OpenTheFile buff, FOM_HEX
    					        fTimer = 1    
    					    EndIf
    
    					Case IDM_FIB_OPEN_TXT
    					    SendMessage ah.hfib, FBM_GETSELECTED, 0, Cast (LPARAM, @buff)
    					    If GetFileAttributes (@buff) And FILE_ATTRIBUTE_DIRECTORY Then
    					        ' is DIR, dont load
    					    Else
    					        OpenTheFile buff, FOM_TXT    
    					        fTimer = 1
    					    EndIf
					    
					    Case IDM_PROJECT_FILE_OPEN_STD
					        GetTrvSelItemData sFile, 0, 0, PT_ABSOLUTE
					        OpenTheFile sFile, FOM_STD
					        fTimer = 1
					        
					    Case IDM_PROJECT_FILE_OPEN_HEX 
   							GetTrvSelItemData sFile, 0, 0, PT_ABSOLUTE
					        OpenTheFile sFile, FOM_HEX
					        fTimer = 1
					        
					    Case IDM_PROJECT_FILE_OPEN_TXT
					        GetTrvSelItemData sFile, 0, 0, PT_ABSOLUTE
					        OpenTheFile sFile, FOM_TXT
                            fTimer = 1
                            
					    Case IDM_FILE_SAVE							
							SetFocus(ah.hred)
							If Left(ad.filename,10)="(Untitled)" Then
								SaveTabAs()                    ' MOD 2.1.2012   SaveFileAs(hWin)
							Else
								WriteTheFile(ah.hred,ad.filename)
							EndIf
							UpdateAllTabs (4)                  ' update dirty bit
							
						Case IDM_FILE_SAVEALL
							SaveAllTabs()                      ' MOD 2.1.2012   SaveAllFiles(hWin)
							UpdateAllTabs (4)                  ' update dirty bit
							
						Case IDM_FILE_SAVEAS
							SaveTabAs()                        ' MOD 2.1.2012   SaveFileAs(hWin)
							UpdateAllTabs (4)                  ' update dirty bit
							                                   'TODO
					    Case IDM_FILE_CLOSE                    ' remove ugly focus rectangle from tiny button
					        SendDlgItemMessage ah.hwnd, IDM_FILE_CLOSE, WM_KILLFOCUS, NULL, 0   
			            	i = SendMessage (ah.htabtool, TCM_GETCURSEL, 0, 0)
                            If i <> INVALID_TABID Then    
    							CloseTab i                      ' MOD 1.2.2012    DelTab(hWin)
    							fTimer = 1
                            EndIf	
							'
						Case IDM_FILE_CLOSEALL
							CloseAllTabs                       ' MOD 1.2.2012
							fTimer = 1
							'
						Case IDM_FILE_PAGESETUP
							psd.lStructSize=SizeOf(psd)
							psd.hwndOwner=hWin
							psd.hInstance=hInstance
							If ppage.inch Then
								psd.Flags=PSD_MARGINS Or PSD_INTHOUSANDTHSOFINCHES
							Else
								psd.Flags=PSD_MARGINS Or PSD_INHUNDREDTHSOFMILLIMETERS
							EndIf
							If PageSetupDlg(@psd) Then
								ppage.page.x=psd.ptPaperSize.x
								ppage.page.y=psd.ptPaperSize.y
								ppage.margin.left=psd.rtMargin.left
								ppage.margin.top=psd.rtMargin.top
								ppage.margin.right=psd.rtMargin.right
								ppage.margin.bottom=psd.rtMargin.bottom
								SaveToIni(StrPtr("Printer"),StrPtr("Page"),"4444444",@ppage,FALSE)
							EndIf
							'
						Case IDM_FILE_PRINT
							pd.lStructSize=SizeOf(pd)
							pd.hwndOwner=hWin
							pd.hInstance=hInstance
							i=SendMessage(ah.hred,EM_GETLINECOUNT,0,0)
							id=i\ppage.pagelen
							If i/ppage.pagelen>id Then
								id+=1
							EndIf
							pd.nMinPage=1
							pd.nMaxPage=id
							pd.nFromPage=1
							pd.nToPage=id
							SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@chrg))
							If chrg.cpMin<>chrg.cpMax Then
								pd.Flags=PD_RETURNDC Or PD_SELECTION
							Else
								pd.Flags=PD_RETURNDC Or PD_NOSELECTION Or PD_PAGENUMS
							EndIf
							If PrintDlg(@pd) Then
								PrintDoc
							EndIf
							'
						Case IDM_FILE_EXIT
							SendMessage(hWin,WM_CLOSE,0,0)
							'
						Case IDM_EDIT_UNDO
							SendMessage(ah.hred,EM_UNDO,0,0)
							'
						Case IDM_EDIT_REDO
							SendMessage(ah.hred,EM_REDO,0,0)
							'
						Case IDM_EDIT_EMPTYUNDO
							SendMessage(ah.hred,EM_EMPTYUNDOBUFFER,0,0)
							fTimer=1
							'
						Case IDM_EDIT_CUT
					        hCtl = GetParent (GetFocus ())
                            Select Case hCtl 
                            Case ah.hred
					            SendMessage hCtl, WM_CUT, 0, 0
					            SetPropertyDirty hCtl
	                        Case ah.hout, ah.himm
					            SendMessage hCtl, WM_CUT, 0, 0
	                        Case ah.hraresed    
					            SendMessage ah.hres, WM_CUT, 0, 0
	                        End Select
							'
					    Case IDM_EDIT_COPY
					        hCtl = GetParent (GetFocus ())
                            Select Case hCtl 
                            Case ah.hred
					            SendMessage hCtl, WM_COPY, 0, 0
					            SetPropertyDirty hCtl
	                        Case ah.hout, ah.himm
					            SendMessage hCtl, WM_COPY, 0, 0
	                        Case ah.hraresed    
					            SendMessage ah.hres, WM_COPY, 0, 0
	                        End Select
							'
						Case IDM_EDIT_PASTE
					        hCtl = GetParent (GetFocus ())
	                        Select Case hCtl
	                        Case ah.hred
					            SendMessage hCtl, WM_PASTE, 0, 0
					            SetPropertyDirty hCtl
	                        Case ah.hout, ah.himm
					            SendMessage hCtl, WM_PASTE, 0, 0
	                        Case ah.hraresed    
					            SendMessage ah.hres, WM_PASTE, 0, 0
	                        End Select
							'
					    Case IDM_EDIT_HISTORYPASTE
                            SendMessage hCBHDlg, CBH_SETTARGET, 0, Cast (LPARAM, GetParent (GetFocus ()))                            
                            SetWindowPos hCBHDlg, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE Or SWP_NOMOVE Or SWP_SHOWWINDOW     
					        
						Case IDM_EDIT_DELETE
					        hCtl = GetParent (GetFocus ())
	                        Select Case hCtl
	                        Case ah.hred
					            SendMessage hCtl, WM_CLEAR, 0, 0
					            SetPropertyDirty hCtl
	                        Case ah.hout, ah.himm
					            SendMessage hCtl, WM_CLEAR, 0, 0
	                        Case ah.hraresed    
					            SendMessage ah.hres, WM_CLEAR, 0, 0
	                        End Select
							'
						Case IDM_EDIT_SELECTALL
    				        hCtl = GetParent (GetFocus ())
					        If hCtl Then
    					        If hCtl = ah.hred OrElse hCtl = ah.hout OrElse hCtl = ah.himm Then
        							SendMessage hCtl, EM_EXSETSEL, 0, Cast (LPARAM, @Type<CHARRANGE>(0, -1))
    					        EndIf
					        EndIf
							'
						Case IDM_EDIT_GOTO
							If gotovisible Then
								SetFocus (gotovisible)
							Else
								CreateDialog (hInstance, MAKEINTRESOURCE (IDD_GOTODLG), GetOwner, @GotoDlgProc)
							EndIf
							'  
					    Case IDM_EDIT_ELEVATOR_UP
                            Elevator ah.hred, VK_UP

					    Case IDM_EDIT_ELEVATOR_DOWN
                            Elevator ah.hred, VK_DOWN
                            					    
						Case IDM_EDIT_FIND
							SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@chrg))

							Select Case GetWindowLong (ah.hred, GWL_ID)
							Case IDC_HEXED
								SetZStrEmpty (buff)             'MOD 26.1.2012 
								If chrg.cpMin<>chrg.cpMax Then
									SendMessage(ah.hred,EM_GETSELTEXT,0,Cast(LPARAM,@buff))
								EndIf
								If IsZStrNotEmpty (buff) Then
									hexfindbuff=buff
								EndIf
								If findvisible Then
									SendDlgItemMessage(ah.hfind,IDC_FINDTEXT,WM_SETTEXT,0,Cast(LPARAM,@hexfindbuff))
									SetFocus(findvisible)
								Else
									CreateDialogParam (hInstance, MAKEINTRESOURCE (IDD_HEXFINDDLG), GetOwner, @HexFindDlgProc, FALSE)
								EndIf
							Case IDC_CODEED, IDC_TEXTED
								If chrg.cpMin<>chrg.cpMax Then
									SendMessage(ah.hred,EM_GETSELTEXT,0,Cast(LPARAM,@buff))
								Else
									SendMessage(ah.hred,REM_GETWORD,260,Cast(LPARAM,@buff))
								EndIf
    						    'GetSubStr 0, buff, buff, VK_RETURN
								If IsZStrNotEmpty (buff) Then
									f.findbuff=buff
								EndIf
								If findvisible Then
									If GetActiveWindow=findvisible Then
										SendMessage(findvisible,WM_CLOSE,0,0)
									Else
										SendDlgItemMessage(ah.hfind,IDC_FINDTEXT,WM_SETTEXT,0,Cast(LPARAM,@f.findbuff))
										SetFocus(findvisible)
									EndIf
								Else
									CreateDialogParam (hInstance, MAKEINTRESOURCE (IDD_FINDDLG) ,GetOwner, @FindDlgProc, FALSE)    ' lparam <> FALSE -> autopress replace button 
								EndIf
							End Select
							'
					    Case IDM_EDIT_FINDNEXT
                            If findvisible = 0 Then          ' simulate Ctrl + F
                                SendMessage hWin, WM_COMMAND, IDM_EDIT_FIND, 0
                            EndIf
    						If GetActiveWindow <> findvisible Then
                                SetFocus findvisible    
                            EndIf
                            If IsDlgItemEnabled (findvisible, IDC_RBN_DOWN) Then
                                SendDlgItemMessage findvisible, IDC_RBN_DOWN, BM_CLICK, 0, 0
                                If IsDlgItemEnabled (findvisible, IDOK) Then
                                    SendDlgItemMessage findvisible, IDOK, BM_CLICK, 0, 0
                                Else
                                    TextToOutput "*** search service not available ***", MB_ICONASTERISK
                                EndIf    
                            Else
                                TextToOutput "*** search direction not available ***", MB_ICONASTERISK
                            EndIf
                            'SetFocus ah.hred
                            'SendMessage(findvisible,WM_COMMAND,MAKEWPARAM(IDC_RBN_DOWN,BN_CLICKED),0)
                            'SendMessage(findvisible,WM_COMMAND,MAKEWPARAM(IDOK,BN_CLICKED),0)
							'If findvisible Then
							'	SendMessage(findvisible,WM_COMMAND,MAKEWPARAM(IDOK,BN_CLICKED),0)
							'	SetFocus(findvisible)
							'Else
							'	If IsZStrNotEmpty (f.findbuff) AndAlso EditorHasFocus<>0 Then
							'		Find(hWin,f.fr Or FR_DOWN)
							'		SetFocus(ah.hred)
							'	EndIf
							'EndIf
							'
						Case IDM_EDIT_FINDPREVIOUS
                            If findvisible = 0 Then
                                SendMessage hWin, WM_COMMAND, IDM_EDIT_FIND, 0
                            EndIf
    						If GetActiveWindow <> findvisible Then
                                SetFocus findvisible    
                            EndIf
                            If IsDlgItemEnabled (findvisible, IDC_RBN_UP) Then
                                SendDlgItemMessage findvisible, IDC_RBN_UP, BM_CLICK, 0, 0
                                If IsDlgItemEnabled (findvisible, IDOK) Then
                                    SendDlgItemMessage findvisible, IDOK, BM_CLICK, 0, 0
                                Else
                                    TextToOutput "*** search service not available ***", MB_ICONASTERISK
                                EndIf    
                            Else
                                TextToOutput "*** search direction not available ***", MB_ICONASTERISK
                            EndIf
							'If IsZStrNotEmpty (f.findbuff) AndAlso EditorHasFocus<>0 Then
							'	Dim ft As FINDTEXTEX
							'	SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@ft.chrg))
							'	ft.chrg.cpMax=0
							'	ft.chrg.cpMin-=1
							'	ft.lpstrText=@f.findbuff
							'	If SendMessage(ah.hred,EM_FINDTEXTEX,f.fr Xor FR_DOWN,Cast(LPARAM,@ft))=-1 Then
							'		MessageBox(hWin,GetInternalString(IS_REGION_SEARCHED),@szAppName,MB_OK Or MB_ICONINFORMATION)
							'	Else
							'		SendMessage(ah.hred,EM_EXSETSEL,0,Cast(LPARAM,@ft.chrgText))
							'	EndIf
							'EndIf
							'
						Case IDM_EDIT_REPLACE
							SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@chrg))
							Select Case GetWindowLong (ah.hred, GWL_ID)
							Case IDC_HEXED
								SetZStrEmpty (buff)             'MOD 26.1.2012 
								If chrg.cpMin<>chrg.cpMax Then
									SendMessage(ah.hred,EM_GETSELTEXT,0,Cast(LPARAM,@buff))
								'Else
								'	SendMessage(ah.hred,REM_GETWORD,260,Cast(LPARAM,@buff))
								EndIf
								If IsZStrNotEmpty (buff) Then
									hexfindbuff=buff
								EndIf
								If findvisible Then
									SendDlgItemMessage(ah.hfind,IDC_HEXFINDTEXT,WM_SETTEXT,0,Cast(LPARAM,@hexfindbuff))
									SetFocus(findvisible)
								Else
									CreateDialogParam (hInstance, MAKEINTRESOURCE (IDD_HEXFINDDLG), GetOwner, @HexFindDlgProc, TRUE)
								EndIf
							Case IDC_CODEED, IDC_TEXTED
								If chrg.cpMin<>chrg.cpMax Then
									SendMessage(ah.hred,EM_GETSELTEXT,0,Cast(LPARAM,@buff))
								Else
									SendMessage(ah.hred,REM_GETWORD,260,Cast(LPARAM,@buff))
								EndIf
							    'GetSubStr 0, buff, buff, VK_RETURN
								If IsZStrNotEmpty (buff) Then
									f.findbuff=buff
								EndIf
								If findvisible Then
									If GetActiveWindow=findvisible Then
										SendMessage(findvisible,WM_CLOSE,0,0)
									Else
										SendDlgItemMessage(ah.hfind,IDC_FINDTEXT,WM_SETTEXT,0,Cast(LPARAM,@f.findbuff))
										SetFocus(findvisible)
									EndIf
								Else
									CreateDialogParam (hInstance, MAKEINTRESOURCE (IDD_FINDDLG), GetOwner, @FindDlgProc, TRUE)    ' TRUE = show replace dialog version
								EndIf
							End Select	
							'
						Case IDM_EDIT_FINDDECLARE
							If EditorHasFocus () Then
								SendMessage(ah.hred,REM_GETWORD,260,Cast(Integer,@buff))
								If fProject Then
								    SendMessage ah.hpr, PRM_SETSELBUTTON, 3, 0
								Else
								    SendMessage ah.hpr, PRM_SETSELBUTTON, 2, 0
								EndIf    
								POL_Changed = TRUE
								UpdateProperty  
								lret=Cast(Integer,FindExact(StrPtr("pdcsme"),@buff,TRUE))
								If lret Then
									i=SendMessage(ah.hpr,PRM_FINDGETLINE,0,0)
									'hCtl=ah.hred
									SendMessage(ah.hred,EM_EXGETSEL,0,Cast(Integer,@chrg))
                                    'CaretPosEnqueue ah.hred, chrg.cpMin
									'nLine=chrg.cpMin
									lret=SendMessage(ah.hpr,PRM_FINDGETOWNER,0,0)
									
									If      IsWindow (Cast (HWND, lret)) _
                    				AndAlso GetWindowLong (Cast (HWND, lret), GWL_ID) = IDC_CODEED Then
                    				    SelectTabByWindow Cast (HWND, lret)
									Else
                    				    SelectTabByFileID lret
                    				EndIf
									'If fProject Then
									'	OpenTheFile (*GetProjectFileName (lret, PT_ABSOLUTE), FOM_STD)
									'Else
									'	SelectTabByWindow(Cast(HWND,lret))   ' MOD 1.2.2012 removed hWin
									'	'SetFocus(ah.hred)
									'EndIf
									GotoTextLine ah.hred, i, TRUE            ' MOD 21.1.2012
									'chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,i,0)
									'chrg.cpMax=chrg.cpMin
									'SendMessage(ah.hred,EM_EXSETSEL,0,Cast(Integer,@chrg))
									'SendMessage(ah.hred,EM_SCROLLCARET,0,0)
									'SendMessage(ah.hred,REM_VCENTER,0,0)
									SetFocus(ah.hred)
                                    fTimer = 1
								Else
								    TextToOutput "*** symbol not recognized ***", &hFFFFFFFF
								EndIf
								'fTimer=1
							EndIf
							'
					    Case IDM_EDIT_BACKWARD
							If EditorHasFocus () Then
								CH.GoBackward
								fTimer = 1
							EndIf

					    Case IDM_EDIT_FORWARD
							If EditorHasFocus () Then
								CH.GoForward
								fTimer = 1
							EndIf
							'
						Case IDM_EDIT_BLOCKINDENT
							If EditorHasFocus () Then
								IndentComment(Chr(9),FALSE)
							EndIf
							'
						Case IDM_EDIT_BLOCKOUTDENT
							If EditorHasFocus () Then
								IndentComment(Chr(9),TRUE)
							EndIf
							'
						Case IDM_EDIT_BLOCKCOMMENT
							If EditorHasFocus () Then
								IndentComment("'" & szNULL,FALSE)
								SetPropertyDirty ah.hred 
							EndIf
							'
						Case IDM_EDIT_BLOCKUNCOMMENT
							If EditorHasFocus () Then
								IndentComment("'" & szNULL,TRUE)
								If GetWindowLong (ah.hred, GWL_ID) = IDC_CODEED Then
									SendMessage(ah.hred,REM_SETBLOCKS,0,0)
									SetPropertyDirty ah.hred 
								EndIf
							EndIf
							'
						Case IDM_EDIT_BLOCKTRIM
							If EditorHasFocus () Then
								TrimTrailingSpaces
								If GetWindowLong(ah.hred,GWL_ID)=IDC_CODEED Then
									SendMessage(ah.hred,REM_SETBLOCKS,0,0)
								EndIf
							EndIf
							'    
						Case IDM_EDIT_CONVERTTAB 
                            If EditorHasFocus () Then
                                SendMessage(ah.hred,REM_CONVERT,CONVERT_TABTOSPACE,0)
                            EndIf
							'               
						Case IDM_EDIT_CONVERTSPACE           
							If EditorHasFocus () Then
								SendMessage(ah.hred,REM_CONVERT,CONVERT_SPACETOTAB,0)
							EndIf
							'
						Case IDM_EDIT_CONVERTUPPER
							If EditorHasFocus () Then
								SendMessage(ah.hred,REM_CONVERT,CONVERT_UPPERCASE,0)
							EndIf
							'
						Case IDM_EDIT_CONVERTLOWER
							If EditorHasFocus () Then
								SendMessage(ah.hred,REM_CONVERT,CONVERT_LOWERCASE,0)
							EndIf
							'
						Case IDM_EDIT_BLOCKMODE
							If EditorHasFocus () Then
								BlockModeToggle              ' MOD 20.1.2012
						        SbarSetBlockMode
							EndIf
							'
						Case IDM_EDIT_BLOCK_INSERT
							DialogBox(hInstance,Cast(ZString Ptr,IDD_BLOCKDLG),GetOwner,@BlockDlgProc)
							'
						Case IDM_EDIT_BOOKMARKTOGGLE
							If EditorHasFocus () Then
								id=GetWindowLong(ah.hred,GWL_ID)
								If id=IDC_HEXED Then
									SendMessage(ah.hred,HEM_TOGGLEBOOKMARK,nLastLine,0)    ' MOD 22.2.2ß12   SendMessage(ah.hred,HEM_TOGGLEBOOKMARK,0,0) 
								Else
									Select Case SendMessage(ah.hred,REM_GETBOOKMARK,nLastLine,0)
									Case BMT_NONE
										SendMessage(ah.hred,REM_SETBOOKMARK,nLastLine,BMT_STD)
									Case BMT_STD
										SendMessage(ah.hred,REM_SETBOOKMARK,nLastLine,BMT_NONE)
									End Select
								EndIf
								fTimer = 1
							EndIf
							'
						Case IDM_EDIT_BOOKMARKNEXT
							If EditorHasFocus () Then
								id=GetWindowLong(ah.hred,GWL_ID)
								If id=IDC_HEXED Then
									If SendMessage(ah.hred,HEM_NEXTBOOKMARK,0,Cast(LPARAM,@hebm)) Then
										SelectTabByWindow(hebm.hWin)                       ' MOD 1.2.2012 removed ah.hwnd
										chrg.cpMin=hebm.nLine Shl 5
										chrg.cpMax=chrg.cpMin
										SetFocus(ah.hred)
										SendMessage(ah.hred,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
										SendMessage(ah.hred,EM_SCROLLCARET,0,0)
									EndIf
								Else
									nLine=SendMessage(ah.hred,REM_NXTBOOKMARK,nLastLine,BMT_STD)
									If nLine<>-1 Then
									    GotoTextLine ah.hred, nLine, FALSE           ' MOD 21.1.2012
									    'chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,nLine,0)
										'chrg.cpMax=chrg.cpMin
										'SendMessage(ah.hred,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
										'SendMessage(ah.hred,EM_SCROLLCARET,0,0)
									EndIf
								EndIf
							EndIf
							'
						Case IDM_EDIT_BOOKMARKPREVIOUS
							If EditorHasFocus () Then
								id=GetWindowLong(ah.hred,GWL_ID)
								If id=IDC_HEXED Then
									If SendMessage(ah.hred,HEM_PREVIOUSBOOKMARK,0,Cast(LPARAM,@hebm)) Then
										SelectTabByWindow(hebm.hWin)                       ' MOD 1.2.2012 removed ah.hwnd
										chrg.cpMin=hebm.nLine Shl 5
										chrg.cpMax=chrg.cpMin
										SetFocus(ah.hred)
										SendMessage(ah.hred,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
										SendMessage(ah.hred,EM_SCROLLCARET,0,0)
									EndIf
								Else
									nLine=SendMessage(ah.hred,REM_PRVBOOKMARK,nLastLine,BMT_STD)
									If nLine<>-1 Then
									    GotoTextLine ah.hred, nLine, FALSE           ' MOD 21.1.2012
										'chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,nLine,0)
										'chrg.cpMax=chrg.cpMin
										'SendMessage(ah.hred,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
										'SendMessage(ah.hred,EM_SCROLLCARET,0,0)
									EndIf
								EndIf
							EndIf
							'
						Case IDM_EDIT_BOOKMARKDELETE
							If EditorHasFocus () Then
								id=GetWindowLong(ah.hred,GWL_ID)
								If id=IDC_HEXED Then
									SendMessage(ah.hred,HEM_CLEARBOOKMARKS,0,0)
								Else
									SendMessage(ah.hred,REM_CLRBOOKMARKS,0,BMT_STD)
								EndIf
								fTimer = 1
							EndIf
							'
					    Case IDM_EDIT_BOOKMARKLIST 
					        ListAllBookmarks 
					         
						Case IDM_EDIT_ERRORCLEAR
							If EditorHasFocus () Then
								UpdateAllTabs (2)                         ' clear errors
							EndIf
							'
						Case IDM_EDIT_ERRORNEXT
							If EditorHasFocus () Then
								nLine=SendMessage(ah.hred,REM_NEXTERROR,nLastLine,0)
								If nLine=-1 Then
									nLine=SendMessage(ah.hred,REM_NEXTERROR,-1,7)
								EndIf
								If nLine<>-1 Then
								    GotoTextLine ah.hred, nLine, FALSE           ' MOD 21.1.2012
									'chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,nLine,0)
									'chrg.cpMax=chrg.cpMin
									'SendMessage(ah.hred,EM_EXSETSEL,0,Cast(Integer,@chrg))
									'SendMessage(ah.hred,EM_SCROLLCARET,0,0)
								EndIf
							EndIf
							'
						Case IDM_EDIT_EXPAND
							If EditorHasFocus () Then
								SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@chrg))
								i=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMin)
								bm=SendMessage(ah.hred,REM_GETBOOKMARK,i,0)
								If bm=BMT_COLLAPSE Then
									' Collapse
									SendMessage(ah.hred,REM_COLLAPSE,i,0)
								ElseIf bm=BMT_EXPAND Then
									' Expand
									SendMessage(ah.hred,REM_EXPAND,i,0)
								ElseIf SendMessage(ah.hred,REM_ISLINEHIDDEN,i+1,0) Then
									While SendMessage(ah.hred,REM_ISLINEHIDDEN,i+1,0)
										SendMessage(ah.hred,REM_HIDELINE,i+1,FALSE)
										i=i+1
									Wend
									SendMessage(ah.hred,REM_REPAINT,0,0)
								ElseIf SendMessage(ah.hred,REM_ISLINEHIDDEN,i-1,0)<>0 Or SendMessage(ah.hred,REM_GETBOOKMARK,i-1,0)=BMT_EXPAND Then
									i=i-1
									While SendMessage(ah.hred,REM_ISLINEHIDDEN,i,0)And i>0
										i=SendMessage(ah.hred,REM_PRVBOOKMARK,i,BMT_EXPAND)
									Wend
									SendMessage(ah.hred,REM_EXPAND,i,0)
									SendMessage(ah.hred,REM_COLLAPSE,i,0)
								EndIf
							EndIf
							'
						Case IDM_FORMAT_LOCK
							x=SendMessage(ah.hraresed,DEM_ISLOCKED,0,0) Xor TRUE
							SendMessage(ah.hraresed,DEM_LOCKCONTROLS,0,x)
							fTimer = 1
							'
						Case IDM_FORMAT_BACK
							SendMessage(ah.hraresed,DEM_SENDTOBACK,0,0)
							'
						Case IDM_FORMAT_FRONT
							SendMessage(ah.hraresed,DEM_BRINGTOFRONT,0,0)
							'
						Case IDM_FORMAT_GRID
							x=GetWindowLong(ah.hraresed,GWL_STYLE) Xor DES_GRID
							SetWindowLong(ah.hraresed,GWL_STYLE,x)
							fTimer=1
							'
						Case IDM_FORMAT_SNAP
							x=GetWindowLong(ah.hraresed,GWL_STYLE) Xor DES_SNAPTOGRID
							SetWindowLong(ah.hraresed,GWL_STYLE,x)
							fTimer=1
							'
						Case IDM_FORMAT_ALIGN_LEFT
							SendMessage(ah.hraresed,DEM_ALIGNSIZE,0,ALIGN_LEFT)
							'
						Case IDM_FORMAT_ALIGN_CENTER
							SendMessage(ah.hraresed,DEM_ALIGNSIZE,0,ALIGN_CENTER)
							'
						Case IDM_FORMAT_ALIGN_RIGHT
							SendMessage(ah.hraresed,DEM_ALIGNSIZE,0,ALIGN_RIGHT)
							'
						Case IDM_FORMAT_ALIGN_TOP
							SendMessage(ah.hraresed,DEM_ALIGNSIZE,0,ALIGN_TOP)
							'
						Case IDM_FORMAT_ALIGN_MIDDLE
							SendMessage(ah.hraresed,DEM_ALIGNSIZE,0,ALIGN_MIDDLE)
							'
						Case IDM_FORMAT_ALIGN_BOTTOM
							SendMessage(ah.hraresed,DEM_ALIGNSIZE,0,ALIGN_BOTTOM)
							'
						Case IDM_FORMAT_SIZE_WIDTH
							SendMessage(ah.hraresed,DEM_ALIGNSIZE,0,SIZE_WIDTH)
							'
						Case IDM_FORMAT_SIZE_HEIGHT
							SendMessage(ah.hraresed,DEM_ALIGNSIZE,0,SIZE_HEIGHT)
							'
						Case IDM_FORMAT_SIZE_BOTH
							SendMessage(ah.hraresed,DEM_ALIGNSIZE,0,SIZE_BOTH)
							'
						Case IDM_FORMAT_CENTER_HOR
							SendMessage(ah.hraresed,DEM_ALIGNSIZE,0,ALIGN_DLGHCENTER)
							'
						Case IDM_FORMAT_CENTER_VER
							SendMessage(ah.hraresed,DEM_ALIGNSIZE,0,ALIGN_DLGVCENTER)
							'
						Case IDM_FORMAT_TAB
							SendMessage(ah.hraresed,DEM_SHOWTABINDEX,0,0)
							'
						Case IDM_FORMAT_RENUM
							SendMessage(ah.hraresed,DEM_AUTOID,0,0)
							'
						Case IDM_FORMAT_CASECONVERT
							If EditorHasFocus () Then
								If edtopt.autocase Then
									CaseConvert(ah.hred)
								EndIf
							EndIf
							'
						Case IDM_FORMAT_INDENT
							If EditorHasFocus () Then
								FormatIndent(ah.hred)
							EndIf
							'
						Case IDM_VIEW_OUTPUT
							wpos.fview=wpos.fview Xor VIEW_OUTPUT
							SendMessage(hWin,WM_SIZE,SIZE_RESTORED,0)
							ShowWindow(ah.hout,IIf(wpos.fview And VIEW_OUTPUT,SW_SHOWNA,SW_HIDE))
							SendMessage(ah.htoolbar,TB_CHECKBUTTON,IDM_VIEW_OUTPUT,wpos.fview And VIEW_OUTPUT)
							If ah.hred Then
								SetFocus(ah.hred)
							EndIf
							fTimer=1
							'
						Case IDM_VIEW_IMMEDIATE
							wpos.fview=wpos.fview Xor VIEW_IMMEDIATE
							SendMessage(hWin,WM_SIZE,SIZE_RESTORED,0)
							ShowWindow(ah.himm,IIf(wpos.fview And VIEW_IMMEDIATE,SW_SHOWNA,SW_HIDE))
							SendMessage(ah.htoolbar,TB_CHECKBUTTON,IDM_VIEW_IMMEDIATE,wpos.fview And VIEW_IMMEDIATE)
							If ah.hred Then
								SetFocus(ah.hred)
							EndIf
							fTimer=1
							'
						Case IDM_VIEW_PROJECT
							wpos.fview=wpos.fview Xor VIEW_PROJECT
							SendMessage(hWin,WM_SIZE,SIZE_RESTORED,0)
							If wpos.fview And VIEW_PROJECT Then
								ShowWindow(ah.htab,SW_SHOWNA)
								ShowProjectTab
								SendMessage(ah.htoolbar,TB_CHECKBUTTON,IDM_VIEW_PROJECT,TRUE)
							Else
								ShowWindow(ah.htab,SW_HIDE)
								ShowWindow(ah.hfib,SW_HIDE)
								ShowWindow(ah.hprj,SW_HIDE)
								SendMessage(ah.htoolbar,TB_CHECKBUTTON,IDM_VIEW_PROJECT,FALSE)
							EndIf
							fTimer=1
							'
						Case IDM_VIEW_PROPERTY
							wpos.fview=wpos.fview Xor VIEW_PROPERTY
							SendMessage(hWin,WM_SIZE,SIZE_RESTORED,0)
							If wpos.fview And VIEW_PROPERTY Then
								ShowWindow(ah.hpr,SW_SHOWNA)
								SendMessage(ah.htoolbar,TB_CHECKBUTTON,IDM_VIEW_PROPERTY,TRUE)
							Else
								ShowWindow(ah.hpr,SW_HIDE)
								SendMessage(ah.htoolbar,TB_CHECKBUTTON,IDM_VIEW_PROPERTY,FALSE)
							EndIf
							fTimer=1
							'
						Case IDM_VIEW_TOOLBAR
							wpos.fview=wpos.fview Xor VIEW_TOOLBAR
							hCtl=GetDlgItem(hWin,IDC_DIVIDER2)
							If wpos.fview And VIEW_TOOLBAR Then
								ShowWindow(ah.htoolbar,SW_SHOWNA)
								ShowWindow(ah.hcbobuild,SW_SHOWNA)
								ShowWindow(hCtl,SW_SHOWNA)
							Else
								ShowWindow(ah.htoolbar,SW_HIDE)
								ShowWindow(ah.hcbobuild,SW_HIDE)
								ShowWindow(hCtl,SW_HIDE)
							EndIf
							SendMessage(hWin,WM_SIZE,SIZE_RESTORED,0)
							InvalidateRect(ah.hshp,NULL,TRUE)
							fTimer=1
							'
						Case IDM_VIEW_TABSELECT
							wpos.fview=wpos.fview Xor VIEW_TABSELECT
							hCtl=GetDlgItem(hWin,IDM_FILE_CLOSE)
							If wpos.fview And VIEW_TABSELECT Then
								ShowWindow(ah.htabtool,SW_SHOWNA)
								ShowWindow(hCtl,SW_SHOWNA)
								hCtl=GetDlgItem(hWin,IDC_DIVIDER)
								ShowWindow(hCtl,SW_SHOWNA)
							Else
								ShowWindow(ah.htabtool,SW_HIDE)
								ShowWindow(hCtl,SW_HIDE)
								hCtl=GetDlgItem(hWin,IDC_DIVIDER)
								ShowWindow(hCtl,SW_HIDE)
							EndIf
							SendMessage(hWin,WM_SIZE,SIZE_RESTORED,0)
							InvalidateRect(ah.hshp,NULL,TRUE)
							fTimer=1
						Case IDM_VIEW_STATUSBAR
							wpos.fview=wpos.fview Xor VIEW_STATUSBAR
							If wpos.fview And VIEW_STATUSBAR Then
								ShowWindow(ah.hsbr,SW_SHOWNA)
							Else
								ShowWindow(ah.hsbr,SW_HIDE)
							EndIf
							SendMessage(hWin,WM_SIZE,SIZE_RESTORED,0)
							fTimer=1
						Case IDM_VIEW_DIALOG
							x = SendMessage (ah.hraresed, DEM_SHOWDIALOG, 0, 0)
							'
						Case IDM_VIEW_SPLITSCREEN
							id=GetWindowLong(ah.hred,GWL_ID)
							If id=IDC_HEXED Then
								x=SendMessage(ah.hred,HEM_GETSPLIT,0,0)
								If x Then
									x=0
								Else
									x=500
								EndIf
								SendMessage(ah.hred,HEM_SETSPLIT,x,0)
							Else
								x=SendMessage(ah.hred,REM_GETSPLIT,0,0)
								If x Then
									x=0
								Else
									x=500
								EndIf
								SendMessage(ah.hred,REM_SETSPLIT,x,0)
							EndIf
							SetFocus(ah.hwnd)
							SetFocus(ah.hred)
							'
						Case IDM_VIEW_FULLSCREEN
							If ah.hfullscreen Then
								hMnu = GetSubMenu (GetMenu (ah.hwnd), 1)
								DeleteMenu hMnu, IDM_VIEW_FULLSCREEN, MF_BYCOMMAND	
								DestroyWindow(ah.hfullscreen)
								SendMessage(hWin,WM_SIZE,SIZE_RESTORED,0)
							Else
								ah.hfullscreen=CreateWindowEx(NULL,@szFullScreenClassName,NULL,WS_POPUP Or WS_VISIBLE Or WS_MAXIMIZE,0,0,0,0,hWin,NULL,hInstance,NULL)
								SetFullScreen(ah.hred)
								hMnu = GetSubMenu (GetMenu (ah.hwnd), 1)
								buff = GetInternalString (IS_EXITFULLSCREEN)
								AppendMenu hMnu, MF_STRING, IDM_VIEW_FULLSCREEN, @buff
							EndIf
							'
						Case IDM_VIEW_DUALPANE
							If ah.hpane(0) Then
								If ah.hpane(1) Then
									ShowWindow(ah.hpane(1),SW_HIDE)
								Else
									ShowWindow(ah.hshp,SW_HIDE)
								EndIf
								ah.hred=ah.hpane(0)
								ah.hpane(0)=0
								ah.hpane(1)=0
								SelectTabByWindow(ah.hred)                   ' MOD 1.2.2012 removed ah.hwnd
								SetFocus(ah.hred)
							Else
								ah.hpane(0)=ah.hred
								ah.hpane(1)=0
							EndIf
							SendMessage(hWin,WM_SIZE,SIZE_RESTORED,0)
							'
						Case IDM_PROJECT_ADDNEWFILE
							AddNewProjectFile()
							'
						Case IDM_PROJECT_ADDNEWMODULE
							AddNewProjectModule
							'
						Case IDM_PROJECT_ADDEXISTINGFILE
							AddExistingProjectFile()
							'
						Case IDM_PROJECT_ADDEXISTINGMODULE
							AddExistingProjectModule
							'
						Case IDM_PROJECT_SETMAIN
							GetTrvSelItemData sFile, FileID, hTVItem, PT_RELATIVE
							If FileID > 1000 Then 
								TextToOutput "*** module remarked as assembly ***", MB_ICONHAND
								ToggleProjectFile FileID                 ' FileID changed inside
							EndIf
							SetAsMainFile FileID
							'
						Case IDM_PROJECT_TOGGLE
							GetTrvSelItemData sFile, FileID, hTVItem, PT_RELATIVE
							If FileID = nMain Then
								TextToOutput "*** cancelled: main file selected ***", MB_ICONHAND
							Else
								ToggleProjectFile FileID                 ' FileID changed inside
							EndIf
							'
    					Case IDM_PROJECT_REMOVE
   							GetTrvSelItemData sFile, FileID, hTVItem, PT_RELATIVE
							RemoveProjectFile FileID, hTVItem, FALSE
							'
						Case IDM_PROJECT_RENAME
							SetFocus(ah.hprj)
							lret=SendMessage(ah.hprj,TVM_GETNEXTITEM,TVGN_CARET,0)
							If lret<>SendMessage(ah.hprj,TVM_GETNEXTITEM,TVGN_ROOT,0) Then
								SendMessage(ah.hprj,TVM_EDITLABEL,0,lret)
							EndIf
							'
    					Case IDM_PROJECT_INCLUDE
   							GetTrvSelItemData sFile, 0, 0, PT_RELATIVE
							InsertInclude sFile, IM_INCLUDE
							SetFocus ah.hred
						
						Case IDM_PROJECT_INCLUDE_ONCE
   							GetTrvSelItemData sFile, 0, 0, PT_RELATIVE
							InsertInclude sFile, IM_INCLUDEONCE
							SetFocus ah.hred
							'
						Case IDM_PROJECT_OPTIONS
							DialogBox(hInstance,Cast(ZString Ptr,IDD_DLGPROJECTOPTION),hWin,@ProjectOptionDlgProc)
							'
						Case IDM_PROJECT_CREATETEMPLATE
							DialogBox(hInstance,Cast(ZString Ptr,IDD_CREATETEMPLATE),hWin,@CreateTemplateDlgProc)
							'
						Case IDM_RESOURCE_DIALOG
							SendMessage(ah.hraresed,PRO_ADDITEM,TPE_DIALOG,TRUE)
							'
						Case IDM_RESOURCE_MENU
							SendMessage(ah.hraresed,PRO_ADDITEM,TPE_MENU,TRUE)
							'
						Case IDM_RESOURCE_ACCEL
							SendMessage(ah.hraresed,PRO_ADDITEM,TPE_ACCEL,TRUE)
							'
						Case IDM_RESOURCE_STRINGTABLE
							SendMessage(ah.hraresed,PRO_ADDITEM,TPE_STRING,TRUE)
							'
						Case IDM_RESOURCE_VERSION
							SendMessage(ah.hraresed,PRO_ADDITEM,TPE_VERSION,TRUE)
							'
						Case IDM_RESOURCE_XPMANIFEST
							SendMessage(ah.hraresed,PRO_ADDITEM,TPE_XPMANIFEST,TRUE)
							'
						Case IDM_RESOURCE_RCDATA
							SendMessage(ah.hraresed,PRO_ADDITEM,TPE_RCDATA,TRUE)
							'
						Case IDM_RESOURCE_LANGUAGE
							SendMessage(ah.hraresed,PRO_ADDITEM,TPE_LANGUAGE,TRUE)
							'
						Case IDM_RESOURCE_INCLUDE
							SendMessage(ah.hraresed,PRO_ADDITEM,TPE_INCLUDE,TRUE)
							'
						Case IDM_RESOURCE_RES
							SendMessage(ah.hraresed,PRO_ADDITEM,TPE_RESOURCE,TRUE)
							'
						Case IDM_RESOURCE_NAMES
							ah.hrareseddlg = Cast (HWND, SendMessage (ah.hraresed, PRO_SHOWNAMES, 0, Cast (LPARAM, ah.hout)))
							'
						Case IDM_RESOURCE_EXPORT
							SendMessage(ah.hraresed,PRO_EXPORTNAMES,0,Cast(Integer,ah.hout))
							'
						Case IDM_RESOURCE_REMOVE
							SendMessage(ah.hraresed,PRO_DELITEM,0,0)
							'
						Case IDM_RESOURCE_UNDO
							SendMessage(ah.hraresed,PRO_UNDODELETED,0,0)
							'
						Case IDM_MAKE_COMPILE
							fQR=FALSE
							Return Compile(ad.smake)
							'
						Case IDM_MAKE_GO
							'fQR=FALSE
							lret = SendMessage (ah.hwnd, WM_COMMAND, IDM_MAKE_COMPILE, 0)
							If lret = 0 Then
							    SendMessage ah.hwnd, WM_COMMAND, IDM_MAKE_RUN, 0
								'If fProject Then
								'	' MOD 17.2.2012
								'	sFile = *GetProjectFileName (nMain, PT_RELATIVE)
								'	'sFile=GetProjectFile(GetPrivateProfileInt(StrPtr("File"),StrPtr("Main"),1,ad.ProjectFile))
								'	' ============
								'Else
								'	sFile=ad.filename
								'EndIf
								'If IsZStrNotEmpty (ad.smakeoutput) Then
								'	sFile=ad.ProjectPath & "\" & ad.smakeoutput
								'EndIf
								'MakeRun(sFile,FALSE)
							EndIf
							'
					    Case IDM_MAKE_RUN
							fQR = FALSE
							If IsZStrNotEmpty (ad.smakeoutput) Then
								sFile = ad.smakeoutput                                 ' MOD sFile = ad.ProjectPath & "\" & ad.smakeoutput
							ElseIf fProject Then
							    sFile = *GetProjectFileName (nMain, PT_RELATIVE)	   ' MOD sFile=GetProjectFile(GetPrivateProfileInt(StrPtr("File"),StrPtr("Main"),1,ad.ProjectFile))
							Else
							    sFile = ad.filename
							EndIf
							MakeRun sFile, FALSE
							'
						Case IDM_MAKE_RUNDEBUG
							fQR = FALSE
							If IsZStrNotEmpty (ad.smakeoutput) Then
								sFile = ad.smakeoutput
							ElseIf fProject Then
							    sFile = *GetProjectFileName (nMain, PT_RELATIVE)	   ' MOD sFile=GetProjectFile(GetPrivateProfileInt(StrPtr("File"),StrPtr("Main"),1,ad.ProjectFile))
							Else
							    sFile = ad.filename
							EndIf
							MakeRun sFile, TRUE 
							'
						Case IDM_MAKE_MODULE
							fQR=FALSE
							TextToOutput !"compiling modules:\13"
							CompileModules                                             ' usually called by Function: Compile (), which doing the log
    						HLineToOutput
							'
						Case IDM_MAKE_QUICKRUN
							KillQuickRun
							bm=wpos.fview And VIEW_OUTPUT
							UpdateAllTabs (2)                         ' clear errors

							If ad.filename="(Untitled).bas" Then
								sItem=ad.AppPath
							Else
								sItem=ad.filename
								GetFilePath(sItem)
							EndIf
							sItem=sItem & "\FbTemp.bas"
							If fProject Then
								sItem=*RemoveProjectPath(sItem)
								SetCurrentDirectory(ad.ProjectPath)						
							Else
								GetFilePath(sItem)
								SetCurrentDirectory(sItem)
								sItem="FbTemp.bas"
							EndIf
							SaveTempFile(ah.hred,sItem)
							sFile=sItem
							lret=MakeBuild(ad.fbcPath & "\" & ad.smakequickrun,sItem,"QuickRun",FALSE,FALSE,TRUE)
							DeleteFile(StrPtr(sFile))
							If lret=0 Then
								If bm=0 Then
									nHideOut=15
								EndIf
								szQuickRun=Left(sFile,Len(sFile)-3) & "exe"
								makeinf.hThread=CreateThread(NULL,NULL,Cast(Any Ptr,@ProcessQuickRun),0,NORMAL_PRIORITY_CLASS,@x)
							Else
								fQR=TRUE
								nHideOut=0
							EndIf
							'
						Case IDM_TOOLS_EXPORT
							DialogBox(hInstance,Cast(ZString Ptr,IDD_DLGEXPORT),hWin,@ExportDlgProc)
							'
						Case IDM_OPTIONS_LANGUAGE
							DialogBox(hInstance,Cast(ZString Ptr,IDD_DLGLANGUAGE),hWin,@LanguageDlgProc)
							'
						Case IDM_OPTIONS_CODE
							DialogBox(hInstance,Cast(ZString Ptr,IDD_DLGKEYWORDS),hWin,@KeyWordsDlgProc)
							'
						Case IDM_OPTIONS_DIALOG
							DialogBox(hInstance,Cast(ZString Ptr,IDD_TABOPTIONS),hWin,@TabOptionsProc)
							'
						'Case IDM_OPTIONS_PATH
							'DialogBox(hInstance,Cast(ZString Ptr,IDD_DLGPATHOPTION),hWin,@PathOptDlgProc)
							'
						Case IDM_OPTIONS_DEBUG
							DialogBox(hInstance,Cast(ZString Ptr,IDD_DLGDEBUGOPT),hWin,@DebugOptDlgProc)
							'
						Case IDM_OPTIONS_MAKE
							i = DialogBoxParam (hInstance, MAKEINTRESOURCE (IDD_DLGOPTMNU), hWin, @GenericOptDlgProc, GODM_MakeOptCollection)
		                    If i Then 
		                        WritePrivateProfileString @"Make", @"Current", Str (i), @ad.IniFile
                        		GetMakeOption
		                    EndIf
						'	'
						'Case IDM_OPTIONS_EXTERNALFILES
						'	DialogBox(hInstance,Cast(ZString Ptr,IDD_DLGEXTERNALFILE),hWin,@ExternalFileDlgProc)
							'
						Case IDM_OPTIONS_ADDINS
							DialogBox(hInstance,Cast(ZString Ptr,IDD_DLGADDINMANAGER),hWin,@AddinManagerProc)
							'
					    Case IDM_OPTIONS_ENVIRONMENT 
					        DialogBox (hInstance, MAKEINTRESOURCE (IDD_DLG_ENVIRON), hWin, @EnvironProc) 
					        GetMakeOption
					        '
						Case IDM_OPTIONS_TOOLS
							DialogBoxParam (hInstance, MAKEINTRESOURCE (IDD_DLGOPTMNU), hWin, @GenericOptDlgProc, GODM_ToolsMenu)
                       		MakeSubMenu IDM_TOOLS, IDM_TOOLS_USER_1, IDM_TOOLS_USER_LAST, "Tools"
		                    CallAddins(ah.hwnd,AIM_MENUREFRESH,0,0,HOOK_MENUREFRESH)
							'
						Case IDM_OPTIONS_HELP
							DialogBoxParam (hInstance, MAKEINTRESOURCE (IDD_DLGOPTMNU), hWin, @GenericOptDlgProc, GODM_HelpMenu)
    						MakeSubMenu IDM_HELP, IDM_HELP_USER_1, IDM_HELP_USER_LAST, "Help"
	                    	CallAddins(ah.hwnd,AIM_MENUREFRESH,0,0,HOOK_MENUREFRESH)
							'
						Case IDM_HELP_ABOUT
							DialogBox (hInstance, MAKEINTRESOURCE (IDD_DLGABOUT), hWin, @AboutDlgProc)
							SetFocus(ah.hred)
							'
					    Case IDM_HELPF1, IDM_HELPCTRLF1
					        If id = IDM_HELPF1 Then 
					            pZStr = @"F1"
					        Else
					            pZStr = @"CtrlF1"
					        EndIf
					        GetPrivateProfileSpec "Help", pZStr, @ad.IniFile, @buff, GPP_Expanded Or GPP_MustExist

							If IsZStrNotEmpty (buff) Then
							    If ah.hred Then
								    SendMessage ah.hred, REM_GETWORD, SizeOf (s), Cast (LPARAM, @s)
							    Else
							        SetZStrEmpty (s)
							    EndIf 
							    
								Select Case GetFBEFileType (buff)
								Case FBFT_WINHELP     ' .hlp
									WinHelp hWin, @buff, HELP_KEY, Cast (DWORD, @s)
								Case FBFT_HTMLHELP    ' .chm
									HH_Help
								Case Else
									ShellExecute hWin, NULL, @buff, NULL, @s, SW_SHOWNORMAL
								End Select 
							EndIf
							'
					    Case IDM_WINDOW_NEXTTAB
							NextTab(FALSE)
							'
						Case IDM_WINDOW_PREVIOUSTAB
							NextTab(TRUE)
							'
						Case IDM_WINDOW_SWITCHTAB
							SwitchTab
							'
					    Case IDM_WINDOW_TAB2PROJECT
					        Tab2Project
					        
					    Case IDM_WINDOW_CLOSE_ALL_NONPROJECT
					        CloseAllNonProjectTabs
							fTimer=1

						Case IDM_WINDOW_ALL_BUT_CURRENT
							CloseAllTabsButCurrent                        ' MOD 1.2.2012
							fTimer = 1
							'
						Case IDM_WINDOW_TOGGLE_LOCK
							If ah.hred Then
							    TabID = GetTabIDByEditWindow (ah.hred)
							    ToggleTabLock TabID
							    SbarLabelLockState
							    'fTimer = 1
							    'If GetTabLock (TabID) = TRUE Then
								'    SetTabLock (TabID, FALSE) 
							    'Else  
								'    SetTabLock (TabID, TRUE) 
							    'EndIf 
								'SendMessage(ah.hred,WM_COMMAND,(BN_CLICKED Shl 16) Or -5,0)
								''' it is works but does not refresh button
								''' need review raedit.dll (WM_COMMAND -5)
								'SendMessage(ah.hred,REM_SETLOCK,SendMessage(ah.hred,REM_GETLOCK,0,0) Xor 1,0)
							EndIf    
							'
						Case IDM_WINDOW_UNLOCKALL
							UnlockAllTabs
							fTimer = 1
							'
						Case IDM_OUTPUT_CLEAR
							SendMessage ah.hout, WM_SETTEXT, 0, Cast (LPARAM, @"")
							UpdateAllTabs (6)          ' clear all bookmarks
						'
						'Case IDM_OUTPUT_SELECTALL
						'	SendMessage(ah.hout,EM_EXSETSEL,0,Cast(LPARAM,@Type<CHARRANGE>(0,-1)))
						'
						'Case IDM_OUTPUT_COPY
						'	SendMessage(ah.hout,WM_COPY,0,0)
						'
						Case IDM_IMMEDIATE_CLEAR
							SendMessage ah.himm, WM_SETTEXT, 0, Cast (LPARAM, @"")
						'
						'Case IDM_IMMEDIATE_SELECTALL
						'	SendMessage(ah.himm,EM_EXSETSEL,0,Cast(LPARAM,@Type<CHARRANGE>(0,-1)))
						'
						'Case IDM_IMMEDIATE_COPY
						'	SendMessage(ah.himm,WM_COPY,0,0)
						'
						Case IDM_PROPERTY_JUMP
							SendMessage(ah.hpr,WM_COMMAND,MAKEWPARAM(1003,LBN_DBLCLK),0)
							'
						Case IDM_PROPERTY_COPY_NAME
							If SendMessage(ah.hpr,PRM_GETSELTEXT,0,Cast(LPARAM,@buff)) Then
							    
							    ' MOD 19.1.2012
							    Dim Position As Integer = InStr (buff, Any "(:")
							    If Position Then buff[Position - 1] = NULL 
								'If InStr(buff,"(") Then
								'	buff=Left(buff,InStr(buff,"(")-1)
								'ElseIf InStr(buff,":") Then
								'	buff=Left(buff,InStr(buff,":")-1)
								'EndIf
								'==============================
								SendMessage(ah.hred,EM_REPLACESEL,TRUE,Cast(LPARAM,@buff))
								SetFocus(ah.hred)
							EndIf
							'
					    Case IDM_PROPERTY_COPY_SPEC         ' MOD 23.1.2012 ADD
							If SendMessage(ah.hpr,PRM_GETSELTEXT,0,Cast(LPARAM,@buff)) Then
								SendMessage(ah.hred,EM_REPLACESEL,TRUE,Cast(LPARAM,@buff))
								SetFocus(ah.hred)
							EndIf
                            '
						Case IDM_PROPERTY_FINDALL
							If SendMessage(ah.hpr,PRM_GETSELTEXT,0,Cast(LPARAM,@buff)) Then
								'SendMessage(ah.hout,WM_SETTEXT,0,Cast(Integer,StrPtr(szNULL)))
								UpdateAllTabs (6)          ' clear all bookmarks
							    ' MOD 19.1.2012
							    Dim Position As Integer = InStr (buff, Any "(:")
							    If Position Then buff[Position - 1] = NULL 
								'If InStr(buff,"(") Then
								'	buff=Left(buff,InStr(buff,"(")-1)
								'ElseIf InStr(buff,":") Then
								'	buff=Left(buff,InStr(buff,":")-1)
								'EndIf
								'==============================
								fsave=f
								f.fr=FR_MATCHCASE Or FR_WHOLEWORD
								f.fdir=FM_DIR_ALL
								f.fsearch=FM_RANGE_PROJECT
								f.flogfind=TRUE
								f.findbuff=buff
								ResetFind
								If f.fres=-1 Then
									Find(hWin,f.fr)
								EndIf
								Do While f.fres<>-1
									SendMessage(ah.hred,EM_EXGETSEL,0,Cast(Integer,@chrg))
									' MOD 9.3.2012
									f.ft.chrg.cpMin=chrg.cpMax
									'If f.fdir=2 Then
									'	If f.fres<>-1 Then
									'		f.ft.chrg.cpMin=chrg.cpMin-1
									'	EndIf
									'Else
									'	If f.fres<>-1 Then
									'		f.ft.chrg.cpMin=chrg.cpMin+chrg.cpMax-chrg.cpMin
									'	EndIf
									'EndIf
									' ===================
									Find(hWin,f.fr)
								Loop
								f=fsave
							EndIf
							'
						Case IDM_PROPERTY_HILIGHT_RESET
							PropertyHL(FALSE)
							'
						Case IDM_PROPERTY_HILIGHT_UPDATE
							PropertyHL(TRUE)
							'
						Case Else
							If id=IDC_CBOBUILD Then
								id=SendMessage(ah.hcbobuild,CB_GETCURSEL,0,0)
								If fProject Then
									WritePrivateProfileString(StrPtr("Make"),StrPtr("Current"),Str(id+1),@ad.ProjectFile)
								Else
									WritePrivateProfileString(StrPtr("Make"),StrPtr("Current"),Str(id+1),@ad.IniFile)
								EndIf
								GetMakeOption
								'
							ElseIf id=&HFFFD Then
								' Expand button clicked
								SendMessage(ah.hred,REM_EXPANDALL,0,0)
								SendMessage(ah.hred,EM_SCROLLCARET,0,0)
								SendMessage(ah.hred,REM_REPAINT,0,0)
								'
							ElseIf id=&HFFFC Then
								' Collapse button clicked
								SendMessage(ah.hred,REM_COLLAPSEALL,0,0)
								SendMessage(ah.hred,EM_SCROLLCARET,0,0)
								SendMessage(ah.hred,REM_REPAINT,0,0)
								'
							ElseIf id>=IDM_TOOLS_USER_1 AndAlso id<=IDM_TOOLS_USER_LAST Then
								' Tools menu
								UpdateEnvironment
								GetPrivateProfileString(StrPtr("Tools"),Str(id-IDM_TOOLS_USER_1+1),NULL,@buff,GOD_EntrySize,@ad.IniFile)
								If IsZStrNotEmpty (buff) Then
                                   	Dim SInfo  As STARTUPINFO
                                	Dim PInfo  As PROCESS_INFORMATION
									SplitStr buff, Asc (","), pBuffB 
									ExpandStrByEnviron *pBuffB
                                	CreateProcess NULL, pBuffB, NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, NULL, @SInfo, @PInfo
                                	CloseHandle PInfo.hProcess
                                	CloseHandle PInfo.hThread
									'FixPath(buff)
									'If buff[0] = Asc ("\") Then         ' MOD 27.1.2012   
									'	buff=Left(ad.AppPath,2) & buff
									'EndIf
									'If Right(buff,2)=" $" Then          
									'	buff[Len(buff)-2]=NULL
									'	ShellExecute(hWin,NULL,@buff,@ad.filename,NULL,SW_SHOWNORMAL)
									'ElseIf buff[0] = Asc ("$") Then     ' MOD 27.1.2012    
									'	GetCurrentDirectory(260,@buff)
									'	lstrcat(@buff,StrPtr("\"))
									'	ShellExecute(hWin,StrPtr("explore"),@buff,NULL,NULL,SW_SHOWNORMAL)
									'Else
									'	If InStr(buff,"""") Then
									'		s=Mid(buff,InStr(buff,""""))
									'		s=Mid(s,2)
									'		s=Left(s,Len(s)-1)
									'		buff=Trim(Left(buff,InStr(buff,"""")-1))
									'		ShellExecute(hWin,NULL,@buff,@s,NULL,SW_SHOWNORMAL)
									'	Else
									'		ShellExecute(hWin,NULL,@buff,NULL,NULL,SW_SHOWNORMAL)
									'	EndIf
									'EndIf
								EndIf
							ElseIf id>=IDM_HELP_USER_1 AndAlso id<=IDM_HELP_USER_LAST Then
								' Help menu
								UpdateEnvironment
								GetPrivateProfileString(StrPtr("Help"),Str(id-IDM_HELP_USER_1+1),NULL,@buff,GOD_EntrySize,@ad.IniFile)
								If IsZStrNotEmpty (buff) Then
                                   	Dim SInfo  As STARTUPINFO
                                	Dim PInfo  As PROCESS_INFORMATION
									SplitStr buff, Asc (","), pBuffB 
									ExpandStrByEnviron *pBuffB
                                	CreateProcess NULL, pBuffB, NULL, NULL, FALSE, CREATE_NEW_CONSOLE, NULL, NULL, @SInfo, @PInfo
                                	CloseHandle PInfo.hProcess
                                	CloseHandle PInfo.hThread
									'buff=Mid(buff,InStr(buff,",")+1)
									'FixPath(buff)
									'If buff[0] = Asc ("\") Then             ' MOD 27.1.2012   
									'	buff=Left(ad.AppPath,2) & buff
									'EndIf
									'ShellExecute(hWin,NULL,@buff,NULL,NULL,SW_SHOWNORMAL)
								EndIf
							ElseIf id>=IDM_FILE_MRUPROJECT_1 Andalso id<=IDM_FILE_MRUPROJECT_LAST Then
								' Mru project
								x = InStr (MruProject(id - IDM_FILE_MRUPROJECT_1), ",")
								If x Then
									sItem = Mid (MruProject(id - IDM_FILE_MRUPROJECT_1), x + 1)
									OpenTheFile sItem, FOM_STD
									'If fProject Then
									'	If CloseProject=FALSE Then
									'		Return TRUE
									'	EndIf
									'Else
    								'	If CloseAllTabs(FALSE,0)=TRUE Then      ' MOD 1.2.2012 removed hWin
									'		Return TRUE
									'	EndIf
									'EndIf
									'ad.ProjectFile=Mid(MruProject(id-14001),x+1)
									'OpenProject
								EndIf
							ElseIf id>=IDM_FILE_MRUFILE_1 Andalso id<=IDM_FILE_MRUFILE_LAST Then
								' Mru file
								sItem = MruFile(id - IDM_FILE_MRUFILE_1)     ' local copy needed, because OpenTheFile modifies MruFile(), (shared)
								OpenTheFile sItem, FOM_STD
								'x=InStr(MruFile(id-15001),",")
								'If x Then
								'	OpenTheFile(Mid(MruFile(id-15001),x+1),FOM_STD)
								'EndIf
							ElseIf id>=22000 And id<=22032 Then
								' Custom resource
								SendMessage(ah.hraresed,PRO_ADDITEM,id-22000+32,TRUE)
							EndIf
							'
					End Select
					'
			End Select
			'
		Case WM_CONTEXTMENU
			If CallAddins(hWin,AIM_CONTEXTMEMU,wParam,lParam,HOOK_CONTEXTMEMU)=FALSE Then
				If lParam=-1 Then
					hCtl=GetFocus
					GetCaretPos(@pt)
					ClientToScreen(hCtl,@pt)
					pt.x=pt.x+10
				Else
					pt.x=Cast(Short,LoWord(lParam))
					pt.y=Cast(Short,HiWord(lParam))
					hCtl=WindowFromPoint(pt)
				EndIf
				hCtl=Cast(HWND,wParam)
				If hCtl=ah.hprj Then
					' Project 
					TrackPopupMenu(GetSubMenu(ah.hcontextmenu,1),TPM_LEFTALIGN Or TPM_RIGHTBUTTON,pt.x,pt.y,0,ah.hwnd,0)
				ElseIf hCtl=ah.hpr Then
					' Property Context
					TrackPopupMenu(GetSubMenu(ah.hcontextmenu,3),TPM_LEFTALIGN Or TPM_RIGHTBUTTON,pt.x,pt.y,0,ah.hwnd,0)
				ElseIf hCtl=hWin Then
					' Main window
					TrackPopupMenu(GetSubMenu(ah.hmenu,0),TPM_LEFTALIGN Or TPM_RIGHTBUTTON,pt.x,pt.y,0,ah.hwnd,0)
				ElseIf hCtl=ah.htabtool Then
					' Tab select
					TrackPopupMenu(GetSubMenu(ah.hcontextmenu,0),TPM_LEFTALIGN Or TPM_RIGHTBUTTON,pt.x,pt.y,0,ah.hwnd,0)
				' MOD 11.2.2012   add
				ElseIf hCtl=ah.hfib Then                        
					' Filebrowser Context
					TrackPopupMenu(GetSubMenu(ah.hcontextmenu,6),TPM_LEFTALIGN Or TPM_RIGHTBUTTON,pt.x,pt.y,0,ah.hwnd,0)
				' =========================
				EndIf
			EndIf
		Case WM_MOVE
			ShowWindow(ah.htt,SW_HIDE)
			HideCCLists()
			'
		Case WM_NOTIFY
			lpRASELCHANGE=Cast(RASELCHANGE Ptr,lParam)
			If lpRASELCHANGE->nmhdr.hwndFrom=ah.hred And lpRASELCHANGE->nmhdr.idFrom=IDC_RAEDIT Then
				If ad.fNoNotify Then
					If lpRASELCHANGE->Line<>nLastLine Then
						ShowWindow(ah.htt,SW_HIDE)
						HideCCLists()
					EndIf
					nCaretPos=lpRASELCHANGE->chrg.cpMin-lpRASELCHANGE->cpLine
					UpDateFind(ah.hred,lpRASELCHANGE->chrg.cpMin,lpRASELCHANGE->fchanged)
					nLastLine=lpRASELCHANGE->Line
					fTimer=1
					Return 0
				EndIf
				nCaretPos=lpRASELCHANGE->chrg.cpMin-lpRASELCHANGE->cpLine
				If lpRASELCHANGE->seltyp=SEL_OBJECT Then
					SendMessage(ah.hred,REM_SETHILITELINE,nLastLine,0)
					bm=SendMessage(ah.hred,REM_GETBOOKMARK,lpRASELCHANGE->Line,0)
					If bm=BMT_COLLAPSE Then
						' Collapse
						If GetKeyState(VK_CONTROL) And &H80 Then
							nLine=SendMessage(ah.hred,REM_GETBLOCKEND,lpRASELCHANGE->Line,0)
							While nLine>lpRASELCHANGE->Line And nLine<>-1
								nLine=SendMessage(ah.hred,REM_PRVBOOKMARK,nLine,BMT_COLLAPSE)
								SendMessage(ah.hred,REM_COLLAPSE,nLine,0)
							Wend
						Else
							SendMessage(ah.hred,REM_COLLAPSE,lpRASELCHANGE->Line,0)
						EndIf
					ElseIf bm=BMT_EXPAND Then
						' Expand
						If GetKeyState(VK_CONTROL) And &H80 Then
							nLine=lpRASELCHANGE->Line
							i=SendMessage(ah.hred,REM_GETBLOCKEND,nLine,0)
							If i<>-1 Then
								While nLine<i And nLine<>-1
									SendMessage(ah.hred,REM_EXPAND,nLine,0)
									nLine=SendMessage(ah.hred,REM_NXTBOOKMARK,nLine,BMT_EXPAND)
								Wend
							EndIf
						Else
							SendMessage(ah.hred,REM_EXPAND,lpRASELCHANGE->Line,0)
						EndIf
					EndIf
					If edtopt.hiliteline Then
						SendMessage(ah.hred,REM_SETHILITELINE,lpRASELCHANGE->Line,2)
					EndIf
				Else                  ' seltyp=SEL_TEXT
					If GetWindowLong(ah.hred,GWL_ID)=IDC_CODEED Then
						If lstpos.fchanged<>0 And lstpos.nline<>lpRASELCHANGE->Line And lstpos.fnohandling=0 Then
							ad.fNoNotify=TRUE
							If edtopt.autocase Then
								CaseConvertWord(lstpos.hwnd,lstpos.chrg.cpMin)
							EndIf
							If ah.hred=lstpos.hwnd Then
								lret=AutoFormatLine(lstpos.hwnd,@lstpos.chrg)
								If lpRASELCHANGE->chrg.cpMin>lstpos.chrg.cpMin Then
									lpRASELCHANGE->chrg.cpMin-=lret
									lpRASELCHANGE->chrg.cpMax-=lret
								EndIf
								SendMessage(lstpos.hwnd,EM_EXSETSEL,0,Cast(LPARAM,@lpRASELCHANGE->chrg.cpMin))
								SendMessage(lstpos.hwnd,EM_SCROLLCARET,0,0)
							EndIf
							SetPropertyDirty lstpos.hwnd 
							ad.fNoNotify=FALSE
						EndIf
						
						If     Abs (lpRASELCHANGE->Line - nLastLine) > 1 _            ' only jumps, no scrolling
						OrElse ah.hred<>lstpos.hwnd Then
                            CH.Enqueue (ah.hred, lpRASELCHANGE->chrg.cpMin)						
						EndIf
					
						lstpos.hwnd=ah.hred
						lstpos.chrg.cpMin=lpRASELCHANGE->chrg.cpMin
						lstpos.chrg.cpMax=lpRASELCHANGE->chrg.cpMax
						lstpos.fchanged=lpRASELCHANGE->fchanged
						lstpos.nline=lpRASELCHANGE->Line
						
						'TODO
						
						SendMessage(ah.hred,REM_BRACKETMATCH,0,0)
						If lpRASELCHANGE->Line<>nLastLine Then
							ShowWindow(ah.htt,SW_HIDE)
							HideCCLists()
							If GetWindowLong(ah.hred,GWL_USERDATA)=1 Then
								' Must be parsed
								SetPropertyDirty ah.hred 
							EndIf
						EndIf

						If lpRASELCHANGE->fchanged Then
							If lpRASELCHANGE->Line>=nLastLine And nLastLine>0 Then
								nLastLine-=1
								nLastLine=SendMessage(ah.hred,REM_GETLINEBEGIN,nLastLine,0)
							ElseIf lpRASELCHANGE->Line<nLastLine Then
								nLastLine+=1
							EndIf
							If GetWindowLong(ah.hred,GWL_USERDATA)=0 Then
								SetWindowLong(ah.hred,GWL_USERDATA,1)
							EndIf
							
							SendMessage ah.hred, REM_SETCOMMENTBLOCKS, Cast (WPARAM, @"/'"), Cast (LPARAM, @"'/") ' Set comment block definition

							Do
								bm=SendMessage(ah.hred,REM_GETBOOKMARK,nLastLine,0)
								i=-1
								lret=-1
								While lret=-1 And i<40
									i+=1
									If BD(i).lpszStart Then
										lret=SendMessage(ah.hred,REM_ISLINE,nLastLine,Cast(Integer,@szSt(i)))
									EndIf
								Wend
								If bm=BMT_COLLAPSE Or bm=BMT_EXPAND Then
									If lret=-1 Then
										' Remove collapse bookmark
										If bm=BMT_EXPAND Then
											SendMessage(ah.hred,REM_EXPAND,nLastLine,0)
										EndIf
										SendMessage(ah.hred,REM_SETBOOKMARK,nLastLine,BMT_NONE)
										SendMessage(ah.hred,REM_SETDIVIDERLINE,nLastLine,FALSE)
										SendMessage(ah.hred,REM_REPAINT,0,TRUE)
									EndIf
								ElseIf bm=BMT_NONE Then
									x=0
									y=0
									While x<40
										If BD(x).lpszStart<>0 And (BD(x).flag And BD_NOBLOCK)<>0 Then
											y=SendMessage(ah.hred,REM_ISINBLOCK,nLastLine,Cast(Integer,@BD(x)))
											If y Then
												Exit While
											EndIf
										EndIf
										x+=1
									Wend
									If y=0 And lret>=0 Then
										' Set collapse bookmark
										SendMessage(ah.hred,REM_SETBOOKMARK,nLastLine,BMT_COLLAPSE)
										SendMessage(ah.hred,REM_SETDIVIDERLINE,nLastLine,BD(i).flag And BD_DIVIDERLINE)
										SendMessage(ah.hred,REM_REPAINT,0,TRUE)
									ElseIf y Then
										' Set no block flag
										SendMessage(ah.hred,REM_SETNOBLOCKLINE,nLastLine,TRUE)
									EndIf
									x=0
									y=0
									While x<40
										If BD(x).lpszStart<>0 And (BD(x).flag And BD_ALTHILITE)<>0 Then
											y=SendMessage(ah.hred,REM_ISINBLOCK,nLastLine,Cast(Integer,@BD(x)))
											If y Then
												Exit While
											EndIf
										EndIf
										x+=1
									Wend
									If y=0 And lret>=0 Then
										' Set collapse bookmark
										SendMessage(ah.hred,REM_SETBOOKMARK,nLastLine,BMT_COLLAPSE)
										SendMessage(ah.hred,REM_SETDIVIDERLINE,nLastLine,BD(i).flag And BD_DIVIDERLINE)
										If (BD(i).flag And BD_ALTHILITE)<>0 Then
											' Set althilite flag
											SendMessage(ah.hred,REM_SETALTHILITELINE,nLastLine,TRUE)
										EndIf
										SendMessage(ah.hred,REM_REPAINT,0,TRUE)
									ElseIf y Then
										' Set althilite flag
										SendMessage(ah.hred,REM_SETALTHILITELINE,nLastLine,TRUE)
									Else
										' Set althilite flag off
										SendMessage(ah.hred,REM_SETALTHILITELINE,nLastLine,FALSE)
									EndIf
								EndIf
								bm=0
								If lpRASELCHANGE->Line>nLastLine Then
									nLastLine=nLastLine+1
									bm=1
								ElseIf lpRASELCHANGE->Line<nLastLine Then
									nLastLine=nLastLine-1
									bm=1
								EndIf
							Loop While bm
						EndIf
					EndIf
					UpDateFind(ah.hred,lpRASELCHANGE->chrg.cpMin,lpRASELCHANGE->fchanged)
				EndIf
				nLastLine=lpRASELCHANGE->Line
				fTimer=1
			ElseIf lpRASELCHANGE->nmhdr.hwndFrom=ah.hred And lpRASELCHANGE->nmhdr.idFrom=IDC_HEXED Then
				lpHESELCHANGE=Cast(HESELCHANGE Ptr,lParam)
				nLastLine=lpHESELCHANGE->nline
				nCaretPos=lpHESELCHANGE->chrg.cpMin-(lpHESELCHANGE->chrg.cpMin Shr 5)*32
				fTimer=1
			ElseIf lpRASELCHANGE->nmhdr.hwndFrom=ah.hout Then
				If lpRASELCHANGE->seltyp=SEL_OBJECT Then
					bm=SendMessage(ah.hout,REM_GETBOOKMARK,lpRASELCHANGE->Line,0)
					If bm=BMT_STD OrElse bm=BMT_REPEAT Then 
						' MOD 22.2.2012
						For x = lpRASELCHANGE->Line To 0 Step -1
						    If SendMessage (ah.hout, REM_GETBOOKMARK, x, 0) = BMT_SPEC Then 
        						GetLineByNo ah.hout, x, @buff
						        If GetFBEFileType (buff) = FBFT_CODE Then     ' .bas.bi file
        							OpenTheFile buff, FOM_STD
        						Else	
        							OpenTheFile buff, FOM_TXT
        						EndIf 	
        					    GetLineByNo ah.hout, lpRASELCHANGE->Line, @buff
       						    GetEnclosedStr 0, buff, buff, SizeOf (buff), CUByte (Asc ("(")), CUByte (Asc (")"))
                                GotoTextLine ah.hred, ValInt (buff) - 1, TRUE
        						SetFocus(ah.hred)
						        Exit For
						    EndIf
						Next
						'x=lpRASELCHANGE->Line
						'While bm<>5
						'	x-=1
						'	bm=SendMessage(ah.hout,REM_GETBOOKMARK,x,0)
						'Wend
						'buff=Chr(255) & Chr(1)
						'x=SendMessage(ah.hout,EM_GETLINE,x,Cast(LPARAM,@buff))
						'buff[x]=NULL
						'OpenTheFile(buff,FOM_STD)
						'x=SendMessage(ah.hout,REM_GETBMID,lpRASELCHANGE->Line,0)
						'If x Then
						'	x=SendMessage(ah.hred,REM_FINDBOOKMARK,x,0)
						'	If x>=0 Then
						'		y=x
						'	EndIf
						'EndIf
						'chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,y,0)
						'chrg.cpMax=chrg.cpMin
						'SendMessage(ah.hred,EM_EXSETSEL,0,Cast(Integer,@chrg))
						'SendMessage(ah.hred,REM_VCENTER,0,0)
						'SendMessage(ah.hred,EM_SCROLLCARET,0,0)
						'SetFocus(ah.hred)
						' ========================
					ElseIf bm=BMT_WARN Or bm=BMT_ERROR Then
	                    GetLineByCaret ah.hout, @buff, 0        ' MOD 28.1.2012			    
					    'SendMessage(ah.hout,EM_EXGETSEL,0,Cast(LPARAM,@chrg))
						'y=SendMessage(ah.hout,EM_LINEFROMCHAR,chrg.cpMin,0)
						'x=SendMessage(ah.hout,EM_LINELENGTH,chrg.cpMin,0)
						'buff=Chr(x And 255) & Chr(x\256)
						'x=SendMessage(ah.hout,EM_GETLINE,y,Cast(LPARAM,@buff))
						'buff[x]=NULL
						y=GetErrLine(buff,fQR)
						If y>=0 Then
							If ah.hred<>ah.hres Then
								x=SendMessage(ah.hout,REM_GETBMID,lpRASELCHANGE->Line,0)
								If x Then
									lret=-1
									While TRUE
										lret=SendMessage(ah.hred,REM_NEXTERROR,lret,0)
										If lret=-1 Then
											Exit While
										EndIf
										i=SendMessage(ah.hred,REM_GETERROR,lret,0)
										If x=i Then
											y=lret
											Exit While
										EndIf
									Wend
								EndIf
								GotoTextLine ah.hred, y, TRUE            ' MOD 21.1.2012
								'chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,y,0)
								'chrg.cpMax=chrg.cpMin
								'SendMessage(ah.hred,EM_EXSETSEL,0,Cast(Integer,@chrg))
								'SendMessage(ah.hred,REM_VCENTER,0,0)
								'SendMessage(ah.hred,EM_SCROLLCARET,0,0)
							EndIf
							SetFocus(ah.hred)
						EndIf
					Else
						Return 0
					EndIf
				EndIf
				'
			ElseIf lpRASELCHANGE->nmhdr.code=TCN_SELCHANGE And lpRASELCHANGE->nmhdr.hwndFrom=ah.htab Then
				' Project tab
				ShowProjectTab
				'
			ElseIf lpRASELCHANGE->nmhdr.code=TCN_SELCHANGE And lpRASELCHANGE->nmhdr.hwndFrom=ah.hdbgtab Then
				' Debug tab
				ad.nDbgTabSel=SendMessage(ah.hdbgtab,TCM_GETCURSEL,0,0)
				Select Case ad.nDbgTabSel
					Case 0
						' REG
						ShowWindow(ah.hregister,SW_SHOWNA)
						ShowWindow(ah.hfpu,SW_HIDE)
						ShowWindow(ah.hmmx,SW_HIDE)
					Case 1
						' FPU
						ShowWindow(ah.hfpu,SW_SHOWNA)
						ShowWindow(ah.hregister,SW_HIDE)
						ShowWindow(ah.hmmx,SW_HIDE)
					Case 2
						' MMX
						ShowWindow(ah.hmmx,SW_SHOWNA)
						ShowWindow(ah.hregister,SW_HIDE)
						ShowWindow(ah.hfpu,SW_HIDE)
				End Select
				'
			ElseIf lpRASELCHANGE->nmhdr.code=FBN_DBLCLICK  And lpRASELCHANGE->nmhdr.hwndFrom=ah.hfib Then
				' File dblclicked
				lpFBNOTIFY=Cast(FBNOTIFY Ptr,lParam)
				lstrcpy(@sItem,lpFBNOTIFY->lpfile)
			    If GetKeyState(VK_CONTROL) And &H80 Then
				    OpenTheFile(sItem,FOM_TXT)
			    Else
				    OpenTheFile(sItem,FOM_STD)
			    EndIf    
				'
			ElseIf lpRASELCHANGE->nmhdr.code=BN_CLICKED And lpRASELCHANGE->nmhdr.hwndFrom=ah.hpr Then
				' Property toolbar button
				
			    POL_Changed = TRUE     
			    UpdateProperty
				
				'lpRAPNOTIFY=Cast(RAPNOTIFY Ptr,lParam)
				'Select Case lpRAPNOTIFY->nid
				    'Case 1       ' current file button
					'	UpdateFileProperty
					'Case 2       ' all files button
					'	SendMessage(ah.hpr,PRM_SELOWNER,0,0)
					'	SendMessage(ah.hpr,PRM_REFRESHLIST,0,0)
				    'Case 5       ' update button
					'	i=SendMessage(ah.hpr,PRM_GETSELBUTTON,0,0)
					'	If i=1 Then
					'		' Current file
					'		UpdateFileProperty
					'	EndIf
				'End Select
				
			ElseIf lpRASELCHANGE->nmhdr.code=LBN_DBLCLK And lpRASELCHANGE->nmhdr.hwndFrom=ah.hpr Then
				' Property dbl click
				'If ah.hred<>0 And ah.hred<>ah.hres Then
				'	SendMessage(ah.hred,EM_EXGETSEL,0,Cast(Integer,@chrg))
				'	CaretPosEnqueue ah.hred, chrg.cpMin
			    'EndIf
				lpRAPNOTIFY=Cast(RAPNOTIFY Ptr,lParam)
				
				If      IsWindow (Cast (HWND, lpRAPNOTIFY->nid)) _
				AndAlso GetWindowLong (Cast (HWND, lpRAPNOTIFY->nid), GWL_ID) = IDC_CODEED Then
				    SelectTabByWindow Cast (HWND, lpRAPNOTIFY->nid)
				Else
				    SelectTabByFileID lpRAPNOTIFY->nid
				EndIf
				
				'If fProject Then
				'	SelectTabByFileID(lpRAPNOTIFY->nid)              ' MOD 1.2.2012 removed hWin
				'Else
				'	SelectTabByWindow(Cast(HWND,lpRAPNOTIFY->nid))   ' MOD 1.2.2012 removed hWin
				'EndIf
				
				GotoTextLine ah.hred, lpRAPNOTIFY->nline, TRUE
				
				'SetFocus(ah.hred)
				'chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,lpRAPNOTIFY->nline,0)
				'chrg.cpMax=chrg.cpMin
				'SendMessage(ah.hred,EM_EXSETSEL,0,Cast(Integer,@chrg))
				'SendMessage(ah.hred,REM_VCENTER,0,0)
				'SendMessage(ah.hred,EM_SCROLLCARET,0,0)
				'SetFocus(ah.hred)
				'
			ElseIf lpRASELCHANGE->nmhdr.code=LBN_SELCHANGE And lpRASELCHANGE->nmhdr.hwndFrom=ah.hpr Then
				' Property selchange
				'fTimer=1
				'
			ElseIf lpRASELCHANGE->nmhdr.code=TVN_BEGINLABELEDIT And lpRASELCHANGE->nmhdr.hwndFrom=ah.hprj Then
				' Project labeledit start
				#Define pNMTVDISPINFO     Cast (NMTVDISPINFO Ptr, lParam)
				'lpNMTVDISPINFO=Cast(NMTVDISPINFO Ptr,lParam)
				sEditFileName = *pNMTVDISPINFO->item.pszText
				If pNMTVDISPINFO->item.lParam = 0 Then
					SendMessage ah.hprj, TVM_ENDEDITLABELNOW, 0, 0
				EndIf
				#Undef pNMTVDISPINFO
				'
			ElseIf lpRASELCHANGE->nmhdr.code=TVN_ENDLABELEDIT And lpRASELCHANGE->nmhdr.hwndFrom=ah.hprj Then
				' Project labeledit end
				#Define pNMTVDISPINFO     Cast (NMTVDISPINFO Ptr, lParam)
				If pNMTVDISPINFO->item.pszText Then
    				sItem = *pNMTVDISPINFO->item.pszText
    				SetCurrentDirectory @ad.ProjectPath
    				If MoveFile (@sEditFileName, @sItem) Then
    					SendMessage ah.hprj, TVM_SETITEM, 0, Cast (LPARAM, @pNMTVDISPINFO->item)
    					UpdateProjectFileName sEditFileName, sItem
    					sEditFileName = MakeProjectFileName (sEditFileName)
    					If ShowTab (sEditFileName) Then                 ' MOD 1.2.2012 removed Param: hWin
    						ad.filename = MakeProjectFileName (sItem)
    						UpdateTab
    						SetWinCaption
    					EndIf
    					RefreshProjectTree
    				Else
    			        FormatMessage FORMAT_MESSAGE_FROM_SYSTEM, NULL, GetLastError, NULL, @sItem, SizeOf (sItem), NULL
                		TextToOutput "*** rename failed ***", MB_ICONHAND 
                		TextToOutput sItem
    				EndIf
				EndIf
				#Undef pNMTVDISPINFO
				'
			ElseIf lpRASELCHANGE->nmhdr.code=TTN_NEEDTEXTA Then
				' ToolBar tooltip
				#Define pTOOLTIPTEXT     Cast (TOOLTIPTEXT Ptr, lParam)
				lret=CallAddins(ah.hwnd,AIM_GETTOOLTIP,pTOOLTIPTEXT->hdr.idFrom,0,HOOK_GETTOOLTIP)
				If lret Then
					pTOOLTIPTEXT->lpszText = Cast (ZString Ptr, lret)
				Else
					buff = FindString (ad.hLangMem, "Strings", Str (pTOOLTIPTEXT->hdr.idFrom))
					If IsZStrEmpty (buff) Then
						LoadString hInstance, pTOOLTIPTEXT->hdr.idFrom, @buff, 256
					EndIf
					pTOOLTIPTEXT->lpszText = @buff
				EndIf
			    #Undef pTOOLTIPTEXT
			EndIf
			
		
		
		
		
    		'TODO
    		' Statusbar click
				
    		If      Cast(NMMOUSE Ptr, LPARAM)->hdr.hwndFrom = ah.hsbr _
    		AndAlso Cast(NMMOUSE Ptr, LPARAM)->hdr.idFrom   = IDC_STATUSBAR _
    		AndAlso Cast(NMMOUSE Ptr, LPARAM)->hdr.code     = NM_CLICK Then
    		    Select Case Cast(NMMOUSE Ptr, LPARAM)->dwItemSpec
    		    Case 1
    		        SendMessage ah.hwnd, WM_COMMAND, IDM_WINDOW_TOGGLE_LOCK, 0
    		    Case 2 
    		        If EditInfo.CoTxEd Then 
                		SendMessage ah.hwnd, WM_COMMAND, IDM_EDIT_BLOCKMODE, 0
    		        EndIf
    		    Case 3 
                    If EditInfo.CoTxEd Then
                    	SendMessage ah.hred, REM_COMMAND, CMD_INSERT, 0              ' toggle INS/OVR mode
           			    SbarSetWriteMode
                    ElseIf EditInfo.HexEd Then
                    	Mode = SendMessage (ah.hred, HEM_GETMODE, 0, 0) Xor MODE_OVERWRITE 
                        SendMessage ah.hred, HEM_SETMODE, Mode, 0
           			    SbarSetWriteMode
                    EndIf 
    		    End Select
   		    
    		    'Print "****HIT"; Cast(NMMOUSE Ptr, LPARAM)->dwItemSpec
     		    Return TRUE 
    		EndIf
		
		
		
		
		
		Case WM_DROPFILES
			id=0
			lret=TRUE
			Do While lret
				lret=DragQueryFile(Cast(HDROP,wParam),id,@sItem,SizeOf(sItem))
				If lret Then
					' Open single file
					If (GetFileAttributes(@sItem) And FILE_ATTRIBUTE_DIRECTORY)=0 Then
						OpenTheFile(sItem,FOM_STD)
					EndIf
				EndIf
				id+=1
			Loop
			'
		Case WM_SIZE
			If ah.hfullscreen=0 Then
				' Size the FbEdit control to fill the dialogs client area
				twt=wpos.wtpro
				If (wpos.fview And (VIEW_PROJECT Or VIEW_PROPERTY))=0 Then
					twt=0
				EndIf
				' Get dialogs client rect
				GetClientRect(hWin,@rect)
				'hgt=0
				If wpos.fview And VIEW_TOOLBAR Then
					' Size the divider2  (menu | toolbar)
					hCtl=GetDlgItem(hWin,IDC_DIVIDER2)
					MoveWindow(hCtl,0,0,rect.right+1,2,TRUE)
					' Add height of divider + space
					hgt=2+3
					' Get width of toolbar
					wdt=SendMessage(ah.htoolbar,TB_BUTTONCOUNT,0,0)-1
					SendMessage(ah.htoolbar,TB_GETITEMRECT,wdt,Cast(LPARAM,@rect1))
					ad.tbwt=rect1.right+5
					' Get height of toolbar
					GetClientRect(ah.htoolbar,@rect1)
					If rect1.right<>ad.tbwt Then
						rect1.right=ad.tbwt
						MoveWindow(ah.htoolbar,0,hgt,rect1.right,rect1.bottom,TRUE)
						MoveWindow(ah.hcbobuild,ad.tbwt,hgt,150,200,TRUE)
					EndIf
                    ' Add height of toolbar
				    hgt=hgt+rect1.bottom
				EndIf
				If wpos.fview And VIEW_TABSELECT Then
					' Size the divider  (toolbar | tabtool)
					hCtl=GetDlgItem(hWin,IDC_DIVIDER)
					MoveWindow(hCtl,0,hgt,rect.right+1,2,TRUE)
					' Add height of divider + space
					hgt=hgt+2+3
					tbhgt=hgt
					' Size the tab select
					GetClientRect(ah.htabtool,@rect1)
					MoveWindow(ah.htabtool,0,hgt,rect.right-twt-20,rect1.bottom,TRUE)
					' Size close button
					hCtl=GetDlgItem(hWin,IDM_FILE_CLOSE)
					MoveWindow(hCtl,rect.right-twt-20,hgt+4,20,20,TRUE)
					' Add height of tab select
					hgt=hgt+rect1.bottom
				EndIf
				rect1.bottom=0
				If wpos.fview And VIEW_STATUSBAR Then
					' Autosize the statusbar
					MoveWindow(ah.hsbr,0,0,0,0,TRUE)
					' Get client rect of statusbar
					GetClientRect(ah.hsbr,@rect1)
				EndIf
				prjht=0
				prht=0
				If (wpos.fview And (VIEW_PROJECT Or VIEW_PROPERTY))=(VIEW_PROJECT Or VIEW_PROPERTY) Then
					prjht=(rect.bottom-tbhgt-rect1.bottom)\2
					prht=rect.bottom-tbhgt-rect1.bottom-prjht
					If ad.fDebug Then
						prht=prht-HT_DEBUG
						MoveWindow(ah.hdbgtab,rect.right-twt+2,tbhgt+prjht+prht,twt-2,20,TRUE)
						MoveWindow(ah.hregister,rect.right-twt+2,tbhgt+prjht+prht+20,twt-2,HT_DEBUG-20,TRUE)
						MoveWindow(ah.hfpu,rect.right-twt+2,tbhgt+prjht+prht+20,twt-2,HT_DEBUG-20,TRUE)
						MoveWindow(ah.hmmx,rect.right-twt+2,tbhgt+prjht+prht+20,twt-2,HT_DEBUG-20,TRUE)
					EndIf
				ElseIf (wpos.fview And (VIEW_PROJECT Or VIEW_PROPERTY))=VIEW_PROJECT Then
					prjht=(rect.bottom-tbhgt-rect1.bottom)
				ElseIf (wpos.fview And (VIEW_PROJECT Or VIEW_PROPERTY))=VIEW_PROPERTY Then
					prht=(rect.bottom-tbhgt-rect1.bottom)
					If ad.fDebug Then
						prht=prht-HT_DEBUG
						MoveWindow(ah.hdbgtab,rect.right-twt+2,tbhgt+prjht+prht,twt-2,20,TRUE)
						MoveWindow(ah.hregister,rect.right-twt+2,tbhgt+prjht+prht+20,twt-2,HT_DEBUG-20,TRUE)
						MoveWindow(ah.hfpu,rect.right-twt+2,tbhgt+prjht+prht+20,twt-2,HT_DEBUG-20,TRUE)
						MoveWindow(ah.hmmx,rect.right-twt+2,tbhgt+prjht+prht+20,twt-2,HT_DEBUG-20,TRUE)
					EndIf
				EndIf
				If ad.fDebug Then
					ShowWindow(ah.hdbgtab,SW_SHOWNA)
					Select Case ad.nDbgTabSel
						Case 0
							' REG
							ShowWindow(ah.hregister,SW_SHOWNA)
							ShowWindow(ah.hfpu,SW_HIDE)
							ShowWindow(ah.hmmx,SW_HIDE)
						Case 1
							' FPU
							ShowWindow(ah.hfpu,SW_SHOWNA)
							ShowWindow(ah.hregister,SW_HIDE)
							ShowWindow(ah.hmmx,SW_HIDE)
						Case 2
							' MMX
							ShowWindow(ah.hmmx,SW_SHOWNA)
							ShowWindow(ah.hregister,SW_HIDE)
							ShowWindow(ah.hfpu,SW_HIDE)
					End Select
				Else
					ShowWindow(ah.hdbgtab,SW_HIDE)
					ShowWindow(ah.hregister,SW_HIDE)
					ShowWindow(ah.hfpu,SW_HIDE)
					ShowWindow(ah.hmmx,SW_HIDE)
				EndIf
				' Size the tab
				MoveWindow(ah.htab,rect.right-twt+2,tbhgt,twt-2,prjht,TRUE)
				' Size the file browser
				MoveWindow(ah.hfib,rect.right-twt+3,tbhgt+22,twt-5,prjht-24,TRUE)
				' Size the project browser
				MoveWindow(ah.hprj,rect.right-twt+3,tbhgt+22,twt-5,prjht-24,TRUE)
				' Size the property
				MoveWindow(ah.hpr,rect.right-twt+2,tbhgt+prjht,twt-2,prht,TRUE)
				y=rect.bottom-hgt-rect1.bottom-wpos.htout*((wpos.fview And VIEW_OUTPUT) Or ((wpos.fview And VIEW_IMMEDIATE)/VIEW_IMMEDIATE))
				hgt=hgt+3
				If ah.hpane(0) Then
					' Two panes
					MoveWindow(ah.hpane(0),0,hgt,rect.right-twt,y\2,TRUE)
					If ah.hpane(1) Then
						ShowWindow(ah.hshp,SW_HIDE)
						MoveWindow(ah.hpane(1),0,hgt+y\2,rect.right-twt,y-y\2,TRUE)
						MoveWindow(ah.hshp,0,hgt+y\2,rect.right-twt,y-y\2,TRUE)
					Else
						ShowWindow(ah.hshp,SW_SHOWNA)
						MoveWindow(ah.hshp,0,hgt+y\2,rect.right-twt,y-y\2,TRUE)
					EndIf
				ElseIf ah.hred Then
					' Size the edit control
					MoveWindow(ah.hred,0,hgt,rect.right-twt,y,TRUE)
					' Adjust shape for resize works
					MoveWindow(ah.hshp,0,hgt,rect.right-twt,y,TRUE)
				Else
					' Size the shape
					MoveWindow(ah.hshp,0,hgt,rect.right-twt,y,TRUE)
				EndIf
				If ad.bExtOutput=0 Then
					' Size the Output / Immediate
					Select Case wpos.fview And (VIEW_OUTPUT Or VIEW_IMMEDIATE)
						Case VIEW_OUTPUT
							MoveWindow(ah.hout,0,rect.bottom-rect1.bottom-wpos.htout+2,rect.right-twt,wpos.htout-2,TRUE)
						Case VIEW_IMMEDIATE
							MoveWindow(ah.himm,0,rect.bottom-rect1.bottom-wpos.htout+2,rect.right-twt,wpos.htout-2,TRUE)
						Case VIEW_OUTPUT Or VIEW_IMMEDIATE
							x=rect.right-twt
							MoveWindow(ah.hout,0,rect.bottom-rect1.bottom-wpos.htout+2,x\2,wpos.htout-2,TRUE)
							MoveWindow(ah.himm,x\2,rect.bottom-rect1.bottom-wpos.htout+2,x-x\2,wpos.htout-2,TRUE)
					End Select
				EndIf
				' Size the splash
				'GetWindowRect(ah.hshp,@rect1)
				'ScreenToClient(hWin,Cast(Point Ptr,@rect1.right))
				'MoveWindow(GetDlgItem(hWin,IDC_IMGSPLASH),(rect1.right-340)\2,(rect1.bottom-188)\2+25,340,188,TRUE)
			EndIf
			'
		Case WM_MOUSEMOVE,WM_LBUTTONDOWN,WM_LBUTTONUP
			' Size tool windows
			x=LoWord(lParam)
			If x>&H7FFF Then
				x=&HFFFF0000 Or x
			EndIf
			y=HiWord(lParam)
			If y>&H7FFF Then
				y=&HFFFF0000 Or y
			EndIf
			GetWindowRect(ah.hshp,@rect)
			ScreenToClient(hWin,Cast(Point Ptr,@rect.right))
			If x>=rect.right And x<rect.right+3 Then
				SetCursor(hVCur)
				If uMsg=WM_LBUTTONDOWN Then
					SetCapture(hWin)
					nSize=1
				ElseIf uMsg=WM_LBUTTONUP Then
					If GetCapture=hWin Then
						ReleaseCapture
						nSize=0
					EndIf
				EndIf
			ElseIf y>=rect.bottom And y<rect.bottom+3 Then
				SetCursor(hHCur)
				If uMsg=WM_LBUTTONDOWN Then
					SetCapture(hWin)
					nSize=2
				ElseIf uMsg=WM_LBUTTONUP Then
					If GetCapture=hWin Then
						ReleaseCapture
						nSize=0
					EndIf
				EndIf
			Else
				If GetCapture=hWin Then
					If uMsg=WM_LBUTTONUP Then
						ReleaseCapture
						nSize=0
					EndIf
				Else
					SetCursor(LoadCursor(0,IDC_ARROW))
				EndIf
			EndIf
			If uMsg=WM_MOUSEMOVE Then
				If nSize=1 Then
					GetClientRect(hWin,@rect)
					x=rect.right-x
					If x<100 Then
						x=100
					ElseIf x>rect.right-100 Then
						x=rect.right-100
					EndIf
					If x<>wpos.wtpro Then
						wpos.wtpro=x
						SendMessage(hWin,WM_SIZE,SIZE_RESTORED,0)
						UpdateWindow(hWin)
					EndIf
				ElseIf nSize=2 Then
					GetClientRect(hWin,@rect)
					If wpos.fview And VIEW_STATUSBAR Then
						GetClientRect(ah.hsbr,@rect1)
					EndIf
					y=rect.bottom-rect1.bottom-y
					If y<50 Then
						y=50
					ElseIf y>rect.bottom-150 Then
						y=rect.bottom-150
					EndIf
					If y<>wpos.htout Then
						wpos.htout=y
						SendMessage(hWin,WM_SIZE,SIZE_RESTORED,0)
						UpdateWindow(hWin)
					EndIf
				EndIf
			EndIf
			Return DefWindowProc(hWin,uMsg,wParam,lParam)
			'
		Case WM_SETFOCUS
			'Print "MainDlgProc: SETFOCUS"
			If ah.hred Then
				' Hack to solve a caret problem
				SetFocus(ah.hred)
				SetFocus(ah.hout)
				SetFocus(ah.hred)
			EndIf
		Case WM_KILLFOCUS
			'Print "MainDlgProc: KILLFOCUS"
			'
		Case AIM_GETHANDLES
			Return Cast(Integer,@ah)
			'
		Case AIM_GETDATA
			Return Cast(Integer,@ad)
			'
		Case AIM_GETFUNCTIONS
			Return Cast(Integer,@af)
			'
		Case AIM_GETMENUID
			mnuid=mnuid+1
			x=mnuid
			If wParam Then
				mnuid+=wParam-1
			EndIf
			Return x
			'
		Case AIM_OPENFILE
			lstrcpy(@buff,Cast(ZString Ptr,lParam))
			OpenTheFile(buff,wParam)
			'
	    Case WM_COPYDATA               ' processing command line if single instance option is enabled
			lpCOPYDATASTRUCT=Cast(COPYDATASTRUCT Ptr,lParam)
			CommandLine=lpCOPYDATASTRUCT->lpData
			DoCommandLine        
			'
		Case WM_QUERYENDSESSION
			SendMessage(hWin,WM_CLOSE,0,0)
	        '
		'Case WM_CHAR 
		'	DebugPrint (wParam)	
		Case Else
			Return DefWindowProc(hWin,uMsg,wParam,lParam)
			'
	End Select
	Return 0

End Function

Function WinMain(ByVal hInst As HINSTANCE,ByVal hPrevInst As HINSTANCE,ByVal lpCmdLine As LPSTR,ByVal CmdShow As Integer) As Integer
	
	Dim wcex   As WNDCLASSEXA
	Dim msg    As MSG
	Dim cpd    As COPYDATASTRUCT
    Dim FBEWnd As HWND

	' Get AppPath
	GetModuleFileName NULL, @ad.AppPath, MAX_PATH
	GetFilePath ad.AppPath
	
	' Get inifilename
	GetModuleFileName NULL, @ad.IniFile, MAX_PATH
	PathRenameExtension ad.IniFile, ".ini" 
	CheckIniFile  
	
	' FbEdit development, use main ini file
	#If __FB_DEBUG__
    	GetPrivateProfileString "Win", "AppPath", NULL, @buff, MAX_PATH, @ad.IniFile
    	If IsZStrNotEmpty (buff) Then
    		ad.AppPath = buff
    		ad.IniFile = ad.AppPath + "\FbEdit.ini"
    	EndIf
	#EndIf 
	
	SetCurrentDirectory @ad.AppPath
	wpos = Type <WINPOS> (0, 10, 10, 780, 580, _
	                      VIEW_PROJECT Or VIEW_PROPERTY Or VIEW_TOOLBAR Or VIEW_TABSELECT Or VIEW_STATUSBAR, _ 
	                      (0, 0), 120, 160, (10, 10), (10, 10), 0, (150, 150), (10, 10))
	LoadFromIni "Win", "Winpos", "4444444444444444444", @wpos, FALSE
	LoadFromIni "Win", "ressize", "444444", @ressize, FALSE

	' handle single instance mode
	CommandLine = PathGetArgs (GetCommandLine)
	If wpos.singleinstance Then
		FBEWnd = FindWindow (@szMainWindowClassName, NULL)
		If FBEWnd Then
			If IsIconic (FBEWnd) Then
				ShowWindow FBEWnd, SW_RESTORE
			EndIf
			If IsZStrNotEmpty (*CommandLine) Then
				cpd.dwData = 0
				cpd.lpData = CommandLine
				cpd.cbData = lstrlen (CommandLine) + 1
				SendMessage FBEWnd, WM_COPYDATA, 0, Cast (LPARAM, @cpd)
			EndIf
			Return 0
		EndIf
	EndIf
	
	' Main window
	hIcon = LoadIcon (hInstance, Cast (ZString Ptr, IDC_MAINICON))
	wcex.cbSize        = SizeOf (WNDCLASSEX)
	wcex.style         = CS_HREDRAW Or CS_VREDRAW
	wcex.lpfnWndProc   = @MainDlgProc
	wcex.cbClsExtra    = NULL
	wcex.cbWndExtra    = DLGWINDOWEXTRA
	wcex.hInstance     = hInst
	wcex.hbrBackground = Cast (HBRUSH, COLOR_BTNFACE + 1)
	wcex.lpszMenuName  = MAKEINTRESOURCE (IDR_MENU)
	wcex.lpszClassName = @szMainWindowClassName
	wcex.hIcon         = hIcon
	wcex.hIconSm       = 0
	wcex.hCursor       = LoadCursor (NULL, IDC_ARROW)
	RegisterClassEx @wcex
	
	' Full screen
	wcex.cbSize        = SizeOf (WNDCLASSEXA)
	wcex.style         = CS_HREDRAW Or CS_VREDRAW
	wcex.lpfnWndProc   = @FullScreenProc
	wcex.cbClsExtra    = NULL
	wcex.cbWndExtra    = NULL
	wcex.hInstance     = hInst
	wcex.hbrBackground = Cast (HBRUSH, NULL)
	wcex.lpszMenuName  = NULL
	wcex.lpszClassName = @szFullScreenClassName
	wcex.hIcon         = 0
	wcex.hCursor       = LoadCursor (NULL, IDC_ARROW)
	wcex.hIconSm       = 0
	RegisterClassEx @wcex
	
	CreateDialog (hInst, MAKEINTRESOURCE (IDD_MAIN), NULL, @MainDlgProc)
	If wpos.fMax Then
		ShowWindow ah.hwnd, SW_MAXIMIZE
		SendMessage ah.hwnd, WM_SIZE, SIZE_RESTORED, 0
	Else
		ShowWindow ah.hwnd, SW_SHOWNORMAL
	EndIf
	UpdateWindow ah.hwnd

    ' CBH_Dialog  (ClipBoardHistory)
	CreateDialog (hInstance, MAKEINTRESOURCE (IDD_DLG_CBH), ah.hwnd, @CBHDlgProc)
	ThreadCall SplashScreen 
	FileMonitorStart
	
	DoCommandLine
	Do While GetMessage(@msg,NULL,0,0) > 0          ' exits on 0 (WM_QUIT) and -1 (error) 
		If TranslateAccelerator(ah.hwnd,ah.haccel,@msg)=0 Then
			If IsDialogMessage(ah.hfind,@msg)=0 Then
				If IsDialogMessage(ah.hrareseddlg,@msg)=0 Then
					TranslateMessage(@msg)
					DispatchMessage(@msg)
				EndIf
			EndIf
		EndIf
	Loop
	Return msg.wParam

End Function





' 	Program start

    Dim hRichEditDll As HMODULE
    Dim CH           As CaretHistory

	''
	'' Create the Dialog
	''
	hInstance = GetModuleHandle (NULL)
	hRichEditDll = LoadLibrary ("riched20.dll")

	ad.lpCharTab   = Getchartabptr ()
	ad.lpszVersion = @"FreeBASIC editor 1.0.7.8"
    ad.version     = 1078
	ad.lpBuff      = @buff
	ah.haccel      = LoadAccelerators (hInstance, Cast (ZString Ptr, IDA_ACCEL))
	af             = Type <ADDINFUNCTIONS> (@TextToOutput,         @SaveToIni,            @LoadFromIni, _
	                                        @OpenTheFile,          @Compile,              @ShowOutput,  _
	                                        @TranslateAddinDialog, @FindString,           @CallAddins,  _
	                                        @ShowImmediate,        @MakeProjectFileName,  @HH_Help,     _
	                                        @GetFileID)
	OleInitialize NULL
	WinMain hInstance, NULL, NULL, NULL
	OleUninitialize
	FreeAddins
	FreeLibrary hRichEditDll
	''
	'' Program has ended
	''
	ExitProcess 0
	End

'   Program end

