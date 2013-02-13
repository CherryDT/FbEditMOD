

#Include Once "windows.bi"
#Include Once "win\HtmlHelp.bi"
#Include Once "regex.bi"                        ' MOD 16.2.2012

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAResEd.bi"
#Include Once "Inc\RAProperty.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\CoTxEd.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\Project.bi"
#Include Once "Inc\SpecHandling.bi"
#Include Once "Inc\TabTool.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\Misc.bi"
#Include Once "Inc\showvars.bi"

'#Inclib "Htmlhelp.lib"
'#Inclib "..\..\..\MicrosoftSDKs\Windows\v7.1\Lib\Htmlhelp.lib"

'Type HH_AKLINK                                    ' HTML help
'	cbStruct	    As Integer
'	fReserved		As BOOLEAN 
'	pszKeywords		As ZString Ptr
'	pszUrl			As ZString Ptr
'	pszMsgText		As ZString Ptr
'	pszMsgTitle		As ZString Ptr
'	pszWindow		As ZString Ptr
'	fIndexOnFail	As BOOLEAN 
'End Type
'
'#Define HH_DISPLAY_TOPIC	&H0000
'#Define HH_KEYWORD_LOOKUP   &H000D

'Dim Shared hHtmlOcx      As HINSTANCE = 0 
'Dim Shared pHtmlHelpProc As Any Ptr   = 0
'Dim Shared hHHwin        As HWND      = 0
'Dim Shared hhaklink      As HH_AKLINK

'Declare Function HtmlHelp StdCall Alias "HtmlHelpA" (ByVal hwndCaller As HWND, ByVal pszFile As LPCSTR, ByVal uCommand As UINT, ByVal dwData As DWORD) As HWND

Dim Shared fSizeing As Integer
Dim Shared ppage    As PRNPAGE = ((21000,29700),(1000,1000,1000,1000),66,0)
Dim Shared psd      As PageSetupDlg
Dim Shared pd       As PrintDlg

 

Sub SearchRegEx (ByRef StartIdx    As Integer,      _
	             ByVal pSearchData As ZString Ptr,  _
	             ByVal pSearchExpr As ZString Ptr,  _
	             ByVal SubMatchNo  As Integer,      _
	             ByRef Found       As String,       _
	             ByRef pErrText    As ZString Ptr)  	
	
	
	Const  cFlags                   As Integer       = REG_EXTENDED Or REG_ICASE
    Const  MaxSubMatch              As Integer       = 9

    Static ErrText                  As ZString * 256
    
    Dim    RegEx                    As regex_t
	Dim    Match(0 To MaxSubMatch)  As regmatch_t
	Dim    ExitCode                 As Integer       = Any
	Dim    SearchDataLen            As Integer       = lstrlen (pSearchData) 
	
    
    If (StartIdx > SearchDataLen) OrElse (StartIdx < 0) Then 
	    pErrText = @"index out of range"
	    Found    = ""
		StartIdx = 0
		Exit Sub
    EndIf
    	
	If (SubMatchNo < 0) OrElse (SubMatchNo > MaxSubMatch) Then
	    pErrText = @"submatch index out of range"
	    Found    = ""
		StartIdx = 0
		Exit Sub
	EndIf
	
	ExitCode = RegComp(@RegEx, pSearchExpr, cFlags)
	If ExitCode Then 
	    RegError(ExitCode, @RegEx, @ErrText, SizeOf (ErrText))
   	    pErrText = @ErrText
	    Found    = ""
		StartIdx = 0
		Exit Sub
	EndIf 
	    	
	If RegExec(@RegEx, pSearchData + StartIdx, MaxSubMatch + 1, @Match(0), 0) Then
	    pErrText = @"not found"
	    Found    = ""
		StartIdx = 0
	Else
		pErrText = @""                                      ' success
		Found    = Mid (*pSearchData, StartIdx + Match(SubMatchNo).rm_so + 1, Match(SubMatchNo).rm_eo - Match(SubMatchNo).rm_so)
		StartIdx += Match(0).rm_eo 
		If StartIdx >= SearchDataLen Then StartIdx = 0	    ' flagging: end reached
	EndIf

	RegFree(@RegEx)

End Sub 

Function MyGlobalAlloc (ByVal nType As UINT, ByVal nSize As DWORD) As HGLOBAL
	Dim hMem As HGLOBAL

Retry:

	hMem = GlobalAlloc (nType, nSize)
	If hMem = 0 Then
		Select Case MessageBox(ah.hwnd,"Memory allocation failed." & CRLF & Str(nSize) & " Bytes.",@szAppName,MB_ABORTRETRYIGNORE Or MB_ICONERROR)
			Case IDRETRY
				GoTo Retry
				'
			Case IDABORT
				End
				'
			Case IDIGNORE
				'
		End Select
	EndIf
	Return hMem

End Function

Sub HH_Help

    Dim hhaklink As HH_AKLINK = Any  

    hhaklink.cbStruct     = SizeOf (HH_AKLINK)
    hhaklink.fReserved    = FALSE
    hhaklink.pszKeywords  = @s
    hhaklink.pszUrl       = NULL
    hhaklink.pszMsgText   = NULL
    hhaklink.pszMsgTitle  = NULL
    hhaklink.pszWindow    = NULL
    hhaklink.fIndexOnFail = TRUE 
    
    HtmlHelp 0, @buff, HH_DISPLAY_TOPIC , 0
    HtmlHelp 0, @buff, HH_KEYWORD_LOOKUP, Cast (DWORD, @hhaklink)

End Sub

'Sub HH_Helpold ()
'
'    Print "HH_Help"
'    DebugPrint (buff)
'    DebugPrint (s)
'    
'	If hHtmlOcx=0 Then
'		hHtmlOcx=LoadLibrary(StrPtr("hhctrl.ocx"))
'		pHtmlHelpProc=GetProcAddress(hHtmlOcx,StrPtr("HtmlHelpA"))
'	EndIf
'	
'	DebugPrint (hHtmlOcx)
'	DebugPrint (pHtmlHelpProc)
'	
'	If hHtmlOcx Then
'		hhaklink.cbStruct=SizeOf(HH_AKLINK)
'		hhaklink.fReserved=FALSE
'		hhaklink.pszKeywords=@s
'		hhaklink.pszUrl=NULL
'		hhaklink.pszMsgText=NULL
'		hhaklink.pszMsgTitle=NULL
'		hhaklink.pszWindow=NULL
'		hhaklink.fIndexOnFail=TRUE 
'		Asm
'			'hHHwin = HtmlHelp (0, @buff, HH_DISPLAY_TOPIC, NULL)
'			push 0
'			push HH_DISPLAY_TOPIC
'			'lea	 eax,buff               ' help file spec
'			'push eax
'			push offset buff
'			push 0
'			Call [pHtmlHelpProc]
'			mov	 hHHwin,eax
'			'HtmlHelp (0, @buff, HH_KEYWORD_LOOKUP, @hhaklink)
'			'lea	 eax,hhaklink
'			'push eax
'			push offset hhaklink
'			push HH_KEYWORD_LOOKUP
'			'lea	 eax,buff
'			'push eax
'			push offset buff
'			push 0
'			Call [pHtmlHelpProc]
'		End Asm
'	EndIf
'
'End Sub

Sub EnableDisable(ByVal bm As Long,ByVal id As Long)
	
	Dim hMnu As HMENU = Any 

	hMnu=GetMenu(ah.hwnd)
	EnableMenuItem(hMnu,id,IIf(bm,MF_ENABLED,MF_GRAYED))
	SendMessage(ah.htoolbar,TB_ENABLEBUTTON,id,IIf(bm,TRUE,FALSE))
	
End Sub

'===================================
' MOD 17.1.2012 ADD
#Macro Enable (id)
	EnableMenuItem hMnu,id, MF_ENABLED       ' set outside!   hMnu = GetMenu (ah.hwnd)
	SendMessage ah.htoolbar, TB_ENABLEBUTTON, id, TRUE
#EndMacro
'Sub Enable (ByVal id As Long)
'	
'	Dim hMnu As HMENU = Any 
'
'	hMnu = GetMenu (ah.hwnd)
'	EnableMenuItem hMnu,id, MF_ENABLED
'	SendMessage ah.htoolbar, TB_ENABLEBUTTON, id, TRUE
'	
'End Sub
'===================================

'===================================
' MOD 17.1.2012 ADD
#Macro Disable (id)
	EnableMenuItem hMnu,id, MF_GRAYED        ' set outside!   hMnu = GetMenu (ah.hwnd)
	SendMessage ah.htoolbar, TB_ENABLEBUTTON, id, FALSE 
#EndMacro
'Sub Disable (ByVal id As Long)
'	
'	Dim hMnu As HMENU = Any 
'
'	hMnu = GetMenu (ah.hwnd)
'	EnableMenuItem hMnu,id, MF_GRAYED
'	SendMessage ah.htoolbar, TB_ENABLEBUTTON, id, FALSE 
'	
'End Sub
'===================================

#Macro EnableContext (id)
	EnableMenuItem ah.hcontextmenu, id, MF_ENABLED
#EndMacro

#Macro DisableContext (id)
	EnableMenuItem ah.hcontextmenu, id, MF_GRAYED
#EndMacro

Sub EnableDisableContext(ByVal bm As Long,ByVal id As Long)

	'Dim hMnu As HMENU = Any               MOD 8.2.2012 

	'hMnu=GetMenu(ah.hwnd)                 MOD 8.2.2012
	EnableMenuItem(ah.hcontextmenu,id,IIf(bm,MF_ENABLED,MF_GRAYED))
	
End Sub

Sub CheckMenu()

	CheckMenuItem(ah.hmenu,IDM_VIEW_OUTPUT,IIf(wpos.fview And VIEW_OUTPUT,MF_CHECKED,MF_UNCHECKED))
	CheckMenuItem(ah.hmenu,IDM_VIEW_IMMEDIATE,IIf(wpos.fview And VIEW_IMMEDIATE,MF_CHECKED,MF_UNCHECKED))
	CheckMenuItem(ah.hmenu,IDM_VIEW_PROJECT,IIf(wpos.fview And VIEW_PROJECT,MF_CHECKED,MF_UNCHECKED))
	CheckMenuItem(ah.hmenu,IDM_VIEW_PROPERTY,IIf(wpos.fview And VIEW_PROPERTY,MF_CHECKED,MF_UNCHECKED))

	CheckMenuItem(ah.hmenu,IDM_VIEW_TOOLBAR,IIf(wpos.fview And VIEW_TOOLBAR,MF_CHECKED,MF_UNCHECKED))
	CheckMenuItem(ah.hmenu,IDM_VIEW_TABSELECT,IIf(wpos.fview And VIEW_TABSELECT,MF_CHECKED,MF_UNCHECKED))
	CheckMenuItem(ah.hmenu,IDM_VIEW_STATUSBAR,IIf(wpos.fview And VIEW_STATUSBAR,MF_CHECKED,MF_UNCHECKED))
    ' MOD 31.1.2012 ADD
    CheckMenuItem ah.hmenu, IDM_VIEW_DIALOG,IIf (SendMessage (ah.hraresed, DEM_GETSHOWDIALOG, 0, 0), MF_CHECKED, MF_UNCHECKED)
   	CheckMenuItem ah.hmenu, IDM_EDIT_BLOCKMODE, IIf (SendMessage (ah.hred, REM_GETMODE, 0, 0) And MODE_BLOCK, MF_CHECKED, MF_UNCHECKED)
    ' =================
	CheckMenuItem(ah.hmenu,IDM_FORMAT_LOCK,IIf(SendMessage(ah.hraresed,DEM_ISLOCKED,0,0),MF_CHECKED,MF_UNCHECKED))
	CheckMenuItem(ah.hmenu,IDM_FORMAT_GRID,IIf(GetWindowLong(ah.hraresed,GWL_STYLE) And DES_GRID,MF_CHECKED,MF_UNCHECKED))
	CheckMenuItem(ah.hmenu,IDM_FORMAT_SNAP,IIf(GetWindowLong(ah.hraresed,GWL_STYLE) And DES_SNAPTOGRID,MF_CHECKED,MF_UNCHECKED))
	CheckMenuItem(ah.hcontextmenu,IDM_FORMAT_LOCK,IIf(SendMessage(ah.hraresed,DEM_ISLOCKED,0,0),MF_CHECKED,MF_UNCHECKED))
	CheckMenuItem(ah.hcontextmenu,IDM_FORMAT_GRID,IIf(GetWindowLong(ah.hraresed,GWL_STYLE) And DES_GRID,MF_CHECKED,MF_UNCHECKED))
	CheckMenuItem(ah.hcontextmenu,IDM_FORMAT_SNAP,IIf(GetWindowLong(ah.hraresed,GWL_STYLE) And DES_SNAPTOGRID,MF_CHECKED,MF_UNCHECKED))

End Sub

#Macro DisMenu (Condition, ID)
	
	EnableMenuItem hMnu           , ID, IIf (Condition, MF_GRAYED, MF_ENABLED)
	EnableMenuItem ah.hcontextmenu, ID, IIf (Condition, MF_GRAYED, MF_ENABLED)
	SendMessage ah.htoolbar, TB_ENABLEBUTTON, ID, IIf (Condition, FALSE, TRUE)
	
#EndMacro   

#Macro EnMenu (Condition, ID)
	
	EnableMenuItem hMnu           , ID, IIf (Condition, MF_ENABLED, MF_GRAYED)
	EnableMenuItem ah.hcontextmenu, ID, IIf (Condition, MF_ENABLED, MF_GRAYED)
	SendMessage ah.htoolbar, TB_ENABLEBUTTON, ID, IIf (Condition, TRUE, FALSE)
	
#EndMacro   

#Macro DisCtxMenu (Condition, ID)
	
	EnableMenuItem ah.hcontextmenu, ID, IIf (Condition, MF_GRAYED, MF_ENABLED)
	
#EndMacro   

#Macro EnCtxMenu (Condition, ID)
	
	EnableMenuItem ah.hcontextmenu, ID, IIf (Condition, MF_ENABLED, MF_GRAYED)
	
#EndMacro   

Sub EnableMenu ()

    Dim hMnu As HMENU = Any 

	hMnu = GetMenu (ah.hwnd)
    Dim NoTabOpen          As BOOL      = FALSE 
    Dim AnyTabOpen         As BOOL      = FALSE
	Dim TabIsRESED         As BOOL      = FALSE
	Dim TabIsCODEED        As BOOL      = FALSE
	Dim TabIsHEXED         As BOOL      = FALSE
	Dim TabIsTEXTED        As BOOL      = FALSE
	Dim TabIsCOTXED        As BOOL      = FALSE 
	Dim TabIsAlpha         As BOOL      = FALSE
	Dim TabIsAny           As BOOL      = FALSE
	Dim TabIsProject       As BOOL      = FALSE
	Dim TabCanUndo         As BOOL      = FALSE 
	Dim TabCanRedo         As BOOL      = FALSE
	Dim TabHasSel          As BOOL      = FALSE
	Dim TabCanPaste        As BOOL      = FALSE
	Dim TabHasDeclareQueue As BOOL      = FALSE 
	Dim EditorMode         As Long      = 0
	Dim TabCount           As Integer   = 0
	Dim PropertyValid      As BOOL      = FALSE
	Dim BlockMode          As BOOL      = FALSE 
	Dim ID                 As Integer   = Any 
	Dim chrg               As CHARRANGE = Any 
	
	
    'hCtl = GetParent (GetFocus)
    'If hCtl Then
    '    If hCtl = ah.hred OrElse hCtl = ah.hout OrElse hCtl = ah.himm Then
    '        FocusIsRAEdit = TRUE	
    '    EndIf
    'EndIf
	
	If ah.hred Then
		EditorMode    = GetWindowLong (ah.hred, GWL_ID)
		TabIsRESED    = (EditorMode =  IDC_RESED)
		TabIsCODEED   = (EditorMode =  IDC_CODEED)
		TabIsHEXED    = (EditorMode =  IDC_HEXED)
		TabIsTEXTED   = (EditorMode =  IDC_TEXTED)
		TabIsCOTXED   = TabIsCODEED Or TabIsTEXTED
		TabIsAlpha    = Not (TabIsRESED)
		TabIsAny      = TRUE
		TabIsProject  = fProject
		TabCount      = SendMessage (ah.htabtool, TCM_GETITEMCOUNT, 0, 0)
		PropertyValid = SendMessage (ah.hpr, PRM_GETCURSEL, 0, 0) <> LB_ERR
		BlockMode     = (SendMessage (ah.hred, REM_GETMODE, 0, 0) And MODE_BLOCK) <> 0 
		TabCanUndo    = (TabIsAlpha AndAlso SendMessage (ah.hred, EM_CANUNDO, 0, 0)) OrElse _
		             	(TabIsRESED AndAlso SendMessage (ah.hraresed, DEM_CANUNDO, 0, 0))
		TabCanRedo    = (TabIsAlpha AndAlso SendMessage (ah.hred, EM_CANREDO, 0, 0)) OrElse _
		             	(TabIsRESED AndAlso SendMessage (ah.hraresed, DEM_CANREDO, 0, 0))
        
        SendMessage ah.hred, EM_EXGETSEL, 0, Cast (LPARAM, @chrg)
        
        TabHasSel     = (TabIsAlpha AndAlso (chrg.cpMax <> chrg.cpMin)) OrElse _
                        (TabIsRESED AndAlso	SendMessage (ah.hraresed, DEM_ISSELECTION, 0, 0))
		TabCanPaste   = (TabIsAlpha AndAlso SendMessage (ah.hred, EM_CANPASTE, CF_TEXT, 0)) OrElse _
		                (TabIsRESED AndAlso SendMessage (ah.hraresed, DEM_CANPASTE, 0, 0))
				
        'TabHasDeclareQueue = TabIsCODEED AndAlso fdc(fdcpos).hwnd 
	Else
		NoTabOpen = TRUE 	
	EndIf
		
	'IDM_FILE					
	'IDM_FILE_NEWPROJECT		
	'IDM_FILE_OPENPROJECT		
	EnMenu (fProject,           IDM_FILE_CLOSEPROJECT)
	'IDM_FILE_NEW				
	'IDM_FILE_NEW_RESOURCE		
	'IDM_FILE_OPEN_STD   		
	'IDM_FILE_OPEN_HEX			
	'IDM_FILE_OPEN_TXT			
	'IDM_FILE_RECENTFILE		
	EnMenu (TabIsAny,           IDM_FILE_SAVE    )
	EnMenu (TabIsAny,           IDM_FILE_SAVEALL )
	EnMenu (TabIsAny,           IDM_FILE_SAVEAS  )
	EnMenu (TabIsAny,           IDM_FILE_CLOSE   )
	EnMenu (TabIsAny,           IDM_FILE_CLOSEALL)
	'IDM_FILE_PAGESETUP
    EnMenu (TabIsAlpha,         IDM_FILE_PRINT   )
	'IDM_FILE_EXIT				

	'IDM_EDIT					
	EnMenu (TabCanUndo,         IDM_EDIT_UNDO)
    EnMenu (TabCanRedo,         IDM_EDIT_REDO)
    EnMenu (TabIsCOTXED,        IDM_EDIT_EMPTYUNDO)
    'EnMenu (TabHasSel,          IDM_EDIT_CUT)
    'EnMenu (TabHasSel,          IDM_EDIT_COPY)
    'EnMenu (TabCanPaste,        IDM_EDIT_PASTE)
	'EnMenu (TabIsAlpha,         IDM_EDIT_DELETE)
	'EnMenu (TabIsAlpha,         IDM_EDIT_SELECTALL)
	EnMenu (TabIsAlpha,         IDM_EDIT_GOTO)
	EnMenu (TabIsAlpha,         IDM_EDIT_FIND)
	EnMenu (TabIsAlpha,         IDM_EDIT_FINDNEXT)
	EnMenu (TabIsAlpha,         IDM_EDIT_FINDPREVIOUS)
	EnMenu (TabIsAlpha,         IDM_EDIT_REPLACE)
	EnMenu (TabIsCODEED,        IDM_EDIT_FINDDECLARE)
	'EnMenu (TabHasDeclareQueue, IDM_EDIT_RETURN)
	EnMenu (TabIsCODEED,        IDM_EDIT_EXPAND)
	
	'IDM_EDIT_BLOCK
	EnMenu (TabIsCOTXED,        IDM_EDIT_BLOCKINDENT)
	EnMenu (TabIsCOTXED,        IDM_EDIT_BLOCKOUTDENT)
	EnMenu (TabIsCODEED,        IDM_EDIT_BLOCKCOMMENT)
	EnMenu (TabIsCODEED,        IDM_EDIT_BLOCKUNCOMMENT)
	EnMenu (TabIsCOTXED AndAlso TabHasSel, IDM_EDIT_BLOCKTRIM)
	EnMenu (TabIsCOTXED AndAlso TabHasSel, IDM_EDIT_CONVERTTAB)		 
	EnMenu (TabIsCOTXED AndAlso TabHasSel, IDM_EDIT_CONVERTSPACE)	
	EnMenu (TabIsCOTXED AndAlso TabHasSel, IDM_EDIT_CONVERTUPPER)	
	EnMenu (TabIsCOTXED AndAlso TabHasSel, IDM_EDIT_CONVERTLOWER)	
    EnMenu (TabIsCOTXED                  , IDM_EDIT_BLOCKMODE)
    EnMenu (TabIsCOTXED AndAlso BlockMode, IDM_EDIT_BLOCK_INSERT)

	'IDM_EDIT_BOOKMARK
'IDM_EDIT_BOOKMARKTOGGLE		    	10051
'IDM_EDIT_BOOKMARKNEXT				10052
'IDM_EDIT_BOOKMARKPREVIOUS		    10053
'IDM_EDIT_BOOKMARKDELETE	    		10054
'IDM_EDIT_BOOKMARKLIST               10089
'IDM_EDIT_ERROR						10055
'IDM_EDIT_ERRORNEXT					10056
'IDM_EDIT_ERRORCLEAR			    	10057
'IDM_EDIT_HISTORYPASTE               10090  
	EnMenu (TabIsCOTXED, IDM_EDIT_ELEVATOR_UP)
	EnMenu (TabIsCOTXED, IDM_EDIT_ELEVATOR_DOWN)

	'IDM_FORMAT						
    EnMenu (TabIsRESED, IDM_FORMAT_LOCK)
    EnMenu (TabIsRESED, IDM_FORMAT_BACK)
    EnMenu (TabIsRESED, IDM_FORMAT_FRONT)
    EnMenu (TabIsRESED, IDM_FORMAT_GRID)					
    EnMenu (TabIsRESED, IDM_FORMAT_SNAP)					
	'IDM_FORMAT_ALIGN				
    EnMenu (TabIsRESED, IDM_FORMAT_ALIGN_LEFT)	
    EnMenu (TabIsRESED, IDM_FORMAT_ALIGN_CENTER)
    EnMenu (TabIsRESED, IDM_FORMAT_ALIGN_RIGHT)	  
    EnMenu (TabIsRESED, IDM_FORMAT_ALIGN_TOP)	
    EnMenu (TabIsRESED, IDM_FORMAT_ALIGN_MIDDLE)
    EnMenu (TabIsRESED, IDM_FORMAT_ALIGN_BOTTOM)
	'IDM_FORMAT_SIZE				
    EnMenu (TabIsRESED, IDM_FORMAT_SIZE_WIDTH)		
    EnMenu (TabIsRESED, IDM_FORMAT_SIZE_HEIGHT)		
    EnMenu (TabIsRESED, IDM_FORMAT_SIZE_BOTH)		
	'IDM_FORMAT_CENTER				
    EnMenu (TabIsRESED, IDM_FORMAT_CENTER_HOR)			
    EnMenu (TabIsRESED, IDM_FORMAT_CENTER_VER)			
    EnMenu (TabIsRESED, IDM_FORMAT_TAB)	
    EnMenu (TabIsRESED, IDM_FORMAT_RENUM)
    EnMenu (TabIsAlpha, IDM_FORMAT_CASECONVERT)
    EnMenu (TabIsAlpha, IDM_FORMAT_INDENT)

	'IDM_VIEW						
	'IDM_VIEW_OUTPUT				
	'IDM_VIEW_IMMEDIATE				
	'IDM_VIEW_PROJECT				
	'IDM_VIEW_PROPERTY				
	'IDM_VIEW_TOOLBAR				
	'IDM_VIEW_TABSELECT				
	'IDM_VIEW_STATUSBAR				
	EnMenu (TabIsRESED, IDM_VIEW_DIALOG)
	EnMenu (TabIsAlpha, IDM_VIEW_SPLITSCREEN)			
	EnMenu (TabIsAny, IDM_VIEW_FULLSCREEN)			
	EnMenu (TabIsAny, IDM_VIEW_DUALPANE)				


	'IDM_PROJECT
	'IDM_PROJECT_ADDNEW
	EnMenu (fProject, IDM_PROJECT_ADDNEWFILE)         
	EnMenu (fProject, IDM_PROJECT_ADDNEWMODULE)         
	'IDM_PROJECT_ADDEXISTING
	EnMenu (fProject, IDM_PROJECT_ADDEXISTINGFILE)
    EnMenu (fProject, IDM_PROJECT_ADDEXISTINGMODULE)
	EnMenu (fProject, IDM_PROJECT_SETMAIN)	    		
	EnMenu (fProject, IDM_PROJECT_TOGGLE)				
	EnMenu (fProject, IDM_PROJECT_REMOVE)				
	EnMenu (fProject, IDM_PROJECT_RENAME)				
	EnMenu (fProject, IDM_PROJECT_INCLUDE)	
	EnMenu (fProject, IDM_PROJECT_INCLUDE_ONCE)	    	
	EnMenu (fProject, IDM_PROJECT_OPTIONS)			    
	EnMenu (fProject, IDM_PROJECT_CREATETEMPLATE)		 
	'IDM_PROJECT_FILE_OPEN             
	EnMenu (fProject, IDM_PROJECT_FILE_OPEN_TXT)         
	EnMenu (fProject, IDM_PROJECT_FILE_OPEN_STD)         
	EnMenu (fProject, IDM_PROJECT_FILE_OPEN_HEX)         

    'IDM_RESOURCE						
    EnMenu (TabIsRESED, IDM_RESOURCE_DIALOG)                                                                    
    EnMenu (TabIsRESED, IDM_RESOURCE_MENU)				
    EnMenu (TabIsRESED, IDM_RESOURCE_ACCEL)				
    EnMenu (TabIsRESED, IDM_RESOURCE_STRINGTABLE)		
    EnMenu (TabIsRESED, IDM_RESOURCE_VERSION)			
    EnMenu (TabIsRESED, IDM_RESOURCE_XPMANIFEST)	    
    EnMenu (TabIsRESED, IDM_RESOURCE_RCDATA)			 
    EnMenu (TabIsRESED, IDM_RESOURCE_LANGUAGE)			
    EnMenu (TabIsRESED, IDM_RESOURCE_INCLUDE)			
    EnMenu (TabIsRESED, IDM_RESOURCE_RES)				
    EnMenu (TabIsRESED, IDM_RESOURCE_NAMES)				
    EnMenu (TabIsRESED, IDM_RESOURCE_EXPORT)			 
    EnMenu (TabIsRESED, IDM_RESOURCE_REMOVE)			 
    EnMenu (TabIsRESED, IDM_RESOURCE_UNDO)				
	For ID = 22000 To 22032       ' Custom resource
		EnMenu (TabIsRESED,	ID)
	Next


	'IDM_MAKE				
	'IDM_MAKE_COMPILE		
	'IDM_MAKE_RUN			
	'IDM_MAKE_GO			
	'IDM_MAKE_RUNDEBUG		
	EnMenu (fProject, IDM_MAKE_MODULE)	    		
	'IDM_MAKE_QUICKRUN		

	'IDM_TOOLS							 
	EnMenu (TabIsAny, IDM_TOOLS_EXPORT)

	'IDM_OPTIONS					
	'IDM_OPTIONS_LANGUAGE			
	'IDM_OPTIONS_CODE				
	'IDM_OPTIONS_DIALOG				
	'IDM_OPTIONS_PATH				
	'IDM_OPTIONS_DEBUG				
	'IDM_OPTIONS_MAKE				
	'IDM_OPTIONS_EXTERNALFILES		   
	'IDM_OPTIONS_ADDINS
	'IDM_OPTIONS_ENVIRONMENT				
	'IDM_OPTIONS_TOOLS				
	'IDM_OPTIONS_HELP				

	'IDM_HELP
	'IDM_HELP_ABOUT

	'context menu
	'IDM_WINDOW_TOGGLE_LOCK
    'IDM_WINDOW_UNLOCKALL
	'IDM_WINDOW_ALL_BUT_CURRENT
	EnMenu (TabCount > 1, IDM_WINDOW_NEXTTAB)		
	EnMenu (TabCount > 1, IDM_WINDOW_PREVIOUSTAB)
	'IDM_WINDOW_SWITCHTAB
	EnMenu (fProject, IDM_WINDOW_TAB2PROJECT)
	'IDM_WINDOW_CLOSE_ALL_NONPROJECT

	'IDM_OUTPUT_CLEAR				
	'IDM_OUTPUT_SELECTALL			
	'IDM_OUTPUT_COPY				

	'IDM_IMMEDIATE_CLEAR            
	'IDM_IMMEDIATE_SELECTALL        
	'IDM_IMMEDIATE_COPY             
	
	EnMenu (PropertyValid, IDM_PROPERTY_JUMP)
	EnMenu (PropertyValid, IDM_PROPERTY_COPY_NAME)
	EnMenu (PropertyValid, IDM_PROPERTY_COPY_SPEC)
	'IDM_PROPERTY_FINDALL			
	'IDM_PROPERTY_HILIGHT
	'IDM_PROPERTY_HILIGHT_UPDATE 	
	'IDM_PROPERTY_HILIGHT_RESET 	

	'IDM_FIB_OPEN_STD                   
	'IDM_FIB_OPEN_HEX                   
	'IDM_FIB_OPEN_TXT                   
    
    'accelerator only
	'IDM_HELPF1							
	'IDM_HELPCTRLF1						

End Sub

'Sub EnableMenu2()
'	Dim bm As Integer = Any
'	Dim chrg As CHARRANGE
'	Dim id As Integer = Any
'    Dim hMnu As HMENU = Any 
'
'	hMnu = GetMenu (ah.hwnd)
'
'	If ah.hred=ah.hres Then
'		' Resource editor
'    	Enable(IDM_FILE_SAVE)
'		Enable(IDM_FILE_SAVEALL)
'		Enable(IDM_FILE_SAVEAS)
'		Enable(IDM_FILE_CLOSE)
'		Enable(IDM_FILE_CLOSEALL)
'		Disable(IDM_FILE_PRINT)
'		Disable(IDM_EDIT_GOTO)
'		Disable(IDM_EDIT_ELEVATOR_UP)
'		Disable(IDM_EDIT_ELEVATOR_DOWN)
'		Disable(IDM_EDIT_FIND)
'		Disable(IDM_EDIT_FINDNEXT)
'		Disable(IDM_EDIT_FINDPREVIOUS)
'		Disable(IDM_EDIT_REPLACE)
'		Disable(IDM_EDIT_FINDDECLARE)
'		'Disable(IDM_EDIT_RETURN)
'		Disable(IDM_EDIT_BLOCKINDENT)
'		Disable(IDM_EDIT_BLOCKOUTDENT)
'		Disable(IDM_EDIT_BLOCKCOMMENT)
'		Disable(IDM_EDIT_BLOCKUNCOMMENT)
'		Disable(IDM_EDIT_BLOCKTRIM)
'		Disable(IDM_EDIT_CONVERTTAB)
'		Disable(IDM_EDIT_CONVERTSPACE)
'		Disable(IDM_EDIT_CONVERTUPPER)
'		Disable(IDM_EDIT_CONVERTLOWER)
'		Disable(IDM_EDIT_BLOCKMODE)
'		Disable(IDM_EDIT_BLOCK_INSERT)
'		Disable(IDM_EDIT_EMPTYUNDO)
'		Disable(IDM_EDIT_EXPAND)
'		bm=SendMessage(ah.hraresed,DEM_CANUNDO,0,0)
'		EnableDisable(bm,IDM_EDIT_UNDO)
'		bm=SendMessage(ah.hraresed,DEM_CANREDO,0,0)
'		EnableDisable(bm,IDM_EDIT_REDO)
'		bm=SendMessage(ah.hraresed,DEM_ISSELECTION,0,0)
'		EnableDisable(bm,IDM_EDIT_CUT)
'		EnableDisable(bm,IDM_EDIT_COPY)
'		EnableDisable(bm,IDM_EDIT_DELETE)
'		EnableDisableContext(bm,IDM_EDIT_CUT)
'		EnableDisableContext(bm,IDM_EDIT_COPY)
'		EnableDisableContext(bm,IDM_EDIT_DELETE)
'		Disable(IDM_EDIT_SELECTALL)
'		EnableDisable(bm,IDM_FORMAT_CENTER)
'		EnableDisableContext(bm,IDM_FORMAT_CENTER)
'		If bm<>2 Then
'			bm=0
'		EndIf
'		EnableDisable(bm,IDM_FORMAT_ALIGN)
'		EnableDisable(bm,IDM_FORMAT_SIZE)
'		EnableDisable(bm,IDM_FORMAT_RENUM)
'		EnableDisableContext(bm,IDM_FORMAT_ALIGN)
'		EnableDisableContext(bm,IDM_FORMAT_SIZE)
'		EnableDisableContext(bm,IDM_FORMAT_RENUM)
'		bm=SendMessage(ah.hraresed,DEM_CANPASTE,0,0)
'		EnableDisable(bm,IDM_EDIT_PASTE)
'		EnableDisableContext(bm,IDM_EDIT_PASTE)
'		Disable(IDM_EDIT_HISTORYPASTE)
'		Disable(IDM_EDIT_BOOKMARKTOGGLE)
'		Disable(IDM_EDIT_BOOKMARKNEXT)
'		Disable(IDM_EDIT_BOOKMARKPREVIOUS)
'		Disable(IDM_EDIT_BOOKMARKDELETE)
'		Disable(IDM_EDIT_ERRORCLEAR)
'		Disable(IDM_EDIT_ERRORNEXT)
'		Enable(IDM_FORMAT_LOCK)
'		EnableContext(IDM_FORMAT_LOCK)
'		bm=SendMessage(ah.hraresed,DEM_ISBACK,0,0) Xor TRUE
'		EnableDisable(bm,IDM_FORMAT_BACK)
'		EnableDisableContext(bm,IDM_FORMAT_BACK)
'		bm=SendMessage(ah.hraresed,DEM_ISFRONT,0,0) Xor TRUE
'		EnableDisable(bm,IDM_FORMAT_FRONT)
'		EnableDisableContext(bm,IDM_FORMAT_FRONT)
'		Enable(IDM_FORMAT_GRID)
'		Enable(IDM_FORMAT_SNAP)
'		Enable(IDM_FORMAT_TAB)
'		EnableContext(IDM_FORMAT_GRID)
'		EnableContext(IDM_FORMAT_SNAP)
'		EnableContext(IDM_FORMAT_TAB)
'		Disable(IDM_FORMAT_CASECONVERT)
'		Disable(IDM_FORMAT_INDENT)
'		Enable(IDM_VIEW_DIALOG)
'		Disable(IDM_VIEW_SPLITSCREEN)
'		Enable(IDM_VIEW_FULLSCREEN)
'		Enable(IDM_VIEW_DUALPANE)
'		Disable(IDM_PROJECT_INCLUDE)
'		DisableContext(IDM_PROJECT_INCLUDE)
'		Enable(IDM_RESOURCE_DIALOG)
'		Enable(IDM_RESOURCE_MENU)
'		Enable(IDM_RESOURCE_ACCEL)
'		Enable(IDM_RESOURCE_STRINGTABLE)
'		Enable(IDM_RESOURCE_VERSION)
'		Enable(IDM_RESOURCE_XPMANIFEST)
'		Enable(IDM_RESOURCE_RCDATA)
'		For id=22000 To 22032
'			Enable(id)
'		Next
'		Enable(IDM_RESOURCE_LANGUAGE)
'		Enable(IDM_RESOURCE_INCLUDE)
'		Enable(IDM_RESOURCE_RES)
'		Enable(IDM_RESOURCE_NAMES)
'		Enable(IDM_RESOURCE_EXPORT)
'		Enable(IDM_RESOURCE_REMOVE)
'		Enable(IDM_RESOURCE_UNDO)
'		Disable(IDM_MAKE_QUICKRUN)
'		DisableContext(IDM_PROPERTY_JUMP)
'		DisableContext(IDM_PROPERTY_COPY_NAME)    ' MOD 23.1.2012
'		DisableContext(IDM_PROPERTY_COPY_SPEC)    ' MOD 23.1.2012 ADD
'	ElseIf ah.hred=0 Then
'		' No open files
'		Disable(IDM_FILE_SAVE)
'		Disable(IDM_FILE_SAVEALL)
'		Disable(IDM_FILE_SAVEAS)
'		Disable(IDM_FILE_CLOSE)
'		Disable(IDM_FILE_CLOSEALL)
'		Disable(IDM_FILE_PRINT)
'		Disable(IDM_EDIT_GOTO)
'		Disable(IDM_EDIT_ELEVATOR_UP)
'		Disable(IDM_EDIT_ELEVATOR_DOWN)
'		Disable(IDM_EDIT_FIND)
'		Disable(IDM_EDIT_FINDNEXT)
'		Disable(IDM_EDIT_FINDPREVIOUS)
'		Disable(IDM_EDIT_REPLACE)
'		Disable(IDM_EDIT_FINDDECLARE)
'		'Disable(IDM_EDIT_RETURN)
'		Disable(IDM_EDIT_BLOCKINDENT)
'		Disable(IDM_EDIT_BLOCKOUTDENT)
'		Disable(IDM_EDIT_BLOCKCOMMENT)
'		Disable(IDM_EDIT_BLOCKUNCOMMENT)
'		Disable(IDM_EDIT_BLOCKTRIM)
'		Disable(IDM_EDIT_CONVERTTAB)
'		Disable(IDM_EDIT_CONVERTSPACE)
'		Disable(IDM_EDIT_CONVERTUPPER)
'		Disable(IDM_EDIT_CONVERTLOWER)
'		Disable(IDM_EDIT_BLOCKMODE)
'		Disable(IDM_EDIT_BLOCK_INSERT)
'		Disable(IDM_EDIT_UNDO)
'		Disable(IDM_EDIT_REDO)
'		Disable(IDM_EDIT_EMPTYUNDO)
'		Disable(IDM_EDIT_CUT)
'		Disable(IDM_EDIT_COPY)
'		Disable(IDM_EDIT_DELETE)
'		Disable(IDM_EDIT_PASTE)
'		Disable(IDM_EDIT_HISTORYPASTE)
'		Disable(IDM_EDIT_SELECTALL)
'		Disable(IDM_EDIT_BOOKMARKTOGGLE)
'		Disable(IDM_EDIT_BOOKMARKNEXT)
'		Disable(IDM_EDIT_BOOKMARKPREVIOUS)
'		Disable(IDM_EDIT_BOOKMARKDELETE)
'		Disable(IDM_EDIT_BOOKMARKLIST)               ' MOD 22.2.2012 add
'		Disable(IDM_EDIT_ERRORCLEAR)
'		Disable(IDM_EDIT_ERRORNEXT)
'		Disable(IDM_EDIT_EXPAND)
'		Disable(IDM_FORMAT_LOCK)
'		Disable(IDM_FORMAT_BACK)
'		Disable(IDM_FORMAT_FRONT)
'		Disable(IDM_FORMAT_GRID)
'		Disable(IDM_FORMAT_SNAP)
'		Disable(IDM_FORMAT_ALIGN)
'		Disable(IDM_FORMAT_SIZE)
'		Disable(IDM_FORMAT_CENTER)
'		Disable(IDM_FORMAT_TAB)
'		Disable(IDM_FORMAT_RENUM)
'		Disable(IDM_FORMAT_CASECONVERT)
'		Disable(IDM_FORMAT_INDENT)
'		Disable(IDM_VIEW_DIALOG)
'		Disable(IDM_VIEW_SPLITSCREEN)
'		Disable(IDM_VIEW_FULLSCREEN)
'		Disable(IDM_VIEW_DUALPANE)
'		Disable(IDM_PROJECT_INCLUDE)
'		DisableContext(IDM_PROJECT_INCLUDE)
'		Disable(IDM_RESOURCE_DIALOG)
'		Disable(IDM_RESOURCE_MENU)
'		Disable(IDM_RESOURCE_ACCEL)
'		Disable(IDM_RESOURCE_STRINGTABLE)
'		Disable(IDM_RESOURCE_VERSION)
'		Disable(IDM_RESOURCE_XPMANIFEST)
'		Disable(IDM_RESOURCE_RCDATA)
'		For id=22000 To 22032
'			Disable(id)
'		Next
'		Disable(IDM_RESOURCE_LANGUAGE)
'		Disable(IDM_RESOURCE_INCLUDE)
'		Disable(IDM_RESOURCE_RES)
'		Disable(IDM_RESOURCE_NAMES)
'		Disable(IDM_RESOURCE_EXPORT)
'		Disable(IDM_RESOURCE_REMOVE)
'		Disable(IDM_RESOURCE_UNDO)
'		Disable(IDM_MAKE_QUICKRUN)
'		DisableContext(IDM_PROPERTY_JUMP)
'		DisableContext(IDM_PROPERTY_COPY_NAME)    ' MOD 23.1.2012
'		DisableContext(IDM_PROPERTY_COPY_SPEC)    ' MOD 23.1.2012 ADD
'	Else
'	    ' Code editor      IDC_CODEED OR IDC_HEXED OR IDC_TEXTED
'		Enable(IDM_FILE_SAVE)
'		Enable(IDM_FILE_SAVEALL)
'		Enable(IDM_FILE_SAVEAS)
'		Enable(IDM_FILE_CLOSE)
'		Enable(IDM_FILE_CLOSEALL)
'		Enable(IDM_FILE_PRINT)
'		Enable(IDM_EDIT_GOTO)
'		Enable(IDM_EDIT_FIND)
'		Enable(IDM_EDIT_FINDNEXT)
'		Enable(IDM_EDIT_FINDPREVIOUS)
'		Enable(IDM_EDIT_REPLACE)
'		If fdc(fdcpos).hwnd Then
'			'Enable(IDM_EDIT_RETURN)
'		Else
'			'Disable(IDM_EDIT_RETURN)
'		EndIf
'        
'        id=GetWindowLong(ah.hred,GWL_ID)
'		If id=IDC_CODEED Then
'    		Enable(IDM_EDIT_FINDDECLARE)
'    		Enable(IDM_MAKE_QUICKRUN)
'    		Enable(IDM_EDIT_EXPAND)
'    		Enable(IDM_FORMAT_INDENT)
'    		Enable(IDM_FORMAT_CASECONVERT)
'    		Enable(IDM_EDIT_BLOCKCOMMENT)
'    		Enable(IDM_EDIT_BLOCKUNCOMMENT)
'    		Enable(IDM_EDIT_BLOCKINDENT)
'    		Enable(IDM_EDIT_BLOCKOUTDENT)
'    		Enable(IDM_EDIT_BLOCKMODE)
'		    Enable(IDM_EDIT_ELEVATOR_UP)
'		    Enable(IDM_EDIT_ELEVATOR_DOWN)
'
'		Else ' IDC_HEXED
'    		Disable(IDM_EDIT_FINDDECLARE)
'    		Disable(IDM_MAKE_QUICKRUN)
'    		Disable(IDM_EDIT_EXPAND)
'    		Disable(IDM_FORMAT_INDENT)
'    		Disable(IDM_FORMAT_CASECONVERT)
'    		Disable(IDM_EDIT_BLOCKCOMMENT)
'    		Disable(IDM_EDIT_BLOCKUNCOMMENT)
'    		Disable(IDM_EDIT_BLOCKINDENT)
'    		Disable(IDM_EDIT_BLOCKOUTDENT)
'    		Disable(IDM_EDIT_BLOCKMODE)
'    		Disable(IDM_EDIT_ELEVATOR_UP)
'    		Disable(IDM_EDIT_ELEVATOR_DOWN)
'
'		EndIf
'		
'		'If id=IDC_HEXED Then
'    	'	Disable(IDM_EDIT_BLOCKCOMMENT)
'    	'	Disable(IDM_EDIT_BLOCKUNCOMMENT)
'    	'	Disable(IDM_EDIT_BLOCKINDENT)
'    	'	Disable(IDM_EDIT_BLOCKOUTDENT)
'    	'	Disable(IDM_EDIT_BLOCKMODE)
'		'Else
'    	'	Enable(IDM_EDIT_BLOCKCOMMENT)
'    	'	Enable(IDM_EDIT_BLOCKUNCOMMENT)
'    	'	Enable(IDM_EDIT_BLOCKINDENT)
'    	'	Enable(IDM_EDIT_BLOCKOUTDENT)
'    	'	Enable(IDM_EDIT_BLOCKMODE)
'		'EndIf
'
'		bm=SendMessage(ah.hred,EM_CANUNDO,0,0)
'		EnableDisable(bm,IDM_EDIT_UNDO)
'		bm=SendMessage(ah.hred,EM_CANREDO,0,0)
'		EnableDisable(bm,IDM_EDIT_REDO)
'		Enable(IDM_EDIT_EMPTYUNDO)
'		SendMessage(ah.hred,EM_EXGETSEL,0,Cast(Integer,@chrg))
'		bm=chrg.cpMax-chrg.cpMin
'		EnableDisable(bm,IDM_EDIT_CUT)
'		EnableDisable(bm,IDM_EDIT_COPY)
'		EnableDisable(bm,IDM_EDIT_DELETE)
'		If id=IDC_HEXED Then
'			bm=0
'		EndIf
'		EnableDisable(bm,IDM_EDIT_BLOCKTRIM)
'		EnableDisable(bm,IDM_EDIT_CONVERTTAB)
'		EnableDisable(bm,IDM_EDIT_CONVERTSPACE)
'		EnableDisable(bm,IDM_EDIT_CONVERTUPPER)
'		EnableDisable(bm,IDM_EDIT_CONVERTLOWER)
'		bm=SendMessage(ah.hred,EM_CANPASTE,CF_TEXT,0)
'		EnableDisable(bm,IDM_EDIT_PASTE)
'        Enable(IDM_EDIT_HISTORYPASTE)
'		Enable(IDM_EDIT_SELECTALL)
'		Enable(IDM_EDIT_BOOKMARKTOGGLE)
'		Enable(IDM_EDIT_BOOKMARKLIST)              ' MOD 22.2.2012   add
'		If id=IDC_HEXED Then
'			' Hex edit
'			Disable(IDM_EDIT_BLOCK_INSERT)
'			bm=SendMessage(ah.hred,HEM_ANYBOOKMARKS,0,0)
'			EnableDisable(bm,IDM_EDIT_BOOKMARKNEXT)
'			EnableDisable(bm,IDM_EDIT_BOOKMARKPREVIOUS)
'			EnableDisable(bm,IDM_EDIT_BOOKMARKDELETE)
'			Disable(IDM_EDIT_ERRORCLEAR)
'			Disable(IDM_EDIT_ERRORNEXT)
'			Disable(IDM_EDIT_EMPTYUNDO)
'		Else
'			bm=SendMessage(ah.hred,REM_GETMODE,0,0) And MODE_BLOCK
'			EnableDisable(bm,IDM_EDIT_BLOCK_INSERT)
'			bm=SendMessage(ah.hred,REM_NXTBOOKMARK,nLastLine,BMT_STD)+1
'			EnableDisable(bm,IDM_EDIT_BOOKMARKNEXT)
'			bm=SendMessage(ah.hred,REM_PRVBOOKMARK,nLastLine,BMT_STD)+1
'			EnableDisable(bm,IDM_EDIT_BOOKMARKPREVIOUS)
'			bm=SendMessage(ah.hred,REM_NXTBOOKMARK,-1,BMT_STD)+1
'			EnableDisable(bm,IDM_EDIT_BOOKMARKDELETE)
'			bm=SendMessage(ah.hred,REM_NEXTERROR,-1,0)+1
'			EnableDisable(bm,IDM_EDIT_ERRORCLEAR)
'			EnableDisable(bm,IDM_EDIT_ERRORNEXT)
'		EndIf
'		Disable(IDM_FORMAT_LOCK)
'		Disable(IDM_FORMAT_BACK)
'		Disable(IDM_FORMAT_FRONT)
'		Disable(IDM_FORMAT_GRID)
'		Disable(IDM_FORMAT_SNAP)
'		Disable(IDM_FORMAT_ALIGN)
'		Disable(IDM_FORMAT_SIZE)
'		Disable(IDM_FORMAT_CENTER)
'		Disable(IDM_FORMAT_TAB)
'		Disable(IDM_FORMAT_RENUM)
'
'		Disable(IDM_VIEW_DIALOG)
'		Enable(IDM_VIEW_SPLITSCREEN)
'		Enable(IDM_VIEW_FULLSCREEN)
'		Enable(IDM_VIEW_DUALPANE)
'
'		If id=IDC_CODEED Then
'    		Enable(IDM_PROJECT_INCLUDE)
'    		EnableContext(IDM_PROJECT_INCLUDE)
'		Else
'	   		Disable(IDM_PROJECT_INCLUDE)
'    		DisableContext(IDM_PROJECT_INCLUDE)
'		EndIf
'
'		Disable(IDM_RESOURCE_DIALOG)
'		Disable(IDM_RESOURCE_MENU)
'		Disable(IDM_RESOURCE_ACCEL)
'		Disable(IDM_RESOURCE_STRINGTABLE)
'		Disable(IDM_RESOURCE_VERSION)
'		Disable(IDM_RESOURCE_XPMANIFEST)
'		Disable(IDM_RESOURCE_RCDATA)
'		For id=22000 To 22032
'			Disable(id)
'		Next
'		Disable(IDM_RESOURCE_LANGUAGE)
'		Disable(IDM_RESOURCE_INCLUDE)
'		Disable(IDM_RESOURCE_RES)
'		Disable(IDM_RESOURCE_NAMES)
'		Disable(IDM_RESOURCE_EXPORT)
'		Disable(IDM_RESOURCE_REMOVE)
'		Disable(IDM_RESOURCE_UNDO)
'
'		If SendMessage(ah.hpr,PRM_GETCURSEL,0,0)=LB_ERR Then
'			DisableContext(IDM_PROPERTY_JUMP)
'    		DisableContext(IDM_PROPERTY_COPY_NAME)    ' MOD 23.1.2012
'	    	DisableContext(IDM_PROPERTY_COPY_SPEC)    ' MOD 23.1.2012 ADD
'		Else
'			EnableContext(IDM_PROPERTY_JUMP)
'    		EnableContext(IDM_PROPERTY_COPY_NAME)     ' MOD 23.1.2012
'	    	EnableContext(IDM_PROPERTY_COPY_SPEC)     ' MOD 23.1.2012 ADD
'		EndIf
'	EndIf
'	
'	If fProject Then
'		Enable(IDM_FILE_CLOSEPROJECT)
'		Enable(IDM_PROJECT_ADDNEWFILE)
'		Enable(IDM_PROJECT_ADDNEWMODULE)
'		Enable(IDM_PROJECT_ADDEXISTINGFILE)
'		Enable(IDM_PROJECT_ADDEXISTINGMODULE)
'		Enable(IDM_PROJECT_SETMAIN)
'		Enable(IDM_PROJECT_TOGGLE)
'		Enable(IDM_PROJECT_REMOVE)
'		Enable(IDM_PROJECT_RENAME)
'		Enable(IDM_PROJECT_OPTIONS)
'		Enable(IDM_PROJECT_CREATETEMPLATE)
'		EnableContext(IDM_FILE_CLOSEPROJECT)
'		EnableContext(IDM_PROJECT_ADDNEWFILE)
'		EnableContext(IDM_PROJECT_ADDNEWMODULE)
'		EnableContext(IDM_PROJECT_ADDEXISTINGFILE)
'		EnableContext(IDM_PROJECT_ADDEXISTINGMODULE)
'		EnableContext(IDM_PROJECT_SETMAIN)
'		EnableContext(IDM_PROJECT_TOGGLE)
'		EnableContext(IDM_PROJECT_REMOVE)
'		EnableContext(IDM_PROJECT_RENAME)
'		EnableContext(IDM_PROJECT_OPTIONS)
'		EnableContext(IDM_PROJECT_FILE_OPEN)
'		EnableContext(IDM_WINDOW_TAB2PROJECT)
'	    EnableContext(IDM_WINDOW_CLOSE_ALL_NONPROJECT)
'	Else
'		Disable(IDM_FILE_CLOSEPROJECT)
'		Disable(IDM_PROJECT_ADDNEWFILE)
'		Disable(IDM_PROJECT_ADDNEWMODULE)
'		Disable(IDM_PROJECT_ADDEXISTINGFILE)
'		Disable(IDM_PROJECT_ADDEXISTINGMODULE)
'		Disable(IDM_PROJECT_SETMAIN)
'		Disable(IDM_PROJECT_TOGGLE)
'		Disable(IDM_PROJECT_REMOVE)
'		Disable(IDM_PROJECT_RENAME)
'		Disable(IDM_PROJECT_OPTIONS)
'		Disable(IDM_PROJECT_CREATETEMPLATE)
'		DisableContext(IDM_FILE_CLOSEPROJECT)
'		DisableContext(IDM_PROJECT_ADDNEWFILE)
'		DisableContext(IDM_PROJECT_ADDNEWMODULE)
'		DisableContext(IDM_PROJECT_ADDEXISTINGFILE)
'		DisableContext(IDM_PROJECT_ADDEXISTINGMODULE)
'		DisableContext(IDM_PROJECT_SETMAIN)
'		DisableContext(IDM_PROJECT_TOGGLE)
'		DisableContext(IDM_PROJECT_REMOVE)
'		DisableContext(IDM_PROJECT_RENAME)
'		DisableContext(IDM_PROJECT_OPTIONS)
'		DisableContext(IDM_PROJECT_FILE_OPEN)
'		DisableContext(IDM_WINDOW_TAB2PROJECT)
'		DisableContext(IDM_WINDOW_CLOSE_ALL_NONPROJECT)
'	EndIf
'
'End Sub

Function IsResOpen() As HWND
	Dim tci As TCITEM
    Dim i As Integer = Any
    
	tci.mask=TCIF_PARAM
	i=0
	Do While TRUE
		If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(Integer,@tci)) Then
		    If GetWindowLong(pTABMEM->hedit,GWL_ID)=IDC_RESED Then
				Return pTABMEM->hedit
			EndIf
		Else
			Exit Do
		EndIf
		i=i+1
	Loop
	Return 0

End Function


'Sub NotImplemented()
'
'	MessageBox(ah.hwnd,"Not implemented",@szAppName,MB_OK)
'
'End Sub

'Function OpenInclude() As String
'	Dim chrg As CHARRANGE
'	Dim x As Integer
'	Dim sItem As ZString*260
'	Dim p As ZString Ptr
'
'	If ah.hred<>0 And ah.hred<>ah.hres Then
'		SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@chrg))
'		If SendMessage(ah.hred,REM_ISCHARPOS,chrg.cpMin,0)=3 Then       ' 3=IsString
'			x=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMax)
'			' MOD 21.1.2012
'			GetLineByNo ah.hred, x, @buff           
'			GetEnclosedStr 0, buff, buff, Cast (UByte, 34), Cast (UByte, 34)
'			'chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,x,0)
'			'buff=Chr(255) & Chr(1)
'			'x=SendMessage(ah.hred,EM_GETLINE,x,Cast(LPARAM,@buff))
'			'buff[x]=NULL
'			'x=chrg.cpMax-chrg.cpMin+1
'			'While x
'			'	If Asc(buff,x-1)=34 Then
'			'		Exit While
'			'	EndIf
'			'	x=x-1
'			'Wend
'			'buff=Mid(buff,x)
'			'x=InStr(buff,"""")
'			'buff=Left(buff,x-1)
'			' ==============================
'			If IsZStrNotEmpty (buff) Then
'				If fProject Then
'					sItem=ad.ProjectPath & "\"
'				Else
'					sItem=ad.filename
'					GetFilePath(sItem)
'					sItem=sItem & "\"
'				EndIf
'				If GetFileAttributes(sItem & buff)<>INVALID_FILE_ATTRIBUTES Then
'					buff=sItem & buff
'					GetFullPathName(@buff,260,@buff,@p)
'					Return buff
'				Else
'					If IsZStrNotEmpty (ad.fbcPath) Then
'						buff=ad.fbcPath & "\inc\" & buff
'					Else
'						buff=ad.AppPath & "\inc\" & buff
'					EndIf
'					If GetFileAttributes(buff)<>INVALID_FILE_ATTRIBUTES Then
'						GetFullPathName(@buff,260,@buff,@p)
'						Return buff
'					EndIf
'				EndIf
'			EndIf
'		EndIf
'	EndIf
'	Return ""
'
'End Function

Function GetTextItem(ByRef sText As String) As String
	Dim x As Integer
	Dim sItem As String

	x=InStr(sText,",")
	If x Then
		sItem=Left(sText,x-1)
		sText=Mid(sText,x+1)
	Else
		sItem=sText
		sText=""
	EndIf
	Return sItem

End Function

Function ConvToTwips (ByVal lSize As Integer) As Integer

	If ppage.inch Then
		'Inches
		Return (lSize*1440)\1000
	EndIf
	'millimeters
	Return (lSize*567)\1000

End Function

Sub PrintDoc ()
	Dim doci As DOCINFO
	Dim pX As Integer
	Dim pY As Integer
	Dim pML As Integer
	Dim pMT As Integer
	Dim pMR As Integer
	Dim pMB As Integer
	Dim chrg As CHARRANGE
	Dim rect As RECT
	Dim buffer As ZString*32
	Dim nLine As Integer
	Dim nPageno As Integer
	Dim nMLine As Integer
	Dim fmr As FORMATRANGE
	Dim hOldFont As HFONT

	pX=ConvToTwips(psd.ptPaperSize.x)
	pML=ConvToTwips(psd.rtMargin.left)
	pMR=ConvToTwips(psd.rtMargin.right)
	pY=ConvToTwips(psd.ptPaperSize.y)
	pMT=ConvToTwips(psd.rtMargin.top)
	pMB=ConvToTwips(psd.rtMargin.bottom)
	fmr.rcPage.left=0
	fmr.rc.left=pML
	fmr.rcPage.right=pX
	fmr.rc.right=pX-pMR
	fmr.rcPage.top=0
	fmr.rc.top=pMT
	fmr.rcPage.bottom=pY
	fmr.rc.bottom=pY-pMB
	fmr.hdc=GetDC(ah.hred)
	hOldFont=SelectObject(fmr.hdc,ah.rafnt.hFont)
	fmr.hdcTarget=pd.hDC
	doci.cbSize=SizeOf(doci)
	doci.lpszDocName=StrPtr("FbEdit")
	If pd.Flags And PD_PRINTTOFILE Then
		buffer="FILE:"
		doci.lpszOutput=@buffer
	Else
		doci.lpszOutput=NULL
	EndIf
	doci.lpszDatatype=NULL
	doci.fwType=NULL
	StartDoc(pd.hDC,@doci)
	If pd.Flags And PD_SELECTION Then
		SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@chrg))
		nLine=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMin)
		nPageno=nLine\ppage.pagelen
		nMLine=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,chrg.cpMax)
		pd.nToPage=9999
		fmr.chrg.cpMin=chrg.cpMin
		fmr.chrg.cpMax=chrg.cpMax
	Else
		nPageno=pd.nFromPage-1
		nLine=nPageno*ppage.pagelen
		nMLine=SendMessage(ah.hred,EM_GETLINECOUNT,0,0)
		fmr.chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,nLine,0)
		fmr.chrg.cpMax=-1
	EndIf
	While nLine<nMline And nPageno<pd.nToPage
		nPageno+=1
		StartPage(pd.hDC)
		fmr.chrg.cpMin=SendMessage(ah.hred,EM_FORMATRANGE,TRUE,Cast(LPARAM,@fmr))
		If EndPage(pd.hDC)<=0 Then
			Exit While
		EndIf
		nLine=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,fmr.chrg.cpMin)
	Wend
	EndDoc(pd.hDC)
	SelectObject(fmr.hdc,hOldFont)
	DeleteDC(pd.hDC)
	ReleaseDC(ah.hred,fmr.hdc)

End Sub



