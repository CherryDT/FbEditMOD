

Declare Sub SetPropertyDirty (ByVal hWin As HWND)


Common Shared PO_Changed    As BOOLEAN      ' Property-Owner
Common Shared POL_Changed   As BOOLEAN      ' Property-Owner-List flag
                                            ' reset by: UpdateProperty
                                            ' set by  : Add/CloseTab, Open/CloseProject, AddTo/RemoveFromProject
