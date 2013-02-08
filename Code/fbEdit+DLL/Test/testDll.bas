#Include "windows.bi"

'Dim As HANDLE hFbEditDll = LoadLibrary("../Dll/FbEdit.dll")
Dim As HANDLE hFbEditDll = LoadLibrary("../Src/FbEditBase.dll")

Print hFbEditDll

Dim CharTab As Function() As Any Ptr

If hFbEditDll Then
	Dim As HANDLE hChar = GetProcAddress(hFbEditDll,StrPtr("GetCharTabPtr"))
	Print hChar
	If hChar Then
		CharTab=Cast(Any Ptr, hChar)
		Print CharTab()
	EndIf
	FreeLibrary(hFbEditDll)
End If


Sleep