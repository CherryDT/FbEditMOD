

Enum GetPrivateProfileMode
    GPP_UnExpanded
    GPP_Expanded
End Enum

Declare Sub SaveToIni (ByVal lpszApp As ZString Ptr,ByVal lpszKey As ZString Ptr,Byref lpszTypes As ZString,ByVal lpDta As Any Ptr,ByVal fProject As Boolean)
Declare Function LoadFromIni (ByVal lpszApp As ZString Ptr,ByVal lpszKey As ZString Ptr,Byref szTypes As zString,ByVal lpDta As Any Ptr,ByVal fProject As Boolean) As Boolean
Declare Sub CheckIniFile ()
Declare Sub IniKeyNotFoundMsg (ByVal pSectionName As ZString Ptr, ByVal pKeyName As ZString Ptr)
Declare Sub GetPrivateProfilePath (ByVal pSectionName As ZString Ptr, ByVal pKeyName As ZString Ptr, ByVal pIniSpec As ZString Ptr, ByVal pPath As ZString Ptr, ByVal Mode As GetPrivateProfileMode)

