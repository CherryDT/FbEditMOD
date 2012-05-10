#Include once "windows.bi"
#include once "win/commctrl.bi"

#include "..\..\..\Inc\Addins.bi"

#include "HelpAddin.bi"

Declare Function ReadIniValue(INIpath As String, KEY As String, Variable As String) As String

' Returns info on what messages the addin hooks into (in an ADDINHOOKS type).
function InstallDll CDECL alias "InstallDll" (byval hWin as HWND,byval hInst as HINSTANCE) as ADDINHOOKS ptr EXPORT

	' Dll's instance
	hInstance=hInst
	' Get pointer to ADDINHANDLES
	lpHandles=Cast(ADDINHANDLES ptr,SendMessage(hWin,AIM_GETHANDLES,0,0))
	' Get pointer to ADDINDATA
	lpData=Cast(ADDINDATA ptr,SendMessage(hWin,AIM_GETDATA,0,0))
	' Get pointer to ADDINFUNCTIONS
	lpFunctions=Cast(ADDINFUNCTIONS ptr,SendMessage(hWin,AIM_GETFUNCTIONS,0,0))
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
	return @hooks

end function

' FbEdit calls this function for every addin message that this addin is hooked into.
' Returning TRUE will prevent FbEdit and other addins from processing the message.
function DllFunction CDECL alias "DllFunction" (byval hWin as HWND,byval uMsg as UINT,byval wParam as WPARAM,byval lParam as LPARAM) as bool EXPORT
	dim wrd as zstring*512

	select case uMsg
		case AIM_COMMAND
			' Did user press F1?
			if loword(wParam)=IDM_HELPF1 Then
				' Is there an open edit window?
				if lpHandles->hred<>0 and lpHandles->hred<>lpHandles->hres Then
					' Get word under caret.
					SendMessage(lpHandles->hred,REM_GETWORD,SizeOf(wrd),Cast(LPARAM,@wrd))
					' Is word in the fb keyword list?
					if instr(lcase(fbwords)," " & lcase(wrd) & " ") then
						' Show fb.chm
						SendMessage(lpHandles->hwnd,WM_COMMAND,IDM_HELPCTRLF1,0)
						' Prevent FbEdit from showing Win32.hlp
						return TRUE
					endif
				endif
			endif
			'
	end select
	return FALSE

end function

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
