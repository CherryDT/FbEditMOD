

#Include Once "windowsUR.bi"

Declare Function GenericOptDlgProc(ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer

' Generic Options Dialog
Type  GOD_EntryName As ZString * 32
Type  GOD_EntryData As ZString * MAX_PATH  

Const GOD_EntrySize As Integer = SizeOf (GOD_EntryName) + 1 + SizeOf (GOD_EntryData)      ' 1 Delimiter
Const GOD_MaxItems  As Integer = 50

Enum GenericOptionsDialogMode
    GODM_ToolsMenu         = 1
    GODM_HelpMenu
	GODM_MakeOptCollection 
	GODM_MakeOptProject
	GODM_MakeOptImport
	GODM_RegExLib
	GODM_MakeOptModule
End Enum	

#Define IDD_DLGOPTMNU						3200
#Define IDC_LSTME							3201
#Define IDC_EDTMEITEM						3207
#Define IDC_EDTMECMND						3208
#Define IDC_BTNMEU							3202
#Define IDC_BTNMED							3204
#Define IDC_BTNMEADD						3205
#Define IDC_BTNMEDEL						3206
#Define IDC_BTNMFILE						3203
#Define IDC_BTNIMPORT						3209
