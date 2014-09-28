
#Include Once "windows.bi"
#Include Once "Inc\RAEdit.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\TabTool.bi"


Enum EditorType
    ET_ResEd   = 1
    ET_CodeEd
    ET_HexEd
    ET_TextEd
    ET_CoTxEd
    ET_AlphaEd
End Enum


Declare Sub FormatIndent (ByVal hWin As HWND)
Declare Function AddIndent (ByVal n As Integer,ByVal lpszIndent As ZString Ptr) As String
Declare Function SetIndent (ByVal hWin As HWND,ByVal ln As Integer,ByVal lpszIndent As ZString Ptr) As Integer
Declare Function GetIndent (ByVal hWin As HWND,ByVal ln As Integer,ByVal lpszBlockSt As ZString Ptr,ByVal lpErr As Integer Ptr) As String
Declare Sub CaseConvert (ByVal hWin As HWND)
Declare Sub CaseConvertWordFromList (ByVal hWin As HWND,ByVal cp As Integer,ByVal hMem As HGLOBAL,ByVal nCount As Integer)
Declare Sub CaseConvertWord (ByVal hWin As HWND,ByVal cp As Integer)
Declare Sub AutoBrace (ByVal hWin As HWND, ByVal nChr As Integer)
Declare Function AutoFormatLine (ByVal hWin As HWND, ByVal lpchrg As CHARRANGE Ptr) As Integer
Declare Sub TrimTrailingSpaces ()
Declare Sub IndentComment (Byref char As zString,ByVal fUn As Boolean)
Declare Sub BlockModeToggle (ByVal hEditor As HWND = ah.hred)

Declare Sub GetLineByNo (ByVal hWin As HWND, ByVal LineNo As Integer, Byval pBuff As ZString Ptr)
Declare Sub GetLineUpToCaret (ByVal hWin As HWND, ByRef pBuff As ZString Ptr, ByRef LineNo As Integer)
Declare Sub GetLineByCaret (ByVal hWin As HWND, ByRef pBuff As ZString Ptr, ByRef LineNo As Integer)     ' MOD 21.1.2012   Function GetLineBySel(ByVal hWin As HWND,ByRef lpszBuff As ZString Ptr) As Integer
Declare Sub GetStringLiteralByCaret (ByVal hWin As HWND, ByRef pBuff As ZString Ptr, ByRef LineNo As Integer)

Declare Function EditorHasFocus () As BOOL
Declare Sub SetEditorTypeInfo (ByVal hWin As HWND)

Declare Function CreateCodeEd (Byref sFile As zString) As HWND
Declare Function CreateTxtEd (Byref sFile As zString) As HWND

Declare Function CoTxEdProc (ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
Declare Function ParCoTxEdProc (ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
Declare Function CCProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer

Type LASTPOS
	hwnd		As HWND
	chrg		As CHARRANGE
	nline		As Integer
	fchanged	As Integer
	fnohandling	As Integer
End Type

Type AUTOFORMAT
	wrd	        As ZString Ptr
	st	      	As Integer
	add1      	As Integer
	add2      	As Integer
End Type

Type EditorTypeInfo
    ResEd       As BOOL
    CodeEd      As BOOL
    HexEd       As BOOL
    TextEd      As BOOL
    CoTxEd      As BOOL       ' CodeEd OR TextEd
    AlphaEd     As BOOL       ' CodeEd Or TextEd Or HexEd
End Type

#Define MAXBLOCKDEFS 50

Extern lpOldCoTxEdProc        As WNDPROC
Extern lpOldParCoTxEdProc     As WNDPROC
Extern lpOldCCProc            As WNDPROC

Extern lstpos                 As LASTPOS
Extern szCaseConvert          As ZString * 32
Extern szIndent(MAXBLOCKDEFS) As ZString * 32
Extern autofmt(MAXBLOCKDEFS)  As AUTOFORMAT

' Code blocks
Extern blk                    As RABLOCKDEF
Extern szSt(MAXBLOCKDEFS)     As ZString * 32
Extern szEn(MAXBLOCKDEFS)     As ZString * 32
Extern szNot1                 As ZString * 32
Extern szNot2                 As ZString * 32
Extern BD(MAXBLOCKDEFS)       As RABLOCKDEF

Extern EditInfo               As EditorTypeInfo



