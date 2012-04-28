' Test comment

#Include Once "windows.bi"
#Include Once "win/commctrl.bi"
#Include Once "win/commdlg.bi"
#Include Once "win/richedit.bi"
#Include Once "win/shellapi.bi"
#Include Once "win/shlwapi.bi"
#Include Once "win/ole2.bi"

#Include "Inc/RAEdit.bi"
#Include "Inc/RAFile.bi"
#Include "Inc/RAProperty.bi"
#Include "Inc/RACodeComplete.bi"
#Include "Inc/RAResEd.bi"
#Include "Inc/RAHexEd.bi"
#Include "Inc/Addins.bi"
#Include "Inc/RAGrid.bi"

Declare Function IsResOpen() As HWND
Declare Function WantToSave(ByVal hWin As HWND) As Boolean
Declare Function OpenProject() As Integer
Declare Function CloseProject() As Integer
Declare Function IsProjectFile(ByVal sFile As String) As Integer
Declare Sub OpenProjectFile(ByVal nInx As Integer)
Declare Sub WriteProjectFileInfo(ByVal hWin As HWND,ByVal nInx As Integer,ByVal fProjectClose As Boolean)
Declare Sub OpenTheFile(ByVal sFile As String,ByVal fHex As Boolean)
Declare Sub TextToOutput(ByVal sText As String)
Declare Sub SaveToIni(ByVal lpszApp As ZString Ptr,ByVal lpszKey As ZString Ptr,ByVal lpszTypes As ZString Ptr,ByVal lpDta As Any Ptr,ByVal fProject As Boolean)
Declare Function LoadFromIni(ByVal lpszApp As ZString Ptr,ByVal lpszKey As ZString Ptr,ByVal szTypes As String,ByVal lpDta As Any Ptr,ByVal fProject As Boolean) As Boolean
Declare Function GetProjectFileID(ByVal hWin As HWND) As Integer
Declare Function CallAddins(ByVal hWin As HWND,ByVal uMsg As UINT,wParam As WPARAM,lParam As LPARAM,ByVal hook1 As UINT) As Integer
Declare Function GetProjectFile(ByVal nInx As Integer) As String
Declare Function Compile(ByVal sMake As String) As Integer
Declare Sub ShowOutput(ByVal bShow As Boolean)
Declare Sub ShowImmediate(ByVal bShow As Boolean)
Declare Sub UpdateAllTabs(ByVal nType As Integer)
Declare Function OpenInclude() As String
Declare Function GetFileImg(ByVal sFile As String) As Integer
Declare Function GetProjectResource() As String
Declare Function MakeProjectFileName(ByVal sFile As String) As String
Declare Function IsFileOpen(ByVal hWin As HWND,ByVal fn As String,ByVal fShow As Boolean) As HWND
Declare Function GetTextItem(ByRef sText As String) As String
Declare Sub SelectTab(ByVal hWin As HWND,ByVal hEdit As HWND,ByVal nInx As Integer)
Declare Function FindString(ByVal hMem As HGLOBAL,ByVal szApp As String,ByVal szKey As String) As String
Declare Sub TranslateDialog(ByVal hWin As HWND,ByVal id As Integer)
Declare Function GetInternalString(ByVal id As Integer) As String
Declare Sub TranslateAddinDialog(ByVal hWin As HWND,ByVal sID As String)
Declare Sub SelectProjectFile(ByVal sFile As String)
Declare Sub HH_Help()

' Main dialog
#Define IDD_MAIN 								1000
#Define IDC_RAEDIT							1001
#Define IDC_TOOLBAR							1002
#Define IDC_STATUSBAR						1003
#Define IDC_TABSELECT						1004
#Define IDC_DIVIDER							1005
#Define IDC_DIVIDER2							1015
#Define IDC_TAB								1011
#Define IDC_FILEBROWSER						1006
#Define IDC_TRVPRJ							1012
#Define IDC_OUTPUT							1007
#Define IDC_IMMEDIATE						1018
#Define IDC_PROPERTY							1008
#Define IDC_RACCTT							1009
#Define IDC_RACCLB							1010
#Define IDC_SHP								1014
#Define IDC_CBOBUILD							1016
#Define IDC_IMGSPLASH						1017
#Define IDC_REGISTER							1019
#Define IDC_FPU								1020
#Define IDC_MMX								1021
#Define IDC_TABDEBUG							1022

' Menu and toolbar
#Define IDR_MENU								10000
#Define IDM_FILE								10001
#Define IDM_FILE_NEWPROJECT				10002
#Define IDM_FILE_OPENPROJECT				10003
#Define IDM_FILE_CLOSEPROJECT				10004
#Define IDM_FILE_NEW							10005
#Define IDM_FILE_NEW_RESOURCE				10006
#Define IDM_FILE_OPEN						10007
#Define IDM_FILE_OPEN_HEX					10060
#Define IDM_FILE_RECENTFILE				10008
#Define IDM_FILE_SAVE						10009
#Define IDM_FILE_SAVEALL					10010
#Define IDM_FILE_SAVEAS						10011
#Define IDM_FILE_CLOSE						10012
#Define IDM_FILE_CLOSEALL					10013
#Define IDM_FILE_PAGESETUP					10015
#Define IDM_FILE_PRINT						10016
#Define IDM_FILE_EXIT						10014

#Define IDM_EDIT								10021
#Define IDM_EDIT_UNDO						10022
#Define IDM_EDIT_REDO						10023
#Define IDM_EDIT_EMPTYUNDO					10087
#Define IDM_EDIT_CUT							10024
#Define IDM_EDIT_COPY						10025
#Define IDM_EDIT_PASTE						10026
#Define IDM_EDIT_DELETE						10027
#Define IDM_EDIT_SELECTALL					10028
#Define IDM_EDIT_GOTO						10029
#Define IDM_EDIT_FIND						10030
#Define IDM_EDIT_FINDNEXT					10031
#Define IDM_EDIT_FINDPREVIOUS				10032
#Define IDM_EDIT_REPLACE					10033
#Define IDM_EDIT_FINDDECLARE				10034
#Define IDM_EDIT_RETURN						10035
#define IDM_EDIT_EXPAND         			10036
#Define IDM_EDIT_BLOCK						10037
#Define IDM_EDIT_BLOCKINDENT				10038
#Define IDM_EDIT_BLOCKOUTDENT				10039
#Define IDM_EDIT_BLOCKCOMMENT				10040
#Define IDM_EDIT_BLOCKUNCOMMENT			10041
#Define IDM_EDIT_BLOCKTRIM					10042
#Define IDM_EDIT_CONVERT					10043
#Define IDM_EDIT_CONVERTTAB				10044
#Define IDM_EDIT_CONVERTSPACE				10045
#Define IDM_EDIT_CONVERTUPPER				10046
#Define IDM_EDIT_CONVERTLOWER				10047
#Define IDM_EDIT_BLOCKMODE					10048
#Define IDM_EDIT_BLOCK_INSERT				10049
#Define IDM_EDIT_BOOKMARK					10050
#Define IDM_EDIT_BOOKMARKTOGGLE			10051
#Define IDM_EDIT_BOOKMARKNEXT				10052
#Define IDM_EDIT_BOOKMARKPREVIOUS		10053
#Define IDM_EDIT_BOOKMARKDELETE			10054
#Define IDM_EDIT_ERROR						10055
#Define IDM_EDIT_ERRORNEXT					10056
#Define IDM_EDIT_ERRORCLEAR				10057

#Define IDM_FORMAT							10061
#Define IDM_FORMAT_LOCK						10062
#Define IDM_FORMAT_BACK						10063
#Define IDM_FORMAT_FRONT					10064
#Define IDM_FORMAT_GRID						10065
#Define IDM_FORMAT_SNAP						10066
#Define IDM_FORMAT_ALIGN					10067
#Define IDM_FORMAT_ALIGN_LEFT				10068
#Define IDM_FORMAT_ALIGN_CENTER			10069
#Define IDM_FORMAT_ALIGN_RIGHT			10070
#Define IDM_FORMAT_ALIGN_TOP				10071
#Define IDM_FORMAT_ALIGN_MIDDLE			10072
#Define IDM_FORMAT_ALIGN_BOTTOM			10073
#Define IDM_FORMAT_SIZE						10074
#Define IDM_FORMAT_SIZE_WIDTH				10075
#Define IDM_FORMAT_SIZE_HEIGHT			10076
#Define IDM_FORMAT_SIZE_BOTH				10077
#Define IDM_FORMAT_CENTER					10078
#Define IDM_FORMAT_CENTER_HOR				10079
#Define IDM_FORMAT_CENTER_VER				10080
#Define IDM_FORMAT_TAB						10081
#Define IDM_FORMAT_RENUM					10082
#Define IDM_FORMAT_CASECONVERT			10083
#Define IDM_FORMAT_INDENT					10084

#Define IDM_VIEW								10091
#Define IDM_VIEW_OUTPUT						10092
#Define IDM_VIEW_IMMEDIATE					10085
#Define IDM_VIEW_PROJECT					10093
#Define IDM_VIEW_PROPERTY					10094
#Define IDM_VIEW_TOOLBAR					10020
#Define IDM_VIEW_TABSELECT					10058
#Define IDM_VIEW_STATUSBAR					10059
#Define IDM_VIEW_DIALOG						10095
#Define IDM_VIEW_SPLITSCREEN				10096
#Define IDM_VIEW_FULLSCREEN				10097
#Define IDM_VIEW_DUALPANE					10098

#Define IDM_PROJECT							10101
#Define IDM_PROJECT_ADDNEW					10102
#Define IDM_PROJECT_ADDNEWFILE			10103
#Define IDM_PROJECT_ADDNEWMODULE			10104
#Define IDM_PROJECT_ADDEXISTING			10105
#Define IDM_PROJECT_ADDEXISTINGFILE		10106
#Define IDM_PROJECT_ADDEXISTINGMODULE	10107
#Define IDM_PROJECT_SETMAIN				10018
#Define IDM_PROJECT_TOGGLE					10019
#Define IDM_PROJECT_REMOVE					10108
#Define IDM_PROJECT_RENAME					10109
#Define IDM_PROJECT_INCLUDE				10086
#Define IDM_PROJECT_OPTIONS				10110
#Define IDM_PROJECT_CREATETEMPLATE		10111

#Define IDM_RESOURCE							10121
#Define IDM_RESOURCE_DIALOG				10122
#Define IDM_RESOURCE_MENU					10123
#Define IDM_RESOURCE_ACCEL					10124
#Define IDM_RESOURCE_STRINGTABLE			10125
#Define IDM_RESOURCE_VERSION				10126
#Define IDM_RESOURCE_XPMANIFEST			10127
#Define IDM_RESOURCE_RCDATA				10128
#Define IDM_RESOURCE_LANGUAGE				10129
#Define IDM_RESOURCE_INCLUDE				10130
#Define IDM_RESOURCE_RES					10131
#Define IDM_RESOURCE_NAMES					10132
#Define IDM_RESOURCE_EXPORT				10133
#Define IDM_RESOURCE_REMOVE				10134
#Define IDM_RESOURCE_UNDO					10135

#Define IDM_MAKE								10141
#Define IDM_MAKE_COMPILE					10142
#Define IDM_MAKE_RUN							10143
#Define IDM_MAKE_GO							10144
#Define IDM_MAKE_RUNDEBUG					10145
#Define IDM_MAKE_MODULE						10146
#Define IDM_MAKE_QUICKRUN					10147

#Define IDM_TOOLS								10151
#Define IDM_TOOLS_EXPORT					10152

#Define IDM_OPTIONS							10161
#Define IDM_OPTIONS_LANGUAGE				10017
#Define IDM_OPTIONS_CODE					10162
#Define IDM_OPTIONS_DIALOG					10163
#Define IDM_OPTIONS_PATH					10164
#Define IDM_OPTIONS_DEBUG					10165
#Define IDM_OPTIONS_MAKE					10166
#Define IDM_OPTIONS_EXTERNALFILES		10167
#Define IDM_OPTIONS_ADDINS					10168
#Define IDM_OPTIONS_TOOLS					10169
#Define IDM_OPTIONS_HELP					10170

#Define IDM_HELP								10181
#Define IDM_HELP_ABOUT						10182

' Context menu
#Define IDM_WINDOW_LOCK						10201
#Define IDM_WINDOW_UNLOCKALL				10202
#Define IDM_WINDOW_ALL_BUT_CURRENT		10203
#Define IDM_WINDOW_NEXTTAB					10204
#Define IDM_WINDOW_PREVIOUSTAB			10205
#Define IDM_WINDOW_SPLITT					10206
#Define IDM_WINDOW_SWITCHTAB				10207

#Define IDM_OUTPUT_CLEAR					10211
#Define IDM_OUTPUT_SELECTALL				10212
#Define IDM_OUTPUT_COPY						10213

#define IDM_IMMEDIATE_CLEAR 10226
#define IDM_IMMEDIATE_SELECTALL 10227
#define IDM_IMMEDIATE_COPY 10228

#Define IDM_PROPERTY_JUMP					10221
#Define IDM_PROPERTY_COPY					10222
#Define IDM_PROPERTY_FINDALL				10229
#define IDM_PROPERTY_HILIGHT 				10223
#define IDM_PROPERTY_HILIGHT_UPDATE 	10224
#define IDM_PROPERTY_HILIGHT_RESET 		10225

#Define IDM_HELPF1							10231
#Define IDM_HELPCTRLF1						10232

#Define IDR_CONTEXTMENU						20000

#Define IDC_HSPLIT							100
#Define IDC_VSPLIT							101
#Define IDC_MAINICON							100
#Define IDB_MNUARROW							200

' Accelerator table
#Define IDA_ACCEL								1
#Define IDB_FILES								102

Type EDITFONT
	size				As Integer
	charset			As Integer
	szFont			As ZString Ptr
	weight			As Integer
	italics			As Integer
End Type

Type EDITOPTION
	tabsize			As Integer
	expand			As Integer
	hiliteline		As Integer
	autoindent		As Integer
	hilitecmnt		As Integer
	linenumbers		As Integer
	backup			As Integer
	bracematch		As Integer
	AutoBrace		As Integer
	autocase			As Integer
	autoblock		As Integer
	autoformat		As Integer
	codecomplete	As Integer
	autosave			As Integer
	autoload			As Integer
	autowidth		As Integer
	autoinclude		As Integer
	closeonlocks	As Integer
	tooltip			As Integer
	smartmath		As Integer
End Type

'#define TTN_NEEDTEXTA			-520
'included in freebasic 0.17 cvs
#Ifndef TVN_BEGINLABELEDITA
#Define TVN_BEGINLABELEDITA	TVN_FIRST-10
#Define TVN_ENDLABELEDITA		TVN_FIRST-11
#EndIf

Type NAMEEXPORT
	nType				As Integer
	nOutput			As Integer
	fAuto				As Integer
	szFileName		As ZString Ptr
End Type

Type GRIDSIZE
	x					As Integer
	y					As Integer
	show				As Integer
	snap				As Integer
	tips				As Integer
	Color				As Integer
	Line				As Integer
	stylehex			As Integer
	sizetofont		As Integer
	nodefines		As Integer
	simple			As Integer
	defstatic		As Integer
End Type

Type PFI
	nGroup			As Integer
	nPos				As Integer
	nLoad				As Integer
	nColl(15)		As Integer
End Type

Declare Sub ReadProjectFileInfo(ByVal nInx As Integer,ByVal lpPFI As PFI Ptr)
Declare Sub SetProjectFileInfo(ByVal hWin As HWND,ByVal lpPFI As PFI Ptr)

#Define VIEW_OUTPUT		1
#Define VIEW_PROJECT		2
#Define VIEW_PROPERTY	4
#Define VIEW_TOOLBAR		8
#Define VIEW_TABSELECT	16
#Define VIEW_STATUSBAR	32
#Define VIEW_IMMEDIATE	64
#Define MAX_MISS			10
#Define HT_DEBUG			224

Const szNULL=!"\0"
Const CRLF=Chr(13) & Chr(10)
Const CR=Chr(13)

Const szAppName=!"FreeBASIC editor\0"
Const szVersion=!"FreeBASIC editor 1.0.7.7\0"
Const szReg=!"REG"
Const szFpu=!"FPU"
Const szMmx=!"MMX"

Dim Shared hInstance As HINSTANCE

' Custom controls used by FbEdit
Dim hRichEditDll As HMODULE
Dim hFbEditDll As HMODULE

' Addins
Dim Shared ah As ADDINHANDLES
Dim Shared ad As ADDINDATA=(1077)
Dim Shared af As ADDINFUNCTIONS=(@TextToOutput,@SaveToIni,@LoadFromIni,@OpenTheFile,@Compile,@ShowOutput,@TranslateAddinDialog,@FindString,@CallAddins,@ShowImmediate,@MakeProjectFileName,@HH_Help,@IsProjectFile)
ad.lpszVersion=@szVersion

' Custom controls
Dim Shared hCustDll(32) As HMODULE

' Resources
Dim Shared hDlgFnt As HFONT
Dim Shared hIcon As HICON
Dim Shared hVCur As HCURSOR
Dim Shared hHCur As HCURSOR

' Subclass
Dim Shared lpOldTabToolProc As Any Ptr
Dim Shared lpOldProjectProc As Any Ptr
Dim Shared lpOldCCProc As Any Ptr
Dim Shared lpOldSplashProc As Any Ptr

' Misc
Dim Shared nLastLine As Integer
Dim Shared nLastSize As Integer
Dim Shared nLastCp As Integer
Dim Shared nLasthWin As HWND
Dim Shared nCaretPos As Integer
Dim Shared buff As ZString*20*1024
Dim Shared s As ZString*20*1024
Dim Shared CommandLine As ZString Ptr
Dim Shared ApiFiles As ZString*260
Dim Shared DefApiFiles As ZString*260

' Project
Dim Shared fProject As Boolean
Dim Shared ProjectDescription As ZString*260
Dim Shared ProjectApiFiles As ZString*260
Dim Shared ProjectDeleteFiles As ZString*260
Dim Shared nMain As Integer
Dim Shared fRecompile As Integer
Dim Shared fNoResMode As Boolean
Dim Shared nProjectGroup As Integer
Dim Shared fAddMainFiles As Boolean
Dim Shared fCompileIfNewer As Boolean
Dim Shared fAddModuleFiles As Boolean
Dim Shared fIncVersion As Boolean
Dim Shared fRunCmd As Boolean

' Code complete
Dim Shared ftypelist As Boolean
Dim Shared fconstlist As Boolean
Dim Shared fstructlist As Boolean
Dim Shared fmessagelist As Boolean
Dim Shared flocallist As Boolean
Dim Shared fincludelist As Boolean
Dim Shared fincliblist As Boolean
Dim Shared fenumlist As Boolean
Dim Shared sEditFileName As ZString*260
Dim Shared ccpos As ZString Ptr
Dim Shared ccstring As ZString*65536
Dim Shared sCodeFiles As ZString*260

' Hilite words
Const C0=""
Const C1=""
Const C2=""
Const C3=""
Const C4=""
Const C5=""
Const C6=""
Const C7=""
Const C8=""
Const C9=""
Const C10=""
Const C11=""
Const C12=""
Const C13=""
Const C14=""
Const C15=""
Const C16=""
Const C17=""
Const C18=""
Const C19=""
Const C20=""
Const C21=""
Dim Shared sKeyWords(21) As String

' Colors
Dim Shared fbcol As FBCOLOR=((DEFBCKCOLOR,DEFTXTCOLOR,DEFSELBCKCOLOR,DEFSELTXTCOLOR,DEFCMNTCOLOR,DEFSTRCOLOR,DEFOPRCOLOR,DEFHILITE1,DEFHILITE2,DEFHILITE3,DEFSELBARCOLOR,DEFSELBARPEN,DEFLNRCOLOR,DEFNUMCOLOR,DEFCMNTBCK,DEFSTRBCK,DEFNUMBCK,DEFOPRBCK,DEFCHANGEDCLR,DEFCHANGESAVEDCLR),DEFBCKCOLOR,DEFTXTCOLOR,DEFBCKCOLOR,DEFTXTCOLOR)
Dim Shared kwcol As KWCOLOR=(RGB(0,0,128),RGB(0,0,128),RGB(0,0,128),RGB(64,64,0),RGB(128,0,0),RGB(0,0,128),RGB(0,0,128),RGB(0,0,128),RGB(0,0,128),&H1000000+RGB(0,0,128),&H4000000+RGB(0,0,128),RGB(0,0,128),RGB(0,0,128),RGB(0,0,128),RGB(0,0,128),RGB(0,0,128),&H1000000+RGB(0,255,255),&H1000000+RGB(0,255,255),&H1000000+RGB(0,255,255))
Dim Shared custcol As KWCOLOR
Dim Shared thme(15) As THEME
Dim Shared szTheme(15) As ZString*32

Const szColon=":"

' Format string for wsprintf
Const fmt="Line: %d Pos: %d"

' Filter string for GetOpenFileName
Const ALLFilterString="Code Files (*.bas, *.bi, *.rc)" & szNULL & "*.bas;*.bi;*.rc" & szNULL & "Text Files (*.txt)" & szNULL & "*.txt" & szNULL & "All Files (*.*)" & szNULL & "*.*" & szNULL & szNULL
Const MODFilterString="Code File (*.bas)" & szNULL & "*.bas" & szNULL & szNULL
Const DLLFilterString="Custom controls (*.dll)" & szNULL & "*.dll" & szNULL & szNULL
Const PRJFilterString="FreeBASIC Projects (*.fbp)" & szNULL & "*.fbp" & szNULL & szNULL
Const EXEFilterString="Commands (*.com, *.exe, *.cmd)" & szNULL & "*.com;*.exe;*.cmd" & szNULL & "All Files (*.*)" & szNULL & "*.*" & szNULL & szNULL
Const HLPFilterString="Help (*.hlp, *.chm)" & szNULL & "*.hlp;*.chm" & szNULL & "All Files (*.*)" & szNULL & "*.*" & szNULL & szNULL
Const TPLFilterString="Template (*.tpl)" & szNULL & "*.tpl" & szNULL & szNULL

' Bracket matching
Const szBracketMatch="({[,)}],_"

' Code blocks
Dim Shared blk As RABLOCKDEF
Dim Shared szSt(40) As ZString*32
Dim Shared szEn(40) As ZString*32
Dim Shared szNot1 As ZString*32
Dim Shared szNot2 As ZString*32
Dim Shared BD(40) As RABLOCKDEF

' Autoformat
Type AUTOFORMAT
	wrd	As ZString Ptr
	st		As Integer
	add1	As Integer
	add2	As Integer
End Type

Dim Shared autofmt(40) As AUTOFORMAT
Dim Shared szIndent(40) As ZString*32

Const sf1 = !"Courier New\0                    "
Const sf2 = !"Terminal\0                       "
Const sf3 = !"Tahoma\0                         "
Dim Shared edtfnt As EDITFONT=(-12,0,@sf1,400,0)
Dim Shared lnrfnt As EDITFONT=(-6,0,@sf2,400,0)
Dim Shared toolfnt As EDITFONT=(-11,0,@sf3,400,0)
Dim Shared edtopt As EDITOPTION=(3,0,0,1,0,0,3,1,1,1,1,1,1,0,0,0,1,1,1,0)
Const sn = !"rsrc.bi\0                        "
Dim Shared nmeexp As NAMEEXPORT=(1,2,0,@sn)
Dim Shared grdsize As GRIDSIZE=(3,3,TRUE,TRUE,TRUE,0,FALSE,TRUE,FALSE,FALSE,FALSE,TRUE)

' Code properties
Const szCode = "Functions"
Const szConst = "Constants"
Const szData = "Variables"
Const szStruct = "UDTs"
Const szEnum = "Enums"
Const szNamespace = "Namespaces"
Const szMacro = "Macros"
Const szConstructor = "Constructors"
Const szDestructor = "Destructors"
Const szProperty = "Properties"
Const szOperator = "Operators"
Dim Shared defgen As DEFGEN = ("/'" & szNULL,"'/" & szNULL,"'" & szNULL,"""" & szNULL,"_" & szNULL)
Dim Shared deftypesub As DEFTYPE = (TYPE_NAMESECOND,DEFTYPE_PROC,Asc("p"),3,"sub")
Dim Shared deftypeendsub As DEFTYPE = (TYPE_TWOWORDS,DEFTYPE_ENDPROC,Asc("p"),3,"end" & Chr(3) & "sub")
Dim Shared deftypefun As DEFTYPE = (TYPE_NAMESECOND,DEFTYPE_FUNCTION,Asc("p"),8,"function")
Dim Shared deftypeendfun As DEFTYPE = (TYPE_TWOWORDS,DEFTYPE_ENDFUNCTION,Asc("p"),3,"end" & Chr(8) & "function")
Dim Shared deftypedata As DEFTYPE = (TYPE_NAMESECOND,DEFTYPE_DATA,Asc("d"),3,"dim")
Dim Shared deftypecommon As DEFTYPE = (TYPE_NAMESECOND,DEFTYPE_DATA,Asc("d"),6,"common")
Dim Shared deftypestatic As DEFTYPE = (TYPE_NAMESECOND,DEFTYPE_DATA,Asc("d"),6,"static")
Dim Shared deftypevar As DEFTYPE = (TYPE_NAMESECOND,DEFTYPE_DATA,Asc("d"),3,"var")
Dim Shared deftypeconst As DEFTYPE = (TYPE_NAMESECOND,DEFTYPE_CONST,Asc("c"),7,"#define")
Dim Shared deftypeconst2 As DEFTYPE = (TYPE_NAMESECOND,DEFTYPE_CONST,Asc("c"),5,"const")
Dim Shared deftypestruct As DEFTYPE = (TYPE_OPTNAMESECOND,DEFTYPE_STRUCT,Asc("s"),4,"type")
Dim Shared deftypeendstruct As DEFTYPE = (TYPE_TWOWORDS,DEFTYPE_ENDSTRUCT,Asc("s"),3,"end" & Chr(4) & "type")
Dim Shared deftypeunion As DEFTYPE = (TYPE_OPTNAMESECOND,DEFTYPE_STRUCT,Asc("s"),5,"union")
Dim Shared deftypeendunion As DEFTYPE = (TYPE_TWOWORDS,DEFTYPE_ENDSTRUCT,Asc("s"),3,"end" & Chr(5) & "union")
Dim Shared deftypeenum As DEFTYPE = (TYPE_NAMESECOND,DEFTYPE_ENUM,Asc("e"),4,"enum")
Dim Shared deftypeendenum As DEFTYPE = (TYPE_TWOWORDS,DEFTYPE_ENDENUM,Asc("e"),3,"end" & Chr(4) & "enum")
Dim Shared deftypenamespace As DEFTYPE = (TYPE_NAMESECOND,DEFTYPE_NAMESPACE,Asc("n"),9,"namespace")
Dim Shared deftypeendnamespace As DEFTYPE = (TYPE_TWOWORDS,DEFTYPE_ENDNAMESPACE,Asc("n"),3,"end" & Chr(9) & "namespace")
Dim Shared deftypewithblock As DEFTYPE = (TYPE_NAMESECOND,DEFTYPE_WITHBLOCK,Asc("w"),4,"with")
Dim Shared deftypeendwithblock As DEFTYPE = (TYPE_TWOWORDS,DEFTYPE_ENDWITHBLOCK,Asc("w"),3,"end" & Chr(4) & "with")
Dim Shared deftypemacro As DEFTYPE = (TYPE_NAMESECOND,DEFTYPE_MACRO,Asc("m"),6,"#macro")
Dim Shared deftypeendmacro As DEFTYPE = (TYPE_ONEWORD,DEFTYPE_ENDMACRO,Asc("m"),9,"#endmacro")
Dim Shared deftypeconstructor As DEFTYPE = (TYPE_NAMESECOND,DEFTYPE_CONSTRUCTOR,Asc("x"),11,"constructor")
Dim Shared deftypeendconstructor As DEFTYPE = (TYPE_TWOWORDS,DEFTYPE_ENDCONSTRUCTOR,Asc("x"),3,"end" & Chr(11) & "constructor")
Dim Shared deftypedestructor As DEFTYPE = (TYPE_NAMESECOND,DEFTYPE_DESTRUCTOR,Asc("y"),10,"destructor")
Dim Shared deftypeenddestructor As DEFTYPE = (TYPE_TWOWORDS,DEFTYPE_ENDDESTRUCTOR,Asc("y"),3,"end" & Chr(10) & "destructor")
Dim Shared deftypeproperty As DEFTYPE = (TYPE_NAMESECOND,DEFTYPE_PROPERTY,Asc("z"),8,"property")
Dim Shared deftypeendproperty As DEFTYPE = (TYPE_TWOWORDS,DEFTYPE_ENDPROPERTY,Asc("z"),3,"end" & Chr(8) & "property")
Dim Shared deftypeoperator As DEFTYPE = (TYPE_OPTNAMESECOND,DEFTYPE_OPERATOR,Asc("o"),8,"operator")
Dim Shared deftypeendoperator As DEFTYPE = (TYPE_TWOWORDS,DEFTYPE_ENDOPERATOR,Asc("o"),3,"end" & Chr(8) & "operator")
Dim Shared deftypeignore As DEFTYPE = (TYPE_OPTNAMESECOND,DEFTYPE_IGNORE,Asc("i"),3,"asm")
Dim Shared deftypeendignore As DEFTYPE = (TYPE_TWOWORDS,DEFTYPE_ENDIGNORE,Asc("i"),3,"end" & Chr(3) & "asm")

' HTML help
Type HH_AKLINK
	cbStruct			As Integer
	fReserved		As Boolean
	pszKeywords		As ZString Ptr
	pszUrl			As ZString Ptr
	pszMsgText		As ZString Ptr
	pszMsgTitle		As ZString Ptr
	pszWindow		As ZString Ptr
	fIndexOnFail	As Boolean
End Type

#Define HH_DISPLAY_TOPIC	&H0000
#Define HH_KEYWORD_LOOKUP  &H000D

Dim Shared hHtmlOcx As HINSTANCE
Dim Shared pHtmlHelpProc As Any Ptr
Dim Shared hHHwin As HWND
Dim Shared hhaklink As HH_AKLINK

Const szResClassName="RESEDCLASS"
Const szFullScreenClassName="FULLSCREENCLASS"
Dim Shared fTimer As Integer
Dim Shared fChangeNotification As Integer
Dim Shared fParse As Integer
Dim Shared nSize As Integer
Dim Shared fBuildErr As Integer
Dim Shared nHideOut As Integer
Dim Shared fInUse As Boolean

' Find declare
Type FINDDECLARE
	npos		As Integer
	hwnd		As HWND
End Type

Dim Shared fdc(31) As FINDDECLARE
Dim Shared fdcpos As Integer

' Modeless dialogs
Dim Shared findvisible As HWND
Dim Shared gotovisible As HWND

' MRU projects
Dim Shared MruProject(3) As ZString*260

' MRU files
Dim Shared MruFile(8) As ZString*260

' FIND history
Dim Shared FindHistory(8) As ZString*260

' Template
Const szBPRO = "[*BEGINPRO*]"
Const szEPRO = "[*ENDPRO*]"
Const szBDEF = "[*BEGINDEF*]"
Const szEDEF = "[*ENDDEF*]"
Const szBTXT = "[*BEGINTXT*]"
Const szETXT = "[*ENDTXT*]"
Const szBBIN = "[*BEGINBIN*]"
Const szEBIN = "[*ENDBIN*]"
Const szNAME = "[*PRONAME*]"

' Addins
Type ADDIN
	hdll As HMODULE
	lpdllfunc As Any Ptr
	hooks As ADDINHOOKS
End Type

Type PRNPAGE
	Page		As Point
	margin	As RECT
	pagelen	As Integer
	inch		As Integer
End Type

Dim Shared addins(31) As ADDIN
Dim Shared mnuid As Integer=21000
Dim Shared curtab As Integer=-1
Dim Shared prevtab As Integer=-1
Dim Shared szCaseConvert As ZString*32
Dim Shared fQR As Boolean
Dim Shared nSplash As Integer=10
Dim Shared hSplashBmp As HBITMAP
Dim Shared wpos As WINPOS=(0,10,10,780,580,VIEW_PROJECT Or VIEW_PROPERTY Or VIEW_TOOLBAR Or VIEW_TABSELECT Or VIEW_STATUSBAR,(0,0),120,160,(10,10),(10,10),0,(150,150),(10,10))
Dim Shared ppage As PRNPAGE=((21000,29700),(1000,1000,1000,1000),66,0)
Dim Shared psd As PageSetupDlg
Dim Shared pd As PrintDlg
Dim Shared szApi As ZString*260
Dim Shared novr As Integer
Dim Shared nsel As Integer
Dim Shared Language As ZString*260
Dim Shared ttpos As Integer

Const szMsg1 = "SendMessage"
Const szMsg2 = "PostMessage"
Const szMsg3 = "SendDlgItemMessage"

Dim Shared ttmsg As MESSAGE

Type FIND
	fdir					As Integer						' 0=All,1=Up,2=Down
	fsearch				As Integer						' 0=Procedure,1=Module,2=Open Files,3=Project,4=Selected text
	fpro					As Integer
	ffileno				As Integer
	chrginit				As CHARRANGE					' Position at startup
	chrgrange			As CHARRANGE					' Range to search
	fr						As Integer						' Find flags
	ft						As FINDTEXTEX
	findbuff				As ZString*260
	replacebuff			As ZString*260
	nreplacecount		As Integer
	fskipcommentline	As Integer
	flogfind				As Integer
	fonlyonetime		As Integer
	fnoproc				As Boolean						' Flag to handle no procedure
	fnoreset				As Boolean						' Flag to handle opening a new file
	listoffiles			As String
	nlinesout			As Integer
	fres					As Integer						' Find result
End Type

Dim Shared f As FIND
Dim Shared fsave As FIND

Type LASTPOS
	hwnd		As HWND
	chrg		As CHARRANGE
	nline		As Integer
	fchanged	As Integer
	fnohandling	As Integer
End Type

Dim Shared lstpos As LASTPOS
Dim Shared szQuickRun As ZString*MAX_PATH
Dim Shared fUnicode As Integer
Dim Shared szLastDir As ZString*MAX_PATH
