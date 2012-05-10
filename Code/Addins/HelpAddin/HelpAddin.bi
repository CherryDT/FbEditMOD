
' FbEdit menu id's
#define IDM_HELPF1							10231
#define IDM_HELPCTRLF1						10232

' RAEdit commands
#define REM_BASE								WM_USER+1000
#define REM_GETWORD							REM_BASE+15		' wParam=BuffSize, lParam=lpBuff

dim SHARED hInstance as HINSTANCE
dim SHARED hooks as ADDINHOOKS
dim SHARED lpHandles as ADDINHANDLES ptr
dim SHARED lpFunctions as ADDINFUNCTIONS ptr
dim SHARED lpData as ADDINDATA ptr

' fb keywords
Dim Shared fbwords As String

