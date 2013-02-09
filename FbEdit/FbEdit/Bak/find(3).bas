

#Include Once "windowsUR.bi"
#Include Once "win\shlwapi.bi"
#Include Once "win\richedit.bi"
#Include Once "win\commdlg.bi"
#Include Once "regexUR.bi"                                                 ' MOD 16.2.2012

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAProperty.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\CodeComplete.bi"
#Include Once "Inc\EditorHandling.bi"
#Include Once "Inc\Environment.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\FileIO.bi"
#Include Once "Inc\GenericOpt.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\IniFile.bi"
#Include Once "Inc\Language.bi"
#Include Once "Inc\LineQueue.bi"
#Include Once "Inc\Misc.bi"
#Include Once "Inc\Project.bi"
#Include Once "Inc\SpecHandling.bi"
#Include Once "Inc\TabTool.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\Find.bi"
#Include Once "showvarsUR.bi"


Dim Shared f              As FIND 
Dim Shared fsave          As FIND
Dim Shared FindHistory(8) As ZString * 260


Sub FindDlgDisable ()
    
    Dim chrg As CHARRANGE = Any
            
    EnableDlgItem (ah.hfind, IDOK                , TRUE)
    EnableDlgItem (ah.hfind, IDC_BTN_REPLACE     , TRUE)      
    EnableDlgItem (ah.hfind, IDC_BTN_REPLACEALL  , TRUE)         
    EnableDlgItem (ah.hfind, IDC_BTN_FINDALL     , TRUE)      
    EnableDlgItem (ah.hfind, IDC_BTN_CLR_OUTPUT  , TRUE)
    EnableDlgItem (ah.hfind, IDC_FINDTEXT	     , TRUE)
    EnableDlgItem (ah.hfind, IDC_REPLACETEXT     , TRUE)
    EnableDlgItem (ah.hfind, IDC_RBN_SELECTION   , TRUE)
    EnableDlgItem (ah.hfind, IDC_RBN_PROCEDURE   , TRUE)
    EnableDlgItem (ah.hfind, IDC_RBN_CURRENTFILE , TRUE)
    EnableDlgItem (ah.hfind, IDC_RBN_OPENFILES   , TRUE)
    EnableDlgItem (ah.hfind, IDC_RBN_PROJECTFILES, TRUE)
    EnableDlgItem (ah.hfind, IDC_RBN_INCLUDEPATH , TRUE)
    EnableDlgItem (ah.hfind, IDC_RBN_ALL         , TRUE)
    EnableDlgItem (ah.hfind, IDC_RBN_DOWN        , TRUE)
    EnableDlgItem (ah.hfind, IDC_RBN_UP          , TRUE)
    EnableDlgItem (ah.hfind, IDC_CHK_MATCHCASE   , TRUE)
    EnableDlgItem (ah.hfind, IDC_CHK_WHOLEWORD   , TRUE)
    EnableDlgItem (ah.hfind, IDC_CHK_SKIPCOMMENTS, TRUE)
    EnableDlgItem (ah.hfind, IDC_CHK_LOGFIND	 , TRUE)
    EnableDlgItem (ah.hfind, IDC_CHK_USE_REGEX   , TRUE)
    EnableDlgItem (ah.hfind, IDC_BTN_REGEX_LIB   , TRUE)
    
	If IsWindowVisible (GetDlgItem (ah.hfind, IDC_REPLACETEXT)) = FALSE Then
		EnableDlgItem (ah.hfind, IDC_BTN_REPLACEALL, FALSE) 
	EndIf
						
    If f.flogfind = FALSE Then  	
	    EnableDlgItem (ah.hfind, IDC_BTN_FINDALL, FALSE)
    EndIf
 
    If CountCodeEdTabs < 2 Then 
        EnableDlgItem (ah.hfind, IDC_RBN_OPENFILES, FALSE)
    End If 
    
    If fProject = FALSE  then
        EnableDlgItem (ah.hfind, IDC_RBN_PROJECTFILES, FALSE) 
    EndIf
    
    If f.Engine = FM_ENGINE_REGEX Then
        EnableDlgItem (ah.hfind, IDC_RBN_UP       , FALSE)
        EnableDlgItem (ah.hfind, IDC_CHK_WHOLEWORD, FALSE)
        EnableDlgItem (ah.hfind, IDC_CHK_WHOLEWORD, FALSE)
    Else
        EnableDlgItem (ah.hfind, IDC_BTN_REGEX_LIB, FALSE)
    EndIf
    
    If f.findbuff[0] = 0 Then
        EnableDlgItem (ah.hfind, IDOK           , FALSE)
        EnableDlgItem (ah.hfind, IDC_BTN_REPLACE, FALSE)
        EnableDlgItem (ah.hfind, IDC_BTN_FINDALL, FALSE)     
    EndIf
    
    SendMessage ah.hred, EM_EXGETSEL, 0, Cast (LPARAM,@chrg)		
	If chrg.cpMin = chrg.cpMax Then
        EnableDlgItem (ah.hfind, IDC_RBN_SELECTION, FALSE) 
    EndIf
    
    If f.fsearch = FM_RANGE_COMPILERINCPATH Then
        EnableDlgItem (ah.hfind, IDOK                , FALSE)
        EnableDlgItem (ah.hfind, IDC_BTN_REPLACE     , FALSE)      
        EnableDlgItem (ah.hfind, IDC_BTN_REPLACEALL  , FALSE)         
        EnableDlgItem (ah.hfind, IDC_REPLACETEXT     , FALSE)
        EnableDlgItem (ah.hfind, IDC_CHK_SKIPCOMMENTS, FALSE)
        EnableDlgItem (ah.hfind, IDC_CHK_WHOLEWORD   , FALSE)
        EnableDlgItem (ah.hfind, IDC_CHK_LOGFIND     , FALSE)
        EnableDlgItem (ah.hfind, IDC_RBN_UP          , FALSE)
        EnableDlgItem (ah.hfind, IDC_RBN_DOWN        , FALSE)
    EndIf

	If     GetWindowLong (ah.hred, GWL_ID) = IDC_RESED _
	OrElse GetWindowLong (ah.hred, GWL_ID) = IDC_HEXED Then
		'EnableDlgItem (ah.hfind, IDOK                , FALSE)
		EnableDlgItem (ah.hfind, IDC_BTN_REPLACE     , FALSE)
        EnableDlgItem (ah.hfind, IDC_RBN_PROCEDURE   , FALSE) 
        EnableDlgItem (ah.hfind, IDC_RBN_CURRENTFILE , FALSE)
	EndIf

    If f.Busy Then
        EnableDlgItem (ah.hfind, IDOK                , FALSE)
        EnableDlgItem (ah.hfind, IDC_BTN_REPLACE     , FALSE)      
        EnableDlgItem (ah.hfind, IDC_BTN_REPLACEALL  , FALSE)         
        EnableDlgItem (ah.hfind, IDC_BTN_FINDALL     , FALSE)      
        EnableDlgItem (ah.hfind, IDC_BTN_CLR_OUTPUT  , FALSE)
        EnableDlgItem (ah.hfind, IDC_FINDTEXT	     , FALSE)
        EnableDlgItem (ah.hfind, IDC_REPLACETEXT     , FALSE)
        EnableDlgItem (ah.hfind, IDC_RBN_SELECTION   , FALSE)
        EnableDlgItem (ah.hfind, IDC_RBN_PROCEDURE   , FALSE)
        EnableDlgItem (ah.hfind, IDC_RBN_CURRENTFILE , FALSE)
        EnableDlgItem (ah.hfind, IDC_RBN_OPENFILES   , FALSE)
        EnableDlgItem (ah.hfind, IDC_RBN_PROJECTFILES, FALSE)
        EnableDlgItem (ah.hfind, IDC_RBN_INCLUDEPATH , FALSE)
        EnableDlgItem (ah.hfind, IDC_RBN_ALL         , FALSE)
        EnableDlgItem (ah.hfind, IDC_RBN_DOWN        , FALSE)
        EnableDlgItem (ah.hfind, IDC_RBN_UP          , FALSE)
        EnableDlgItem (ah.hfind, IDC_CHK_MATCHCASE   , FALSE)
        EnableDlgItem (ah.hfind, IDC_CHK_WHOLEWORD   , FALSE)
        EnableDlgItem (ah.hfind, IDC_CHK_SKIPCOMMENTS, FALSE)
        EnableDlgItem (ah.hfind, IDC_CHK_LOGFIND	 , FALSE)
        EnableDlgItem (ah.hfind, IDC_CHK_USE_REGEX   , FALSE)
        EnableDlgItem (ah.hfind, IDC_BTN_REGEX_LIB   , FALSE)
    EndIf

End Sub

Sub ClearFindMsg ()

	SendDlgItemMessage ah.hfind, IDC_IMG_FINDMSG, STM_SETICON, NULL, 0                 ' MOD 18.2.2012 add
	SendDlgItemMessage ah.hfind, IDC_TXT_FINDMSG, WM_SETTEXT, 0, Cast (LPARAM, @"")    ' MOD 18.2.2012 add
    
End Sub

Sub SetFindMsg (ByRef MsgText As ZString, Byval IconID As ZString Ptr)

    SendDlgItemMessage ah.hfind, IDC_IMG_FINDMSG, STM_SETICON, Cast (WPARAM, LoadIcon (NULL, IconID)), 0
	SendDlgItemMessage ah.hfind, IDC_TXT_FINDMSG, WM_SETTEXT, 0, Cast (LPARAM, @MsgText)		

End Sub

Sub GetFindMsg (ByVal pMsgText As ZString Ptr, ByVal BuffSize As Integer)

	SendDlgItemMessage ah.hfind, IDC_TXT_FINDMSG, WM_GETTEXT, BuffSize, Cast (LPARAM, pMsgText)		

End Sub

Sub BuildFileList (ByRef Path As ZString, ByRef ValidExt As ZString)
	
	Dim wfd     As WIN32_FIND_DATA    = Any 
	Dim hwfd    As HANDLE             = Any 
	Dim buffer  As ZString * MAX_PATH = Any 
    Dim PathLen As Integer            = Any 

	lstrcpy @buffer, @Path
	lstrcat @buffer, "\*"
	PathLen = lstrlen (Path) + 1          ' incl. backslash

	hwfd = FindFirstFile (@buffer, @wfd)
	If hwfd <> INVALID_HANDLE_VALUE Then
		Do 
 			If wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY Then
				If wfd.cFileName[0] <> Asc (".") Then
                     
					buffer[PathLen] = 0  
					lstrcat @buffer, @wfd.cFileName
					
					BuildFileList buffer, ValidExt
				EndIf
			Else
		        If lstrcmpi (*PathFindExtension (@wfd.cFileName), @ValidExt) = 0 Then
            	    f.listoffiles +=  Path + "\" + wfd.cFileName + ","
            	EndIf
 			EndIf

			If FindNextFile (hwfd, @wfd) = FALSE Then Exit Do 
		Loop 
		FindClose hwfd
	EndIf
End Sub

Function FindRegEx (Byval Buffer As HGLOBAL) As Integer 
	
	' imitate EM_FINDTEXTEX behaviour 
    
    Dim RegExMatch As regmatch_t

	If f.RegEx.value Then
    	If RegNExec (f.RegEx, Buffer + f.ft.chrg.cpMin, f.ft.chrg.cpMax - f.ft.chrg.cpMin + 1, 1, RegExMatch, 0) Then
    	    Return -1    ' not found
    	Else
    	    f.ft.chrgText.cpMin = f.ft.chrg.cpMin + RegExMatch.rm_so
            f.ft.chrgText.cpMax = f.ft.chrg.cpMin + RegExMatch.rm_eo
    	    Return f.ft.chrgText.cpMin
    	EndIf
	Else
	    Return -1
	EndIf 

End Function

Sub InitRegEx

	Dim Result     As Integer = Any 
	Dim ErrText    As ZString * 256
	Dim cFlags     As Integer = Any 
    
    RegFree f.RegEx 
    cFlags = IIf (f.fr And FR_MATCHCASE, REG_EXTENDED, REG_EXTENDED Or REG_ICASE)	

    If f.Engine = FM_ENGINE_STD Then
        cFlags Or= REG_LITERAL                       ' set bit, emulate STD-Engine
    EndIf

	Result = RegComp (f.RegEx, *f.ft.lpstrText, cFlags)
	
	If Result Then 
	    RegError Result, f.RegEx, ErrText, SizeOf (ErrText)
	    ErrText = "REGEX: " + ErrText
	    SetFindMsg ErrText, IDI_EXCLAMATION
	Else
	    GetFindMsg @ErrText, SizeOf (ErrText)
	    If Left (ErrText, 5) = "REGEX" Then          ' clear only my own error messages
	        ClearFindMsg    
	    EndIf
	EndIf
    
End Sub

Sub InitCharRange
	
	' f.chrginit.      = selection on start of search (new search is marked by ResetFind)
    '                    for determining end of search after rewind
	'            cpMin = first char idx
	'            cpMax = last char idx + 1      (cpMin = cpMax: no selection)
	'
	' f.chrgrange.     = total text block to search (eg. total file) (set by InitFindRange)
	'            cpMin = first char idx (incl.)
	'            cpMax = last char idx  (incl.)
	'
	' f.ft.chrg.       = working range for following search job
	
   	f.ft.lpstrText = @f.findbuff
	
	Select Case f.fdir
		Case FM_DIR_ALL, FM_DIR_DOWN
			If f.fsearch = FM_RANGE_SELECTION Then
				f.ft.chrg.cpMin = f.chrginit.cpMin         
			    f.ft.chrg.cpMax = f.chrginit.cpMax - 1     
			Else
				f.ft.chrg.cpMin = f.chrginit.cpMax
			    f.ft.chrg.cpMax = f.chrgrange.cpMax        ' f.chrgrange.cpMax  = last char of total text (file)
			EndIf
			f.fr = f.fr Or FR_DOWN
	 	Case FM_DIR_UP
	        If f.fsearch = FM_RANGE_SELECTION Then	 
				f.ft.chrg.cpMin = f.chrginit.cpMax - 1     ' reverse range        
				f.ft.chrg.cpMax = f.chrginit.cpMin
	        Else 
				f.ft.chrg.cpMin = f.chrginit.cpMin - 1        
				f.ft.chrg.cpMax = f.chrgrange.cpMin
	        EndIf
			f.fr = f.fr And (-1 Xor FR_DOWN)
	End Select

End Sub

Sub InitFindRange
	
	Dim nLn As Integer
	Dim isinp As ISINPROC
	Dim tci As TCITEM
	Dim p As ZString Ptr
	Dim i          As Integer            = Any       ' MOD 17.2.2012
	Dim sItem      As ZString * MAX_PATH = Any       ' MOD 17.2.2012
	Dim nInx       As Integer            = Any       ' MOD 17.2.2012
	Dim nMiss      As Integer            = Any       ' MOD 17.2.2012
	Dim Base       As Integer            = Any       ' MOD 17.2.2012
    Dim CurrentTab As Integer            = Any       ' MOD 17.2.2012
	Dim EditMode   As Long               = Any 

	f.listoffiles=""
	SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@f.chrginit))

	Select Case f.fsearch
	    Case FM_RANGE_PROC			    ' Current Procedure
			isinp.nLine=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,f.chrginit.cpMin)
			isinp.lpszType=StrPtr("p")
			'If fProject Then
			'	tci.mask=TCIF_PARAM
			'	SendMessage(ah.htabtool,TCM_GETITEM,SendMessage(ah.htabtool,TCM_GETCURSEL,0,0),Cast(LPARAM,@tci))
			'	isinp.nOwner=pTABMEM->profileinx
			'Else
				isinp.nOwner=Cast(Integer,ah.hred)
			'EndIf
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
	    Case FM_RANGE_SELTAB			' Current Module
			f.chrgrange.cpMin=0
			f.chrgrange.cpMax=SendMessage(ah.hred,WM_GETTEXTLENGTH,0,0)+1
			'
		Case FM_RANGE_ALLTABS   		' All Open Files
			f.chrgrange.cpMin=0
			f.chrgrange.cpMax=SendMessage(ah.hred,WM_GETTEXTLENGTH,0,0)+1
			' MOD 17.2.2012
			CurrentTab = SendMessage (ah.htabtool, TCM_GETCURSEL, 0, 0)
			tci.mask = TCIF_PARAM
			If f.fdir = FM_DIR_ALL OrElse f.fdir = FM_DIR_DOWN Then
    			For i = CurrentTab + 1 To 999         ' list Followers, except current
    				If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
        				EditMode = GetWindowLong (pTABMEM->hedit, GWL_ID)
        				If EditMode = IDC_CODEED OrElse EditMode = IDC_TEXTED Then
        				    f.listoffiles += Str (i) + ","
        				EndIf     
    				Else
    					Exit For
    				EndIf
    			Next
			EndIf	
			If f.fdir = FM_DIR_ALL Then	
    			For i = 0 To CurrentTab - 1           ' list precedings, except current
    				If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
        				EditMode = GetWindowLong (pTABMEM->hedit, GWL_ID)
        				If EditMode = IDC_CODEED OrElse EditMode = IDC_TEXTED Then
    					    f.listoffiles += Str (i) + ","
        					EndIf     
    				Else
    					Exit For
    				EndIf
    			Next
			EndIf	
			If f.fdir = FM_DIR_UP Then
    			For i = CurrentTab - 1 To 0 Step -1   ' list precedings in reverse order, except current
    				If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
        				EditMode = GetWindowLong (pTABMEM->hedit, GWL_ID)
        				If EditMode = IDC_CODEED OrElse EditMode = IDC_TEXTED Then
        				    f.listoffiles += Str (i) + ","
        				EndIf     
    				Else
    					Exit For
    				EndIf
    			Next
			EndIf	
			'f.listoffiles=","
			'' Add open files
			'i=SendMessage(ah.htabtool,TCM_GETCURSEL,0,0)
			'If i Then
			'	While TRUE
			'		tci.mask=TCIF_PARAM
			'		If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(LPARAM,@tci)) Then
			'			lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
			'		    If GetFBEFileType(lpTABMEM->filename)=1 Then
			'				f.listoffiles &= Str(i) & ","
			'			EndIf
			'		Else
			'			Exit While
			'		EndIf
			'		i+=1
			'	Wend
			'EndIf
			'i=0
			'While TRUE
			'	tci.mask=TCIF_PARAM
			'	If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(LPARAM,@tci)) Then
			'		lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
			'	    If GetFBEFileType(lpTABMEM->filename)=1 Then
			'			If InStr(f.listoffiles,"," & Str(i) & ",")=0 Then
			'				f.listoffiles &= Str(i) & ","
			'			EndIf
			'		EndIf
			'	Else
			'		Exit While
			'	EndIf
			'	i+=1
			'Wend
			'f.fpro=1
			'f.listoffiles=Mid(f.listoffiles,2)
			' ========================

		Case FM_RANGE_PROJECT			' All Project Files
			f.chrgrange.cpMin=0
			f.chrgrange.cpMax=SendMessage(ah.hred,WM_GETTEXTLENGTH,0,0)+1
			CurrentTab = SendMessage (ah.htabtool, TCM_GETCURSEL, 0, 0)
			tci.mask = TCIF_PARAM
			If f.fdir = FM_DIR_ALL OrElse f.fdir = FM_DIR_DOWN Then
    			For i = CurrentTab + 1 To 999         ' list Followers, except current
    				If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
        				EditMode = GetWindowLong (pTABMEM->hedit, GWL_ID)
        				If EditMode = IDC_CODEED OrElse EditMode = IDC_TEXTED Then
        				    If pTABMEM->profileinx Then
        				    	f.listoffiles += Str (pTABMEM->profileinx) + ","
        				    EndIf 	
        				EndIf     
    				Else
    					Exit For
    				EndIf
    			Next
				' MOD 17.2.2012
				' Add currently closed project files
	            For Base = 0 To 1000 Step 1000    
	                nMiss = 0
	            	For nInx = Base + 1 To Base + 256
	            		
	            		GetPrivateProfileString @"File", Str (nInx), NULL, @sItem, SizeOf (sItem), @ad.ProjectFile
	                                
	            		If sItem[0] Then
	    				    If GetFBEFileType (sItem) = FBFT_CODE Then               ' 1 = code files
	    				        If GetTabIDByFileID (nInx) = INVALID_TABID Then      ' ignore open files
	    						    f.listoffiles += Str (nInx) + ","
	    					    EndIf 
	    					EndIf
	                        nMiss = 0
	            		Else
	            	        If nMiss > MAX_MISS Then Exit For
	            		    nMiss += 1
	            		EndIf 
	            	Next
	            Next
			EndIf	
			If f.fdir = FM_DIR_ALL Then	              ' rewind and continue
    			For i = 0 To CurrentTab - 1           ' list precedings, except current
    				If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
        				EditMode = GetWindowLong (pTABMEM->hedit, GWL_ID)
        				If EditMode = IDC_CODEED OrElse EditMode = IDC_TEXTED Then
        				    If pTABMEM->profileinx Then
        				    	f.listoffiles += Str (pTABMEM->profileinx) + ","
        				    EndIf 	
        					EndIf     
    				Else
    					Exit For
    				EndIf
    			Next
			EndIf	
			If f.fdir = FM_DIR_UP Then
    			For i = CurrentTab - 1 To 0 Step -1   ' list precedings in reverse order, except current
    				If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
        				EditMode = GetWindowLong (pTABMEM->hedit, GWL_ID)
        				If EditMode = IDC_CODEED OrElse EditMode = IDC_TEXTED Then
        				    If pTABMEM->profileinx Then
        				    	f.listoffiles += Str (pTABMEM->profileinx) + ","
        				    EndIf 	
        				EndIf     
    				Else
    					Exit For
    				EndIf
    			Next
			EndIf	
			
			'f.listoffiles=","
			'' Add open project files
			'i=SendMessage(ah.htabtool,TCM_GETCURSEL,0,0)
			'If i Then
			'	While TRUE
			'		tci.mask=TCIF_PARAM
			'		If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(LPARAM,@tci)) Then
			'			lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
			'			If lpTABMEM->profileinx Then
			'			    If GetFBEFileType(lpTABMEM->filename)=1 Then
			'					f.listoffiles &= Str(lpTABMEM->profileinx) & ","
			'				EndIf
			'			EndIf
			'		Else
			'			Exit While
			'		EndIf
			'		i+=1
			'	Wend
			'EndIf
			'i=0
			'While TRUE
			'	tci.mask=TCIF_PARAM
			'	If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(LPARAM,@tci)) Then
			'		lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
			'		If lpTABMEM->profileinx Then
			'		    If GetFBEFileType(lpTABMEM->filename)=1 Then
			'				If InStr(f.listoffiles,"," & Str(lpTABMEM->profileinx) & ",")=0 Then
			'					f.listoffiles &= Str(lpTABMEM->profileinx) & ","
			'				EndIf
			'			EndIf
			'		EndIf
			'	Else
			'		Exit While
			'	EndIf
			'	i+=1
			'Wend
			'' Add not open project files
			'f.ffileno=0
			'While f.ffileno<1256 And nMiss<=10
			'	f.ffileno+=1
			'	sItem=GetProjectFileName(f.ffileno)
			'	If Len(sItem) Then
			'		If GetFBEFileType(sItem)=1 Then
			'			If InStr(f.listoffiles,"," & Str(f.ffileno) & ",")=0 Then
			'				f.listoffiles &= Str(f.ffileno) & ","
			'			EndIf
			'		EndIf
			'		nMiss=0
			'	Else
			'		nMiss+=1
			'	EndIf
			'	If (f.ffileno>256 Or nMiss>=10) And f.ffileno<1001 Then
			'		f.ffileno=1000
			'		nMiss=0
			'	EndIf
			'Wend
			'f.listoffiles=Mid(f.listoffiles,2)
			'f.ffileno=1
			'f.fpro=1
			' ========================

	    Case FM_RANGE_COMPILERINCPATH
            If IsZStrNotEmpty (ad.FbcIncPath) Then
	            BuildFileList ad.FbcIncPath, ".bi"
	        Else
	            TextToOutput "*** Environment: FBCINC_PATH not defined ***", MB_ICONHAND
	            f.listoffiles = ""
	        EndIf   
	        f.listidx = 0
	        
	    Case FM_RANGE_SELECTION			' Current selection
			SendMessage(ah.hred,EM_EXGETSEL,0,Cast(Integer,@f.chrgrange))
			'
	End Select
End Sub

Sub ResetFind

	If f.fnoreset=FALSE Then
		
		f.fres          = -1
		f.fonlyonetime  = 0
		f.nreplacecount = 0
		
		SetDlgItemText findvisible, IDOK, GetInternalString (IS_FIND)
	    InitFindRange
    	InitCharRange
        
        If     f.Engine  = FM_ENGINE_REGEX          _
        OrElse f.fsearch = FM_RANGE_COMPILERINCPATH Then 
            InitRegEx
        EndIf
	    
	    FindDlgDisable
	EndIf

End Sub

Sub ShowStat()
	Dim As Integer i,bm,nFiles,nFounds,nRepeats,nErrors,nWarnings

	i=SendMessage(ah.hout,EM_GETLINECOUNT,0,0)
	While i>-1
		bm=SendMessage(ah.hout,REM_GETBOOKMARK,i,0)
		Select Case As Const bm
			Case BMT_STD
				nFounds+=1
		    Case BMT_REPEAT
				nRepeats+=1
			Case BMT_SPEC
				nFiles+=1
			Case BMT_WARN
				nWarnings+=1
			Case BMT_ERROR
				nErrors+=1
		End Select
		i-=1
	Wend
	If f.fsearch = FM_RANGE_PROJECT Then
		wsprintf(@buff,GetInternalString(IS_PROJECT_FILES_SEARCHED_INFO),10,10,10,nFiles,10,nFounds,10,nRepeats,10,10,10,nErrors,10,nWarnings)
	ElseIf f.fsearch = FM_RANGE_ALLTABS Then
		wsprintf(@buff,GetInternalString(IS_OPEN_FILES_SEARCHED_INFO),10,10,10,nFiles,10,nFounds,10,nRepeats,10,10,10,nErrors,10,nWarnings)
	Else
		wsprintf(@buff,GetInternalString(IS_REGION_SEARCHED_INFO),10,10,10,nFounds,10,nRepeats,10,10,10,nErrors,10,nWarnings)
	EndIf
    
	MessageBox(ah.hwnd,@buff,@szAppName,MB_OK Or MB_ICONINFORMATION)
     
End Sub

Function FindInFile(ByVal hWin As HWND,ByVal frType As Integer) As Integer

	Dim res        As Integer = Any 
	Dim nlen       As Integer = Any
	Dim hMem       As HGLOBAL = Any
    Dim EditorMode As Integer = Any 
    
    EditorMode = GetWindowLong (hWin, GWL_ID)
    
    If (EditorMode = IDC_TEXTED) OrElse (EditorMode = IDC_CODEED) then
	    SendMessage hWin, REM_SETMODE, 0, 0              ' MOD 22.2.2012 block mode off 
	    
	    Select Case f.Engine 
	    Case FM_ENGINE_STD
	        res = SendMessage (hWin, EM_FINDTEXTEX, frType, Cast (LPARAM, @f.ft))
	
	    Case FM_ENGINE_REGEX
	    	'nlen = SendMessage (hWin, WM_GETTEXTLENGTH, 0, 0)  
	    	'hMem = MyGlobalAlloc (GMEM_FIXED, nlen + 1)
	    	hMem = GetFileMem (hWin)
	    	If hMem Then
	        	'SendMessage hWin, WM_GETTEXT, nlen + 1, Cast (LPARAM, hMem)
	        	res = FindRegEx (hMem)
	            GlobalFree hMem
	    	Else 
	    		res = -1	
	    	EndIf
	    End Select
	    
		If res<>-1 Then                                   ' found
			If f.fdir = FM_DIR_UP Then
				f.ft.chrg.cpMin=f.ft.chrgText.cpMin-1
			Else
				f.ft.chrg.cpMin=f.ft.chrgText.cpMax
			EndIf
		Else                                              ' not found
			If f.fdir = FM_DIR_ALL And f.fsearch <> FM_RANGE_SELECTION Then 
				If f.chrginit.cpMin<>0 And f.ft.chrg.cpMax>f.chrginit.cpMax Then
					f.ft.chrg.cpMin=f.chrgrange.cpMin
					'f.ft.chrg.cpMax=f.chrginit.cpMax      'Regex version
					f.ft.chrg.cpMax=f.chrginit.cpMax-1   'Win32 version
					f.chrginit.cpMin=0
					res=FindInFile(hWin,frType)
				EndIf
			EndIf
		EndIf
		Return res
	Else
		Return -1
	EndIf
		
End Function

Function Find(ByVal hWin As HWND,ByVal frType As Integer) As Integer
	
	'Static Total As Integer 
	Dim isinp As ISINPROC
	Dim tci As TCITEM
	Dim p As ZString Ptr
	Dim sFile As ZString*260
	'Dim hMem As HGLOBAL
	'Dim ms As MEMSEARCH
	'Dim hREd As HWND                          ' MOD 16.2.2012   unused
	Dim hEditor As HWND = Any                  ' MOD 19.2.2012
	Dim i As Integer
	'Dim chrg As CHARRANGE                     ' MOD 17.2.2012
	Dim nLine As Integer

    ' MOD 17.2.2012
    'SetCursor LoadCursor (NULL, IDC_WAIT)
    SendMessage ah.hout, EM_EXSETSEL, 0, Cast (LPARAM, @Type<CHARRANGE>(-1, -1))
	'chrg.cpMin=-1
	'chrg.cpMax=-1
	'SendMessage(ah.hout,EM_EXSETSEL,0,Cast(LPARAM,@chrg))
	' ====================
	f.nlinesout=SendMessage(ah.hout,EM_GETLINECOUNT,0,0)
TryAgain:
	Select Case f.fsearch
	    Case FM_RANGE_PROC			' Current Procedure
			If f.fnoproc Then
				While TRUE
					f.fres=FindInFile(ah.hred,frType)
					If f.fres<>-1 Then
						isinp.nLine=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,f.ft.chrgText.cpMin)
						isinp.lpszType=StrPtr("p")
						If fProject Then
							tci.mask=TCIF_PARAM
							SendMessage(ah.htabtool,TCM_GETITEM,SendMessage(ah.htabtool,TCM_GETCURSEL,0,0),Cast(LPARAM,@tci))
							isinp.nOwner=pTABMEM->profileinx
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
		Case FM_RANGE_SELTAB	    	' Current Module
			f.fres=FindInFile(ah.hred,frType)
			'
		Case FM_RANGE_ALLTABS  			' All Open Files
            
            hEditor = ah.hred
            Do	    
	            f.fres = FindInFile (hEditor, frType)
	            If f.fres = -1 Then
      				If Len (f.listoffiles) = 0 Then Exit Do
      				i = InStr (f.listoffiles, ",")
    				f.ffileno = Val (f.listoffiles)
    				f.listoffiles = Mid (f.listoffiles, i + 1)
    				hEditor = GetEditWindowByTabID (f.ffileno) 
    				f.chrgrange.cpMin = 0
    				f.chrgrange.cpMax = SendMessage (hEditor, WM_GETTEXTLENGTH, 0, 0) + 1
    				If f.fdir = FM_DIR_UP Then
    				    f.chrginit = Type<CHARRANGE>(f.chrgrange.cpMax, f.chrgrange.cpMax)
    				Else
    					f.chrginit = Type<CHARRANGE>(0, 0)
    				EndIf
    				InitCharRange
    				f.fonlyonetime = 0
	            Else    
	                If hEditor <> ah.hred Then
					    SelectTabByWindow hEditor
					EndIf 
	                Exit Do
	            EndIf
            Loop
		
            'TheNextTab:
			'If f.fpro=1 Then
			'	While Len(f.listoffiles)
			'		i=InStr(f.listoffiles,",")
			'		f.ffileno=Val(Left(f.listoffiles,i-1))
			'		f.listoffiles=Mid(f.listoffiles,i+1)
			'		tci.mask=TCIF_PARAM
			'		SendMessage(ah.htabtool,TCM_GETITEM,f.ffileno,Cast(LPARAM,@tci))
			'		lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
			'		f.chrgrange.cpMin=0
			'		f.chrgrange.cpMax=SendMessage(lpTABMEM->hedit,WM_GETTEXTLENGTH,0,0)+1
			'		SendMessage(lpTABMEM->hedit,EM_EXGETSEL,0,Cast(LPARAM,@f.chrginit))
			'		InitCharRange
			'		f.fres=FindInFile(lpTABMEM->hedit,frType)
			'		If f.fres<>-1 Then
			'			f.fpro=2
			'			SelectTab(lpTABMEM->hedit,0)       ' MOD 1.2.2012 removed ah.hwnd
			'			f.fonlyonetime=0
			'			Exit While
			'		Else
			'			f.fpro=1
			'			GoTo TheNextTab
			'		EndIf
			'		f.fres=-1
			'	Wend
			'Else
			'    SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@f.chrginit))
			'    InitCharRange
			'	f.fres=FindInFile(ah.hred,frType)
			'	If f.fres=-1 Then
			'		f.fpro=1
			'		GoTo TheNextTab
			'	EndIf
			'EndIf

	    Case FM_RANGE_PROJECT			' All Project Files

            hEditor = ah.hred
            Do	    
	            f.fres = FindInFile (hEditor, frType)
	            If f.fres = -1 Then
      				If Len (f.listoffiles) = 0 Then Exit Do
      				i = InStr (f.listoffiles, ",")
    				f.ffileno = Val (f.listoffiles)
    				f.listoffiles = Mid (f.listoffiles, i + 1)
					OpenTheFile (*GetProjectFileName (f.ffileno, PT_ABSOLUTE), FOM_TXT_BG)
       				hEditor = GetEditWindowByFileID (f.ffileno) 
    				f.chrgrange.cpMin = 0
    				f.chrgrange.cpMax = SendMessage (hEditor, WM_GETTEXTLENGTH, 0, 0) + 1
    				If f.fdir = FM_DIR_UP Then
    				    f.chrginit = Type<CHARRANGE>(f.chrgrange.cpMax, f.chrgrange.cpMax)
    				Else
    					f.chrginit = Type<CHARRANGE>(0, 0)
    				EndIf
    				InitCharRange
                    f.fonlyonetime = 0
	            Else    
	                If hEditor <> ah.hred Then
					    SelectTabByWindow hEditor
					EndIf 
	                Exit Do
	            EndIf
            Loop
	    
            'TheNextFile:
			'Print "CASE 3 TheNextFile: fpro:"; f.fpro
			'If f.fpro=1 Then
			'	While Len(f.listoffiles)
			'		i=InStr(f.listoffiles,",")
			'		f.ffileno=Val(Left(f.listoffiles,i-1))
			'		f.listoffiles=Mid(f.listoffiles,i+1)
			'		sFile=GetProjectFileName(f.ffileno)
			'		If IsZStrNotEmpty (sFile) Then
			'			hMem=GetFileMem(sFile)
			'			If hMem Then
			'			    If f.Engine = 0 Then
    		'					ms.lpMem=hMem
    		'					ms.lpFind=@f.findbuff
    		'					ms.lpCharTab=ad.lpCharTab
    		'					' Memory search down is faster
    		'					ms.fr=f.fr Or FR_DOWN
    		'					f.fres=SendMessage(ah.hpr,PRM_MEMSEARCH,0,Cast(Integer,@ms))
    		'					GlobalFree(hMem)
			'			    Else
	        '                    f.ft.chrg.cpMin = 0 
	        '                    f.ft.chrg.cpMax = len(*Cast(ZString Ptr,hMem))
	        '                    Print "LEN:"; sFile, f.ft.chrg.cpMax
	        '                    f.fres = FindRegEx (hMem) + 1          ' -1 = not found
            '
			'			    EndIf
			'				If f.fres Then
			'					f.fnoreset=TRUE
			'					OpenProjectFile(f.ffileno)
			'					SetFocus(ah.hfind)
			'					f.fnoreset=FALSE
            '        			' MOD
            '        			f.chrginit.cpMin=0
            '        			f.chrginit.cpMax=0
			'					'SendMessage(ah.hred,EM_EXGETSEL,0,Cast(LPARAM,@f.chrginit))
            '        			'====================
			'					f.chrgrange.cpMin=0
			'					f.chrgrange.cpMax=SendMessage(ah.hred,WM_GETTEXTLENGTH,0,0)+1
			'					InitCharRange
			'					f.fpro=2
			'					f.fonlyonetime=0
			'					GoTo TheNextFile
			'				EndIf
			'			EndIf
			'		EndIf
			'	Wend
			'	f.fres=-1
			'Else
			'	f.fres=FindInFile(ah.hred,frType)
			'	If f.fres=-1 Then
			'		f.fpro=1
			'		GoTo TheNextFile
			'	EndIf
			'EndIf

    	'Case FM_RANGE_COMPILERINCPATH			' All .BI-Files in Compiler-Include-Path
        '    
        '    hEditor = ah.hred
        '    Do	    
	    '        f.fres = FindInFile (hEditor, frType)
	    '        If f.fres = -1 Then
		'			If hEditor <> ah.hred Then
		'			    DelTab(  GetTabIDByEditWindow(hEditor))
		'			EndIf
	    '            
    	'			GetSubStr f.listidx, f.listoffiles, sFile, Asc(",")
		'			If f.listidx = 0 Then Exit Do 
		'			OpenTheFile sFile, FOM_TXT_BG
       	'			'Total += 1
       	'		     	
       	'			hEditor = GetEditWindow (sFile) 
    	'			'Print Total;":";hEditor
    	'			If hEditor = 0 Then Exit Do 
    	'			f.chrgrange.cpMin = 0
    	'			f.chrgrange.cpMax = SendMessage (hEditor, WM_GETTEXTLENGTH, 0, 0) + 1
    	'			If f.fdir = FM_DIR_UP Then
    	'			    f.chrginit = Type<CHARRANGE>(f.chrgrange.cpMax, f.chrgrange.cpMax)
    	'			Else
    	'				f.chrginit = Type<CHARRANGE>(0, 0)
    	'			EndIf
    	'			InitCharRange
        '            f.fonlyonetime = 0
	    '        Else    
	    '            If hEditor <> ah.hred Then
		'			    SelectTabByWindow hEditor
		'			EndIf 
	    '            Exit Do
	    '        EndIf
        '    Loop 
			
		Case FM_RANGE_SELECTION			' Current selection
			f.fres=FindInFile(ah.hred,frType)
			'
	End Select
	If f.fres<>-1 Then
		If f.fskipcommentline Then
			i=SendMessage(ah.hred,REM_ISCHARPOS,f.ft.chrgText.cpMin,0)
			If i=1 Or i=2 Then
				If f.fdir = FM_DIR_UP Then
					f.ft.chrg.cpMin-=1
				Else        'all, down
					f.ft.chrg.cpMin+=1
				EndIf
				GoTo TryAgain
			EndIf
		EndIf
		If f.flogfind Then
			If f.fonlyonetime=0 Then
			    TextToOutput ad.filename
				'SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(LPARAM,@ad.filename))
				'SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(LPARAM,@CR))
				SendMessage(ah.hout,REM_SETBOOKMARK,f.nlinesout,BMT_SPEC)
				SendMessage(ah.hout,REM_SETBMID,f.nlinesout,0)
				f.fonlyonetime=1
				f.nlinesout+=1
			EndIf
			'buff=Chr(255) & Chr(1)
			nLine=SendMessage(ah.hred,EM_EXLINEFROMCHAR,0,f.fres)
			' MOD 21.1.2012
			GetLineByNo ah.hred, nLine, @buff
			TextToOutput " (" + Str (nLine + 1) + ") " + buff
			'chrg.cpMin=SendMessage(ah.hred,EM_LINEINDEX,nLine,0)
			'chrg.cpMax=SendMessage(ah.hred,EM_GETLINE,nLine,Cast(LPARAM,@buff))
			'buff[chrg.cpMax]=NULL
			'lstrcpy(@s," (")
			'lstrcat(@s,Str(nLine+1))
			'lstrcat(@s,") ")
			'lstrcat(@s,@buff)
			'SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(LPARAM,@s))
			'SendMessage(ah.hout,EM_REPLACESEL,FALSE,Cast(LPARAM,@CR))
			' ===========================
			i=SendMessage(ah.hred,REM_GETBOOKMARK,nLine,0)
			If i<>BMT_STD Then
				SendMessage(ah.hout,REM_SETBOOKMARK,f.nlinesout,BMT_STD)
				SendMessage(ah.hred,REM_SETBOOKMARK,nLine,BMT_STD)
				i=SendMessage(ah.hout,REM_GETBMID,f.nlinesout,0)
				SendMessage(ah.hred,REM_SETBMID,nLine,i)
			Else
				SendMessage(ah.hout,REM_SETBOOKMARK,f.nlinesout,BMT_REPEAT)
				SendMessage(ah.hout,REM_SETBMID,f.nlinesout,0)
			EndIf
			f.nlinesout+=1
		EndIf
		' Mark the found text
		ad.fNoNotify=TRUE
		SendMessage(ah.hred,EM_EXSETSEL,0,Cast(LPARAM,@f.ft.chrgText))
		SendMessage(ah.hred,REM_VCENTER,0,0)
		SendMessage(ah.hred,EM_SCROLLCARET,0,0)
		ad.fNoNotify=FALSE
	Else
		Select Case f.fsearch
			Case FM_RANGE_PROJECT				' Project Files searched
				buff=GetInternalString(IS_PROJECT_FILES_SEARCHED)
			Case Else            				' Region searched
				buff=GetInternalString(IS_REGION_SEARCHED)
		End Select
		If f.nreplacecount Then
			buff &= CR & CR & Str(f.nreplacecount) & " " & GetInternalString(IS_REPLACEMENTS_DONE)
		EndIf
		
		' MOD 20.2.2012
		If f.flogfind Then HLineToOutput
	    If findvisible Then
       	    SetFindMsg buff, IDI_ASTERISK
            MessageBeep MB_ICONASTERISK
        Else      			
		    MessageBox hWin, @buff, @szAppName, MB_OK Or MB_ICONINFORMATION
	    EndIf 
		'If f.flogfind Then
        '    ShowStat()                                      
		'Else                                                
		'    MessageBox(hWin,@buff,@szAppName,MB_OK Or MB_ICONINFORMATION)
		'EndIf 
		' ======================
        ResetFind
	EndIf
	Return f.fres

End Function

Sub LoadFindHistory ()

	Dim i                 As Integer 
	Dim sItem             As ZString * 260
	Dim SaveFlags(1 To 6) As Integer              ' MOD 23.2.2012 add
	
	For i = 1 To 9
		If GetPrivateProfileString (@"Find", Str (i), NULL, @sItem, SizeOf (sItem), @ad.IniFile) Then
			FindHistory(i - 1) = sItem
		Else
			Exit For
		EndIf
	Next
	
	' MOD 23.2.2012
	LoadFromIni "Find", "Flags", "444444", @SaveFlags(1), FALSE 

    f.Engine           = SaveFlags(1)
    f.fdir             = SaveFlags(2)
    f.fr               = SaveFlags(3)
    f.fskipcommentline = SaveFlags(4)
    f.flogfind         = SaveFlags(5)
    f.fsearch          = SaveFlags(6)
    '=================
End Sub

Sub SaveFindHistory()
	
	Dim As Integer i
    Dim SaveFlags (1 To 6) As Integer => { f.Engine,           _     ' MOD 23.2.2012 add
                                           f.fdir,             _
                                           f.fr,               _
                                           f.fskipcommentline, _
                                           f.flogfind,         _
                                           f.fsearch }

	For i=1 To 9
		WritePrivateProfileString @"Find", Str (i), @FindHistory(i - 1), @ad.IniFile
	Next
    SaveToIni @"Find", @"Flags", "444444", @SaveFlags(1), FALSE       ' MOD 23.2.2012 add
    
End Sub

Sub UpdateFindHistory(ByVal hWin As HWND)
	
	If IsZStrNotEmpty (f.findbuff) AndAlso SendMessage(hWin,CB_FINDSTRINGEXACT,-1,Cast(LPARAM,@f.findbuff))=CB_ERR Then
		SendMessage(hWin,CB_INSERTSTRING,0,Cast(LPARAM,@f.findbuff))
	EndIf

End Sub

Sub UpDateFind(ByVal hWin As HWND,ByVal cpMin As Integer,ByVal fChanged As Integer)
	
	Dim    i         As Integer 
	Dim    nSize     As integer    
    Static nLasthWin As HWND
    Static nLastCp   As Integer

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
			CH.Shift (hWin, nLastCp, nSize)
		EndIf
		nLastSize+=nSize
	EndIf
	nLastCp=cpMin

End Sub

Sub FindAllOutside
    
    Dim LineNo          As Integer              = Any
    Dim LineStr         As ZString * 1024
    Dim FileSpec        As ZString * MAX_PATH 
    Dim hMem            As HGLOBAL              = Any
    Dim cpMin           As Integer              = Any 
    Dim cpMax           As Integer              = Any 
    Dim RegExMatch      As regmatch_t
  	Dim OutputLine      As Integer              = Any
	Dim HeadLineWritten As BOOLEAN              = Any 
    
	UpdateFindHistory GetDlgItem (ah.hfind, IDC_FINDTEXT)
	ClearFindMsg
    ResetFind
    If Len (f.listoffiles) = 0 Then Exit Sub 

    OutputLine = SendMessage (ah.hout, EM_GETLINECOUNT, 0, 0) 
    f.Busy = TRUE
    
    Do
        'SetCursor LoadCursor (NULL, IDC_WAIT)
    	GetSubStr f.listidx, *StrPtr (f.listoffiles), FileSpec, SizeOf (FileSpec), CUByte (Asc (","))
	    If f.listidx = 0 Then Exit Do 
        hMem = GetFileMem (FileSpec)
        HeadLineWritten = FALSE 
        
        If hMem Then
            cpMin = 0 
            cpMax = lstrlen (Cast (ZString Ptr, hMem))
            SendDlgItemMessage ah.hfind, IDC_TXT_FINDMSG, WM_SETTEXT, 0, Cast (LPARAM, @FileSpec)

            Do
                DoEvents NULL
                If f.Busy = FALSE Then 
                	 GlobalFree hMem
                	 Exit Do, Do   
                EndIf
        
            	If RegNExec (f.RegEx, hMem + cpMin, cpMax - cpMin, 1, RegExMatch, 0) Then
            	    Exit Do  
            	Else
  			        If HeadLineWritten = FALSE Then 
               			TextToOutput FileSpec
            			SendMessage ah.hout, REM_SETBOOKMARK, OutputLine, BMT_SPEC
                        OutputLine += 1
                        HeadLineWritten = TRUE
  			         EndIf
                   
            	    GetLineFromChar *Cast (ZString Ptr, hMem), cpMin + RegExMatch.rm_so, LineStr, SizeOf(LineStr), LineNo  
                    cpMin += RegExMatch.rm_eo
           			TextToOutput " (" + Str (LineNo) + ") " + LineStr
    				SendMessage ah.hout, REM_SETBOOKMARK, OutputLine, BMT_STD
                    OutputLine += 1
            	EndIf
            Loop
            GlobalFree hMem 
        EndIf
    Loop

    If f.Busy Then
        HLineToOutput
    	buff = GetInternalString (IS_COMPILER_INCPATH_SEARCHED)
        SetFindMsg buff, IDI_ASTERISK
        MessageBeep MB_ICONASTERISK
    Else
        TextToOutput "cancelled"
        HLineToOutput
		buff = GetInternalString (IS_SEARCH_CANCELLED)
        SetFindMsg buff, IDI_EXCLAMATION        
        MessageBeep MB_ICONEXCLAMATION
    EndIf
    
    f.Busy = FALSE 
    ResetFind 
     
End Sub

Sub FindAllInside

    UpdateFindHistory GetDlgItem (ah.hfind, IDC_FINDTEXT)
	ClearFindMsg
	
	f.Busy = TRUE 
	ResetFind 
    	
	Do
        Find ah.hfind, f.fr
        DoEvents NULL
        If f.Busy = FALSE Then
   		    TextToOutput "cancelled"
   		    HLineToOutput
    	    SendDlgItemMessage ah.hfind, IDC_IMG_FINDMSG, STM_SETICON, Cast (WPARAM, LoadIcon (NULL, IDI_EXCLAMATION)), 0
    		buff = GetInternalString (IS_SEARCH_CANCELLED)
    		SendDlgItemMessage ah.hfind, IDC_TXT_FINDMSG, WM_SETTEXT, 0, Cast (LPARAM, @buff)		
            MessageBeep MB_ICONEXCLAMATION 
            Exit Do 
        EndIf
	Loop Until f.fres = -1
    
    f.Busy = FALSE    
    ResetFind 
    
End Sub

Function FindDlgProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer

	Dim id      As Integer = Any 
	Dim Event   As Integer = Any 
	Dim Result  As Integer = Any
	Dim x       As Integer = Any  
	Dim hCtl    As HWND    = Any 
	Dim chrg    As CHARRANGE
	Dim rect    As RECT    = Any        
    Static hBMP As HBITMAP = Any 
    
	Select Case uMsg
	    Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_FINDDLG)
			findvisible=hWin
			If lParam Then
				PostMessage hWin, WM_COMMAND, MAKEWPARAM (IDC_BTN_REPLACE, BN_CLICKED), 0
			EndIf
			' Fill ComboBox
			hCtl=GetDlgItem(hWin,IDC_FINDTEXT)
			For id = 0 To 8
				If IsZStrNotEmpty (FindHistory(id)) Then
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
			CheckDlgButton(hWin,IDC_CHK_USE_REGEX,IIf(f.Engine,BST_CHECKED,BST_UNCHECKED))
			' Set find direction
			Select Case f.fdir
				Case FM_DIR_ALL
					id=IDC_RBN_ALL
			    Case FM_DIR_DOWN
					id=IDC_RBN_DOWN
			    Case FM_DIR_UP
					id=IDC_RBN_UP
			End Select
			CheckDlgButton(hWin,id,BST_CHECKED)
			
			'EnableWindow(GetDlgItem(hWin,IDC_RBN_SELECTION),f.ft.chrg.cpMin<>f.ft.chrg.cpMax)
			CheckDlgButton(hWin,IDC_CHK_SKIPCOMMENTS,IIf(f.fskipcommentline,BST_CHECKED,BST_UNCHECKED))
			CheckDlgButton(hWin,IDC_CHK_LOGFIND,IIf(f.flogfind,BST_CHECKED,BST_UNCHECKED))
			'EnableWindow(GetDlgItem(hWin,IDC_BTN_FINDALL),f.flogfind)
			'EnableWindow(GetDlgItem(hWin,IDC_RBN_PROJECTFILES),fProject)
			SetWindowPos(hWin,0,wpos.ptfind.x,wpos.ptfind.y,0,0,SWP_NOSIZE)
            hBMP = LoadImage (hInstance, MAKEINTRESOURCE (IDC_HELPICON), IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS)
            SendDlgItemMessage hWin, IDC_BTN_REGEX_HELP, BM_SETIMAGE, IMAGE_BITMAP, Cast (LPARAM, hBMP)			
			'f.fpro=0
			'ResetFind
			'
		Case WM_ACTIVATE
			If wParam<>WA_INACTIVE Then
				ah.hfind=hWin
                ' translate    			
    			Select Case f.fsearch
    			Case FM_RANGE_SELECTION
    			    id = IDC_RBN_SELECTION
    			Case FM_RANGE_PROC
    			    id = IDC_RBN_PROCEDURE
    			Case FM_RANGE_SELTAB
    			    id = IDC_RBN_CURRENTFILE
    			Case FM_RANGE_PROJECT
    			    id = IDC_RBN_PROJECTFILES
    			Case FM_RANGE_ALLTABS
    			    id = IDC_RBN_OPENFILES
    			Case FM_RANGE_COMPILERINCPATH
	                id=IDC_RBN_INCLUDEPATH   		    
    			End Select
    			'validate and downgrade
    			If id = IDC_RBN_SELECTION Then
			        SendMessage ah.hred, EM_EXGETSEL, 0, Cast (LPARAM, @chrg)		
					If chrg.cpMin = chrg.cpMax Then
					    id = IDC_RBN_CURRENTFILE                 ' selection removed while Dlg unfocus
					EndIf
    			EndIf
                If id = IDC_RBN_PROCEDURE Then
                    If GetWindowLong (ah.hred, GWL_ID) <> IDC_CODEED Then
                        id = IDC_RBN_PROJECTFILES
                    EndIf          
                EndIf
                If id = IDC_RBN_CURRENTFILE Then
                	If     GetWindowLong (ah.hred, GWL_ID) = IDC_RESED _
                    OrElse GetWindowLong (ah.hred, GWL_ID) = IDC_HEXED Then
                        id = IDC_RBN_PROJECTFILES
                    EndIf          
                EndIf
    			If id = IDC_RBN_PROJECTFILES Then
    			    If fProject = FALSE  Then
    			        id = IDC_RBN_OPENFILES
    			    EndIf
    			EndIf
    			If id = IDC_RBN_OPENFILES Then
    				Select Case CountCodeEdTabs
					Case 0
					    id = IDC_RBN_INCLUDEPATH
					Case 1
					    id = IDC_RBN_CURRENTFILE 
					End Select
    			EndIf 

                SendDlgItemMessage hWin, id, BM_CLICK, 0, 0
                ResetFind 
			EndIf
			'
	    'Case WM_SETFOCUS 
	    '    Print "Find:WM_SETFOCUS"
	        '
    	Case WM_COMMAND
			id=LoWord(wParam)
			Event=HiWord(wParam)
			If Event=BN_CLICKED Then
				Select Case id
					Case IDOK
				        If IsDlgItemEnabled (hWin, IDOK) Then	' if button click was on queue, before disabling take effect
							If f.fdir = FM_DIR_UP Then
								buff=GetInternalString(IS_PREVIOUS)
							Else
								buff=GetInternalString(IS_NEXT)
							EndIf
							SendMessage(GetDlgItem(hWin,IDOK),WM_SETTEXT,0,Cast(LPARAM,@buff))
							UpdateFindHistory(GetDlgItem(hWin,IDC_FINDTEXT))
	                        ClearFindMsg
							Find(hWin,f.fr)
				        EndIf
						'
					Case IDCANCEL
               			If f.Busy Then
               			    f.Busy = FALSE 
               			Else
                            SendMessage hWin, WM_CLOSE, 0, 0
               			EndIf
						'
					Case IDC_BTN_REPLACE
				        If IsDlgItemEnabled (hWin, IDC_BTN_REPLACE) Then
							If IsWindowVisible(GetDlgItem(hWin,IDC_REPLACETEXT))=FALSE Then
								' Enable Replace all button
							    EnableDlgItem(hWin,IDC_BTN_REPLACEALL,TRUE)
								' Set caption to Replace...
								SetWindowText(hWin,GetInternalString(IS_REPLACE))
								' Show replace
								ShowWindow(GetDlgItem(hWin,IDC_REPLACESTATIC),SW_SHOWNA)
								ShowWindow(GetDlgItem(hWin,IDC_REPLACETEXT),SW_SHOWNA)
								SetFocus GetDlgItem (hWin, IDC_REPLACETEXT)      ' MOD 20.2.2012  add
							Else
								If f.fres<>-1 Then
									f.nreplacecount+=1
									SendMessage(ah.hred,EM_REPLACESEL,TRUE,Cast(Integer,@f.replacebuff))
									If f.fdir = FM_DIR_UP Then
										f.ft.chrg.cpMin=f.ft.chrg.cpMin-1
									EndIf
								EndIf
								ClearFindMsg
								Find(hWin,f.fr)
							EndIf 
						EndIf
						'
					Case IDC_BTN_FINDALL
                        If IsDlgItemEnabled (hWin, IDC_BTN_FINDALL) Then
	                        If f.fsearch = FM_RANGE_COMPILERINCPATH Then
	                            FindAllOutside
	                        Else
	                            FindAllInside   
	                        EndIf
                        EndIf 
                        
				    Case IDC_BTN_REPLACEALL
				        If IsDlgItemEnabled (hWin, IDC_BTN_REPLACEALL) Then
					        ClearFindMsg
							If f.fres=-1 Then
								Find(hWin,f.fr)
							EndIf
							Do While f.fres<>-1
								SendMessage hWin, WM_COMMAND, MAKEWPARAM (IDC_BTN_REPLACE, BN_CLICKED), 0
							Loop
							ResetFind
				        EndIf 
				        	
					' MOD 15.2.2012     add
				    Case IDC_BTN_CLR_OUTPUT
                        SendMessage ah.hout, WM_SETTEXT, 0, Cast (lparam, @"")
				        UpdateAllTabs(6)            'clear bookmarks  

                    Case IDC_BTN_REGEX_HELP
						GetPrivateProfileString @"Help", @"FbEdit", NULL, @buff, MAX_PATH, @ad.IniFile
						If IsZStrNotEmpty (buff) Then
				            ExpandStrByEnviron buff
    				        s = "Regular Expression"
	    			        HH_Help
						Else
						    IniKeyNotFoundMsg "Help", "FbEdit"
						EndIf
				
				    Case IDC_BTN_REGEX_LIB
    					Result = DialogBoxParam (hInstance, MAKEINTRESOURCE (IDD_DLGOPTMNU), hWin, @GenericOptDlgProc, GODM_RegExLib)
                        If Result > 0 Then
               			    GetPrivateProfileString @"RegExLib", Str (Result), NULL, @buff, GOD_EntrySize, @ad.IniFile
                            If IsZStrNotEmpty (buff) Then
                                x = InStr (buff, ",")    
                                SendDlgItemMessage hWin, IDC_FINDTEXT, WM_SETTEXT, 0, Cast (LPARAM, @buff[x])
                                f.findbuff = *@buff[x]
                                ResetFind  
                            EndIf 
                        EndIf
                        
				    Case IDC_CHK_USE_REGEX  
				        Select Case f.Engine
				        Case FM_ENGINE_STD       
				            f.Engine = FM_ENGINE_REGEX     ' sorry, searching only forward
				            f.fnoreset = TRUE
				            If f.fdir = FM_DIR_UP Then SendDlgItemMessage hWin, IDC_RBN_ALL, BM_CLICK, 0, 0
				            If f.fr And FR_WHOLEWORD Then SendDlgItemMessage hWin, IDC_CHK_WHOLEWORD, BM_CLICK, 0, 0
				            f.fnoreset = FALSE
				        Case FM_ENGINE_REGEX
				            f.Engine = FM_ENGINE_STD
				        End Select
				        ResetFind
				    '==========================
				        
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
						ResetFind
						'
				    Case IDC_RBN_ALL
				        If f.fdir <> FM_DIR_ALL Then
						    f.fdir = FM_DIR_ALL
						    ResetFind
						EndIf     
						'
				    Case IDC_RBN_DOWN
				        If f.fdir <> FM_DIR_DOWN Then
				        	f.fdir = FM_DIR_DOWN    
						    ResetFind
				        EndIf    
						'
				    Case IDC_RBN_UP
						If f.fdir <> FM_DIR_UP Then 
						    f.fdir = FM_DIR_UP
						    ResetFind
						EndIf    
						'
					Case IDC_RBN_PROCEDURE
						If f.fsearch <> FM_RANGE_PROC Then
						    f.fsearch = FM_RANGE_PROC
						    ResetFind
						EndIf    
						'
					Case IDC_RBN_CURRENTFILE
						If f.fsearch <> FM_RANGE_SELTAB Then
						    f.fsearch = FM_RANGE_SELTAB
						    ResetFind
						EndIf     
						'
					Case IDC_RBN_OPENFILES
						If f.fsearch <> FM_RANGE_ALLTABS Then
						    f.fsearch = FM_RANGE_ALLTABS
						    ResetFind
						EndIf     
						'
					Case IDC_RBN_PROJECTFILES
						If f.fsearch <> FM_RANGE_PROJECT Then
						    f.fsearch = FM_RANGE_PROJECT
						    ResetFind
						EndIf    
						'
				    Case IDC_RBN_INCLUDEPATH
						f.fsearch = FM_RANGE_COMPILERINCPATH
						f.fnoreset = TRUE 
						If f.fdir <> FM_DIR_ALL  Then SendDlgItemMessage hWin, IDC_RBN_ALL,          BM_CLICK, 0, 0
						If f.flogfind = FALSE    Then SendDlgItemMessage hWin, IDC_CHK_LOGFIND,      BM_CLICK, 0, 0
						If f.fskipcommentline    Then SendDlgItemMessage hWin, IDC_CHK_SKIPCOMMENTS, BM_CLICK, 0, 0
                        If f.fr And FR_WHOLEWORD Then SendDlgItemMessage hWin, IDC_CHK_WHOLEWORD,    BM_CLICK, 0, 0						
						f.fnoreset = FALSE
						ResetFind
						'
					Case IDC_RBN_SELECTION
						If f.fsearch <> FM_RANGE_SELECTION Then
						    f.fsearch = FM_RANGE_SELECTION
						    ResetFind
						EndIf    
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
	        f.Busy = FALSE                      ' stoppit if running
			DestroyWindow(hWin)
            DeleteObject hBMP 
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
