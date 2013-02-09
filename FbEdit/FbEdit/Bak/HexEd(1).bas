

#Include Once "windowsUR.bi"

#Include Once "Inc\RAHexEd.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\EditorOpt.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\Statusbar.bi"
#Include Once "Inc\TabTool.bi"

#Include Once "Inc\HexEd.bi"
#Include Once "showvarsUR.bi"


Dim Shared lpOldHexEdProc    As WNDPROC


Function CreateHexEd (Byref sFile As zString) As HWND

	Dim hTmp    As HWND         = Any 
    Dim i       As Integer      = Any 
	Dim buffer  As ZString * 64
	
	Const Style As DWORD        = WS_CHILD Or WS_VISIBLE Or WS_CLIPCHILDREN Or WS_CLIPSIBLINGS

	hTmp = CreateWindowEx (WS_EX_CLIENTEDGE, @"RAHEXEDIT", NULL, Style, 0, 0, 0, 0, ah.hwnd, Cast (HMENU, IDC_HEXED), hInstance, 0)
    
    If hTmp Then
        SetWindowLong hTmp, GWL_ID, IDC_HEXED           ' MOD 10.2.2012  add
    	UpdateEditOptions hTmp

    	SendMessage hTmp, WM_SETTEXT , 0, Cast (LPARAM, @"")
    	SendMessage hTmp, EM_SETMODIFY, FALSE, 0

    	' Set tooltips
    	For i = 1 To 6
    		buffer = GetInternalString (IS_RAEDIT_BASE + i)
    		SendMessage hTmp, REM_SETTOOLTIP, i, Cast (LPARAM, @buffer)
    	Next

    	lpOldHexEdProc = Cast (WNDPROC, SendMessage (hTmp, HEM_SUBCLASS, 0, Cast (LPARAM, @HexEdProc)))

       	If edtopt.linenumbers Then
    		SendDlgItemMessage hTmp, -2, BM_CLICK, 0, 0
    	EndIf
    EndIf
	Return hTmp

End Function

Function HexEdProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer

	Select Case uMsg
	Case WM_KEYDOWN
		Select Case wParam
		Case VK_INSERT
		    CallWindowProc lpOldHexEdProc, hWin, uMsg, wParam, lParam
            SbarSetWriteMode
            Return 0
		End Select 

	Case WM_SETFOCUS
        'Print "HexEd:SETFOCUS"
		'temp fix split focus bug
		If ah.hpane(0) Then
			If ah.hred <> GetParent(hWin) Then
				If ah.hpane(0) <> ah.hred Then
					ah.hpane(1) = ah.hred
				EndIf
				SelectTabByWindow (GetParent (hWin))      ' MOD 1.2.2012 removed ah.hwnd
			EndIf
		EndIf
        SbarSetBlockMode             ' N/A
        SbarLabelLockState
        SbarSetWriteMode    
		'Return 0
        
	Case WM_KILLFOCUS
        'Print "HexEd:KILLFOCUS"
		'SendMessage ah.hwnd, FBE_CHILDLOOSINGFOCUS, 0, Cast (LPARAM, GetParent (hWin))     ' notify: window is loosing focus
	    SbarClear
	End Select

	Return CallWindowProc (lpOldHexEdProc, hWin, uMsg, wParam, lParam)

End Function
