

Type CARETPOS
	cp   		As Integer
    HWND		As HWND
End Type


Type CaretHistory

    Private:

        Const MaxItems                As Integer     = 50
        Dim   Top                     As Integer     = Any
        Dim   Curr                    As Integer     = Any
        Dim   Items                   As Integer     = Any 
        Dim   LoopMem(1 To MaxItems)  As CARETPOS    = Any 
        
        Declare Function MapIdx   (ByVal Idx As Integer) As Integer         
        
    Public:
        Declare Sub      GoBackward ()
        Declare Sub      GoForward  ()
        Declare Sub      GoCurrent  ()
        Declare Sub      Enqueue  (ByVal hWin As HWND, ByVal cp As Integer)           ' append after current
        Declare Sub      Requeue  (ByVal hWin As HWND, ByVal cp As Integer)           ' overwrite current
        Declare Sub      Shift    (ByVal hWin As HWND, ByVal Position As Integer, ByVal Offset As Integer)

        Declare Constructor

End Type

Extern CH As CaretHistory
