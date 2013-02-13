
;Messages to MasmEd's main window
AIM_GETHANDLES					equ WM_USER+50			;Returns a poiner to a struct containing all useful handles. See ADDINHANDLES structure below.
AIM_GETPROCS					equ WM_USER+51			;Returns a poiner to a struct containing some procs in MasmEd. See ADDINPROCS structure below.
AIM_GETDATA						equ WM_USER+52			;Returns a poiner to a struct comtaining data pointers. See ADDINDATA structure below.
AIM_GETMENUID					equ WM_USER+53			;Returns a free menu id. If you need more than one, wParam contains the number of id's to reserve.

;Messages sendt to addins
AIM_ADDINSLOADED				equ WM_USER+100			;This message is sendt to the addins after all addins are loaded. hWin=Main window, wParam=0, lParam=0
AIM_COMMAND						equ WM_USER+101			;This message is sendt to the addins when user makes a menu selection or clicks a toolbar button. hWin=Main window, wParam and lParam as for WM_COMMAND
AIM_CLOSE						equ WM_USER+102			;MasmEd requests closing. Return TRUE to prevent MasmEd from closing. hWin=Main window, wParam and lParam as for WM_CLOSE
AIM_DESTROY						equ WM_USER+103			;MasmEd is about to be destroyed. Now is the time to free memory and resources that your addin allocated. Always return FALSE. hWin=Main window, wParam and lParam as for WM_DESTROY
AIM_MENUUPDATE					equ WM_USER+104			;MasmEd has updated menues. Now is the time to add menu items. Always return FALSE. hWin=Main window, wParam=hMnu, lParam=hContextMnu. NOTE: This command can be sendt more than once. Do not allocate MenuID's here
AIM_NEWFILE						equ WM_USER+105			;A new file is about to be created. Return TRUE to prevent MasmEd from creating the file. hWin=Main window, wParam=IDC_RAE or IDC_RES, lParam=lpFileName
AIM_FILEOPEN					equ WM_USER+106			;A file is about to be opened. Return TRUE to prevent MasmEd from opening the file. hWin=Main window, wParam=IDC_RAE, IDC_RES, IDC_HEX, IDC_EXECUTE, IDC_USER or IDC_MES, lParam=lpFileName
AIM_FILEOPENED					equ WM_USER+107			;A file has ben opened.. Always return FALSE. hWin=Main window, wParam=IDC_RAE, IDC_RES, IDC_HEX, IDC_EXECUTE or IDC_MES, lParam=lpFileName
AIM_FILECLOSE					equ WM_USER+108			;A file is about to be closed.. Return TRUE to prevent MasmEd from closing the file. hWin=Editor window, wParam=IDC_RAE, IDC_RES, IDC_HEX or IDC_USER, lParam=lpFileName
AIM_FILECLOSED					equ WM_USER+109			;A file has been closed.. Always return FALSE. hWin=Editor window, wParam=IDC_RAE, IDC_RES or IDC_HEX, lParam=lpFileName
AIM_FILESAVE					equ WM_USER+110			;A file is about to be saved. Return TRUE to prevent MasmEd from saving the file. hWin=Editor window, wParam=IDC_RAE, IDC_RES, IDC_HEX or IDC_USER, lParam=lpFileName
AIM_FILESAVEAS					equ WM_USER+111			;A file is about to be saved with a new name. Return TRUE to prevent MasmEd from saving the file. hWin=Editor window, wParam=IDC_RAE, IDC_RES, IDC_HEX or IDC_USER, lParam=lpFileName
AIM_FILESAVEED					equ WM_USER+112			;A file has been saved. Always return FALSE. hWin=Editor window, wParam=IDC_RAE, IDC_RES, IDC_HEX or IDC_USER, lParam=lpFileName
AIM_GETMODIFY					equ WM_USER+113			;MasmEd requests if a file is changed. Return TRUE if it is your file and it has changed. hWin=Editor window, wParam=IDC_USER, lParam=lpFileName
AIM_MAKEBEGIN					equ WM_USER+114			;MasmEd starts a make process. Return TRUE to prevent MasmEd from running the make process. hWin=Main window, wParam=IDM_MAKE_COMPILE, IDM_MAKE_ASSEMBLE, IDM_MAKE_LINK, IDM_MAKE_BUILD, IDM_MAKE_RUN or IDM_MAKE_GO, lParam=Main file
AIM_MAKEDONE					equ WM_USER+115			;MasmEd finished the make process. Always return FALSE. hWin=Main window, wParam=IDM_MAKE_COMPILE, IDM_MAKE_ASSEMBLE, IDM_MAKE_LINK, IDM_MAKE_BUILD, IDM_MAKE_RUN or IDM_MAKE_GO, lParam=Main file

;HOOK flags returned in hook1 of HOOK structure
HOOK_ADDINSLOADED				equ 0001h
HOOK_COMMAND					equ 0002h
HOOK_CLOSE						equ 0004h
HOOK_DESTROY					equ 0008h
HOOK_MENUUPDATE					equ 0010h
HOOK_NEWFILE					equ 0020h
HOOK_FILEOPEN					equ 0040h
HOOK_FILEOPENED					equ 0080h
HOOK_FILECLOSE					equ 0100h
HOOK_FILECLOSED					equ 0200h
HOOK_FILESAVE					equ 0400h
HOOK_FILESAVEAS					equ 0800h
HOOK_FILESAVEED					equ 1000h
HOOK_GETMODIFY					equ 2000h
HOOK_MAKEBEGIN					equ 4000h
HOOK_MAKEDONE					equ 8000h

HOOK struct
	hook1						DWORD ?					;Combinations of HOOK_ flags
	hook2						DWORD ?					;Not used must be zero
	hook3						DWORD ?					;Not used must be zero
	hook4						DWORD ?					;Not used must be zero
HOOK ends

ADDINHANDLES struct
	hWnd						HWND ?					;Handle of main window.
	hClient						HWND ?					;Handle to window shown if no files are open.
	hREd						HWND ?					;Handle to current selected editor.
	hTab						HWND ?					;Handle to tab select tool.
	hBtn						HWND ?					;Handle to close button.
	hFind						HWND ?					;Handle to Find / Replace dialog.
	hTbr						HWND ?					;Handle to toolbar.
	hShp						HWND ?					;Handle to box surrounding toolbar.
	hStc						HWND ?					;Container for Make type combobox
	hCbo						HWND ?					;Handle to Make type combobox.
	hCCLB						HWND ?					;Handle to code complete listbox.
	hCCTT						HWND ?					;Handle to code tooltip.
	hRes						HWND ?					;Handle to resource editor container.
	hResEd						HWND ?					;Handle to resource editor work area.
	hOut						HWND ?					;Handle to output window (RAEdit)
	hImmOut						HWND ?					;Handle to immediate window (RAEdit)
	hTabOut						HWND ?					;Handle to tab selectin output or immediate.
	hBrowse						HWND ?					;Handle to file browser.
	hProperty					HWND ?					;Handle to code property.
	hSbr						HWND ?					;Handle to status bar.
	hDbgReg						HWND ?					;Handle to debug register window (RAEdit).
	hDbgWatch					HWND ?					;Handle to debug watch window (RAEdit).
	hTabDbg						HWND ?					;Handle to tab selecting register or watch window.
	hDbgTip						HWND ?					;Handle to debug tooltip.
	hInstance					HINSTANCE ?				;MasmEd's instance.
	hAccel						HACCEL ?				;Handle to accelerator table.
	hMnu						HMENU ?					;Handle to MasmEd's menu.
	hContextMnu					HMENU ?					;Handle to MasmEd's context menu.
	hVSplitCur					HCURSOR ?				;Handle to cursor.
	hHSplitCur					HCURSOR ?				;Handle to cursor.
	hFont						HFONT ?					;RAEdit font.
	hIFont						HFONT ?					;RAEdit italics font.
	hLnrFont					HFONT ?					;RAEdit line number font.
	hImlTbr						HIMAGELIST ?			;Handle to toolbar imagelist.
	hImlTbrGray					HIMAGELIST ?			;Handle to toolbar grayed imagelist.
	hMnuIml						HIMAGELIST ?			;Handle to menu imagelist.
	hBrBack						HBRUSH ?				;Handle to background brush.
	hMenuBrushA					HBRUSH ?				;Handle to menu background brush.
	hMenuBrushB					HBRUSH ?				;Handle to menu background brush.
	hMnuFont					HFONT ?					;Handle to menu font.
	hReg						HKEY ?					;Handle to MasmEd's registry key.
	hDbgFpu						HWND ?					;Handle to debug FPU window (RAEdit).
	hDbgMMX						HWND ?					;Handle to debug MMX window (RAEdit).
	hTabPbr						HWND ?					;Handle to File / Project tab
	hPbr						HWND ?					;Handle to project browser
ADDINHANDLES ends

MAKEOPT struct
	szType						BYTE 32 dup(?)			;Build type
	szCompileRC					BYTE 128 dup(?)			;Compile resource command
	szAssemble					BYTE 128 dup(?)			;Assemble command
	szLink						BYTE 128 dup(?)			;Link command
	OutpuType					DWORD ?					;Output filetype
MAKEOPT ends

ADDINDATA struct
	AppPath						BYTE MAX_PATH dup(?)	;Path to where MasmEd.exe was started.
	FileName					BYTE MAX_PATH dup(?)	;Filename of current selected file.
	MainFile					BYTE MAX_PATH dup(?)	;Filename of main file, if any.
	DbgFileName					BYTE MAX_PATH dup(?)	;Fileneme of debugged file, if any.
	findbuff					BYTE 256 dup(?)			;Find text.
	replacebuff					BYTE 256 dup(?)			;Replace text.
	szInitFolder				BYTE MAX_PATH dup(?)	;Initial folder.
	szSessionFile				BYTE MAX_PATH dup(?)	;Current session file, if any.
	PathBin						BYTE MAX_PATH dup(?)	;Path to assembler, linker and resource compiler.
	PathInc						BYTE MAX_PATH dup(?)	;Path to include files.
	PathLib						BYTE MAX_PATH dup(?)	;Path to libraries.
	makeopt						MAKEOPT 16 dup(<>)		;Make options
	nBuildOpt					DWORD ?					;Current make option
	ver							DWORD ?					;MasmEd version
	lpCharTab					DWORD ?					;Pointer to RAEdit character table
	lpszVersion					DWORD ?					;Pointer to version string
	fProject					DWORD ?					;TRUE if there is a project
ADDINDATA ends

ADDINPROCS struct
	lpOpenEditFile				DWORD ?					;Opens a file. lpFileName:DWORD,fType:DWORD
	lpOutputSelect				DWORD ?					;Selects Output or Immediate. nSel:DWORD (0 or 1)
	lpOutputShow				DWORD ?					;Shows or hides the selected output. fShow:DWORD (TRUE or FALSE)
	lpOutputString				DWORD ?					;Outputs a string to selected output. lpString:DWORD
	lpOutputClear				DWORD ?					;Clears the selected output.
	lpTabToolAdd				DWORD ?					;Adds a new tab. hWin:HWND,lpFileName:DWORD
	lpTabToolActivate			DWORD ?					;Activates the current tab.
	lpTabToolGetMem				DWORD ?					;Gets a pointer to TABMEM. hWin:DWORD
	lpUpdateFileTime			DWORD ?					;Updates the filetime. lpTABMEM:DWORD
	lpTabToolSetChanged			DWORD ?					;Sets the tabs changed state. hWin:DWORD,fChanged:DWORD (TRUE or FALSE)
	lpUpdateFileName			DWORD ?					;Changes the filename for current selected tab. hWin:DWORD,lpFileName:DWORD
	lpWriteSessionFile			DWORD ?					;Saves session file. lpFileName:DWORD
ADDINPROCS ends

;#########################################################################

TABMEM struct
	hwnd						HWND ?					;Handle of the editor window.
	pid							DWORD ?					;Project id
	filename					BYTE MAX_PATH dup (?)	;Filename including full path.
	ft							FILETIME <?>			;Filetime for last write.
	nchange						DWORD ?
	fchanged					DWORD ?
	fupdate						DWORD ?
	fnonotify					DWORD ?
TABMEM ends

;Edit window ID's
IDC_RAE							equ 1011				;Text editor
IDC_RES							equ 1012				;Resource editor
IDC_HEX							equ 1013				;Hex editor
IDC_EXECUTE						equ 1014				;File can be executed. (.com, .bat or .exe)
IDC_USER						equ 1015				;User defined editor
IDC_MES							equ 1016				;Session file

;MasmEd menu ID's
IDM_MENU						equ 10000
IDM_HELPF1						equ 500
IDM_FILE						equ 11000
IDM_FILE_NEW					equ 10001
IDM_FILE_NEW_RES				equ 10007
IDM_FILE_OPEN					equ 10002
IDM_FILE_OPEN_HEX				equ 10022
IDM_FILE_SAVE					equ 10003
IDM_FILE_SAVEAS					equ 10004
IDM_FILE_SAVEALL				equ 10011
IDM_FILE_CLOSE					equ 10010
IDM_FILE_CLOSE_ALL				equ 10058
IDM_FILE_PAGESETUP				equ 10029
IDM_FILE_PRINT					equ 10005
IDM_FILE_RECENTFILES			equ 10094
IDM_FILE_RECENTSESSIONS			equ 10095
IDM_FILE_EXIT					equ 10006

IDM_EDIT						equ 11001
IDM_EDIT_UNDO					equ 10101
IDM_EDIT_REDO					equ 10102
IDM_EDIT_DELETE					equ 10103
IDM_EDIT_CUT					equ 10104
IDM_EDIT_COPY					equ 10105
IDM_EDIT_PASTE					equ 10106
IDM_EDIT_SELECTALL				equ 10107
IDM_EDIT_FIND					equ 10108
IDM_EDIT_FINDNEXT				equ 10110
IDM_EDIT_FINDPREV				equ 10111
IDM_EDIT_REPLACE				equ 10109
IDM_EDIT_GOTO					equ 10091
IDM_EDIT_RETURN					equ 10092
IDM_EDIT_INDENT					equ 10037
IDM_EDIT_OUTDENT				equ 10038
IDM_EDIT_COMMENT				equ 10035
IDM_EDIT_UNCOMMENT				equ 10036
IDM_EDIT_BLOCKCONVERT			equ 10096
IDM_EDIT_BLOCKUPPER				equ 10097
IDM_EDIT_BLOCKLOWER				equ 10098
IDM_EDIT_BLOCKTABTOSPC			equ 10099
IDM_EDIT_BLOCKSPCTOTAB			equ 10100
IDM_EDIT_BLOCKSPCTRIM			equ 10112
IDM_EDIT_BLOCKMODE				equ 10061
IDM_EDIT_BLOCKINSERT			equ 10062
IDM_EDIT_TOGGLEBM				equ 10018
IDM_EDIT_NEXTBM					equ 10019
IDM_EDIT_PREVBM					equ 10020
IDM_EDIT_CLEARBM				equ 10021
IDM_EDIT_CLEARERRORS			equ 10074
IDM_EDIT_NEXTERROR				equ 10075

IDM_FORMAT						equ 11002
IDM_FORMAT_LOCK					equ 10012
IDM_FORMAT_BACK					equ 10013
IDM_FORMAT_FRONT				equ 10014
IDM_FORMAT_GRID					equ 10015
IDM_FORMAT_SNAP					equ 10016
IDM_FORMAT_ALIGN				equ 10017
IDM_FORMAT_ALIGN_LEFT			equ 10034
IDM_FORMAT_ALIGN_CENTER			equ 10042
IDM_FORMAT_ALIGN_RIGHT			equ 10043
IDM_FORMAT_ALIGN_TOP			equ 10044
IDM_FORMAT_ALIGN_MIDDLE			equ 10045
IDM_FORMAT_ALIGN_BOTTOM			equ 10046
IDM_FORMAT_SIZE					equ 10033
IDM_FORMAT_SIZE_WIDTH			equ 10039
IDM_FORMAT_SIZE_HEIGHT			equ 10040
IDM_FORMAT_SIZE_BOTH			equ 10041
IDM_FORMAT_CENTER				equ 10066
IDM_FORMAT_CENTER_HOR			equ 10067
IDM_FORMAT_CENTER_VERT			equ 10068
IDM_FORMAT_TABINDEX				equ 10069

IDM_VIEW						equ 11003
IDM_VIEW_TOOLBAR				equ 10008
IDM_VIEW_STATUSBAR				equ 10009
IDM_VIEW_OUTPUT					equ 10023
IDM_VIEW_DIALOG					equ 10065
IDM_VIEW_FILEBROWSER			equ 10059
IDM_VIEW_NEXTTAB				equ 10116
IDM_VIEW_PREVIOUSTAB			equ 10117

IDM_RESOURCE					equ 11004
IDM_RESOURCE_DIALOG				equ 10048
IDM_RESOURCE_MENU				equ 10049
IDM_RESOURCE_ACCEL				equ 10050
IDM_RESOURCE_VERINF				equ 10051
IDM_RESOURCE_MANIFEST			equ 10071
IDM_RESOURCE_RCDATA				equ 10072
IDM_RESOURCE_TOOLBAR			equ 10073
IDM_RESOURCE_LANGUAGE			equ 10064
IDM_RESOURCE_INCLUDE			equ 10052
IDM_RESOURCE_RESOURCE			equ 10053
IDM_RESOURCE_STRING				equ 10054
IDM_RESOURCE_NAME				equ 10055
IDM_RESOURCE_EXPORT				equ 10063
IDM_RESOURCE_REMOVE				equ 10056
IDM_RESOURCE_UNDO				equ 10057

IDM_MAKE						equ 11005
IDM_MAKE_COMPILE				equ 10024
IDM_MAKE_ASSEMBLE				equ 10025
IDM_MAKE_LINK					equ 10026
IDM_MAKE_BUILD					equ 10090
IDM_MAKE_RUN					equ 10027
IDM_MAKE_GO						equ 10028
IDM_DEBUG						equ 10113
IDM_DEBUG_TOGGLE				equ 10082
IDM_DEBUG_CLEAR					equ 10083
IDM_DEBUG_RUN					equ 10081
IDM_DEBUG_BREAK					equ 10089
IDM_DEBUG_STOP					equ 10084
IDM_DEBUG_INTO					equ 10085
IDM_DEBUG_OVER					equ 10086
IDM_DEBUG_CARET					equ 10087
IDM_DEBUG_NODEBUG				equ 10088
IDM_MAKE_MAINFILE				equ 10079

IDM_TOOLS						equ 11005

IDM_OPTION						equ 11006
IDM_OPTION_CODE					equ 10030
IDM_OPTION_DIALOG				equ 10047
IDM_OPTION_PATH					equ 10080
IDM_OPTION_BUILD				equ 10070
IDM_OPTION_ADDINS				equ 10093
IDM_OPTION_TOOLS				equ 10031
IDM_OPTION_HELP					equ 10032
IDM_OPTION_EXTERNAL				equ 10076

IDM_HELP						equ 11007
IDM_HELP_ABOUT					equ 10201

IDR_MENUCONTEXT					equ 21000
IDM_TABTOOL						equ 21001
IDM_FILE_CLOSE_ALL_BUT			equ 21002
IDM_OUTPUT_CLEAR				equ 21004
IDM_IMMEDIATE_CLEAR				equ 21013
IDM_BROWSER_OPEN				equ 21006
IDM_BROWSER_COPY				equ 21007
IDM_PROPERTY_GOTODECLARE		equ 21010
IDM_PROPERTY_COPYTOCODE			equ 21011
IDM_PROPERTY_COPYPROTO			equ 21014
IDM_PROJECT						equ 21015
IDM_PROJECT_CREATE				equ 21022
IDM_PROJECT_OPEN				equ 10114
IDM_PROJECT_CLOSE				equ 10115
IDM_PROJECT_ADDITEM				equ 21023
IDM_PROJECT_ADDGROUP			equ 21016
IDM_PROJECT_ADDFILE				equ 21019
IDM_PROJECT_ADDALLFILES			equ 21020
IDM_PROJECT_ADDEXISTINGFILE		equ 21027
IDM_PROJECT_ADDNEWFILE			equ 21028
IDM_PROJECT_REMOVEITEM			equ 21024
IDM_PROJECT_REMOVEGROUP			equ 21017
IDM_PROJECT_REMOVEFILE			equ 21021
IDM_PROJECT_EDITITEM			equ 21025
IDM_PROJECT_EDITGROUP			equ 21018
IDM_PROJECT_EDITFILE			equ 21026
