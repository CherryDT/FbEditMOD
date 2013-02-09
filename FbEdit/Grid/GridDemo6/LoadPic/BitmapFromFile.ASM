;-------------------------------------------------------------------------------
;  BitmapFromFile.asm
;
;  Image file loading routines for the MASM32 library
;
;  This source and assosciated binary code is 
;  Copyright © 2001 by M Stoller Enterprises
;
;  Written by Ernest Murphy
;
;  Not for commercial reproduction. No fee whatsoever may be imposed for 
;  transfering this file. Source files may be coppied only for educational use
;  on a free basis.
;
;  Binary object files may be included in any work be it private, public or
;  a commercial application without payment necessary, however, it would be
;  appreciated to add a note to the effect "certain routines used in this program
;  were produced by Ernest Murphy" in the program documentation. Burried deep in 
;  the help file is just fine.
;
;  There is no 'LZW' code contained in these routines.
;
;-------------------------------------------------------------------------------
.386
.model flat,stdcall
option casemap:none
.NOLIST

include windows.inc
include user32.inc
include kernel32.inc
include masm32.inc
include gdi32.inc
include comctl32.inc
include ole32.inc
include oleaut32.inc

includelib user32.lib
includelib masm32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib ole32.lib 
includelib oleaut32.lib 
includelib comctl32.lib

.LISTALL
.data
BitmapFromPicture   PROTO   :DWORD

sIID_IPicture       TEXTEQU <{07BF80980H, 0BF32H, 0101AH,   \
                             {08BH, 0BBH, 000H, 0AAH, 000H, 030H, 00CH, 0ABH}}>
                             
IID_IPicture        GUID    sIID_IPicture

IPicture STRUCT
    ; IUnknown methods
    QueryInterface          DWORD   ?
    AddRef                  DWORD   ?
    Release                 DWORD   ?
    ; IPicture methods
    get_Handle              DWORD   ?
    get_hPal                DWORD   ?
    get_Type                DWORD   ?
    get_Width               DWORD   ?
    get_Height              DWORD   ?
    Render                  DWORD   ?	
    set_hPal                DWORD   ?
    get_CurDC               DWORD   ?
    SelectPicture           DWORD   ?
    get_KeepOriginalFormat  DWORD   ?
    put_KeepOriginalFormat  DWORD   ?
    PictureChanged          DWORD   ?
    SaveAsFile              DWORD   ?
    get_Attributes          DWORD   ?
IPicture ENDS

.code
;-------------------------------------------------------------------------------
BitmapFromFile PROC public pszFileName:DWORD
    LOCAL pwszFileName:DWORD, dwLength:DWORD, pPicture:DWORD, hNewBmp:DWORD

    invoke CoInitialize, NULL
    mov pPicture, NULL    ; NULL pointer for later use

    ; first, we need the filename in Unicode
    ; get the buffer size in wide characters
    invoke MultiByteToWideChar, CP_ACP, 0, pszFileName, -1, NULL, 0
    mov dwLength, eax
    ; double that for buffer size in bytes
    rol eax, 1              
    invoke CoTaskMemAlloc, eax
    .IF !eax
        ; we didn't get the memory
        invoke SetLastError, ERROR_NOT_ENOUGH_MEMORY
        mov eax, NULL
        ret
    .ENDIF
    mov pwszFileName, eax

    invoke MultiByteToWideChar, CP_ACP, 0, pszFileName, -1, pwszFileName, dwLength
    ; now we can create out picture object
    invoke OleLoadPicturePath, pwszFileName, NULL, NULL, NULL, ADDR IID_IPicture, ADDR pPicture
    .IF  eax > 80000000H  ; hresult failed
        ; we didn't get the file to open, assume bad filename
        invoke SetLastError, ERROR_FILE_NOT_FOUND
        mov eax, NULL
        ret
    .ENDIF

    ; now we are ready to get the hBipmap, we farm this out for reuseability
    invoke BitmapFromPicture, pPicture
    mov hNewBmp, eax
    invoke CoUninitialize           ; all done with COM
    .IF !hNewBmp
        ; we didn't get the bitmap
        ; BitmapFromPicture called SetLastError for us, so just return
        mov eax, NULL
        ret
    .ENDIF

    ; release the Picture object
    mov eax, pPicture
    push eax
    mov eax, [eax]
    call [eax].IPicture.Release         

    mov eax, hNewBmp    ; hBitpap is our return value, stuff it

    ret                 ; we're all done

BitmapFromFile ENDP                
;-------------------------------------------------------------------------------
end 
