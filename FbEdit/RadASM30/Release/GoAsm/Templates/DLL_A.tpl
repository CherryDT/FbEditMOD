DLL no resource, ANSI
[*BEGINTXT*]
[*PROJECTNAME*].prra
[Version]
Version=3000
[Project]
Assembler=goasm
Group=2,-1,0,1,Ansi DLL,-2,-1,1,Assembly,-3,-1,1,Include,-4,-1,1,Misc,-5,-1,1,Resource
F1=-2,2,1,22,22,600,400,0,[*PROJECTNAME*].Asm
F2=-3,0,1,22,22,600,400,6,[*PROJECTNAME*].h
F3=-4,0,2,22,22,600,400,0,[*PROJECTNAME*].Def
Open=0,1,2,3
Api=
[Make]
Make=0
0=DLL32 ANSI Release,'/r "$R"',"$R.res",'/c /x86 "$C"',"$C.obj",'$C $M $R /dll /entry DllEntryPoint',"$C.exe",'',
Delete=0
IncBuild=0
Run=0,'',''
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].Asm
;##################################################################
; [*PROJECTNAME*]
;##################################################################

#Include [*PROJECTNAME*].h

DATA SECTION
	hInstance		HANDLE		0

;##################################################################

CODE SECTION

DllEntryPoint	FRAME hInst, reason, reserved1

	mov eax,[reason]
	.DLLPROCESSATTACH
	cmp eax,DLL_PROCESS_ATTACH
	JNE >.DLLPROCESSDETACH
		mov eax,[hInst]
		mov [hInstance], eax
		JMP >.LOAD
	
	.DLLPROCESSDETACH
	cmp eax,DLL_PROCESS_DETACH
	JNE >.DLLTHREADATTACH
		JMP >.LOAD
	
	.DLLTHREADATTACH
	cmp eax,DLL_THREAD_ATTACH
	JNE >.DLLTHREADDETACH
		JMP >.LOAD
	
	.DLLTHREADDETACH
	cmp eax,DLL_THREAD_DETACH
	JNE >.NOLOAD
		JMP >.LOAD
	
	.NOLOAD
		; The reson was not understood
		; Rather than take a chance we will refuse to load
		xor eax, eax
		ret
	
	.LOAD
		xor eax, eax
		inc eax

	ret
ENDF

[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].Def


[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].h
// Headers available at
// http://www.quickersoft.com/donkey/index.html

// NOTE: INCLUDE Environment variable must be set to headers path

#DEFINE WINVER NTDDI_WINXP
#DEFINE FILTERAPI

#DEFINE LINKFILES
#DEFINE LINKVCRT

#DEFINE CCUSEORDINALS

#include "WINDOWS.H"
#include "Commctrl.h"
[*ENDTXT*]
