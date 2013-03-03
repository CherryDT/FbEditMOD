
@echo off

rem configure environment BEFORE execution
set MasmBin=%PROGRAMFILES(x86)%\Masm32\Bin
set MasmInc=%PROGRAMFILES(x86)%\Masm32\Include
set MasmLib=%PROGRAMFILES(x86)%\Masm32\Lib
set RadAsmHome=%PROGRAMFILES(x86)%\RadASM

cd FbEditDLL
echo compiling RC
"%MasmBin%\RC.EXE" /v FbEditDLL.rc || goto ERR_Exit

echo compiling ASMs
"%MasmBin%\ML.EXE" /DDLL /c /coff /Cp /Zi /I"%MasmInc%" "FbEditDLL.asm" || goto ERR_Exit

echo linking
"%MasmBin%\LINK.EXE" /verbose /SUBSYSTEM:WINDOWS /RELEASE /DLL /DEF:FbEditDLL.def /LIBPATH:"%MasmLib%" /OUT:"Dll\FbEdit.dll" FbEditDLL.obj FbEditDLL.res || goto ERR_Exit


echo Install DLL
xcopy FbEdit.dll ..\..\..\..\..\FbEdit.dll               /d /y || goto ERR_Exit
s
echo Install Import-Library
xcopy FbEdit.lib ..\..\FbEdit\Lib\libFbEdit.dll.a        /d /y || goto ERR_Exit



:OK_Exit
echo .
echo ------------------------
echo --- OK - Batch ready ---
echo ------------------------
echo .
echo .
echo .
pause
exit

:ERR_Exit
echo .
echo ********************************
echo *** ERROR - Batch terminated ***
echo ********************************
echo .
echo .
echo .
pause
exit
