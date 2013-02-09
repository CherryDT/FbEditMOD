
;#########################################################################
;Include files

include windows.inc
include kernel32.inc
include user32.inc

;#########################################################################
;Libraries

includelib kernel32.lib
includelib user32.lib

;#########################################################################
;	MasmEd Addin Include

include ..\Addins.inc

;#########################################################################
;		VKim's Debug

include masm32.inc
include debug.inc
includelib debug.lib

.const

szMenuItem			db 'Addin test',0

.data?

hInstance			dd ?	;Dll's module handle
lpHandles			dd ?	;Pointer to handles struct
lpProc				dd ?	;Pointer to proc struct
lpData				dd ?	;Pointer to data struct
MenuIDAddin			dd ?	;A MenuID allocated for this addin
hook				HOOK <>
