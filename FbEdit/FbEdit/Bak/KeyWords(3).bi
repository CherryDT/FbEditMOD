
#Include Once "windowsUR.bi"

Declare Sub SetHiliteWords (ByVal hWin As HWND)
Declare Sub SetHiliteWordsFromApi (ByVal hWin As HWND)
Declare Sub AddApiFile (Byref sFile As zString, ByVal nType As Integer)
Declare Sub LoadApiFiles ()

Common Shared edtopt  As EDITOPTION ' = (3,0,0,1,0,0,3,1,1,1,1,1,1,0,0,0,1,1,1,0,0)
