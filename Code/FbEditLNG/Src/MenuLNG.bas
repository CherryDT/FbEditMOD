
Sub GetMenuItems(ByVal hMenu As HMENU)
	Dim hMnu As HMENU
	Dim nPos As Integer
	Dim mii As MENUITEMINFO
	Dim szBuff As ZString*256
	Dim szID As ZString*256
	
	hMnu=hMenu
	nPos=0
Nxt:
	mii.cbSize=SizeOf(MENUITEMINFO)
	mii.fMask=MIIM_DATA or MIIM_ID or MIIM_SUBMENU or MIIM_TYPE
	mii.dwTypeData=@szBuff
	mii.cch=SizeOf(szBuff)
	If GetMenuItemInfo(hMnu,nPos,TRUE,@mii) Then
		If mii.wID<>0 And szBuff<>"(Empty)" Then
			ConvertTo(@szBuff)
			szID=Str(mii.wID)
			SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@szID))
			SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@"="))
			SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@szBuff))
			SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@!"\13\10"))
			If mii.hSubMenu Then
				GetMenuItems(mii.hSubMenu)
			EndIf
		EndIf
		nPos+=1
		GoTo	Nxt
	EndIf

End Sub

Sub DumpMenu(ByVal ID As Integer)
	Dim hMnu As HMENU
	Dim szBuff As ZString*256

	hMnu=LoadMenu(hInstance,Cast(ZString Ptr,ID))
	If hMnu Then
		SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@"["))
		szBuff=Str(ID)
		SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@szBuff))
		SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@"]"))
		SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@!"\13\10"))
		GetMenuItems(hMnu)
		DestroyMenu(hMnu)
		SendMessage(hEdt,EM_REPLACESEL,FALSE,Cast(LPARAM,@szDivider))
	EndIf

End Sub

Sub UpdateMenuItems(ByVal hMenu As HMENU,ByVal szApp As String)
	Dim hMnu As HMENU
	Dim nPos As Integer
	Dim mii As MENUITEMINFO
	Dim szBuff As ZString*256
	Dim szID As ZString*256
	
	hMnu=hMenu
	nPos=0
Nxt:
	mii.cbSize=SizeOf(MENUITEMINFO)
	mii.fMask=MIIM_DATA or MIIM_ID or MIIM_SUBMENU or MIIM_TYPE
	mii.dwTypeData=@szBuff
	mii.cch=SizeOf(szBuff)
	If GetMenuItemInfo(hMnu,nPos,TRUE,@mii) Then
		If mii.wID<>0 And szBuff<>"(Empty)" Then
			szID=Str(mii.wID)
			szBuff=FindString2(szApp,szID)
			If lstrlen(@szBuff) Then
				SetMenuItemInfo(hMnu,nPos,TRUE,@mii)
			EndIf
			If mii.hSubMenu Then
				UpdateMenuItems(mii.hSubMenu,szApp)
			EndIf
		EndIf
		nPos+=1
		GoTo	Nxt
	EndIf

End Sub

Function DlgMenuProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim hMnu As HMENU
	Dim szApp As ZString*256

	Select Case uMsg
		Case WM_INITDIALOG
			hMnu=LoadMenu(hInstance,Cast(ZString Ptr,lParam))
			SetMenu(hWin,hMnu)
			szApp=Str(lParam)
			UpdateMenuItems(hMnu,szApp)
			'
		Case WM_CLOSE
			EndDialog(hWin, 0)
			'
		Case WM_COMMAND
			'
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function
