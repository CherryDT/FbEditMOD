
#Define IDD_FINDDLG							2500
#Define IDC_FINDTEXT							2001
#Define IDC_REPLACETEXT						2002
#Define IDC_CHK_MATCHCASE					2003
#Define IDC_CHK_WHOLEWORD					2007
#Define IDC_BTN_REPLACEALL					2008
#Define IDC_REPLACESTATIC					2009
#Define IDC_BTN_REPLACE						2010
#Define IDC_CHK_SKIPCOMMENTS				2013
#Define IDC_CHK_LOGFIND						2014
#Define IDC_BTN_FINDALL						2015
' Direction
#Define IDC_RBN_ALL							2004
#Define IDC_RBN_DOWN							2005
#Define IDC_RBN_UP							2006
' Search
#Define IDC_RBN_SELECTION					2505
#Define IDC_RBN_PROCEDURE					2502
#Define IDC_RBN_MODULE						2503
#Define IDC_RBN_FILES						2504
#Define IDC_RBN_PROJECTFILES				2012

Sub InitFindDir
	
	Select Case f.fdir
		Case 0,1
			' All, Down
			If f.fsearch=4 Then
				f.ft.chrg.cpMin=f.chrginit.cpMin
			Else
				f.ft.chrg.cpMin=f.chrginit.cpMax
			EndIf
			f.ft.chrg.cpMax=f.chrgrange.cpMax
			f.fr=f.fr Or FR_DOWN
		Case 2
			' Up
			f.ft.chrg.cpMin=f.chrginit.cpMin
			f.ft.chrg.cpMax=f.chrgrange.cpMin
			f.fr=f.fr And (-1 Xor FR_DOWN)
	End Select

End Sub

Sub InitFind
	Dim nLn As Integer
	Dim isinp As ISINPROC
	Dim tci As TCITEM
	Dim lpTABMEM As TABMEM Ptr
	Dim p As ZString Ptr
	Dim i As Integer
	Dim sItem As String
	Dim nMiss As Integer

	f.listoffiles=""
	SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@f.chrginit))
	Select Case f.fsearch
		Case 0
			' Current Procedure
			isinp.nLine=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,f.chrginit.cpMin)
			isinp.lpszType=StrPtr("p")
			If fProject Then
				tci.mask=TCIF_PARAM
				SendMessage(ah.htabtool,TCM_GETITEM,SendMessage(ah.htabtool,TCM_GETCURSEL,0,0),Cast(LPARAM,@tci))
				lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
				isinp.nOwner=lpTABMEM->profileinx
			Else
				isinp.nOwner=Cast(Integer,ah.hred)
			EndIf
			p=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_ISINPROC,0,Cast(LPARAM,@isinp)))
			If p Then
				p=FindExact(StrPtr("p"),p,TRUE)
				nLn=SendMessage(ah.hpr,PRM_FINDGETLINE,0,0)
				f.chrgrange.cpMin=SendMessage(ah.hred,EM_LINEINDEX,nLn,0)
				nLn=SendMessage(ah.hpr,PRM_FINDGETENDLINE,0,0)
				f.chrgrange.cpMax=SendMessage(ah.hred,EM_LINEINDEX,nLn,0)
				f.fnoproc=FALSE
			Else
				f.chrgrange.cpMin=0
				f.chrgrange.cpMax=SendMessage(ah.hred,WM_GETTEXTLENGTH,0,0)+1
				f.fnoproc=TRUE
			EndIf
			'
		Case 1
			' Current Module
			f.chrgrange.cpMin=0
			f.chrgrange.cpMax=SendMessage(ah.hred,WM_GETTEXTLENGTH,0,0)+1
			'
		Case 2
			' All Open Files
			f.chrgrange.cpMin=0
			f.chrgrange.cpMax=SendMessage(ah.hred,WM_GETTEXTLENGTH,0,0)+1
			f.listoffiles=","
			' Add open files
			i=SendMessage(ah.htabtool,TCM_GETCURSEL,0,0)
			If i Then
				While TRUE
					tci.mask=TCIF_PARAM
					If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(LPARAM,@tci)) Then
						lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
						If FileType(lpTABMEM->filename)=1 Then
							f.listoffiles &= Str(i) & ","
						EndIf
					Else
						Exit While
					EndIf
					i+=1
				Wend
			EndIf
			i=0
			While TRUE
				tci.mask=TCIF_PARAM
				If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(LPARAM,@tci)) Then
					lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
					If FileType(lpTABMEM->filename)=1 Then
						If InStr(f.listoffiles,"," & Str(i) & ",")=0 Then
							f.listoffiles &= Str(i) & ","
						EndIf
					EndIf
				Else
					Exit While
				EndIf
				i+=1
			Wend
			f.fpro=1
			f.listoffiles=Mid(f.listoffiles,2)
			'
		Case 3
			' All Project Files
			f.listoffiles=","
			' Add open project files
			i=SendMessage(ah.htabtool,TCM_GETCURSEL,0,0)
			If i Then
				While TRUE
					tci.mask=TCIF_PARAM
					If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(LPARAM,@tci)) Then
						lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
						If lpTABMEM->profileinx Then
							If FileType(lpTABMEM->filename)=1 Then
								f.listoffiles &= Str(lpTABMEM->profileinx) & ","
							EndIf
						EndIf
					Else
						Exit While
					EndIf
					i+=1
				Wend
			EndIf
			i=0
			While TRUE
				tci.mask=TCIF_PARAM
				If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(LPARAM,@tci)) Then
					lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
					If lpTABMEM->profileinx Then
						If FileType(lpTABMEM->filename)=1 Then
							If InStr(f.listoffiles,"," & Str(lpTABMEM->profileinx) & ",")=0 Then
								f.listoffiles &= Str(lpTABMEM->profileinx) & ","
							EndIf
						EndIf
					EndIf
				Else
					Exit While
				EndIf
				i+=1
			Wend
			' Add not open project files
			f.ffileno=0
			While f.ffileno<1256 And nMiss<=10
				f.ffileno+=1
				sItem=GetProjectFileName(f.ffileno)
				If Len(sItem) Then
					If FileType(sItem)=1 Then
						If InStr(f.listoffiles,"," & Str(f.ffileno) & ",")=0 Then
							f.listoffiles &= Str(f.ffileno) & ","
						EndIf
					EndIf
					nMiss=0
				Else
					nMiss+=1
				EndIf
				If (f.ffileno>256 Or nMiss>=10) And f.ffileno<1001 Then
					f.ffileno=1000
					nMiss=0
				EndIf
			Wend
			f.listoffiles=Mid(f.listoffiles,2)
			f.ffileno=1
			f.fpro=1
			'
		Case 4
			' Current selection
			SendMessage(ah.hred,EM_EXGETSEL,0,Cast(Integer,@f.chrgrange))
			'
	End Select
	InitFindDir
	f.ft.lpstrText=@f.findbuff

End Sub

Sub ResetFind

	If f.fnoreset=FALSE Then
		f.fres=-1
		f.fonlyonetime=0
		f.nreplacecount=0
		SetDlgItemText(findvisible,IDOK,GetInternalString(IS_FIND))
		InitFind
	EndIf

End Sub

Sub ShowStat()
	Dim As Integer i,bm,nFiles,nFounds,nRepeats,nErrors,nWarnings

	i=SendMessage(ah.hout,EM_GETLINECOUNT,0,0)
	While i>-1
		bm=SendMessage(ah.hout,REM_GETBOOKMARK,i,0)
		Select Case As Const bm
			Case 3
				nFounds+=1
			Case 4
				nRepeats+=1
			Case 5
				nFiles+=1
			Case 6
				nWarnings+=1
			Case 7
				nErrors+=1
		End Select
		i-=1
	Wend
	If f.fsearch=3 Then
		wsprintf(@buff,GetInternalString(IS_PROJECT_FILES_SEARCHED_INFO),10,10,10,nFiles,10,nFounds,10,nRepeats,10,10,10,nErrors,10,nWarnings)
	ElseIf f.fsearch=2 Then
		wsprintf(@buff,GetInternalString(IS_OPEN_FILES_SEARCHED_INFO),10,10,10,nFiles,10,nFounds,10,nRepeats,10,10,10,nErrors,10,nWarnings)
	Else
		wsprintf(@buff,GetInternalString(IS_REGION_SEARCHED_INFO),10,10,10,nFounds,10,nRepeats,10,10,10,nErrors,10,nWarnings)
	EndIf
	MessageBox(ah.hwnd,@buff,@szAppName,MB_OK Or MB_ICONINFORMATION)

End Sub

Function FindInFile(hWin As HWND,frType As Integer) As Integer
	Dim res As Integer

	res=SendMessage(hWin,EM_FINDTEXTEX,frType,Cast(LPARAM,@f.ft))
	If res<>-1 Then
		If f.fdir=2 Then
			f.ft.chrg.cpMin=f.ft.chrgText.cpMin-1
		Else
			f.ft.chrg.cpMin=f.ft.chrgText.cpMax
		EndIf
	Else
		If f.fdir=0 And f.fsearch<>4 Then
			' All
			If f.chrginit.cpMin<>0 And f.ft.chrg.cpMax>f.chrginit.cpMax Then
				f.ft.chrg.cpMin=f.chrgrange.cpMin
				f.ft.chrg.cpMax=f.chrginit.cpMax-1
				f.chrginit.cpMin=0
				res=FindInFile(hWin,frType)
			EndIf
		EndIf
	EndIf
	Return res

End Function

Function Find(hWin As HWND,frType As Integer) As Integer
	Dim isinp As ISINPROC
	Dim tci As TCITEM
	Dim lpTABMEM As TABMEM Ptr
	Dim p As ZString Ptr
	Dim sFile As ZString*260
	Dim hMem As HGLOBAL
	Dim ms As MEMSEARCH
	Dim hREd As HWND
	Dim i As Integer
	Dim chrg As CHARRANGE
	Dim nLine As Integer

	chrg.cpMin=-1
	chrg.cpMax=-1
	SendMessage(ah.hout,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
	f.nlinesout=SendMessage(ah.hout,EM_GETLINECOUNT,0,0)
TryAgain:
	Select Case f.fsearch
		Case 0
			' Current Procedure
			If f.fnoproc Then
				While TRUE
					f.fres=FindInFile(ah.hred,frType)
					If f.fres<>-1 Then
						isinp.nLine=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,f.ft.chrgText.cpMin)
						isinp.lpszType=StrPtr("p")
						If fProject Then
							tci.mask=TCIF_PARAM
							SendMessage(ah.htabtool,TCM_GETITEM,SendMessage(ah.htabtool,TCM_GETCURSEL,0,0),Cast(LPARAM,@tci))
							lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
							isinp.nOwner=lpTABMEM->profileinx
						Else
							isinp.nOwner=Cast(Integer,ah.hred)
						EndIf
						p=Cast(ZString Ptr,SendMessage(ah.hpr,PRM_ISINPROC,0,Cast(LPARAM,@isinp)))
						If p=0 Then
							Exit While
						EndIf
					Else
						Exit While
					EndIf
				Wend
			Else
				f.fres=FindInFile(ah.hred,frType)
			EndIf
			'
		Case 1
			' Current Module
			f.fres=FindInFile(ah.hred,frType)
			'
		Case 2
			' All Open Files
TheNextTab:
			If f.fpro=1 Then
				While Len(f.listoffiles)
					i=InStr(f.listoffiles,",")
					f.ffileno=Val(Left(f.listoffiles,i-1))
					f.listoffiles=Mid(f.listoffiles,i+1)
					tci.mask=TCIF_PARAM
					SendMessage(ah.htabtool,TCM_GETITEM,f.ffileno,Cast(LPARAM,@tci))
					lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
					SendMessage(lpTABMEM->hedit,EM_EXGETSEL,0,Cast(LPARAM,@f.chrginit))
					f.chrgrange.cpMin=0
					f.chrgrange.cpMax=SendMessage(lpTABMEM->hedit,WM_GETTEXTLENGTH,0,0)+1
					InitFindDir
					f.fres=FindInFile(lpTABMEM->hedit,frType)
					If f.fres<>-1 Then
						f.fpro=2
						SelectTab(ah.hwnd,lpTABMEM->hedit,0)
						f.fonlyonetime=0
						Exit While
					Else
						f.fpro=1
						GoTo TheNextTab
					EndIf
					f.fres=-1
				Wend
			Else
				f.fres=FindInFile(ah.hred,frType)
				If f.fres=-1 Then
					f.fpro=1
					GoTo TheNextTab
				EndIf
			EndIf
			'
		Case 3
			' All Project Files
TheNextFile:
			If f.fpro=1 Then
				While Len(f.listoffiles)
					i=InStr(f.listoffiles,",")
					f.ffileno=Val(Left(f.listoffiles,i-1))
					f.listoffiles=Mid(f.listoffiles,i+1)
					sFile=GetProjectFileName(f.ffileno)
					If Len(sFile) Then
						hMem=GetFileMem(sFile)
						If hMem Then
							ms.lpMem=hMem
							ms.lpFind=@f.findbuff
							ms.lpCharTab=ad.lpCharTab
							' Memory search down is faster
							ms.fr=f.fr Or FR_DOWN
							f.fres=SendMessage(ah.hpr,PRM_MEMSEARCH,0,Cast(Integer,@ms))
							GlobalFree(hMem)
							If f.fres Then
								f.fnoreset=TRUE
								OpenProjectFile(f.ffileno)
								SetFocus(ah.hfind)
								f.fnoreset=FALSE
								SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@f.chrginit))
								f.chrgrange.cpMin=0
								f.chrgrange.cpMax=SendMessage(ah.hred,WM_GETTEXTLENGTH,0,0)+1
								InitFindDir
								f.fpro=2
								f.fonlyonetime=0
								GoTo TheNextFile
							EndIf
						EndIf
					EndIf
				Wend
				f.fres=-1
			Else
				f.fres=FindInFile(ah.hred,frType)
				If f.fres=-1 Then
					f.fpro=1
					GoTo TheNextFile
				EndIf
			EndIf
			'
		Case 4
			' Current selection
			f.fres=FindInFile(ah.hred,frType)
			'
	End Select
	If f.fres<>-1 Then
		If f.fskipcommentline Then
			i=SendMessage(ah.hred,REM_ISCHARPOS,f.ft.chrgText.cpMin,0)
			If i=1 Or i=2 Then
				If f.fdir=2 Then
					f.ft.chrg.cpMin-=1
				Else
					f.ft.chrg.cpMin+=1
				EndIf
				GoTo TryAgain
			EndIf
		EndIf
		If f.flogfind Then
			If f.fonlyonetime=0 Then
				SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(LPARAM,@ad.filename))
				SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(LPARAM,@CR))
				SendMessage(ah.hout,REM_SETBOOKMARK,f.nlinesout,5)
				SendMessage(ah.hout,REM_SETBMID,f.nlinesout,0)
				f.fonlyonetime=1
				f.nlinesout+=1
			EndIf
			buff=Chr(255) & Chr(1)
			nLine=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,f.fres)
			chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,nLine,0)
			chrg.cpMax=SendMessage(ah.hred,EM_GETLINE,nLine,Cast(LPARAM,@buff))
			buff[chrg.cpMax]=NULL
			lstrcpy(@s," (")
			lstrcat(@s,Str(nLine+1))
			lstrcat(@s,") ")
			lstrcat(@s,@buff)
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(LPARAM,@s))
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(LPARAM,@CR))
			i=SendMessage(ah.hred,REM_GETBOOKMARK,nLine,0)
			If i<>3 Then
				SendMessage(ah.hout,REM_SETBOOKMARK,f.nlinesout,3)
				SendMessage(ah.hred,REM_SETBOOKMARK,nLine,3)
				i=SendMessage(ah.hout,REM_GETBMID,f.nlinesout,0)
				SendMessage(ah.hred,REM_SETBMID,nLine,i)
			Else
				SendMessage(ah.hout,REM_SETBOOKMARK,f.nlinesout,4)
				SendMessage(ah.hout,REM_SETBMID,f.nlinesout,0)
			EndIf
			f.nlinesout+=1
		EndIf
		' Mark the foud text
		ad.fNoNotify=TRUE
		SendMessage(ah.hred,EM_EXSETSEL,0,Cast(LPARAM,@f.ft.chrgText))
		SendMessage(ah.hred,REM_VCENTER,0,0)
		SendMessage(ah.hred,EM_SCROLLCARET,0,0)
		ad.fNoNotify=FALSE
	Else
		Select Case f.fsearch
			Case 3
				' Project Files searched
				buff=GetInternalString(IS_PROJECT_FILES_SEARCHED)
			Case Else
				' Region searched
				buff=GetInternalString(IS_REGION_SEARCHED)
		End Select
		If f.nreplacecount Then
			buff &=CR & CR & Str(f.nreplacecount) & " " & GetInternalString(IS_REPLACEMENTS_DONE)
		EndIf
		If f.flogfind Then
			ShowStat()
		Else
			MessageBox(hWin,@buff,@szAppName,MB_OK Or MB_ICONINFORMATION)
		EndIf
		ResetFind
	EndIf
	Return f.fres

End Function

Sub LoadFindHistory()
	Dim As Integer i
	Dim As ZString*260 sItem
	
	For i=1 To 9
		If GetPrivateProfileString(StrPtr("Find"),Str(i),@szNULL,@sItem,SizeOf(sItem),@ad.IniFile) Then
			FindHistory(i-1)=sItem
		Else
			Exit For
		EndIf
	Next
	
End Sub

Sub SaveFindHistory()
	Dim As Integer i
	
	For i=1 To 9
		WritePrivateProfileString(StrPtr("Find"),Str(i),@FindHistory(i-1),@ad.IniFile)
	Next
	
End Sub

Sub UpdateFindHistory(ByVal hWin As HWND)
	
	If Len(f.findbuff) And SendMessage(hWin,CB_FINDSTRINGEXACT,-1,Cast(LPARAM,@f.findbuff))=CB_ERR Then
		SendMessage(hWin,CB_INSERTSTRING,0,Cast(LPARAM,@f.findbuff))
	EndIf

End Sub

Sub UpDateFind(ByVal hWin As HWND,ByVal cpMin As Integer,ByVal fChanged As Integer)
	Dim As Integer nSize,i

	If hWin<>nLasthWin Then
		nSize=SendMessage(hWin,WM_GETTEXTLENGTH,0,0)
		nLastSize=nSize
		nLasthWin=hWin
	ElseIf fchanged Then
		nSize=SendMessage(hWin,WM_GETTEXTLENGTH,0,0)
		nSize-=nLastSize
		If nSize Then
			' Update find
			If nLastCp<=f.ft.chrg.cpMin Then
				f.ft.chrg.cpMin+=nSize
				f.ft.chrg.cpMax+=nSize
			ElseIf nLastCp<=f.ft.chrg.cpMax Then
				f.ft.chrg.cpMax+=nSize
			EndIf
			If nLastCp<=f.chrginit.cpMin Then
				f.chrginit.cpMin+=nSize
				f.chrginit.cpMax+=nSize
			ElseIf nLastCp<=f.chrginit.cpMax Then
				f.chrginit.cpMax+=nSize
			EndIf
			If nLastCp<=f.chrgrange.cpMin Then
				f.chrgrange.cpMin+=nSize
				f.chrgrange.cpMax+=nSize
			ElseIf nLastCp<=f.chrgrange.cpMax Then
				f.chrgrange.cpMax+=nSize
			EndIf
			' Update find declare
			For i=0 To 31
				If fdc(i).hwnd=hWin Then
					If nLastCp<=fdc(i).npos Then
						fdc(i).npos+=nSize
					EndIf
				EndIf
			Next
		EndIf
		nLastSize+=nSize
	EndIf
	nLastCp=cpMin

End Sub

Function FindDlgProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim As Integer id,Event,lret
	Dim hCtl As HWND
	Dim chrg As CHARRANGE
	Dim rect As RECT

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_FINDDLG)
			findvisible=hWin
			If lParam Then
				PostMessage(hWin,WM_COMMAND,(BN_CLICKED Shl 16) Or IDC_BTN_REPLACE,0)
			EndIf
			' Fill ComboBox
			hCtl=GetDlgItem(hWin,IDC_FINDTEXT)
			For id=0 To 8
				If Len(FindHistory(id)) Then
					SendMessage(hCtl,CB_ADDSTRING,0,Cast(LPARAM,@FindHistory(id)))
				EndIf
			Next
			' Put text in edit boxes
			SendDlgItemMessage(hWin,IDC_FINDTEXT,EM_LIMITTEXT,255,0)
			SendDlgItemMessage(hWin,IDC_FINDTEXT,WM_SETTEXT,0,Cast(Integer,@f.findbuff))
			SendDlgItemMessage(hWin,IDC_REPLACETEXT,EM_LIMITTEXT,255,0)
			SendDlgItemMessage(hWin,IDC_REPLACETEXT,WM_SETTEXT,0,Cast(Integer,@f.replacebuff))
			' Set check boxes
			CheckDlgButton(hWin,IDC_CHK_MATCHCASE,IIf(f.fr And FR_MATCHCASE,BST_CHECKED,BST_UNCHECKED))
			CheckDlgButton(hWin,IDC_CHK_WHOLEWORD,IIf(f.fr And FR_WHOLEWORD,BST_CHECKED,BST_UNCHECKED))
			' Set find direction
			Select Case f.fdir
				Case 0
					id=IDC_RBN_ALL
				Case 1
					id=IDC_RBN_DOWN
				Case 2
					id=IDC_RBN_UP
			End Select
			CheckDlgButton(hWin,id,BST_CHECKED)
			SendMessage(ah.hred,EM_EXGETSEL,0,Cast(Integer,@f.ft.chrg))
			EnableWindow(GetDlgItem(hWin,IDC_RBN_SELECTION),f.ft.chrg.cpMin<>f.ft.chrg.cpMax)
			CheckDlgButton(hWin,IDC_CHK_SKIPCOMMENTS,IIf(f.fskipcommentline,BST_CHECKED,BST_UNCHECKED))
			CheckDlgButton(hWin,IDC_CHK_LOGFIND,IIf(f.flogfind,BST_CHECKED,BST_UNCHECKED))
			EnableWindow(GetDlgItem(hWin,IDC_BTN_FINDALL),f.flogfind)
			EnableWindow(GetDlgItem(hWin,IDC_RBN_PROJECTFILES),fProject)
			Select Case f.fsearch
				Case 0
					id=IDC_RBN_PROCEDURE
				Case 1
					id=IDC_RBN_MODULE
				Case 2
					id=IDC_RBN_FILES
				Case 3
					id=IDC_RBN_PROJECTFILES
				Case 4
					id=IDC_RBN_MODULE
					f.fsearch=1
			End Select
			CheckDlgButton(hWin,id,BST_CHECKED)
			SetWindowPos(hWin,0,wpos.ptfind.x,wpos.ptfind.y,0,0,SWP_NOSIZE)
			f.fpro=0
			ResetFind
			'
		Case WM_ACTIVATE
			If wParam<>WA_INACTIVE Then
				ah.hfind=hWin
			EndIf
			EnableWindow(GetDlgItem(hWin,IDC_RBN_PROJECTFILES),fProject)
			ResetFind
			If ah.hred Then
				id=GetWindowLong(ah.hred,GWL_ID)
			EndIf
			If id=IDC_HEXED Or id=0 Then
				EnableWindow(GetDlgItem(hWin,IDOK),FALSE)
				EnableWindow(GetDlgItem(hWin,IDC_BTN_REPLACE),FALSE)
			Else
				EnableWindow(GetDlgItem(hWin,IDOK),TRUE)
				EnableWindow(GetDlgItem(hWin,IDC_BTN_REPLACE),TRUE)
			EndIf
			'
		Case WM_COMMAND
			id=LoWord(wParam)
			Event=HiWord(wParam)
			If Event=BN_CLICKED Then
				Select Case id
					Case IDOK
						If f.fdir=2 Then
							buff=GetInternalString(IS_PREVIOUS)
						Else
							buff=GetInternalString(IS_NEXT)
						EndIf
						SendMessage(GetDlgItem(hWin,IDOK),WM_SETTEXT,0,Cast(LPARAM,@buff))
						UpdateFindHistory(GetDlgItem(hWin,IDC_FINDTEXT))
						Find(hWin,f.fr)
						'
					Case IDCANCEL
						SendMessage(hWin,WM_CLOSE,0,0)
						'
					Case IDC_BTN_REPLACE
						hCtl=GetDlgItem(hWin,IDC_BTN_REPLACEALL)
						If IsWindowEnabled(hCtl)=FALSE Then
							' Enable Replace all button
							EnableWindow(hCtl,TRUE)
							' Set caption to Replace...
							SetWindowText(hWin,GetInternalString(IS_REPLACE))
							' Show replace
							hCtl=GetDlgItem(hWin,IDC_REPLACESTATIC)
							ShowWindow(hCtl,SW_SHOWNA)
							hCtl=GetDlgItem(hWin,IDC_REPLACETEXT)
							ShowWindow(hCtl,SW_SHOWNA)
						Else
							If f.fres<>-1 Then
								f.nreplacecount+=1
								SendMessage(ah.hred,EM_REPLACESEL,TRUE,Cast(Integer,@f.replacebuff))
								If f.fdir=2 Then
									' Up
									f.ft.chrg.cpMin=f.ft.chrg.cpMin-1
								EndIf
							EndIf
							Find(hWin,f.fr)
						EndIf
						'
					Case IDC_BTN_FINDALL
						UpdateFindHistory(GetDlgItem(hWin,IDC_FINDTEXT))
						If f.fres=-1 Then
							Find(hWin,f.fr)
						EndIf
						Do While f.fres<>-1
							SendMessage(ah.hred,EM_EXGETSEL,0,Cast(Integer,@chrg))
							If f.fdir=2 Then
								If f.fres<>-1 Then
									f.ft.chrg.cpMin=chrg.cpMin-1
								EndIf
							Else
								If f.fres<>-1 Then
									f.ft.chrg.cpMin=chrg.cpMin+chrg.cpMax-chrg.cpMin
								EndIf
							EndIf
							Find(hWin,f.fr)
						Loop
						'
					Case IDC_BTN_REPLACEALL
						If f.fres=-1 Then
							Find(hWin,f.fr)
						EndIf
						Do While f.fres<>-1
							SendMessage(hWin,WM_COMMAND,(BN_CLICKED Shl 16) Or IDC_BTN_REPLACE,0)
						Loop
						ResetFind
						'
					Case IDC_CHK_MATCHCASE
						f.fr=f.fr Xor FR_MATCHCASE
						ResetFind
						'
					Case IDC_CHK_WHOLEWORD
						f.fr=f.fr Xor FR_WHOLEWORD
						ResetFind
						'
					Case IDC_CHK_SKIPCOMMENTS
						f.fskipcommentline=f.fskipcommentline Xor 1
						ResetFind
						'
					Case IDC_CHK_LOGFIND
						f.flogfind=f.flogfind Xor 1
						EnableWindow(GetDlgItem(hWin,IDC_BTN_FINDALL),f.flogfind)
						ResetFind
						'
					Case IDC_RBN_ALL
						f.fdir=0
						ResetFind
						'
					Case IDC_RBN_DOWN
						f.fdir=1
						ResetFind
						'
					Case IDC_RBN_UP
						f.fdir=2
						ResetFind
						'
					Case IDC_RBN_PROCEDURE
						f.fsearch=0
						ResetFind
						'
					Case IDC_RBN_MODULE
						f.fsearch=1
						ResetFind
						'
					Case IDC_RBN_FILES
						f.fsearch=2
						ResetFind
						'
					Case IDC_RBN_PROJECTFILES
						f.fsearch=3
						ResetFind
						'
					Case IDC_RBN_SELECTION
						f.fsearch=4
						ResetFind
						'
				End Select
				'
			ElseIf Event=CBN_EDITCHANGE Then
				SendDlgItemMessage(hWin,id,WM_GETTEXT,255,Cast(LPARAM,@f.findbuff))
				SendDlgItemMessage(hWin,IDC_REPLACETEXT,WM_GETTEXT,255,Cast(LPARAM,@f.replacebuff))
				ResetFind
				'
			ElseIf Event=CBN_SELCHANGE Then
				id=SendDlgItemMessage(hWin,id,CB_GETCURSEL,0,0)
				SendDlgItemMessage(hWin,IDC_FINDTEXT,CB_SETCURSEL,id,0)
				SendDlgItemMessage(hWin,IDC_FINDTEXT,WM_GETTEXT,255,Cast(LPARAM,@f.findbuff))
				SendDlgItemMessage(hWin,IDC_REPLACETEXT,WM_GETTEXT,255,Cast(LPARAM,@f.replacebuff))
				ResetFind
				'
			ElseIf Event=EN_CHANGE Then
				' Update text buffers
				SendDlgItemMessage(hWin,IDC_FINDTEXT,WM_GETTEXT,255,Cast(LPARAM,@f.findbuff))
				SendDlgItemMessage(hWin,IDC_REPLACETEXT,WM_GETTEXT,255,Cast(LPARAM,@f.replacebuff))
				ResetFind
			EndIf
			'
		Case WM_CLOSE
			DestroyWindow(hWin)
			SetFocus(ah.hred)
			'
		Case WM_DESTROY
			hCtl=GetDlgItem(hWin,IDC_FINDTEXT)
			For id=0 To 8
				SendMessage(hCtl,CB_GETLBTEXT,id,Cast(LPARAM,@FindHistory(id)))
			Next
			GetWindowRect(hWin,@rect)
			wpos.ptfind.x=rect.left
			wpos.ptfind.y=rect.top
			ah.hfind=0
			findvisible=0
			'
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function
