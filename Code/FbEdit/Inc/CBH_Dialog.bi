
    
    Declare Function CBHDlgProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wparm As WPARAM, ByVal lparm As LPARAM) As Integer 
    Declare Function CBHBoxProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParm As WPARAM, ByVal lParm As LPARAM) As Integer


    #Define IDD_DLG_CBH         6500 
    #Define CBH_SETTARGET       WM_USER + 1                              ' sets paste target window, wparam = 0, lparam = Handle As HWND


    Extern hCBHDlg       As HWND
    Extern CBHDlgDefProc As WNDPROC 


