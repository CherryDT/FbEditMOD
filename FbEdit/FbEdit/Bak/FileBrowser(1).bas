Function PropertyProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer

	Dim lret As Integer
	Dim id As Integer
	Dim hItem As Integer
	Dim ht As TVHITTESTINFO
	Dim tvi As TV_ITEM
	Dim sFile As String*260
	Dim fCtrl As Boolean
    Dim p As Point
    Dim Item As LRESULT 
    
	Select Case uMsg
    
	Case WM_RBUTTONDOWN
        SetFocus hWin                 ' MOD 14.2.2012
		p.x = LoWord (lParam)
		p.y = HiWord (lParam)
		Print "x:"; p.x
		Print "y:"; p.y
		
		Item = SendMessage (hWin, LB_ITEMFROMPOINT, 0, lParam)
		Print "n:"; Item
		SendMessage hWin, LB_SETCURSEL, Cast(WPARAM, Item), 0
		Return FALSE  
		
	Case Else
		Return CallWindowProc (lpOldPropertyProc, hWin, uMsg, wparam, lparam)
	End Select

End Function
