

#Include Once "win\commdlg.bi"

Declare Function GlobalAllocUI (ByVal nType As UINT,ByVal nSize As DWORD) As HGLOBAL
Declare Function ShellExecuteUI (ByVal hWindow As HWND, ByVal pOperation As ZString Ptr, ByVal pFileSpec As ZString Ptr, ByVal pParameters As ZString Ptr, ByVal pWorkDir As ZString Ptr, ByVal ShowCmd As Integer) As BOOL
Declare Sub SearchRegEx (ByRef StartIdx As Integer, ByVal pSearchData As ZString Ptr, ByVal pSearchExpr As ZString Ptr, ByVal SubMatchNo As Integer, ByRef Found As String, ByRef pErrText As ZString Ptr)  	
Declare Function GetTextItem (ByRef sText As String) As String


Declare Sub EnableMenu ()
Declare Sub CheckMenu ()
Declare Sub HH_Help ()
Declare Sub PrintDoc ()


Type PRNPAGE
	Page		As Point
	margin	    As RECT
	pagelen	    As Integer
	inch		As Integer
End Type


Extern ppage As PRNPAGE
Extern psd   As PageSetupDlg
Extern pd    As PrintDlg

