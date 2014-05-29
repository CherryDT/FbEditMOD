

Enum GetPrivateProfileSpecMode       ' (bitmasked value)
    GPP_UnTouched = 0                ' no expansion / existence not checked
    GPP_Expanded  = 1                ' environment expansion will be done
    GPP_MustExist = ( 1 Shl 1)       ' if Spec doesnt exist, empty String is returned
End Enum

Declare Sub SaveToIni (ByVal pSection As ZString Ptr, ByVal pKey As ZString Ptr, ByRef Types As ZString, ByVal pStruct As Any Ptr, ByVal fProject As Boolean)
Declare Function LoadFromIni (ByVal lpszApp As ZString Ptr,ByVal lpszKey As ZString Ptr,Byref szTypes As zString,ByVal lpDta As Any Ptr,ByVal fProject As Boolean) As Boolean
Declare Sub CheckIniFile ()
Declare Sub IniKeyNotFoundMsg (ByVal pSectionName As ZString Ptr, ByVal pKeyName As ZString Ptr)
Declare Sub GetPrivateProfilePath (ByVal pSectionName As ZString Ptr, ByVal pKeyName As ZString Ptr, ByVal pIniSpec As ZString Ptr, ByVal pPath As ZString Ptr, ByVal Mode As GetPrivateProfileSpecMode)
Declare Sub GetPrivateProfileSpec (ByVal pSectionName As ZString Ptr, ByVal pKeyName As ZString Ptr, ByVal pIniSpec As ZString Ptr, ByVal pSpec As ZString Ptr, ByVal Mode As GetPrivateProfileSpecMode)

