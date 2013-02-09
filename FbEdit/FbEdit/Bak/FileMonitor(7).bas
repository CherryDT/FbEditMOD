

    #Include Once "windowsUR.bi"
    #Include Once "win\commctrlUR.bi"
    #Include Once "Inc\Addins.bi"
    #Include Once "Inc\FbEdit.bi"
    #Include Once "Inc\FileIO.bi"
    #Include Once "Inc\Language.bi"
    #Include Once "Inc\SpecHandling.bi"
    #Include Once "Inc\TabTool.bi"

    #Include Once "Inc\FileMonitor.bi"

    Declare Sub FileMonitorProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal idEvent As UINT, ByVal dwTime As DWORD)

    Dim Shared FMon As FileMonitor



Sub FileMonitor.Start ()
    
    If TimerRunning = 0 Then
        TimerRunning = SetTimer (ah.hwnd, IDT_FILEMONITOR, 2000, Cast (TIMERPROC, @FileMonitorProc))
    EndIf
    
End Sub


Sub FileMonitor.Stop ()

    If TimerRunning Then
        KillTimer ah.hwnd, IDT_FILEMONITOR
    EndIf 

End Sub


Sub FileMonitorProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal idEvent As UINT, ByVal dwTime As DWORD)

	Dim tci   As TCITEM
	Dim i     As Integer  = 0
	Dim hFile As HANDLE   = Any 
	Dim ft    As FILETIME = Any 

	tci.mask=TCIF_PARAM
	
	Print "FileMon:";idEvent;":";dwTime
	
	Do
		If SendMessage (ah.htabtool, TCM_GETITEM, i, Cast (LPARAM ,@tci)) Then
			GetLastWriteTime pTABMEM->filename, @ft
			'hFile = CreateFile (pTABMEM->filename, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
			'If hFile <> INVALID_HANDLE_VALUE Then
			'	GetFileTime hFile, NULL, NULL, @ft
			'	CloseHandle hFile
				If CompareFileTime (@ft, @pTABMEM->ft) > 0 Then
					
					This.Stop
					buff = pTABMEM->filename + CR + GetInternalString (IS_FILE_CHANGED_OUTSIDE_EDITOR) + CR + GetInternalString (IS_REOPEN_THE_FILE)
					If MessageBox (ah.hwnd, @buff, @szAppName, MB_YESNO Or MB_ICONEXCLAMATION) = IDYES Then
						ReadTheFile pTABMEM->hedit, pTABMEM->filename             ' Reload file
						SetFileInfo pTABMEM->hedit, pTABMEM->filename
					EndIf
                                        
                    GetLastWriteTime pTABMEM->filename, @pTABMEM->ft 
					'hFile = CreateFile (pTABMEM->filename, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)
					'If hFile <> INVALID_HANDLE_VALUE Then
					'	GetFileTime hFile, NULL, NULL, @ft
					'	CloseHandle hFile
					'EndIf
					'pTABMEM->ft = ft
				    This.Start
				EndIf
			'EndIf
		Else
			Exit Do
		EndIf
		i += 1
	Loop

End Sub 

