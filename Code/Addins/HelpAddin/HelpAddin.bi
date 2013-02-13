
' FbEdit menu id's
#Define IDM_HELPF1							10231
#Define IDM_HELPCTRLF1						10232

' RAEdit commands
#Define REM_BASE								WM_USER+1000
#Define REM_GETWORD							REM_BASE+15		' wParam=BuffSize, lParam=lpBuff

Dim Shared hInstance As HINSTANCE
Dim Shared hooks As ADDINHOOKS
Dim Shared lpHandles As ADDINHANDLES Ptr
Dim Shared lpFunctions As ADDINFUNCTIONS Ptr
Dim Shared lpData As ADDINDATA Ptr

' fb keywords
Dim Shared fbwords As String

