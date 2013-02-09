.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive
include windows.inc
include kernel32.inc
include user32.inc

includelib kernel32.lib
includelib user32.lib


;#######################################################################
;#Here are the protos declarations.                                    #
;#                                                                     #
;#######################################################################
DlgProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM
CalcKey         PROTO

;#######################################################################
;# This is the data section. I decided to declare the constants first  #
;# just to use them in the other data types.                           #
;#######################################################################


maxlenght				    equ 00FFh; máximo comprimento do nome.


include resource.inc

.data
szErro          			BYTE "Error",0
szAbout     				BYTE "About",0
szMaxLenReached             BYTE "Maximum length reached.",0
szNoName                    BYTE "There's not any name.",0
szAboutText                 BYTE "This is a simple keygen. Use with care.",0
uRotation                   UINT 03
uAlpha                      UINT 26

.data?
szMessage					BYTE 255 DUP(?) ; buffer para guardar o nome.
szKey						BYTE 255 DUP(?) ; buffer para guardar a chave gerada.
hInstance					DWORD ?
hWnd						DWORD ?	; handle para a janela. Diferente de hInstance.

;########################################################################	
.code
start:
	invoke GetModuleHandle,NULL
	mov		 [hInstance],EAX
	invoke DialogBoxParam, [hInstance],IDD_DLG1, NULL, addr DlgProc,NULL
	invoke ExitProcess,0

;########################################################################
	
DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
local hItem:HWND
	;m2m  [hWnd], [hWin]	
	mov	EAX,uMsg
	.if uMsg == WM_INITDIALOG
		invoke GetDlgItem, [hWin],IDC_EDT_MESSAGE
		mov [hItem], EAX
		invoke SetFocus, [hItem]
		invoke SendMessage, [hItem], EM_LIMITTEXT, (lengthof szMessage) / 10, 0
	.elseif uMsg == WM_COMMAND
		.if  [lParam] == 0
			nop
		.else
			mov EAX, [wParam]
			push EAX
			pop EDX
			shr EDX,010h
			and EAX,0FFFFh
			.if EDX == BN_CLICKED
				.if EAX == IDC_BTN_CRYPT
					invoke GetDlgItemText, [hWin], IDC_EDT_MESSAGE, addr szMessage, (lengthof szMessage) / 10
					.if  EAX !=0
						invoke CalcKey
						invoke SetDlgItemText, [hWin], IDC_EDT_CRYPTO, addr szKey ; aqui ele mostra a chave
					.else
						invoke MessageBox, [hWin], addr szNoName, addr szErro,MB_OK
					.endif
					
				.elseif EAX == IDC_BTN_ABOUT ; se o botão 2 for pressionado mostra uma messagebox bem tola.
					invoke MessageBox, [hWnd], addr szAboutText, addr szAbout, MB_OK
				.elseif EAX == IDC_BTN_EXIT
					invoke SendMessage, [hWin], WM_CLOSE, 0, 0
				.endif				
			.elseif EDX == EN_ERRSPACE || EDX == EN_MAXTEXT
				.if EAX == IDC_EDT_MESSAGE
					invoke MessageBox, [hWin], addr szMaxLenReached, addr szErro, MB_OK
				.endif
			.endif	
		.endif
	.elseif uMsg == WM_CLOSE
		invoke EndDialog, [hWin],0
		mov EAX,TRUE
		ret
	.endif
	mov	EAX,FALSE
	ret
DlgProc endp
	
;#######################################################################
;# This is the key coding  section, usually took from the executable  #
;# to be cracked. Other sources are not very reliable.                 #
;#######################################################################

CalcKey proc
local szTemp[255]:BYTE

	invoke RtlZeroMemory, addr szTemp, lengthof szTemp
	invoke lstrcpy, addr szTemp, addr szMessage
	
	xor ECX, ECX
L000:
	movzx EAX, byte ptr [szTemp + ECX]
	test EAX, EAX ; Tests the end of string.
	jz fini
	
	push ECX
	invoke IsCharAlpha, al
	pop ECX
	test EAX, EAX ; Tests an alpha character.
	jnz L001
	
	push ECX ; If the character is not alpha, shrinks the string.
	lea EBX, [szTemp]
	add EBX, ECX
	inc ebx
	push EBX    ; EBX --> The character after the non-alpha.
	dec EBX     ; EBX --> The non-alpha character to be overwritten.
	push EBX
	call lstrcpy
	pop ECX
	jmp L000
L001:
	movzx EAX, byte ptr [szTemp + ECX]
	and EAX, 11011111b  ; Converts character to uppercase.
	sub EAX, 'A'
	add EAX, [uRotation] ; Do the rotation on the alphabet
	xor EDX, EDX
	mov EBX, [uAlpha]
	div  BL
	add AH, 'A'
	shr EAX, 08
	mov byte ptr [szTemp + ECX], AL
	inc ECX
	jmp L000
	
fini:
	invoke lstrcpy, addr szKey, addr szTemp 
	ret
	
CalcKey endp
	
end start
	