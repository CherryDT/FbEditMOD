

#Include Once "windowsUR.bi"


Declare Sub GetItems (ByVal ntype As Integer)
Declare Function FindExact (ByVal lpTypes As ZString Ptr,ByVal lpFind As ZString Ptr,ByVal fMatchCase As Boolean) As ZString Ptr
Declare Sub MoveList ()
Declare Sub HideCCLists ()

Declare Function UpdateEnumList (ByVal lpszEnum As ZString Ptr) As Boolean
Declare Function UpdateConstList (ByVal lpszApi As ZString Ptr,ByVal npos As Integer) As Integer
Declare Sub UpdateTypeList ()
Declare Sub UpdateStructList (ByVal lpProc As ZString Ptr)
Declare Sub UpdateIncludeList ()
Declare Sub UpdateInclibList ()
Declare Sub UpdateList (ByVal lpProc As ZString Ptr)
Declare Sub IsStructList ()


Common Shared ftypelist     As Boolean
Common Shared fconstlist    As Boolean
Common Shared fstructlist   As Boolean
Common Shared fmessagelist  As Boolean
Common Shared flocallist    As Boolean
Common Shared fincludelist  As Boolean
Common Shared fincliblist   As Boolean
Common Shared fenumlist     As Boolean
Common Shared sEditFileName As ZString * MAX_PATH 
Common Shared ccpos         As ZString Ptr
Common Shared ccstring      As ZString * 65536

