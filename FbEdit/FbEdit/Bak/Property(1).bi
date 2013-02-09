

Declare Sub SetPropertyDirty (ByVal hWin As HWND)

Declare Function ParseFile OverLoad (ByVal hEdit As HWND) As Integer
Declare Function ParseFile OverLoad (ByRef sFile As ZString) As Integer


Common Shared PO_Changed    As BOOLEAN      ' Property-Owner
Common Shared POL_Changed   As BOOLEAN      ' Property-Owner-List flag
                                            ' reset by: UpdateProperty
                                            ' set by  : Add/CloseTab, Open/CloseProject, AddTo/RemoveFromProject
