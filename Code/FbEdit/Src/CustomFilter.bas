    
    
    #Include Once "windows.bi" 
    #Include Once "win\richedit.bi" 
    
    #Include Once "Inc\Addins.bi"
    #Include Once "Inc\CoTxEd.bi"
    #Include Once "Inc\FbEdit.bi"
    #Include Once "Inc\FileIO.bi"
    #Include Once "Inc\GUIHandling.bi"
    #Include Once "Inc\IniFile.bi"
    #Include Once "Inc\Misc.bi"
    #Include Once "Inc\ZStringHandling.bi"
    
    #Include Once "Inc\CustomFilter.bi"
    #Include Once "showvars.bi"
    
    
    Declare Sub CustomFilterReplace (ByRef hEditor As HWND)     
    
    Declare Function CustomFilterDlgProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParm As WPARAM, ByVal lParm As LPARAM) As Integer
    
    
    Dim Shared CF_hDlg         As HANDLE
    Dim Shared CF_ProcInfo     As PROCESS_INFORMATION
    Dim Shared CF_hThread      As Any Ptr 
    Dim Shared CF_Spec         As ZString * MAX_PATH 
        
    Const      CF_TERMINATED As UINT = 256                            ' reserved ExitCode: process terminated 
    
    
Function CustomFilterDlgProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParm As WPARAM, ByVal lParm As LPARAM) As Integer

	Dim    DlgRect     As RECT        = Any
    Dim    Success     As BOOL        = Any 
    Dim    i           As Integer     = Any 
    
	Select Case uMsg
	Case WM_INITDIALOG
        GetWindowRect hWin, @DlgRect                                  ' startup position for non existing ini file entry
        LoadFromIni "Win", @"CFDlgPos", "4444", @DlgRect, FALSE
        With DlgRect
            SetWindowPos hWin, HWND_TOP, .Left, .Top, 0, 0, SWP_HIDEWINDOW Or SWP_NOSIZE             ' dialog not sizeable
        End With
        CF_hDlg = hWin
        CF_ProcInfo.hProcess = 0
        CF_ProcInfo.hThread = 0
        CheckDlgButton hWin, IDC_CHK_WAITFOREXIT, BST_CHECKED
        CF_hThread = CreateThread (NULL, 0, Cast (LPTHREAD_START_ROUTINE, @CustomFilterReplace), @ah.hred, 0, NULL)
        Return TRUE
	
	Case WM_DESTROY
        CloseHandle CF_ProcInfo.hProcess
        CloseHandle CF_ProcInfo.hThread
        CloseHandle CF_hThread
        CF_hThread = 0
        CF_hDlg = 0
        SetZStrEmpty (CF_Spec)
        Return FALSE
        
	Case WM_CLOSE
        GetWindowRect hWin, @DlgRect
        SaveToIni @"Win", @"CFDlgPos", "4444", @DlgRect, FALSE
        EndDialog hWin, 0
		Return TRUE 

    Case WM_COMMAND
        Select Case LoWord (wParm)
        Case IDD_BTN_ABORT
            If CF_ProcInfo.hProcess = 0 Then
                TextToOutput "*** custom filter: process not running ***"
                SendMessage hWin, WM_CLOSE, 0, 0
                Return 0
            EndIf
                
            Success = TerminateProcess (CF_ProcInfo.hProcess, CF_TERMINATED)
            If Success = FALSE Then
                TextToOutput OTT_WINLASTERROR                    
                SendMessage hWin, WM_CLOSE, 0, 0
                Return 0
            EndIf
            
            EnableDlgItem (hWin, IDD_BTN_ABORT, FALSE)                   ' allow only one hit
            Return 0
        End Select 
	
	Case Else
		Return FALSE
	
	End Select

End Function


Sub CustomFilterStartUp (ByVal pFilterSpec As ZString Ptr)
    
    CF_Spec = ad.AppPath + $"\CustomFilter\" + *pFilterSpec 
    DialogBox (hInstance, MAKEINTRESOURCE (IDD_DLG_CUSTOMFILTER), ah.hwnd, @CustomFilterDlgProc)
    
End Sub
    
     
Sub CustomFilterReplace (ByRef hEditor As HWND)     

    Const MemChunkSize    As ULong   = 32 * 1024
    
    Dim MemSize           As ULong   = Any
    Dim SeekPos           As ULong   = Any
    Dim BytesDone         As DWORD   = Any 

    Dim hMem              As HGLOBAL = Any
    Dim hMem2             As HGLOBAL = Any
    Dim i                 As Integer = Any 
    Dim n                 As Integer = Any  
    Dim Success           As BOOL    = Any
    Dim ExitCode          As DWORD   = Any 
      
    Dim hReadChildStdIn   As HANDLE  = Any            ' end of pipe: filter
    Dim hWriteChildStdOut As HANDLE  = Any            ' end of pipe: filter
    Dim hWriteChildStdIn  As HANDLE  = Any            ' end of pipe: fbedit
    Dim hReadChildStdOut  As HANDLE  = Any            ' end of pipe: fbedit           
    
    Dim SecAttrib         As SECURITY_ATTRIBUTES 
    Dim StartInfo         As STARTUPINFO
       

    If EditInfo.CoTxEd = FALSE Then
        SendMessage CF_hDlg, WM_CLOSE, 0, 0
        Exit Sub
    EndIf
    
    With SecAttrib
        .nLength              = SizeOf (SECURITY_ATTRIBUTES)                            ' Set the bInheritHandle flag so pipe handles are inherited. 
        .bInheritHandle       = TRUE
        .lpSecurityDescriptor = NULL 
    End With
    
    ' Create a pipe for the child process's STDOUT.
    If CreatePipe (@hReadChildStdOut, @hWriteChildStdOut, @SecAttrib, 0) = FALSE Then    
        TextToOutput "CustomFilter: stdout pipe creation failed" 
    EndIf 

    SetHandleInformation hReadChildStdOut, HANDLE_FLAG_INHERIT, 0                       ' Ensure that the read handle to the child process's pipe for STDOUT is not inherited.
 
    If CreatePipe (@hReadChildStdIn, @hWriteChildStdIn, @SecAttrib, 0) = FALSE Then     ' Create a pipe for the child process's STDIN. 
        TextToOutput "CustomFilter: stdin pipe creation failed"
    EndIf      

    SetHandleInformation hWriteChildStdIn, HANDLE_FLAG_INHERIT, 0                       ' Ensure that the write handle to the child process's pipe for STDIN is not inherited. 

   
    ' *** create the child process
    With StartInfo
        .cb         = SizeOf (STARTUPINFO) 
        .hStdError  = hWriteChildStdOut
        .hStdOutput = hWriteChildStdOut
        .hStdInput  = hReadChildStdIn
        .dwFlags    = STARTF_USESTDHANDLES
    End With 
    
    TextToOutput !"EXECUTE: \"" + CF_Spec + !"\""
    Success = CreateProcess (NULL, @CF_Spec, NULL, NULL, TRUE, 0, NULL, NULL, @StartInfo, @CF_ProcInfo)
   
    If Success = FALSE Then 
        TextToOutput "custom filter: CreateProcess failed"
        CloseHandle hReadChildStdOut
        CloseHandle hWriteChildStdOut
        CloseHandle hReadChildStdIn
        CloseHandle hWriteChildStdIn
        SendMessage CF_hDlg, WM_CLOSE, 0, 0
        Exit Sub
    EndIf

    SendDlgItemMessage (CF_hDlg, IDC_STC_CFNAME, WM_SETTEXT, 0, Cast (LPARAM, PathFindFileName (CF_Spec)))
    
    CloseHandle hWriteChildStdOut                               ' close unused end of pipe
    CloseHandle hReadChildStdIn                                 

    
    ' *** write to pipe    (child's STD IN)
    hMem = GetFileMemSelected (hEditor)        
    If hMem Then
        i = 0
        Do
            Select Case Cast(UByte Ptr, hMem)[i]
            Case 0
                Exit Do
            Case 13                                             ' write to pipe that is the standard input for a child process
                Success = WriteFile (hWriteChildStdIn, @!"\13\10", 2, @BytesDone, NULL)   
                If Success = FALSE Then Exit Do 
                i += 1
            Case Else
                Success = WriteFile (hWriteChildStdIn, hMem + i, 1, @BytesDone, NULL)
                If Success = FALSE Then Exit Do
                i += 1
            End Select
        Loop
        GlobalFree hMem
    EndIf     
    CloseHandle hWriteChildStdIn                                ' close pipe handle, so child process stops reading  
    
    
    ' *** read from pipe    (child's STD OUT) 
    hMem = GlobalAllocUI (GMEM_FIXED, MemChunkSize)
    
    If hMem Then
        MemSize = GlobalSize (hMem) - 1                         ' reserve 1 byte for terminating NULL
        SeekPos = 0
        Do                                                      ' read output from the child process, and write to parent's STDOUT
            If SeekPos >= MemSize Then                          ' expand mem
                hMem2 = GlobalReAlloc (hMem, MemSize + MemChunkSize, GMEM_MOVEABLE)    ' mem is still GMEM_FIXED! (GMEM_MOVEABLE has different meanings to GobalAlloc vs GlobalReAlloc)
                If hMem2 Then
                    hMem = hMem2
                    MemSize = GlobalSize (hMem) - 1             ' reserve 1 byte for terminating NULL
                Else
                    TextToOutput "custom filter: GlobalReAlloc failed"
                    TextToOutput OTT_WINLASTERROR
                    SeekPos = 0                                 ' discard everything 
                    Exit Do    
                EndIf
            EndIf
            

            Success = ReadFile (hReadChildStdOut, hMem + SeekPos, MemSize - SeekPos, @BytesDone, NULL)
            If Success = FALSE Then
                If GetLastError = ERROR_BROKEN_PIPE Then
                                                                ' thats ok, sender stops writing
                Else 
                    TextToOutput "custom filter: error reading pipe"
                    TextToOutput OTT_WINLASTERROR    
                    SeekPos = 0                                 ' discard everything
                EndIf
                Exit Do           
            EndIf
            SeekPos += BytesDone
        Loop While BytesDone
        CloseHandle hReadChildStdOut

        Cast (ZString Ptr, hMem)[SeekPos] = 0                   ' append terminating NULL

        
        ' *** translate buffer: CRLF -> CR, CRCRLF -> CR   
        i = 0
        n = 0
        Do
            Select Case Cast(UByte Ptr, hMem)[i]
            Case 13
                i += 1                                          ' skip
            Case 10
                Cast(UByte Ptr, hMem)[n] = 13
                i += 1
                n += 1
            Case 0
                Cast(UByte Ptr, hMem)[n] = 0
                Exit Do
            Case Else
                Cast(UByte Ptr, hMem)[n] = Cast(UByte Ptr, hMem)[i]
                i += 1
                n += 1
            End Select
        Loop

        
        ' *** finish job    
        SendMessage hEditor, EM_REPLACESEL, TRUE, Cast (LPARAM, hMem)
        GlobalFree hMem
    Else
        TextToOutput "custom filter: GlobalAlloc input buffer failed"
        CloseHandle hReadChildStdOut
    EndIf


    ' *** exit process custom filter   
    Do     
        If SendDlgItemMessage (CF_hDlg, IDC_CHK_WAITFOREXIT, BM_GETCHECK, 0, 0) = BST_UNCHECKED Then   
            TextToOutput "custom filter: waiting for exitcode cancelled"
            Exit Do 
        EndIf

        Success = GetExitCodeProcess (CF_ProcInfo.hProcess, @ExitCode)
        If Success = FALSE Then
            TextToOutput OTT_WINLASTERROR
            Exit Do  
        EndIf                            
                                
        If ExitCode = STILL_ACTIVE Then
            Sleep 0.2
        Else
            TextToOutput "custom filter: exitcode: " + Str (ExitCode)
            Exit Do  
        EndIf
    Loop 
    SendMessage CF_hDlg, WM_CLOSE, 0, 0

    
End Sub

