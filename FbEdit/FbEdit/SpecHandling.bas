
#Include Once "windowsUR.bi"

#Include Once "Inc\RAEdit.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\CoTxEd.bi"
#Include Once "Inc\EditorOpt.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\Project.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\SpecHandling.bi"
#Include Once "showvarsUR.bi"


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

Sub GetFilePath (ByRef sFile As ZString)
	
	' MOD 22.1.2012
	
	PathRemoveFileSpec @sFile
	
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

Function GetFileExt(ByRef sFile As ZString) As ZString ptr

    ' MOD 11.1.2012

	Return PathFindExtension (@sFile)

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

End Function

Function RemoveFileExt (Byref sFile As zString) As ZString Ptr

    Dim    x        As Integer = lstrlen (@sFile)
    Static SpecCopy As ZString * MAX_PATH
    SpecCopy = sFile
    
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

Function GetFileName (ByRef Buff As ZString) As ZString Ptr   ' MOD 22.1.2012 String -> Zstring Ptr
                                                              ' fExt = FALSE -> Call GetFileBaseName  
    Return PathFindFileName (@Buff)
    
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

Function GetFileBaseName (ByRef FileSpec As ZString) As ZString Ptr
    
    Static Buffer As ZString * MAX_PATH = Any
    
    Buffer = *PathFindFileName (@FileSpec)
    
    PathRemoveExtension @Buffer
    
    Return @Buffer

End Function

Function GetFBEFileType (Byref FileSpec As ZString) As FBEFileType
	
	' MOD 11.1.2012
	'sCodeFiles is LCASE p.def. - forced on file I/O
	
	Dim i       As Integer            = Any
	Dim FileExt As ZString * MAX_PATH = *PathFindExtension (@FileSpec)
		
	If FileExt[0] = 0 Then Return FBFT_UNKOWN
	CharLower FileExt
	If InZStr (0, sCodeFiles, FileExt + ".") >= 0 Then Return FBFT_CODE	
	
	Select Case FileExt
	Case ".rc"   :   Return FBFT_RESOURCE
	Case ".hlp"  :   Return FBFT_WINHELP
	Case ".chm"  :   Return FBFT_HTMLHELP    
	Case ".fbp"  :   Return FBFT_PROJECT    
	Case Else    :   Return FBFT_UNKOWN
	End Select    

	'Dim sItem As String
	'sItem=GetFileExt(sFile) & "."
	'If InStr(UCase(sCodeFiles),UCase(sItem)) Then
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

Sub BuildDirList(ByVal lpDir As ZString Ptr,ByVal lpSub As ZString Ptr,ByVal nType As Integer)
	Dim wfd As WIN32_FIND_DATA
	Dim hwfd As HANDLE
	Dim buffer As ZString*260
	Dim subdir As ZString*260
	Dim l As Integer
	Dim ls As Integer

	lstrcpy(@buffer,lpDir)
	lstrcpy(@subdir,lpSub)
	lstrcat(@buffer,"\*")
	
	'Print "buffer:*";buffer;"*"
	'Print "subdir:*";subdir;"*"
	
	hwfd=FindFirstFile(@buffer,@wfd)
	
	If hwfd<>INVALID_HANDLE_VALUE Then
		While TRUE
			If wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
				lstrcpy(@s,@wfd.cFileName)
				If Asc(s)<>Asc(".") Then
					buffer[Len(buffer)-1]=0
					l=Len(buffer)
					lstrcat(@buffer,@wfd.cFileName)
					ls=Len(subdir)
					lstrcat(@subdir,@wfd.cFileName)
					lstrcat(@subdir,"\")                         ' MOD 25.2.2012
					BuildDirList(@buffer,@subdir,nType)
					buffer[l]=0
					lstrcat(@buffer,"*")
					subdir[ls]=0
				EndIf
			Else
				If ntype<8 Then
					If lpSub Then
						lstrcpy(@s,lpSub)
						lstrcat(@s,@wfd.cFileName)
					Else
						lstrcpy(@s,@wfd.cFileName)
					EndIf
					
			       '===================		
				   'MOD 4.Jan.2012
					DirList += Str (nType) + "," + s + "#"       'preserve case
				   'dirlist+=Str(nType)+","+LCase(s)+"#"
			       '===================					
				Else
					lstrcpy(@s,@wfd.cFileName)
			       '===================		
				   'MOD 4.Jan.2012
				   's=LCase(s)                                   'preserve case
				    If LCase (Right (s, 2)) = ".a" Then
			       '===================
						s[Len (s) - 2] = 0
						If LCase (Right (s, 4)) = ".dll" Then
							s[Len (s) - 4] = 0
						EndIf
						DirList+=Str(nType And 7)+","+s+"#"
					EndIf
				EndIf
			EndIf
			If FindNextFile(hwfd,@wfd)=FALSE Then
				Exit While
			EndIf
		Wend
		FindClose(hwfd)
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
	    *pFileTime = InitFileTime
	EndIf

End Sub
