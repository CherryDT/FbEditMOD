

Enum SaveAllMode
    SAM_ALLFILES = 0
    SAM_NONPROJECTFILES
    SAM_PROJECTFILES
    SAM_ALLFILES_BUT_CURRENT
End Enum

Enum AddTabMode
    ATM_FOREGROUND
    ATM_BACKGROUND
End Enum

Enum CloseTabMode
    CTM_STD = 0
    CTM_IGNORE_DIRTY = 1             'ignores modify state
    CTM_PROJECTCLOSE = 1 Shl 1       'preserve open state on closing project files
End Enum


Declare Sub SaveProjectTabOrder ()
Declare Sub AddTab (ByVal hEdt As HWND, ByRef lpFileName As ZString, ByVal AddMode As AddTabMode)        'MOD2.2.2012    AddTab(ByVal hEdt As HWND,ByVal lpFileName As String,ByVal fHex As Boolean)
Declare Sub NextTab (ByVal fPrev As Boolean)
Declare Function ShowTab (ByRef FileSpec As ZString) As BOOLEAN
Declare Function CloseTab (ByVal TabID As Integer, ByVal Mode As CloseTabMode = CTM_STD) As Integer   ' MOD 1.2.2012   DelTab(ByVal hWin As HWND)
Declare Function CloseAllProjectTabs () As BOOL
Declare Function CloseAllTabsButCurrent () As BOOL
Declare Function CloseAllNonProjectTabs () As BOOL 
Declare Function CloseAllTabs () As BOOL
Declare Sub UpdateTab ()
Declare Sub UpdateAllTabs (ByVal nType As Integer)
Declare Sub UpdateTabImageByFileID (ByVal FileID As Integer)
Declare Sub UpdateTabImageByTabID (ByVal TabID As Integer)
Declare Sub SwitchTab ()
Declare Sub Tab2Project ()
Declare Sub SetTabLock (ByVal TabID As Integer, ByVal NewState As BOOL)
Declare Function GetTabLock (ByVal TabId As Integer) As BOOL 
Declare Sub UnlockAllTabs ()

Declare Sub SetFileIDByTabID (ByVal TabID As Integer, ByVal NewFileID As Integer)
Declare Function SaveAllTabs () As Integer                            ' MOD 2.1.2012   (ByVal hWin As HWND)
Declare Function SaveTabAs() As BOOLEAN                               ' MOD 1.2.2012    SaveFileAs(ByVal hWin As HWND) As Boolean
Declare Function SaveSelectionDlgProc (ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer

Declare Function CountCodeEdTabs () As Integer
Declare Sub OpenTheFile (Byref FileSpec As ZString, ByVal OpenMode As FileOpenMode)
Declare Sub OpenAFile (ByVal OpenMode As FileOpenMode)                ' MOD 1.2.2012 OpenAFile(ByVal hWin As HWND,ByVal fHex As Boolean)
Declare Sub OpenAProject ()                                           ' MOD 1.2.2012    OpenAProject(ByVal hWin As HWND) As Boolean

Declare Function CreateCodeEd (Byref sFile As zString) As HWND

Declare Function GetTabIDByFileID (ByVal FileID As Integer)	As Integer
Declare Function GetTabIDByEditWindow (ByVal hEditor As HWND) As Integer  
Declare Function GetFileIDByEditor (ByVal hWin As HWND) As Integer
Declare Function GetFileIDByCurrTab () As Integer
Declare Function GetEditWindowBySpec (Byref fn As ZString) As HWND          ' MOD 1.2.2012   (ByVal hWin As HWND,ByVal fn As String,ByVal fShow As Boolean) As HWND
Declare Function GetEditWindowByFileID (ByVal FileID As Integer) As HWND 
Declare Function GetEditWindowByTabID (ByVal TabID As Integer) As HWND 
Declare Function GetEditWindowByFocus () As HWND 
Declare Function GetModifyFlag (ByVal hEdit As HWND) As BOOL

Declare Sub SelectTabByWindow (ByVal hEdit As HWND)
Declare Sub SelectTabByTabID (ByVal TabID As Integer)
Declare Sub SelectTabByFileID (ByVal nInx As Integer)

Declare Function TabToolProc(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer


#Define IDD_DLGSAVESELECTION		5000
#Define pTABMEM                     Cast(TABMEM Ptr, tci.lParam) 


Extern lpOldTabToolProc        As WNDPROC
Extern curtab                  As Integer
Extern prevtab                 As Integer


Const INVALID_TABID            As Integer = -1 


