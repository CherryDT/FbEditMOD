; #########################################################################
;                    THIS IS MASM32
; #########################################################################

    .386
    .model flat, stdcall  ; 32 bit memory model
    option casemap :none  ; case sensitive

    include .\Redist\VKDebug\VKDebug.inc        ; needed only for debugging

    .code

; #########################################################################

IntSqrt proc source:DWORD

    LOCAL var:DWORD

    mov eax, 0
    
    .while eax < 5
        inc eax
        PrintDec eax                            ; debug output to FbEdit's output window
    .endw                                       ; for details see -> .\Redist\VKDebug\VKDebug.chm
	
	PrintLine
    PrintHex eax
    PrintText "end of debugout"
    
    fild source     ; load source integer
    fsqrt
    fistp var       ; store result in variable
   
    mov eax, var
    
    ret

IntSqrt endp

; #########################################################################

end