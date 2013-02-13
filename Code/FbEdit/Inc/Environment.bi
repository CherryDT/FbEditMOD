

#Define IDD_DLG_ENVIRON         1600

#Define IDC_GRD_USERSTRING      1601
#Define IDC_GRD_READONLY        1602
#Define IDC_GRD_USERPATH        1603
#Define IDC_GRD_PATH            1604

#Define IDC_STC_PATH            1607
#Define IDC_STC_USERPATH        1608
#Define IDC_STC_READONLY        1609
#Define IDC_STC_USERSTRING      1610

#Define IDC_BTN_ADD_USERPATH    1611
#Define IDC_BTN_DEL_USERPATH    1612
#Define IDC_BTN_DEL_USERSTRING  1613
#Define IDC_BTN_ADD_USERSTRING  1614

Declare Function EnvironProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
Declare Sub ExpandStrByEnviron (ByRef Source As ZString, ByVal MaxAttempt As Integer = 5)
Declare Sub UpdateEnvironment ()

Type EnvironVarName     As ZString * 64
Type EnvironPathValue   As ZString * MAX_PATH 
Type EnvironStringValue As ZString * 1024
Type EnvironItem        As ZString * SizeOf (EnvironVarName) + SizeOf (EnvironStringValue) + 1

Enum NamedPath
    HELP_PATH = 1
    FBC_PATH
    FBCINC_PATH
    FBCLIB_PATH
    PROJECTS_PATH
End Enum

Const EnvDlgGrdCount As Integer = 4

Dim Shared EnvDlgGrdItems(1 To EnvDlgGrdCount) As Integer => { IDC_GRD_READONLY,   _ 
                                                               IDC_GRD_PATH,       _
                                                               IDC_GRD_USERPATH,   _
                                                               IDC_GRD_USERSTRING  _
                                                             }

Dim Shared EnvDlgStcItems(1 To EnvDlgGrdCount) As Integer => { IDC_STC_READONLY,   _ 
                                                               IDC_STC_PATH,       _
                                                               IDC_STC_USERPATH,   _
                                                               IDC_STC_USERSTRING  _
                                                             }

Dim Shared EnvDlgAddItems(1 To EnvDlgGrdCount) As Integer => { NULL,                  _ 
                                                               NULL,                  _
                                                               IDC_BTN_ADD_USERPATH,  _
                                                               IDC_BTN_ADD_USERSTRING _
                                                             }

Dim Shared EnvDlgDelItems(1 To EnvDlgGrdCount) As Integer => { NULL,                  _ 
                                                               NULL,                  _
                                                               IDC_BTN_DEL_USERPATH,  _
                                                               IDC_BTN_DEL_USERSTRING _
                                                             }

Dim Shared EnvPaths(1 To ...) As EnvironVarName => { "HELP_PATH",     _
                                                     "FBC_PATH",      _
                                                     "FBCINC_PATH",   _
                                                     "FBCLIB_PATH",   _
                                                     "PROJECTS_PATH"  _
                                                   }

