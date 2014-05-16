

#Include Once "windows.bi"

#Include Once "Inc\Addins.bi"
#Include Once "Inc\FbEdit.bi"
#Include Once "Inc\Language.bi"
#Include Once "Inc\ZStringHandling.bi"

#Include Once "Inc\showvars.bi"

Type lpDllFunction As Function (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
Type lpInstallDll  As Function (ByVal hWnd As HWND, ByVal hInst As HINSTANCE) As ADDINHOOKS Ptr

Type ADDIN
    hdll        As HMODULE
    lpdllfunc   As Any Ptr
    hooks       As ADDINHOOKS
End Type

Dim Shared DllFunction        As lpDllFunction
Dim Shared InstallDll         As lpInstallDll
Dim Shared lpOldAddinListProc As Any Ptr
Dim Shared addins(31)         As ADDIN

Function AddinListProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
    Dim pt As Point
    Dim cursel As Integer
    Dim chkval As Integer

    Select Case uMsg
        Case WM_LBUTTONDOWN
            SetCapture(hWin)
            '
        Case WM_LBUTTONUP
            pt.x=LoWord(lParam)
            pt.y=HiWord(lParam)
            If pt.x>=1 And pt.x<=14 Then
                cursel=SendMessage(hWin,LB_GETCURSEL,0,0)
                chkval=SendMessage(hWin,LB_GETITEMDATA,cursel,0) Xor 1
                SendMessage(hWin,LB_SETITEMDATA,cursel,chkval)
                InvalidateRect(hWin,NULL,TRUE)
            EndIf
            ReleaseCapture
            '
    End Select
    Return CallWindowProc(lpOldAddinListProc,hWin,uMsg,wParam,lParam)

End Function

Function AddinManagerProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
    Dim wfd As WIN32_FIND_DATA
    Dim hwfd As HANDLE
    Dim hDll As HMODULE
    Dim nInx As Integer
    Dim lpDRAWITEMSTRUCT As DRAWITEMSTRUCT Ptr
    Dim rect As RECT
    Dim sItem As ZString*256
    Dim hLst As HWND
    Dim x As Integer

    Select Case uMsg
        Case WM_INITDIALOG
            TranslateDialog(hWin,IDD_DLG_ADDINMANAGER)
            hLst=GetDlgItem(hWin,IDC_LSTADDINS)
            lpOldAddinListProc=Cast(Any Ptr,SetWindowLong(hLst,GWL_WNDPROC,Cast(Integer,@AddinListProc)))
            nInx=0
            buff=ad.AppPath & "\Addins\*.dll"
            hwfd=FindFirstFile(@buff,@wfd)
            If hwfd<>INVALID_HANDLE_VALUE Then
                While TRUE
                    buff=ad.AppPath & "\Addins\" & wfd.cFileName
                    hDll=LoadLibrary(@buff)
                    If hDll Then
                        InstallDll=Cast(Any Ptr,GetProcAddress(hDll,StrPtr("InstallDll")))
                        If InstallDll Then
                            InstallDll=Cast(Any Ptr,GetProcAddress(hDll,StrPtr("DllFunction")))
                            If InstallDll Then
                                nInx=SendMessage(hLst,LB_ADDSTRING,0,Cast(LPARAM,@wfd.cFileName))
                                If GetPrivateProfileInt("Addins",@wfd.cFileName,1,ad.IniFile) Then
                                    SendMessage(hLst,LB_SETITEMDATA,nInx,1)
                                EndIf
                            EndIf
                        EndIf
                        FreeLibrary(hDll)
                    EndIf
                    If FindNextFile(hwfd,@wfd)=FALSE Then
                        Exit While
                    EndIf
                Wend
                FindClose(hwfd)
            EndIf
            SendMessage(hLst,LB_SETCURSEL,0,0)
            '
        Case WM_CLOSE
            EndDialog(hWin, 0)
            '
        Case WM_COMMAND
            Select Case HiWord(wParam)
                Case BN_CLICKED
                    Select Case LoWord(wParam)
                        Case IDCANCEL
                            EndDialog(hWin, 0)
                            '
                        Case IDOK
                            nInx=0
                            While TRUE
                                If SendDlgItemMessage(hWin,IDC_LSTADDINS,LB_GETTEXT,nInx,Cast(LPARAM,@sItem))=LB_ERR Then
                                    Exit While
                                EndIf
                                x=SendDlgItemMessage(hWin,IDC_LSTADDINS,LB_GETITEMDATA,nInx,0)
                                WritePrivateProfileString("Addins",@sItem,Str(x),ad.IniFile)
                                nInx=nInx+1
                            Wend
                            EndDialog(hWin, 0)
                            '
                        Case IDC_ADDINHELP
                            nInx=SendDlgItemMessage(hWin,IDC_LSTADDINS,LB_GETCURSEL,0,0)
                            SendDlgItemMessage(hWin,IDC_LSTADDINS,LB_GETTEXT,nInx,Cast(LPARAM,@sItem))
                            SplitStr sItem, Asc ("."), 0
                            'sItem=Left(sItem,InStr(sItem,".")-1)
                            buff=ad.AppPath & "\Addins\Help\" & sItem & ".txt"
                            ShellExecute(hWin,"Open",@buff,NULL,NULL,SW_SHOWNORMAL)
                            '
                    End Select
                    '
            End Select
            '
        Case WM_DRAWITEM
            lpDRAWITEMSTRUCT=Cast(DRAWITEMSTRUCT Ptr,lParam)
            ' Select back and text colors
            If lpDRAWITEMSTRUCT->itemState And ODS_SELECTED Then
                SetTextColor(lpDRAWITEMSTRUCT->hdc,GetSysColor(COLOR_HIGHLIGHTTEXT))
                SetBkColor(lpDRAWITEMSTRUCT->hdc,GetSysColor(COLOR_HIGHLIGHT))
            Else
                SetTextColor(lpDRAWITEMSTRUCT->hdc,GetSysColor(COLOR_WINDOWTEXT))
                SetBkColor(lpDRAWITEMSTRUCT->hdc,GetSysColor(COLOR_WINDOW))
            EndIf
            ' Draw selected / unselected back color
            ExtTextOut(lpDRAWITEMSTRUCT->hdc,0,0,ETO_OPAQUE,@lpDRAWITEMSTRUCT->rcItem,NULL,0,NULL)
            ' Draw the checkbox
            rect.left=lpDRAWITEMSTRUCT->rcItem.left+1
            rect.right=rect.left+13
            rect.top=lpDRAWITEMSTRUCT->rcItem.top+1
            rect.bottom=rect.top+13
            If lpDRAWITEMSTRUCT->itemData Then
                nInx=DFCS_BUTTONCHECK Or DFCS_FLAT Or DFCS_CHECKED
            Else
                nInx=DFCS_BUTTONCHECK Or DFCS_FLAT
            EndIf
            DrawFrameControl(lpDRAWITEMSTRUCT->hdc,@rect,DFC_BUTTON,nInx)
            ' Draw the text
            SendMessage(lpDRAWITEMSTRUCT->hwndItem,LB_GETTEXT,lpDRAWITEMSTRUCT->itemID,Cast(Integer,@sItem))
            TextOut(lpDRAWITEMSTRUCT->hdc,lpDRAWITEMSTRUCT->rcItem.left+18,lpDRAWITEMSTRUCT->rcItem.top,@sItem,Len(sItem))
            If lpDRAWITEMSTRUCT->hwndItem=GetFocus() Then
                ' Let windows draw the focus rectangle
                Return FALSE
            EndIf
            '
        Case Else
            Return FALSE
            '
    End Select
    Return TRUE

End Function

Function CallAddins(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM,ByVal hook1 As UINT) As Integer
    Dim nInx As Integer
    Dim b As Integer

    nInx=0
    While nInx<32
        If addins(nInx).hdll Then
            If (addins(nInx).hooks.hook1 And hook1)<>0 Then
                DllFunction=addins(nInx).lpdllfunc
                b=DllFunction(hWin,uMsg,wParam,lParam)
                If b Then
                    Exit While
                EndIf
            EndIf
        Else
            Exit While
        EndIf
        nInx=nInx+1
    Wend
    Return b

End Function

Sub LoadAddins
    Dim wfd As WIN32_FIND_DATA
    Dim hwfd As HANDLE
    Dim hDll As HMODULE
    Dim nInx As Integer
    Dim x As Any Ptr
    Dim y As ADDINHOOKS Ptr
    Dim hwin As HWND

    nInx=0
    hwin=ah.hwnd
    buff=ad.AppPath & "\Addins\*.dll"

    hwfd=FindFirstFile(@buff,@wfd)
    If hwfd<>INVALID_HANDLE_VALUE Then
        While TRUE
            If GetPrivateProfileInt("Addins",@wfd.cFileName,0,ad.IniFile) Then
                buff=ad.AppPath & "\Addins\" & wfd.cFileName
                hDll=LoadLibrary(@buff)
                If hDll Then
                    InstallDll=Cast(Any Ptr,GetProcAddress(hDll,StrPtr("InstallDll")))
                    If InstallDll Then
                        y=InstallDll(hwin,hDll)
                        addins(nInx).hdll=hDll
                        addins(nInx).hooks.hook1=y->hook1
                        addins(nInx).hooks.hook2=y->hook2
                        addins(nInx).hooks.hook3=y->hook3
                        addins(nInx).hooks.hook4=y->hook4
                        addins(nInx).lpdllfunc=GetProcAddress(hDll,StrPtr("DllFunction"))
                        nInx=nInx+1
                    Else
                        FreeLibrary(hDll)
                    EndIf
                EndIf
            EndIf
            If FindNextFile(hwfd,@wfd)=FALSE Then
                Exit While
            EndIf
        Wend
        FindClose(hwfd)
        CallAddins(ah.hwnd,AIM_ADDINSLOADED,0,0,HOOK_ADDINSLOADED)
    EndIf
End Sub

Sub FreeAddins
    Dim nInx As Integer

    While addins(nInx).hdll
        FreeLibrary(addins(nInx).hdll)
        nInx+=1
    Wend

End Sub