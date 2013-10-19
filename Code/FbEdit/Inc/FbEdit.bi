

#LibPath "..\FbEditDLL\Build"
#Inclib  "FbEdit"
Declare Function GetCharTabPtr StdCall Alias "GetCharTabPtr" () As Any Ptr
	' other publics
	'SetHiliteWords proc public uses esi edi,nColor:DWORD,lpWords:DWORD
	'GetCharTabVal proc public nChar:DWORD
	'SetCharTabVal proc public nChar:DWORD,nValue:DWORD
	'SetBlockDef proc public uses ebx esi edi,lpRABLOCKDEF:DWORD



Const szNULL     As String = !"\0"
Const CRLF       As String = Chr (13, 10)
Const CR         As String = Chr (13)
Const WHITESPACE As String = Chr (32, 9)
Const QUOTE      As String = Chr (34)
Const COLON      As String = ":"


' Filter string for GetOpenFileName
Const ALLFilterString = "Code Files (*.bas, *.bi, *.rc)"        + szNULL + "*.bas;*.bi;*.rc"         + szNULL + _
                        "Text Files (*.txt)"                    + szNULL + "*.txt"                   + szNULL + _
                        "Project Files (*.fbp)"                 + szNULL + "*.fbp"                   + szNULL + _
                        "All Files (*.*)"                       + szNULL + "*.*"                     + szNULL
Const MODFilterString = "Code File (*.bas)"                     + szNULL + "*.bas"                   + szNULL
Const DLLFilterString = "Custom Controls (*.dll)"               + szNULL + "*.dll"                   + szNULL
Const PRJFilterString = "Project Files (*.fbp)"                 + szNULL + "*.fbp"                   + szNULL + _
                        "All Files (*.*)"                       + szNULL + "*.*"                     + szNULL
Const EXEFilterString = "Commands (*.com, *.exe, *.cmd, *.bat)" + szNULL + "*.com;*.exe;*.cmd;*.bat" + szNULL + _
                        "All Files (*.*)"                       + szNULL + "*.*"                     + szNULL
Const HLPFilterString = "Help Files (*.hlp, *.chm)"             + szNULL + "*.hlp;*.chm"             + szNULL + _
                        "All Files (*.*)"                       + szNULL + "*.*"                     + szNULL
Const TPLFilterString = "Template Files (*.tpl)"                + szNULL + "*.tpl"                   + szNULL


Common Shared hInstance           As HINSTANCE
Common Shared hIcon               As HICON
                                  
' Misc                            
Common Shared nLastLine           As Integer
Common Shared nLastSize           As Integer
Common Shared nCaretPos           As Integer
Common Shared buff                As ZString * 20 * 1024
Common Shared s                   As ZString * 20 * 1024
Common Shared CommandLine         As ZString Ptr
Common Shared ApiFiles            As ZString * 260
Common Shared DefApiFiles         As ZString * 260

Common Shared fTimer              As Integer
'Common Shared fChangeNotification As Integer
 
Common Shared nHideOut            As Integer
Common Shared fInUse              As BOOLEAN 

' Modeless dialogs
Common Shared findvisible         As HWND
Common Shared gotovisible         As HWND
                                  
Common Shared wpos                As WINPOS
                                  
Common Shared szLastDir           As ZString * MAX_PATH

#Include Once "Inc\LineQueue.bi"
Extern CH                         As CaretHistory

