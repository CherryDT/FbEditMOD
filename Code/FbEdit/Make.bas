
Sub GetMakeOption()
	Dim nInx As Integer
	Dim sText As ZString*260

	SendMessage(ah.hcbobuild,CB_RESETCONTENT,0,0)
	If fProject Then
		' Get make option from project
		nInx=1
		While GetPrivateProfileString(StrPtr("Make"),Str(nInx),@szNULL,@buff,SizeOf(ad.smake),@ad.ProjectFile)
			If Len(buff) Then
				buff=Left(buff,InStr(buff,",")-1)
				SendMessage(ah.hcbobuild,CB_ADDSTRING,0,Cast(Integer,@buff))
			EndIf
			nInx=nInx+1
		Wend
		nInx=GetPrivateProfileInt(StrPtr("Make"),StrPtr("Current"),1,@ad.ProjectFile)
		SendMessage(ah.hcbobuild,CB_SETCURSEL,nInx-1,0)
		GetPrivateProfileString(StrPtr("Make"),Str(nInx),@szNULL,@ad.smake,SizeOf(ad.smake),@ad.ProjectFile)
		If Len(ad.smake) Then
			nInx=InStr(ad.smake,",")
			sText=Left(ad.smake,nInx-1)
			SendMessage(ah.hsbr,SB_SETTEXT,2,Cast(Integer,@sText))
			ad.smake=Mid(ad.smake,nInx+1)
		EndIf
		GetPrivateProfileString(StrPtr("Make"),StrPtr("Module"),StrPtr("Module Build,fbc -c"),@ad.smakemodule,SizeOf(ad.smakemodule),@ad.ProjectFile)
		If Len(ad.smakemodule) Then
			nInx=InStr(ad.smakemodule,",")
			ad.smakemodule=Mid(ad.smakemodule,nInx+1)
		EndIf
		fRecompile=GetPrivateProfileInt(StrPtr("Make"),StrPtr("Recompile"),0,@ad.ProjectFile)
		GetPrivateProfileString(StrPtr("Make"),StrPtr("Output"),@szNULL,@ad.smakeoutput,SizeOf(ad.smakeoutput),@ad.ProjectFile)
		GetPrivateProfileString(StrPtr("Make"),StrPtr("Run"),@szNULL,@ad.smakerun,SizeOf(ad.smakerun),@ad.ProjectFile)
		GetPrivateProfileString(StrPtr("Make"),StrPtr("Delete"),@szNULL,@ProjectDeleteFiles,SizeOf(ProjectDeleteFiles),@ad.ProjectFile)
	Else
		' Get make option from ini
		nInx=1
		While GetPrivateProfileString(StrPtr("Make"),Str(nInx),@szNULL,@buff,SizeOf(ad.smake),@ad.IniFile)
			If Len(buff) Then
				buff=Left(buff,InStr(buff,",")-1)
				SendMessage(ah.hcbobuild,CB_ADDSTRING,0,Cast(Integer,@buff))
			EndIf
			nInx=nInx+1
		Wend
		nInx=GetPrivateProfileInt(StrPtr("Make"),StrPtr("Current"),1,@ad.IniFile)
		SendMessage(ah.hcbobuild,CB_SETCURSEL,nInx-1,0)
		GetPrivateProfileString(StrPtr("Make"),Str(nInx),@szNULL,@ad.smake,SizeOf(ad.smake),@ad.IniFile)
		If Len(ad.smake) Then
			nInx=InStr(ad.smake,",")
			sText=Left(ad.smake,nInx-1)
			SendMessage(ah.hsbr,SB_SETTEXT,2,Cast(Integer,@sText))
			ad.smake=Mid(ad.smake,nInx+1)
		EndIf
		GetPrivateProfileString(StrPtr("Make"),StrPtr("Module"),StrPtr("Module Build,fbc -c"),@ad.smakemodule,SizeOf(ad.smakemodule),@ad.IniFile)
		If Len(ad.smakemodule) Then
			nInx=InStr(ad.smakemodule,",")
			ad.smakemodule=Mid(ad.smakemodule,nInx+1)
		EndIf
		fRecompile=0
		ad.smakeoutput=""
		ad.smakerun=""
		ProjectDeleteFiles=""
	EndIf
	If Len(ad.fbcPath)>0 And Mid(ad.smake,2,2)<>":\" And Left(ad.smake,1)<>"$" Then
		ad.smake=ad.fbcPath & "\" & ad.smake
	EndIf
	If Len(ad.fbcPath)>0 And Mid(ad.smakemodule,2,2)<>":\" And Left(ad.smakemodule,1)<>"$" Then
		ad.smakemodule=ad.fbcPath & "\" & ad.smakemodule
	EndIf
	If Left(ad.smake,1)="$" Then
		ad.smake=Mid(ad.smake,2)
	EndIf
	If Left(ad.smakemodule,1)="$" Then
		ad.smakemodule=Mid(ad.smakemodule,2)
	EndIf

End Sub

Type Make
	hThread	As HANDLE
	hrd		As HANDLE
	hwr		As HANDLE
	pInfo		As PROCESS_INFORMATION
	uExit		As Integer
End Type

Dim Shared makeinf As Make

Function MakeThreadProc(ByVal Param As ZString Ptr) As Integer
	Dim sat As SECURITY_ATTRIBUTES
	Dim startupinfo As STARTUPINFO
	Dim lret As Integer
	Dim i As Integer
	Dim buff As ZString*MAX_PATH

	buff=szQuickRun
	sat.nLength=SizeOf(SECURITY_ATTRIBUTES)
	sat.lpSecurityDescriptor=NULL
	sat.bInheritHandle=TRUE
	makeinf.uExit=10
	If CreatePipe(@makeinf.hrd,@makeinf.hwr,@sat,NULL)=NULL Then
		' CreatePipe failed
		MessageBox(NULL,StrPtr("CreatePipe failed"),@szAppName,MB_OK Or MB_ICONERROR)
	Else
		startupinfo.cb=SizeOf(STARTUPINFO)
		GetStartupInfo(@startupinfo)
		startupinfo.hStdOutput=makeinf.hwr
		startupinfo.hStdError=makeinf.hwr
		' Create process
		startupinfo.dwFlags=STARTF_USESHOWWINDOW
		startupinfo.wShowWindow=SW_SHOWNORMAL
		If CreateProcess(NULL,@buff,NULL,NULL,FALSE,NULL,NULL,NULL,@startupinfo,@makeinf.pInfo)=0 Then
			' CreateProcess failed
			CloseHandle(makeinf.hrd)
			CloseHandle(makeinf.hwr)
			MessageBox(NULL,StrPtr("CreateProcess failed"),@szAppName,MB_OK Or MB_ICONERROR)
		Else
			WaitForSingleObject(makeinf.pInfo.hProcess,INFINITE)
			GetExitCodeProcess(makeinf.pInfo.hProcess,@makeinf.uExit)
			CloseHandle(makeinf.hwr)
			CloseHandle(makeinf.hrd)
			CloseHandle(makeinf.pInfo.hThread)
			makeinf.pInfo.hThread=0
			CloseHandle(makeinf.pInfo.hProcess)
			makeinf.pInfo.hProcess=0
		EndIf
	EndIf
	Do While i<1000
		lret=DeleteFile(@buff)
		If lret Then
			Exit Do
		EndIf
		i+=1
	Loop
	If lret=0 Then
		lret=GetLastError
		MessageBox(ah.hwnd,"Deleting " & buff & " failed! Error: " & Str(lret),"Quick run",MB_OK Or MB_ICONERROR)
	EndIf
	makeinf.hThread=0
	Return makeinf.uExit

End Function

Sub KillQuickRun()
	Dim msg As MSG

	If makeinf.pInfo.hProcess Then
		TerminateProcess(makeinf.pInfo.hProcess,0)
		While makeinf.hThread
			GetMessage(@msg,NULL,0,0)
			If TranslateAccelerator(ah.hwnd,ah.haccel,@msg)=0 Then
				If IsDialogMessage(ah.hfind,@msg)=0 Then
					If IsDialogMessage(ah.hrareseddlg,@msg)=0 Then
						TranslateMessage(@msg)
						DispatchMessage(@msg)
					EndIf
				EndIf
			EndIf
		Wend
		TextToOutput("Quick run Terminated")
	EndIf

End Sub

Function MakeRun(ByVal sFile As String,ByVal fDebug As Boolean) As Integer
	Dim fval As ZString Ptr

	GetFullPathName(@sFile,260,@buff,@fval)
	buff=!"\"" & RemoveFileExt(buff) & ".exe" & !"\""
	If fDebug Then
		buff=ad.smakerundebug & " " & buff
	EndIf
	If Len(ad.smakerun) Then
		buff=buff & " " & ad.smakerun
	EndIf
	If fRunCmd<>0 And fDebug=0 Then
		buff="/k " & buff
		ShellExecute(ah.hwnd,NULL,"cmd.exe",@buff,NULL,SW_SHOWNORMAL)
	Else
		MakeRun=WinExec(@buff,SW_SHOWNORMAL)
	EndIf

End Function

Function MakeProc(ByVal Param As Integer) As Integer
	Dim sat As SECURITY_ATTRIBUTES
	Dim startupinfo As STARTUPINFO
	Dim pinfo As PROCESS_INFORMATION
	Dim chrg As CHARRANGE
	Dim hrd As HANDLE
	Dim hwr As HANDLE
	Dim bytesRead As Integer
	Dim lret As Integer
	Dim buffer As ZString*4096
	Dim rd As ZString*32

	chrg.cpMin=-1
	chrg.cpMax=-1
	SendMessage(ah.hout,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
	sat.nLength=SizeOf(SECURITY_ATTRIBUTES)
	sat.lpSecurityDescriptor=NULL
	sat.bInheritHandle=TRUE
	lret=CreatePipe(@hrd,@hwr,@sat,NULL)
	If lret=0 Then
		' CreatePipe failed
		SetCursor(LoadCursor(0,IDC_ARROW))
		MessageBox(ah.hwnd,StrPtr("CreatePipeError"),@szAppName,MB_ICONERROR+MB_OK)
	Else
		startupinfo.cb=SizeOf(STARTUPINFO)
		GetStartupInfo(@startupinfo)
		startupinfo.hStdOutput=hwr
		startupinfo.hStdError=hwr
		startupinfo.dwFlags=STARTF_USESHOWWINDOW+STARTF_USESTDHANDLES
		startupinfo.wShowWindow=SW_HIDE
		' Create process
		lret=CreateProcess(NULL,@buff,NULL,NULL,TRUE,NULL,NULL,NULL,@startupinfo,@pinfo)
		If lret=0 Then
			' CreateProcess failed
			CloseHandle(hrd)
			CloseHandle(hwr)
			SetCursor(LoadCursor(0,IDC_ARROW))
			MessageBox(ah.hwnd,@buff,@szAppName,MB_ICONERROR+MB_OK)
		Else
			CloseHandle(hwr)
			SetFocus(ah.hout)
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(LPARAM,@buff))
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(LPARAM,@CR))
			lret=SendMessage(ah.hout,EM_GETLINECOUNT,0,0)-1
			SendMessage(ah.hout,REM_SETBOOKMARK,lret,8)
			SendMessage(ah.hout,REM_SETBMID,lret,0)
			SendMessage(ah.hout,REM_REPAINT,0,TRUE)
			buffer=""
			While TRUE
				lret=ReadFile(hrd,@rd,1,@bytesRead,NULL)
				If lret=0 Then
					Exit While
				ElseIf Asc(rd)=10 Then
					SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(LPARAM,@buffer))
					buffer=""
				Else
					buffer=buffer & rd
				EndIf
			Wend
			CloseHandle(pinfo.hProcess)
			CloseHandle(pinfo.hThread)
			CloseHandle(hrd)
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(LPARAM,@buffer))
			Return 0
		EndIf
	EndIf
	Return -1
	
End Function

Function GetErrLine(ByVal buff As String,ByVal fQuickRun As Boolean) As Integer
	Dim As Integer x,y
	Dim sItem As ZString*260
	Dim buffer As ZString*4096

	buffer=buff
	x=2
	While x
		x=InStr(x,buffer,"(")
		y=InStr(x,buffer,")")
		If y-x>1 And y-x<7 Then
			y=Val(Mid(buffer,x+1))-1
			If fQuickRun Then
				buffer=ad.filename
			Else
				buffer[x-1]=NULL
				If fProject Then
					If Asc(buffer,2)<>Asc(":") Then
						buffer=ad.ProjectPath & "\" & buffer
					EndIf
				Else
					If Asc(buffer,2)<>Asc(":") Then
						GetCurrentDirectory(260,@sItem)
						buffer=sItem & "\" & buffer
					EndIf
				EndIf
			EndIf
			For x=1 To Len(buffer)
				If Asc(buffer,x)=Asc("/") Then
					buffer=Left(buffer,x-1) & "\" & Mid(buffer,x+1)
				EndIf
			Next x
			If fQuickRun=FALSE Then
				GetFullPathName(@buffer,SizeOf(buffer),@buffer,Cast(LPTSTR Ptr,@x))
				OpenTheFile(buffer,FALSE)
			EndIf
			Return y
		ElseIf x Then
			x=x+1
		EndIf
	Wend
	Return -1

End Function

Sub DeleteFiles(ByVal sFile As String)
	Dim wfd As WIN32_FIND_DATA
	Dim hwfd As HANDLE
	Dim sPath As String
	Dim i As Integer
	Dim sTmp As String

	i=InStrRev(sFile,"\")
	If i Then
		sPath=Left(sFile,i)
	EndIf
	hwfd=FindFirstFile(sFile,@wfd)
	If hwfd<>INVALID_HANDLE_VALUE Then
		While TRUE
			If (wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY)=0 Then
				sTmp=ad.ProjectPath & "\" & sPath & wfd.cFileName
				If DeleteFile(sTmp) Then
					sTmp="Deleted: " & sTmp
					TextToOutput(sTmp)
				EndIf
			EndIf
			If FindNextFile(hwfd,@wfd)=FALSE Then
				Exit While
			EndIf
		Wend
		FindClose(hwfd)
	EndIf

End Sub

Function Make(ByVal sMakeOpt As String,ByVal sFile As String,ByVal fModule As Boolean,ByVal fNoClear As Boolean,ByVal fQuickRun As Boolean) As Integer
	Dim fExitCode As Integer
	Dim lret As Integer
	Dim nMiss As Integer
	Dim buffer As ZString*4096
	Dim sItem As ZString*260
	Dim nLine As Integer
	Dim cPos As Integer
	Dim nErr As Integer
	Dim As Integer x,y
	Dim chrg As CHARRANGE
	Dim msg As MSG
	Dim bm As Integer
	Dim sTmp As String
	Dim sErrFile As String
	Dim nErrLine As Integer

	CallAddins(ah.hwnd,AIM_MAKEBEGIN,Cast(WPARAM,@sFile),Cast(LPARAM,@sMakeOpt),HOOK_MAKEBEGIN)
	nErr=0
	If fNoClear=FALSE Then
		SendMessage(ah.hwnd,IDM_OUTPUT_CLEAR,0,0)
	EndIf
	ShowOutput(TRUE)
	If fProject Then
		SetCurrentDirectory(@ad.ProjectPath)
		If fModule Then
			buff=sMakeOpt & " " & """" & sFile & """"
		Else
			sItem=sFile
			If fQuickRun Then
				sItem=GetFileName(ad.filename,FALSE)
			Else
				x=InStr(sItem,".")
				y=x
				While x
					y=x
					x=InStr(x+1,sItem,".")
				Wend
				If y Then
					sItem[y-1]=NULL
				EndIf
			EndIf
			If fProject Then
				sItem=GetProjectResource
			Else
				sItem=sItem & ".rc"
			EndIf
			If (fProject<>0 And fAddMainFiles<>0) Or fProject=0 Then
				If GetFileAttributes(@sItem)<>-1 Then
					buff=sMakeOpt & " " & """" & sFile & """" & " " & """" & sItem & """"
				Else
					buff=sMakeOpt & " " & """" & sFile & """"
				EndIf
			Else
				buff=sMakeOpt
			EndIf
			If fAddModuleFiles Then
				' Add module oject files
				lret=1001
				nMiss=0
				Do While lret<1256 And nMiss<MAX_MISS
					sItem=String(260,szNULL)
					GetPrivateProfileString(StrPtr("File"),Str(lret),@szNULL,@sItem,SizeOf(sItem),@ad.ProjectFile)
					If Len(sItem) Then
						nMiss=0
						x=InStr(sItem,".")
						y=x
						While x
							y=x
							x=InStr(x+1,sItem,".")
						Wend
						If y Then
							sItem[y-1]=NULL
						EndIf
						If fRecompile=2 Then
							buff=buff & " " & """" & sItem & ".bas" & """"
						Else
							buff=buff & " " & """" & sItem & ".o" & """"
						EndIf
					Else
						nMiss+=1
					EndIf
					lret=lret+1
				Loop
			EndIf
			If Len(ad.smakeoutput)<>0 And fQuickRun=FALSE Then
				buff=buff & " -x """ & ad.smakeoutput & """"
			EndIf
		EndIf
	Else
		buff=sFile
		GetFilePath(buff)
		SetCurrentDirectory(@buff)
		If fModule Then
			buff=sMakeOpt & " " & """" & GetFileName(sFile,TRUE)
			buff=buff & """"
		Else
			If fQuickRun Then
				sItem=GetFileName(ad.filename,FALSE)
			Else
				sItem=GetFileName(sFile,FALSE)
			EndIf
			sItem=sItem & ".rc"
			If GetFileAttributes(@sItem)<>-1 Then
				buff=sMakeOpt & " " & """" & GetFileName(sFile,TRUE)
				buff=buff & """" & " " & """" & sItem
				buff=buff & """"
			Else
				buff=sMakeOpt & " " & """" & GetFileName(sFile,TRUE)
				buff=buff & """"
			EndIf
		EndIf
	EndIf
'	lret=CreateThread(NULL,NULL,@MakeProc,0,NORMAL_PRIORITY_CLASS,@x)
'Nxt:
'	GetExitCodeThread(lret,@x)
'	If x=STILL_ACTIVE Then
'		GetMessage(@msg,NULL,0,0)
'		If msg.message=WM_CHAR Then
'			If msg.wParam=VK_ESCAPE Then
'				TerminateProcess(lret,1234)
'			EndIf
'		EndIf
'		TranslateMessage(@msg)
'		DispatchMessage(@msg)
'		GoTo	Nxt
'	EndIf
	x=MakeProc(0)
	If x<>-1 Then
		SetFocus(ah.hout)
		nLine=SendMessage(ah.hout,EM_GETLINECOUNT,0,0)
		bm=SendMessage(ah.hout,REM_GETBOOKMARK,nLine,0)
		While bm<>8
			nLine-=1
			bm=SendMessage(ah.hout,REM_GETBOOKMARK,nLine,0)
		Wend
		lret=-1
		While TRUE
			cPos=SendMessage(ah.hout,EM_LINEINDEX,nLine,0)
			If lret=cPos Then
				Exit While
			EndIf
			lret=cPos
			x=SendMessage(ah.hout,EM_LINELENGTH,cPos,0)
			buffer=Chr(x And 255) & Chr(x\256)
			x=SendMessage(ah.hout,EM_GETLINE,nLine,Cast(Integer,@buffer))
			buffer[x]=NULL
			If InStr(buffer," : error ") Or InStr(buffer,") error ") Or InStr(buffer,") warning ") Then
				If InStr(buffer,") warning ") Then
					SendMessage(ah.hout,REM_SETBOOKMARK,nLine,6)
				Else
					SendMessage(ah.hout,REM_SETBOOKMARK,nLine,7)
					nErr=nErr+1
					y=GetErrLine(buffer,fQuickRun)
					If y>=0 Then
						If ah.hred<>ah.hres Then
							chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,y,0)
							chrg.cpMax=chrg.cpMin
							SendMessage(ah.hred,EM_EXSETSEL,0,Cast(Integer,@chrg))
							SendMessage(ah.hred,EM_SCROLLCARET,0,0)
							x=SendMessage(ah.hout,REM_GETBMID,nLine,0)
							SendMessage(ah.hred,REM_SETERROR,y,x)
							If nErr=1 Then
								sErrFile=ad.filename
								nErrLine=y
							EndIf
						EndIf
						SetFocus(ah.hred)
					EndIf
				EndIf
			ElseIf InStr(buffer,"No such file: ") Then
				SendMessage(ah.hout,REM_SETBOOKMARK,nLine,7)
				SendMessage(ah.hout,REM_SETBMID,nLine,0)
				nErr=nErr+1
			ElseIf InStr(buffer,"undefined reference to") Then
				SendMessage(ah.hout,REM_SETBOOKMARK,nLine,7)
				SendMessage(ah.hout,REM_SETBMID,nLine,0)
				nErr=nErr+1
			ElseIf InStr(buffer,"cannot open output file") Then
				SendMessage(ah.hout,REM_SETBOOKMARK,nLine,7)
				SendMessage(ah.hout,REM_SETBMID,nLine,0)
				nErr=nErr+1
			ElseIf InStr(buffer,"cannot find") Then
				SendMessage(ah.hout,REM_SETBOOKMARK,nLine,7)
				SendMessage(ah.hout,REM_SETBMID,nLine,0)
				nErr=nErr+1
			EndIf
			nLine=nLine+1
		Wend
		If nErr Then
			sItem=CR & "Build error(s)" & CR
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,@sItem))
			MessageBeep(MB_ICONERROR)
			If Len(sErrFile) Then
				OpenTheFile(sErrFile,FALSE)
				chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,nErrLine,0)
				chrg.cpMax=chrg.cpMin
				SendMessage(ah.hred,EM_EXSETSEL,0,Cast(Integer,@chrg))
				SendMessage(ah.hred,EM_SCROLLCARET,0,0)
			EndIf
		Else
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,@CR))
			If fModule=FALSE Then
				sTmp=ProjectDeleteFiles
				While Len(sTmp)
					lret=InStr(sTmp,";")
					If lret Then
						sFile=Trim(Left(sTmp,lret-1))
						sTmp=Mid(sTmp,lret+1)
					Else
						sFile=Trim(sTmp)
						sTmp=""
					EndIf
					DeleteFiles(sFile)
				Wend
			EndIf
			sItem="Make done" & CR
			SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(Integer,@sItem))
			If ah.hred Then
				SetFocus(ah.hred)
			Else
				SetFocus(ah.hwnd)
			EndIf
		EndIf
	EndIf
	CallAddins(ah.hwnd,AIM_MAKEDONE,Cast(WPARAM,@sFile),Cast(LPARAM,@sMakeOpt),HOOK_MAKEDONE)
	Return nErr

End Function

Function FileCheck(ByVal sPaths As String,ByVal sFiles As String) As HANDLE
	Dim As Integer ipath,ifile,i
	Dim As ZString*MAX_PATH szPath,szFile,szFileName
	Dim hFile As HANDLE

	ifile=1
	While iFile
		i=InStr(iFile,sFiles,";")
		If i=0 Then
			szFile=Mid(sFiles,iFile)
		Else
			szFile=Mid(sFiles,iFile,i-iFile)
			i+=1
		EndIf
		iFile=i
		ipath=1
		While iPath
			i=InStr(iPath,sPaths,";")
			If i=0 Then
				szPath=Mid(sPaths,iPath)
			Else
				szPath=Mid(sPaths,iPath,i-Ipath)
				i+=1
			EndIf
			iPath=i
			szFileName=szPath & szFile
			hFile=CreateFile(@szFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
			If hFile<>INVALID_HANDLE_VALUE Then
				TextToOutput("Checking: " & szFileName)
				Return hFile
			EndIf
		Wend
	Wend
	Return Cast(HANDLE,INVALID_HANDLE_VALUE)

End Function

Sub IsNewer(ByVal sFile As String,ByVal fInc As Integer,ByRef ft1 As FILETIME)
	Dim hFile As HANDLE
	Dim ft As FILETIME
	Dim hMem As HGLOBAL
	Dim hMem1 As HGLOBAL
	Dim hPtr As HGLOBAL
	Dim As Integer i,j
	Dim ms As MEMSEARCH
	Dim sz As ZString*512

	If fInc Then
		hFile=FileCheck(";" & ad.fbcPath & "/inc/",sFile)
	Else
		hFile=FileCheck(";" & ad.fbcPath & "/lib/win32/",sFile & ";" & sFile & ".a;" & sFile & ".dll.a;" & "lib" & sFile & ";lib" & sFile & ".a;" & "lib" & sFile & ".dll.a")
	EndIf
	If hFile<>INVALID_HANDLE_VALUE Then
		GetFileTime(hFile,NULL,NULL,@ft)
		If CompareFileTime(@ft,@ft1)>0 Then
			CloseHandle(hFile)
			ft1=ft
		ElseIf fInc Then
			' Check #Include and #Inclib
			i=GetFileSize(hFile,NULL)
			hMem=MyGlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,i+2)
			ReadFile(hFile,hMem,i,@j,NULL)
			CloseHandle(hFile)
			If Peek(WORD,hMem)=&HFEFF Then
				' Unicode
				hMem1=MyGlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,i+2)
				WideCharToMultiByte(CP_ACP,0,hMem,-1,hMem1,i,NULL,NULL)
				GlobalFree(hMem)
				hMem=hMem1
			EndIf
			SendMessage(ah.hpr,PRM_PREPARSE,TRUE,Cast(LPARAM,hMem))
			hPtr=hMem
			While hPtr
				ms.lpMem=hPtr
				ms.lpFind=StrPtr("#include")
				ms.lpCharTab=ad.lpCharTab
				' Memory search down is faster
				ms.fr=FR_WHOLEWORD Or FR_DOWN
				hPtr=Cast(HGLOBAL,SendMessage(ah.hpr,PRM_MEMSEARCH,0,Cast(LPARAM,@ms)))
				If hPtr Then
					lstrcpyn(@sz,hPtr,500)
					i=InStr(sz,Chr(34))
					sz=Mid(sz,i+1)
					i=InStr(sz,Chr(34))
					sz=Left(sz,i-1)
					IsNewer(sz,TRUE,ft1)
					hPtr+=1
				EndIf
			Wend
			hPtr=hMem
			While hPtr
				ms.lpMem=hPtr
				ms.lpFind=StrPtr("#inclib")
				ms.lpCharTab=ad.lpCharTab
				' Memory search down is faster
				ms.fr=FR_WHOLEWORD Or FR_DOWN
				hPtr=Cast(HGLOBAL,SendMessage(ah.hpr,PRM_MEMSEARCH,0,Cast(LPARAM,@ms)))
				If hPtr Then
					lstrcpyn(@sz,hPtr,500)
					i=InStr(sz,Chr(34))
					sz=Mid(sz,i+1)
					i=InStr(sz,Chr(34))
					sz=Left(sz,i-1)
					IsNewer(sz,FALSE,ft1)
					hPtr+=1
				EndIf
			Wend
			GlobalFree(hMem)
		EndIf
	EndIf
	
End Sub

Function CompileModules(ByVal sMake As String) As Integer
	Dim bm As Integer
	Dim id As Integer
	Dim nLine As Integer
	Dim nMiss As Integer
	Dim sFile As String
	Dim sOFile As String
	Dim hFile As HANDLE
	Dim As FILETIME ft1,ft2

	If edtopt.autosave Then
		bm=SaveAllFiles(ah.hwnd)
	Else
		bm=DialogBoxParam(hInstance,Cast(ZString Ptr,IDD_DLGSAVESELECTION),ah.hwnd,@SaveAllProc,NULL)
	EndIf
	If bm=0 Then
		bm=wpos.fview And VIEW_OUTPUT
		' Clear errors
		UpdateAllTabs(2)
		fBuildErr=0
		If fProject Then
			SendMessage(ah.hwnd,IDM_OUTPUT_CLEAR,0,0)
			id=1001
			nMiss=0
			Do While id<1256 And nMiss<MAX_MISS
				sFile=GetProjectFile(id)
				If sFile<>"" Then
					nMiss=0
					If fCompileIfNewer Then
						sOFile=RemoveFileExt(sFile) & ".o"
						hFile=CreateFile(sOFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL)
						If hFile=INVALID_HANDLE_VALUE Then
							' File does not exist
							fBuildErr=Make(sMake,sFile,TRUE,TRUE,FALSE)
						Else 
							GetFileTime(hFile,NULL,NULL,@ft2)
							CloseHandle(hFile)
							ft1=ft2
							IsNewer(sFile,TRUE,ft1)
							If CompareFileTime(@ft1,@ft2)>0 Then
								fBuildErr=Make(sMake,sFile,TRUE,TRUE,FALSE)
							Else
								nLine=SendMessage(ah.hout,EM_GETLINECOUNT,0,0)
								TextToOutput(sOFile & " is newer than any of the checked files." & CR)
								SendMessage(ah.hout,REM_SETBOOKMARK,nLine,8)
							EndIf
						EndIf
					Else
						fBuildErr=Make(sMake,sFile,TRUE,TRUE,FALSE)
					EndIf
					If fBuildErr Then
						Exit Do
					EndIf
				Else
					nMiss+=1
				EndIf
				id=id+1
			Loop
		Else
			sFile=ad.filename
			fBuildErr=Make(sMake,sFile,TRUE,FALSE,FALSE)
		EndIf
		If fBuildErr=0 And bm=0 Then
			nHideOut=15
		Else
			nHideOut=0
		EndIf
	EndIf
	UpdateAllTabs(4)
	Return fBuildErr

End Function

Function Compile(ByVal sMake As String) As Integer
	Dim bm As Integer
	Dim nMain As Integer
	Dim sFile As String
	Dim lRet As Integer

	If fProject<>0 And fIncVersion<>0 Then
		If ah.hres Then
			lRet=SendMessage(ah.hraresed,PRO_GETMEM,0,0)
			If SendMessage(ah.hraresed,PRO_GETMEM,0,0) Then
				SendMessage(ah.hraresed,PRO_INCVERSION,0,0)
			Else
				sFile=GetProjectResource
				If sFile<>"" Then
					sFile=ad.ProjectPath & "\" & sFile
					OpenTheFile(sFile,FALSE)
					SendMessage(ah.hraresed,PRO_INCVERSION,0,0)
				EndIf
			EndIf
		EndIf
	EndIf
	If edtopt.autosave Then
		bm=SaveAllFiles(ah.hwnd)
	Else
		bm=DialogBoxParam(hInstance,Cast(ZString Ptr,IDD_DLGSAVESELECTION),ah.hwnd,@SaveAllProc,NULL)
	EndIf
	If bm=0 Then
		bm=wpos.fview And VIEW_OUTPUT
		' Clear errors
		UpdateAllTabs(2)
		If fProject Then
			nMain=GetPrivateProfileInt(StrPtr("File"),StrPtr("Main"),1,ad.ProjectFile)
			If fRecompile=1 Then
				If CompileModules(ad.smakemodule)=0 Then
					nHideOut=0
					sFile=GetProjectFile(nMain)
					fBuildErr=Make(sMake,sFile,FALSE,TRUE,FALSE)
				EndIf
			Else
				sFile=GetProjectFile(nMain)
				fBuildErr=Make(sMake,sFile,FALSE,FALSE,FALSE)
			EndIf
		Else
			sFile=ad.filename
			fBuildErr=Make(sMake,sFile,FALSE,FALSE,FALSE)
		EndIf
		If fBuildErr=0 And bm=0 Then
			nHideOut=15
		Else
			nHideOut=0
		EndIf
	Else
		Return 1
	EndIf
	UpdateAllTabs(4)
	Return fBuildErr

End Function
