

#Include Once "windowsUR.bi"


Declare Sub ReadTheFile (ByVal hWin As HWND, ByVal lpFile As ZString Ptr)
Declare Sub WriteTheFile (ByVal hWin As HWND,Byref szFileName As zString)

Declare Function GetFileMem OverLoad (Byref sFile As String) As HGLOBAL
Declare Function GetFileMem OverLoad (Byval hEdit As HWND) As HGLOBAL



