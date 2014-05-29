

Enum FBEFileType
    FBFT_UNKOWN = 0
    FBFT_CODE
    FBFT_RESOURCE
    FBFT_WINHELP
    FBFT_HTMLHELP
    FBFT_PROJECT
End Enum


Declare Function GetFileName (ByVal pFileSpec As ZString Ptr) As ZString Ptr   ' MOD 22.1.2012 String -> Zstring Ptr
Declare Function RemoveFileExt (ByVal pFileSpec As ZString Ptr) As ZString Ptr
'Declare Function GetFileExt (ByVal pFileSpec As ZString Ptr) As ZString Ptr
Declare Sub GetFilePath (ByVal pFileSpec As ZString Ptr)
'Declare Sub FixPath (Byref Path As ZString)
Declare Function GetFileBaseName (ByVal pFileSpec As ZString Ptr) As ZString Ptr
Declare Function GetFBEFileType (ByVal pFileSpec As ZString Ptr) As FBEFileType
Declare Sub BuildDirList (ByVal lpDir As ZString Ptr, ByVal lpSub As ZString Ptr, ByVal nType As Integer)
Declare Sub GetIncludeSpec (ByVal pIncludeSpec As ZString Ptr)
Declare Sub GetLastWriteTime (ByVal pFileSpec As ZString Ptr, ByVal pFileTime As FILETIME Ptr)
Declare Sub CmdLineSubstExeUI (ByRef CmdLine As ZString, ByVal hwndOwner As HWND, ByVal pFilterstring As ZString Ptr)
Declare Sub CmdLineCombinePath (ByRef CmdLine As ZString, ByVal pDefaultPath As ZString Ptr)
Declare Sub WeedOutSpec (ByRef FileSpec As ZString)

Declare Function FileExists (ByVal pSpec As ZString Ptr) As BOOL
Declare Function DirExists (ByVal pSpec As ZString Ptr) As BOOL


Extern DirList      As String
Extern DirListLCase As String



