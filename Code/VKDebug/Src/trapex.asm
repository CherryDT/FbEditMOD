;-----------------------------------------------------------------------------
;TrapEx_seh, FormatFlags, TrapExEnd_seh, GetExName functions are written
;by vkim.
;-----------------------------------------------------------------------------

.386
.model flat, stdcall
option casemap: none

include VKDebug.inc

includelib kernel32.lib
includelib user32.lib
includelib masm32.lib

public __esp
public __hLib
public __hInst
public __pSymOpt
public __pGetLine
public __pSymInit
public __eh

DebugProc       proto :dword
GetExName       proto :dword
FormatFlags     proto :dword, :dword, :dword

.data?
szRegs          byte 128 dup(?)

.data
__esp           dword 0
__hLib          dword 0
__hInst         dword 0
__pSymInit      dword 0
__pGetLine      dword 0
__pSymOpt       dword 0
__eh            dword 0
dwLine          dword 0
pFile           dword 0

szExcHead       byte "=====================[EXCEPTION INFORMATION]====================", 0
szExcBottom     byte 64 dup("-"), 0
szExcCode       byte 128 dup(0)
szExcCodeFmt    byte "Exception code: %s", 13, 10, "Location: %s, %d", 13, 10, 0

szRegsFmt       byte "eax=%0.8X ebx=%0.8X ecx=%0.8X edx=%0.8X esi=%0.8X", 13, 10, \
                     "edi=%0.8X ebp=%0.8X esp=%0.8X eip=%0.8X", 0
szSegFmt        byte "CS=%0.4X DS=%0.4X SS=%0.4X ES=%0.4X FS=%0.4X GS=%0.4X  %s", 0
szSeg           byte 65 dup(0)

szFlagsFmt      byte "%s %s %s %s %s %s %s %s", 0
szFlags         byte 16 dup(0)

il IMAGEHLP_LINE <>
dwDisp dword 0

.code

TrapEx_seh proc C pExcept: dword, pFrame: dword, pContext: dword, pDispatch: dword
    mov edx, pExcept
    assume edx: ptr EXCEPTION_RECORD
    mov ebx, pContext
    assume ebx: ptr CONTEXT
    .if (([edx].ExceptionCode == EXCEPTION_BREAKPOINT) || ([edx].ExceptionCode == EXCEPTION_SINGLE_STEP))
        .if __hLib != 0
            mov edx, pExcept
            mov il.SizeOfStruct, sizeof IMAGEHLP_LINE
            pushad
            push offset il
            push offset dwDisp
            push [edx].ExceptionAddress
            push __hInst
            call __pGetLine
            mov dword ptr [esp+28], eax
            popad
            .if eax 
                push il.LineNumber
                pop dwLine
                push il.FileName
                pop pFile 
                mov ebx, pContext
                mov edx, pExcept
                mov eax, [edx].ExceptionAddress
                mov eax, dword ptr [eax]
                .if al == 0C3h ;if al == ret opcode we need to remove seh frame
                    mov [ebx].regEip, offset TrapExEnd_seh
                    jmp ext
                .endif
                pushfd
                pop eax
                or eax, 100h
                push eax
                pop [ebx].regFlag
            .endif
        .endif
    .else
        invoke DebugPrint, addr szExcHead
        mov edx, pExcept
        invoke GetExName, [edx].ExceptionCode
        invoke wsprintf, addr szExcCode, addr szExcCodeFmt, eax, pFile, dwLine
        invoke DebugPrint, addr szExcCode
        mov ebx, pContext
        invoke wsprintf, addr szRegs, addr szRegsFmt, [ebx].regEax, [ebx].regEbx, [ebx].regEcx, [ebx].regEdx, [ebx].regEsi, [ebx].regEdi, [ebx].regEbp, [ebx].regEsp, [ebx].regEip
        invoke DebugPrint, addr szRegs
        mov [ebx].regEip, offset TrapExEnd_seh
        invoke FormatFlags, [ebx].regFlag, addr szFlags, addr szFlagsFmt
        invoke wsprintf, addr szSeg, addr szSegFmt, [ebx].regCs, [ebx].regDs, [ebx].regSs, [ebx].regEs, [ebx].regFs, [ebx].regGs, eax
        invoke DebugPrint, addr szSeg
        invoke DebugPrint, addr szExcBottom
    .endif
ext:
    assume edx: nothing
    assume ebx: nothing
    mov eax, ExceptionContinueExecution
    ret
TrapEx_seh endp

TrapExEnd_seh proc
    assume fs: nothing
    push eax
    mov eax, [esp]
    mov fs:[0], eax
    pop eax
    mov esp, __esp
    jmp __eh
TrapExEnd_seh endp

GetExName proc ExCode: dword
    mov eax, ExCode
    .if eax == EXCEPTION_ACCESS_VIOLATION
        mov eax, CTEXT("EXCEPTION_ACCESS_VIOLATION")
    .elseif eax == EXCEPTION_ARRAY_BOUNDS_EXCEEDED
        mov eax, CTEXT("EXCEPTION_ARRAY_BOUNDS_EXCEEDED")
    .elseif eax == EXCEPTION_BREAKPOINT
        mov eax, CTEXT("EXCEPTION_BREAKPOINT")
    .elseif eax == EXCEPTION_DATATYPE_MISALIGNMENT
        mov eax, CTEXT("EXCEPTION_DATATYPE_MISALIGNMENT")
    .elseif eax == EXCEPTION_FLT_DENORMAL_OPERAND
        mov eax, CTEXT("EXCEPTION_FLT_DENORMAL_OPERAND")
    .elseif eax == EXCEPTION_FLT_DIVIDE_BY_ZERO
        mov eax, CTEXT("EXCEPTION_FLT_DIVIDE_BY_ZERO")
    .elseif eax == EXCEPTION_FLT_INEXACT_RESULT
        mov eax, CTEXT("EXCEPTION_FLT_INEXACT_RESULT")
    .elseif eax == EXCEPTION_FLT_INVALID_OPERATION
        mov eax, CTEXT("EXCEPTION_FLT_INVALID_OPERATION")
    .elseif eax == EXCEPTION_FLT_OVERFLOW
        mov eax, CTEXT("EXCEPTION_FLT_OVERFLOW")
    .elseif eax == EXCEPTION_FLT_STACK_CHECK
        mov eax, CTEXT("EXCEPTION_FLT_STACK_CHECK")
    .elseif eax == EXCEPTION_FLT_UNDERFLOW
        mov eax, CTEXT("EXCEPTION_FLT_UNDERFLOW")
    .elseif eax == EXCEPTION_ILLEGAL_INSTRUCTION
        mov eax, CTEXT("EXCEPTION_ILLEGAL_INSTRUCTION")
    .elseif eax == EXCEPTION_IN_PAGE_ERROR
        mov eax, CTEXT("EXCEPTION_IN_PAGE_ERROR")
    .elseif eax == EXCEPTION_INT_DIVIDE_BY_ZERO
        mov eax, CTEXT("EXCEPTION_INT_DIVIDE_BY_ZERO")
    .elseif eax == EXCEPTION_INT_OVERFLOW
        mov eax, CTEXT("EXCEPTION_INT_OVERFLOW")
    .elseif eax == EXCEPTION_SINGLE_STEP
        mov eax, CTEXT("EXCEPTION_SINGLE_STEP")
    .else
        mov eax, CTEXT("UNKNOWN_EXCEPTION")
    .endif
    ret
GetExName endp

FormatFlags proc fl: dword, szFlag: dword, szFmt: dword
    local szFl[16]: byte
    mov szFl[0], "o"
    mov szFl[1], 0
    mov szFl[2], "d"
    mov szFl[3], 0
    mov szFl[4], "i"
    mov szFl[5], 0
    mov szFl[6], "s"
    mov szFl[7], 0
    mov szFl[8], "z"
    mov szFl[9], 0
    mov szFl[10], "a" 
    mov szFl[11], 0
    mov szFl[12], "p"
    mov szFl[13], 0
    mov szFl[14], "c"
    mov szFl[15], 0
    mov eax, fl
    test eax, 800h
    .if !zero?
        sub szFl[0], 20h
    .endif
    test eax, 400h
    .if !zero?
        sub szFl[2], 20h
    .endif
    test eax, 200h
    .if !zero?
        sub szFl[4], 20h
    .endif
    test eax, 80h
    .if !zero?
        sub szFl[6], 20h
    .endif
    test eax, 40h
    .if !zero?
        sub szFl[8], 20h
    .endif
    test eax, 10h
    .if !zero?
        sub szFl[10], 20h
    .endif
    test eax, 4h
    .if !zero?
        sub szFl[12], 20h
    .endif
    test eax, 1h
    .if !zero?
        sub szFl[14], 20h
    .endif
    invoke wsprintf, szFlag, szFmt, addr szFl[0], addr szFl[2], addr szFl[4], addr szFl[6], addr szFl[8], addr szFl[10], addr szFl[12], addr szFl[14]
    mov eax, szFlag
    ret
FormatFlags endp

end
