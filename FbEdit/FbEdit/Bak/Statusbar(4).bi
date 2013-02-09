

Type Statusbar

    

    Private:
        Const MaxPart                 As Integer       = 6
        Dim   sbParts (1 to MaxPart)  As Integer       => { 165, 215, 240, 270, 400, -1 }    ' pixels from left

        
    Public:
        Declare Sub      Init ()    
        Declare Sub      LabelLockState ()
        Declare Sub      SetBuildName   (ByVal pBuildName As ZString Ptr)

End Type


