

' module compile with: -gen gas

' while incompatibilities towards -gen gcc disappears
' move procedures to ZStringHandling.bas    

    
    
    #Include Once "windows.bi"



Sub ZStrCat Cdecl (ByVal pTarget As ZString Ptr, ByVal TargetSize As Integer, ...)

    Dim n        As Integer        = Any
    Dim i        As Integer        = Any
    Dim pArg     As UByte Ptr Ptr  = Any 
    Dim pZString As UByte Ptr      = Any 
 
    
    pArg = va_first ()
    n = lstrlen (pTarget)
  
    Do
        pZString = *pArg
    
        If pZString Then
            i = 0
            Do
                If n = TargetSize Then
                    pTarget[n] = 0
                    Exit Do, Do 
                EndIf
                
                Select Case pZString[i]
                Case 0
                    pTarget[n] = 0
                    Exit Do 
                Case Else    
                    pTarget[n] = pZString[i]
                    n += 1
                    i += 1
                End Select 
            Loop
        Else
            Exit Do
        EndIf
        
        pArg = va_next (pArg, UByte Ptr)     ' destination type = UByte Ptr
    Loop 
    
End Sub     
