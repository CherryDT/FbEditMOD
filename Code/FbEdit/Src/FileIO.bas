

#Include Once "windows.bi"

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAProperty.bi"
#Include Once "Inc\RAResEd.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\EditorOpt.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\Misc.bi"
#Include Once "Inc\Project.bi"
#Include Once "Inc\Property.bi"
#Include Once "Inc\ResEd.bi"
#Include Once "Inc\ResEdOpt.bi"
#Include Once "Inc\SpecHandling.bi"
#Include Once "Inc\TabTool.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\FileIO.bi"


Function StreamIn(ByVal hFile As HANDLE,ByVal pBuffer As ZString Ptr,ByVal NumBytes As Long,ByVal pBytesRead As Long Ptr) As Boolean

    Return ReadFile(hFile,pBuffer,NumBytes,pBytesRead,0) Xor 1

End Function

Function StreamOut(ByVal hFile As HANDLE,ByVal pBuffer As ZString Ptr,ByVal NumBytes As Long,ByVal pBytesWritten As Long Ptr) As Boolean

    Return WriteFile(hFile,pBuffer,NumBytes,pBytesWritten,0) Xor 1

End Function

Function GetFileMem OverLoad (Byref sFile As String) As HGLOBAL

    Dim nlen      As Integer = Any
    Dim hMem      As HGLOBAL = Any
    Dim hMem1     As HGLOBAL = Any
    Dim hFile     As HANDLE  = Any
    Dim BytesRead As DWORD   = Any
    Dim hEdit     As HWND    = Any

    hEdit = GetEditWindowBySpec (sFile)

    If hEdit Then
        hMem = GetFileMem (Cast (HWND, hEdit))
        Return hMem
    Else
        hFile = CreateFile (StrPtr(sFile), GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0)
        If hFile <> INVALID_HANDLE_VALUE Then
            nlen = GetFileSize (hFile, NULL)
            hMem = GlobalAllocUI (GMEM_FIXED, nlen + 1)            ' + pending NULL
            If hMem Then
                ReadFile hFile, hMem, nlen, @BytesRead, NULL
                CloseHandle hFile
                Cast (ZString Ptr, hMem)[nlen] = 0                 ' append NULL

                If *Cast (WORD Ptr, hMem) = &HFEFF Then            ' Unicode
                    hMem1 = GlobalAllocUI (GMEM_FIXED, nlen + 1)
                    If hMem1 Then
                        WideCharToMultiByte CP_ACP, 0, hMem, -1, hMem1, nlen, NULL, NULL
                        GlobalFree hMem
                        Return hMem1
                    Else
                        GlobalFree hMem
                        Return 0
                    EndIf
                Else
                    Return hMem
                EndIf
            Else
                CloseHandle hFile
                Return 0
            EndIf
        Else
            Return 0
        EndIf
    EndIf

End Function

Function GetFileMem OverLoad (Byval hEdit As HWND) As HGLOBAL

    Dim nlen As Integer  = Any
    Dim hMem As HGLOBAL  = Any

    If hEdit Then
        nlen = SendMessage (hEdit, WM_GETTEXTLENGTH, 0, 0)
        hMem = GlobalAllocUI (GMEM_FIXED, nlen + 1)                             ' + pending NULL

        If hMem Then
            SendMessage hEdit, WM_GETTEXT, nlen + 1, Cast (LPARAM, hMem)       ' buffer size incl. terminating NULL
        EndIf
        Return hMem
    Else
        Return 0
    EndIf

End Function

Function GetFileMemSelected (Byval hEdit As HWND) As HGLOBAL

    Dim hMem As HGLOBAL   = Any
   	Dim chrg As CHARRANGE = Any


    If hEdit Then
        
       	SendMessage hEdit, EM_EXGETSEL, 0, Cast (LPARAM, @chrg)
        
        'Print "cpMin:"; chrg.cpmin 
        'Print "cpMax:"; chrg.cpmax       
               
        If      chrg.cpMin = 0 _
        AndAlso chrg.cpMax = -1 Then                                           ' full range
            hMem = GetFileMem (hEdit)

        Else 
			hMem = GlobalAllocUI (GMEM_FIXED, chrg.cpMax - chrg.cpMin + 1)      ' + pending NULL
			If hMem Then
			    SendMessage hEdit, EM_GETSELTEXT, 0, Cast (LPARAM, hMem)
			EndIf 
        EndIf

        Return hMem
    Else
        Return 0
    EndIf

End Function

Sub ReadResEdFile (ByVal hWin As HWND, ByVal hFile As HANDLE, ByVal lpFilename As ZString Ptr)

    Dim nSize     As DWORD   = Any
    Dim BytesRead As DWORD   = Any
    Dim hMem      As HGLOBAL = Any

    nSize = GetFileSize (hFile, NULL)
    hMem = GlobalAllocUI (GMEM_FIXED, nSize + 1)                     ' + pending NULL
    ReadFile hFile, hMem, nSize, @BytesRead, NULL
    Cast (ZString Ptr, hMem)[nSize] = 0                              ' append NULL
    
    SendMessage ah.hraresed, PRO_OPEN, Cast (WPARAM, lpFilename), Cast (LPARAM, hMem)  ' RAResEd uses GetCurrentDirectory retrieving ProjectPath

    'If fProject Then
    '    SendMessage ah.hraresed, PRO_SETNAME, Cast (WPARAM, lpFilename), Cast (LPARAM, @ad.ProjectPath)
    'EndIf

End Sub

Sub ReadCodeEdFile (ByVal hWin As HWND, ByVal hFile As HANDLE, ByVal lpFilename As ZString Ptr)

    Dim editstream As EDITSTREAM

    editstream.dwCookie    = Cast (DWORD, hFile)
    editstream.pfnCallback = Cast (EDITSTREAMCALLBACK, @StreamIn)

    nLastSize = SendMessage (hWin, WM_GETTEXTLENGTH, 0, 0)
    SendMessage hWin, WM_SETTEXT, 0, Cast (LPARAM, @"")
    SendMessage hWin, EM_STREAMIN, SF_TEXT, Cast (LPARAM, @editstream)

    SendMessage hWin, EM_SETMODIFY, FALSE, 0
    SendMessage hWin, REM_SETCHANGEDSTATE, FALSE, 0
    SendMessage hWin, REM_SETCOMMENTBLOCKS, Cast (WPARAM, @"/'"), Cast (LPARAM, @"'/") ' Set comment block definition
    SendMessage hWin, REM_SETBLOCKS, 0, 0                                              ' Set blocks

    SetPropertyDirty hWin                       	'todo

    If fProject Then
        If IsZStrNotEmpty (ad.resexport) Then
            buff = MakeProjectFileName (ad.resexport)
            If lstrcmpi (@buff, lpFileName) = 0 Then
                SetWindowLong hWin, GWL_STYLE, GetWindowLong (hWin, GWL_STYLE) Or STYLE_READONLY
            EndIf
        EndIf
    EndIf

End Sub

Sub ReadTxtEdFile (ByVal hWin As HWND, ByVal hFile As HANDLE, ByVal lpFilename As ZString Ptr)

    Dim editstream As EDITSTREAM

    editstream.dwCookie    = Cast (DWORD, hFile)
    editstream.pfnCallback = Cast (EDITSTREAMCALLBACK, @StreamIn)

    nLastSize = SendMessage (hWin, WM_GETTEXTLENGTH, 0, 0)
    SendMessage hWin, WM_SETTEXT, 0, Cast (LPARAM, @"")
    SendMessage hWin, EM_STREAMIN, SF_TEXT, Cast (LPARAM, @editstream)

    SendMessage hWin, EM_SETMODIFY, FALSE, 0
    SendMessage hWin, REM_SETCHANGEDSTATE, FALSE, 0

End Sub

Sub ReadHexEdFile (ByVal hWin As HWND, ByVal hFile As HANDLE, ByVal lpFilename As ZString Ptr)

    Dim editstream As EDITSTREAM

    editstream.dwCookie    = Cast (DWORD, hFile)
    editstream.pfnCallback = Cast (EDITSTREAMCALLBACK, @StreamIn)

    SendMessage hWin, WM_SETTEXT, 0, Cast (LPARAM, @"")
    SendMessage hWin, EM_STREAMIN, SF_TEXT, Cast (LPARAM, @editstream)

    SendMessage hWin, EM_SETMODIFY, FALSE, 0

End Sub

Sub ReadTheFile (ByVal hWin As HWND, ByVal lpFile As ZString Ptr)

    Dim hFile      As HANDLE        = Any
    Dim EditorMode As Integer       = Any

    If hWin Then                                                                ' MOD 1.3.2012   add
        EditorMode = GetWindowLong (hWin, GWL_ID)
        hFile = CreateFile (lpFile, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0)

        If hFile = INVALID_HANDLE_VALUE Then
            TextToOutput "*** file not accessible ***", &hFFFFFFFF
            TextToOutput "try to read: " + *lpFile
        Else
            Select Case EditorMode
            Case IDC_RESED
                ReadResEdFile hWin, hFile, lpFile
            Case IDC_CODEED
                ReadCodeEdFile hWin, hFile, lpFile
            Case IDC_TEXTED
                ReadTxtEdFile hWin, hFile, lpFile
            Case IDC_HEXED
                ReadHexEdFile hWin, hFile, lpFile
            End Select
            CloseHandle hFile
        EndIf
    EndIf
End Sub

Sub BackupFile(Byref szFileName As zString,ByVal nBackup As Integer)
    Dim szBackup As ZString*260
    Dim szFile As ZString*260
    Dim szN As ZString*32
    Dim x As Integer

    szFile = *GetFileName (szFileName)            ' MOD 22.1.2012
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
        If FileExists (szBackup) Then
            ' File exist
            BackupFile(szBackup,nBackup+1)
        EndIf
    EndIf
    CopyFile(@szFileName,@szBackup,FALSE)

End Sub

Sub WriteTheFile(ByVal hWin As HWND,Byref szFileName As zString)

    Dim editstream As EDITSTREAM
    Dim hFile As HANDLE
    Dim hMem As HGLOBAL
    Dim nSize As Integer
    Dim tpe As Integer
    Dim hREd As HWND
    Dim tci As TCITEM
    Dim i As Integer
    Dim Text       As ZString * 512 = Any

    If fProject=TRUE And edtopt.backup<>0 Then
        BackupFile(szFileName,1)
    EndIf
    'fChangeNotification=10
    hFile=CreateFile(szFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0)
    'Print "hFile=INVALID_HANDLE_VALUE;"; HFILE=INVALID_HANDLE_VALUE
    If hFile = INVALID_HANDLE_VALUE Then
        Text = "writing: " + szFileName
        TextToOutput "*** file not accessible ***", &hFFFFFFFF
        TextToOutput Text
    Else
        If hWin=ah.hres Then
            hMem=GlobalAllocUI(GMEM_FIXED,256*1024)
            Cast (ZString Ptr, hMem)[0] = 0                              ' set content length zero
            SendMessage(ah.hraresed,PRO_EXPORT,0,Cast(LPARAM,hMem))
            nSize = lstrlen (Cast (ZString Ptr, hMem))                   ' MOD 11.3.2012    nSize=Len(*Cast(ZString Ptr,hMem))
            WriteFile(hFile,hMem,nSize,@nSize,NULL)
            CloseHandle(hFile)
            hFile=CreateFile(szFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
            tci.mask=TCIF_PARAM
            i=0
            Do While TRUE
                If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(LPARAM,@tci)) Then
                    If hWin=pTABMEM->hedit Then
                        GetFileTime(hFile,NULL,NULL,@pTABMEM->ft)
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
            If fProject AndAlso IsZStrNotEmpty (ad.resexport) Then
                SendMessage(ah.hraresed,PRO_SETEXPORT,MAKEWPARAM(nmeexp.nType,0),Cast(LPARAM,@ad.resexport))
                SendMessage(ah.hraresed,PRO_EXPORTNAMES,1,Cast(Integer,ah.hout))
                SendMessage(ah.hraresed,PRO_SETEXPORT,MAKEWPARAM(nmeexp.nType,nmeexp.nOutput),Cast(LPARAM,@nmeexp.szFileName))
                buff=MakeProjectFileName(ad.resexport)
                If GetFileID(buff) Then
                    ParseFile(buff)
                    SendMessage(ah.hpr,PRM_REFRESHLIST,0,0)
                EndIf
                hREd=GetEditWindowBySpec(buff)                   ' MOD 1.2.2012 removed Param: ah.hwnd
                If hREd Then
                    hFile=CreateFile(buff,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
                    If hFile<>INVALID_HANDLE_VALUE Then
                        ReadCodeEdFile hREd, hFile, buff
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
            tpe=GetFBEFileType(szFileName)
            editstream.dwCookie=Cast(Integer,hFile)
            editstream.pfnCallback=Cast(Any Ptr,@StreamOut)
            SendMessage(hWin,EM_STREAMOUT,SF_TEXT,Cast(Integer,@editstream))
            CloseHandle(hFile)
            hFile=CreateFile(szFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0)
            tci.mask=TCIF_PARAM
            i=0
            Do While TRUE
                If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(LPARAM,@tci)) Then
                    If hWin=pTABMEM->hedit Then
                        GetFileTime(hFile,NULL,NULL,@pTABMEM->ft)
                        Exit Do
                    EndIf
                Else
                    Exit Do
                EndIf
                i=i+1
            Loop
            CloseHandle(hFile)
            If tpe=FBFT_CODE Then
                'If GetWindowLong(hWin,GWL_ID)<>IDC_HEXED Then
                '	SetWindowLong(hWin,GWL_ID,IDC_CODEED)
                'EndIf

                ' TODO
                UpdateAllTabs(3)              ' update properties
            EndIf
        EndIf
        SendMessage(hWin,EM_SETMODIFY,FALSE,0)
        If GetWindowLong(hWin,GWL_ID)<>IDC_HEXED Then
            SendMessage(hWin,REM_SETCHANGEDSTATE,TRUE,0)
        EndIf
        CallAddins(ah.hwnd,AIM_FILESAVED,Cast(WPARAM,hWin),Cast(LPARAM,szFileName),HOOK_FILESAVED)
    EndIf

End Sub

Sub SaveTempFile(ByVal hWin As HWND,Byref szFileName As zString)
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

