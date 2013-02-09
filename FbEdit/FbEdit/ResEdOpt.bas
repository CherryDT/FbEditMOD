

#Include Once "windowsUR.bi"
#Include Once "win\commdlg.bi"

#Include Once "Inc\RAGrid.bi"
#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAProperty.bi"
#Include Once "Inc\RAResEd.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\EditorOpt.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\IniFile.bi"
#Include Once "Inc\Language.bi"
#Include Once "Inc\ResEd.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\ResEdOpt.bi"


Const sn = !"rsrc.bi\0                        "
Dim Shared nmeexp  As NAMEEXPORT = (1,2,0,@sn)
Dim Shared grdsize As GRIDSIZE   = (3,3,TRUE,TRUE,TRUE,0,FALSE,TRUE,FALSE,FALSE,FALSE,TRUE)

Dim Shared hTabOpt      As HWND
Dim Shared hTabDlg(4)   As HWND
Dim Shared SelTab       As Integer
Dim Shared grdcol       As Integer
Dim Shared hGrdBr       As HBRUSH

Function TabOpt1Proc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
    
    ' Name Export Tab
	
	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_TABOPT1)
			CheckRadioButton(hWin,IDC_RBNEXPOPT1,IDC_RBNEXPOPT4,IDC_RBNEXPOPT1+nmeexp.nType)
			CheckRadioButton(hWin,IDC_RBNEXPORTFILE,IDC_RBNEXPORTOUT,IDC_RBNEXPORTFILE+nmeexp.nOutput)
			SendDlgItemMessage(hWin,IDC_EDTEXPOPT,EM_LIMITTEXT,MAX_PATH,0)
			SetDlgItemText(hWin,IDC_EDTEXPOPT,nmeexp.szFileName)
			CheckDlgButton(hWin,IDC_CHKAUTOEXPORT,nmeexp.fAuto)
			'
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function

Function TabOpt2Proc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	
	' Custom Controls Tab
	
	Dim As Long id,Event
	Dim nInx As Integer
	Dim ofn As OPENFILENAME
	Dim hGrd As HWND
	Dim clmn As COLUMN
	Dim row(1) As Integer
	Dim x As Integer
	Dim lpGRIDNOTIFY As GRIDNOTIFY Ptr

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_TABOPT2)
			hGrd=GetDlgItem(hWin,IDC_GRDCUST)
			SendMessage(hGrd,WM_SETFONT,SendMessage(hWin,WM_GETFONT,0,0),FALSE)
			SendMessage hGrd, GM_SETHDRHEIGHT, 0, 22
			SendMessage hGrd, GM_SETROWHEIGHT, 0, 20
			clmn.colwt=300
			buff=GetInternalString(IS_RESOURCEOPT3HDR1)
			clmn.lpszhdrtext=StrPtr(buff)
			clmn.halign=GA_ALIGN_LEFT
			clmn.calign=GA_ALIGN_LEFT
			clmn.ctype=TYPE_EDITBUTTON
			clmn.ctextmax=128
			clmn.lpszformat=0
			clmn.himl=0
			clmn.hdrflag=0
			SendMessage(hGrd,GM_ADDCOL,0,Cast(LPARAM,@clmn))
			' Style mask
			clmn.colwt=80
			buff=GetInternalString(IS_RESOURCEOPT3HDR2)
			clmn.lpszhdrtext=StrPtr(buff)
			clmn.halign=GA_ALIGN_LEFT
			clmn.calign=GA_ALIGN_LEFT
			clmn.ctype=TYPE_EDITTEXT
			clmn.ctextmax=16
			clmn.lpszformat=0
			clmn.himl=0
			clmn.hdrflag=0
			SendMessage(hGrd,GM_ADDCOL,0,Cast(LPARAM,@clmn))
			nInx=1
			While nInx<=32
				GetPrivateProfileString(StrPtr("CustCtrl"),Str(nInx),NULL,@buff,260,@ad.IniFile)
				If IsZStrNotEmpty (buff) Then
					x=InStr(buff,",")
					If x Then
						buff[x-1]=NULL
						row(0)=Cast(Integer,@buff)
						If buff[x] Then
						    row(1)=Cast(Integer,@buff[x])
						Else
						    row(1)=0
						EndIf      
					Else
						row(0)=Cast(Integer,@buff)
						row(1)=0
					EndIf
					SendMessage(hGrd,GM_ADDROW,0,Cast(LPARAM,@row(0)))
				EndIf
				nInx=nInx+1
			Wend
			'
		Case WM_COMMAND
			hGrd=GetDlgItem(hWin,IDC_GRDCUST)
			id=LoWord(wParam)
			Event=HiWord(wParam)
			Select Case Event
				Case BN_CLICKED
					Select Case id
						Case IDC_BTNCUSTADD
							nInx=SendMessage(hGrd,GM_ADDROW,0,0)
							SendMessage(hGrd,GM_SETCURSEL,0,nInx)
							SetFocus(hGrd)
							'
						Case IDC_BTNCUSTDEL
							nInx=SendMessage(hGrd,GM_GETCURROW,0,0)
							SendMessage(hGrd,GM_DELROW,nInx,0)
							SendMessage(hGrd,GM_SETCURSEL,0,nInx)
							SetFocus(hGrd)
							'
					End Select
					'
			End Select
			'
		Case WM_NOTIFY
			hGrd=GetDlgItem(hWin,IDC_GRDCUST)
			lpGRIDNOTIFY=Cast(GRIDNOTIFY Ptr,lParam)
			If lpGRIDNOTIFY->nmhdr.hwndFrom=hGrd Then
				If lpGRIDNOTIFY->nmhdr.code=GN_HEADERCLICK Then
					' Sort the grid by column, invert sorting order
					SendMessage(hGrd,GM_COLUMNSORT,lpGRIDNOTIFY->col,SORT_INVERT)
				ElseIf lpGRIDNOTIFY->nmhdr.code=GN_BUTTONCLICK Then
					' Cell button clicked
					ofn.lStructSize=SizeOf(ofn)
					ofn.hwndOwner=hWin
					ofn.hInstance=hInstance
					ofn.lpstrFilter=@DLLFilterString
					ofn.lpstrFile=@buff
					lstrcpy(@buff,Cast(ZString Ptr,lpGRIDNOTIFY->lpdata))
					ofn.nMaxFile=MAX_PATH
					ofn.Flags=OFN_EXPLORER Or OFN_FILEMUSTEXIST Or OFN_HIDEREADONLY Or OFN_PATHMUSTEXIST
					' Show the Open dialog
					If GetOpenFileName(@ofn) Then
						lstrcpy(Cast(ZString Ptr,lpGRIDNOTIFY->lpdata),@buff)
						lpGRIDNOTIFY->fcancel=FALSE
					Else
						lpGRIDNOTIFY->fcancel=TRUE
					EndIf
				EndIf
			EndIf
			'
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function

Function TabOpt3Proc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	
	' Grid Options Tab
	
	Dim cc As ChooseColor

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_TABOPT3)
			SendDlgItemMessage(hWin,IDC_UDNX,UDM_SETRANGE,0,&H00010014)	' Set range
			SendDlgItemMessage(hWin,IDC_UDNX,UDM_SETPOS,0,grdsize.x)		' Set default value
			SendDlgItemMessage(hWin,IDC_UDNY,UDM_SETRANGE,0,&H00010014)	' Set range
			SendDlgItemMessage(hWin,IDC_UDNY,UDM_SETPOS,0,grdsize.y)		' Set default value
			CheckDlgButton(hWin,IDC_CHKSHOWGRID,grdsize.show)
			CheckDlgButton(hWin,IDC_CHKSNAPGRID,grdsize.snap)
			CheckDlgButton(hWin,IDC_CHKSHOWTIP,grdsize.tips)
			CheckDlgButton(hWin,IDC_CHKGRIDLINE,grdsize.line)
			CheckDlgButton(hWin,IDC_CHKSTYLEHEX,grdsize.stylehex)
			CheckDlgButton(hWin,IDC_CHKSIZETOFONT,grdsize.sizetofont)
			CheckDlgButton(hWin,IDC_CHKSIMPLEPROPERTY,grdsize.simple)
			CheckDlgButton(hWin,IDC_CHKDEFSTATIC,grdsize.defstatic)
			'
		Case WM_COMMAND
			If wParam=IDC_STCGRIDCOLOR Then
				cc.lStructSize=SizeOf(ChooseColor)
				cc.hwndOwner=hWin
				cc.hInstance=Cast(Any Ptr,hInstance)
				cc.lpCustColors=Cast(Any Ptr,@custcol)
				cc.Flags=CC_FULLOPEN Or CC_RGBINIT
				cc.lCustData=0
				cc.lpfnHook=0
				cc.lpTemplateName=0
				cc.rgbResult=grdcol
				If ChooseColor(@cc) Then
					DeleteObject(hGrdBr)
					grdcol=cc.rgbResult
					hGrdBr=CreateSolidBrush(grdcol)
					InvalidateRect(GetDlgItem(hWin,IDC_STCGRIDCOLOR),NULL,TRUE)
				EndIf
			EndIf
		Case WM_CTLCOLORSTATIC
			If GetDlgItem(hWin,IDC_STCGRIDCOLOR)=lParam Then
				Return Cast(Integer,hGrdBr)
			EndIf
			Return FALSE
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function

Function TabOpt4Proc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	
	' Custom Styles Tab
	
	Dim As Long id,EVENT
	Dim nInx As Integer
	Dim ofn As OPENFILENAME
	Dim hGrd As HWND
	Dim clmn As COLUMN
	Dim row(2) As ZString Ptr
	Dim x As Integer
	Dim lpGRIDNOTIFY As GRIDNOTIFY Ptr
	Dim fbcust As FBCUSTSTYLE

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_TABOPT4)
			hGrd=GetDlgItem(hWin,IDC_GRDSTYLE)
			SendMessage(hGrd,WM_SETFONT,SendMessage(hWin,WM_GETFONT,0,0),FALSE)
            SendMessage hGrd, GM_SETHDRHEIGHT, 0, 22
            SendMessage hGrd, GM_SETROWHEIGHT, 0, 20
			clmn.colwt=240
			buff=GetInternalString(IS_RESOURCEOPT4HDR1)
			clmn.lpszhdrtext=StrPtr(buff)
			clmn.halign=GA_ALIGN_LEFT
			clmn.calign=GA_ALIGN_LEFT
			clmn.ctype=TYPE_EDITTEXT
			clmn.ctextmax=63
			clmn.lpszformat=0
			clmn.himl=0
			clmn.hdrflag=0
			SendMessage(hGrd,GM_ADDCOL,0,Cast(LPARAM,@clmn))
			' Style value
			clmn.colwt=70
			buff=GetInternalString(IS_RESOURCEOPT4HDR2)
			clmn.lpszhdrtext=StrPtr(buff)
			clmn.halign=GA_ALIGN_LEFT
			clmn.calign=GA_ALIGN_LEFT
			clmn.ctype=TYPE_EDITTEXT
			clmn.ctextmax=8
			clmn.lpszformat=0
			clmn.himl=0
			clmn.hdrflag=0
			SendMessage(hGrd,GM_ADDCOL,0,Cast(LPARAM,@clmn))
			' Style mask
			clmn.colwt=70
			buff=GetInternalString(IS_RESOURCEOPT4HDR3)
			clmn.lpszhdrtext=StrPtr(buff)
			clmn.halign=GA_ALIGN_LEFT
			clmn.calign=GA_ALIGN_LEFT
			clmn.ctype=TYPE_EDITTEXT
			clmn.ctextmax=8
			clmn.lpszformat=0
			clmn.himl=0
			clmn.hdrflag=0
			SendMessage(hGrd,GM_ADDCOL,0,Cast(LPARAM,@clmn))
			nInx=1
			While nInx<=64
				fbcust.lpszStyle=@buff
				SetZStrEmpty (buff)             'MOD 26.1.2012 
				LoadFromIni "CustStyle", Str (nInx), "044", @fbcust, FALSE
				If IsZStrNotEmpty (buff) Then
					row(0)=@buff
					buff[100]=Hex(fbcust.nValue,8)
					row(1)=@buff[100]
					buff[150]=Hex(fbcust.nMask,8)
					row(2)=@buff[150]
					SendMessage(hGrd,GM_ADDROW,0,Cast(LPARAM,@row(0)))
				EndIf
				nInx+=1
			Wend
			'
		Case WM_COMMAND
			hGrd=GetDlgItem(hWin,IDC_GRDSTYLE)
			id=LoWord(wParam)
			Event=HiWord(wParam)
			Select Case Event
				Case BN_CLICKED
					Select Case id
						Case IDC_BTNSTYLEADD
							nInx=SendMessage(hGrd,GM_ADDROW,0,0)
							SendMessage(hGrd,GM_SETCURSEL,0,nInx)
							SetFocus(hGrd)
							'
						Case IDC_BTNSTYLEDEL
							nInx=SendMessage(hGrd,GM_GETCURROW,0,0)
							SendMessage(hGrd,GM_DELROW,nInx,0)
							SendMessage(hGrd,GM_SETCURSEL,0,nInx)
							SetFocus(hGrd)
							'
					End Select
					'
			End Select
			'
		Case WM_NOTIFY
			hGrd=GetDlgItem(hWin,IDC_GRDSTYLE)
			lpGRIDNOTIFY=Cast(GRIDNOTIFY Ptr,lParam)
			If lpGRIDNOTIFY->nmhdr.hwndFrom=hGrd Then
				If lpGRIDNOTIFY->nmhdr.code=GN_HEADERCLICK Then
					' Sort the grid by column, invert sorting order
					SendMessage(hGrd,GM_COLUMNSORT,lpGRIDNOTIFY->col,SORT_INVERT)
				EndIf
			EndIf
			'
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function

Function TabOpt5Proc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	
	' Resource Types Tab
	
	Dim As Long id,Event
	Dim nInx As Integer
	Dim ofn As OPENFILENAME
	Dim hGrd As HWND
	Dim clmn As COLUMN
	Dim row(3) As ZString Ptr
	Dim x As Integer
	Dim lpGRIDNOTIFY As GRIDNOTIFY Ptr
	Dim rarstype As RARSTYPE
	Dim lpRARSTYPE As RARSTYPE Ptr
	Dim fbrstype As FBRSTYPE
	Dim sType As ZString*32
	Dim sExt As ZString*64
	Dim sEdit As ZString*128
	Dim buffer As ZString*MAX_PATH

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_TABOPT5)
			hGrd=GetDlgItem(hWin,IDC_GRDTYPE)
			SendMessage(hGrd,WM_SETFONT,SendMessage(hWin,WM_GETFONT,0,0),FALSE)
			SendMessage hGrd, GM_SETHDRHEIGHT, 0, 22
			SendMessage hGrd, GM_SETROWHEIGHT, 0, 20
			clmn.colwt=110
			buff=GetInternalString(IS_RESOURCEOPT5HDR1)
			clmn.lpszhdrtext=StrPtr(buff)
			clmn.halign=GA_ALIGN_LEFT
			clmn.calign=GA_ALIGN_LEFT
			clmn.ctype=TYPE_EDITTEXT
			clmn.ctextmax=31
			clmn.lpszformat=0
			clmn.himl=0
			clmn.hdrflag=0
			SendMessage(hGrd,GM_ADDCOL,0,Cast(LPARAM,@clmn))
			' Type value
			clmn.colwt=50
			buff=GetInternalString(IS_RESOURCEOPT5HDR2)
			clmn.lpszhdrtext=StrPtr(buff)
			clmn.halign=GA_ALIGN_RIGHT
			clmn.calign=GA_ALIGN_RIGHT
			clmn.ctype=TYPE_EDITLONG
			clmn.ctextmax=5
			clmn.lpszformat=0
			clmn.himl=0
			clmn.hdrflag=0
			SendMessage(hGrd,GM_ADDCOL,0,Cast(LPARAM,@clmn))
			' Files
			clmn.colwt=115
			buff=GetInternalString(IS_RESOURCEOPT5HDR3)
			clmn.lpszhdrtext=StrPtr(buff)
			clmn.halign=GA_ALIGN_LEFT
			clmn.calign=GA_ALIGN_LEFT
			clmn.ctype=TYPE_EDITTEXT
			clmn.ctextmax=63
			clmn.lpszformat=0
			clmn.himl=0
			clmn.hdrflag=0
			SendMessage(hGrd,GM_ADDCOL,0,Cast(LPARAM,@clmn))
			' Editor
			clmn.colwt=115
			buff=GetInternalString(IS_RESOURCEOPT5HDR4)
			clmn.lpszhdrtext=StrPtr(buff)
			clmn.halign=GA_ALIGN_LEFT
			clmn.calign=GA_ALIGN_LEFT
			clmn.ctype=TYPE_EDITBUTTON
			clmn.ctextmax=127
			clmn.lpszformat=0
			clmn.himl=0
			clmn.hdrflag=0
			SendMessage(hGrd,GM_ADDCOL,0,Cast(LPARAM,@clmn))
			fbrstype.lpsztype=@sType
			fbrstype.lpszext=@sExt
			fbrstype.lpszedit=@sEdit
			nInx=1
			While nInx<=32
				SetZStrEmpty (sType)             'MOD 26.1.2012 
				fbrstype.nid=0
				LoadFromIni "ResType", Str (nInx), "0400", @fbrstype, FALSE
				If IsZStrNotEmpty (sType) OrElse fbrstype.nid<>0 Then
					ZStrReplaceChar @sExt, Asc("!"), Asc(",")    ' MOD 23.1.2012
					row(0)=@sType
					row(1)=Cast(ZString Ptr,fbrstype.nid)
					row(2)=@sExt
					row(3)=@sEdit
					SendMessage(hGrd,GM_ADDROW,0,Cast(LPARAM,@row(0)))
				ElseIf nInx<=11 Then
					lpRARSTYPE=Cast(RARSTYPE Ptr,SendMessage(ah.hraresed,PRO_GETCUSTOMTYPE,nInx-1,0))
					sType=lpRARSTYPE->sztype
					sExt=lpRARSTYPE->szext
					sEdit=lpRARSTYPE->szedit
					row(0)=@sType
					row(1)=Cast(ZString Ptr,lpRARSTYPE->nid)
					row(2)=@sExt
					row(3)=@sEdit
					SendMessage(hGrd,GM_ADDROW,0,Cast(LPARAM,@row(0)))
				EndIf
				nInx+=1
			Wend
			'
		Case WM_COMMAND
			hGrd=GetDlgItem(hWin,IDC_GRDTYPE)
			id=LoWord(wParam)
			Event=HiWord(wParam)
			Select Case Event
				Case BN_CLICKED
					Select Case id
						Case IDC_BTNTYPEADD
							nInx=SendMessage(hGrd,GM_ADDROW,0,0)
							SendMessage(hGrd,GM_SETCURSEL,0,nInx)
							SetFocus(hGrd)
							'
						Case IDC_BTNTYPEDEL
							nInx=SendMessage(hGrd,GM_GETCURROW,0,0)
							SendMessage(hGrd,GM_DELROW,nInx,0)
							SendMessage(hGrd,GM_SETCURSEL,0,nInx)
							SetFocus(hGrd)
							'
					End Select
					'
			End Select
			'
		Case WM_NOTIFY
			hGrd=GetDlgItem(hWin,IDC_GRDTYPE)
			lpGRIDNOTIFY=Cast(GRIDNOTIFY Ptr,lParam)
			If lpGRIDNOTIFY->nmhdr.hwndFrom=hGrd Then
				If lpGRIDNOTIFY->nmhdr.code=GN_HEADERCLICK Then
					' Sort the grid by column, invert sorting order
					'SendMessage(hGrd,GM_COLUMNSORT,lpGRIDNOTIFY->col,SORT_INVERT)
				ElseIf lpGRIDNOTIFY->nmhdr.code=GN_BUTTONCLICK Then
					ofn.lStructSize=SizeOf(OPENFILENAME)
					ofn.hwndOwner=hWin
					ofn.hInstance=hInstance
					ofn.lpstrFilter=@EXEFilterString
					ofn.lpstrFile=@buffer
					lstrcpy(@buffer,lpGRIDNOTIFY->lpdata)
					ofn.nMaxFile=SizeOf(buffer)
					ofn.Flags=OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
					' Show the Open dialog
					If GetOpenFileName(@ofn) Then
						lstrcpy(lpGRIDNOTIFY->lpdata,@buffer)
						lpGRIDNOTIFY->fcancel=FALSE
					Else
						lpGRIDNOTIFY->fcancel=TRUE
					EndIf
				ElseIf lpGRIDNOTIFY->nmhdr.code=GN_BEFOREEDIT Then
					If lpGRIDNOTIFY->row<=10 And lpGRIDNOTIFY->col<=2 Then
						lpGRIDNOTIFY->fcancel=TRUE
					EndIf
				ElseIf lpGRIDNOTIFY->nmhdr.code=GN_AFTERSELCHANGE Then
					If lpGRIDNOTIFY->row<=10 Then
						EnableDlgItem(hWin,IDC_BTNTYPEDEL,FALSE)
					Else
						EnableDlgItem(hWin,IDC_BTNTYPEDEL,TRUE)
					EndIf
				EndIf
			EndIf
			'
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function

Sub SetDialogOptions(ByVal hWin As HWND)
	Dim st As Integer

	lstrcpy(@buff,nmeexp.szFileName)
	SendMessage(ah.hraresed,PRO_SETEXPORT,MAKEWPARAM(nmeexp.nType,nmeexp.nOutput),Cast(Integer,@buff))
	SendMessage(ah.hraresed,DEM_SETGRIDSIZE,MAKEWPARAM(grdsize.x,grdsize.y),(grdsize.line Shl 24)+grdsize.color)
	st=GetWindowLong(ah.hraresed,GWL_STYLE)
	st=st And (-1 Xor (DES_GRID Or DES_SNAPTOGRID Or DES_TOOLTIP Or DES_STYLEHEX Or DES_SIZETOFONT Or DES_NODEFINES Or DES_SIMPLEPROPERTY Or DES_DEFIDC_STATIC))
	If grdsize.show Then
		st=st Or DES_GRID
	EndIf
	If grdsize.snap Then
		st=st Or DES_SNAPTOGRID
	EndIf
	If grdsize.tips Then
		st=st Or DES_TOOLTIP
	EndIf
	If grdsize.stylehex Then
		st=st Or DES_STYLEHEX
	EndIf
	If grdsize.sizetofont Then
		st=st Or DES_SIZETOFONT
	EndIf
	If grdsize.nodefines Then
		st=st Or DES_NODEFINES
	EndIf
	If grdsize.simple Then
		st=st Or DES_SIMPLEPROPERTY
	EndIf
	If grdsize.defstatic Then
		st=st Or DES_DEFIDC_STATIC
	EndIf
	SetWindowLong(ah.hraresed,GWL_STYLE,st)

End Sub

Function TabOptionsProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim As Long id, Event
	Dim ts As TCITEM
	Dim nInx As Integer
	Dim lpNMHDR As NMHDR Ptr
	Dim fbcust As FBCUSTSTYLE
	Dim cust As CUSTSTYLE
	Dim sStyle As ZString*64
	Dim sValue As ZString*32
	Dim sMask As ZString*32
	Dim fbrstype As FBRSTYPE
	Dim rarstype As RARSTYPE
	Dim sType As ZString*32
	Dim sExt As ZString*64
	Dim sEdit As ZString*128

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_TABOPTIONS)
			CenterOwner(hWin)
			grdcol=grdsize.color
			hGrdBr=CreateSolidBrush(grdcol)
			' Create the tabs
			hTabOpt=GetDlgItem(hWin,IDC_TABOPT)
			ts.mask=TCIF_TEXT
			ts.iImage=-1
			ts.lParam=0
			buff=GetInternalString(IS_RESOURCEOPT1)
			ts.pszText=StrPtr(buff)
			SendMessage(hTabOpt,TCM_INSERTITEM,0,Cast(Integer,@ts))
			buff=GetInternalString(IS_RESOURCEOPT2)
			ts.pszText=StrPtr(buff)
			SendMessage(hTabOpt,TCM_INSERTITEM,1,Cast(Integer,@ts))
			buff=GetInternalString(IS_RESOURCEOPT3)
			ts.pszText=StrPtr(buff)
			SendMessage(hTabOpt,TCM_INSERTITEM,2,Cast(Integer,@ts))
			buff=GetInternalString(IS_RESOURCEOPT4)
			ts.pszText=StrPtr(buff)
			SendMessage(hTabOpt,TCM_INSERTITEM,3,Cast(Integer,@ts))
			buff=GetInternalString(IS_RESOURCEOPT5)
			ts.pszText=StrPtr(buff)
			SendMessage(hTabOpt,TCM_INSERTITEM,4,Cast(Integer,@ts))
			' Create the tab dialogs
			hTabDlg(0) = CreateDialog (hInstance, MAKEINTRESOURCE (IDD_TABOPT1), hTabOpt, @TabOpt1Proc)  ' Name Export  
			hTabDlg(1) = CreateDialog (hInstance, MAKEINTRESOURCE (IDD_TABOPT3), hTabOpt, @TabOpt3Proc)  ' Grid Options
			hTabDlg(2) = CreateDialog (hInstance, MAKEINTRESOURCE (IDD_TABOPT2), hTabOpt, @TabOpt2Proc)  ' Custom Controls
			hTabDlg(3) = CreateDialog (hInstance, MAKEINTRESOURCE (IDD_TABOPT4), hTabOpt, @TabOpt4Proc)  ' Custom Styles
			hTabDlg(4) = CreateDialog (hInstance, MAKEINTRESOURCE (IDD_TABOPT5), hTabOpt, @TabOpt5Proc)  ' Resource Types
			SelTab=0
			'
		Case WM_NOTIFY
			lpNMHDR=Cast(NMHDR Ptr,lParam)
			If lpNMHDR->code=TCN_SELCHANGE Then
				' Tab selection
				id=SendMessage(hTabOpt,TCM_GETCURSEL,0,0)
                SetFocus hTabDlg(id)
				If id<>SelTab Then
					ShowWindow(hTabDlg(SelTab),SW_HIDE)
					ShowWindow(hTabDlg(id),SW_SHOWDEFAULT)
					SelTab=id
				EndIf
			EndIf
		Case WM_CLOSE
			DeleteObject(hGrdBr)
			EndDialog(hWin,0)
			'
		Case WM_COMMAND
			id=LoWord(wParam)
			Event=HiWord(wParam)
			Select Case id
				Case IDOK
					nInx=SendDlgItemMessage(hTabDlg(2),IDC_GRDCUST,GM_GETCURSEL,0,0)
					SendDlgItemMessage(hTabDlg(2),IDC_GRDCUST,GM_ENDEDIT,nInx,FALSE)
					nInx=SendDlgItemMessage(hTabDlg(3),IDC_GRDSTYLE,GM_GETCURSEL,0,0)
					SendDlgItemMessage(hTabDlg(3),IDC_GRDSTYLE,GM_ENDEDIT,nInx,FALSE)
					nInx=SendDlgItemMessage(hTabDlg(4),IDC_GRDTYPE,GM_GETCURSEL,0,0)
					SendDlgItemMessage(hTabDlg(4),IDC_GRDTYPE,GM_ENDEDIT,nInx,FALSE)
					Select Case TRUE
						Case IsDlgButtonChecked(hTabDlg(0),IDC_RBNEXPOPT1)
							nmeexp.nType=0
						Case IsDlgButtonChecked(hTabDlg(0),IDC_RBNEXPOPT2)
							nmeexp.nType=1
						Case IsDlgButtonChecked(hTabDlg(0),IDC_RBNEXPOPT3)
							nmeexp.nType=2
						Case IsDlgButtonChecked(hTabDlg(0),IDC_RBNEXPOPT4)
							nmeexp.nType=3
					End Select
					Select Case TRUE
						Case IsDlgButtonChecked(hTabDlg(0),IDC_RBNEXPORTFILE)
							nmeexp.nOutput=0
						Case IsDlgButtonChecked(hTabDlg(0),IDC_RBNEXPORTCLIP)
							nmeexp.nOutput=1
						Case IsDlgButtonChecked(hTabDlg(0),IDC_RBNEXPORTOUT)
							nmeexp.nOutput=2
					End Select
					GetDlgItemText(hTabDlg(0),IDC_EDTEXPOPT,@buff,260)
					lstrcpyn(nmeexp.szFileName,buff,32)
					nmeexp.fAuto=IsDlgButtonChecked(hTabDlg(0),IDC_CHKAUTOEXPORT)
					SaveToIni(StrPtr("Resource"),StrPtr("Export"),"4440",@nmeexp,FALSE)
					grdsize.x=GetDlgItemInt(hTabDlg(1),IDC_EDTX,NULL,FALSE)
					grdsize.y=GetDlgItemInt(hTabDlg(1),IDC_EDTY,NULL,FALSE)
					grdsize.show=IsDlgButtonChecked(hTabDlg(1),IDC_CHKSHOWGRID)
					grdsize.snap=IsDlgButtonChecked(hTabDlg(1),IDC_CHKSNAPGRID)
					grdsize.tips=IsDlgButtonChecked(hTabDlg(1),IDC_CHKSHOWTIP)
					grdsize.line=IsDlgButtonChecked(hTabDlg(1),IDC_CHKGRIDLINE)
					grdsize.stylehex=IsDlgButtonChecked(hTabDlg(1),IDC_CHKSTYLEHEX)
					grdsize.sizetofont=IsDlgButtonChecked(hTabDlg(1),IDC_CHKSIZETOFONT)
					grdsize.simple=IsDlgButtonChecked(hTabDlg(1),IDC_CHKSIMPLEPROPERTY)
					grdsize.defstatic=IsDlgButtonChecked(hTabDlg(1),IDC_CHKDEFSTATIC)
					grdsize.color=grdcol
					SaveToIni(StrPtr("Resource"),StrPtr("Grid"),"444444444444",@grdsize,FALSE)
					SetDialogOptions(ah.hres)
					'buff=String(32,0)
					'WritePrivateProfileSection(StrPtr("CustCtrl"),@buff,@ad.IniFile)
					WritePrivateProfileSection(StrPtr("CustCtrl"),szNULL & szNULL,@ad.IniFile)
					nInx=0
					While SendDlgItemMessage(hTabDlg(2),IDC_GRDCUST,GM_GETROWCOUNT,0,0)>nInx
						SendDlgItemMessage(hTabDlg(2),IDC_GRDCUST,GM_GETCELLDATA,MAKEWPARAM(0,nInx),Cast(LPARAM,@buff))
						buff &=","
						SendDlgItemMessage(hTabDlg(2),IDC_GRDCUST,GM_GETCELLDATA,MAKEWPARAM(1,nInx),Cast(LPARAM,@buff[Len(buff)]))
						nInx=nInx+1
						WritePrivateProfileString(StrPtr("CustCtrl"),Str(nInx),@buff,@ad.IniFile)
					Wend
					SendMessage(ah.hraresed,DEM_CLEARCUSTSTYLE,0,0)
					WritePrivateProfileSection(StrPtr("CustStyle"),szNULL & szNULL,@ad.IniFile)
					nInx=0
					While SendDlgItemMessage(hTabDlg(3),IDC_GRDSTYLE,GM_GETROWCOUNT,0,0)>nInx
						SendDlgItemMessage(hTabDlg(3),IDC_GRDSTYLE,GM_GETCELLDATA,MAKEWPARAM(0,nInx),Cast(LPARAM,@sStyle))
						SendDlgItemMessage(hTabDlg(3),IDC_GRDSTYLE,GM_GETCELLDATA,MAKEWPARAM(1,nInx),Cast(LPARAM,@sValue))
						SendDlgItemMessage(hTabDlg(3),IDC_GRDSTYLE,GM_GETCELLDATA,MAKEWPARAM(2,nInx),Cast(LPARAM,@sMask))
						nInx=nInx+1
						fbcust.lpszStyle=@sStyle
						fbcust.nValue=Val("&H" & sValue)
						fbcust.nMask=Val("&H" & sMask)
						SaveToIni(StrPtr("CustStyle"),Str(nInx),"044",@fbcust,FALSE)
						cust.szStyle=sStyle
						cust.nValue=fbcust.nValue
						cust.nMask=fbcust.nMask
						SendMessage(ah.hraresed,DEM_ADDCUSTSTYLE,0,Cast(LPARAM,@cust))
					Wend
					WritePrivateProfileSection(StrPtr("ResType"),szNULL & szNULL,@ad.IniFile)
					nInx=0
					While SendDlgItemMessage(hTabDlg(4),IDC_GRDTYPE,GM_GETROWCOUNT,0,0)>nInx
						SendDlgItemMessage(hTabDlg(4),IDC_GRDTYPE,GM_GETCELLDATA,MAKEWPARAM(0,nInx),Cast(LPARAM,@sType))
						SendDlgItemMessage(hTabDlg(4),IDC_GRDTYPE,GM_GETCELLDATA,MAKEWPARAM(1,nInx),Cast(LPARAM,@rarstype.nid))
						SendDlgItemMessage(hTabDlg(4),IDC_GRDTYPE,GM_GETCELLDATA,MAKEWPARAM(2,nInx),Cast(LPARAM,@sExt))
						SendDlgItemMessage(hTabDlg(4),IDC_GRDTYPE,GM_GETCELLDATA,MAKEWPARAM(3,nInx),Cast(LPARAM,@sEdit))
						nInx=nInx+1
						ZStrReplaceChar @sExt, Asc(","), Asc("!")    ' MOD 23.1.2012
						fbrstype.lpsztype=@sType
						fbrstype.nid=rarstype.nid
						fbrstype.lpszext=@sExt
						fbrstype.lpszedit=@sEdit
						SaveToIni(StrPtr("ResType"),Str(nInx),"0400",@fbrstype,FALSE)
					Wend
					SendMessage(hWin,WM_CLOSE,0,0)
					'
				Case IDCANCEL
					SendMessage(hWin,WM_CLOSE,0,0)
					'
			End Select
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function
