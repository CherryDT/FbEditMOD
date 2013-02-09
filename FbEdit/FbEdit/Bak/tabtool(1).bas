

#Include Once "windowsUR.bi"

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAResEd.bi"
#Include Once "Inc\RAHexEd.bi"
#Include Once "Inc\RAProperty.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\CodeComplete.bi"
#Include Once "Inc\CoTxEd.bi"
#Include Once "Inc\CoTxEdOpt.bi"
#Include Once "Inc\Environment.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\FileIO.bi"
#Include Once "Inc\FileMonitor.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\HexEd.bi"
#Include Once "Inc\Language.bi"
#Include Once "Inc\Misc.bi"
#Include Once "Inc\Project.bi"
#Include Once "Inc\Property.bi"
#Include Once "Inc\SpecHandling.bi"
'#Include Once "Inc\Statusbar.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\TabTool.bi"
#Include Once "showvarsUR.bi"



#Define IDC_LSTFILES				1001
#Define IDC_BTNSELECT				1002
#Define IDC_BTNDESELECT				1003


Dim Shared fUnicode         As Integer
Dim Shared lpOldTabToolProc As WNDPROC
Dim Shared curtab           As Integer = -1
Dim Shared prevtab          As Integer = -1


Sub SaveProjectTabOrder ()

	Dim tci       As TCITEM
	Dim i         As Integer = 0
  	Dim sTabOrder As String
    Dim FirstItem As BOOL    = TRUE  

	tci.mask = TCIF_PARAM
	Do
		If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
		    If pTABMEM->profileinx Then
			    If FirstItem Then
			        sTabOrder = Str (pTABMEM->profileinx)
			        FirstItem = FALSE
			    Else 
			        sTabOrder += "," + Str (pTABMEM->profileinx)
			    EndIf
			EndIf
    		i += 1
		Else
			Exit Do 
		EndIf
	Loop

	WritePrivateProfileString @"TabOrder", @"TabOrder"  , sTabOrder               , @ad.ProjectFile
    WritePrivateProfileString @"TabOrder", @"CurrentTab", Str (GetFileIDByCurrTab), @ad.ProjectFile   ' writes 0, if curr tab = non project tab 

End Sub

Sub SetTabLock (ByVal TabID As Integer, ByVal NewState As BOOL)

	Dim tci      As TCITEM

	tci.mask = TCIF_PARAM
	If SendMessage (ah.htabtool, TCM_GETITEM, TabID, Cast (LPARAM, @tci)) Then
		If NewState = TRUE Then
            pTABMEM->locked = TRUE
		    SendMessage ah.htabtool, TCM_HIGHLIGHTITEM, TabID, TRUE 
		Else
		    pTABMEM->locked = FALSE
		    SendMessage ah.htabtool, TCM_HIGHLIGHTITEM, TabID, FALSE
		EndIf
	EndIf
           
End Sub

Function GetTabLock (ByVal TabId As Integer) As BOOL 

	Dim tci      As TCITEM

	tci.mask = TCIF_PARAM

	If SendMessage (ah.htabtool, TCM_GETITEM, TabID, Cast (LPARAM, @tci)) Then
		Return pTABMEM->locked 
	EndIf
    
End Function

Sub ToggleTabLock (ByVal TabId As Integer)

	Dim tci      As TCITEM

	tci.mask = TCIF_PARAM

	If SendMessage (ah.htabtool, TCM_GETITEM, TabID, Cast (LPARAM, @tci)) Then
		If pTABMEM->locked = TRUE Then
		    pTABMEM->locked = FALSE    
            SendMessage ah.htabtool, TCM_HIGHLIGHTITEM, TabID, FALSE
        Else
		    pTABMEM->locked = TRUE     
            SendMessage ah.htabtool, TCM_HIGHLIGHTITEM, TabID, TRUE 
		EndIf
	EndIf
	
End Sub

Function GetTabLockByCurrTab () As Integer  

	Dim tci      As TCITEM
	Dim CurrTab  As Integer    = Any 

	tci.mask = TCIF_PARAM
	CurrTab = SendMessage (ah.htabtool, TCM_GETCURSEL, 0, 0)

	If CurrTab <> INVALID_TABID Then
		If SendMessage (ah.htabtool, TCM_GETITEM, CurrTab, Cast (LPARAM, @tci)) Then
			Return pTABMEM->locked
		EndIf 
	EndIf

	Return INVALID_TABID

End Function

Sub SetFileIDByTabID (ByVal TabID As Integer, ByVal NewFileID As Integer)

	Dim tci      As TCITEM

	tci.mask = TCIF_PARAM

	If SendMessage (ah.htabtool, TCM_GETITEM, TabId, Cast (LPARAM, @tci)) Then
        pTABMEM->profileinx = NewFileID
	EndIf
   
End Sub

Sub Tab2Project ()

	Dim tci      As TCITEM
	Dim CurrTab  As Integer    = Any 
    
    If fProject Then
    	tci.mask = TCIF_PARAM
    	CurrTab = SendMessage (ah.htabtool, TCM_GETCURSEL, 0, 0)
    
    	If CurrTab <> INVALID_TABID Then
    		If SendMessage (ah.htabtool, TCM_GETITEM, CurrTab, Cast (LPARAM, @tci)) Then
   				AddAProjectFile pTABMEM->filename, FALSE, FALSE 
    		EndIf 
    	EndIf
    EndIf

End Sub

Function CountCodeEdTabs () As Integer

	Dim tci        As TCITEM
	Dim i          As Integer = 0
    Dim Count      As Integer = 0
    Dim EditorMode As Integer = Any 
    
	tci.mask = TCIF_PARAM
	
	Do
		If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
     		EditorMode = GetWindowLong (pTABMEM->hedit, GWL_ID)
     		If (EditorMode = IDC_CODEED) OrElse (EditorMode = IDC_TEXTED) Then
				Count += 1
			EndIf
		    i += 1
		Else
			Return Count
		EndIf
	Loop
    
End Function

Function GetEditWindowByFileID (ByVal FileID As Integer) As HWND 

	Dim tci      As TCITEM
	Dim i        As Integer    = 0
	
	tci.mask = TCIF_PARAM

	Do
		If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
		    If pTABMEM->profileinx = FileID Then
				Return pTABMEM->hedit
			EndIf
    		i += 1
		Else
	        Return 0
		EndIf
	Loop

End Function

Function GetEditWindowByTabID (ByVal TabID As Integer) As HWND 

    ' TabID = 0 ... n  (zerobased)
    
	Dim tci As TCITEM
	
	tci.mask = TCIF_PARAM

	If SendMessage (ah.htabtool, TCM_GETITEM, TabID, Cast (LPARAM, @tci)) Then
        Return pTABMEM->hedit
    Else
        Return 0
	EndIf
	
End Function

Function GetEditWindowBySpec (Byref fn As ZString) As HWND     ' MOD 1.2.2012   (ByVal hWin As HWND,ByVal fn As String,ByVal fShow As Boolean) As HWND

	Dim tci      As TCITEM
	'Dim hOld As HWND
	Dim i        As Integer    = 0 

	tci.mask=TCIF_PARAM

	Do
		If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(Integer,@tci)) Then
		    If lstrcmpi(fn,pTABMEM->filename)=0 Then
                ' MOD 3.2.2012  removed, call function ShowTab
				'If fShow Then
				'	SelectTab(lpTABMEM->hedit,0)         ' MOD 1.2.2012 removed ah.hwnd
				'	SetFocus(ah.hred)
				'EndIf
				Return pTABMEM->hedit
			EndIf
			i += 1
		Else
			Return 0
		EndIf
	Loop

End Function

Function GetEditWindowByFocus () As HWND 
    
    If ah.hred = GetParent (GetFocus ()) Then
        Return ah.hred
    Else
        Return 0
    EndIf
    
End Function

Function ShowTab (ByRef FileSpec As ZString) As BOOLEAN
    
    Dim hEdit As HWND = Any
    
    hEdit = GetEditWindowBySpec (FileSpec)
    
    If hEdit Then
		SelectTabByWindow hEdit
		SetFocus ah.hred
        Return TRUE 
    Else
        Return FALSE 
    EndIf

End Function

Sub GetResTabID (ByRef ResTabID As Integer, ByRef ResFileSpec As String)  
    
	Dim tci      As TCITEM
    
    ResTabID = 0
	tci.mask = TCIF_PARAM
	Do
		If SendMessage (ah.htabtool, TCM_GETITEM, ResTabID, Cast (LPARAM, @tci)) Then
			If GetWindowLong (pTABMEM->hedit, GWL_ID) = IDC_RESED Then
				ResFileSpec = pTABMEM->filename
				Exit Sub 
			EndIf
		    ResTabID += 1
		Else
			ResFileSpec = ""
			ResTabID = INVALID_TABID      ' not found
			Exit Sub 
		EndIf
	Loop
   
End Sub 

Function GetTabIDByEditWindow (ByVal hEditor As HWND) As Integer  
    
	Dim tci      As TCITEM
	Dim i        As Integer = 0

	tci.mask = TCIF_PARAM
	Do
		If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
			If pTABMEM->hedit = hEditor Then
				Return i
			EndIf
		    i += 1
		Else
			Return INVALID_TABID      ' not found
		EndIf
	Loop
   
End Function

Function GetTabIDByFileID (ByVal FileID As Integer)	As Integer

	Dim tci      As TCITEM
	Dim TabID    As Integer = 0

	tci.mask = TCIF_PARAM
	Do
		If SendMessage (ah.htabtool, TCM_GETITEM, TabID, Cast (LPARAM, @tci)) Then
			If pTABMEM->profileinx = FileID Then
				Return TabID
			EndIf
		    TabID += 1
		Else
			Return INVALID_TABID      ' not found
		EndIf
	Loop

End Function

Sub GetTabIDBySpec (ByRef FileSpec As ZString, ByRef TabID As Integer, ByRef EditorMode As Integer)  

	Dim tci As TCITEM

    TabID = 0
	tci.mask = TCIF_PARAM
	Do
		If SendMessage (ah.htabtool, TCM_GETITEM, TabID, Cast (LPARAM, @tci)) Then
			If lstrcmpi (FileSpec, pTABMEM->filename) = 0 Then
				EditorMode = GetWindowLong (pTABMEM->hedit, GWL_ID)
				Exit Sub   
			EndIf
		    TabID += 1
		Else
		    EditorMode = 0
			TabID = INVALID_TABID      ' not found
			Exit Sub 
		EndIf
	Loop
   
End Sub 

Sub NextTab(ByVal fPrev As Boolean)

	Dim n        As Integer    = Any 
	Dim i        As Integer    = Any 
	Dim tci      As TCITEM
	
	n=SendMessage(ah.htabtool,TCM_GETITEMCOUNT,0,0)
	If n>1 Then
		i=SendMessage(ah.htabtool,TCM_GETCURSEL,0,0)
		If fPrev Then
			i -= 1
			If i < 0 Then
				i = n - 1
			EndIf
		Else
			i += 1
			If i = n Then
				i = 0
			EndIf
		EndIf
		tci.mask=TCIF_PARAM
		SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(Integer,@tci))
		SelectTabByWindow(pTABMEM->hedit)                    ' MOD 1.2.2012 removed ah.hwnd
		SetFocus(ah.hred)
	EndIf

End Sub

Function WantToSaveTab (ByVal TabID As Integer) As BOOLEAN     ' MOD 9.2.2012 ADD
	
    ' TabID = 0 ... n  (zerobased)
    
	Dim tci      As TCITEM
	
	tci.mask = TCIF_PARAM
	
	If SendMessage (ah.htabtool, TCM_GETITEM, TabID, Cast (LPARAM, @tci)) Then
        		 			
		If pTABMEM->hedit = ah.hres Then                           ' update filestate if tab is current
			pTABMEM->filestate = SendMessage (ah.hraresed, PRO_GETMODIFY, 0, 0)
		ElseIf pTABMEM->hedit = ah.hred Then
			pTABMEM->filestate = SendMessage (ah.hred, EM_GETMODIFY, 0, 0)
		EndIf
		
		If pTABMEM->filestate Then
			Select Case  MessageBox(ah.hwnd,GetInternalString(IS_WANT_TO_SAVE_CHANGES),@szAppName,MB_YESNOCANCEL + MB_ICONQUESTION)
				Case IDYES                                         ' MOD 1.2.2012    MessageBox(hWin,GetInter...
					If Left (pTABMEM->filename, 10) = "(Untitled)" Then
						Return SaveTabAs () Xor TRUE              ' MOD 2.1.2012   SaveFileAs(hWin)
					Else
						WriteTheFile (pTABMEM->hedit, pTABMEM->filename)
					    Return FALSE 
					EndIf
					'
				Case IDCANCEL
					Return TRUE
					'
			End Select
		EndIf
    EndIf 
	Return FALSE

End Function

Function CloseTab (ByVal TabID As Integer, ByVal Mode As CloseTabMode = CTM_STD) As Integer   ' MOD 1.2.2012   DelTab(ByVal hWin As HWND)
	
	Dim tci       As TCITEM
	Dim CurrTabID As Integer    = Any 
	'Dim x         As Integer    = Any 
    
    tci.mask = TCIF_PARAM
    If SendMessage (ah.htabtool, TCM_GETITEM, TabID, Cast (LPARAM, @tci)) Then 

        If pTABMEM->locked = FALSE _ 
        OrElse edtopt.closeonlocks = TRUE Then
           
            If Mode And CTM_IGNORE_DIRTY _
            OrElse WantToSaveTab (TabID) = FALSE Then           ' MOD 1.2.2012    WantToSave(hWin)=FALSE
                
           		CurrTabID = SendMessage (ah.htabtool, TCM_GETCURSEL, 0, 0)

        		curtab = -1
        		prevtab = -1
        		CallAddins ah.hwnd, AIM_FILECLOSE, 0, Cast (LPARAM, @pTABMEM->filename), HOOK_FILECLOSE
        		If pTABMEM->profileinx Then
        		    If Mode And CTM_PROJECTCLOSE Then
        			    WriteProjectFileInfo pTABMEM->hedit, pTABMEM->profileinx, TRUE 
        		    Else
        		        WriteProjectFileInfo pTABMEM->hedit, pTABMEM->profileinx, FALSE
        		    EndIf    
        		EndIf
        		'SendMessage ah.hpr, PRM_DELPROPERTY, Cast (LPARAM, pTABMEM->hedit), 0
               	'SendMessage ah.hpr, PRM_REFRESHLIST, 0, 0
        		If pTABMEM->hedit <> ah.hres Then
        			'For x = 0 To 15
        			'	If fdc(x).hwnd = pTABMEM->hedit Then
        			'		fdc(x).hwnd = Cast (HWND, -1)
        			'	EndIf
        			'Next
        			DestroyWindow pTABMEM->hedit
        		Else
        			SendMessage ah.hraresed, PRO_CLOSE, 0, 0
        			ShowWindow pTABMEM->hedit, SW_HIDE
        		EndIf
        		ah.hpane(1) = 0
        		If pTABMEM->hedit = ah.hpane(0) Then
        			ah.hpane(0) = 0
        		EndIf
        		GlobalFree pTABMEM
        		SendMessage ah.htabtool, TCM_DELETEITEM, TabID, 0
        		If CurrTabID = TabID Then
            		If SendMessage (ah.htabtool, TCM_GETITEMCOUNT, 0, 0) Then
                        If TabID Then 
                            SelectTabByTabID TabID - 1
                        Else
                            SelectTabByTabID 0
                        EndIf
            			SetFocus ah.hred
            		Else
            			If wpos.fview And VIEW_TABSELECT Then
            				ShowWindow ah.htabtool, SW_HIDE
            			EndIf
            			ShowWindow ah.hshp, SW_SHOWNA
            			If ah.hfullscreen Then DestroyWindow ah.hfullscreen
            			SetZStrEmpty (ad.filename)             ' MOD 26.1.2012 
            			ah.hred = 0
            			ah.hpane(0) = 0
            			ah.hpane(1) = 0
            			SetEditorTypeInfo 0
            			SetWinCaption
                		SendMessage ah.hwnd, WM_SIZE, SIZE_RESTORED, 0
                		'fTimer = 1
            		EndIf
        		EndIf
            	'SendMessage ah.hpr, PRM_REFRESHLIST, 0, 0
            	HideCCLists
            	POL_Changed = TRUE
            	Return TRUE   ' success, tab closed
        	EndIf 
            Return FALSE      ' no success, saving prevented 
        EndIf 
        Return FALSE          ' no success, tab locked
    Else
        Return TRUE           ' tab wasnt present, nothing to do, but success
    EndIf   
End Function

'Sub CloseTab (ByVal TabID As Integer)                                 ' MOD 1.2.2012   DelTab(ByVal hWin As HWND)
'	Dim tci As TCITEM
'	Dim lpTABMEM As TABMEM Ptr
'	'Dim i As Integer
'	Dim x As Integer = Any 
'	
'	tci.mask=TCIF_PARAM
'	If TabID >= 0 Then
'		curtab=-1
'		prevtab=-1
'		SendMessage(ah.htabtool,TCM_GETITEM,TabID,Cast(Integer,@tci))
'		lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
'		CallAddins(ah.hwnd,AIM_FILECLOSE,0,Cast(LPARAM,@lpTABMEM->filename),HOOK_FILECLOSE)
'		If lpTABMEM->profileinx Then
'			WriteProjectFileInfo(lpTABMEM->hedit,lpTABMEM->profileinx,FALSE)
'		EndIf
'		SendMessage(ah.hpr,PRM_DELPROPERTY,Cast(Integer,lpTABMEM->hedit),0)
'		If lpTABMEM->hedit<>ah.hres Then
'			For x = 0 To 15
'				If fdc(x).hwnd=lpTABMEM->hedit Then
'					fdc(x).hwnd=Cast(HWND,-1)
'				EndIf
'			Next
'			DestroyWindow(lpTABMEM->hedit)
'		Else
'			SendMessage(ah.hraresed,PRO_CLOSE,0,0)
'			ShowWindow(lpTABMEM->hedit,SW_HIDE)
'		EndIf
'		ah.hpane(1)=0
'		If lpTABMEM->hedit=ah.hpane(0) Then
'			ah.hpane(0)=0
'		EndIf
'		GlobalFree(lpTABMEM)
'		SendMessage(ah.htabtool,TCM_DELETEITEM,TabID,0)
'	EndIf
'	SendMessage(ah.hpr,PRM_REFRESHLIST,0,0)
'	HideList()
'End Sub

Sub AddTab(ByVal hEdt As HWND, ByRef lpFileName As ZString, ByVal AddMode As AddTabMode)        'MOD2.2.2012    AddTab(ByVal hEdt As HWND,ByVal lpFileName As String,ByVal fHex As Boolean)

	Dim tci      As TCITEM
	'Dim i As Integer         MOD 27.1.2012
	'Dim x As Integer         MOD 27.1.2012
	Dim hFile    As HANDLE     = Any

    ' MOD 31.1.2012 
	'i=SendMessage(ah.htabtool,TCM_GETCURSEL,0,0)
	'buff=lpFileName
	'Do While InStr(buff,"\")
	'	buff=Mid(buff,InStr(buff,"\")+1)
	'Loop
    '========================
    If hEdt Then
    	pTABMEM=MyGlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,SizeOf(TABMEM))
    	'tci.lParam=MyGlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,SizeOf(TABMEM))
    	pTABMEM->hedit=hEdt
    	pTABMEM->filename=lpFileName
    	If fProject Then
    		pTABMEM->profileinx=GetFileID(lpFileName)
    	'Else
    	'	lpTABMEM->profileinx=0
    	EndIf
    	'lpTABMEM->locked=0
    	' Set file time
    	'hFile=CreateFile(lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL)
    	'If hFile<>INVALID_HANDLE_VALUE Then
    	'	GetFileTime(hFile,NULL,NULL,@pTABMEM->ft)
    	'	CloseHandle(hFile)
    	'EndIf
    	GetLastWriteTime lpFileName, @pTABMEM->ft
    	tci.mask=TCIF_TEXT Or TCIF_PARAM Or TCIF_IMAGE
      	tci.pszText = GetFileName (lpFileName)                           ' MOD 31.1.2012   tci.pszText=@buff
    	' MOD 30.1.2012
    	tci.iImage = GetFileImg (*tci.pszText, pTABMEM->profileinx)
    	'If lpTABMEM->profileinx = nMain Then
    	'    tci.iImage = 7
    	'ElseIf lpTABMEM->profileinx > 1000 Then
    	'	tci.iImage=6
    	'Else
    	'	tci.iImage=GetFileImg(buff)
    	'EndIf
    	' ======================
    	
    	'tci.lParam=Cast(LPARAM,lpTABMEM)
    	SendMessage (ah.htabtool, TCM_INSERTITEM, 999, Cast (LPARAM, @tci))       ' MOD 27.1.2012     x=SendMessage(ah.htabtool,TCM_INSERTITEM,999,Cast(Integer,@tci))
    	If wpos.fview And VIEW_TABSELECT Then
    		ShowWindow(ah.htabtool,SW_SHOWNA)
    	EndIf 
    	If ah.hpane(0)=0 Then
    		ShowWindow(ah.hshp,SW_HIDE)
    	Else
    		ah.hpane(1)=hEdt
    	EndIf
    
    	If AddMode = ATM_FOREGROUND Then      ' MOD 21.2.2012 add
        	SelectTabByWindow(hEdt)           ' MOD  1.2.2012 removed ah.hwnd
        	SetFocus(ah.hred)
        	'fTimer=1
    	EndIf 
    	POL_Changed = TRUE 
    EndIf
End Sub

Sub UpdateTab()
    
	Dim tci      As TCITEM
	Dim i        As Integer    = Any 

	i=SendMessage(ah.htabtool,TCM_GETCURSEL,0,0)
	tci.mask=TCIF_PARAM
	SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(Integer,@tci))
	' MOD 26.1.2012 
	'buff=ad.filename         
	'Do While InStr(buff,"\")
	'	buff=Mid(buff,InStr(buff,"\")+1)
	'Loop
    ' ================================	
	pTABMEM->filename=ad.filename
	tci.mask=TCIF_TEXT
	tci.pszText = GetFileName (ad.filename)                           ' MOD 26.1.2012   tci.pszText=@buff
    ' MOD 30.1.2012
    tci.iImage = GetFileImg (*tci.pszText, pTABMEM->profileinx)      ' MOD 26.1.2012   tci.iImage = GetFileImg (buff)	
	'If lpTABMEM->profileinx = nMain Then
	'    tci.iImage = 7
	'ElseIf lpTABMEM->profileinx > 1000 Then
	'	tci.iImage = 6
	'Else
	'	tci.iImage = GetFileImg (*tci.pszText)
	'EndIf
	' ======================

	SendMessage(ah.htabtool,TCM_SETITEM,i,Cast(Integer,@tci))

End Sub

'Sub SelectTab (ByVal hEdit As HWND,ByVal nInx As Integer)
'	'MOD 1.2.2012 Sub SelectTab(ByVal hWin As HWND,ByVal hEdit As HWND,ByVal nInx As Integer)
'	
'	Dim tci      As TCITEM
'	Dim hOld     As HWND       = Any
'	Dim lpTABMEM As TABMEM Ptr = Any
'	Dim i        As Integer    = Any 
'   'Dim BlockMode As Long        ' MOD 20.1.2012 ADD
'
'	tci.mask=TCIF_PARAM
'	i=0
'	While TRUE
'		If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(Integer,@tci)) Then
'			lpTABMEM=Cast(TABMEM Ptr,tci.lParam)
'			If (lpTABMEM->hedit=hEdit And hEdit<>0) Or (lpTABMEM->profileinx=nInx And nInx<>0) Then
'        		SendMessage(ah.htabtool,TCM_SETCURFOCUS,i,0)
'				SendMessage(ah.htabtool,TCM_SETCURSEL,i,0)
'				hOld=ah.hred
'				ah.hred=lpTABMEM->hedit
'				ad.filename=lpTABMEM->filename
'				'SendMessage(ah.hwnd,WM_SIZE,SIZE_RESTORED,0)     ' MOD 1.2.2012 hWin -> ah.hwnd
'				ShowWindow(ah.hred,SW_SHOWNA)
'				SetWinCaption
'				If hOld<>ah.hpane(0) And ah.hred<>ah.hpane(0) And hOld<>ah.hred Then
'					ShowWindow(hOld,SW_HIDE)
'				EndIf
'				ShowWindow(ah.htt,SW_HIDE)
'				HideList()
'				If ah.hpane(0)<>0 And ah.hred<>ah.hpane(0) Then
'					If ah.hred<>ah.hpane(1) Then
'						ShowWindow(ah.hpane(1),SW_HIDE)
'					EndIf
'					ah.hpane(1)=ah.hred
'				EndIf
'				SendMessage(ah.hwnd,WM_SIZE,SIZE_RESTORED,0)
'				'SetFocus(lpTABMEM->hedit)
'				SelectTrvItem(ad.filename)
'				If SendMessage(ah.hpr,PRM_GETSELBUTTON,0,0)=1 Then
'					UpdateFileProperty
'				EndIf
'				Exit While
'			EndIf
'		Else
'			If nInx Then
'				OpenProjectFile(nInx)
'			EndIf
'			Exit While
'		EndIf
'		i=i+1
'	Wend
'    
'    ' MOD 20.1.2012 ADD    
'	'BlockMode = SendMessage (ah.hred, REM_GETMODE, 0, 0) And MODE_BLOCK
'	'CheckMenuItem ah.hmenu, IDM_EDIT_BLOCKMODE, IIf (BlockMode, MF_CHECKED, MF_UNCHECKED)
'	' ==================
'	
'End Sub

Sub UpdateTabImageByFileID (ByVal FileID As Integer)
    
    Dim tci      As TCITEM
	Dim TabID    As Integer    = 0
	
	tci.mask = TCIF_PARAM
	
	Do
		If SendMessage (ah.htabtool, TCM_GETITEM, TabID, Cast (LPARAM, @tci)) Then
		    If pTABMEM->profileinx = FileID Then
                tci.mask   = TCIF_IMAGE
                tci.iImage = GetFileImg (pTABMEM->filename, FileID)
				SendMessage (ah.htabtool, TCM_SETITEM, TabID, Cast (LPARAM, @tci))
				Exit Do
			EndIf
		Else
			Exit Do
		EndIf
		
		TabID += 1
	Loop
    
End Sub

Sub UpdateTabImageByTabID (ByVal TabID As Integer)
    
   	Dim tci As TCITEM
	
	tci.mask = TCIF_PARAM

	If SendMessage (ah.htabtool, TCM_GETITEM, TabID, Cast (LPARAM, @tci)) Then
        tci.mask   = TCIF_IMAGE
        tci.iImage = GetFileImg (pTABMEM->filename, pTABMEM->profileinx)
		SendMessage (ah.htabtool, TCM_SETITEM, TabID, Cast (LPARAM, @tci))
	EndIf
    
End Sub

Sub SelectTabByTabID (ByVal TabID As Integer)

	Dim tci      As TCITEM
	Dim hOld     As HWND       = Any
	        
	tci.mask = TCIF_PARAM

	If SendMessage (ah.htabtool, TCM_GETITEM, TabID, Cast (LPARAM, @tci)) Then
		SendMessage ah.htabtool, TCM_SETCURFOCUS, TabID, 0
		SendMessage ah.htabtool, TCM_SETCURSEL  , TabID, 0
		hOld = ah.hred
		ah.hred = pTABMEM->hedit
		ad.filename = pTABMEM->filename
        SetEditorTypeInfo ah.hred
		'SendMessage(ah.hwnd,WM_SIZE,SIZE_RESTORED,0)     ' MOD 1.2.2012 hWin -> ah.hwnd
		ShowWindow ah.hred, SW_SHOWNA
		SetWinCaption
		If hOld<>ah.hpane(0) And ah.hred<>ah.hpane(0) And hOld<>ah.hred Then
			ShowWindow hOld, SW_HIDE
		EndIf
		ShowWindow ah.htt, SW_HIDE
		HideCCLists
		If ah.hpane(0)<>0 And ah.hred<>ah.hpane(0) Then
			If ah.hred<>ah.hpane(1) Then
				ShowWindow ah.hpane(1), SW_HIDE
			EndIf
			ah.hpane(1)=ah.hred
		EndIf
		SendMessage ah.hwnd, WM_SIZE, SIZE_RESTORED, 0
		'SetFocus pTABMEM->hedit         must be set by caller, some dlgs wanna hold focus (eg. finddlg)
		SelectTrvItem(ad.filename)
        'Print "SelectTabByTabID"; TabID
        'SbarSetBlockMode
        
        
        
        'If SendMessage(ah.hpr,PRM_GETSELBUTTON,0,0)=1 Then
			'UpdateProperty
        'EndIf
	EndIf 
    
End Sub

Sub SelectTabByFileID (ByVal nInx As Integer)

	Dim tci       As TCITEM
	Dim i         As Integer    = 0
    
    If nInx then    
    	tci.mask = TCIF_PARAM
        
    	Do
    		If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
    			If pTABMEM->profileinx = nInx Then
    			    SelectTabByTabID i
    				Exit Do 
    			EndIf
    		Else
    		    OpenTheFile (*GetProjectFileName (nInx, PT_ABSOLUTE), FOM_STD)
    			Exit Do 
    		EndIf
    		i += 1
    	Loop 
    EndIf 
End Sub

Sub SelectTabByWindow (ByVal hEdit As HWND)
		
	Dim tci      As TCITEM
	Dim i        As Integer    = 0

	If hEdit Then
    	tci.mask=TCIF_PARAM

    	Do
    		If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(Integer,@tci)) Then
    			If pTABMEM->hedit=hEdit Then
       			    SelectTabByTabID i
    				Exit Do 
    			EndIf
    		Else
    			Exit Do	
    		EndIf
    		i += 1
    	Loop
	EndIf 
End Sub

Sub SwitchTab()
    
	Dim n        As Integer    = Any 
	Dim i        As Integer    = Any 
	Dim tci      As TCITEM

	n = SendMessage (ah.htabtool, TCM_GETITEMCOUNT, 0, 0)
	If n > 1 Then
		i = SendMessage (ah.htabtool, TCM_GETCURSEL, 0, 0)
		tci.mask = TCIF_PARAM
		If SendMessage (ah.htabtool, TCM_GETITEM, prevtab, Cast (LPARAM, @tci)) Then
			SelectTabByWindow pTABMEM->hedit                  ' MOD 1.2.2012 removed ah.hwnd
			SetFocus ah.hred
		EndIf
	EndIf

End Sub

Sub SetFileInfo (ByVal hWin As HWND, ByVal pFileSpec As ZString Ptr)
	
	Dim nInx       As Integer = Any 
	Dim pfi        As PFI
    Dim EditorMode As Long    = Any

    If hWin Then
    	EditorMode = GetWindowLong (hWin, GWL_ID)
    	If     EditorMode = IDC_CODEED _
    	OrElse EditorMode = IDC_TEXTED Then
    		If fProject Then
    			nInx = GetFileID (*pFileSpec)
    			ReadProjectFileInfo nInx, @pfi
    			SetProjectFileInfo hWin, @pfi
    		EndIf
    	EndIf
    EndIf 

End Sub

Function OpenFileExtern (ByRef FileSpec As ZString) As BOOLEAN
        
    Dim sType     As String
    Dim sItem     As ZString * 512
    Dim pErrText  As ZString Ptr   = Any 
    Dim ExitCode  As Integer       = Any 
    
    sType = *GetFileExt (FileSpec)
		
	If Len (sType) Then
	    sType += "."
		GetPrivateProfileString @"Open", @"Extern", NULL, @sItem, SizeOf (sItem), @ad.IniFile
		
		If      IsZStrNotEmpty (sItem) _
		AndAlso InStr (sItem, sType) Then
			UpdateEnvironment
			buff = QUOTE + FileSpec + QUOTE
			TextToOutput "SHELLEXECUTE: " + buff
			ExitCode = CInt (ShellExecute (ah.hwnd, @"open", @buff, NULL, NULL, SW_SHOWDEFAULT))
		Else
		    Return FALSE         ' not allowed for ShellExecute by FbEdit.ini (no ErrText)
		EndIf     
    Else 
	    ExitCode = SE_ERR_ASSOCINCOMPLETE
	EndIf
    
    Select Case ExitCode
    Case 0                      :  pErrText = @"The operating system is out of memory or resources" 
    Case ERROR_FILE_NOT_FOUND   :  pErrText = @"The specified file was not found" 
    Case ERROR_PATH_NOT_FOUND   :  pErrText = @"The specified path was not found" 
    Case ERROR_BAD_FORMAT       :  pErrText = @"The .exe file is invalid (non-Microsoft Win32 .exe or error in .exe image)" 
    Case SE_ERR_ACCESSDENIED    :  pErrText = @"The operating system denied access to the specified file" 
    Case SE_ERR_ASSOCINCOMPLETE :  pErrText = @"The file name association is incomplete or invalid" 
    Case SE_ERR_DDEBUSY         :  pErrText = @"The Dynamic Data Exchange (DDE) transaction could not be completed because other DDE transactions were being processed" 
    Case SE_ERR_DDEFAIL         :  pErrText = @"The DDE transaction failed" 
    Case SE_ERR_DDETIMEOUT      :  pErrText = @"The DDE transaction could not be completed because the request timed out" 
    Case SE_ERR_DLLNOTFOUND     :  pErrText = @"The specified DLL was not found" 
    Case SE_ERR_FNF             :  pErrText = @"The specified file was not found" 
    Case SE_ERR_NOASSOC         :  pErrText = @"There is no application associated with the given file name extension" 
    Case SE_ERR_OOM             :  pErrText = @"There was not enough memory to complete the operation" 
    Case SE_ERR_PNF             :  pErrText = @"The specified path was not found" 
    Case SE_ERR_SHARE           :  pErrText = @"A sharing violation occurred" 
    End Select
    
    If ExitCode > 32 Then
        Return TRUE 
    Else
        TextToOutput @"*** error SHELLEXECUTE ***", MB_ICONHAND
        TextToOutput pErrText 
        Return FALSE 
    EndIf

    
    'Dim sType     As String
    'Dim nInx      As Integer        = Any 
    'Dim sItem     As ZString * 260
    'Dim pFileName As ZString Ptr    = Any                      ' MOD 2.3.2012 add
    '
	'sType = *GetFileExt (FileSpec)

	'If Len (sType) Then
	'    sType += "."
	'Else
	'    sType= ".."
	'EndIf

	'nInx=1
	'Do
	'	GetPrivateProfileString(StrPtr("Open"),Str(nInx),NULL,@sItem,SizeOf(sItem),@ad.IniFile)
	'	If IsZStrNotEmpty (sItem) Then
	'		If InStr(sItem,sType) Then
	'			pFileName = @sItem + InStr (sItem, ",")        ' MOD 2.3.2012 add
	'			'sItem=Mid(sItem,InStr(sItem,",")+1)
	'			buff = QUOTE + FileSpec + QUOTE
	'			ShellExecute (ah.hwnd,NULL,pFileName,@buff,0,SW_SHOWDEFAULT)
	'			Return TRUE 
	'		EndIf
	'	Else
	'		Return FALSE 
	'	EndIf
	'	nInx=nInx+1
	'Loop
    
End Function

Sub OpenTheFile (Byref FileSpec As ZString, ByVal OpenMode As FileOpenMode)

    Dim TabID       As Integer = Any 
    Dim ResTabID    As Integer = Any
    Dim TabMode     As Integer = Any 
    Dim OldFileName As String 
    Dim FileType    As Integer = Any
    Dim hEditor     As HWND    = Any
    
    If IsZStrEmpty2 (FileSpec) Then Exit Sub 
	If CallAddins (ah.hwnd, AIM_FILEOPEN, 0, Cast (LPARAM, @FileSpec), HOOK_FILEOPEN) Then Exit Sub
	
	GetTabIDBySpec FileSpec, TabID, TabMode                ' zerobased
    FileType = GetFBEFileType (FileSpec)
    
	Select Case OpenMode
	Case FOM_HEX
		AddMruFile (FileSpec)

        If TabMode = IDC_HEXED Then                        ' exists, right mode
            SelectTabByTabID TabID
            SetFocus ah.hred                           
        Else                                               ' wrong mode
            If TabID = INVALID_TABID  _                        
            OrElse CloseTab (TabID) = TRUE then                           
        	    AddTab CreateHexEd (FileSpec), FileSpec, ATM_FOREGROUND 
        	    ReadTheFile ah.hred, FileSpec
            EndIf
        EndIf    

	Case FOM_TXT
		AddMruFile (FileSpec)

        If TabMode = IDC_TEXTED Then                       ' exists, right mode
            SelectTabByTabID TabID
            SetFocus ah.hred                          
        Else                                               ' wrong mode
            If TabID = INVALID_TABID  _                        
            OrElse CloseTab (TabID) = TRUE then                           
            	AddTab CreateTxtEd (FileSpec), FileSpec, ATM_FOREGROUND
            	ReadTheFile ah.hred, FileSpec
                SetFileInfo ah.hred, FileSpec
            EndIf 
        EndIf    

	Case FOM_STD    
    	Select Case FileType
    	Case FBFT_PROJECT                                  ' ProjectFile (.fbp)
    		If fProject Then
    			If CloseProject = FALSE Then
    				Exit Sub
    			EndIf
    		EndIf
    		ad.filename = FileSpec
    		ad.ProjectFile = FileSpec 
    		OpenProject
    		'fTimer = 1
    		's = String (8192, 0)                           
    	 
    	Case FBFT_RESOURCE                                 ' ResourceFile (.rc)
			AddMruFile (FileSpec)

            If TabMode = IDC_RESED Then                    ' exists, right mode
                SelectTabByTabID TabID
                SetFocus ah.hres                      
            Else                                           ' wrong mode
                ' What we have: 1.rc as RESED and 2.rc as TXTED    
                ' What we want: 2.rc as RESED
                ' What's to do: - close 1.rc as RESED
                '               - open  1.rc as TXTED
                '               - close 2.rc as TXTED
                '               - open  2.rc as RESED
                If CloseTab (TabID) = TRUE then                              
                	GetResTabID ResTabId, OldFileName
                    If CloseTab (ResTabID) = TRUE Then
                        If ResTabID <> INVALID_TABID Then 
            			    AddTab CreateTxtEd (OldFileName), OldFileName, ATM_FOREGROUND
            			    ReadTheFile ah.hred, OldFileName
        	    		    SetFileInfo ah.hred, OldFileName
                        EndIf 
               			AddTab ah.hres, FileSpec, ATM_FOREGROUND
               			ReadTheFile ah.hres, FileSpec
                    EndIf    
                EndIf 
            EndIf    
		
		Case FBFT_CODE                                     ' CodeFile (.bas .bi)
   			AddMruFile (FileSpec)
            
            If TabMode = IDC_CODEED Then                   ' exists, right mode
                SelectTabByTabID TabID
                SetFileIDByTabID TabID, GetFileID (FileSpec) 
                UpdateTabImageByTabID TabID                ' exists, but wrong state: module / non module
                SetFocus ah.hred                      
            Else                                           ' wrong mode
                If TabID = INVALID_TABID  _                        
                OrElse CloseTab (TabID) = TRUE Then                            
        			AddTab CreateCodeEd (FileSpec), FileSpec, ATM_FOREGROUND
        			ReadTheFile ah.hred, FileSpec
        			SetFileInfo ah.hred, FileSpec
        			CallAddins ah.hwnd, AIM_FILEOPENNEW, Cast (WPARAM, ah.hred), Cast (LPARAM, @FileSpec), HOOK_FILEOPENNEW
                EndIf
            EndIf   
	    
	    Case Else                                          ' no one of: .fbp, .rc, .bas, .bi
			AddMruFile (FileSpec)
            
            If OpenFileExtern (FileSpec) Then 
                Exit Sub
            EndIf

            If TabMode = IDC_TEXTED Then                   ' exists, right mode
                SelectTabByTabID TabID
                SetFocus ah.hred                      
            Else                                           ' wrong mode
                If TabID = INVALID_TABID  _                        
                OrElse CloseTab (TabID) = TRUE Then                            
        			AddTab CreateTxtEd (FileSpec), FileSpec, ATM_FOREGROUND
        			ReadTheFile ah.hred, FileSpec
        			SetFileInfo ah.hred, FileSpec
                EndIf
            EndIf   
    	End Select
	
	Case FOM_TXT_BG
        If     TabMode = IDC_CODEED _
        OrElse TABMODE = IDC_TEXTED Then                   ' exists, right mode
            'dont select                                    
        Else                                               ' wrong mode
            If TabID = INVALID_TABID  _                        
            OrElse CloseTab (TabID) = TRUE then                           
            	hEditor = CreateTxtEd (FileSpec)
            	AddTab hEditor, FileSpec, ATM_BACKGROUND
            	ReadTheFile hEditor, FileSpec
            	SetFileInfo ah.hred, FileSpec
            EndIf 
        EndIf    
	End Select
End Sub

Sub OpenAFile (ByVal OpenMode As FileOpenMode)         ' MOD 1.2.2012 OpenAFile(ByVal hWin As HWND,ByVal fHex As Boolean)

	Dim ofn     As OPENFILENAME
	Dim Buffer  As ZString * 32 * 1024 
	Dim SubStr1 As ZString * MAX_PATH 
	Dim SubStrN As ZString * MAX_PATH 
	Dim Idx     As Integer = Any 
	
	With ofn
    	.lStructSize     = SizeOf (OPENFILENAME)
    	.hwndOwner       = GetOwner
    	.hInstance       = hInstance
    	.lpstrFile       = @Buffer                      
    	.nMaxFile        = SizeOf (Buffer)              
    	.lpstrFilter     = @ALLFilterString
    	.Flags           = OFN_EXPLORER      Or OFN_FILEMUSTEXIST    Or OFN_HIDEREADONLY Or _
    	                   OFN_PATHMUSTEXIST Or OFN_ALLOWMULTISELECT
   		.lpstrInitialDir = @szLastDir
	End With 
	
	If GetOpenFileName (@ofn) Then
		
		Idx = 0
		DePackStr Idx, Buffer, SubStr1, SizeOf (SubStr1)
		If Idx = 0 Then           ' nothing follows
			OpenTheFile SubStr1, OpenMode
			PathRemoveFileSpec SubStr1
		Else                      ' multi file selection
			Do
				DePackStr Idx, Buffer, SubStrN, SizeOf (SubStrN)
				OpenTheFile SubStr1 + "\" + SubStrN, OpenMode
			Loop While Idx
		EndIf 
		szLastDir = SubStr1		
	EndIf
End Sub

'Sub OpenAFile(ByVal hWin As HWND,ByVal fHex As Boolean)
'	Dim ofn As OPENFILENAME
'	Dim hMem As HGLOBAL
'	Dim i As Integer
'	Dim pth As ZString*260
'	Dim sFile As ZString*260
'	Dim s As ZString*260
'	Dim hTmp As HWND
'
'	hMem=MyGlobalAlloc(GMEM_FIXED Or GMEM_ZEROINIT,32*1024)
'	ofn.lStructSize=SizeOf(OPENFILENAME)
'	ofn.hwndOwner=GetOwner
'	ofn.hInstance=hInstance
'	ofn.lpstrFile=Cast(ZString Ptr,hMem)
'	ofn.nMaxFile=32*1024
'	ofn.lpstrFilter=StrPtr(ALLFilterString)
'	ofn.Flags=OFN_EXPLORER Or OFN_FILEMUSTEXIST Or OFN_HIDEREADONLY Or OFN_PATHMUSTEXIST Or OFN_ALLOWMULTISELECT Or OFN_EXPLORER
'	If Len(szLastDir) Then
'		ofn.lpstrInitialDir=@szLastDir
'	EndIf
'	If GetOpenFileName(@ofn) Then
'		lstrcpy(@pth,Cast(ZString Ptr,hMem))
'		i=Len(pth)+1
'		lstrcpy(@s,Cast(ZString Ptr,hMem+i))
'		If Asc(s)=0 Then
'			' Open single file
'			OpenTheFile(pth,fHex)
'			i=0
'			While TRUE
'				If InStr(i+1,pth,"\")=0 Then
'					Exit While
'				EndIf
'				i=InStr(i+1,pth,"\")
'			Wend
'			If i=3 Then i=4
'			pth=Left(pth,i-1)
'		Else
'			' Open multiple files
'			Do While Asc(s)<>0
'				sFile=pth & "\" & s
'				hTmp=CreateEdit(sFile)
'				AddTab(hTmp,sFile,FALSE)
'				ReadTheFile(hTmp,sFile)
'				i=i+Len(s)+1
'				lstrcpy(@s,Cast(ZString Ptr,hMem+i))
'			Loop
'		EndIf
'		szLastDir=pth
'	EndIf
'	GlobalFree(hMem)
'
'End Sub

#Define IDD_DLGSAVEUNICODE		1400
#Define IDC_CHKUNICODE			1401

Function UnicodeProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam as WPARAM,ByVal lParam as LPARAM) As Integer

	Select Case uMsg
		Case WM_INITDIALOG
			If fUnicode Then
				CheckDlgButton(hWin,IDC_CHKUNICODE,BST_CHECKED)
			EndIf
			'
		Case WM_COMMAND
			If HiWord(wParam)=BN_CLICKED Then
				fUnicode=IsDlgButtonChecked(hWin,IDC_CHKUNICODE)
			EndIf
			'
	End Select
	Return FALSE

End Function

Function SaveTabAs() As BOOLEAN    ' MOD 1.2.2012    SaveFileAs(ByVal hWin As HWND) As Boolean
	
	Dim ofn As OPENFILENAME

	ofn.lStructSize=SizeOf(OPENFILENAME)
	' MOD 1.2.2012
	ofn.hwndOwner=GetOwner
	'If hWin=ah.hwnd Then
	'	ofn.hwndOwner=GetOwner
	'Else
	'	ofn.hwndOwner=hWin
	'EndIf
	' ==================
	ofn.hInstance=hInstance
	buff=ad.filename
	ofn.lpstrFile=StrPtr(buff)
	ofn.nMaxFile=260
	ofn.lpstrDefExt=StrPtr("bas")
	ofn.lpstrFilter=StrPtr(ALLFilterString)                         
	ofn.Flags=OFN_EXPLORER Or OFN_HIDEREADONLY Or OFN_PATHMUSTEXIST Or OFN_OVERWRITEPROMPT Or OFN_ENABLETEMPLATE Or OFN_ENABLEHOOK
	ofn.lpTemplateName=Cast(ZString Ptr,IDD_DLGSAVEUNICODE)
	ofn.lpfnHook=Cast(Any Ptr,@UnicodeProc)
	fUnicode=SendMessage(ah.hred,REM_GETUNICODE,0,0)
	'fChangeNotification=-1                          ' turn file change checking off, while waiting for saveas
	'FileMonitorStop
	If GetSaveFileName(@ofn) Then
		ad.filename=buff
		SendMessage(ah.hred,REM_SETUNICODE,fUnicode,0)
		WriteTheFile(ah.hred,ad.filename)
		UpdateTab
		SetWinCaption
		Return TRUE
	EndIf
	'FileMonitorStart
	'fChangeNotification=0                           ' turn file change checking on
	Return FALSE

End Function

'Function WantToSaveCurrent() As BOOLEAN     ' MOD 1.2.2012 WantToSave(ByVal hWin As HWND) As Boolean
'	
'	Dim x As Integer = Any
'	
'	If ah.hred Then
'		If ah.hred=ah.hres Then
'			x=SendMessage(ah.hraresed,PRO_GETMODIFY,0,0)
'		Else
'			x=SendMessage(ah.hred,EM_GETMODIFY,0,0)
'		EndIf
'		If x Then
'			Select Case MessageBox(ah.hwnd,GetInternalString(IS_WANT_TO_SAVE_CHANGES),@szAppName,MB_YESNOCANCEL + MB_ICONQUESTION)
'			Case IDYES                                         ' MOD 1.2.2012    MessageBox(hWin,GetInter...
'					If Left(ad.filename,10)="(Untitled)" Then
'						Return SaveFileAs() Xor TRUE               ' MOD 2.1.2012   SaveFileAs(hWin)
'					Else
'						WriteTheFile(ah.hred,ad.filename)
'	                    Return FALSE 
'					EndIf
'					'
'				Case IDCANCEL
'					Return TRUE
'					'
'			End Select
'		EndIf
'	EndIf
'	Return FALSE
'
'End Function

Sub UnlockAllTabs ()
    
	Dim tci      As TCITEM
	Dim i        As Integer    = 0
	
	tci.mask=TCIF_PARAM
	Do 
		If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
			pTABMEM->locked = FALSE  
		    SendMessage ah.htabtool, TCM_HIGHLIGHTITEM, i, FALSE 
		Else
			Exit Do 
		EndIf
		i += 1
	Loop 
	
End Sub

Function SaveSelectionDlgProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer

	Dim As Integer i,n,id,Event,x
	Dim tci As TCITEM
	Dim sItem As ZString*260
	Dim hOld As HWND
	Dim rect As RECT

	Select Case uMsg
		Case WM_INITDIALOG
			TranslateDialog(hWin,IDD_DLGSAVESELECTION)
			tci.mask=TCIF_PARAM
			i=0
			n=0
			Do While TRUE
				If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(Integer,@tci)) Then
				    If (lParam = SAM_NONPROJECTFILES) AndAlso pTABMEM->profileinx Then
					    x = 0
				    ElseIf (lParam = SAM_PROJECTFILES) AndAlso (pTABMEM->profileinx = 0) Then
				        x = 0
					ElseIf (lParam = SAM_ALLFILES_BUT_CURRENT) AndAlso (i = SendMessage (ah.htabtool, TCM_GETCURSEL, 0, 0)) Then 
					    x = 0
					Else
    					x = GetModifyFlag (pTABMEM->hedit)
					EndIf 
					If x Then
						lstrcpy(@buff,pTABMEM->filename)
						sItem = *GetFileName (buff)           ' MOD 22.1.2012
						id=SendDlgItemMessage(hWin,IDC_LSTFILES,LB_ADDSTRING,0,Cast(LPARAM,@sItem))
						SendDlgItemMessage(hWin,IDC_LSTFILES,LB_SETITEMDATA,id,i)
						SendDlgItemMessage(hWin,IDC_LSTFILES,LB_SETSEL,TRUE,id)
						n=n+1
					EndIf
				Else
					Exit Do
				EndIf
				i=i+1
			Loop
			If n=0 Then
				EndDialog(hWin,0)
			EndIf
			SetWindowPos(hWin,0,wpos.ptsavelist.x,wpos.ptsavelist.y,0,0,SWP_NOREPOSITION Or SWP_NOSIZE)
			'
		Case WM_CLOSE
			If lParam=2 Then
				lParam=0
			Else
				lParam=1
			EndIf
			GetWindowRect(hWin,@rect)
			wpos.ptsavelist.x=rect.left
			wpos.ptsavelist.y=rect.top
			EndDialog hWin, lParam
			'
		Case WM_COMMAND
			id=LoWord(wParam)
			Event=HiWord(wParam)
			Select Case id
				Case IDOK
					i=0
					tci.mask=TCIF_PARAM
					While TRUE
						id=SendDlgItemMessage(hWin,IDC_LSTFILES,LB_GETSEL,i,0)
						If id=LB_ERR Then
							Exit While
						ElseIf id=TRUE Then
							id=SendDlgItemMessage(hWin,IDC_LSTFILES,LB_GETITEMDATA,i,0)
							SendMessage(ah.htabtool,TCM_GETITEM,id,Cast(Integer,@tci))
						If Left(pTABMEM->filename,10)="(Untitled)" Then
								hOld=ah.hred
								ah.hred=pTABMEM->hedit
								ad.filename=pTABMEM->filename
								SendMessage(ah.hwnd,WM_SIZE,SIZE_RESTORED,0)
								If ah.hred<>hOld Then
									ShowWindow(ah.hred,SW_SHOW)
									ShowWindow(hOld,SW_HIDE)
								EndIf
								SendMessage(ah.htabtool,TCM_SETCURFOCUS,id,0)
								SendMessage(ah.htabtool,TCM_SETCURSEL,id,0)
								SetWinCaption
						        If SaveTabAs()=FALSE Then            ' MOD 2.1.2012   SaveFileAs(hWin)
									EndDialog(hWin,1)
									Return TRUE
								EndIf
							Else
								WriteTheFile(pTABMEM->hedit,pTABMEM->filename)
							EndIf
						EndIf
						i=i+1
					Wend
					SendMessage(hWin,WM_CLOSE,0,2)
					'
				Case IDCANCEL
					SendMessage(hWin,WM_CLOSE,0,1)
					'
				Case IDC_BTNSELECT
					i=0
					While TRUE
						If SendDlgItemMessage(hWin,IDC_LSTFILES,LB_SETSEL,TRUE,i)=LB_ERR Then
							Exit While
						EndIf
						i=i+1
					Wend
					'
				Case IDC_BTNDESELECT
					i=0
					While TRUE
						If SendDlgItemMessage(hWin,IDC_LSTFILES,LB_SETSEL,FALSE,i)=LB_ERR Then
							Exit While
						EndIf
						i=i+1
					Wend
					'
			End Select
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE

End Function

Function CloseAllTabs () As BOOL

	Dim tci      As TCITEM
	Dim i        As Integer = 0
 
	If DialogBoxParam (hInstance, MAKEINTRESOURCE (IDD_DLGSAVESELECTION), ah.hwnd, @SaveSelectionDlgProc, SAM_ALLFILES) Then
		Return FALSE  
	EndIf

    tci.mask = TCIF_PARAM

	Do
		If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
			If CloseTab (i, CTM_IGNORE_DIRTY) = FALSE Then
			    i += 1           ' skip, tab will survive
			EndIf
		Else
			Exit Do 
		EndIf
	Loop
    
    Return TRUE 
    
End Function 

Function CloseAllTabsButCurrent () As BOOL

	Dim tci      As TCITEM
	Dim i        As Integer = 0
 
	If DialogBoxParam (hInstance, MAKEINTRESOURCE (IDD_DLGSAVESELECTION), ah.hwnd, @SaveSelectionDlgProc, SAM_ALLFILES_BUT_CURRENT) Then
		Return FALSE  
	EndIf

    tci.mask = TCIF_PARAM

	Do
		If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
			If i <> SendMessage (ah.htabtool, TCM_GETCURSEL, 0, 0) Then
				If CloseTab (i, CTM_IGNORE_DIRTY) = FALSE Then
				    i += 1           ' skip, tab will survive
				EndIf
			Else
    		    i += 1               ' skip current
			EndIf
		Else
			Exit Do 
		EndIf
	Loop
    
    Return TRUE 
    
End Function 

Function CloseAllProjectTabs () As BOOL

	Dim tci      As TCITEM
	Dim i        As Integer    = 0

	If DialogBoxParam (hInstance, MAKEINTRESOURCE (IDD_DLGSAVESELECTION), ah.hwnd, @SaveSelectionDlgProc, SAM_PROJECTFILES) Then
		Return FALSE  
	EndIf
    
	tci.mask = TCIF_PARAM

	Do
		If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
			If pTABMEM->profileinx Then
				If CloseTab (i, CTM_IGNORE_DIRTY Or CTM_PROJECTCLOSE) = FALSE Then
				    i += 1           ' skip, tab will survive
				EndIf
			Else
    		    i += 1               ' skip non project tab
			EndIf
		Else
			Exit Do 
		EndIf
	Loop
    
    Return TRUE 
    
End Function 

Function CloseAllNonProjectTabs () As BOOL 

	Dim tci      As TCITEM
	Dim i        As Integer    = 0

	If DialogBoxParam (hInstance, MAKEINTRESOURCE (IDD_DLGSAVESELECTION), ah.hwnd, @SaveSelectionDlgProc, SAM_NONPROJECTFILES) Then
        Return FALSE  
	EndIf

	tci.mask = TCIF_PARAM

	Do
		If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM, @tci)) Then
			If pTABMEM->profileinx = 0 Then
				If CloseTab (i, CTM_IGNORE_DIRTY) = FALSE Then
				    i += 1           ' skip, tab will survive
				EndIf
			Else
    		    i += 1               ' skip project tab
			EndIf
		Else
			Exit Do 
		EndIf
	Loop
    
    Return TRUE 

End Function

'Function CloseAllTabs(ByVal fProjectClose As Boolean,ByVal hWinDontClose As HWND,ByVal fCloseLocked As Boolean=FALSE) As Boolean
'                                                         ' MOD 1.2.2012   Function CloseAllTabs(ByVal hWin As HWND,ByVal fProjectClose As Boolean,ByVal hWinDontClose As HWND,ByVal fCloseLocked As Boolean=FALSE) As Boolean                                        
'	Dim tci As TCITEM
'	Dim i As Integer
'	Dim x As Integer
'	Dim sTabOrder As String
'
'	If fProjectClose Then
'		If DialogBoxParam(hInstance,Cast(ZString Ptr,IDD_DLGSAVESELECTION),ah.hwnd,@SaveSelectionDlgProc,SAM_ALLFILES) Then
'			Return TRUE
'		EndIf
'	EndIf
'	tci.mask=TCIF_PARAM
'	i=0
'	While TRUE
'		If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(Integer,@tci)) Then
'			If pTABMEM->hedit<>hWinDontClose And (pTABMEM->locked=False  Or fCloseLocked=TRUE) Then
'				ShowWindow(ah.hred,SW_HIDE)
'				ah.hred=pTABMEM->hedit
'				ad.filename=pTABMEM->filename
'				SendMessage(ah.hwnd,WM_SIZE,SIZE_RESTORED,0)         ' MOD 1.2.2012    SendMessage(hWin,WM_SIZE,0,0)
'				ShowWindow(ah.hred,SW_SHOW)
'        		SendMessage(ah.htabtool,TCM_SETCURFOCUS,i,0)
'				SendMessage(ah.htabtool,TCM_SETCURSEL,i,0)
'				SetWinCaption
'				If fProjectClose Then
'					sTabOrder &="," & Str(pTABMEM->profileinx)
'				Else
'				    If WantToSaveCurrent() Then          ' MOD 1.2.2012     If WantToSave(hWin) Then
'						Return TRUE
'					EndIf
'				EndIf
'				CallAddins(ah.hwnd,AIM_FILECLOSE,0,Cast(LPARAM,@pTABMEM->filename),HOOK_FILECLOSE)
'			    			    
'			    If pTABMEM->profileinx Then             ' MOD 10.2.2012    If lpTABMEM->profileinx And GetWindowLong(lpTABMEM->hedit,GWL_ID)<>IDC_HEXED Then
'					WriteProjectFileInfo(pTABMEM->hedit,pTABMEM->profileinx,fProjectClose)
'				EndIf
'				SendMessage(ah.hpr,PRM_DELPROPERTY,Cast(Integer,pTABMEM->hedit),0)
'		        If pTABMEM->hedit<>ah.hres Then
'					x=0
'					While x<16
'						If fdc(x).hwnd=pTABMEM->hedit Then
'							fdc(x).hwnd=Cast(HWND,-1)
'						EndIf
'						x=x+1
'					Wend
'					DestroyWindow(pTABMEM->hedit)
'				Else
'					ShowWindow(pTABMEM->hedit,SW_HIDE)
'				EndIf
'				GlobalFree(pTABMEM)
'				SendMessage(ah.htabtool,TCM_DELETEITEM,i,0)
'				i=i-1
'			EndIf
'		Else
'			Exit While
'		EndIf
'		i=i+1
'	Wend
'	If hWinDontClose Then
'		SelectTabByWindow(hWinDontClose)         ' MOD 1.2.2012 removed ah.hwnd
'		SetFocus(ah.hred)
'	ElseIf SendMessage(ah.htabtool,TCM_GETITEMCOUNT,0,0) Then
'		SendMessage(ah.htabtool,TCM_GETITEM,0,Cast(Integer,@tci))
'		SelectTabByWindow(pTABMEM->hedit)       ' MOD 1.2.2012 removed ah.hwnd
'		SetFocus(ah.hred)
'		Return TRUE
'	Else
'		If fProjectClose Then
'			sTabOrder=Mid(sTabOrder,2)
'			WritePrivateProfileString(StrPtr("TabOrder"),StrPtr("TabOrder"),sTabOrder,@ad.ProjectFile)
'		EndIf
'		If wpos.fview And VIEW_TABSELECT Then
'			ShowWindow(ah.htabtool,SW_HIDE)
'		EndIf
'		curtab=-1
'		prevtab=-1
'		ah.hred=0
'		ShowWindow(ah.hshp,SW_SHOWNA)
'		If ah.hfullscreen Then
'			DestroyWindow(ah.hfullscreen)
'		EndIf
'		SetZStrEmpty (ad.filename)             'MOD 26.1.2012 
'	EndIf
'	SendMessage(ah.hpr,PRM_REFRESHLIST,0,0)
'	SetWinCaption
'	HideList()
'	Return FALSE
'
'End Function

Sub OpenAProject ()                           ' MOD 1.2.2012    OpenAProject(ByVal hWin As HWND) As Boolean

	Dim ofn   As OPENFILENAME
	Dim sFile As ZString * MAX_PATH 
	Dim Title As ZString * 1024 = GetInternalString (IS_OPEN_PROJECT)
    
    With ofn
    	.lStructSize     = SizeOf (OPENFILENAME)
    	.hwndOwner       = GetOwner
    	.hInstance       = hInstance
       '.lpstrInitialDir = @ad.DefProjectPath
    	.lpstrInitialDir = @szLastDir
    	.lpstrFile       = @sFile
    	.nMaxFile        = SizeOf (sFile)
    	.lpstrFilter     = @PRJFilterString
    	.lpstrTitle      = @Title
    	.Flags           = OFN_EXPLORER Or OFN_FILEMUSTEXIST Or OFN_HIDEREADONLY Or OFN_PATHMUSTEXIST
	End With 
	
	If GetOpenFileName (@ofn) Then
		OpenTheFile sFile, FOM_STD
	EndIf

End Sub

Function SaveAllTabs () As BOOL                            ' MOD 2.1.2012   (ByVal hWin As HWND)
	
	Dim tci       As TCITEM
	Dim i         As Integer = Any 
	Dim NotSaved  As BOOL    = Any 
	Dim hOld      As HWND

	SetFocus ah.hred
	tci.mask = TCIF_PARAM
	NotSaved = FALSE 
	i        = 0
	
	Do
		If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(Integer,@tci)) Then
			If GetModifyFlag (pTABMEM->hedit) Then
				If Left(pTABMEM->filename,10)="(Untitled)" Then
					hOld=ah.hred
					ah.hred=pTABMEM->hedit
					ad.filename=pTABMEM->filename
					SendMessage(ah.hwnd,WM_SIZE,SIZE_RESTORED,0)          ' MOD 2.1.2012   SendMessage(hWin,WM_SIZE,0,0)   
					If ah.hred<>hOld Then
						ShowWindow(ah.hred,SW_SHOW)
						ShowWindow(hOld,SW_HIDE)
					EndIf
            		SendMessage(ah.htabtool,TCM_SETCURFOCUS,i,0)
					SendMessage(ah.htabtool,TCM_SETCURSEL,i,0)
					SetWinCaption
					If SaveTabAs()=FALSE Then                ' MOD 2.1.2012   SaveFileAs(hWin)
						NotSaved = TRUE 
					EndIf
				Else
					WriteTheFile(pTABMEM->hedit,pTABMEM->filename)
				EndIf
			EndIf
		Else
			Exit Do
		EndIf
		i=i+1
	Loop
	Return NotSaved

End Function

Function GetModifyFlag (ByVal hEdit As HWND) As BOOL

    Dim EditMode As Long = Any
    
    If hEdit Then
    	EditMode = GetWindowLong (hEdit, GWL_ID)

   		If EditMode = IDC_RESED Then                           ' update filestate if tab is current
			Return SendMessage (ah.hraresed, PRO_GETMODIFY, 0, 0)
   		Else
			Return SendMessage (hEdit, EM_GETMODIFY, 0, 0)
		EndIf
    EndIf
    
    Return FALSE 
End Function

Function GetFileIDByCurrTab () As Integer

	Dim tci      As TCITEM
	Dim CurrTab  As Integer    = Any 

	tci.mask = TCIF_PARAM
	CurrTab = SendMessage (ah.htabtool, TCM_GETCURSEL, 0, 0)

	If CurrTab <> INVALID_TABID Then
		If SendMessage (ah.htabtool, TCM_GETITEM, CurrTab, Cast (LPARAM, @tci)) Then
			Return pTABMEM->profileinx
		EndIf 
	EndIf

	Return 0

End Function

Function GetFileIDByEditor(ByVal hWin As HWND) As Integer

	Dim tci      As TCITEM
	Dim i        As Integer    = 0 

	tci.mask=TCIF_PARAM
	Do 
		If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(Integer,@tci)) Then
		 	If pTABMEM->hedit=hWin Then
				Return pTABMEM->profileinx
			EndIf
		Else
			Exit Do
		EndIf
		i += 1
	Loop
	Return 0

End Function

Sub UpdateAllTabs (ByVal nType As Integer)
	Dim tci As TCITEM
	Dim i As Integer
	Dim x As Integer
	Dim p As Integer
	Dim hFile As HANDLE
	Dim ft As FILETIME

	tci.mask=TCIF_PARAM
	i=0
	p=0
	
	Do While TRUE
		If SendMessage(ah.htabtool,TCM_GETITEM,i,Cast(Integer,@tci)) Then
			Select Case As Const nType
				Case 1
					' update editor options
					UpdateEditOption pTABMEM->hedit
				Case 2
					' clear errors
					If pTABMEM->hedit<>ah.hres Then
						x=-1
						While TRUE
							x=SendMessage(pTABMEM->hedit,REM_NEXTERROR,x,0)
							If x=-1 Then
								Exit While
							EndIf
							SendMessage(pTABMEM->hedit,REM_SETERROR,x,0)
						Wend
					EndIf
				Case 3
					If pTABMEM->hedit<>ah.hres Then
						x=GetWindowLong(pTABMEM->hedit,GWL_USERDATA)
						If (x=1 And pTABMEM->hedit<>ah.hred) Or x=2 Then
							' Update properties
							p=p+ParseFile(pTABMEM->hedit)
						EndIf
					EndIf
			    Case 4
					x = GetModifyFlag (pTABMEM->hedit)
					If x<>(pTABMEM->filestate And 1) Then
						pTABMEM->filestate=pTABMEM->filestate And (-1 Xor 1)
						pTABMEM->filestate=pTABMEM->filestate Or x
						CallAddins(ah.hwnd,AIM_FILESTATE,i,Cast(Integer,pTABMEM),HOOK_FILESTATE)
					EndIf
				'Case 5
				'	hFile=CreateFile(pTABMEM->filename,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL)
				'	If hFile<>INVALID_HANDLE_VALUE Then
				'		GetFileTime(hFile,NULL,NULL,@ft)
				'		CloseHandle(hFile)
				'		If CompareFileTime (@ft, @pTABMEM->ft) > 0 Then
				'		'If ft.dwLowDateTime<>pTABMEM->ft.dwLowDateTime Then
				'			' File changed outside editor
				'			fChangeNotification=-1
				'			'lstrcpy(@buff,pTABMEM->filename)
				'			'buff=buff & CR & GetInternalString(IS_FILE_CHANGED_OUTSIDE_EDITOR) & CR & GetInternalString(IS_REOPEN_THE_FILE)
				'			buff = pTABMEM->filename + CR + GetInternalString (IS_FILE_CHANGED_OUTSIDE_EDITOR) + CR + GetInternalString (IS_REOPEN_THE_FILE)
				'			If MessageBox(ah.hwnd,@buff,@szAppName,MB_YESNO Or MB_ICONEXCLAMATION)=IDYES Then
				'				' Reload file
				'				ReadTheFile pTABMEM->hedit, pTABMEM->filename
				'				'lstrcpy(@buff,pTABMEM->filename)
				'				SetFileInfo pTABMEM->hedit, pTABMEM->filename
				'			EndIf
				'			hFile=CreateFile(pTABMEM->filename,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL)
				'			If hFile<>INVALID_HANDLE_VALUE Then
				'				GetFileTime(hFile,NULL,NULL,@ft)
				'				CloseHandle(hFile)
				'			EndIf
				'			pTABMEM->ft = ft
				'			'pTABMEM->ft.dwLowDateTime=ft.dwLowDateTime
				'			'pTABMEM->ft.dwHighDateTime=ft.dwHighDateTime
				'			fChangeNotification=10
				'		EndIf
				'	EndIf
				Case 6
					' Clear find
					If pTABMEM->hedit<>ah.hres Then
						SendMessage(pTABMEM->hedit,REM_CLRBOOKMARKS,0,BMT_STD)
					EndIf
			End Select
		Else
			Exit Do
		EndIf
		i+=1
	Loop

	If nType=3 And p>0 Then
		SendMessage(ah.hpr,WM_SETREDRAW,FALSE,0)
		SendMessage(ah.hpr,PRM_REFRESHLIST,0,0)
		SendMessage(ah.hpr,WM_SETREDRAW,TRUE,0)
	EndIf

	If nType=2 Or nType=6 Then
		fTimer=1
	EndIf

End Sub

Function TabToolProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim lret As Integer
	Dim ht As TCHITTESTINFO
	Dim tci As TCITEM
	Dim buffer As ZString*260
   'Dim hrect As RECT
   'Dim mrect As RECT
   'Dim x As Integer
   'Dim fMove As Integer
	Static i As Integer=-1

    Static MoveCursorOn As BOOL 
    Static TabRECT      As RECT
       
	Select Case uMsg
	    
	    Case WM_LBUTTONDBLCLK
			ht.pt.x=LoWord(lParam)
			ht.pt.y=HiWord(lParam)
			lret=SendMessage(hWin,TCM_HITTEST,0,Cast(Integer,@ht))
			If lret <> INVALID_TABID Then
				'tci.mask=TCIF_PARAM
				'SendMessage(hWin,TCM_GETITEM,lret,Cast(Integer,@tci))
				'SelectTabByWindow(pTABMEM->hedit)          ' MOD 1.2.2012 removed ah.hwnd
				'If pTABMEM->locked = TRUE Then
				'    pTABMEM->locked = FALSE    
	            '    SendMessage hWin, TCM_HIGHLIGHTITEM, lret, FALSE
                'Else
				'    pTABMEM->locked = TRUE     
	            '    SendMessage hWin, TCM_HIGHLIGHTITEM, lret, TRUE 
				'EndIf
				
				SelectTabByTabID lret
				ToggleTabLock lret
				SetFocus ah.hred
				fTimer = 1
				Return 0
			EndIf
			'
	    Case WM_RBUTTONDOWN, WM_MBUTTONDOWN
			ht.pt.x=LoWord(lParam)
			ht.pt.y=HiWord(lParam)
			lret=SendMessage(hWin,TCM_HITTEST,0,Cast(Integer,@ht))
			If lret <> INVALID_TABID Then
				'tci.mask=TCIF_PARAM
				'SendMessage(hWin,TCM_GETITEM,lret,Cast(Integer,@tci))
				'SelectTabByWindow(pTABMEM->hedit)          ' MOD 1.2.2012 removed ah.hwnd
				SelectTabByTabID lret
				SetFocus ah.hred
				fTimer = 1
				Return 0
			EndIf
			'
	    Case WM_MBUTTONUP
			SendMessage(ah.hwnd,WM_COMMAND,IDM_FILE_CLOSE,0)
			Return 0
			'
	    Case WM_LBUTTONDOWN
			ht.pt.x=LoWord(lParam)
			ht.pt.y=HiWord(lParam)
			lret=SendMessage(hWin,TCM_HITTEST,0,Cast(Integer,@ht))
			If lret<>INVALID_TABID Then
    	        MoveCursorOn = TRUE
    	        GetWindowRect hWin, @TabRECT
    	        SetCapture hWin 
				'tci.mask=TCIF_PARAM
				'SendMessage(hWin,TCM_GETITEM,lret,Cast(Integer,@tci))
				'SelectTabByWindow(pTABMEM->hedit)          ' MOD 1.2.2012 removed ah.hwnd
				SelectTabByTabID lret
				SetFocus ah.hred
				i = lret
				fTimer = 1
				Return 0 
			EndIf
			'
	    Case WM_MOUSEMOVE
	        If MoveCursorOn Then
	            SetCursor LoadCursor (NULL, IDC_SIZEWE) 
	            ClipCursor @TabRECT
	        EndIf
	        Return 0
		'	If wParam And MK_LBUTTON Then
		'		ht.pt.x=LoWord(lParam)
		'		ht.pt.y=HiWord(lParam)
		'		lret=SendMessage(hWin,TCM_HITTEST,0,Cast(Integer,@ht))
		'		If lret<>i And lret>=0 And i>=0 Then
        '            ' MOD 17.3.2012 
		'			'SendMessage(hWin,TCM_GETITEMRECT,lret,Cast(LPARAM,@hrect))
		'			'SendMessage(hWin,TCM_GETITEMRECT,i,Cast(LPARAM,@mrect))
		'			'x=hrect.left+(hrect.right-hrect.left)\2
		'			'If mrect.left>hrect.left Then
		'			'	If ht.pt.x<x Then
		'			'		fMove=TRUE
		'			'	EndIf
		'			'Else
		'			'	If ht.pt.x>x Then
		'			'		fMove=TRUE
		'			'	EndIf
		'			'EndIf
		'			'If fMove Then
		'				'tci.mask=TCIF_TEXT Or TCIF_IMAGE Or TCIF_PARAM
		'				'tci.pszText=@buffer
		'				'tci.cchTextMax=260
		'				'SendMessage(hWin,TCM_GETITEM,i,Cast(LPARAM,@tci))
		'				'SendMessage(hWin,TCM_DELETEITEM,i,0)
		'				'SendMessage(hWin,TCM_INSERTITEM,lret,Cast(LPARAM,@tci))
		'				'SendMessage(hWin,TCM_SETCURFOCUS,lret,0)
		'				'i=lret
		'			'EndIf
		'		EndIf
		'		Return 0
		'	EndIf
			'
	    Case WM_LBUTTONUP   
            MoveCursorOn = FALSE
            SetCursor LoadCursor (NULL, IDC_ARROW)
            ClipCursor NULL
            ReleaseCapture 

    		ht.pt.x=LoWord(lParam)
			ht.pt.y=HiWord(lParam)
			lret=SendMessage(hWin,TCM_HITTEST,0,Cast(Integer,@ht))

			If lret<>i And lret>=0 And i>=0 Then
				tci.mask=TCIF_TEXT Or TCIF_IMAGE Or TCIF_PARAM
				tci.pszText=@buffer
				tci.cchTextMax = SizeOf (buffer)
				SendMessage(hWin,TCM_GETITEM,i,Cast(LPARAM,@tci))
				SendMessage(hWin,TCM_DELETEITEM,i,0)
				SendMessage(hWin,TCM_INSERTITEM,lret,Cast(LPARAM,@tci))
				SendMessage(hWin,TCM_SETCURFOCUS,lret,0)
				i = lret
			EndIf
	        Return 0
	
	End Select
	Return CallWindowProc(lpOldTabToolProc,hWin,uMsg,wParam,lParam)

End Function

