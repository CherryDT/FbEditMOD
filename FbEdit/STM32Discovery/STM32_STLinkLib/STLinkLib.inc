include	windows.inc
include	kernel32.inc
include	user32.inc

includelib kernel32.lib
includelib user32.lib

;#########################################################################
;VKim's Debug

;include masm32.inc
;include Debug.Inc
;includelib masm32.lib
;includelib Debug.lib

;include masm32.inc
;include \RadASM30\masm\inc\debug.inc
;includelib masm32.lib
;includelib \RadASM30\masm\lib\debug.lib

;#########################################################################

MAX_RDBLOCK						equ 4096
MAX_WRBLOCK						equ 64

ST_LINK struct
	buff						BYTE 1000h dup(?)
	buff2						BYTE 96h dup(?)
	lpSTMass_Enum_GetNbDevices  DWORD ?
	lpSTMass_Enum_GetDevice     DWORD ?
	lpSTMass_GetDeviceInfo      DWORD ?
	lpSTMass_Enum_Reenumerate   DWORD ?
	lpSTMass_OpenDevice         DWORD ?
	lpSTMass_CloseDevice        DWORD ?
	lpSTMass_SendCommand        DWORD ?
	hDevice						DWORD ?
	hFile						DWORD ?
	hModule						DWORD ?
ST_LINK ends

ST_LINKCMND struct
	cmd0						BYTE ?
	cmd1						BYTE ?
	cmd2						BYTE ?
	rdadr						DWORD ?
	rdbytes						DWORD ?
	reserved0					BYTE 5 dup(?)
	x							WORD ?
	wradr						DWORD ?
	y							DWORD ?
	z							DWORD ?
	reserved1					BYTE 13 dup(?)
ST_LINKCMND ends

.const

szError							BYTE 'Error',0
szErrLoadDll					BYTE 'STLinkUSBDriver.dll not found.',0
szErrProcAddress				BYTE 'STLinkUSBDriver.dll not valid.',0
szErrNotConnected				BYTE 'STLink not connected.',0

szSTLinkUSBDriverDll			BYTE 'STLinkUSBDriver.dll',0
szSTMass_Enum_Reenumerate		BYTE 'STMass_Enum_Reenumerate',0
szSTMass_Enum_GetNbDevices		BYTE 'STMass_Enum_GetNbDevices',0
szSTMass_Enum_GetDevice			BYTE 'STMass_Enum_GetDevice',0
szSTMass_GetDeviceInfo			BYTE 'STMass_GetDeviceInfo',0
szSTMass_OpenDevice				BYTE 'STMass_OpenDevice',0
szSTMass_CloseDevice			BYTE 'STMass_CloseDevice',0
szSTMass_SendCommand			BYTE 'STMass_SendCommand',0

;#########################################################################

.data?

STLink							ST_LINK <>
STLinkCmnd						ST_LINKCMND <>

;#########################################################################
