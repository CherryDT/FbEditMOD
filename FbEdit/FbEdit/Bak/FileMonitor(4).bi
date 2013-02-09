


Type FileMonitor

    Private:
        Declare Sub FileMonitorProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM)

        Const IDT_FILEMONITOR = 201

        
    Public:
        Declare Sub Start ()
        Declare Sub Stop  ()
        
End Type     


Extern FMon As FileMonitor


