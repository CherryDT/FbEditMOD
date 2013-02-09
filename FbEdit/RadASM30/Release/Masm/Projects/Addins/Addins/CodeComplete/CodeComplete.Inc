
;#########################################################################
;Include files

include windows.inc
include kernel32.inc
include user32.inc
include Gdi32.inc

;#########################################################################
;Libraries

includelib kernel32.lib
includelib user32.lib
includelib Gdi32.lib

;#########################################################################
;VKim's Debug

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

;#########################################################################
;RadASM AddIn Include

include ..\Addins.inc

.const

szCoInvoke		db 'CoInvoke',0

szSomeText		db 'aaitemA',0,'paramA0,paramA1,paramA2',0
				db 'aaitemB',0,'paramB0,paramB1,paramB2,paramB3',0
				db 'abitemC',0,'paramC0,paramC1,paramC2',0
				db 'abitemD',0,'paramD0,paramD1,paramD2,paramD3',0,0

szCR			db VK_RETURN,0

.data?

hInstance			dd ?					;Dll's module handle
lpHandles			dd ?					;Pointer to handles struct
lpProc				dd ?					;Pointer to proc struct
lpData				dd ?					;Pointer to data struct

hCC					dd ?					;Handle of codecomplete listbox
hTT					dd ?					;Hancle of codecomplete tooltip
hProperty			dd ?					;Handle of properties tool

nPos				dd ?
linebuff			db 16384 dup(?)
hook				HOOK <>

.code

;#########################################################################
;Output Window procs

TextOutput proc lpszStr

   pushad
   push  lpszStr
   mov   eax,lpProc
   call  [eax].ADDINPROCS.lpTextOutput
   push  offset szCR
   mov   eax,lpProc
   call  [eax].ADDINPROCS.lpTextOutput
   popad
   ret

TextOutput endp
