format PE GUI 4.0
entry MyEntry

include '%fasminc%\win32a.inc'

section '.data' data readable writeable

gIst DD 0
gWnd dd 0
IDD_DIALOG		equ 1

struct LINE
	union
		start POINT
		struct
			x1 dd ?
			y1 dd ?
		ends
	ends
	union
		end POINT
		struct
			x2 dd ?
			y2 dd ?
		ends
	ends
ends

section '.code' code readable executable

MyEntry:
	invoke GetModuleHandle,eax
	mov [gIst],eax
	invoke DialogBoxParam,eax,IDD_DIALOG,0,DlgProc,0 
ExitApp:
	invoke ExitProcess,0

proc DlgProc,hWnd,uMsg,wParam,lParam
	local	tst:DWORD
	local	myvar:DWORD

	push edi esi ebx
	lea		eax,[tst]
	mov eax,[uMsg]
	cmp	eax,WM_COMMAND
	je	jCOMMAND
	cmp	eax,WM_INITDIALOG
	je	jINITDIALOG
	cmp	eax,WM_CLOSE
	je	jCLOSE
	xor eax,eax
	jmp finish

jINITDIALOG:
	mov eax,[hWnd]
	mov [gWnd],eax
	
	mov eax,1
	jmp finish
	
jCOMMAND:
	mov eax,[wParam]
	cmp	eax,1000
	je	a1000
	xor eax,eax
	jmp finish
	
a1000:
	invoke SendMessage,[hWnd],WM_CLOSE,0,0
	mov eax,1
	jmp finish
	
jCLOSE:	
	invoke EndDialog,[hWnd],0
	mov eax,1
	
finish:
	pop ebx esi edi
	ret
endp

section '.idata' import data readable writeable

  library kernel, 'KERNEL32.DLL',\
	  user,   'USER32.DLL'

  import  kernel,\
	  GetModuleHandle,'GetModuleHandleA',\
	  ExitProcess,	  'ExitProcess'

  import  user,\
	  DialogBoxParam, 'DialogBoxParamA',\
	  EndDialog,	  'EndDialog',\
	  SendMessage,	  'SendMessageA'

section '.rsrc' resource from 'win32.res' data readable
