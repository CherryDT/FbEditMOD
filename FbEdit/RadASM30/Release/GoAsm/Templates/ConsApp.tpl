Console App
[*BEGINTXT*]
[*PROJECTNAME*].prra
[Version]
Version=3000
[Project]
Assembler=goasm
Group=2,-1,0,1,Console_Template,-2,-1,1,Assembly,-3,-1,1,Include,-4,-1,1,Misc,-5,-1,1,Resource
F1=-2,0,1,22,22,600,400,0,[*PROJECTNAME*].Asm
F2=-3,0,1,22,22,600,400,0,[*PROJECTNAME*].h
[Make]
Make=0
0=Console release,'/r "$R"',"$R.res",'/c /x86 "$C"',"$C.obj",'$C $M $R /console',"$C.exe",'',
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].Asm
;##################################################################
; [*PROJECTNAME*]
;##################################################################

#include [*PROJECTNAME*].h

.data
	hConsole HANDLE 0

.code
START:

invoke GetStdHandle,-11
mov [hConsole],eax

invoke ExitProcess,0
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
#DEFINE WIN32_LEAN_AND_MEAN

#include "WINDOWS.H"
[*ENDTXT*]
