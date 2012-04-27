
Function StreamIn(ByVal hFile As HANDLE,ByVal pBuffer As ZString Ptr,ByVal NumBytes As Long,ByVal pBytesRead As Long Ptr) As Boolean

	Return ReadFile(hFile,pBuffer,NumBytes,pBytesRead,0) Xor 1

End Function

Function StreamOut(ByVal hFile As HANDLE,ByVal pBuffer As ZString Ptr,ByVal NumBytes As Long,ByVal pBytesWritten As Long Ptr) As Boolean

	Return WriteFile(hFile,pBuffer,NumBytes,pBytesWritten,0) Xor 1

End Function

Function GetFileMem(ByVal sFile As String) As HGLOBAL
	Dim tci As TCITEM
	Dim lpTABMEM As TABMEM Ptr
	Dim i As Integer
	Dim nlen As Integer
	Dim hMem As HGLOBAL
	Dim hMem1 As HGLOBAL
	Dim hFile As HANDLE
	Dim bread As Integer
	Dim hEdit As HWND

	tci.mask=TCIF_PARAM
	i=0
	Do While TRUE
		If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(Integer,@tci)) Then
			lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
			If lstrcmpi(@sFile,lpTABMEM->filename)=0 Then
				hEdit=lpTABMEM->hedit
				Exit Do
			EndIf
		Else
			Exit Do
		EndIf
		i=i+1
	Loop
	If hEdit Then
		nlen=SendMessage(hEdit,WM_GETTEXTLENGTH,0,0)+1
		hMem=MyGlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,nlen+1)
		SendMessage(hEdit,WM_GETTEXT,nlen,Cast(Integer,hMem))
	Else
		hFile=CreateFile(@sFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
		If hFile<>INVALID_HANDLE_VALUE Then
			nlen=GetFileSize(hFile,NULL)+1
			hMem=MyGlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,nlen+2)
			ReadFile(hFile,hMem,nlen,@bread,NULL)
			CloseHandle(hFile)
			If Peek(WORD,hMem)=&HFEFF Then
				' Unicode
				hMem1=MyGlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,nlen+1)
				WideCharToMultiByte(CP_ACP,0,hMem,-1,hMem1,nlen,NULL,NULL)
				GlobalFree(hMem)
				Return hMem1
			EndIf
		EndIf
	EndIf
	Return hMem

End Function

Function ParseFile(ByVal hWin As HWND,ByVal hEdit As HWND,ByVal sFile As String) As Integer
	Dim nlen As Integer
	Dim hMem As HGLOBAL
	Dim hMem1 As HGLOBAL
	Dim fParse As Boolean
	Dim nInx As Integer
	Dim hFile As HANDLE
	Dim bread As Integer
	Dim chrg As CHARRANGE

	fParse=FALSE
	If fProject Then
		nInx=IsProjectFile(sFile)
		If nInx Then
			fParse=TRUE
		EndIf
	Else
		nInx=Cast(Integer,hEdit)
		fParse=TRUE
	EndIf
	If fParse Then
		If hEdit Then
			nlen=SendMessage(hEdit,WM_GETTEXTLENGTH,0,0)+1
			hMem=MyGlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,nlen+1)
			SendMessage(hEdit,WM_GETTEXT,nlen,Cast(Integer,hMem))
			SetWindowLong(hEdit,GWL_USERDATA,0)
		Else
			hFile=CreateFile(sFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
			If hFile<>INVALID_HANDLE_VALUE Then
				nlen=GetFileSize(hFile,NULL)+1
				hMem=MyGlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,nlen+1)
				ReadFile(hFile,hMem,nlen,@bread,NULL)
				CloseHandle(hFile)
				If Peek(WORD,hMem)=&HFEFF Then
					' Unicode
					hMem1=MyGlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,nlen+1)
					WideCharToMultiByte(CP_ACP,0,hMem,-1,hMem1,nlen,NULL,NULL)
					GlobalFree(hMem)
					hMem=hMem1
				EndIf
			EndIf
		EndIf
		If hMem Then
			SendMessage(ah.hpr,PRM_DELPROPERTY,nInx,0)
			SendMessage(ah.hpr,PRM_PARSEFILE,nInx,Cast(Integer,hMem))
			GlobalFree(hMem)
			Return 1
		EndIf
	ElseIf hEdit Then
		SetWindowLong(hEdit,GWL_USERDATA,0)
	EndIf
	Return 0

End Function

Sub ReadTextFile(ByVal hWin As HWND,ByVal hFile As HANDLE,ByVal lpFilename As ZString Ptr)
	Dim editstream As EDITSTREAM
	Dim szItem As ZString*260
	
	SendMessage(hWin,WM_SETTEXT,0,Cast(Integer,StrPtr("")))
	editstream.dwCookie=Cast(Integer,hFile)
	editstream.pfnCallback=Cast(Any Ptr,@StreamIn)
	SendMessage(hWin,EM_STREAMIN,SF_TEXT,Cast(Integer,@editstream))
	nLastSize=SendMessage(hWin,WM_GETTEXTLENGTH,0,0)+1
	SendMessage(hWin,EM_SETMODIFY,FALSE,0)
	SendMessage(hWin,REM_SETCHANGEDSTATE,FALSE,0)
	lstrcpy(@szItem,lpFilename)
	If FileType(szItem)=1 Then
		' Set comment block definition
		SendMessage(hWin,REM_SETCOMMENTBLOCKS,Cast(Integer,StrPtr("/'")),Cast(Integer,StrPtr("'/")))
		' Set blocks
		SendMessage(hWin,REM_SETBLOCKS,0,0)
		UpdateAllTabs(3)
		If fProject<>FALSE And Len(ad.resexport) Then
			buff=MakeProjectFileName(ad.resexport)
			If lstrcmpi(@buff,lpFileName)=0 Then
				SetWindowLong(hWin,GWL_STYLE,GetWindowLong(hWin,GWL_STYLE) Or STYLE_READONLY)
			EndIf
		EndIf
	EndIf

End Sub

Sub ReadTheFile(ByVal hWin As HWND,ByVal lpFile As ZString Ptr)
	Dim hFile As HANDLE
	Dim nSize As Integer
	Dim dwRead As Integer
	Dim hMem As HGLOBAL

	hFile=CreateFile(lpFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
	If hFile<>INVALID_HANDLE_VALUE Then
		If hWin=ah.hres Then
			nSize=GetFileSize(hFile,NULL)
			hMem=MyGlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,nSize+1)
			GlobalLock(hMem)
			ReadFile(hFile,hMem,nSize,@dwRead,NULL)
			CloseHandle(hFile)
			SendMessage(ah.hraresed,PRO_OPEN,Cast(Integer,lpFile),Cast(Integer,hMem))
		Else
			ReadTextFile(hWin,hFile,lpFile)
			'nLastLine=0
			CloseHandle(hFile)
		EndIf
	EndIf

End Sub

Sub BackupFile(ByVal szFileName As String,ByVal nBackup As Integer)
	Dim szBackup As ZString*260
	Dim szFile As ZString*260
	Dim szN As ZString*32
	Dim x As Integer

	szFile=GetFileName(szFileName,TRUE)
	If nBackup=1 Then
		szN="(1)"
		x=InStr(szFile,".")
		If x Then
			szFile=Left(szFile,x-1) & szN & Mid(szFile,x)
		Else
			szFile=szFile & szN
		EndIf
	Else
		x=InStr(szFile,"(" & Str(nBackup-1) & ")")
		If x Then
			szFile=Left(szFile,x) & Str(nBackup) & Mid(szFile,x+2)
		EndIf
	EndIf
	szBackup=ad.ProjectPath & "\Bak\" & szFile
	If nBackup<edtopt.backup Then
		If GetFileAttributes(@szBackup)<>-1 Then
			' File exist
			BackupFile(szBackup,nBackup+1)
		EndIf
	EndIf
	CopyFile(@szFileName,@szBackup,FALSE)

End Sub

Sub WriteTheFile(ByVal hWin As HWND,ByVal szFileName As String)
	Dim editstream As EDITSTREAM
	Dim hFile As HANDLE
	Dim hMem As HGLOBAL
	Dim nSize As Integer
	Dim tpe As Integer
	Dim hREd As HWND
	Dim tci As TCITEM
	Dim lpTABMEM As TABMEM Ptr
	Dim i As Integer

	If fProject=TRUE And edtopt.backup<>0 Then
		BackupFile(szFileName,1)
	EndIf
	fChangeNotification=10
	hFile=CreateFile(szFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0)
	If hFile<>INVALID_HANDLE_VALUE Then
		If hWin=ah.hres Then
			hMem=MyGlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,256*1024)
			SendMessage(ah.hraresed,PRO_EXPORT,0,Cast(Integer,hMem))
			nSize=Len(*Cast(ZString Ptr,hMem))
			WriteFile(hFile,hMem,nSize,@nSize,NULL)
			CloseHandle(hFile)
			hFile=CreateFile(szFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
			tci.mask=TCIF_PARAM
			i=0
			Do While TRUE
				If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(LPARAM,@tci)) Then
					lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
					If hWin=lpTABMEM->hedit Then
						GetFileTime(hFile,NULL,NULL,@lpTABMEM->ft)
						Exit Do
					EndIf
				Else
					Exit Do
				EndIf
				i=i+1
			Loop
			CloseHandle(hFile)
			SendMessage(ah.hraresed,PRO_SETMODIFY,FALSE,0)
			GlobalFree(hMem)
			If fProject<>FALSE And Len(ad.resexport)>0 Then
				SendMessage(ah.hraresed,PRO_SETEXPORT,(0 Shl 16)+nmeexp.nType,Cast(LPARAM,@ad.resexport))
				SendMessage(ah.hraresed,PRO_EXPORTNAMES,1,Cast(Integer,ah.hout))
				SendMessage(ah.hraresed,PRO_SETEXPORT,(nmeexp.nOutput Shl 16)+nmeexp.nType,Cast(LPARAM,@nmeexp.szFileName))
				buff=MakeProjectFileName(ad.resexport)
				If IsProjectFile(buff) Then
					ParseFile(ah.hwnd,0,buff)
					SendMessage(ah.hpr,PRM_REFRESHLIST,0,0)
				EndIf
				hREd=IsFileOpen(ah.hwnd,buff,FALSE)
				If hREd Then
					hFile=CreateFile(buff,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
					If hFile<>INVALID_HANDLE_VALUE Then
						ReadTextFile(hREd,hFile,buff)
						CloseHandle(hFile)
						nLastLine=0
					EndIf
				EndIf
			Else
				If nmeexp.fAuto Then
					SendMessage(ah.hraresed,PRO_EXPORTNAMES,1,Cast(Integer,ah.hout))
				EndIf
			EndIf
		Else
			tpe=FileType(szFileName)
			editstream.dwCookie=Cast(Integer,hFile)
			editstream.pfnCallback=Cast(Any Ptr,@StreamOut)
			SendMessage(hWin,EM_STREAMOUT,SF_TEXT,Cast(Integer,@editstream))
			CloseHandle(hFile)
			hFile=CreateFile(szFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
			tci.mask=TCIF_PARAM
			i=0
			Do While TRUE
				If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(LPARAM,@tci)) Then
					lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
					If hWin=lpTABMEM->hedit Then
						GetFileTime(hFile,NULL,NULL,@lpTABMEM->ft)
						Exit Do
					EndIf
				Else
					Exit Do
				EndIf
				i=i+1
			Loop
			CloseHandle(hFile)
			If tpe=1 Then
				If GetWindowLong(hWin,GWL_ID)<>IDC_HEXED Then
					SetWindowLong(hWin,GWL_ID,IDC_CODEED)
				EndIf
				UpdateAllTabs(3)
			EndIf
		EndIf
		SendMessage(hWin,EM_SETMODIFY,FALSE,0)
		If GetWindowLong(hWin,GWL_ID)<>IDC_HEXED Then
			SendMessage(hWin,REM_SETCHANGEDSTATE,TRUE,0)
		EndIf
		CallAddins(ah.hwnd,AIM_FILESAVED,Cast(WPARAM,hWin),Cast(LPARAM,szFileName),HOOK_FILESAVED)
	EndIf

End Sub

Sub SaveTempFile(ByVal hWin As HWND,ByVal szFileName As String)
	Dim editstream As EDITSTREAM
	Dim hFile As HANDLE

	If hWin<>ah.hres Then
		hFile=CreateFile(szFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0)
		If hFile<>INVALID_HANDLE_VALUE Then
			editstream.dwCookie=Cast(Integer,hFile)
			editstream.pfnCallback=Cast(Any Ptr,@StreamOut)
			SendMessage(hWin,EM_STREAMOUT,SF_TEXT,Cast(Integer,@editstream))
		EndIf
		CloseHandle(hFile)
	EndIf

End Sub

Function IsFileOpen(ByVal hWin As HWND,ByVal fn As String,ByVal fShow As Boolean) As HWND
	Dim tci As TCITEM
	Dim hOld As HWND
	Dim lpTABMEM As TABMEM Ptr
	Dim i As Integer

	tci.mask=TCIF_PARAM
	i=0
	Do While TRUE
		If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(Integer,@tci)) Then
			lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
			If lstrcmpi(fn,lpTABMEM->filename)=0 Then
				If fShow Then
					SelectTab(ah.hwnd,lpTABMEM->hedit,0)
					SetFocus(ah.hred)
				EndIf
				Return lpTABMEM->hedit
			EndIf
		Else
			Exit Do
		EndIf
		i=i+1
	Loop
	Return 0

End Function
