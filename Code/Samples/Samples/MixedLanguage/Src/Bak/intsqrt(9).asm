; #########################################################################
;                    THIS IS MASM32
; #########################################################################

      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

      include <debug.inc>
      includelib <debug.lib>

    .code

; #########################################################################

IntSqrt proc source:DWORD

    LOCAL var:DWORD

    mov eax, 0
    
    .while eax < 5
        inc eax
        PrintDec eax
    .endw



    fild source     ; load source integer
    fsqrt
    fistp var       ; store result in variable
    mov eax, var

    ret

IntSqrt endp

; #########################################################################

end