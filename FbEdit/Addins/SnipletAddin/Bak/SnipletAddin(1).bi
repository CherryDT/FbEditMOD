



dim SHARED hInstance as HINSTANCE
Dim Shared hDialog   As HWND 
Dim Shared FileSpec  As ZString * MAX_PATH  
Dim Shared Path      As ZString * MAX_PATH 

dim SHARED hooks as ADDINHOOKS
dim SHARED lpHandles as ADDINHANDLES ptr
dim SHARED lpFunctions as ADDINFUNCTIONS ptr
dim SHARED lpData as ADDINDATA ptr
dim SHARED IDM_SNIPLETS as integer
dim SHARED winsize as RECT=(10,10,800,600)

#define IDD_DLGSNIPLET			1000
#define IDC_FILEBROWSER			1001
#define IDC_RAEDIT				1002
#Define IDC_BTN_CLIPBOARD       1003
#Define IDC_BTN_EDITOR          1004
#Define IDC_BTN_CANCEL          1005