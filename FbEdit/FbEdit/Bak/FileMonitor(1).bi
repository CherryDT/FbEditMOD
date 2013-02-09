


Type FileMonitor

    Private:
        Dim TimerRunning As UINT  

        Const IDT_FILEMONITOR = 201

        
    Public:
        Declare Sub Start ()
        Declare Sub Stop  ()
        
End Type     


Extern FMon As FileMonitor


