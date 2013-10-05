

#Include Once "windows.bi"
#Include Once "win\shellapi.bi"
#Include Once "win\commctrl.bi"
#Include Once "win\richedit.bi"

#Include Once "Inc\RAEdit.bi"
#Include Once "Inc\RAProperty.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\Language.bi"
#Include Once "Inc\GUIHandling.bi"

#Include Once "Inc\About.bi"


Dim Shared OldUrlProc As Any Ptr
Dim Shared fMouseOver As Boolean
Dim Shared hUrlFont As HFONT
Dim Shared hUrlFontU As HFONT
'Dim Shared hUrlBrush As HBRUSH           MOD 15.1.2012 (unused)


Function UrlProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
    Dim rect As RECT
    Dim buffer As ZString*128

    Select Case uMsg
        Case WM_MOUSEMOVE
            ' Set the hand cursor
            SetCursor(LoadCursor(NULL,IDC_HAND))
            ' Check if mouse is captured
            If GetCapture<>hWin Then
                ' Mouse is not captured and is over the control
                fMouseOver=TRUE
                SetCapture(hWin)
                SendMessage(hWin,WM_SETFONT,Cast(Integer,hUrlFontU),TRUE)
            Else
                ' Mouse is captured
                ' Check if mouse has left the control
                GetClientRect(hWin,@rect)
                If LoWord(lParam)>rect.right Or HiWord(lParam)>rect.bottom Then
                    ' Mouse has left the control
                    fMouseOver=FALSE
                    ReleaseCapture
                    SendMessage(hWin,WM_SETFONT,Cast(Integer,hUrlFont),TRUE)
                EndIf
            EndIf
            '
        Case WM_LBUTTONUP
            ' Url was clicked
            fMouseOver=FALSE
            ReleaseCapture
            SendMessage(hWin,WM_SETFONT,Cast(Integer,hUrlFont),TRUE)
            GetWindowText(hWin,@buffer,SizeOf(buffer))
            ShellExecute(ah.hwnd,StrPtr("Open"),@buffer,NULL,NULL,SW_SHOWNORMAL)
            '
    End Select
    Return CallWindowProc(OldUrlProc,hWin,uMsg,wParam,lParam)

End Function

Function AboutDlgProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
    Dim As Long id,Event
    Dim lf As LOGFONT

    Select Case uMsg
        Case WM_INITDIALOG
            TranslateDialog(hWin,IDD_DLGABOUT)
            SetWindowText(hwin,ad.lpszVersion)
            CenterOwner(hWin)
            ' Subclass the control
            OldUrlProc=Cast(Any Ptr,SetWindowLong(GetDlgItem(hWin,IDC_URL1),GWL_WNDPROC,Cast(Integer,@UrlProc)))
            'SetWindowLong(GetDlgItem(hWin,IDC_URL2),GWL_WNDPROC,Cast(Integer,@UrlProc))
            SetWindowLong(GetDlgItem(hWin,IDC_URL3),GWL_WNDPROC,Cast(Integer,@UrlProc))
            ' Get dialogs font
            hUrlFont=Cast(HFONT,SendMessage(hWin,WM_GETFONT,0,0))
            GetObject(hUrlFont,SizeOf(LOGFONT),@lf)
            ' Create an underlined font
            lf.lfUnderline=TRUE
            hUrlFontU=CreateFontIndirect(@lf)
            ' Create a back brush          MOD 15.1.2012 dont work - GDI leakage 
            'hUrlBrush=CreateSolidBrush(GetSysColor(COLOR_3DFACE))
            '
            
        Case WM_COMMAND
            id=LoWord(wParam)
            Event=HiWord(wParam)
            If Event=BN_CLICKED Then
                If id=IDOK Then
                    SendMessage(hWin,WM_CLOSE,NULL,NULL)
                EndIf
            EndIf
            '
        Case WM_CTLCOLORSTATIC
            If GetDlgItem(hWin,IDC_URL1)=lParam Or GetDlgItem(hWin,IDC_URL2)=lParam Or GetDlgItem(hWin,IDC_URL3)=lParam Then
                ' Set Url control colors
                If fMouseOver Then
                    SetTextColor(Cast(HDC,wParam),&HFF0000)
                Else
                    SetTextColor(Cast(HDC,wParam),0)
                EndIf
                SetBkMode(Cast(HDC,wParam),TRANSPARENT)
                
                ' MOD 15.1.2012    use cached brush
                Return Cast (Integer, GetSysColorBrush (COLOR_3DFACE))
                'Return Cast(Integer,hUrlBrush)
                '=============================
            EndIf
            Return 0
        
        Case WM_CLOSE
            ' Delete font
            DeleteObject(hUrlFontU)
            ' Delete brush
            'DeleteObject(hUrlBrush)    MOD 15.1.2012 dont work - GDI leakage
            EndDialog(hWin,0)

        Case Else
            Return FALSE
            '
    End Select
    Return TRUE

End Function