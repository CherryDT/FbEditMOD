
#Include Once "windowsUR.bi"
#Include Once "win\shlwapi.bi"
#Include Once "win\richedit.bi"

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAGrid.bi"
#Include Once "Inc\RAProperty.bi"


#Include Once "Inc\Addins.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\GUIHandling.bi"
#Include Once "Inc\IniFile.bi"
#Include Once "Inc\Language.bi"
#Include Once "Inc\Project.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\Environment.bi"




Function EnvironProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
	
	Dim    i              As Integer             = Any
	Dim    n              As Integer             = Any 
    Dim    dW             As Integer             = Any 
    Dim    dH             As Integer             = Any 
	Dim    hGrd           As HWND                = Any 
    Dim    hGrdPath       As HWND                = Any
    Dim    hGrdUserPath   As HWND                = Any
    Dim	   hGrdReadOnly   As HWND                = Any
    Dim    hGrdUserString As HWND                = Any
    Dim    hDlgItem       As HWND                = Any 
	Dim    clmn           As COLUMN             
	Dim    row(1)         As ZString Ptr         = Any 
    Dim    CurrRow        As Integer             = Any 
    Dim    RowCol         As DWORD               = Any 
    Dim    EPathValue     As EnvironPathValue
    Dim    EStringValue   As EnvironStringValue 
    Dim    EName          As EnvironVarName
	Dim    EditorMode     As Long                = Any 
	Dim    pPIDL          As LPCITEMIDLIST       = Any 
	Dim    bri            As BROWSEINFO
    Dim    SectionBuffer  As ZString * 64 * 1024
  	Dim    DlgRect        As RECT                = Any
    Dim    ItemRect       As RECT                = Any  
    Static InitRect       As RECT                = Any         ' client coords
    Static DlgRectOld     As RECT                = Any         ' client coords

	Select Case uMsg
	Case WM_INITDIALOG
	    
		TranslateDialog hWin, IDD_DLG_ENVIRON
        GetClientRect hWin, @InitRect
        DlgRectOld = InitRect
        
        GetWindowRect hWin, @DlgRect                                 ' startup position for non existing ini file entry
        LoadFromIni "Win", "EnvironDlgPos", "4444", @DlgRect, FALSE
        SetWindowPos hWin, HWND_TOP, DlgRect.Left, DlgRect.Top, DlgRect.Right - DlgRect.Left, DlgRect.Bottom - DlgRect.Top, NULL
        
        ' build all grids
        For i = 1 To UBound (EnvDlgGrdItems)
            
            hGrd = GetDlgItem (hWin, EnvDlgGrdItems(i))
			SendMessage hGrd, WM_SETFONT, SendMessage (hWin, WM_GETFONT, 0, 0), FALSE
			SendMessage hGrd, GM_SETHDRHEIGHT, 0, 22
			SendMessage hGrd, GM_SETROWHEIGHT, 0, 20
                    
			clmn.colwt       = 160
			clmn.lpszhdrtext = @"Name"
			clmn.ctype       = TYPE_EDITTEXT 
			clmn.ctextmax    = SizeOf (EnvironVarName)
			SendMessage hGrd, GM_ADDCOL, 0, Cast (LPARAM, @clmn)
		    
		    Select Case EnvDlgGrdItems(i)
		    Case IDC_GRD_USERSTRING
		        clmn.ctype    = TYPE_EDITTEXT 
		        clmn.ctextmax = SizeOf (EnvironStringValue)
		    Case IDC_GRD_READONLY
		        clmn.ctype    = TYPE_EDITTEXT
		        clmn.ctextmax = SizeOf (EnvironStringValue)
		    Case IDC_GRD_USERPATH
		        clmn.ctype    = TYPE_BUTTON 
		        clmn.ctextmax = SizeOf (EnvironPathValue)
		    Case IDC_GRD_PATH    
		        clmn.ctype    = TYPE_BUTTON 
		        clmn.ctextmax = SizeOf (EnvironPathValue)
		    End Select

			clmn.colwt       = 320
    		clmn.lpszhdrtext = @"Value"
			SendMessage hGrd, GM_ADDCOL, 0, Cast (LPARAM, @clmn)
        Next
        
        ' fill grid: ReadOnly
        row(0) = @"FBE_PATH"
        row(1) = @ad.AppPath
        SendDlgItemMessage hWin, IDC_GRD_READONLY, GM_ADDROW, 0, Cast (LPARAM, @row(0))
        
        row(0) = @"CURRTAB_BNAME"
        row(1) = @ad.filename
        SendDlgItemMessage hWin, IDC_GRD_READONLY, GM_ADDROW, 0, Cast (LPARAM, @row(0))

        row(0) = @"MAIN_BNAME"
        row(1) = GetProjectFileName (nMain, PT_RELATIVE)
        SendDlgItemMessage hWin, IDC_GRD_READONLY, GM_ADDROW, 0, Cast (LPARAM, @row(0))

        row(0) = @"MAIN_RES_BNAME"
        row(1) = StrPtr(Type<String>(GetProjectMainResource ()))
        SendDlgItemMessage hWin, IDC_GRD_READONLY, GM_ADDROW, 0, Cast (LPARAM, @row(0))

        row(0) = @"COMPILIN_BNAME"
        row(1) = NULL                 ' updated by MakeBuild on every call
        SendDlgItemMessage hWin, IDC_GRD_READONLY, GM_ADDROW, 0, Cast (LPARAM, @row(0))

        row(0) = @"BUILD_TYPE"
        row(1) = NULL                 ' updated by MakeBuild on every call
        SendDlgItemMessage hWin, IDC_GRD_READONLY, GM_ADDROW, 0, Cast (LPARAM, @row(0))

        row(0) = @"CARET_WORD"
        row(1) = NULL
        If ah.hred then
            EditorMode = GetWindowLong (ah.hred, GWL_ID)    
            If EditorMode = IDC_CODEED _
            OrElse EditorMode = IDC_TEXTED Then
                SendMessage ah.hred, REM_GETWORD, SizeOf (EnvironStringValue), Cast (LPARAM, @buff)
                row(1) = @buff
            EndIf    
        EndIf     
        SendDlgItemMessage hWin, IDC_GRD_READONLY, GM_ADDROW, 0, Cast (LPARAM, @row(0))

        ' fill grid: Path
    	For i = 1 To UBound (EnvPaths)
    		GetPrivateProfileString @"EnvironPath", EnvPaths(i), NULL, @EPathValue, SizeOf (EPathValue), @ad.IniFile
    		'If EPathValue[0] Then
				row(0) = @EnvPaths(i)
		        row(1) = @EPathValue 
			    SendDlgItemMessage hWin, IDC_GRD_PATH, GM_ADDROW, 0, Cast (LPARAM, @row(0))
    		'EndIf
    	Next
        
        ' fill grid: UserPath
        GetPrivateProfileSection "EnvironUserPath", @SectionBuffer, SizeOf (SectionBuffer), ad.IniFile
        i = 0
        Do
            DePackStr i, @SectionBuffer, row(0)
            SplitStr *row(0), Asc ("="), row(1)
            SendDlgItemMessage hWin, IDC_GRD_USERPATH, GM_ADDROW, 0, Cast (LPARAM, @row(0))
        Loop While i
        
        ' fill grid: UserString
        GetPrivateProfileSection "EnvironUserString", @SectionBuffer, SizeOf (SectionBuffer), ad.IniFile
        i = 0
        Do
            DePackStr i, @SectionBuffer, row(0)
            SplitStr *row(0), Asc ("="), row(1)
            SendDlgItemMessage hWin, IDC_GRD_USERSTRING, GM_ADDROW, 0, Cast (LPARAM, @row(0))
        Loop While i
            
	Case WM_CLOSE
   		GetWindowRect hWin, @DlgRect
        SaveToIni @"Win", @"EnvironDlgPos", "4444", @DlgRect, FALSE
		EndDialog hWin, 0

	Case WM_COMMAND
		Select Case LoWord (wParam)
		Case IDOK
            hGrdPath = GetDlgItem (hWin, IDC_GRD_PATH)
			RowCol = SendMessage (hGrdPath, GM_GETCURSEL, 0, 0)
		    SendMessage hGrdPath, GM_ENDEDIT, RowCol, FALSE  
			n = SendMessage (hGrdPath, GM_GETROWCOUNT, 0, 0)
			For i = 0 To n - 1                
                SendMessage hGrdPath, GM_GETCELLDATA, MAKEWPARAM (0, i), Cast (LPARAM, @EName)
                SendMessage hGrdPath, GM_GETCELLDATA, MAKEWPARAM (1, i), Cast (LPARAM, @EPathValue)     
		        WritePrivateProfileString "EnvironPath", @EName, @EPathValue, ad.IniFile
		        
		        Select Case EName 
		        Case "HELP_PATH"      :  ad.HelpPath       = EPathValue 
		        Case "FBC_PATH"       :  ad.fbcPath        = EPathValue
		        Case "FBCINC_PATH"    :  ad.FbcIncPath     = EPathValue
		        Case "FBCLIB_PATH"    :  ad.FbcLibPath     = EPathValue
		        Case "PROJECTS_PATH"  :  ad.DefProjectPath = EPathValue   
		        End Select
			Next

            hGrdUserPath = GetDlgItem (hWin, IDC_GRD_USERPATH)
			RowCol = SendMessage (hGrdUserPath, GM_GETCURSEL, 0, 0)
		    SendMessage hGrdUserPath, GM_ENDEDIT, RowCol, FALSE  
			WritePrivateProfileSection "EnvironUserPath", !"\0", ad.IniFile        'remove all keys
			n = SendMessage (hGrdUserPath, GM_GETROWCOUNT, 0, 0)
			For i = 0 To n - 1                
                SendMessage hGrdUserPath, GM_GETCELLDATA, MAKEWPARAM (0, i), Cast (LPARAM, @EName)
                If IsZStrNotEmpty (EName) Then
                    SendMessage hGrdUserPath, GM_GETCELLDATA, MAKEWPARAM (1, i), Cast (LPARAM, @EPathValue)     
			        WritePrivateProfileString "EnvironUserPath", @EName, @EPathValue, ad.IniFile
			    EndIf 
			Next
			
			hGrdUserString = GetDlgItem (hWin, IDC_GRD_USERSTRING)
			RowCol = SendMessage (hGrdUserString, GM_GETCURSEL, 0, 0)
			SendMessage hGrdUserString, GM_ENDEDIT, RowCol, FALSE 
			WritePrivateProfileSection "EnvironUserString", !"\0", ad.IniFile      'remove all keys
			n = SendMessage (hGrdUserString, GM_GETROWCOUNT, 0, 0)
			For i = 0 To n - 1                
                SendMessage hGrdUserString, GM_GETCELLDATA, MAKEWPARAM (0, i), Cast (LPARAM, @EName)
                If IsZStrNotEmpty (EName) Then
                    SendMessage hGrdUserString, GM_GETCELLDATA, MAKEWPARAM (1, i), Cast (LPARAM, @EStringValue)     
			        WritePrivateProfileString "EnvironUserString", @EName, @EStringValue, ad.IniFile
			    EndIf 
			Next
			SendMessage hWin, WM_CLOSE, 0, 0
                            
	    Case IDCANCEL
	        hGrdUserPath = GetDlgItem (hWin, IDC_GRD_USERPATH)
			SendMessage hGrdUserPath, GM_GETCELLDATA, MAKEWPARAM (1, 0), Cast (LPARAM, @buff)
			SendMessage hGrdUserPath, GM_GETCELLDATA, MAKEWPARAM (1, 1), Cast (LPARAM, @buff)
			SendMessage hWin, WM_CLOSE, 0, 0
	
	    Case IDC_BTN_ADD_USERPATH
	        row(0) = NULL
	        row(1) = NULL
            SendDlgItemMessage hWin, IDC_GRD_USERPATH, GM_ADDROW, 0, Cast (LPARAM, @row(0))
	    
		Case IDC_BTN_DEL_USERPATH  
			CurrRow = SendDlgItemMessage (hWin, IDC_GRD_USERPATH, GM_GETCURROW, 0, 0)
	        SendDlgItemMessage hWin, IDC_GRD_USERPATH, GM_DELROW, CurrRow, 0

	    Case IDC_BTN_ADD_USERSTRING
	        row(0) = NULL
	        row(1) = NULL 
            SendDlgItemMessage hWin, IDC_GRD_USERSTRING, GM_ADDROW, 0, Cast (LPARAM, @row(0))

	    Case IDC_BTN_DEL_USERSTRING
			CurrRow = SendDlgItemMessage (hWin, IDC_GRD_USERSTRING, GM_GETCURROW, 0, 0)
	        SendDlgItemMessage hWin, IDC_GRD_USERSTRING, GM_DELROW, CurrRow, 0
		End Select

	Case WM_NOTIFY
		#Define pGRIDNOTIFY     Cast (GRIDNOTIFY Ptr, lParam)
		hGrdPath       = GetDlgItem (hWin, IDC_GRD_PATH)      
        hGrdUserPath   = GetDlgItem (hWin, IDC_GRD_USERPATH)
		hGrdReadOnly   = GetDlgItem (hWin, IDC_GRD_READONLY)      
        hGrdUserString = GetDlgItem (hWin, IDC_GRD_USERSTRING)

        Select Case pGRIDNOTIFY->nmhdr.hwndFrom        
        Case hGrdPath                      
            Select Case pGRIDNOTIFY->nmhdr.code
            Case GN_HEADERCLICK
                SendMessage hGrdPath, GM_COLUMNSORT, pGRIDNOTIFY->col, SORT_INVERT
            Case GN_BUTTONCLICK 
                bri.hwndOwner = hWin
            	bri.ulFlags   = BIF_RETURNONLYFSDIRS Or BIF_BROWSEINCLUDEFILES Or BIF_NEWDIALOGSTYLE         ' Or BIF_EDITBOX
            	bri.lpfn      = @BrowseForFolderCallBack
            	bri.lParam    = Cast (LPARAM, pGRIDNOTIFY->lpdata)  'browsing starts here 
            	pPIDL = SHBrowseForFolder (@bri)
            	If pPIDL Then
            		SHGetPathFromIDList(pPIDL, Cast (ZString Ptr, pGRIDNOTIFY->lpdata))
            		CoTaskMemFree pPIDL
            	EndIf
            Case GN_BEFOREEDIT
                Select Case pGRIDNOTIFY->col
                Case 0
                    pGRIDNOTIFY->fcancel = TRUE                     ' read only
                End Select 
            End Select 

        Case hGrdUserPath
            Select Case pGRIDNOTIFY->nmhdr.code
            Case GN_HEADERCLICK
                SendMessage hGrdUserPath, GM_COLUMNSORT, pGRIDNOTIFY->col, SORT_INVERT
            Case GN_BUTTONCLICK 
                bri.hwndOwner = hWin
            	bri.ulFlags   = BIF_RETURNONLYFSDIRS Or BIF_BROWSEINCLUDEFILES Or BIF_NEWDIALOGSTYLE         ' Or BIF_EDITBOX
            	bri.lpfn      = @BrowseForFolderCallBack
            	bri.lParam    = Cast (LPARAM, pGRIDNOTIFY->lpdata)  'browsing starts here 
            	pPIDL = SHBrowseForFolder (@bri)
            	If pPIDL Then
            		SHGetPathFromIDList(pPIDL, Cast (ZString Ptr, pGRIDNOTIFY->lpdata))
            		CoTaskMemFree pPIDL
            	EndIf
            Case GN_AFTEREDIT
                Select Case pGRIDNOTIFY->col
                Case 0
                    TrimWhiteSpace *Cast (ZString Ptr, pGRIDNOTIFY->lpdata)
                    ZStrReplaceChar pGRIDNOTIFY->lpdata, Asc ("="), Asc ("*")   
                End Select
            End Select
        
        Case hGrdReadOnly
            Select Case pGRIDNOTIFY->nmhdr.code
            Case GN_HEADERCLICK
                SendMessage hGrdReadOnly, GM_COLUMNSORT, pGRIDNOTIFY->col, SORT_INVERT
            Case GN_BEFOREEDIT
                pGRIDNOTIFY->fcancel = TRUE                         ' read only
            End Select 

        Case hGrdUserString    
            Select Case pGRIDNOTIFY->nmhdr.code
            Case GN_HEADERCLICK
                SendMessage hGrdUserString, GM_COLUMNSORT, pGRIDNOTIFY->col, SORT_INVERT
            Case GN_AFTEREDIT
                Select Case pGRIDNOTIFY->col
                Case 0
                    TrimWhiteSpace *Cast (ZString Ptr, pGRIDNOTIFY->lpdata)
                    ZStrReplaceChar pGRIDNOTIFY->lpdata, Asc ("="), Asc ("*")      
                End Select
            End Select
        End Select
        #Undef  pGRIDNOTIFY

	Case WM_WINDOWPOSCHANGING
        If Cast (WINDOWPOS Ptr, lParam)->CY < InitRect.Bottom Then
            Cast (WINDOWPOS Ptr, lParam)->CY = InitRect.Bottom
        EndIf
        
        If Cast (WINDOWPOS Ptr, lParam)->CX < InitRect.Right Then
            Cast (WINDOWPOS Ptr, lParam)->CX = InitRect.Right
        EndIf
	    
	    Return FALSE 

	Case WM_SIZE
  		GetClientRect hWin, @DlgRect                                
        dW = DlgRect.Right - DlgRectOld.Right
        dH = DlgRect.Bottom - DlgRectOld.Bottom
	    DlgRectOld = DlgRect        
    
        hDlgItem = GetDlgItem (hWin, IDOK)
        GetWindowRect hDlgItem, @ItemRect
	    MapWindowPoints NULL, hWin, Cast (Point Ptr, @ItemRect), 2
	    SetWindowPos hDlgItem, HWND_TOP, ItemRect.Left + dW, ItemRect.Top + dH, 0, 0, SWP_NOSIZE   ' DLG coords

        hDlgItem = GetDlgItem (hWin, IDCANCEL)
        GetWindowRect hDlgItem, @ItemRect
	    MapWindowPoints NULL, hWin, Cast (Point Ptr, @ItemRect), 2
	    SetWindowPos hDlgItem, HWND_TOP, ItemRect.Left + dW, ItemRect.Top + dH, 0, 0, SWP_NOSIZE   ' DLG coords
        
        For i = 1 To EnvDlgGrdCount
            hDlgItem = GetDlgItem (hWin, EnvDlgGrdItems(i))
            GetWindowRect hDlgItem, @ItemRect
    	    MapWindowPoints NULL, hWin, Cast (Point Ptr, @ItemRect), 2
    	    SetWindowPos hDlgItem, HWND_TOP, ItemRect.Left, ItemRect.Top + (i - 1) * dH \ EnvDlgGrdCount, ItemRect.Right - ItemRect.Left + dW, ItemRect.Bottom - ItemRect.Top + dH \ EnvDlgGrdCount, NULL 'DLG Coords
        Next

        For i = 1 To EnvDlgGrdCount
            hDlgItem = GetDlgItem (hWin, EnvDlgStcItems(i))
            GetWindowRect hDlgItem, @ItemRect
    	    MapWindowPoints NULL, hWin, Cast (Point Ptr, @ItemRect), 2
    	    SetWindowPos hDlgItem, HWND_TOP, ItemRect.Left, ItemRect.Top + (i - 1) * dH \ EnvDlgGrdCount, 0, 0, SWP_NOSIZE 'DLG Coords
        Next
       
        For i = 3 To EnvDlgGrdCount
            hDlgItem = GetDlgItem (hWin, EnvDlgAddItems(i))
            GetWindowRect hDlgItem, @ItemRect
    	    MapWindowPoints NULL, hWin, Cast (Point Ptr, @ItemRect), 2
    	    SetWindowPos hDlgItem, HWND_TOP, ItemRect.Left + dW, ItemRect.Top + (i - 1) * dH \ EnvDlgGrdCount, 0, 0, SWP_NOSIZE 'DLG Coords
        Next

        For i = 3 To EnvDlgGrdCount
            hDlgItem = GetDlgItem (hWin, EnvDlgDelItems(i))
            GetWindowRect hDlgItem, @ItemRect
    	    MapWindowPoints NULL, hWin, Cast (Point Ptr, @ItemRect), 2
    	    SetWindowPos hDlgItem, HWND_TOP, ItemRect.Left + dW, ItemRect.Top + (i - 1) * dH \ EnvDlgGrdCount, 0, 0, SWP_NOSIZE 'DLG Coords
        Next
	    Return FALSE 
	
	Case Else
		Return FALSE

	End Select
	Return TRUE
End Function

Sub ExpandStrByEnviron (ByRef Source As ZString, ByVal MaxAttempt As Integer = 5)
    
    ' expands substrings like %var% with values defined in environment
    ' substitution is done inplace
    ' MaxAttempt limits forwarding e.g. greeting=%var1%, %var2%
    '                                   var1=hello
    '                                   var2=%target%
    '                                   target=world
    
    Dim i    As Integer             = Any 
    Dim Dest As ZString * 32 * 1024
        
    For i = 1 To MaxAttempt
        ExpandEnvironmentStrings @Source, @Dest, SizeOf (Dest)

        If Dest = Source Then
            Exit For 
        Else
            Source = Dest         ' TODO: check for buffer overflow
        EndIf
    Next
    
End Sub

Sub UpdateEnvironment

	Dim i              As Integer             = Any
    Dim EPathValue     As EnvironPathValue
    Dim EStringValue   As EnvironStringValue
    Dim EItem          As EnvironItem                      ' "Var=Value"
    Dim pEnvironBlock  As LPTCH               = Any 
	Dim EditorMode     As Long                = Any 
    Dim SectionBuffer  As ZString * 64 * 1024
    Dim pBuff          As ZString Ptr         = Any 
    Dim pBuffB         As ZString Ptr         = Any 

    ' Path
	For i = 1 To UBound (EnvPaths)
		GetPrivateProfileString @"EnvironPath", EnvPaths(i), NULL, @EPathValue, SizeOf (EPathValue), @ad.IniFile
		If EPathValue[0] Then
            SetEnvironmentVariable @EnvPaths(i), @EPathValue
		EndIf
	Next
    
    ' ReadOnly
    SetEnvironmentVariable @"FBE_PATH", @ad.AppPath
    SetEnvironmentVariable @"CURRTAB_BNAME", @ad.filename
    SetEnvironmentVariable @"MAIN_BNAME", GetProjectFileName (nMain, PT_RELATIVE)
    SetEnvironmentVariable @"MAIN_RES_BNAME", StrPtr(Type<String>(GetProjectMainResource ()))
    SetEnvironmentVariable @"COMPILIN_BNAME", @""               ' updated by MakeBuild on every call
    SetEnvironmentVariable @"BUILD_TYPE", @""                   ' updated by MakeBuild on every call
    
    SetZStrEmpty (EStringValue)
    If ah.hred then
        EditorMode = GetWindowLong (ah.hred, GWL_ID)    
        If EditorMode = IDC_CODEED _
        OrElse EditorMode = IDC_TEXTED Then
            SendMessage ah.hred, REM_GETWORD, SizeOf (EStringValue), Cast (LPARAM, @EStringValue)
        EndIf    
    EndIf     
    SetEnvironmentVariable @"CARET_WORD", @EStringValue
    
    ' UserPath
    GetPrivateProfileSection @"EnvironUserPath", @SectionBuffer, SizeOf (SectionBuffer), @ad.IniFile
    i = 0
    Do
        DePackStr i, @SectionBuffer, pBuff
        SplitStr *pBuff, Asc ("="), pBuffB
        SetEnvironmentVariable pBuff, pBuffB
    Loop While i
    
    ' UserString
    GetPrivateProfileSection @"EnvironUserString", @SectionBuffer, SizeOf (SectionBuffer), @ad.IniFile
    i = 0
    Do
        DePackStr i, @SectionBuffer, pBuff
        SplitStr *pBuff, Asc ("="), pBuffB
        SetEnvironmentVariable pBuff, pBuffB
    Loop While i
    
    ' resolve references / backreferences
    pEnvironBlock = GetEnvironmentStrings ()
    i = 0
    Do
        DePackStr i, *pEnvironBlock, EItem, SizeOf (EItem)   ' get copies, EnvironBlock is Const
        SplitStr EItem, Asc ("="), pBuffB
        ExpandStrByEnviron *pBuffB                           ' but we wanna expand
        SetEnvironmentVariable EItem, pBuffB
    Loop While i
    FreeEnvironmentStrings pEnvironBlock

End Sub
