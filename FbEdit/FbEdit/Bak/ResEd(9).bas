

#Include Once "windowsUR.bi"
#Include Once "win\commctrlUR.bi"
#Include Once "win\richedit.bi"

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAResEd.bi"
#Include Once "Inc\RAProperty.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\IniFile.bi"
#Include Once "Inc\ResEdOpt.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\ResEd.bi"


#Define IDC_RARESED             1301


Dim Shared ressize As WINSIZE=(300,170,0,52,100,100)


Function ResEdProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim rect As RECT
	Dim As Integer nInx,x,y
	Dim pt As Point
	Dim hMnu As HMENU
	Dim hDll As HMODULE
	Dim nBtn As Integer
	Dim tbxwt As Integer
	Dim lpCTLDBLCLICK As CTLDBLCLICK Ptr
	Dim fbcust As FBCUSTSTYLE
	Dim cust As CUSTSTYLE
	Dim fbrstype As FBRSTYPE
	Dim sType As ZString*32
	Dim sExt As ZString*64
	Dim sEdit As ZString*128
	Dim rarstype As RARSTYPE
	Dim buffer As ZString*256
    
    Static hCustDll(32) As HMODULE

	Select Case uMsg
		Case WM_INITDIALOG
			ah.hraresed=GetDlgItem(hWin,IDC_RARESED)
			SendMessage(ah.hraresed,DEM_SETSIZE,0,Cast(LPARAM,@ressize))
			SetDialogOptions(hWin)
			SendMessage(ah.hraresed,DEM_SETPOSSTATUS,Cast(Integer,ah.hsbr),0)
			nInx=1
			x=0
			While nInx<=32
				GetPrivateProfileString(StrPtr("CustCtrl"),Str(nInx),NULL,@buff,260,@ad.IniFile)
				If IsZStrNotEmpty (buff) Then
				    y = lstrlen (buff)
				    If buff[y - 1] = Asc (",") Then buff[y - 1] = NULL    ' no pending comma allowed 
					hDll=Cast(HMODULE,SendMessage(ah.hraresed,DEM_ADDCONTROL,0,Cast(Integer,@buff)))
					If hDll Then
						hCustDll(x)=hDll
						x=x+1
					EndIf
				EndIf
				nInx=nInx+1
			Wend
			nInx=1
			While nInx<=64
				fbcust.lpszStyle=@buff
				SetZStrEmpty (buff)             'MOD 26.1.2012 
				LoadFromIni "CustStyle", Str (nInx), "044", @fbcust, FALSE
				If IsZStrNotEmpty (buff) Then
					cust.szStyle=buff
					cust.nValue=fbcust.nValue
					cust.nMask=IIf(fbcust.nMask,fbcust.nMask,fbcust.nValue)
					SendMessage(ah.hraresed,DEM_ADDCUSTSTYLE,0,Cast(LPARAM,@cust))
				EndIf
				nInx+=1
			Wend
			nInx=1
			While nInx<=32
				fbcust.lpszStyle=@buff
				fbrstype.lpsztype=@sType
				fbrstype.nid=0
				fbrstype.lpszext=@sExt
				fbrstype.lpszedit=@sEdit
				SetZStrEmpty (sType)             'MOD 26.1.2012 
				LoadFromIni "ResType", Str (nInx), "0400", @fbrstype, FALSE
				If IsZStrNotEmpty (sType) OrElse fbrstype.nid<>0 Then
					ZStrReplaceChar @sExt, Asc("!"), Asc(",")      ' MOD 23.1.2012
					rarstype.sztype=sType
					rarstype.nid=fbrstype.nid
					rarstype.szext=sExt
					rarstype.szedit=sEdit
					SendMessage(ah.hraresed,PRO_SETCUSTOMTYPE,nInx-1,Cast(LPARAM,@rarstype))
					If IsZStrEmpty (sExt) AndAlso nInx>11 Then
						buffer="Add " & sType
						InsertMenu(ah.hmenu,IDM_RESOURCE_LANGUAGE,MF_BYCOMMAND,nInx+22000-12,@buffer)
					EndIf
				EndIf
				nInx+=1
			Wend
			'
		Case WM_CLOSE
			DestroyWindow(hWin)
			'
		Case WM_DESTROY
			DestroyWindow(ah.hraresed)
			'
		Case WM_SIZE
			GetClientRect(hWin,@rect)
			MoveWindow(ah.hraresed,0,0,rect.right,rect.bottom,TRUE)
            MoveWindow(ah.hrareseddlg,0,0,rect.right,rect.bottom,TRUE)
            
'		Case EM_GETMODIFY
'			Return SendMessage(ah.hraresed,PRO_GETMODIFY,0,0)
'			'
		Case EM_SETMODIFY
			SendMessage(ah.hraresed,PRO_SETMODIFY,wParam,0)
			'
		Case EM_UNDO
			SendMessage(ah.hraresed,DEM_UNDO,0,0)
			'
		Case EM_REDO
			SendMessage(ah.hraresed,DEM_REDO,0,0)
			'
		Case WM_CUT
			SendMessage(ah.hraresed,DEM_CUT,0,0)
			'
	    Case WM_COPY
			SendMessage(ah.hraresed,DEM_COPY,0,0)
			'
		Case WM_PASTE
			SendMessage(ah.hraresed,DEM_PASTE,0,0)
			'
		Case WM_CLEAR
			SendMessage(ah.hraresed,DEM_DELETECONTROLS,0,0)
			'
		Case WM_NOTIFY
			lpCTLDBLCLICK=Cast(CTLDBLCLICK Ptr,lParam)
			If lpCTLDBLCLICK->nmhdr.code=NM_DBLCLK Then
				CallAddins(hWin,AIM_CTLDBLCLK,0,lParam,HOOK_CTLDBLCLK)
			EndIf
			If lpCTLDBLCLICK->nmhdr.code=NM_CLICK Then
				CallAddins(hWin,AIM_CTLDBLCLK,0,lParam,HOOK_CTLDBLCLK)
			EndIf
			ah.hrareseddlg=Cast(HWND,SendMessage(ah.hraresed,PRO_GETDIALOG,0,0))
			fTimer=1
			'
		Case WM_CONTEXTMENU
			If CallAddins(hWin,AIM_CONTEXTMEMU,wParam,lParam,HOOK_CONTEXTMEMU)=FALSE Then
				If lParam=-1 Then
					GetWindowRect(hWin,@rect)
					pt.x=rect.left+90
					pt.y=rect.top+90
				Else
					pt.x=Cast(Short,LoWord(lParam))
					pt.y=Cast(Short,HiWord(lParam))
				EndIf
				hMnu=GetSubMenu(ah.hcontextmenu,4)
				TrackPopupMenu(hMnu,TPM_LEFTALIGN Or TPM_RIGHTBUTTON,pt.x,pt.y,0,ah.hwnd,0)
			EndIf
			'
		Case WM_SHOWWINDOW
			If ah.hfullscreen<>0 And fInUse=FALSE Then
				fInUse=TRUE
				If wParam Then
					If GetParent(hWin)<>ah.hfullscreen Then
						SetFullScreen(hWin)
					EndIf
				Else
					If GetParent(hWin)=ah.hfullscreen Then
						SetParent(hWin,ah.hwnd)
					EndIf
				EndIf
				fInUse=FALSE
			EndIf
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function
