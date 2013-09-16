

Type Make
	hThread	As HANDLE
	hrd		As HANDLE
	hwr		As HANDLE
	pInfo	As PROCESS_INFORMATION
	uExit	As Integer
End Type


Enum ProcessError
    CREATE_PROCESS_FAILED = &hFFFF
    CREATE_PIPE_FAILED
End Enum


Declare Sub GetCCL (ByVal ModuleID As Integer, ByVal pCCLName As GOD_EntryName Ptr, ByVal pCCLData As GOD_EntryData Ptr)
Declare Sub GetCCLData (ByVal pCCLName As GOD_EntryName Ptr, ByVal pCCLData As GOD_EntryData Ptr)
Declare Sub GetMakeOption()
Declare Function GetErrLine (Byref ErrMsgLine As zString, ByVal fQuickRun As Boolean) As Integer

Declare Function MakeBuild (Byref sMakeOpt As ZString, ByRef sFile As zString, ByRef CCLName As ZString, ByVal fOnlyThisModule As Boolean,ByVal fNoClear As Boolean,ByVal fQuickRun As Boolean) As Integer
Declare Sub MakeRun (ByRef sFile As ZString)
Declare Sub MakeRunDebug (ByRef sFile As ZString)
Declare Function Compile (Byref sMake As zString) As Integer
Declare Function CompileModules () As Integer

Declare Sub KillQuickRun ()
Declare Function ProcessQuickRun (ByVal Param As ZString Ptr) As Integer


Extern szQuickRun As ZString * MAX_PATH
Extern makeinf    As Make



