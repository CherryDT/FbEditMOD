;-----------------------------------------------------------------------------
;FPUDump function is written by NaN.
;-----------------------------------------------------------------------------

.386
.model flat, stdcall
option casemap: none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\masm32.inc
include debug.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\masm32.lib

DebugProc       proto :dword
FPUDump         proto

.data?
dbbuf           byte 128 dup (?)
dbbuf1          byte 32  dup (?)         ; New buffer for building String Messages, used WITH dbbuf together

.data
szFPU1          byte "Conditional: ST > Source",0               ; Floading point messages to be displayed
szFPU2          byte "Conditional: ST < Source",0
szFPU3          byte "Conditional: ST = Source",0
szFPU4          byte "Conditional: Undefined",0
szFPU5          byte "FPU Levels : %d ",0
szFPU6          byte "Exception  : e s p u o z d i",0           ; Exception bits
szFPU7          byte "St(%d)      : %s",0

.code

FPUDump proc
     LOCAL sts      :WORD                                   ; Original Status Reg when called
     LOCAL lev      :DWORD                                  ; Levels used on the stack
     LOCAL stks[8]  :QWORD                                  ; Stack values

     fstsw sts                                              ; Save the current status of FPU
     xor eax, eax                                           ; EAX = 0
     mov ax, sts                                            ; EAX = 0000XXXX
     shr eax, 11                                            ; AX  = 00000000 00000111
     neg eax                                                ; AX  = 11111111 11111001
     and eax, 7                                             ; AX  = 00000000 00000[001]
     mov lev, eax                                           ; Save the levels found
     .if( lev == 0 )                                        ; If special case (0)
       fst qword ptr [stks][0]                              ; Try storing ST(0)
       fstsw ax                                             ; Get status reg again
       .if(ax & 0041h)                                      ; See if Underflow and Not Valid
         mov lev, 0                                         ; Yes, then it IS empty (0)
       .else                                                ;
         mov lev, 8                                         ; No, Then its FULL (8)
       .endif
     .endif
     
     invoke wsprintf, addr dbbuf, addr szFPU5, lev          ; Display Levels found
     invoke DebugPrint, addr dbbuf                          ; DPrint It!
     
     xor eax, eax                                           ; EAX = 00000000
     mov ax, sts                                            ; EAX = 0000????
     shr eax, 6                                             ; AX  = 000000X* XXY*Y*ZZ
     shl al, 3                                              ; AX  = 000000X* *Y*ZZ---
     shl ax, 1                                              ; AX  = 00000X** Y*ZZ----
     shl al, 1                                              ; AX  = 00000X** *ZZ-----
     shr eax, 7                                             ; AX  = -------0 0000X***
     and eax, 7                                             ; AX  = 00000000 00000***
     .if( eax == 0 )                                        ; If ST > Source
       push offset szFPU1                                   ;   Then say so
     .elseif( eax == 1 )                                    ; If ST < Source
       push offset szFPU2                                   ;   Then say so
     .elseif( eax == 4 )                                    ; IF ST = Source
       push offset szFPU3                                   ;   Then say so
     .else                                                  ; Anything else
       push offset szFPU4                                   ;   Say as Undefined
     .endif
     call DebugPrint                                        ; Print it up!
     
     xor eax, eax                                           ; EAX = 0
     xor ecx, ecx                                           ; ECX = 0
     mov ax, sts                                            ; AX = Status first found 
     lea edx, szFPU6                                        ; EDX = Exception String Address
     add edx, 13                                            ; EDX = First Exception Bit
     .while( ecx < 8 )                                      ; Go thru 8 exception bits
       rol al, 1                                            ; Rol the exception bits left 1
       jc @F                                                ; See if a '1' Passed out
         or byte ptr [edx], 20h                             ; No, then force lower case (not set)
         jmp @next                                          ;     and onto next section
       @@:                                                  ; 
         and byte ptr [edx],0DFh                            ; Yes, then Force Upper case (Exception set)
       @next:                                               ;     and onto next section
       add edx, 2                                           ; Since Spaces, inc 2 in string
       inc ecx                                              ; Next bit!
     .endw
     push offset szFPU6                                     ; Push modified exception string
     call DebugPrint                                        ; Display The exception flags
     
     xor esi, esi                                           ; ESI = Counter = 0
     lea edi, stks                                          ; EDI = QWORD Buffer address
     .while( esi < lev )                                    ; Go thru all known stack entries
          fstp QWORD PTR [edi + esi*8]                      ; And pop into the buffer
          inc esi                                           ; Next entry
     .endw     
     xor esi, esi                                           ; ESI = 0 again!
     .while( esi < lev )                                    ; Go thru all known buffer entries
          invoke FloatToStr, [edi + esi*8], addr dbbuf1     ; Create Text Strings from them
          invoke wsprintf, addr dbbuf, addr szFPU7,         ; And display their contents
                 esi, addr dbbuf1                           ;
          invoke DebugPrint, addr dbbuf                     ;
          inc esi                                           ; Next entry
     .endw
     
     mov esi, lev                                           ; ESI = # of stack entries
     dec esi                                                ; ESI = 0 Based number of entries
     .if (SDWORD PTR esi >= 0)                              ; If and While still positive         
       .while (SDWORD PTR esi >= 0)                         ;
          fld QWORD PTR [edi +esi*8]                        ; Push the dwords back in proper order           
          dec esi                                           ; dec esi (for proper ordering)
       .endw                                                ;
     .endif                                                 ;

     ret                                                    ; DONE!
FPUDump endp

end
