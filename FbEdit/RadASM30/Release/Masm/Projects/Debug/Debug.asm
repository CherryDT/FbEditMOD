;-----------------------------------------------------------------------------
;DebugPrint function is written by vkim and optimized by KetilO.
;-----------------------------------------------------------------------------

.386
.model flat, stdcall
option casemap: none

include windows.inc
include kernel32.inc
include user32.inc
include masm32.inc

includelib kernel32.lib
includelib user32.lib
includelib masm32.lib

AIM_DEBUGGETWIN	equ WM_USER+54	;Gets the handle of RadASM output window.

.data

szWinClass		byte "RadASM30Class", 0
szCommandLine	byte "\RadASM30\RadASM.exe", 0
szCRLF          byte 13, 10, 0 

.code

DebugPrint proc DebugData: dword
    local hwnd: dword
    invoke FindWindow, addr szWinClass, NULL
    .if !eax
        invoke WinExec, addr szCommandLine, SW_SHOWNORMAL
        invoke FindWindow, addr szWinClass, NULL
    .endif
    .if eax
		invoke SendMessage,eax,AIM_DEBUGGETWIN,0,1			;Activate Output#1 and returns handle.
        mov		hwnd,eax
        invoke SendMessage,hwnd,EM_SETSEL,-1,-1
        invoke SendMessage,hwnd,WM_GETTEXTLENGTH,0,0
        .if eax
            invoke SendMessage,hwnd,EM_REPLACESEL,FALSE,addr szCRLF
        .endif
        invoke SendMessage,hwnd,EM_REPLACESEL,FALSE,DebugData
        invoke SendMessage,hwnd,EM_SCROLLCARET,0,0
    .endif
    ret
DebugPrint endp

end
