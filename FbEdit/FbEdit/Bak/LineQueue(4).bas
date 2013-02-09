

#Include Once "Inc\LineQueue.bi"
#Include Once "win\richedit.bi"
#Include Once "Inc\Addins.bi"
#Include Once "Inc\TabTool.bi"


Dim Shared CH As CaretHistory


Function CaretHistory.MapIdx (ByVal Idx As Integer) As Integer
     
    Return ((Idx - 1) Mod MaxItems) + 1                  ' clamping
    
End Function

Sub CaretHistory.Enqueue (ByVal hWin As HWND, ByVal cpMin As Integer)
    
    Dim IsDifferent As BOOL = Any 
    
    With LoopMem(MapIdx (Curr))
        IsDifferent = .hwnd <> hWin OrElse .cp <> cpMin
    End With 
    
    If IsDifferent Then
        Curr += 1        
        LoopMem(MapIdx (Curr)) = Type<CARETPOS>(cpMin, hWin)
        
        If Curr = Top + Items  Then
            If Items < MaxItems Then
                Items += 1
            Else
                Top += 1
            EndIf
        Else
            Items = Curr - Top + 1
        EndIf
    EndIf
    
End Sub

Sub CaretHistory.GoForward ()
    
    If Curr < Top + Items - 1 Then
        Curr += 1
        GoCurrent    
    Else
        'TextToOutput "*** end of caret queue ***", &hFFFFFFFF
        MessageBeep &hFFFFFFFF
    EndIf

End Sub

Sub CaretHistory.GoBackward ()
    
    Dim IsDifferent As BOOL      = Any 
    Dim chrg        As CHARRANGE = Any 
    
    With LoopMem(MapIdx (Curr))
        IsDifferent = TRUE 
        If .hwnd = ah.hred Then
            If ah.hred Andalso ah.hred <> ah.hres Then
            	SendMessage ah.hred, EM_EXGETSEL, 0, Cast (LPARAM, @chrg)
                If .cp = chrg.cpMin Then IsDifferent = FALSE 
            EndIf
        EndIf
    End With

    If IsDifferent Then
        GoCurrent
    Else
        If Curr > Top Then 
            Curr -= 1
            GoCurrent    
        Else
            'TextToOutput "*** top of caret queue ***", &hFFFFFFFF
            MessageBeep &hFFFFFFFF
        EndIf
    EndIf
    
End Sub

Constructor CaretHistory
    
    Curr   = 0
    Top    = 1
    Items  = 0

End Constructor

Sub CaretHistory.GoCurrent ()
    
    With LoopMem(MapIdx (Curr))
        If      IsWindow (.hwnd) _
    	AndAlso GetWindowLong (.hwnd, GWL_ID) = IDC_CODEED Then
    		SelectTabByWindow .hwnd    
    		SendMessage ah.hred, EM_EXSETSEL, 0, Cast (LPARAM, @Type<CHARRANGE>(.cp, .cp))
            SendMessage ah.hred, REM_VCENTER, 0, 0
    		SendMessage ah.hred, EM_SCROLLCARET, 0, 0
    		SetFocus ah.hred
        EndIf
    End With
    
End Sub

Sub CaretHistory.Shift (ByVal hWin As HWND, ByVal Position As Integer, ByVal Offset As Integer)
    
    Dim i As Integer = Any     		
	
	For i = 1 To MaxItems
		With LoopMem(i)
    		If .hwnd = hWin Then
    			If Position <= .cp Then
    				.cp += Offset
    			EndIf
    		EndIf
	    End With 
	Next

End Sub

'Sub CaretPosBackward
'    
'    If fdcpos Then
'		fdcpos=fdcpos-1
'	Else
'		fdcpos=31
'	EndIf
'    
'    DebugPrint (fdcpos)
'    
'    With fdc(fdcpos)
'        If      IsWindow (.hwnd) _
'    	AndAlso GetWindowLong (.hwnd, GWL_ID) = IDC_CODEED Then
'    		SelectTabByWindow .hwnd    
'    		SendMessage ah.hred, EM_EXSETSEL, 0, Cast (LPARAM, @Type<CHARRANGE>(.npos, .npos))
'    		SendMessage(ah.hred,EM_SCROLLCARET,0,0)
'    		SetFocus(ah.hred)
'        EndIf
'    End With
'
'End Sub 

'Sub CaretPosEnqueue (ByVal hWin As HWND, ByVal cpMin As Integer)
'
'    DebugPrint (fdcpos)
'    
'    If     hWin <> fdc(fdcpos).hwnd _
'    OrElse cpMin <> fdc(fdcpos).npos Then 
'        fdcpos=(fdcpos+1) And 31
'    	fdc(fdcpos).npos = cpMin
'    	fdc(fdcpos).hwnd = hWin
'    EndIf
'    
'End Sub


 
