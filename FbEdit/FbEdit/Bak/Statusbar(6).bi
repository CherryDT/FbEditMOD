

Type Statusbar

    

    Private:

        Dim   sbParts (1 to ...)      As Integer => { 165, 215, 240, 270, 400, -1 }    ' pixels from left
        Const MaxItems                As Integer       = 50
        Dim   Top                     As Integer       = Any
        Dim   Curr                    As Integer       = Any
        Dim   Items                   As Integer       = Any 
        Dim   LoopMem(1 To MaxItems)  As CARETPOS      = Any 
        
        Declare Function MapIdx   (ByVal Idx As Integer) As Integer         
        
    Public:
        Declare Sub      LabelLockState ()
        Declare Sub      SetBuildName   (ByVal pBuildName As ZString Ptr)

        Declare Constructor

End Type


