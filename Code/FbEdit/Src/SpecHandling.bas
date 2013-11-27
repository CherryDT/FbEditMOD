
#Include Once "windows.bi"
#Include Once "win/commdlg.bi"

#Include Once "..\..\Redist\Masm32Lib\Build\Masm32.bi"
#LibPath "..\..\Redist\Masm32Lib\Build"

#Include Once "Inc\RAEdit.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\CoTxEd.bi"
#Include Once "Inc\EditorOpt.bi"
#Include Once "Inc\Environment.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\Misc.bi"
#Include Once "Inc\Project.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\SpecHandling.bi"
#Include Once "Inc\showvars.bi"


Dim Shared DirList      As String  
Dim Shared DirListLCase As String 


'Sub FixPath (Byref Path As ZString)
'
'    '=============================================
'    ' MOD 16.1.2012    faster, no GoTo's
'    '
'    ' dont use this sub for regular purpose
'    ' only for updating of outdated inis
'
'    Dim x       As Integer            = Any 
'    Dim Temp    As ZString * MAX_PATH = Any
'    Dim Success As BOOL               = Any 
'	
'    Do
'    	x = InStr (Path, "$A")          ' Applicationpath (FbEdit.exe)
'    	If x Then
'    		Path = Left (Path, x - 1) + ad.AppPath + Mid (Path, x + 2)
'    		Continue Do
'    	EndIf
'    	
'    	x = InStr (Path, "$C")          ' Compilerpath (fbc.exe)
'    	If x Then
'    		Path = Left (Path, x - 1) + ad.fbcPath + Mid (Path, x + 2)
'    		Continue Do
'    	EndIf
'    	
'    	x = InStr (Path, "$H")
'    	If x Then
'    		Path = Left (Path, x - 1) + ad.HelpPath + Mid (Path, x + 2)
'    		Continue Do
'    	EndIf
'    	
'    	x = InStr (Path, "$P")
'    	If x Then
'    		Path = Left (Path, x - 1) + ad.DefProjectPath + Mid (Path, x + 2)
'    		Continue Do
'    	EndIf
'    Loop While x
'
'    
'    Success = PathCanonicalize (@Temp, @Path)    ' if containing sequences of ".."
'	
'	If Success Then Path = Temp
'  
'
'Sub FixPath(lpCmd As ZString Ptr)
'
'   Dim path As ZString*260
'	Dim x As Integer
'
'	lstrcpy(@path,lpCmd)
'Again:
'	If InStr(path,"$A") Then
'		x=InStr(path,"$A")
'		path=Left(path,x-1) & ad.AppPath & Mid(path,x+2)
'		GoTo Again
'	EndIf
'	If InStr(path,"$C") Then
'		x=InStr(path,"$C")
'		path=Left(path,x-1) & ad.fbcPath & Mid(path,x+2)
'		GoTo Again
'	EndIf
'	If InStr(path,"$H") Then
'		x=InStr(path,"$H")
'		path=Left(path,x-1) & ad.HelpPath & Mid(path,x+2)
'		GoTo Again
'	EndIf
'	If InStr(path,"$P") Then
'		x=InStr(path,"$P")
'		path=Left(path,x-1) & ad.DefProjectPath & Mid(path,x+2)
'		GoTo Again
'	EndIf
'	lstrcpy(lpCmd,@path)
'
'End Sub

Sub GetFilePath (ByVal pFileSpec As ZString Ptr)
	
	' MOD 22.1.2012
	
	PathRemoveFileSpec pFileSpec
	
	'Dim x As Integer
    '
	'x=Len(sFile)
	'While x
	'	If Asc(sFile,x)=Asc("\") Then
	'		sFile=Left(sFile,x-1)
	'		Exit While
	'	EndIf
	'	x=x-1
	'Wend

End Sub

'Function GetFileExt (ByVal pSpec As ZString Ptr) As ZString Ptr 

    ' MOD 11.1.2012

	'Return PathFindExtension (pSpec)

	'Const ASCII_Point     As Integer = Asc(".")
	'Const ASCII_Colon     As Integer = Asc(":")
	'Const ASCII_Backslash As Integer = Asc("\")
	'Dim   x               As Integer = Len (sFile)
    '
	'While x
    '
	'	Select Case Asc (sFile, x)
	'	Case ASCII_Point
	'	    Return Mid (sFile, x)
	'	Case ASCII_Backslash, ASCII_Colon
	'	    Return ""
	'	End Select
    '
	'	x -= 1
	'Wend

'End Function

Function RemoveFileExt (ByVal pFileSpec As ZString Ptr) As ZString Ptr

    Dim    x        As Integer = lstrlen (pFileSpec)
    Static SpecCopy As ZString * MAX_PATH
    SpecCopy = *pFileSpec
    
	Do While x

		Select Case SpecCopy[x]
		Case Asc (".")
		    SpecCopy[x] = NULL
		    Return @SpecCopy
		Case Asc ("\"), Asc (":")
		    Return @SpecCopy
		End Select

		x -= 1
	Loop

	Return @SpecCopy            ' x = 0, nothing found

    '=================================
    ' MOD 24.1.2012               
    'Static SpecCopy As ZString * MAX_PATH 
    '
    'SpecCopy = sFile 
    '
    'PathRemoveExtension @SpecCopy
    '
    'Return @SpecCopy
    '=================================

End Function

Function GetFileName (ByVal pFileSpec As ZString Ptr) As ZString Ptr   ' MOD 22.1.2012 String -> Zstring Ptr
                                                                       ' fExt = FALSE -> Call GetFileBaseName  
    Return PathFindFileName (pFileSpec)
    
    '=================================
    ' MOD 22.1.2012
    'Function GetFileName(ByVal sFile As String,ByVal fExt As Boolean) As String
	'Dim x As Integer
	'Dim sItem As ZString*260
    '
	'sItem=sFile
	'If fExt=FALSE Then
	'	x=Len(sItem)
	'	While x
	'		If Asc(sItem,x)=Asc(".") Then
	'			sItem=Left(sItem,x-1)
	'			Exit While
	'		EndIf
	'		x=x-1
	'	Wend
	'EndIf
	'x=Len(sItem)
	'While x
	'	If Asc(sItem,x)=Asc("\") Then
	'		Exit While
	'	EndIf
	'	x=x-1
	'Wend
	'GetFileName=Mid(sItem,x+1)
    '=================================
    
End Function

Function GetFileBaseName (ByVal pFileSpec As ZString Ptr) As ZString Ptr
    
    Static Buffer As ZString * MAX_PATH = Any
    
    Buffer = *PathFindFileName (pFileSpec)
    
    PathRemoveExtension @Buffer
    
    Return @Buffer

End Function

Function GetFBEFileType (ByVal pFileSpec As ZString Ptr) As FBEFileType
	
	' MOD 11.1.2012
	'CodeFiles is LCASE p.def. - forced on file I/O
	
	Dim i       As Integer            = Any
	Dim FileExt As ZString * MAX_PATH = *PathFindExtension (pFileSpec)
		
	If IsZStrEmpty (FileExt) Then Return FBFT_UNKOWN
	CharLower FileExt
	If InZStr (0, CodeFiles, FileExt + ".") >= 0 Then Return FBFT_CODE	
	
	Select Case FileExt
	Case ".rc"   :   Return FBFT_RESOURCE
	Case ".hlp"  :   Return FBFT_WINHELP
	Case ".chm"  :   Return FBFT_HTMLHELP    
	Case ".fbp"  :   Return FBFT_PROJECT    
	Case Else    :   Return FBFT_UNKOWN
	End Select    

	'Dim sItem As String
	'sItem=GetFileExt(sFile) & "."
	'If InStr(UCase(CodeFiles),UCase(sItem)) Then
	'	Return 1
	'ElseIf UCase(Right(sFile,3))=".RC" Then
	'	Return 2
	'ElseIf UCase(Right(sFile,4))=".HLP" Then
	'	Return 3
	'ElseIf UCase(Right(sFile,4))=".CHM" Then
	'	Return 4
	'ElseIf UCase(Right(sFile,4))=".FBP" Then
	'	Return 5
	'EndIf
	'Return 0

End Function

Sub BuildDirList (ByVal lpDir As ZString Ptr, ByVal lpSub As ZString Ptr, ByVal nType As Integer)
	
	Dim wfd        As WIN32_FIND_DATA
	Dim hwfd       As HANDLE             = Any 
	Dim l          As Integer            = Any
	Dim NewPattern As ZString * MAX_PATH = Any
    Dim NewSubDir  As ZString * MAX_PATH = Any 

	hwfd = FindFirstFile (*lpDir + $"\*", @wfd)
	
	If hwfd <> INVALID_HANDLE_VALUE Then
		Do
			If wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
				If wfd.cFileName[0] <> Asc (".") Then
					NewSubDir  = *lpSub + wfd.cFileName + $"\"
					NewPattern = *lpDir + $"\" + wfd.cFileName
					BuildDirList NewPattern, NewSubDir, nType
				EndIf
			Else
				If ntype < 8 Then
					If lpSub Then
						DirList += Str (nType) + "," + *lpSub + wfd.cFileName + "#"
					Else
						DirList += Str (nType) + "," + wfd.cFileName + "#"
					EndIf
				Else
					l = lstrlen (@wfd.cFileName)
					If l > 2 Then
					    If lstrcmpi (@wfd.cFileName[l - 2], @".a") = 0 Then
					        wfd.cFileName[l - 2] = 0
					        l -= 2
					        If l > 4 Then
					            If lstrcmpi (@wfd.cFileName[l - 4], @".dll") = 0 Then
					                wfd.cFileName[l - 4] = 0
					            EndIf
					        EndIf    
					        If szCmpi (@wfd.cFileName, @"lib", 3) = 0 Then
					            DirList += Str (nType And 7) + "," + (@wfd.cFileName)[3] + "#"   ' WATCH    
					        EndIf
					    EndIf
					EndIf
				EndIf
			EndIf
		Loop While FindNextFile (hwfd, @wfd)
		
		FindClose hwfd
	EndIf

End Sub

Sub GetIncludeSpec (ByVal pIncludeSpec As ZString Ptr)
    
    ' *pIncludeSpec [OUT]
    
    Dim i                       As Integer             = Any 
    Dim EditorMode              As Long                = Any
    Dim EditorSpec              As ZString * MAX_PATH                           
    Dim SrcPath                 As ZString * MAX_PATH
    Dim pSearchPathes(1 To ...) As ZString Ptr = {@ad.ProjectPath, @ad.AppPath, @ad.FbcIncPath, 0} 
        
    EditorMode = GetWindowLong (ah.hred, GWL_ID)
    
    If     EditorMode = IDC_CODEED _ 
    OrElse EditorMode = IDC_TEXTED Then

        GetStringLiteralByCaret ah.hred, EditorSpec, 0
        
        If fProject = FALSE Then
            SrcPath = ad.filename
            PathRemoveFileSpec SrcPath 
            pSearchPathes(1) = @SrcPath
        EndIf     
            
        For i = 1 To UBound (pSearchPathes)
            PathCombine pIncludeSpec, pSearchPathes(i), EditorSpec
            If FileExists (pIncludeSpec) Then Exit Sub
        Next
    EndIf

    SetZStrEmpty (*pIncludeSpec)

End Sub

Function FileExists (ByVal pSpec As ZString Ptr) As BOOL
    
    Dim FileAttr As DWORD = Any 
    
    FileAttr = GetFileAttributes (pSpec)
    
    If FileAttr = INVALID_FILE_ATTRIBUTES Then Return FALSE  
    If FileAttr And FILE_ATTRIBUTE_DIRECTORY Then Return FALSE
    Return TRUE

End Function

Function DirExists (ByVal pSpec As ZString Ptr) As BOOL
    
    Dim FileAttr As DWORD = Any 
    
    FileAttr = GetFileAttributes (pSpec)
    
    If FileAttr = INVALID_FILE_ATTRIBUTES Then Return FALSE  
    If FileAttr And FILE_ATTRIBUTE_DIRECTORY Then Return TRUE 
    Return FALSE 

End Function

Sub GetLastWriteTime (ByVal pFileSpec As ZString Ptr, ByVal pFileTime As FILETIME Ptr)

	Dim hFile As HANDLE = Any 

	hFile = CreateFile (pFileSpec, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)

	If hFile <> INVALID_HANDLE_VALUE Then
		GetFileTime hFile, NULL, NULL, pFileTime
		CloseHandle hFile
	Else
	    Dim InitFileTime As FILETIME
	    *pFileTime = InitFileTime                      ' zero out
	EndIf

End Sub

Sub CmdLineSubstExeUI (ByRef CmdLine       As ZString,    _         ' [IN] required size is 32 * 1024 bytes
                       ByVal hwndOwner     As HWND,       _         ' [IN]
                       ByVal pFilterstring As ZString Ptr _         ' [IN]
                      )
                        
    ' caller has to ensure: required buffer size for CmdLine is 32768 bytes (MSDN Library)                   
                        
   
    Const CmdLineSize As Integer               = 32 * 1024            ' max. CmdLine size
    Dim   pBuffB      As ZString Ptr           = Any     
    Dim   ofn         As OPENFILENAME
    Dim   ArgList     As ZString * CmdLineSize 
        
    With ofn
		.lStructSize = SizeOf (ofn)
		.hwndOwner   = hwndOwner 
		.hInstance   = hInstance
		.lpstrFilter = pFilterString
		.lpstrFile   = @CmdLine
		.nMaxFile    = CmdLineSize
		.Flags       = OFN_EXPLORER Or OFN_FILEMUSTEXIST Or OFN_HIDEREADONLY Or OFN_PATHMUSTEXIST
    End With
	
	pBuffB = PathGetArgs (@CmdLine)
    ArgList = *pBuffB
    pBuffB[0] = 0                        ' trim arglist from buff
	UpdateEnvironment
	ExpandStrByEnviron CmdLine, CmdLineSize
	TrimWhiteSpace CmdLine
	PathUnquoteSpaces @CmdLine
	
	If GetOpenFileNameUI (@ofn) Then
		PathQuoteSpaces @CmdLine
		If IsZStrNotEmpty (ArgList) Then
		    ZStrCat @CmdLine, CmdLineSize, 2, @" ", @ArgList
		EndIf    
	EndIf
  
End Sub

Sub CmdLineCombinePath (ByRef CmdLine      As ZString,    _         ' [IN/OUT] required size is 32 * 1024 bytes
                        ByVal pDefaultPath As ZString Ptr _         ' [IN]     combined if needed
                       )
                        
    ' caller has to ensure: required buffer size for CmdLine is 32768 bytes (MSDN Library)                   
                        
   
    Const CmdLineSize   As Integer               = 32 * 1024       ' max. CmdLine size
    Dim   pBuffB        As ZString Ptr           = Any     
    Dim   ArgList       As ZString * CmdLineSize 
    Dim   DefaultPathLC As ZString * MAX_PATH   
    
    DefaultPathLC = *pDefaultPath                       ' local copy  

	ExpandStrByEnviron CmdLine, CmdLineSize             ' arguments are expanded too

	pBuffB = PathGetArgs (@CmdLine)
    ArgList = *pBuffB
    pBuffB[0] = 0                                       ' trim arglist from buffer

	TrimWhiteSpace CmdLine
    PathUnquoteSpaces CmdLine
    PathUnquoteSpaces DefaultPathLC
    PathCombine CmdLine, @DefaultPathLC, CmdLine         ' PathCombine dont like quotes
    PathQuoteSpaces CmdLine

	If IsZStrNotEmpty (ArgList) Then
	    ZStrCat @CmdLine, SizeOf (CmdLine), 2, @" ", @ArgList
	EndIf

End Sub

Sub WeedOutSpec (ByRef FileSpec As ZString)

    ' removes illegal chars from spec, removing is done inplace
    ' [IN/OUT] FileSpec (has to be terminated by NULL)

    Dim n As Integer = Any 
    Dim i As Integer = Any

    i = 0
    n = 0
    
    Do                                ' remove illegal chars
        If FileSpec[i] Then
            If PathGetCharType (FileSpec[i]) And GCT_LFNCHAR Then
                FileSpec[n] = FileSpec[i]
                n += 1
                i += 1
            Else
                i += 1
            EndIf
        Else
            FileSpec[n] = NULL        ' terminating null
            Exit Do
        EndIf
    Loop
    
End Sub
