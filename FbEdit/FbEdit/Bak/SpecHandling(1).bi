

Enum FBEFileType
    FBFT_UNKOWN = 0
    FBFT_CODE   
    FBFT_RESOURCE
    FBFT_WINHELP
    FBFT_HTMLHELP
    FBFT_PROJECT
End Enum


Declare Function GetFileName (ByRef Buff As ZString) As ZString Ptr   ' MOD 22.1.2012 String -> Zstring Ptr
Declare Function RemoveFileExt (Byref sFile As zString) As ZString Ptr
Declare Function GetFileExt (ByRef sFile As ZString) As ZString ptr
Declare Sub GetFilePath (ByRef sFile As ZString)
'Declare Sub FixPath (Byref Path As ZString)
Declare Function GetFileBaseName (ByRef FileSpec As ZString) As ZString Ptr
Declare Function GetFBEFileType (Byref FileSpec As ZString) As FBEFileType
Declare Sub BuildDirList (ByVal lpDir As ZString Ptr,ByVal lpSub As ZString Ptr,ByVal nType As Integer)
Declare Sub GetIncludeSpec (ByVal pIncludeSpec As ZString Ptr)

Declare Function FileExists (ByVal pSpec As ZString Ptr) As BOOL
Declare Function DirExists (ByVal pSpec As ZString Ptr) As BOOL


Extern DirList      As string
Extern DirListLCase As String 



  