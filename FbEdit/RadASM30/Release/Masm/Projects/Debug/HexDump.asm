;-----------------------------------------------------------------------------
;HexDump2 function is written by NaN.
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

.data?
dbbuf           byte 128 dup (?)

.data
szFormat        byte  "%0.8X : %0.2X %0.2X %0.2X %0.2X - %0.2X %0.2X %0.2X %0.2X - %0.2X %0.2X %0.2X %0.2X - %0.2X %0.2X %0.2X %0.2X",0
szFormat2       byte "%0.8d : BYTES TOTAL",0

.code

HexDump2 proc lpData:DWORD, nLen:DWORD
     LOCAL lns      :DWORD
     LOCAL Rmd      :DWORD
     mov eax, nLen
     .if( eax )                                             ; If a valid sting length
          shr eax, 4                                        ; Get divisions of 16
          mov lns, eax                                      ; Save it into Lns
          mov eax, nLen
          and eax, 0Fh                                      ; Get the Remainder
          mov Rmd, eax                                      ; Save the Remainder
          xor ebx, ebx                                      ; Set EBX = 0
          mov esi, lpData                                   ; Get the data pointer
          
          .while( ebx < lns )                               ; While there is more to display
               add esi, 15                                  ; Go to last byte
               xor ecx, ecx                                 ; ECX == NULL
               xor eax, eax                                 ; EAX == NULL               
               .while (ecx < 16)                            ; Get 16 Bytes!
                  mov al, [esi]                             ; Get byte
                  push eax                                  ; Push DWORD
                  inc ecx                                   ; Next count
                  dec esi                                   ; back one byte
               .endw
               inc  esi
               push esi                                     ; Push line address
               push offset szFormat                         ; Push a format string
               push offset dbbuf                            ; Push the buffer
               call wsprintf                                ; call wsprintf to make it!
               add esp, 04ch                                ; update the stack!
               invoke DebugPrint, addr dbbuf                ; Print the formated text
               inc ebx                                      ; Next Line
               add esi, 16                                  ; Next 16 Bytes!
          .endw
          .if( Rmd )
          dec esi
          xor eax, eax                                      ; eAX == NULL
          mov ecx, 16                                       ; ECX = 16
          sub ecx, Rmd                                      ; ECX = 16 - Remainder (diff)
          .while (ecx > 0)                                  ; Loop thru difference
               push eax                                     ; Push NULL
               dec ecx                                      ; next
          .endw
          xor ecx, ecx                                      ; ECX == NULL
          add esi, Rmd                                      ; Goto Last data byte
          .while( ecx < Rmd )                               ; Do last line (under 16)
               mov al, [esi]                                ; Get byte
               push eax                                     ; push dword
               inc ecx                                      ; next count
               dec esi                                      ; back one byte
          .endw
          inc  esi
          push esi                                          ; Push line address
          push offset szFormat                              ; Push a format string
          push offset dbbuf                                 ; Push the buffer
          call wsprintf                                     ; call wsprintf to make it!
          add esp, 04ch                                     ; update the stack
          invoke DebugPrint, addr dbbuf                     ; Print the formated text
          .endif

          invoke wsprintf, addr dbbuf, addr szFormat2, nLen
          invoke DebugPrint, addr dbbuf                                   
     .endif
     ret
HexDump2 endp

end
