

#Include Once "windows.bi"

#Include Once "Inc\RACodeComplete.bi"
#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAProperty.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\CodeComplete.bi"
#Include Once "Inc\CoTxEd.bi"
#Include Once "Inc\EditorOpt.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\GenericOpt.bi"
#Include Once "Inc\Project.bi"
#Include Once "Inc\SpecHandling.bi"
#Include Once "Inc\Statusbar.bi"
#Include Once "Inc\TabTool.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\GUIHandling.bi"


Dim Shared lpOldOutputProc        As WNDPROC
Dim Shared lpOldImmediateProc     As WNDPROC
Dim Shared lpOldFileBrowserProc   As WNDPROC  
                                  
Dim Shared MruProject(3)          As ZString * 260
Dim Shared MruFile(8)             As ZString * 260
                                  
Dim Shared ttmsg                  As MESSAGE                 ' Tooltip
Dim Shared ttpos                  As Integer
Dim Shared novr                   As Integer
Dim Shared nsel                   As Integer

Dim Shared BrowseForFolderDefProc As WNDPROC


Sub DoEvents (ByVal hWin As HWND)    ' ;-)
    
    Dim Bottle As MSG
    
    Do While PeekMessage (@Bottle, hWin, 0, 0, PM_REMOVE)                ' hWin = NULL peeks all messages from thread
  		If TranslateAccelerator (ah.hwnd, ah.haccel, @Bottle) = 0 Then
			If IsDialogMessage (ah.hfind, @Bottle) = 0 Then
				If IsDialogMessage (ah.hrareseddlg, @Bottle) = 0 Then
                    TranslateMessage @Bottle 
                    DispatchMessage  @Bottle 
                EndIf 
			EndIf  
        EndIf  
    Loop 
    
End Sub

Function BrowseForFolderProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
	
	Select Case uMsg
	'Case WM_ACTIVATE
	'	If wParam = WA_INACTIVE Then
	'	    SendMessage hWin, WM_CLOSE, 0, 0 
	'	EndIf
	'    Return 0 
	Case Else
        Return CallWindowProc (BrowseForFolderDefProc, hWin, uMsg, wParam, lParam)
	End Select     

End Function

Function BrowseForFolderCallBack(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal lParam As LPARAM,ByVal lpData As Integer) As Integer

	Select Case uMsg
	Case BFFM_INITIALIZED 
	    BrowseForFolderDefProc = Cast (WNDPROC, SetWindowLongPtr (hWin, GWLP_WNDPROC, Cast (LONG_PTR, @BrowseForFolderProc)))
		PostMessage hWin, BFFM_SETSELECTION, TRUE, lpData
	End Select
	Return 0

End Function

Sub BrowseForFolder(ByVal hWin As HWND,ByVal nID As Integer)
	
	Dim pidl As LPCITEMIDLIST
	Dim bri  As BROWSEINFO
    
    bri.hwndOwner       = hWin
	'bri.pidlRoot       = 0
	'bri.pszDisplayName = 0
	'bri.lpszTitle      = 0
	bri.ulFlags         = BIF_RETURNONLYFSDIRS Or BIF_BROWSEINCLUDEFILES Or BIF_NEWDIALOGSTYLE        ' Or BIF_EDITBOX
	bri.lpfn            = @BrowseForFolderCallBack
	bri.lParam          = Cast (LPARAM, @buff) 
	'bri.iImage         = 0

	' get path   
	SendDlgItemMessage(hWin,nID,WM_GETTEXT,260,Cast(Integer,@buff))
	pidl=SHBrowseForFolder(@bri)
	If pidl Then
		SHGetPathFromIDList(pidl,@buff)
   		CoTaskMemFree pidl
		' set new path back to edit
		SendDlgItemMessage(hWin,nID,WM_SETTEXT,0,Cast(Integer,@buff))
	EndIf

End Sub

Function OutputProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
	
	Dim pt   As Point = Any
	Dim hMnu As HMENU = Any 

	Select Case uMsg
		Case WM_CONTEXTMENU
			If CallAddins(hWin,AIM_CONTEXTMEMU,wParam,lParam,HOOK_CONTEXTMEMU)=FALSE Then
				If lParam=-1 Then
					GetCaretPos(@pt)
					ClientToScreen(hWin,@pt)
					pt.x=pt.x+10
				Else
					pt.x=Cast(Short,LoWord(lParam))
					pt.y=Cast(Short,HiWord(lParam))
				EndIf
				hMnu=GetSubMenu(ah.hcontextmenu,2)
				TrackPopupMenu(hMnu,TPM_LEFTALIGN Or TPM_RIGHTBUTTON,pt.x,pt.y,0,ah.hwnd,0)
			EndIf
		
		Case WM_SETFOCUS
			'Print "OutputProc: SETFOCUS"
		
		Case WM_KILLFOCUS
			'Print "OutputProc: KILLFOCUS"
			'SendMessage ah.hwnd, FBE_CHILDLOOSINGFOCUS, 0, Cast (LPARAM, GetParent (hWin))     ' notify: window is loosing focus
	        SbarClear
	
	End Select
	Return CallWindowProc(lpOldOutputProc,hWin,uMsg,wParam,lParam)

End Function

Function ImmediateProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
	
	Dim pt   As Point = Any 
	Dim hMnu As HMENU = Any

	Select Case uMsg
		Case WM_CONTEXTMENU
			If CallAddins(hWin,AIM_CONTEXTMEMU,wParam,lParam,HOOK_CONTEXTMEMU)=FALSE Then
				If lParam=-1 Then
					GetCaretPos(@pt)
					ClientToScreen(hWin,@pt)
					pt.x=pt.x+10
				Else
					pt.x=Cast(Short,LoWord(lParam))
					pt.y=Cast(Short,HiWord(lParam))
				EndIf
				hMnu=GetSubMenu(ah.hcontextmenu,5)
				TrackPopupMenu(hMnu,TPM_LEFTALIGN Or TPM_RIGHTBUTTON,pt.x,pt.y,0,ah.hwnd,0)
			EndIf

	    Case WM_SETFOCUS
			Print "ImmedProc: SETFOCUS"
		
		Case WM_KILLFOCUS
			Print "ImmedProc: KILLFOCUS"
			'SendMessage ah.hwnd, FBE_CHILDLOOSINGFOCUS, 0, Cast (LPARAM, GetParent (hWin))     ' notify: window is loosing focus
            SbarClear

	End Select
	Return CallWindowProc(lpOldImmediateProc,hWin,uMsg,wParam,lParam)

End Function

Function FileBrowserProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
	
	'Dim NotifyMsg As TV_KEYDOWN   
	'Dim Buffer As ZString * MAX_PATH 
	' 
	'Select Case uMsg
	'Case WM_KEYDOWN
	'	Print "FileBrowser KEYDOWN"			
	'Case WM_NOTIFY 
	'	NotifyMsg = *Cast (TV_KEYDOWN Ptr, lParam)
	'	'Print Cast(TV_KEYDOWN Ptr,LPARAM)->wVKey
	'	'Print Cast(TV_KEYDOWN Ptr,LPARAM)->hdr.code
	'	If NotifyMsg.hdr.code = TVN_KEYDOWN Then
	'		Select Case NotifyMsg.wVKey 
	'		case VK_RETURN
	'			Print "RETURN"	
	'			SendMessage hWin,FBM_GETSELECTED,0,Cast (LPARAM, @Buffer)
	'			Print Buffer
	'		Case VK_BACK
	'			Print "BACKSPACE"
	'			SendMessage hWin,FBM_GETSELECTED,0,Cast(LPARAM,@Buffer)
	'			Print Buffer
	'		End Select
	'	EndIf
	'End Select
	Return CallWindowProc (lpOldFileBrowserProc, hWin, uMsg, wParam, lParam)

End Function

Function GetOwner() As HWND

	If ah.hfullscreen Then
		Return ah.hfullscreen
	EndIf
	Return ah.hwnd

End Function

Sub ShowOutput(ByVal bShow As Boolean)

	If bShow Then
		If (wpos.fview And VIEW_OUTPUT)=0 Then
			SendMessage(ah.hwnd,WM_COMMAND,IDM_VIEW_OUTPUT,0)
		EndIf
	Else
		If wpos.fview And VIEW_OUTPUT Then
			SendMessage(ah.hwnd,WM_COMMAND,IDM_VIEW_OUTPUT,0)
		EndIf
	EndIf

End Sub

Sub ShowImmediate(ByVal bShow As Boolean)

	If bShow Then
		If (wpos.fview And VIEW_IMMEDIATE)=0 Then
			SendMessage(ah.hwnd,WM_COMMAND,IDM_VIEW_IMMEDIATE,0)
		EndIf
	Else
		If wpos.fview And VIEW_IMMEDIATE Then
			SendMessage(ah.hwnd,WM_COMMAND,IDM_VIEW_IMMEDIATE,0)
		EndIf
	EndIf

End Sub

Sub HLineToOutput ()

	TextToOutput String (80, Asc ("="))
  
End Sub

Sub TextToOutput OverLoad (Byval pText As ZString Ptr)
    
    If (wpos.fview And VIEW_OUTPUT) = 0 Then                              ' show if hidden
		SendMessage ah.hwnd, WM_COMMAND, IDM_VIEW_OUTPUT, 0
	EndIf

    SendMessage ah.hout, EM_EXSETSEL, 0, Cast (LPARAM, @Type<CHARRANGE>(-1, -1))
	
	SendMessage ah.hout, EM_REPLACESEL, FALSE, Cast (LPARAM, pText)       ' append
	SendMessage ah.hout, EM_REPLACESEL, FALSE, Cast (LPARAM, @CR)

End Sub

Sub TextToOutput OverLoad (Byval pText As ZString Ptr, ByVal SoundNo As UINT)
    
    TextToOutput pText
    MessageBeep SoundNo

End Sub

Sub TextToOutput OverLoad (Byval pText As ZString Ptr, ByVal BookMarkType As BookMarkTypes, ByVal BookMarkID As Integer)
    
    Dim LastLine As LRESULT = Any  
    
    LastLine = SendMessage (ah.hout, EM_GETLINECOUNT, 0, 0)
    TextToOutput pText    

	SendMessage ah.hout, REM_SETBOOKMARK, LastLine, BookMarkType
	SendMessage ah.hout, REM_SETBMID, LastLine, BookMarkID

End Sub

Sub ListAllBookmarks ()

     ' TabID = 0 ... n  (zerobased)
    
	Dim tci             As TCITEM
	Dim TabID           As Integer    = 0
	Dim LineNo          As Integer    = Any
	Dim EditorLines     As Integer    = Any 
	Dim OutputLine      As Integer    = Any
	Dim HeadLineWritten As BOOLEAN    = Any 
	Dim BookmarkID      As Integer    = Any
	Dim EditorMode      As Long       = Any 
	
	OutputLine = SendMessage (ah.hout, EM_GETLINECOUNT, 0, 0) 
	tci.mask = TCIF_PARAM
    
	Do
		If SendMessage (ah.htabtool, TCM_GETITEM, TabID, Cast (LPARAM, @tci)) Then
		EditorMode = GetWindowLong (pTABMEM->hedit, GWL_ID)
		If     EditorMode = IDC_CODEED _
		OrElse EditorMode = IDC_TEXTED Then 
                
                EditorLines = SendMessage (pTABMEM->hedit, EM_GETLINECOUNT, 0, 0)
                HeadLineWritten = FALSE
                
    			For LineNo = 0 To EditorLines - 1
           			If SendMessage (pTABMEM->hedit, REM_GETBOOKMARK, LineNo, 0) = BMT_STD Then
    			        If HeadLineWritten = FALSE Then      
                   			TextToOutput pTABMEM->filename
                			SendMessage ah.hout, REM_SETBOOKMARK, OutputLine, BMT_SPEC
                			OutputLine += 1
                            HeadLineWritten = TRUE 			        
    			        EndIf
    			        GetLineByNo pTABMEM->hedit, LineNo, @buff
    			        TextToOutput " (" + Str (LineNo + 1) + ") " + buff
    			        SendMessage ah.hout, REM_SETBOOKMARK, OutputLine, BMT_STD
                        BookmarkID = SendMessage (ah.hout, REM_GETBMID, OutputLine, 0)
    			     	SendMessage pTABMEM->hedit, REM_SETBMID, LineNo, BookmarkID
    
    			        OutputLine += 1    
           			EndIf
    			Next
			EndIf			
        	TabID += 1
		Else
		    HLineToOutput
	        Exit Sub 
		EndIf
	Loop

End Sub

Sub SetFullScreen(ByVal hWin As HWND)

	If ah.hfullscreen Then
		SetParent(hWin,ah.hfullscreen)
		ShowWindow(hWin,SW_SHOWMAXIMIZED)
		SetWindowPos(hWin,HWND_TOP,0,0,0,0,SWP_NOSIZE)
		SetFocus(hWin)
	EndIf

End Sub

Function ShowTooltip(ByVal hWin As HWND,ByVal lptt As TOOLTIP Ptr) As Integer
	
	Dim tti As TTITEM
	Dim pt  As POINT
	Dim wp  As Integer
	
	Static szApi As ZString*260
	
	wp=SendMessage(ah.hpr,PRM_ISTOOLTIPMESSAGE,Cast(WPARAM,@ttmsg),Cast(LPARAM,lptt))
	If wp Then
		SendMessage(ah.hcc,CCM_CLEAR,0,0)
		ccpos=@ccstring
		s=*Cast(ZString Ptr,wp)
		SendMessage(ah.hred,REM_GETWORD,256,Cast(LPARAM,@buff))
		GetItems(0)
		SendMessage(ah.hcc,CCM_SORT,0,TRUE)
		SendMessage(ah.hcc,CCM_SETCURSEL,0,0)
		fmessagelist=TRUE
		MoveList
		Return TRUE
	EndIf
	If edtopt.codecomplete Then
		fconstlist=UpdateConstList(lptt->lpszApi,lptt->nPos+1)
	EndIf
	If fconstlist Then
		' Move code complete list
		MoveList
		Return TRUE
	Else
		' Show tooltip
		HideCCLists
		If lstrcmp(@szApi,lptt->lpszApi) Then

			lstrcpy(@szApi,lptt->lpszApi)
			nsel=0
			novr=lptt->novr
		EndIf
	    If nsel >= lptt->novr Then nsel = lptt->novr - 1	
		tti.nsel=nsel
		tti.lpszApi=lptt->lpszApi
		tti.lpszParam=lptt->ovr(nsel).lpszParam
		tti.lpszRetType=lptt->ovr(nsel).lpszRetType
		tti.nitem=lptt->nPos

		wp=SendMessage(ah.htt,TTM_GETITEMTYPE,0,Cast(LPARAM,@tti))
		If Len(*Cast(ZString Ptr,wp)) Then
			wp=Cast(Integer,FindExact(StrPtr("Ee"),Cast(ZString Ptr,wp),TRUE))
			If wp Then
				fenumlist=UpdateEnumList(Cast(ZString Ptr,wp))
				MoveList
				Return TRUE
			EndIf
		EndIf
		wp=SendMessage(ah.htt,TTM_GETITEMNAME,0,Cast(LPARAM,@tti))
		tti.lpszDesc=FindExact(StrPtr("D"),Cast(ZString Ptr,wp),TRUE)
		If tti.lpszDesc Then
			tti.lpszDesc=tti.lpszDesc+Len(*tti.lpszDesc)+1
		EndIf
		tti.novr=lptt->novr
		GetCaretPos(@pt)
		ClientToScreen(hWin,@pt)
		ttpos=SendMessage(ah.htt,TTM_SETITEM,0,Cast(LPARAM,@tti))
		pt.x=pt.x-ttpos
		'SendMessage(ah.htt,TTM_SCREENFITS,0,Cast(LPARAM,@pt))
		If edtopt.tooltip Then
			SetWindowPos(ah.htt,HWND_TOP,pt.x,pt.y+20,0,0,SWP_NOSIZE Or SWP_NOACTIVATE Or SWP_SHOWWINDOW)
			InvalidateRect(ah.htt,NULL,TRUE)
			Return TRUE
		EndIf
	EndIf
	Return FALSE

End Function

Sub SetWinCaption ()

	If ah.hred Then
		If fProject Then
			SetWindowText(ah.hwnd,"FbEditMOD - " & ProjectDescription & " - ["& ad.filename & "]")
		Else
			SetWindowText(ah.hwnd,"FbEditMOD - " & ad.filename)
		EndIf
	Else
		If fProject Then
			SetWindowText(ah.hwnd,"FbEditMOD - " & ProjectDescription)
		Else
			SetWindowText(ah.hwnd,"FbEditMOD")
		EndIf
	EndIf

End Sub

Sub CenterOwner (ByVal hWin As HWND)
	Dim hPar As HWND
	Dim rect As RECT
	Dim rect1 As RECT

	hPar=Cast(HWND,GetWindowLong(hWin,GWL_HWNDPARENT))
	If hPar=0 Then
		hPar=GetDesktopWindow
	EndIf
	GetWindowRect(hPar,@rect)
	GetWindowRect(hWin,@rect1)
	rect1.right=rect1.right-rect1.left
	rect1.bottom=rect1.bottom-rect1.top
	rect1.left=rect.left+(rect.right-rect.left-rect1.right)\2
	rect1.top=rect.top+(rect.bottom-rect.top-rect1.bottom)\2
	MoveWindow(hWin,rect1.left,rect1.top,rect1.right,rect1.bottom,FALSE)
	
End Sub

Sub ShowProjectTab ()

	If SendMessage(ah.htab,TCM_GETCURSEL,0,0)=0 Then
		' File browser
		ShowWindow(ah.hfib,SW_SHOWNA)
		ShowWindow(ah.hprj,SW_HIDE)
	Else
		' Project browser
		ShowWindow(ah.hprj,SW_SHOWNA)
		ShowWindow(ah.hfib,SW_HIDE)
	EndIf

End Sub

Sub MakeSubMenu (ByVal SubMenuID As UINT, ByVal FirstID As UINT, ByVal LastID As UINT, ByRef IniSection As ZString Ptr)
	
	Dim ID  As UInteger  = Any 
	Dim x   As Integer   = Any 
	Dim mii As MENUITEMINFO

	mii.cbSize = SizeOf (MENUITEMINFO)
	mii.fMask  = MIIM_SUBMENU
	GetMenuItemInfo ah.hmenu, SubMenuID, FALSE, @mii

	For ID = FirstID To LastID
	    DeleteMenu mii.hSubMenu, ID, MF_BYCOMMAND
		GetPrivateProfileString IniSection, Str (ID - FirstID + 1), NULL, @buff, GOD_EntrySize, @ad.IniFile
		If IsZStrNotEmpty (buff) Then
			ReplaceChar1stHit buff, Asc (","), NULL 
			If buff = "-" Then
				AppendMenu mii.hSubMenu, MF_SEPARATOR, ID, NULL 
			Else
				AppendMenu mii.hSubMenu, MF_STRING, ID, @buff
			EndIf
		EndIf
	Next 

End Sub

Sub MakeMenuMruProjects ()
	
	Dim Item  As ZString * 260
	Dim pSpec As ZString Ptr = Any 
	Dim i     As Integer     = Any
	Dim j     As Integer     = Any 
	Dim x     As Integer     = Any 
	Dim hMnu  As HMENU       = Any 

	hMnu = GetSubMenu (ah.hmenu, 0)
	For i = 0 To 3
		DeleteMenu hMnu, IDM_FILE_MRUPROJECT_1 + i, MF_BYCOMMAND
	Next 

	j = 0
	For i = 1 To 4
		If GetPrivateProfileString (@"MruProject", Str(i), NULL, @Item, SizeOf (Item), @ad.IniFile) Then
			MruProject(j) = Item
			SplitStr Item, Asc (","), pSpec
			If FileExists (pSpec) Then
				AppendMenu hMnu, MF_STRING, IDM_FILE_MRUPROJECT_1 + j, "&" + Str (j + 1) + " " + Item
				j += 1
			EndIf
		EndIf
	Next 
	CallAddins(ah.hwnd,AIM_MENUREFRESH,0,0,HOOK_MENUREFRESH)

End Sub

Sub AddMruProject ()
	'Dim sItem As ZString*260
	Dim pFile As ZString Ptr = Any 
	Dim i As Integer = Any 
	Dim x As Integer = Any 
	Dim hMnu As HMENU

	hMnu = GetSubMenu (ah.hmenu, 0)
	For i=0 To 3
		x=InStr(MruProject(i),",")
		'sItem=Mid(MruProject(i),x+1)
		If lstrcmpi (@MruProject(i)[x], @ad.ProjectFile) = 0 Then
			For x=i To 2
				MruProject(x)=MruProject(x+1)
			Next 
			SetZStrEmpty (MruProject(3))             'MOD 26.1.2012 
		EndIf
	Next 
	For i=3 To 1 Step -1
		MruProject(i)=MruProject(i-1)
	Next 
	MruProject(0)=ProjectDescription & "," & ad.ProjectFile
	For i=0 To 3
		DeleteMenu(hMnu,IDM_FILE_MRUPROJECT_1+i,MF_BYCOMMAND)
		WritePrivateProfileString(StrPtr("MruProject"),Str(i+1),@MruProject(i),@ad.IniFile)
		x=InStr(MruProject(i),",")
		If x Then
			AppendMenu(hMnu,MF_STRING,IDM_FILE_MRUPROJECT_1+i,"&" & Str(i+1) & " " & Left(MruProject(i),x-1))
		EndIf
	Next 
	CallAddins(ah.hwnd,AIM_MENUREFRESH,0,0,HOOK_MENUREFRESH)

End Sub

Sub MakeMenuMruFiles ()		

	Dim sFile As ZString * 260
	Dim i     As Integer      = Any
	Dim j     As Integer      = Any
	Dim mii   As MENUITEMINFO = Any 

	mii.cbSize = SizeOf (MENUITEMINFO)
	mii.fMask  = MIIM_SUBMENU
	GetMenuItemInfo ah.hmenu, IDM_FILE_RECENTFILE, FALSE, @mii
	
	For i = 0 To 8
		DeleteMenu mii.hSubMenu, IDM_FILE_MRUFILE_1 + i, MF_BYCOMMAND
	Next
	
	j = 0
	For i = 1 To 9
		If GetPrivateProfileString (@"MruFile", Str (i), NULL, @sFile, SizeOf (sFile), @ad.IniFile) Then
			If FileExists (sFile) Then
				AppendMenu mii.hSubMenu, MF_STRING, IDM_FILE_MRUFILE_1 + j, "&" + Str (j + 1) + " " + *GetFileName (sFile)
				MruFile(j) = sFile
				j += 1
			EndIf
		
			'x=InStr(sFile,",")
			'If x Then
			'	If GetFileAttributes(Mid(sFile,x+1))<>INVALID_FILE_ATTRIBUTES Then
			'		AppendMenu(mii.hSubMenu,MF_STRING,15000+j,"&" & Str(j) & " " & Left(sFile,x-1))
			'		MruFile(j-1)=sFile
			'		j=j+1
			'	EndIf
			'EndIf
		EndIf
	Next 
	CallAddins(ah.hwnd,AIM_MENUREFRESH,0,0,HOOK_MENUREFRESH)

End Sub

Sub AddMruFile(Byref sFile As ZString)

	Dim sItem As ZString*260
	Dim i As Integer = Any 
	Dim x As Integer = Any 
	Dim mii As MENUITEMINFO

	If fProject Then
		If GetFileID (sFile) Then
			Exit Sub
		EndIf
	EndIf

	mii.cbSize=SizeOf(MENUITEMINFO)
	mii.fMask=MIIM_SUBMENU
	GetMenuItemInfo(ah.hmenu,IDM_FILE_RECENTFILE,FALSE,@mii)

	For i=0 To 8
		'x=InStr(MruFile(i),",")
		'sItem=Mid(MruFile(i),x+1)
		If lstrcmpi(MruFile(i),sFile)=0 Then
			For x=i To 7
				MruFile(x)=MruFile(x+1)
			Next 
			SetZStrEmpty (MruFile(8))                      'MOD 26.1.2012 
		EndIf
	Next 
	
	For i=8 To 1 Step -1
		MruFile(i)=MruFile(i-1)
	Next
	
	MruFile(0) = sFile
	'MruFile(0) = *GetFileName (sFile) & "," & sFile        ' MOD 22.1.2012
	For i=0 To 8
		DeleteMenu(mii.hSubMenu,IDM_FILE_MRUFILE_1+i,MF_BYCOMMAND)
		WritePrivateProfileString(StrPtr("MruFile"),Str(i+1),@MruFile(i),@ad.IniFile)
		If IsZStrNotEmpty (MruFile (i)) then
			AppendMenu mii.hSubMenu, MF_STRING, IDM_FILE_MRUFILE_1 + i, "&" + Str (i + 1) + " " + *GetFileName (MruFile(i))
		EndIf 
		'x=InStr(MruFile(i-1),",")
		'If x Then
		'	AppendMenu(mii.hSubMenu,MF_STRING,15000+i,"&" & Str(i) & " " & Left(MruFile(i-1),x-1))
		'EndIf
	Next 
	CallAddins(ah.hwnd,AIM_MENUREFRESH,0,0,HOOK_MENUREFRESH)
End Sub
