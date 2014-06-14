#define IDD_DLGLNG              30000
#define IDC_EDTLNGFILE          30001
#define IDC_BTNFILE             30002
#define IDC_BTNLNGSAVE          30003
#define IDC_BTNLNGNEW           30004
#define IDC_EDTLNGLANG          30005
#Define IDC_LSTLNGDIALOG        30006

#Define IDD_DLGMENU				  30100
#Define IDD_DLGTEST				  30200

Dim Shared hInstance As HINSTANCE
Dim Shared hWnd As HWND
Dim Shared hEdt As HWND
Const szDivider As String=!";--------------------------------------------------------------------------\13\10"
Const szAppName As String="Language translator"
' Custom controls used by FbEdit
Dim hRichEditDll As HMODULE
Dim hFbEditDll As HMODULE
Const szFbEditLNGIni As String="FbEditLNG.ini"
Dim Shared szAppPath As ZString*260
Const szNULL=!"\0"
Const LNGFilterString="Language Projects (*.lng)" & szNULL & "*.lng" & szNULL & szNULL
Dim Shared szFileName As ZString*260
Const szNew As String=!"[Lang]\13\10Lang=English (default), By FbEdit team\13\10"
Const szList As String=!"[1100] Goto Line\0" _
							  !"[1200] Language\0" _
							  !"[1600] Environment\0" _
							  !"[1700] Custom Filter\0" _
							  !"[2000] Options\0" _
							  !"[2100] Dialog Options Page#1\0" _
							  !"[2300] Dialog Options Page#2\0" _
							  !"[2200] Dialog Options Page#3\0" _
							  !"[2400] Dialog Options Page#4\0" _
							  !"[2410] Dialog Options Page#5\0" _
							  !"[2500] Find ...\0" _
							  !"[3000] About dialog\0" _
							  !"[3200] Menu Options\0" _
							  !"[4000] Code Editor Options\0" _
							  !"[5000] Save Files\0" _
							  !"[5100] Debug / Quick Run Option\0" _
							  !"[5200] Block Insert\0" _
							  !"[5300] New Project\0" _
							  !"[5360] New Project Options tab\0" _
							  !"[5380] New Project Template tab\0" _
							  !"[5500] Project Options\0" _
							  !"[5600] Export properties to output\0" _
							  !"[6000] Create Template\0" _
							  !"[6100] Addin Manager\0" _
							  !"[6200] Project Api files\0" _
							  !"[6300] Hex Find ...\0" _
							  !"[6500] Clipboard History\0" _
							  !"[10000] Main menu\0" _
							  !"[20000] Context menu\0" _
							  !"\0"
'							  !"[99999] Toolbars\0" _
