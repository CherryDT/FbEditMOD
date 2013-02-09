

#Include Once "windowsUR.bi"
#Include Once "win\shellapi.bi"
#Include Once "win\shlwapi.bi"
#Include Once "win\richedit.bi"
#Include Once "win\commdlg.bi"

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAResEd.bi"
#Include Once "Inc\RAProperty.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\CoTxEd.bi"
#Include Once "Inc\CoTxEdOpt.bi"
#Include Once "Inc\Environment.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\GenericOpt.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\IniFile.bi"
#Include Once "Inc\Misc.bi"
#Include Once "Inc\Project.bi"
#Include Once "Inc\SpecHandling.bi"
#Include Once "Inc\TabTool.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\Make.bi"
#Include Once "showvarsUR.bi"


Dim Shared makeinf    As Make
Dim Shared szQuickRun As ZString * MAX_PATH
Dim Shared fBuildErr  As Integer


Sub GetCCLData (ByVal pCCLName As GOD_EntryName Ptr, ByVal pCCLData As GOD_EntryData Ptr)

    ' pCCLName: IN
    ' pCCLData: OUT

    Dim n      As Integer     = Any 
    Dim pBuffB As ZString Ptr = Any
    
    SetZStrEmpty (*pCCLData)
    For n = 1 To GOD_MaxItems
        GetPrivateProfileString @"Make", Str (n), NULL, @buff, GOD_EntrySize, @ad.ProjectFile
        If IsZStrEmpty (buff) Then Exit For
        SplitStr buff, Asc (","), pBuffB
        If buff = *pCCLName Then
            *pCCLData = *pBuffB
            Exit For 
        EndIf
    Next 
    
End Sub

Sub GetCCL (ByVal ModuleID As Integer, ByVal pCCLName As GOD_EntryName Ptr, ByVal pCCLData As GOD_EntryData Ptr)

    ' ModuleID: IN
    ' pCCLName: OUT
    ' pCCLData: OUT
    
    GetPrivateProfileString @"Make", "CCL" + Str (ModuleID), NULL, pCCLName, SizeOf (GOD_EntryName), @ad.ProjectFile				    
    If IsZStrNotEmpty (*pCCLName) Then
        GetCCLData pCCLName, pCCLData
    Else
        SetZStrEmpty (*pCCLData)    
    EndIf
    
End Sub

Sub GetMakeOption ()
	
	Dim i            As Integer     = Any 
    Dim n            As Integer     = Any
    Dim pIniFileSpec As ZString Ptr = Any  
    Dim pBuffB       As ZString Ptr = Any 
    
    UpdateEnvironment     
	SendMessage ah.hcbobuild, CB_RESETCONTENT, 0, 0
	
	If fProject Then
	    pIniFileSpec = @ad.ProjectFile
	Else
	    pIniFileSpec = @ad.IniFile
	EndIf

	For i = 1 To GOD_MaxItems
	    GetPrivateProfileString @"Make", Str (i), NULL, @buff, SizeOf (ad.smake), pIniFileSpec
		If IsZStrNotEmpty (buff) Then
			ReplaceChar1stHit buff, Asc (","), NULL 
			SendMessage ah.hcbobuild, CB_ADDSTRING, 0, Cast (LPARAM, @buff)
		Else
		    Exit For 
		EndIf
	Next 

	i = GetPrivateProfileInt (@"Make", @"Current", 1, pIniFileSpec)
	SendMessage ah.hcbobuild, CB_SETCURSEL, i - 1, 0
	GetPrivateProfileString @"Make", Str (i), NULL, @buff, SizeOf (ad.smake), pIniFileSpec
	If IsZStrNotEmpty (buff) Then
		SplitStr buff, Asc (","), pBuffB
		SendMessage ah.hsbr, SB_SETTEXT, 4, Cast (LPARAM, @buff)
	    ExpandStrByEnviron *pBuffB
	    PathCombine ad.smake, ad.fbcPath, pBuffB
	EndIf

	'GetPrivateProfileString @"Make", @"ModuleSTD", NULL, @buff, SizeOf (ad.smakemodule), pIniFileSpec
    'If n Then
    '	n = InStr (buff, ",")
	'    FixPath buff[n]
	'    PathCombine ad.smakemodule, ad.fbcPath, @buff[n]
	'EndIf
	
	fRecompile = GetPrivateProfileInt (@"Make", @"Recompile", RCM_MANUAL, pIniFileSpec)
	GetPrivateProfileString @"Make", @"Output", NULL, @ad.smakeoutput,     SizeOf (ad.smakeoutput),     pIniFileSpec
	GetPrivateProfileString @"Make", @"Run"   , NULL, @ad.smakerun,        SizeOf (ad.smakerun),        pIniFileSpec
	GetPrivateProfileString @"Make", @"Delete", NULL, @ProjectDeleteFiles, SizeOf (ProjectDeleteFiles), pIniFileSpec
    
End Sub

'Sub GetMakeOption()
'	Dim nInx As Integer
'	Dim sText As ZString*260
'
'	SendMessage(ah.hcbobuild,CB_RESETCONTENT,0,0)
'	If fProject Then
'		' Get make option from project
'		nInx=1
'		While GetPrivateProfileString(StrPtr("Make"),Str(nInx),NULL,@buff,SizeOf(ad.smake),@ad.ProjectFile)
'			If IsZStrNotEmpty (buff) Then
'				buff=Left(buff,InStr(buff,",")-1)
'				SendMessage(ah.hcbobuild,CB_ADDSTRING,0,Cast(Integer,@buff))
'			EndIf
'			nInx=nInx+1
'		Wend
'		nInx=GetPrivateProfileInt(StrPtr("Make"),StrPtr("Current"),1,@ad.ProjectFile)
'		SendMessage(ah.hcbobuild,CB_SETCURSEL,nInx-1,0)
'		GetPrivateProfileString(StrPtr("Make"),Str(nInx),NULL,@ad.smake,SizeOf(ad.smake),@ad.ProjectFile)
'		If IsZStrNotEmpty (ad.smake) Then
'			nInx=InStr(ad.smake,",")
'			sText=Left(ad.smake,nInx-1)
'			SendMessage(ah.hsbr,SB_SETTEXT,4,Cast(Integer,@sText))
'			ad.smake=Mid(ad.smake,nInx+1)
'		EndIf
'		GetPrivateProfileString(StrPtr("Make"),StrPtr("Module"),StrPtr("Module Build,fbc -c"),@ad.smakemodule,SizeOf(ad.smakemodule),@ad.ProjectFile)
'		If IsZStrNotEmpty (ad.smakemodule) Then
'			nInx=InStr(ad.smakemodule,",")
'			ad.smakemodule=Mid(ad.smakemodule,nInx+1)
'		EndIf
'		fRecompile=GetPrivateProfileInt(StrPtr("Make"),StrPtr("Recompile"),0,@ad.ProjectFile)
'		GetPrivateProfileString(StrPtr("Make"),StrPtr("Output"),NULL,@ad.smakeoutput,SizeOf(ad.smakeoutput),@ad.ProjectFile)
'		GetPrivateProfileString(StrPtr("Make"),StrPtr("Run"),NULL,@ad.smakerun,SizeOf(ad.smakerun),@ad.ProjectFile)
'		GetPrivateProfileString(StrPtr("Make"),StrPtr("Delete"),NULL,@ProjectDeleteFiles,SizeOf(ProjectDeleteFiles),@ad.ProjectFile)
'	Else
'		' Get make option from ini
'		nInx=1
'		While GetPrivateProfileString(StrPtr("Make"),Str(nInx),NULL,@buff,SizeOf(ad.smake),@ad.IniFile)
'			If IsZStrNotEmpty (buff) Then
'				buff=Left(buff,InStr(buff,",")-1)
'				SendMessage(ah.hcbobuild,CB_ADDSTRING,0,Cast(Integer,@buff))
'			EndIf
'			nInx=nInx+1
'		Wend
'		nInx=GetPrivateProfileInt(StrPtr("Make"),StrPtr("Current"),1,@ad.IniFile)
'		SendMessage(ah.hcbobuild,CB_SETCURSEL,nInx-1,0)
'		GetPrivateProfileString(StrPtr("Make"),Str(nInx),NULL,@ad.smake,SizeOf(ad.smake),@ad.IniFile)
'		If IsZStrNotEmpty (ad.smake) Then
'			nInx=InStr(ad.smake,",")
'			sText=Left(ad.smake,nInx-1)
'			SendMessage(ah.hsbr,SB_SETTEXT,4,Cast(Integer,@sText))
'			ad.smake=Mid(ad.smake,nInx+1)
'		EndIf
'		GetPrivateProfileString(StrPtr("Make"),StrPtr("Module"),StrPtr("Module Build,fbc -c"),@ad.smakemodule,SizeOf(ad.smakemodule),@ad.IniFile)
'		If IsZStrNotEmpty (ad.smakemodule) Then
'			nInx=InStr(ad.smakemodule,",")
'			ad.smakemodule=Mid(ad.smakemodule,nInx+1)
'		EndIf
'		fRecompile=0
'		SetZStrEmpty (ad.smakeoutput)             ' MOD 26.1.2012 
'		SetZStrEmpty (ad.smakerun)                ' MOD 26.1.2012 
'		SetZStrEmpty (ProjectDeleteFiles)         ' MOD 26.1.2012 
'	EndIf
'	If IsZStrNotEmpty (ad.fbcPath) AndAlso Mid(ad.smake,2,2)<>":\" AndAlso ad.smake[0] <> Asc("$") Then               ' MOD 27.1.2012  ...Left(ad.smake,1)<>"$" Then
'		ad.smake=ad.fbcPath & "\" & ad.smake
'	EndIf
'	If IsZStrNotEmpty (ad.fbcPath) AndAlso Mid(ad.smakemodule,2,2)<>":\" AndAlso ad.smakemodule[0] <> Asc("$") Then   ' MOD 27.1.2012  ...Left(ad.smakemodule,1)<>"$" Then
'		ad.smakemodule=ad.fbcPath & "\" & ad.smakemodule
'	EndIf
'	If ad.smake[0] = Asc("$") Then                ' MOD 27.1.2012    if Left(ad.smake,1)="$" Then
'		ad.smake=Mid(ad.smake,2)
'	EndIf
'	If ad.smakemodule[0] = Asc("$") Then          ' MOD 27.1.2012   if Left(ad.smakemodule,1)="$" Then
'		ad.smakemodule=Mid(ad.smakemodule,2)
'	EndIf
'
'End Sub

Function ProcessQuickRun(ByVal Param As ZString Ptr) As Integer
	Dim sat As SECURITY_ATTRIBUTES
	Dim startupinfo As STARTUPINFO
	Dim lret As Integer
	Dim i As Integer
	Dim buff As ZString*MAX_PATH
    Dim ErrMsg As ZString * 256

	buff=szQuickRun
	sat.nLength=SizeOf(SECURITY_ATTRIBUTES)
	sat.lpSecurityDescriptor=NULL
	sat.bInheritHandle=TRUE
	makeinf.uExit=10
	If CreatePipe(@makeinf.hrd,@makeinf.hwr,@sat,NULL)=NULL Then
		' CreatePipe failed
        FormatMessage FORMAT_MESSAGE_FROM_SYSTEM, NULL, GetLastError, NULL, @ErrMsg, SizeOf (ErrMsg), NULL
		TextToOutput "*** CreatePipe failed ***", MB_ICONERROR
		TextToOutput ErrMsg
		'MessageBox(NULL,StrPtr("CreatePipe failed"),@szAppName,MB_OK Or MB_ICONERROR)
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
            FormatMessage FORMAT_MESSAGE_FROM_SYSTEM, NULL, GetLastError, NULL, @ErrMsg, SizeOf (ErrMsg), NULL
			CloseHandle(makeinf.hrd)
			CloseHandle(makeinf.hwr)
			TextToOutput "*** CreateProcess failed ***", MB_ICONERROR
			TextToOutput "command line: " + buff
			TextToOutput ErrMsg
			'MessageBox NULL, !"CreateProcess failed:\13" + buff, @szAppName, MB_OK Or MB_ICONERROR
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
	Do While i<1000          ' TODO
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

Sub KillQuickRun ()
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

Function MakeRun(Byref sFile As zString,ByVal fDebug As Boolean) As Integer
	
	Dim fval         As ZString Ptr
    Dim DebuggerSpec As ZString * MAX_PATH
    
	GetFullPathName @sFile, MAX_PATH, @buff, @fval
    PathRenameExtension buff, ".exe"
    buff= QUOTE + buff + QUOTE                     ' MOD 22.1.2012
	
	If fDebug Then
	    DebuggerSpec = ad.smakerundebug
	    ExpandStrByEnviron DebuggerSpec
		buff = DebuggerSpec + " " + buff           ' debugger.exe + debuggee
	EndIf
	
	If IsZStrNotEmpty (ad.smakerun) Then
		buff += " " + ad.smakerun                  ' debuggee commandline parameters
	EndIf
	
	If fRunCmd AndAlso fDebug = 0 Then
		buff = "/k " + buff
		TextToOutput !"execute:\13cmd.exe " + buff + !"\13"
		ShellExecute ah.hwnd, NULL, "cmd.exe", @buff, NULL, SW_SHOWNORMAL
	Else
		TextToOutput !"execute:\13" + buff + !"\13"
		MakeRun = WinExec (@buff, SW_SHOWNORMAL)
	EndIf

End Function

Function ProcessBuild(ByVal pCmdLine As ZString Ptr) As Integer

	Dim sat         As SECURITY_ATTRIBUTES
	Dim startupinfo As STARTUPINFO
	Dim pinfo       As PROCESS_INFORMATION
	Dim hrd         As HANDLE
	Dim hwr         As HANDLE
	Dim BytesRead   As DWORD        = Any 
	Dim lret        As Integer      = Any 
	Dim buffer      As ZString * 4096
	Dim ErrMsg      As ZString * 256
	Dim n           As Integer      = Any 
	Dim rd          As UByte        = Any 
    Dim ExitCode    As DWORD 
    
	'SendMessage ah.hout, EM_EXSETSEL, 0, Cast (LPARAM, @Type<CHARRANGE>(-1, -1))
	
	sat.nLength=SizeOf(SECURITY_ATTRIBUTES)
	sat.lpSecurityDescriptor=NULL
	sat.bInheritHandle=TRUE
	lret=CreatePipe(@hrd,@hwr,@sat,NULL)
	If lret=0 Then
		' CreatePipe failed
        FormatMessage FORMAT_MESSAGE_FROM_SYSTEM, NULL, GetLastError, NULL, @ErrMsg, SizeOf (ErrMsg), NULL
		'SetCursor(LoadCursor(0,IDC_ARROW))
		TextToOutput "*** CreatePipe failed ***", MB_ICONERROR
		TextToOutput ErrMsg
		Return CREATE_PIPE_FAILED
		'MessageBox(ah.hwnd,StrPtr("CreatePipeError"),@szAppName,MB_ICONERROR+MB_OK)
	Else
		startupinfo.cb=SizeOf(STARTUPINFO)
		GetStartupInfo(@startupinfo)
		startupinfo.hStdOutput=hwr
		startupinfo.hStdError=hwr
		startupinfo.dwFlags=STARTF_USESHOWWINDOW+STARTF_USESTDHANDLES
		startupinfo.wShowWindow=SW_HIDE
		' Create process
		'SetCursor LoadCursor (NULL, IDC_WAIT)
		lret=CreateProcess(NULL,pCmdLine,NULL,NULL,TRUE,NULL,NULL,NULL,@startupinfo,@pinfo)
		If lret=0 Then
			' CreateProcess failed
            FormatMessage FORMAT_MESSAGE_FROM_SYSTEM, NULL, GetLastError, NULL, @ErrMsg, SizeOf (ErrMsg), NULL
			CloseHandle(hrd)
			CloseHandle(hwr)
			'SetCursor(LoadCursor(0,IDC_ARROW))
			TextToOutput "*** CreateProcess failed ***", MB_ICONERROR
			TextToOutput "command line: " + *pCmdLine
			TextToOutput ErrMsg
            Return CREATE_PROCESS_FAILED			
			'MessageBox ah.hwnd, !"CreateProcess failed:\13" + buff, @szAppName, MB_ICONERROR Or MB_OK
		Else
			CloseHandle(hwr)
			TextToOutput *pCmdLine, BMT_GO, 0
			
			'SetFocus(ah.hout)
			'SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(LPARAM,@buff))
			'SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(LPARAM,@CR))
			'lret=SendMessage(ah.hout,EM_GETLINECOUNT,0,0)-1
			'SendMessage(ah.hout,REM_SETBOOKMARK,lret,BMT_GO)
			'SendMessage(ah.hout,REM_SETBMID,lret,0)
			'SendMessage(ah.hout,REM_REPAINT,0,TRUE)
			
			n = 0
			Do
				lret = ReadFile (hrd, @rd, 1, @BytesRead, NULL)
				Select Case rd
				Case 0, 10       ' LF
					buffer[n] = NULL 
				    TextToOutput @buffer
					n = 0
				    DoEvents NULL	
				Case 13          ' CR (ignore, always added by TextToOutput)
				Case Else
					buffer[n] = rd
					n += 1
				End Select
			Loop While lret

            GetExitCodeProcess pinfo.hProcess, @ExitCode 
			CloseHandle(pinfo.hProcess)
			CloseHandle(pinfo.hThread)
			CloseHandle(hrd)
			Return ExitCode
		EndIf
	EndIf
	
End Function

Function GetErrLine(Byref ErrMsgLine As zString, ByVal fQuickRun As Boolean) As Integer

	Dim CurrPath           As ZString * MAX_PATH
	Dim FileSpec           As ZString * MAX_PATH   
    Dim FileName           As String 
    Dim LineNoStr          As String 
    Dim i                  As Integer = Any 
    Dim SearchExpr(1 To 3) As ZString Ptr => { @"(.+)\(([0-9]+)\) error [0-9]+:", _                ' compiler error
                                               @"(.+)\(([0-9]+)\) warning [0-9]+(\([0-9]+\))?:", _ ' compiler warning
                                               @"(.+):([0-9]+):" _                                 ' linker error
                                             }        
    ' Errormessages:
    ' Linker:
    '	   "C:\path.ext1\file(123).ext2:1002: ErrText"
    ' Compiler:
    '      "C:\path.ext1\file(123).ext2(42) error 41: ErrText"
    '      "C:\path.ext1\file(123).ext2(20) warning 4(1): ErrText"
	
    For i = 1 To 3
    	SearchRegEx 0, ErrMsgLine, SearchExpr(i), 1, FileName , 0         ' get match subexpression 1
    	SearchRegEx 0, ErrMsgLine, SearchExpr(i), 2, LineNoStr, 0         ' get match subexpression 2
    	If Len (FileName) Then
			If fQuickRun = FALSE Then
				If fProject Then
				    PathCombine FileSpec, ad.ProjectPath, StrPtr (FileName)
				Else
					GetCurrentDirectory SizeOf (CurrPath), CurrPath 
					PathCombine FileSpec, CurrPath, StrPtr (FileName)
				EndIf
	            OpenTheFile FileSpec, FOM_STD
			EndIf
    		Return ValInt (LineNoStr) - 1                                 ' zerobased
    	EndIf	
    Next
    
    Return -1

    ' skip drive letter separator, find second ":"
    ' skip reverse ")" from warning level

	'buffer = ErrText  
	'x = InStr (3, buffer, ":") - 1 - 1 - 1            '   ":", ")", zerobasing                                 
	'GetEnclosedStrRev x, buffer, LineNoStr, Asc("("), Asc(")")

    'If x >= 0 Then
	'	If fQuickRun = FALSE Then
	'		buffer[x + 1] = NULL
	'		If fProject Then
	'		    buffer = MakeProjectFileName (buffer)
	'		Else
	'			If buffer[1] <> Asc(":") Then
	'				GetCurrentDirectory SizeOf (sItem), @sItem 
	'				buffer = sItem + "\" + buffer
	'			EndIf
	'		EndIf
    '        OpenTheFile buffer, FOM_STD
	'	EndIf
	'	Return ValInt (LineNoStr) - 1                            ' zerobased
    'Else
	'    Return -1
    'EndIf
	
	
	' ERROR on specs like "test(1).bas"
	'Dim As Integer x,y
	'Dim sItem As ZString*260
	'Dim buffer As ZString*4096
    '
	'buffer=buff
    'x=2
	'While x
	'	x=InStr(x,buffer,"(")
	'	y=InStr(x,buffer,")")
	'	If y-x>1 And y-x<7 Then
	'		y=Val(Mid(buffer,x+1))-1
	'		If fQuickRun Then
	'			buffer=ad.filename
	'		Else
	'			buffer[x+1]=NULL
	'			If fProject Then
	'				If buffer[1] <> Asc(":") Then
	'					buffer=ad.ProjectPath & "\" & buffer
	'				EndIf
	'			Else
	'				If buffer[1] <> Asc(":") Then
	'					GetCurrentDirectory(260,@sItem)
	'					buffer=sItem & "\" & buffer
	'				EndIf
	'			EndIf
	'		EndIf
	'		For x=1 To Len(buffer)
	'			If Asc(buffer,x)=Asc("/") Then
	'				buffer=Left(buffer,x-1) & "\" & Mid(buffer,x+1)
	'			EndIf
	'		Next
	'		If fQuickRun=FALSE Then
	'			GetFullPathName(@buffer,SizeOf(buffer),@buffer,Cast(LPTSTR Ptr,@x))
	'			OpenTheFile(buffer,FOM_STD)
	'		EndIf
	'		Return y
	'	ElseIf x Then
	'		x=x+1
	'	EndIf
	'Wend
	'Return -1

End Function

Sub DeleteFiles(Byref sFile As zString)
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
					TextToOutput "deleted: " + sTmp
				EndIf
			EndIf
			If FindNextFile(hwfd,@wfd)=FALSE Then
				Exit While
			EndIf
		Wend
		FindClose(hwfd)
	EndIf

End Sub

Function MakeBuild(Byref sMakeOpt As zString, ByRef sFile As zString, ByRef CCLName As ZString, ByVal fOnlyThisModule As Boolean,ByVal fNoClear As Boolean,ByVal fQuickRun As Boolean) As Integer
	
	Dim FileID   As Integer            = Any 
	Dim nMiss    As Integer            = Any 
	Dim nLine    As Integer            = Any 
	Dim nErr     As Integer            = Any 
	Dim id       As Integer            = Any
	Dim ExitCode As Integer            = Any 
	Dim y        As Integer            = Any
	Dim i        As Integer            = Any
	Dim bm       As Integer            = Any  
	Dim buffer   As ZString * 4096
	Dim FileName As ZString * MAX_PATH 
	Dim Path     As ZString * MAX_PATH 
    Dim CmdLine  As ZString * 32768

	If IsZStrEmpty (sFile) Then
	    TextToOutput !"no file spec\r", MB_ICONERROR
	    Return 1 
	EndIf

	CallAddins(ah.hwnd,AIM_MAKEBEGIN,Cast(WPARAM,@sFile),Cast(LPARAM,@sMakeOpt),HOOK_MAKEBEGIN)
	nErr = 0
    SetEnviron "BUILD_TYPE=" + CCLName
    SetEnviron "COMPILIN_BNAME=" + *GetFileBaseName (sFile)
    
    If fProject Then                                             ' start pre build batch
        GetPrivateProfileString @"Make", @"PreBuildBatch", NULL, CmdLine, SizeOf (CmdLine), ad.ProjectFile
        If IsZStrNotEmpty (CmdLine) Then
            ExitCode = ProcessBuild (CmdLine)
            If ExitCode Then
                TextToOutput "exit code: " + Str (ExitCode), MB_ICONERROR  
                nErr = 1 
                GoTo Exit_MakeBuild
            EndIf
        EndIf
    EndIf	
	
	If fProject Then                                             ' build command line
		SetCurrentDirectory @ad.ProjectPath
		If fOnlyThisModule = TRUE Then
		    CmdLine = sMakeOpt + " """ + sFile + """"
		Else 
			CmdLine = sMakeOpt
			If fAddMainFiles Then
        		CmdLine += " """ + sFile + """"
        		If fQuickRun Then
    				FileName = ad.filename                           
    			    PathRenameExtension FileName, ".rc"
    			Else
    				FileName = GetProjectMainResource ()
    			EndIf
    			If FileExists (FileName) Then
					CmdLine +=  " """ & FileName & """"
				EndIf
			EndIf
			If fAddModuleFiles Then
				nMiss=0
				For FileID = 1001 To 1256
					GetPrivateProfileString @"File", Str (FileID), NULL, @FileName, SizeOf (FileName), @ad.ProjectFile
					If IsZStrNotEmpty (FileName) Then
						nMiss = 0
						If fRecompile <> RCM_INBUILD Then PathRenameExtension FileName, ".o"
						CmdLine += " """ + FileName + """"
					Else
               	        If nMiss > MAX_MISS Then Exit For
						nMiss += 1
					EndIf
				Next 
			EndIf
			If IsZStrNotEmpty (ad.smakeoutput) AndAlso fQuickRun = FALSE Then
				CmdLine += " -x """ + ad.smakeoutput + """"
			EndIf
		EndIf
	Else
		Path = sFile
		PathRemoveFileSpec @Path
		SetCurrentDirectory @Path
		
		CmdLine = sMakeOpt + " """ + *GetFileName (sFile) + """"           
		If fOnlyThisModule = FALSE Then                       ' add resource only if building main
			If fQuickRun Then
				FileName = ad.filename         
			Else
				FileName = sFile       
			EndIf
			PathRenameExtension FileName, ".rc"
		    If FileExists (FileName) Then
				CmdLine += " """ + FileName + """"
			EndIf
		EndIf
	EndIf
    
	ExitCode = ProcessBuild (@CmdLine)                       ' start compiler

	Select Case ExitCode                                     ' process compiler output
	Case CREATE_PROCESS_FAILED, CREATE_PIPE_FAILED
	    nErr = 1
	Case Else 	
		nLine = SendMessage (ah.hout, EM_GETLINECOUNT, 0, 0)

		For i = nLine - 1 To 0 Step -1                        ' upstairs bottom line -> bookmark BMT_GO
		    bm = SendMessage (ah.hout, REM_GETBOOKMARK, i, 0)
		    If bm = BMT_GO Then Exit For
		    GetLineByNo ah.hout, i, @buffer
		
			If     InStr(buffer, " : error ") _
			OrElse InStr(buffer, ") error ") Then 
				SendMessage ah.hout, REM_SETBOOKMARK, i, BMT_ERROR
				id = SendMessage (ah.hout, REM_GETBMID, i, 0)
				y = GetErrLine (buffer, fQuickRun)
				If y >= 0 Then
					SendMessage ah.hred, REM_SETERROR, y, id
				EndIf
			    nErr += 1
			ElseIf InStr (buffer, ") warning ") Then
			    SendMessage ah.hout, REM_SETBOOKMARK, i, BMT_WARN
			    'nErr += 0
			ElseIf InStr (buffer, "No such file: ") _
			OrElse InStr (buffer, "cannot find") _
			OrElse InStr (buffer, "cannot open output file") _
			OrElse Left  (buffer, 6) = "Error!" _                         ' error message from GoRC
			OrElse InStr (buffer, "undefined reference to") Then
				SendMessage ah.hout, REM_SETBOOKMARK, i, BMT_ERROR
				SendMessage ah.hout, REM_SETBMID, i, 0
				nErr += 1
			EndIf
		Next 
	End Select  

	If nErr Then
		TextToOutput "build error(s)", MB_ICONERROR
        GoTo Exit_MakeBuild
    EndIf 

    If fProject Then                                          ' start post build batch
        GetPrivateProfileString @"Make", @"PostBuildBatch", NULL, CmdLine, SizeOf (CmdLine), ad.ProjectFile
        If IsZStrNotEmpty (CmdLine) Then
            ExitCode = ProcessBuild (CmdLine)
            If ExitCode Then
                TextToOutput "exit code: " + Str (ExitCode), MB_ICONERROR  
                nErr = 1 
                GoTo Exit_MakeBuild
            EndIf
        EndIf
    EndIf    

	If fOnlyThisModule = FALSE Then                           ' clean up only after building main
		i = 0
		Do
		    GetSubStr i, ProjectDeleteFiles, FileName, SizeOf (FileName), CUByte (Asc (";"))  
		    DeleteFiles FileName
		Loop While i
	EndIf
	
	
Exit_MakeBuild:	
	CallAddins(ah.hwnd,AIM_MAKEDONE,Cast(WPARAM,@sFile),Cast(LPARAM,@sMakeOpt),HOOK_MAKEDONE)
	Return nErr

End Function

Function FileCheck(Byref sPaths As zString,Byref sFiles As zString) As HANDLE
	
	Dim i          As Integer            = Any
	Dim k          As Integer            = Any 
	Dim x          As Integer            = Any 
	Dim szFileName As ZString * MAX_PATH 
	Dim hFile      As HANDLE             = Any 
    
    i = 0
    Do
        GetSubStr i, sPaths, szFileName, SizeOf (szFileName), CUByte (Asc (";")) 
        x = lstrlen (szFileName)
        k = 0
        Do
            GetSubStr k, sFiles, szFileName[x], SizeOf (szFileName) - x, CUByte (Asc (";"))    ' append Filename
			
			If IsZStrNotEmpty (szFileName) Then
			    ZStrReplaceChar @szFileName, Asc ("/"), Asc ("\")
    			hFile = CreateFile (@szFileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0)
    			If hFile <> INVALID_HANDLE_VALUE Then
    				TextToOutput "checking: " + szFileName
    				Return hFile
    			EndIf
			EndIf
        Loop While k
    Loop While i
	
	'Dim As Integer iPath,iFile,i
	'iFile=1
	'While iFile
	'	i=InStr(iFile,sFiles,";")
	'	If i=0 Then
	'		szFile=Mid(sFiles,iFile)
	'	Else
	'		szFile=Mid(sFiles,iFile,i-iFile)
	'		i+=1
	'	EndIf
	'	iFile=i
	'	iPath=1
	'	While iPath
	'		i=InStr(iPath,sPaths,";")
	'		If i=0 Then
	'			szPath=Mid(sPaths,iPath)
	'		Else
	'			szPath=Mid(sPaths,iPath,i-iPath)
	'			i+=1
	'		EndIf
	'		iPath=i
	'		
	'		szFileName=szPath & szFile
	'		hFile=CreateFile(@szFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
	'		If hFile<>INVALID_HANDLE_VALUE Then
	'			TextToOutput("Checking: " & szFileName)
	'			Return hFile
	'		EndIf
	'	Wend
	'Wend
	Return Cast (HANDLE, INVALID_HANDLE_VALUE)

End Function

Sub IsNewer (Byref sFile As zString, ByVal fInc As Integer, ByRef ft1 As FILETIME)
	
	Dim hFile                 As HANDLE             = Any 
	Dim ft                    As FILETIME           
	Dim hMem                  As HGLOBAL            
	Dim hMem1                 As HGLOBAL            
	Dim nSize                 As DWORD              = Any               
	Dim BytesRead             As DWORD              = Any 
	Dim StartIdx              As Integer            = Any 
	Dim FileSpec              As String  
    Dim pSearchExpr(1 To ...) As ZString Ptr        = { @"#include(( )+once)?( )+\x22(.+?)\x22", _      ' search pattern: include
                                                        @"#inclib( )+\x22(.+?)\x22"              _      '                 incLib
                                                      }        
    
    'include code line:
    '   #Include "..\test\file.bi"           ' comment
    '   #Include Once "..\test\file.bi"      ' comment
    'inclib code line:
    '   #IncLib "..\test\file"               ' comment
    
	If fInc Then
        If IsZStrNotEmpty (ad.FbcIncPath) Then
            hFile = FileCheck (";" + ad.FbcIncPath + $"\", sFile)
        Else
            TextToOutput "*** Environment: FBCINC_PATH not defined ***", MB_ICONHAND
            hFile = Cast (HANDLE, INVALID_HANDLE_VALUE)
        EndIf   
	Else
        If IsZStrNotEmpty (ad.FbcLibPath) Then
    		hFile = FileCheck (";" + ad.FbcLibPath + $"\", sFile & ";"       & _
    		                                               sFile & ".a;"     & _
    		                                               sFile & ".dll.a;" & _
    		                                       "lib" & sFile & ";"       & _
    		                                       "lib" & sFile & ".a;"     & _
    		                                       "lib" & sFile & ".dll.a")
        Else
            TextToOutput "*** Environment: FBCLIB_PATH not defined ***", MB_ICONHAND
            hFile = Cast (HANDLE, INVALID_HANDLE_VALUE)
        EndIf   
	EndIf
    
	If hFile<>INVALID_HANDLE_VALUE Then
		GetFileTime hFile, NULL, NULL, @ft
		If CompareFileTime (@ft, @ft1) > 0 Then
			CloseHandle hFile
			ft1 = ft
		ElseIf fInc Then
			' Check #Include and #Inclib
			nSize = GetFileSize (hFile, NULL)
			hMem = MyGlobalAlloc (GMEM_FIXED, nSize + 1)                     ' + pending NULL
		    ReadFile hFile, hMem, nSize, @BytesRead, NULL
		    CloseHandle hFile
		    Cast (ZString Ptr, hMem)[nSize] = 0                              ' append NULL          

			If *Cast (WORD Ptr, hMem) = &HFEFF Then 		                ' Unicode
				hMem1 = MyGlobalAlloc (GMEM_FIXED, nSize + 1)
				If hMem1 Then
				    WideCharToMultiByte CP_ACP, 0, hMem, -1, hMem1, nSize, NULL, NULL
				    GlobalFree hMem
				    hMem = hMem1
				EndIf 
			EndIf
            
            SendMessage ah.hpr, PRM_PREPARSE, TRUE, Cast (LPARAM, hMem)     ' remove single-/multi-line comments 

            StartIdx = 0        
            Do
                SearchRegEx StartIdx, hMem, pSearchExpr(1), 4, FileSpec, 0  ' search #Include  
                If Len (FileSpec) Then
                    IsNewer FileSpec, TRUE, ft1
                EndIf 
            Loop While StartIdx    

            StartIdx = 0        
            Do
                SearchRegEx StartIdx, hMem, pSearchExpr(2), 2, FileSpec, 0  ' search #IncLib
                If Len (FileSpec) Then
                    IsNewer FileSpec, FALSE, ft1
                EndIf 
            Loop While StartIdx    

	        'Dim hPtr                  As HGLOBAL
	        'Dim ms                    As MEMSEARCH
			'ms.lpFind    = @"#include"
			'ms.lpCharTab = ad.lpCharTab
			'ms.fr        = FR_WHOLEWORD Or FR_DOWN              ' Memory search down is faster
			'ms.lpMem     = hMem
            '
			'Do 
			'	hPtr = Cast (HGLOBAL, SendMessage (ah.hpr, PRM_MEMSEARCH, 0, Cast (LPARAM, @ms)))
			'	If hPtr Then
			'	    GetEnclosedStr 0, *Cast (ZString Ptr, hPtr), FileSpec, SizeOf (FileSpec), CUByte (34), CUByte (34)
			'		IsNewer FileSpec, TRUE, ft1
			'		ms.lpMem = hPtr + 1
			'	Else
			'	    Exit Do
			'	EndIf
			'Loop 
            '
    		'ms.lpFind = @"#inclib"
			'ms.lpMem  = hMem
	        '
			'Do 
			'	hPtr = Cast (HGLOBAL, SendMessage (ah.hpr, PRM_MEMSEARCH, 0, Cast (LPARAM, @ms)))
			'	If hPtr Then
   			'	    GetEnclosedStr 0, *Cast (ZString Ptr, hPtr), FileSpec, SizeOf (FileSpec), CUByte (34), CUByte (34)
			'		IsNewer FileSpec, FALSE, ft1
			'		ms.lpMem = hPtr + 1
			'	Else
			'	    Exit Do 
			'	EndIf
			'Loop 

			GlobalFree hMem
		Else
		    CloseHandle hFile
		EndIf
	EndIf
	
End Sub

Function CompileModules () As Integer

	Dim SaveErr       As BOOL               = Any
	Dim OutputVisible As Integer            = Any
	Dim id            As Integer            = Any 
	Dim nMiss         As Integer            = Any 
	Dim sFile         As ZString * MAX_PATH
	Dim sOFile        As ZString * MAX_PATH
	Dim hFile         As HANDLE             = Any 
	Dim ft1           As FILETIME           = Any 
	Dim ft2           As FILETIME           = Any 
	Dim CCLName       As GOD_EntryName      = Any 
    Dim CCLData       As GOD_EntryData      = Any
   	 

    OutputVisible = wpos.fview And VIEW_OUTPUT

	If edtopt.autosave Then
		SaveErr = SaveAllTabs ()                     
	Else
		SaveErr = DialogBoxParam (hInstance, MAKEINTRESOURCE (IDD_DLGSAVESELECTION), ah.hwnd, @SaveSelectionDlgProc, SAM_ALLFILES)
	EndIf

	If SaveErr Then
        TextToOutput !"unsaved file(s) found\r", MB_ICONERROR
        fBuildErr = 1
        GoTo Exit_CompileModules
	EndIf  

    UpdateEnvironment							
	UpdateAllTabs (2)                                                    ' clear errors
	UpdateAllTabs (4)                                                    ' update dirty bit

	fBuildErr=0
	If fProject Then
		nMiss = 0
		For id = 1001 To 1256
			GetPrivateProfileString @"File", Str (id), NULL, @sFile, SizeOf (sFile), @ad.ProjectFile
			If IsZStrNotEmpty (sFile) Then
				nMiss = 0
				GetCCL id, @CCLName, @CCLData
                
                If IsZStrEmpty (CCLData) Then
                    TextToOutput "*** undefined command line ***", MB_ICONEXCLAMATION 
                    TextToOutput sFile
                    fBuildErr = 1
                    Exit for
                EndIf
                
                ExpandStrByEnviron CCLData
         	    PathCombine CCLData, ad.fbcPath, CCLData                 ' add default
                
                DebugPrint (fCompileIfNewer)
				If fCompileIfNewer Then
					sOFile = sFile
				    PathRenameExtension sOFile, ".o"						
					hFile = CreateFile (sOFile, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
					If hFile = INVALID_HANDLE_VALUE Then                 ' file does not exist
					    TextToOutput sOFile + !" not found\13"
						fBuildErr = MakeBuild (CCLData, sFile, CCLName, TRUE, TRUE, FALSE)
					Else 
						GetFileTime hFile, NULL, NULL, @ft2
						CloseHandle hFile
						ft1 = ft2
						IsNewer sFile, TRUE, ft1
						If CompareFileTime (@ft1, @ft2) > 0 Then
							fBuildErr = MakeBuild (CCLData, sFile, CCLName, TRUE, TRUE, FALSE)
						Else
							TextToOutput sOFile + !" is newer than any of the checked files.\13", BMT_GO, 0
						EndIf
					EndIf
				Else
					fBuildErr = MakeBuild (CCLData, sFile, CCLName, TRUE, TRUE, FALSE)
				EndIf
				If fBuildErr Then Exit For 

			Else
       	        If nMiss > MAX_MISS Then Exit For
				nMiss += 1
			EndIf
		Next 
	Else
		TextToOutput "*** no modules available ***", MB_ICONEXCLAMATION 
		fBuildErr = 1
	EndIf
		

Exit_CompileModules:	
	If fBuildErr = 0 AndAlso OutputVisible = 0 Then
		nHideOut=15
	Else
		nHideOut=0
	EndIf

	Return fBuildErr

End Function

Function Compile (Byref sMake As zString) As Integer

    Dim SaveErr       As BOOL               = Any 
	Dim OutputVisible As Integer            = Any 
	Dim i             As Integer            = Any 
	Dim sFile         As ZString * MAX_PATH 
    Dim pIniFileSpec  As ZString Ptr        = Any  
	Dim CCLName       As GOD_EntryName      = Any 
	
    OutputVisible = wpos.fview And VIEW_OUTPUT
	TextToOutput !"build:\r"
	    
    If fProject Then 
        If nMain = 0 Then
       	    TextToOutput !"no main module\r", MB_ICONERROR
            fBuildErr = 1
            GoTo Exit_Compile
        EndIf     
        If nMainRC = 0 Then
            If CountProjectResource () > 0 Then
       	        TextToOutput !"no main resource\r", MB_ICONERROR
                fBuildErr = 1
                GoTo Exit_Compile
            EndIf
        EndIf     
    EndIf
    
	If fIncVersion AndAlso fProject Then
		If ah.hres Then
			If SendMessage(ah.hraresed,PRO_GETMEM,0,0) Then
				SendMessage(ah.hraresed,PRO_INCVERSION,0,0)
			Else
				sFile = GetProjectMainResource ()
				If IsZStrNotEmpty (sFile) Then
					sFile=ad.ProjectPath & "\" & sFile
					OpenTheFile(sFile,FOM_STD)
					SendMessage(ah.hraresed,PRO_INCVERSION,0,0)
				EndIf
			EndIf
		EndIf
	EndIf

	If edtopt.autosave Then
		SaveErr = SaveAllTabs ()                        ' MOD 2.1.2012   bm=SaveAllFiles(ah.hwnd)
	Else
		SaveErr = DialogBoxParam (hInstance, MAKEINTRESOURCE (IDD_DLGSAVESELECTION), ah.hwnd, @SaveSelectionDlgProc, SAM_ALLFILES)
	EndIf
	
	If SaveErr Then
        TextToOutput !"unsaved file(s) found\r", MB_ICONERROR
        fBuildErr = 1
        GoTo Exit_Compile
	EndIf  
	
	UpdateEnvironment
	UpdateAllTabs (2)                                	' clear errors
	UpdateAllTabs (4)                                   ' update dirty bit	
	
	If fProject Then
	    pIniFileSpec = @ad.ProjectFile
	Else
	    pIniFileSpec = @ad.IniFile
	EndIf
	
	i = GetPrivateProfileInt (@"Make", @"Current", 1, pIniFileSpec)
	GetPrivateProfileString @"Make", Str (i), NULL, @CCLName, SizeOf (CCLName), pIniFileSpec
    If IsZStrNotEmpty (CCLName) Then
	    SplitStr CCLName, Asc (","), 0
    EndIf 
	
	If fProject Then
		If fRecompile=RCM_PREBUILD Then
		    If CompileModules () = 0 Then
				nHideOut = 0
				sFile = *GetProjectFileName (nMain, PT_RELATIVE)     ' MOD 17.2.2012
				fBuildErr = MakeBuild (sMake, sFile, CCLName, FALSE, TRUE, FALSE)
			EndIf
		Else
			sFile = *GetProjectFileName (nMain, PT_RELATIVE)         ' MOD 17.2.2012
			fBuildErr = MakeBuild (sMake, sFile, CCLName, FALSE, FALSE, FALSE)
		EndIf
	Else
		sFile = ad.filename
		fBuildErr = MakeBuild (sMake, sFile, CCLName, FALSE, FALSE, FALSE)
	EndIf
	
	
Exit_Compile:	
	If fBuildErr Then
	    TextToOutput "*** terminated ***"
	EndIf
	HLineToOutput
	
	If fBuildErr = 0 AndAlso OutputVisible = 0 Then
		nHideOut=15
	Else
		nHideOut=0
	EndIf

	Return fBuildErr

End Function
