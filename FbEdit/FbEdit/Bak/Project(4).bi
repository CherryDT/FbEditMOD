

Enum PathType
    PT_RELATIVE = 0
    PT_ABSOLUTE
End Enum

Enum RecompileMode
    RCM_MANUAL = 0
    RCM_PREBUILD
    RCM_INBUILD
End Enum

Enum IncludeMode
    IM_INCLUDE = 0
    IM_INCLUDEONCE
End Enum


Type PFI
	nGroup			    As Integer
	nPos				As Integer        ' current line (caret) while last save
	nLoad				As Integer        ' Loadtype: 0 = NoLoad, 1 = STD, 2 = TXT, 3 = HEX
	nColl(15)		    As Integer
End Type


#Define MAX_MISS		                    10
#Define IDD_NEWPROJECT		            	5300
#Define IDD_DLGPROJECTOPTION				5500


Declare Function GetProjectFileName (ByVal nInx As Integer, ByVal PathMode As PathType) As ZString Ptr
Declare Sub UpdateProjectFileName(Byref sOldFile As zString,Byref sNewFile As ZString)
Declare Function GetProjectMainResource () As String
Declare Function GetFileImg (ByRef sFileSpec As ZString, ByVal FileID As Integer) As Integer
Declare Function IsProjectFile (Byref sFile As zString) As Integer
Declare Function MakeProjectFileName (Byref FileSpec As Const ZString) As String  
Declare Function RemoveProjectPath (ByRef sFile As ZString) As ZString Ptr     ' MOD 7.1.2012 ByVal -> ByRef
Declare Function CloseProject () As Integer
Declare Function OpenProject () As Integer

Declare Sub AddAProjectFile (Byref sFile As zString, ByVal fModule As Boolean,ByVal fCreate As Boolean)
Declare Sub AddExistingProjectFile()
Declare Sub AddExistingProjectModule()
Declare Sub AddNewProjectModule()
Declare Sub AddNewProjectFile()
Declare Sub RemoveProjectFile (ByVal FileID As Integer, ByVal hTVItem As HTREEITEM, ByVal fDontAsk As BOOLEAN)
Declare Sub SetAsMainFile (ByVal FileID As Integer)
Declare Sub ToggleProjectFile (ByRef OldFileID As Integer, ByVal hTVItem As HTREEITEM)

Declare Sub InsertInclude (ByRef FileSpec As String, ByVal IncMode As IncludeMode)

Declare Sub WriteProjectFileInfo (ByVal hWin As HWND, ByVal nInx As Integer, ByVal fProjectClose As BOOLEAN)
Declare Sub ReadProjectFileInfo (ByVal nInx As Integer, ByVal lpPFI As PFI Ptr)
Declare Sub SetProjectFileInfo (ByVal hWin As HWND,ByVal lpPFI As PFI Ptr)

Declare Sub RefreshProjectTree
Declare Sub SelectTrvItem (Byref sFile As ZString)
Declare Function GetTrvSelItemData (ByRef FileSpec As String, ByRef FileID As Integer, ByRef hTVItem As HTREEITEM, ByVal PathMode As PathType) As BOOLEAN 

Declare Function ProjectProc (ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
Declare Function NewProjectDlgProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer
Declare Function ProjectOptionDlgProc (ByVal hWin As HWND, ByVal uMsg As UINT, ByVal wParam As WPARAM, ByVal lParam As LPARAM) As Integer


Common Shared fProject           As BOOLEAN             ' set by Add/Remove-Projectfile, reset by UpdateProperty
Common Shared ProjectDescription As ZString * 260
Common Shared ProjectApiFiles    As ZString * 260
Common Shared ProjectDeleteFiles As ZString * 260
Common Shared nMain              As Integer
Common Shared nMainRC            As Integer             ' MOD 30.1.2012 ADD
Common Shared fRecompile         As Integer
Common Shared lpOldProjectProc   As WNDPROC 
Common Shared fAddMainFiles      As Boolean
Common Shared fCompileIfNewer    As Boolean
Common Shared fAddModuleFiles As Boolean
Common Shared fIncVersion As Boolean
Common Shared fRunCmd As BOOLEAN

