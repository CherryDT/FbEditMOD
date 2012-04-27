#Define IDD_DLGLANGUAGE		1200
#Define IDC_LSTLANGUAGE		1003
#Define BMPMARGIN				3
#Define TEXTMARGIN			26

Dim Shared hLngDlg As HWND

Sub ConvertFrom(ByVal buff As ZString Ptr)
	Dim x As Integer

	x=1
	While x
		x=InStr(*buff,"\t")
		If x Then
			*buff=Left(*buff,x-1) & !"\9" & Mid(*buff,x+2)
		EndIf
	Wend	
	x=1
	While x
		x=InStr(*buff,"\r")
		If x Then
			*buff=Left(*buff,x-1) & !"\13" & Mid(*buff,x+2)
		EndIf
	Wend	
	x=1
	While x
		x=InStr(*buff,"\n")
		If x Then
			*buff=Left(*buff,x-1) & !"\10" & Mid(*buff,x+2)
		EndIf
	Wend	

End Sub

Function FindString(ByVal hMem As HGLOBAL,ByVal szApp As String,ByVal szKey As String) As String
	Dim buff As ZString*1024
	Dim As Integer x,y,z
	Dim lp As ZString Ptr

	If hMem Then
		buff=!"\13\10[" & szApp & !"]\13\10"
		lp=hMem
		x=InStr(*lp,buff)
		If x Then
			z=InStr(x+1,*lp,!"\13\10[")
			If z=0 Then
				z=65535
			EndIf
			buff=!"\13\10" & szKey & "="
			x=InStr(x,*lp,buff)
			If x<>0 And x<z Then
				x=x+Len(buff)
				y=InStr(x,*lp,!"\13")
				buff=Mid(*lp,x,y-x)
				ConvertFrom(@buff)
			Else
				buff=""
			EndIf
		Else
			buff=""
		EndIf
	Else
		buff=""
	EndIf
	Return buff

End Function

Sub UpdateMenuItems(ByVal hMenu As HMENU,ByVal szApp As String)
	Dim hMnu As HMENU
	Dim nPos As Integer
	Dim mii As MENUITEMINFO
	Dim buff As ZString*256
	Dim szID As ZString*256
	
	hMnu=hMenu
	nPos=0
Nxt:
	mii.cbSize=SizeOf(MENUITEMINFO)
	mii.fMask=MIIM_DATA Or MIIM_ID Or MIIM_SUBMENU Or MIIM_TYPE
	mii.dwTypeData=@buff
	mii.cch=SizeOf(buff)
	If GetMenuItemInfo(hMnu,nPos,TRUE,@mii) Then
		If mii.wID<>0 And buff<>"(Empty)" Then
			szID=Str(mii.wID)
			buff=FindString(ad.hLangMem,szApp,szID)
			If Len(buff) Then
				mii.fType=MFT_STRING
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

Function DlgTranslateProc(ByVal hWin As HWND,ByVal lParam As LPARAM) As Boolean
	Dim buff As ZString*256
	Dim id As Integer

	If GetParent(hWin)=hLngDlg Then
		id=GetWindowLong(hWin,GWL_ID)
		lstrcpy(@buff,Cast(ZString Ptr,lParam))
		buff=FindString(ad.hLangMem,buff,Str(id))
		If buff<>"" Then
			SendMessage(hWin,WM_SETTEXT,0,Cast(LPARAM,@buff))
		EndIf
	EndIf
	Return TRUE

End Function

Sub TranslateDialog(ByVal hWin As HWND,ByVal id As Integer)
	Dim buff As ZString*256

	hLngDlg=hWin
	buff=FindString(ad.hLangMem,Str(id),Str(id))
	If buff<>"" Then
		SendMessage(hWin,WM_SETTEXT,0,Cast(LPARAM,@buff))
	EndIf
	buff=Str(id)
	EnumChildWindows(hWin,Cast(Any Ptr,@DlgTranslateProc),Cast(LPARAM,@buff))

End Sub

Function GetInternalString(ByVal id As Integer) As String
	Dim buff As ZString*1024

	If ad.hLangMem Then
		buff=FindString(ad.hLangMem,"Internal",Str(id))
		If buff<>"" Then
			Return buff
		EndIf
	EndIf
	buff=FindString(@InternalStrings,"Internal",Str(id))
	Return buff
	
End Function

Sub TranslateAddinDialog(ByVal hWin As HWND,ByVal sID As String)
	Dim buff As ZString*256

	hLngDlg=hWin
	buff=FindString(ad.hLangMem,sID,sID)
	If buff<>"" Then
		SendMessage(hWin,WM_SETTEXT,0,Cast(LPARAM,@buff))
	EndIf
	buff=sID
	EnumChildWindows(hWin,Cast(Any Ptr,@DlgTranslateProc),Cast(LPARAM,@buff))

End Sub

Sub GetLanguageFile
	Dim buff As ZString*260
	Dim hFile As HANDLE
	Dim nSize As Integer

	buff=ad.AppPath & "\Language\" & Language
	hFile=CreateFile(buff,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
	If hFile<>INVALID_HANDLE_VALUE Then
		nSize=GetFileSize(hFile,NULL)
		ad.hLangMem=GlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,nSize+1)
		ReadFile(hFile,ad.hLangMem,nSize,@nSize,0)
		CloseHandle(hFile)
		UpdateMenuItems(ah.hmenu,"10000")
		UpdateMenuItems(ah.hcontextmenu,"20000")
	EndIf

End Sub

Function LanguageDlgProc(ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
	Dim id As Integer
	Dim buff As ZString*MAX_PATH
	Dim buff2 As ZString*MAX_PATH
	Dim wfd As WIN32_FIND_DATA
	Dim hwfd As HANDLE
	Dim hMem As HGLOBAL
	Dim hFile As HANDLE
	Dim nSize As Integer
	Dim hBmp As HANDLE
	Dim lpdis As DRAWITEMSTRUCT Ptr
	Dim rc As RECT

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_DLGLANGUAGE)
			CenterOwner(hWin)
			id=256
			SendDlgItemMessage(hWin,IDC_LSTLANGUAGE,LB_SETTABSTOPS,1,Cast(LPARAM,@id))
			SendDlgItemMessage(hWin,IDC_LSTLANGUAGE,LB_ADDSTRING,0,Cast(LPARAM,StrPtr("(None)")))
			SendDlgItemMessage(hWin,IDC_LSTLANGUAGE,LB_SETITEMDATA,0,0)
			SendDlgItemMessage(hWin,IDC_LSTLANGUAGE,LB_SETCURSEL,0,0)
			buff=ad.AppPath & "\Language\*lng"
			hwfd=FindFirstFile(@buff,@wfd)
			If hwfd<>INVALID_HANDLE_VALUE Then
				While id
					hBmp=0
					buff=ad.AppPath & "\Language\"
					lstrcat(@buff,@wfd.cFileName)
					lstrcpyn(@buff2,@buff,Len(buff)-2)
					lstrcat(@buff2,"bmp")
					hMem=GlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,256*1024)
					hFile=CreateFile(buff,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
					If hFile<>INVALID_HANDLE_VALUE Then
						nSize=GetFileSize(hFile,NULL)
						ReadFile(hFile,hMem,nSize,@nSize,0)
						buff=FindString(hMem,"Lang","Lang")
						buff=buff & Chr(9)
						lstrcat(@buff,@wfd.cFileName)
						CloseHandle(hFile)
						hBmp=LoadImage(0,@buff2,IMAGE_BITMAP,0,0,LR_LOADFROMFILE)
					EndIf
					GlobalFree(hMem)
					id=SendDlgItemMessage(hWin,IDC_LSTLANGUAGE,LB_ADDSTRING,0,Cast(LPARAM,@buff))
					SendDlgItemMessage(hWin,IDC_LSTLANGUAGE,LB_SETITEMDATA,id,Cast(LPARAM,hBmp))
					If lstrcmpi(@Language,@wfd.cFileName)=0 Then
						SendDlgItemMessage(hWin,IDC_LSTLANGUAGE,LB_SETCURSEL,id,0)
					EndIf
					id=FindNextFile(hwfd,@wfd)
				Wend
			EndIf
			FindClose(hwfd)
			'
		Case WM_DESTROY
			For id=0 To SendDlgItemMessage(hWin,IDC_LSTLANGUAGE,LB_GETCOUNT,0,0)-1
				hBmp=Cast(HANDLE,SendDlgItemMessage(hwin,IDC_LSTLANGUAGE,LB_GETITEMDATA,id,0))
				If hBmp Then
					DeleteObject(hBmp)
				EndIf
			Next
			'
		Case WM_DRAWITEM
			If wParam=IDC_LSTLANGUAGE Then
				lpdis=Cast(DRAWITEMSTRUCT Ptr,lParam)
				If lpdis->itemID=-1 Then
					Exit Function
				EndIf
				rc=lpdis->rcItem
				Select Case lpdis->itemAction
					Case ODA_DRAWENTIRE,ODA_SELECT
						If (lpdis->itemState And ODS_SELECTED)=0 Then
							FillRect(lpdis->hdc,@rc,GetSysColorBrush(COLOR_WINDOW))
							SetBkColor(lpdis->hdc,GetSysColor(COLOR_WINDOW))
							SetTextColor(lpdis->hdc,GetSysColor(COLOR_WINDOWTEXT))
						Else
							rc.right=TEXTMARGIN-2
							FillRect(lpdis->hdc,@rc,GetSysColorBrush(COLOR_3DFACE))
							rc.left=TEXTMARGIN-2
							rc.right=lpdis->rcItem.right
							FillRect(lpdis->hdc,@rc,GetSysColorBrush(COLOR_HIGHLIGHT))
							SetBkColor(lpdis->hdc,GetSysColor(COLOR_HIGHLIGHT))
							SetTextColor(lpdis->hdc,GetSysColor(COLOR_HIGHLIGHTTEXT))
						EndIf
						SendDlgItemMessage(hWin,IDC_LSTLANGUAGE,LB_GETTEXT,lpdis->itemID,Cast(LPARAM,@buff))
						id=InStr(buff,!"\9")-1
						buff[id]=0
						rc.top+=1
						rc.left=TEXTMARGIN
						DrawText(lpdis->hdc,@buff,Len(buff),@rc,DT_SINGLELINE Or DT_LEFT Or DT_VCENTER)
						hBmp=Cast(HANDLE,SendDlgItemMessage(hWin,IDC_LSTLANGUAGE,LB_GETITEMDATA,lpdis->itemID,0))
						If hBmp Then
							DrawState(lpdis->hdc,0,0,Cast(LPARAM,hBmp),0,BMPMARGIN,rc.top+2,0,0,DST_BITMAP)
						EndIf
						Return TRUE
				End Select
			EndIf
			'
		Case WM_CLOSE
			EndDialog(hWin, 0)
			'
		Case WM_COMMAND
			id=LoWord(wParam)
			Select Case id
				Case IDOK
					id=SendDlgItemMessage(hWin,IDC_LSTLANGUAGE,LB_GETCURSEL,0,0)
					SendDlgItemMessage(hWin,IDC_LSTLANGUAGE,LB_GETTEXT,id,Cast(LPARAM,@buff))
					Language=Mid(buff,InStr(buff,Chr(9))+1)
					WritePrivateProfileString(StrPtr("Language"),StrPtr("Language"),@Language,@ad.IniFile)
					EndDialog(hWin, 0)
				Case IDCANCEL
					EndDialog(hWin, 0)
			End Select
			'
		Case WM_SIZE
			'
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function
