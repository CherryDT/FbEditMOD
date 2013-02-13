#Include Once "windows.bi"
#Include Once "win/commctrl.bi"

#Include "..\..\FbEdit\Inc\Addins.bi"

#Include "HelpAddin.bi"
Declare Function ReadIniValue(INIpath As String, KEY As String, Variable As String) As String

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
	'read keywords into string
	fbwords = ReadIniValue(lpdata->IniFile,"EDIT", "c0")
	fbwords &= ReadIniValue(lpdata->IniFile,"EDIT", "c1")
	fbwords &= ReadIniValue(lpdata->IniFile,"EDIT", "c2")
	fbwords &= ReadIniValue(lpdata->IniFile,"EDIT", "c3")
	fbwords &= ReadIniValue(lpdata->IniFile,"EDIT", "c4")
	fbwords &= ReadIniValue(lpdata->IniFile,"EDIT", "c5")
	fbwords &= ReadIniValue(lpdata->IniFile,"EDIT", "c6")
	fbwords &= ReadIniValue(lpdata->IniFile,"EDIT", "c7")
	fbwords &= ReadIniValue(lpdata->IniFile,"EDIT", "c8")
	fbwords &= ReadIniValue(lpdata->IniFile,"EDIT", "c9")
	fbwords &= ReadIniValue(lpdata->IniFile,"EDIT", "c10")
	fbwords &= ReadIniValue(lpdata->IniFile,"EDIT", "c11")
	fbwords &= ReadIniValue(lpdata->IniFile,"EDIT", "c12")
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
					if instr(lcase(fbwords)," " & lcase(wrd) & " ") then
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

Function ReadIniValue(INIpath As String, KEY As String, Variable As String) As String
	Dim FileNum				As Integer
	Dim Temp					As String
	Dim LcaseTemp			As String
	Dim ReadyToRead		As Integer
	Dim ret					As String
   
	'Assign variables
	FileNum = FreeFile
	ReadIniValue = ""
	KEY = "[" & LCase$(KEY) & "]"
	Variable = LCase$(Variable)
   
	'Load from the file
	Open INIpath For Input As FileNum
	While Not EOF(FileNum)
		Line Input #FileNum, Temp
		LcaseTemp = LCase$(Temp)
		If InStr(LcaseTemp, "[") <> 0 Then ReadyToRead = 0
		If LcaseTemp = KEY Then ReadyToRead = 1
		If InStr(LcaseTemp, "[") = 0 And ReadyToRead = 1 Then
			If InStr(LcaseTemp, Variable & "=") = 1 Then
				ret = Mid$(Temp, 1 + Len(Variable & "="))
				If Left(ret,1) = !"\"" Then ret = Right(ret, Len(ret)-1)
				If Right(ret,1) = !"\"" Then ret = Left(ret, Len(ret)-1)
				Close FileNum
				Return ret
			End If
		End If
	Wend
	Close FileNum
	Return ret
End Function
