
    
    #Include Once "windowsUR.bi"


    Declare Function CBHDlgProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wparm As WPARAM, ByVal lparm As LPARAM) As Integer 
    Declare Function CBHBoxProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParm As WPARAM, ByVal lParm As LPARAM) As Integer


    #Define IDD_DLG_CBH         6500 


    Common Shared hCBHDlg       As HWND
    Common Shared CBHDlgDefProc As WNDPROC 


