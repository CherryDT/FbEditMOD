Windows Driver
[*BEGINTXT*]
[*PROJECTNAME*].prra
[Version]
Version=3000
[Project]
Assembler=GoAsm
Group=2,-1,0,1,Windows Driver,-2,-1,1,Assembly,-3,-1,1,Include,-4,-1,1,Misc,-5,-1,1,Resource
F1=-2,2,1,22,22,600,400,0,[*PROJECTNAME*].asm
[Make]
Make=0
0=Win32 Driver Release,'/r "$R"',"$R.res",'/c /x86 "$C"',"$C.obj",'$C $M $R /Driver /Entry DriverEntry',"$C.exe",'',
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].asm
/******************************************
[*PROJECTNAME*]
******************************************/

#include [*PROJECTNAME*].h

CODE SECTION

DriverEntry FRAME pDriverObject, pusRegistryPath

    mov eax, STATUS_DEVICE_CONFIGURATION_ERROR
    ret

ENDF
[*ENDTXT*]
[*BEGINTXT*]
[*PROJECTNAME*].h
#DEFINE WINVER NTDDI_WINXP
#DEFINE FILTERAPI

#DEFINE LINKFILES

#INCLUDE "ntstatus.h"
[*ENDTXT*]
