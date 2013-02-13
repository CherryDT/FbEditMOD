
@echo off


set MasmBin=%PROGRAMFILES%\Masm32\Bin
set MasmInc=%PROGRAMFILES%\Masm32\Include
set MasmLib=%PROGRAMFILES%\Masm32\Lib


cd FbEditDLL
echo compiling RC
%MasmBin%\RC.EXE /v FbEditDLL.rc || goto ERR_Exit

echo compiling ASMs
%MasmBin%\ML.EXE /DDLL /c /coff /Cp /Zi /I"%MasmInc%" "FbEditDLL.asm" || goto ERR_Exit

echo linking
%MasmBin%\LINK.EXE /verbose /SUBSYSTEM:WINDOWS /RELEASE /DLL /DEF:FbEditDLL.def /LIBPATH:"%MasmLib%" /OUT:"Dll\FbEdit.dll" FbEditDLL.obj FbEditDLL.res || goto ERR_Exit


echo Install DLL
xcopy FbEdit.dll ..\..\..\..\..\FbEdit.dll               /d /y || goto ERR_Exit

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
