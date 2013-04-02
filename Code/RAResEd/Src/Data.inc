include gdi32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib


PropertyList			PROTO	:HWND
ToolBoxReset			PROTO
PropListSetPos			PROTO

DrawingRect				PROTO	:DWORD,:DWORD,:DWORD
SetProjectItemName		PROTO	:DWORD,:DWORD
GetProjectItemName		PROTO	:DWORD,:DWORD
Do_TreeViewAddNode		PROTO	:HWND,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:LPARAM
MnuSaveAccel			PROTO	:DWORD,:DWORD
GetFreeProjectitemID	PROTO	:DWORD
GetUnikeName			PROTO	:DWORD
NameExists				PROTO	:DWORD,:DWORD
ShowEditDialog			PROTO	:HWND,:DWORD
GetWord					PROTO	:HWND,:DWORD
ParseRCMem				PROTO	:DWORD,:DWORD

m2m MACRO M1, M2
	push M2
	pop  M1
ENDM

IDB_TOOLBOX			equ	32100
IDB_MNUARROW		equ 32101
IDB_DLG				equ 32102
IDB_CUSTCTL			equ 32106
IDB_PROTRV			equ 32107
IDB_BOOKMARK		equ 32108
IDC_HSPLIT			equ 32109
IDC_VSPLIT			equ 32110

RT_MESSAGETABLE		equ 11
RT_MENUEX			equ 13
RT_DIALOGEX			equ 18
RT_LVIMAGE			equ 2110

DS_SHELLFONT		equ DS_SETFONT or DS_FIXEDSYS

SIZEBAR				equ 4

CCDEF struct
	ID				dd ?				;Controls uniqe ID
	lptooltip		dd ?				;Pointer to tooltip text
	hbmp			dd ?				;Handle of bitmap
	lpcaption		dd ?				;Pointer to default caption text
	lpname			dd ?				;Pointer to default id-name text
	lpclass			dd ?				;Pointer to class text
	style			dd ?				;Default style
	exstyle			dd ?				;Default ex-style
	flist1			dd ?				;Property listbox 1
	flist2			dd ?				;Property listbox 2
	disable			dd ?				;Disable controls child windows. 0=No, 1=Use method 1, 2=Use method 2
CCDEF ends

CCDEFEX struct
	ID				dd ?				;Controls uniqe ID
	lptooltip		dd ?				;Pointer to tooltip text
	hbmp			dd ?				;Handle of bitmap
	lpcaption		dd ?				;Pointer to default caption text
	lpname			dd ?				;Pointer to default id-name text
	lpclass			dd ?				;Pointer to class text
	style			dd ?				;Default style
	exstyle			dd ?				;Default ex-style
	flist1			dd ?				;Property listbox 1
	flist2			dd ?				;Property listbox 2
	flist3			dd ?				;Property listbox 3
	flist4			dd ?				;Property listbox 4
	lpproperty		dd ?
	lpmethod		dd ?
CCDEFEX ends

WS_EX_LAYERED	equ 80000h

RADLGHEAD struct
	ver				dd ?				;Set to 101
	changed			dd ?				;Set to FALSE
	class			db 32 dup(?)		;Set to Null string
	menuid			db 32 dup(?)		;Set to Null string
	font			db 32 dup(?)		;Set to "MS Sans Serif"
	fontsize		dd ?				;Set to 8
	fontht			dd ?				;Set to -10
	undo			dd ?				;Set to NULL
	ctlid			dd ?				;Set to 1001
	hmnu			dd ?				;Set to NULL
	htlb			dd ?				;Set to NULL
	hstb			dd ?				;Set to NULL
	locked			dd ?				;Set to TRUE or FALSE
	hfont			dd ?				;Set to NULL
	charset			db ?				;Set to NULL
	italic			db ?
	weight			dw ?
RADLGHEAD ends

RAMaxCap			equ 241

RADIALOG struct
	hwnd			dd ?				;Set to TRUE
	hdmy			dd ?				;Transparent dummy window
	oldproc			dd ?				;Set to NULL
	hpar			dd ?				;Set to NULL
	hcld			dd ?				;Set to NULL
	style			dd ?				;Set to desired style
	exstyle			dd ?				;Set to desired ex style
	x				dd ?				;X position in pixels
	y				dd ?				;Y position in pixels
	ccx				dd ?				;Width in pixels
	ccy				dd ?				;Height in pixels
	caption			db RAMaxCap dup(?)	;Caption max 240+1 char
	ntype			dd ?				;Follows ToolBox buttons Dialog=0, Edit=1, Static=2, GroupBox=3
	ntypeid			dd ?				;Set to NULL
	tab				dd ?				;Tab index, Dialog=0, First index=0
	id				dd ?				;Dialog / Controls ID
	idname			db 32 dup(?)		;ID Name, max 31 chars
	undo			dd ?				;Set to NULL
	himg			dd ?				;Set to NULL
RADIALOG ends

DESIGN struct
	hdlg			HWND ?
	fmode			dd ?
	ctlrect			RECT <?>
	parpt			POINT <?>
	dlgpt			POINT <?>
	mnurect			RECT <?>
	nmnu			dd ?
	hmnu			dd ?
	hselected		HWND ?
	fdblclk			dd ?
DESIGN ends

CCHCCCLASS			equ 32		; Max chars in a class name.
CCHCCDESC			equ 32		; Max chars in a control description.
CCHCCTEXT			equ 256		; Max chars in a text field.

;Custom controls
CCINFOA struct
    szClass				db CCHCCCLASS dup(?)	; Class name for the control.
    flOptions			DWORD ?					; Option flags (CCF_* defines).
    szDesc				db CCHCCDESC dup(?)		; Short, descriptive text for the ctrl.
    cxDefault			DWORD ?					; Default width (in dialog units).
    cyDefault			DWORD ?					; Default height (in dialog units).
    flStyleDefault		DWORD ?					; Default style (WS_CHILD | WS_VISIBLE).
    flExtStyleDefault	DWORD ?					; Default extended style.
    flCtrlTypeMask		DWORD ?					; Mask for control type styles.
    szTextDefault		db CCHCCTEXT dup(?)		; Default text.
    cStyleFlags			DWORD ?					; Entries in the following style table.
    aStyleFlags			DWORD ?					; Points to style flag table.
    lpfnStyle			DWORD ?					; Pointer to the Styles function.
    lpfnSizeToText		DWORD ?					; Pointer to the SizeToText function.
    dwReserved1			DWORD ?					; Reserved.  Must be zero.
    dwReserved2			DWORD ?					; Reserved.  Must be zero.
CCINFOA ends

CCSTYLEFLAGA struct
	flStyle				DWORD ?					; Style bits for this style.
	flStyleMask			DWORD ?					; Mask for the style.  Can be zero.
	pszStyle			DWORD ?					; Points to the style define string.
CCSTYLEFLAGA ends

.const

szProject			db '[PROJECT]',0
szToolTip			db 'Resource editor',0
szCap				db 0
szName				db 'IDC_RESED',0

STYLE				equ WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
EXSTYLE				equ 0

szToolTipsClass		db 'Tooltips_class32',0
szDlgChildClass		db 'RARESEDDIALOG',0
szStaticClass		db 'Static',0
szEditClass			db 'Edit',0
szButtonClass		db 'Button',0
szComboBoxClass		db 'ComboBox',0
szListBoxClass		db 'ListBox',0
szScrollBarClass	db 'ScrollBar',0
szTabControlClass	db 'SysTabControl32',0
szProgressBarClass	db 'msctls_progress32',0
szTreeViewClass		db 'SysTreeView32',0
szListViewClass		db 'SysListView32',0
szTrackBarClass		db 'msctls_trackbar32',0
szUpDownClass		db 'msctls_updown32',0
szToolBarClass		db 'ToolbarWindow32',0
szStatusBarClass	db 'msctls_statusbar32',0
szDateTimeClass		db 'SysDateTimePick32',0
szMonthViewClass	db 'SysMonthCal32',0
szRichEditClass		db 'RichEdit20A',0
szUserControlClass	db 'UDCCLASS',0
szComboBoxExClass	db 'ComboBoxEx32',0
szIPAddressClass	db 'SysIPAddress32',0
szAnimateClass		db 'SysAnimate32',0
szHotKeyClass		db 'msctls_hotkey32',0
szPagerClass		db 'SysPager',0
szReBarClass		db 'ReBarWindow32',0
szHeaderClass		db 'SysHeader32',0
szSysLinkClass		db 'SysLink',0

szComma				db ',',0
szOR				db '|',0
szNULL				db 0
szSPACE				db ' ',0
szAppName			db 'Resource editor',0
szMemFail			db 'Memory allocation failed!',0

szPRELOAD			db 'PRELOAD',0
szLOADONCALL		db 'LOADONCALL',0
szFIXED				db 'FIXED',0
szMOVEABLE			db 'MOVEABLE',0
szDISCARDABLE		db 'DISCARDABLE',0
szPURE				db 'PURE',0
szIMPURE			db 'IMPURE',0

szCHARACTERISTICS	db 'CHARACTERISTICS',0
szVERSION			db 'VERSION',0
szLANGUAGE			db 'LANGUAGE',0

szDIALOGEX			db 'DIALOGEX',0
szDIALOG			db 'DIALOG',0
szCONTROL			db 'CONTROL',0
szEDITTEXT			db 'EDITTEXT',0
szLTEXT				db 'LTEXT',0
szCTEXT				db 'CTEXT',0
szRTEXT				db 'RTEXT',0
szGROUPBOX			db 'GROUPBOX',0
szPUSHBUTTON		db 'PUSHBUTTON',0
szDEFPUSHBUTTON		db 'DEFPUSHBUTTON',0
szAUTOCHECKBOX		db 'AUTOCHECKBOX',0
szAUTORADIOBUTTON	db 'AUTORADIOBUTTON',0
szCOMBOBOX			db 'COMBOBOX',0
szLISTBOX			db 'LISTBOX',0
szSCROLLBAR			db 'SCROLLBAR',0
szBUTTON			db 'BUTTON',0

szCAPTION			db 'CAPTION',0
szCLASS				db 'CLASS',0
szSTYLE				db 'STYLE',0
szEXSTYLE			db 'EXSTYLE',0
szFONT				db 'FONT',0
szMENU				db 'MENU',0
szMENUEX			db 'MENUEX',0
szPOPUP				db 'POPUP',0
szMENUITEM			db 'MENUITEM',0
szCHECKED			db 'CHECKED',0
szGRAYED			db 'GRAYED',0
szINACTIVE			db 'INACTIVE',0
szHELP				db 'HELP',0
szMENUBARBREAK		db 'MENUBARBREAK',0
szMENUBREAK			db 'MENUBREAK',0
szSEPARATOR			db 'SEPARATOR',0
szMFT_SEPARATOR		db 'MFT_SEPARATOR',0
szBEGIN				db 'BEGIN',0
szEND				db 'END',0
szDEFINE			db '#define',0
szUNDEF				db '#undef',0
szIF				db '#if',0
szELIF				db '#elif',0
szELSE				db '#else',0
szENDIF				db '#endif',0
szIFDEF				db '#ifdef',0
szIFNDEF			db '#ifndef',0
szPRAGMA			db '#pragma',0
szINCLUDE			db '#include',0
szDESIGNINFO		db 'DESIGNINFO',0,0

szManifestInfo		db 'xml',0
					db 'encoding',0
					db 'standalone',0
					db 'assembly',0
					db 'xmlns',0
					db 'manifestVersion',0
					db 'assemblyIdentity',0
					db 'processorArchitecture',0
					db 'name',0
					db 'type',0
					db 'description',0
					db 'dependency',0
					db 'dependentAssembly',0
					db 'assemblyIdentity',0
					db 'publicKeyToken',0,0

szBEGINSHORT		db '{',0
szENDSHORT			db '}',0

szBS				db '\',0
szDots				db '...',0

szLSQ				db '[',0
szRSQ				db ']',0
szLPA				db '(',0
szRPA				db ')',0

szBITMAP			db 'BITMAP',0
szCURSOR			db 'CURSOR',0
szICON				db 'ICON',0
szAVI				db 'AVI',0
szRCDATA			db 'RCDATA',0
szUSERDATA			db 'USERDATA',0
szRT_RCDATA			db 'RT_RCDATA',0
szWAVE				db 'WAVE',0
szIMAGE				db 'IMAGE',0
szMANIFEST			db 'MANIFEST',0
szRT_MANIFEST		db 'RT_MANIFEST',0
szANICURSOR			db 'ANICURSOR',0
szMESSAGETABLE		db 'MESSAGETABLE',0

szACCELERATORS		db 'ACCELERATORS',0
szVIRTKEY			db 'VIRTKEY',0
szASCII				db 'ASCII',0
szNOINVERT			db 'NOINVERT',0
szSHIFT				db 'SHIFT',0
szALT				db 'ALT',0

szSTRINGTABLE		db 'STRINGTABLE',0
szTOOLBAR			db 'TOOLBAR',0
szVERSIONINFO		db 'VERSIONINFO',0
szFILEVERSION		db 'FILEVERSION',0
szFILEFLAGSMASK		db 'FILEFLAGSMASK',0
szFILEFLAGS			db 'FILEFLAGS',0
szPRODUCTVERSION	db 'PRODUCTVERSION',0
szFILEOS			db 'FILEOS',0
szFILETYPE			db 'FILETYPE',0
szFILESUBTYPE		db 'FILESUBTYPE',0
szBLOCK				db 'BLOCK',0
szVALUE				db 'VALUE',0
szNOT				db 'NOT',0
szTEXTINCLUDE		db 'TEXTINCLUDE',0,0
szManifestValue		db '24',0

szHdrType			db 'Type',0
szHdrName			db 'Name',0
szHdrID				db 'ID',0
szHdrFileName		db 'Filename',0
szHdrString			db 'String',0
szHdrKey			db 'Key',0
szHdrAscii			db 'Ascii',0
szHdrCtrl			db 'Ctrl',0
szHdrShift			db 'Shift',0
szHdrAlt			db 'Alt',0

szFilterManifest	db 'Manifest (*.xml)',0,'*.xml',0,0

szAclKeys			db 01h,'.Ascii',0
					db 30h,'0',0
					db 31h,'1',0
					db 32h,'2',0
					db 33h,'3',0
					db 34h,'4',0
					db 35h,'5',0
					db 36h,'6',0
					db 37h,'7',0
					db 38h,'8',0
					db 39h,'9',0
					db 41h,'A',0
					db 42h,'B',0
					db 43h,'C',0
					db 44h,'D',0
					db 45h,'E',0
					db 46h,'F',0
					db 47h,'G',0
					db 48h,'H',0
					db 49h,'I',0
					db 4Ah,'J',0
					db 4Bh,'K',0
					db 4Ch,'L',0
					db 4Dh,'M',0
					db 4Eh,'N',0
					db 4Fh,'O',0
					db 50h,'P',0
					db 51h,'Q',0
					db 52h,'R',0
					db 53h,'S',0
					db 54h,'T',0
					db 55h,'U',0
					db 56h,'V',0
					db 57h,'W',0
					db 58h,'X',0
					db 59h,'Y',0
					db 5Ah,'Z',0
					db 70h,'F1',0
					db 71h,'F2',0
					db 72h,'F3',0
					db 73h,'F4',0
					db 74h,'F5',0
					db 75h,'F6',0
					db 76h,'F7',0
					db 77h,'F8',0
					db 78h,'F9',0
					db 79h,'F10',0
					db 7Ah,'F11',0
					db 7Bh,'F12',0
					db 08h,'BACK',0
					db 09h,'TAB',0
					db 0Dh,'RETURN',0
					db 1Bh,'ESCAPE',0
					db 2Dh,'INSERT',0
					db 20h,'SPACE',0
					db 2Eh,'DELETE',0
					db 24h,'HOME',0
					db 23h,'END',0
					db 21h,'PGUP',0
					db 22h,'PGDN',0
					db 26h,'UP',0
					db 28h,'DOWN',0
					db 25h,'LEFT',0
					db 27h,'RIGHT',0
					db 60h,'NUMPAD0',0
					db 61h,'NUMPAD1',0
					db 62h,'NUMPAD2',0
					db 63h,'NUMPAD3',0
					db 64h,'NUMPAD4',0
					db 65h,'NUMPAD5',0
					db 66h,'NUMPAD6',0
					db 67h,'NUMPAD7',0
					db 68h,'NUMPAD8',0
					db 69h,'NUMPAD9',0
					db 0

szGetDef			db 'GetDef',0
szGetDefEx			db 'GetDefEx',0
szCourierNew		db 'Courier New',0

szIDOK				db 'IDOK',0
szIDCANCEL			db 'IDCANCEL',0
szIDABORT			db 'IDABORT',0
szIDRETRY			db 'IDRETRY',0
szIDIGNORE			db 'IDIGNORE',0
szIDYES				db 'IDYES',0
szIDNO				db 'IDNO',0
szIDCLOSE			db 'IDCLOSE',0
szIDHELP			db 'IDHELP',0
szIDC_STATIC		db 'IDC_STATIC',0,0
szIDC_STATICValue	db '-1',0

CombSort_Const		REAL4 1.3
szCustInfo			db 'CustomControlInfoA',0

.data

szCtlText			db 'Dialog,EditText,Static,GroupBox,Button,CheckBox,RadioButton,ComboBox,ListBox,HScroll,VScroll,TabStrip,ProgressBar,TreeView,ListView,TrackBar,UpDown,Image,ToolBar,StatusBar,DatePicker,'
					db 'MonthView,RichEdit,UserDefinedControl,ImageCombo,Shape,IPAddress,Animate,HotKey,HPager,VPager,ReBar,Header,SysLink',0
					db 512 dup(?)

szErrorParse		db 'Errors while parsing at line ',0
szLine				db 'Line: ',0
szNotSupported		db 'Internal data not supported by ResEd.',0Dh,0Ah,0Dh,0Ah,'Convert this kind of data to files?',0
szUnknownStyle		db 'Unknown style in ',0
szCustomType		db 0Dh,0Ah,0Dh,0Ah,'Custom resources not supported by ResEd.',0Dh,0Ah,'Convert to RCDATA?',0
szUnknownType		db 0Dh,0Ah,0Dh,0Ah,'Unknown resource. Not supported by ResEd.',0

szCrLf				db 0Dh,0Ah,0

ccdef				CCDEF <271,offset szToolTip,0,offset szCap,offset szName,offset szResEdClass,STYLE,EXSTYLE,11111101000111100000000000000000b,00010000000000011000000000000000b,2>

initid				INITID <<1000,100>,<10000,1000>,<1,1>,<1,1>,<1,1>,<1,1>,<1,1>,<100,1>,<100,1>>

rarstype			RARSTYPE <'BITMAP',0,'Bitmap (*.bmp)|*.bmp','mspaint.exe'>
					RARSTYPE <'CURSOR',0,'Cursor (*.cur)|*.cur'>
					RARSTYPE <'ICON',0,'Icon (*.ico)|*.ico'>
					RARSTYPE <'AVI',0,'Avi (*.avi)|*.avi'>
					RARSTYPE <'RCDATA',0,'All Files (*.*)|*.*'>
					RARSTYPE <'WAVE',0,'Wave (*.wav)|*.wav'>
					RARSTYPE <'IMAGE',0,'Image (*.jpg, *.gif)|*.jpg;*.gif','mspaint.exe'>
					RARSTYPE <'MANIFEST',24,'Manifest (*.xml)|*.xml','notepad.exe'>
					RARSTYPE <'ANICURSOR',0,'Ani Cursor (*.ani)|*.ani'>
					RARSTYPE <'FONT',0,'Font (*.fon, *.ttc, *.ttf)|*.fon;*.ttc;*.ttf'>
					RARSTYPE <'MESSAGETABLE',0,'Messagetable (*.bin)|*.bin'>
custrarstype		RARSTYPE 32 dup(<>)

;Grid
bmiMakeBitmap		BITMAPINFO <<SIZEOF BITMAPINFOHEADER,,,1,32,BI_RGB>,>
Gridcx				dd 3
Gridcy				dd 3
Gridc				dd 0

.data?

hInstance			dd ?
hRes				dd ?
hDEd				dd ?
hTlb				dd ?
hPrp				dd ?
hPrj				dd ?
hOut				dd ?
hMnuIml				dd ?
hPrjIml				dd ?
hBrTlt				dd ?
hTlt				dd ?
OldToolTipProc		dd ?
hInvisible			dd ?
hGridBr				dd ?
hStatus				dd ?
nStatus				dd ?
hExportOut			dd ?
fEditMode			dd ?
fNoScroll			dd ?
color				RESCOLOR <?>
hBrBack				dd ?
icex				INITCOMMONCONTROLSEX <?>
strHex				db 16 dup(?)
nUndo				dd ?
szProjectPath		db MAX_PATH dup(?)
szSystemPath		db MAX_PATH dup(?)
nPropWt				dd ?
nPropHt				dd ?
hPreview			dd ?
hTabSet				dd ?
nTabSet				dd ?
lfntht				dd ?
fResourceh			dd ?
szResourceh			db 128 dup(?)
fSize				dd ?
hVSplit				dd ?
hHSplit				dd ?
winsize				WINSIZE <?>
htout				dd ?
hredfont			dd ?
Casetab				db 256 dup(?)
namebuff			db 16384 dup(?)
fClose				dd ?
hDialog				dd ?
fDialogChanged		dd ?
hPrpCboDlg			dd ?
fMenuErr			dd ?
hDlgRed				dd ?
hMnuFont			dd ?
des					DESIGN <?>
hMemExported		HGLOBAL ?
