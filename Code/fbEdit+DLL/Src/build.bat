fbc -g -v -dll "fbEditBase.bas" "fbEditBase.rc" -a "../../fbCodeComplete/libfbCodeComplete.a" -a "../lib/RAFile.lib" -a "../lib/RAProperty.lib" -a "../lib/RAGrid.lib" -a "../lib/RAHexEd.lib" -a "../lib/RAEdit.lib" -a "../lib/RAResEd.lib" -l kernel32 -l user32 -l gdi32 -l comctl32 -l ole32 -a "../3rd/Debug.lib" -l ntdll -l comdlg32 -l shell32 -Wl " --entry _MAIN@12, fbEditDLL.def" -x "FbEdit.dll"


del fbEditBase.obj
del libfbEdit.dll.a

rem "C:\Program Files (x86)\FreeBASIC\bin\win32\ld.exe" -T "C:\Program Files (x86)\FreeBASIC\lib\win32\i386pe.x" -subsystem console --dll --enable-stdcall-fixup --export-dynamic -e _DllMainCRTStartup@12 -s --stack 1048576,1048576 -L "C:\Program Files (x86)\FreeBASIC\lib\win32" -L "./" "C:\Program Files (x86)\FreeBASIC\lib\win32\dllcrt2.o" "C:\Program Files (x86)\FreeBASIC\lib\win32\crtbegin.o" "fbEditBase.o" --whole-archive "../lib/RACodeComplete.lib" "../lib/RAFile.lib" "../lib/RAProperty.lib" "../lib/RAGrid.lib" "../lib/RAHexEd.lib" "../lib/RAEdit.lib" "../lib/RAResEd.lib" "../3rd/Debug.lib" "fbEditBase.obj" --no-whole-archive "C:\masm32\lib\masm32.lib" -o "fbEditBase.dll" -( -lkernel32 -luser32 -lgdi32 -lcomctl32 -lole32 -l oleaut32 -lntdll -lcomdlg32 -lshell32 -lversion -ladvapi32 -lfb -lgcc -lmsvcrt -lmingw32 -lmingwex -lmoldname -lsupc++ "C:\Program Files (x86)\FreeBASIC\lib\win32\fbrt0.o" -) "C:\Program Files (x86)\FreeBASIC\lib\win32\crtend.o" fbEditDLL.def
rem fbc -v -dll "fbEditBase.bas" "fbEditBase.rc" -a "../lib/RACodeComplete.lib" -a "../lib/RAFile.lib" -a "../lib/RAProperty.lib" -a "../lib/RAGrid.lib" -a "../lib/RAHexEd.lib" -a "../lib/RAEdit.lib" -a "../lib/RAResEd.lib" -l kernel32 -l user32 -l gdi32 -l comctl32 -l ole32 -a "../3rd/Debug.lib" -l ntdll -l comdlg32 -l shell32 -Wl " --entry _MAIN@12, fbEditDLL.def" -x "FbEdit.dll"

copy fbedit.dll ..\..\..\build\ /y

if not exist fbedit.dll pause