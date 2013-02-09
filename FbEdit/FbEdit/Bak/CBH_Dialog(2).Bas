

    #Include Once "windowsUR.bi"
    #Include Once "win\commctrlUR.bi"

    #Include Once "Inc\Addins.bi"
    #Include Once "Inc\FbEdit.bi"
    #Include Once "Inc\IniFile.bi"
    #Include Once "Inc\Language.bi"

    #Include Once "Inc\CBH_Dialog.bi"



    #Define IDC_EDT1         1001
    #Define IDC_EDT2         1002
    #Define IDC_EDT3         1003
    #Define IDC_EDT4         1004
    #Define IDC_EDT5         1005
    #Define IDC_STC_HINT     1006


    Dim Shared CBH_hTarget   As HWND                                  ' paste target window, if zero no paste is done, only clipboard is updated for manually pasting


Function CBHDlgProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParm As WPARAM, ByVal lParm As LPARAM) As Integer

    Const  Boundary    As Integer     = 5                             ' Pixel	
    Static hNextViewer As HWND
    Static TopCBHBox   As Integer 
    Dim    pMem        As Any Ptr     = Any  
    Dim    hMem        As HGLOBAL     = Any 
    Dim    i           As Integer     = Any 
	Dim    DlgRect     As RECT        = Any
	Dim    HintRect    As RECT        = Any 
	Dim    h           As Integer     = Any
	Dim    y           As Integer     = Any 
    Dim    hCtrl       As HWND        = Any 
	
	Select Case uMsg
	Case WM_INITDIALOG
        hCBHDlg   = hWin
	    TopCBHBox = IDC_EDT1 - 1                                      ' there is a INC before usage

        TranslateDialog hWin, IDD_DLG_CBH
                                
        GetWindowRect hWin, @DlgRect                                  ' startup position for non existing ini file entry
        LoadFromIni "Win", "CBHDlgPos", "4444", @DlgRect, FALSE
        With DlgRect
            SetWindowPos hWin, HWND_TOP, .Left, .Top, .Right - .Left, .Bottom - .Top, SWP_HIDEWINDOW
        End With
        
	    hNextViewer = SetClipboardViewer (hwin)                       ' our neighbor in viewer chain
        For i = IDC_EDT1 To IDC_EDT5
            hCtrl = GetDlgItem (hWin, i)       
            CBHDlgDefProc = Cast (WNDPROC, SetWindowLongPtr (hCtrl, GWLP_WNDPROC, Cast (LONG_PTR, @CBHBoxProc)))
            SendMessage hCtrl, WM_SETFONT, Cast (WPARAM, ah.hOutFont), FALSE
            SendMessage hCtrl, EM_LIMITTEXT, 0, 0                     ' the sky is the limit   
        Next 
	    Return TRUE 
	
	Case CBH_SETTARGET
	    CBH_hTarget = Cast (HWND, lParm)
	    Return TRUE                                                   ' unused
	    
	Case WM_DRAWCLIPBOARD
        If OpenClipboard (NULL) Then  
            If IsClipboardFormatAvailable (CF_TEXT) Then 
                hMem = GetClipboardData (CF_TEXT)
                pMem = GlobalLock (hMem)
                If pMem Then
                    If GetClipboardOwner <> hCBHDlg Then                  ' last EmptyClipBoard assigned ownership                 
                        TopCBHBox += 1                                    ' inc here, so value out of proc is valid too
                        If TopCBHBox > IDC_EDT5 Then TopCBHBox = IDC_EDT1
                        SendDlgItemMessage hWin, TopCBHBox, WM_SETTEXT, NULL, Cast (LPARAM, pMem)
                        SendMessage hWin, WM_SIZE, SIZE_RESTORED, 0       ' push panes down 1 step
                    EndIf
                EndIf
                GlobalUnlock hMem
            EndIf 
            CloseClipboard
	    EndIf
	    If hNextViewer Then 
	        SendMessage hNextViewer, uMsg, wParm, lParm 
	    EndIf
        Return FALSE 
	
	Case WM_CHANGECBCHAIN
        If wParm = hNextViewer Then                               ' If the next window is closing, repair the chain.
            hNextViewer = Cast (HWND, lParm)
        Else                                                      ' Otherwise, pass the message to the next link.
       	    If hNextViewer Then SendMessage hNextViewer, uMsg, wParm, lParm 
        EndIf    
	    Return FALSE 
	    
	Case WM_DESTROY
	    ChangeClipboardChain hWin, hNextViewer
        Return FALSE
        
	Case WM_CLOSE
		GetWindowRect hWin, @DlgRect
        SaveToIni @"Win", @"CBHDlgPos", "4444", @DlgRect, FALSE
		DestroyWindow hWin
		Return TRUE 

	Case WM_SIZE 
        hCtrl = GetDlgItem (hWin, IDC_STC_HINT)
        GetClientRect hCtrl, @HintRect
		GetClientRect hWin, @DlgRect                                
        h = (DlgRect.Bottom - HintRect.Bottom) \ 5 - Boundary            
        y = Boundary
        
        For i = TopCBHBox To IDC_EDT1 Step -1                     ' generate stack effect
			MoveWindow GetDlgItem (hWin, i), Boundary, y, DlgRect.Right - 2 * Boundary, h, TRUE
            y += h + Boundary
        Next
        For i = IDC_EDT5 To TopCBHBox + 1 Step -1
			MoveWindow GetDlgItem (hWin, i), Boundary, y, DlgRect.Right - 2 * Boundary, h , TRUE
            y += h + Boundary
        Next
        
        MoveWindow hCtrl, Boundary, DlgRect.Bottom - HintRect.Bottom , HintRect.Right, HintRect.Bottom, TRUE
        Return FALSE
         
	Case Else
		Return FALSE
			
	End Select

End Function


Function CBHBoxProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParm As WPARAM, ByVal lParm As LPARAM) As Integer
	
    Dim TextLen As LRESULT = Any 
    Dim hMem    As HGLOBAL = Any 
    Dim pMem    As Any Ptr = Any 
		
	Select Case uMsg
	Case WM_CHAR
	    Select Case wParm
	    Case VK_ESCAPE
       	    ShowWindow hCBHDlg, SW_HIDE   
	    Case Else
	        Return CallWindowProc (CBHDlgDefProc, hWin, uMsg, wParm, lParm)    
	    End Select
	    Return FALSE 
	    
	Case WM_LBUTTONDBLCLK
		If OpenClipboard (hCBHDlg) Then 
            TextLen = SendMessage (hWin, WM_GETTEXTLENGTH, 0, 0)
            hMem = GlobalAlloc (GMEM_MOVEABLE, TextLen + 1)
            If hMem Then
                pMem = GlobalLock (hMem)
                SendMessage hWin, WM_GETTEXT, TextLen + 1, Cast (LPARAM, pMem)
                EmptyClipboard
                SetClipboardData CF_TEXT, hMem
                GlobalUnlock hMem
            EndIf 
            CloseClipboard
            ' memory freed by clipboard

            If CBH_hTarget Then
                SetFocus CBH_hTarget
                SendMessage ah.hwnd, WM_COMMAND, IDM_EDIT_PASTE, 0
            EndIf
		EndIf    

	    ShowWindow hCBHDlg, SW_HIDE
	    Return TRUE  

	Case Else
        Return CallWindowProc (CBHDlgDefProc, hWin, uMsg, wParm, lParm)

    End Select     
End Function

