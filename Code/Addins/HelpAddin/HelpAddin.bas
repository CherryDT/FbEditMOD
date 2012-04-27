#Include Once "windows.bi"
#Include Once "win/commctrl.bi"

#Include "..\..\FbEdit\Inc\Addins.bi"

#Include "HelpAddin.bi"

' Returns info on what messages the addin hooks into (in an ADDINHOOKS type).
Function InstallDll Cdecl Alias "InstallDll" (ByVal hWin As HWND,ByVal hInst As HINSTANCE) As ADDINHOOKS Ptr Export

	' Dll's instance
	hInstance=hInst
	' Get pointer to ADDINHANDLES
	lpHandles=Cast(ADDINHANDLES Ptr,SendMessage(hWin,AIM_GETHANDLES,0,0))
	' Get pointer to ADDINDATA
	lpData=Cast(ADDINDATA Ptr,SendMessage(hWin,AIM_GETDATA,0,0))
	' Get pointer to ADDINFUNCTIONS
	lpFunctions=Cast(ADDINFUNCTIONS Ptr,SendMessage(hWin,AIM_GETFUNCTIONS,0,0))
	' Messages this addin will hook into
	hooks.hook1=HOOK_COMMAND
	hooks.hook2=0
	hooks.hook3=0
	hooks.hook4=0
	Return @hooks

End Function

' FbEdit calls this function for every addin message that this addin is hooked into.
' Returning TRUE will prevent FbEdit and other addins from processing the message.
Function DllFunction Cdecl Alias "DllFunction" (ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As bool Export
	Dim wrd As ZString*512

	Select Case uMsg
		Case AIM_COMMAND
			' Did user press F1?
			If LoWord(wParam)=IDM_HELPF1 Then
				' Is there an open edit window?
				If lpHandles->hred<>0 And lpHandles->hred<>lpHandles->hres Then
					' Get word under caret.
					SendMessage(lpHandles->hred,REM_GETWORD,SizeOf(wrd),Cast(LPARAM,@wrd))
					' Is word in the fb keyword list?
					If InStr(fbwords," " & LCase(wrd) & " ") Then
						' Show fb.chm
						SendMessage(lpHandles->hwnd,WM_COMMAND,IDM_HELPCTRLF1,0)
						' Prevent FbEdit from showing Win32.hlp
						Return TRUE
					EndIf
				EndIf
			EndIf
			'
	End Select
	Return FALSE

End Function

