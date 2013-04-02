
    #Include Once "windows.bi"
    #Include Once "win\richedit.bi"
    #Include Once "..\..\..\Code\FbEdit\Inc\Resource.bi"
    
    Declare Function EnumFBEWndProc (ByVal hWindow As HWND, ByVal lParm as LPARAM) As BOOL

    Static Shared hOutpWnd As HWND
    
    
    
Sub DebugPrint Cdecl Alias "DebugPrint" (ByVal pText As ZString Ptr)

    Dim hMainWnd As HWND = Any    
    
    If hOutpWnd = NULL Then
        hMainWnd = FindWindow (@szMainWindowClassName, NULL)
        EnumChildWindows hMainWnd, @EnumFBEWndProc, NULL
    EndIf
    
    If hOutpWnd Then
        'SendMessage hOutpWnd, EM_EXSETSEL, 0, Cast (LPARAM, @Type<CHARRANGE>(-1, -1))
    	
    	SendMessage hOutpWnd, EM_REPLACESEL, FALSE, Cast (LPARAM, pText)       ' append
    	SendMessage hOutpWnd, EM_REPLACESEL, FALSE, Cast (LPARAM, @!"\13")
    EndIf 
     
End Sub
    
    
    
Function EnumFBEWndProc (ByVal hWindow As HWND, ByVal lParm as LPARAM) As BOOL
    
    Dim ID As Long = Any 
    
    If hWindow Then
        ID = GetWindowLong (hWindow, GWL_ID)
        If ID = IDC_OUTPUT Then
            hOutpWnd = hWindow
            Return FALSE 
        EndIf
    EndIf

    Return TRUE 
End Function 