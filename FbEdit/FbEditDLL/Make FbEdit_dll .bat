
@echo off


echo GetLibs
cd %PROGRAMFILES%\FbEdit Test Environ\Projects\Applications\fbedit\FbEditDLL

rem xcopy   /y    =>   skip user confirmation
rem xcopy   /d    =>   update if newer version available
xcopy ..\CodeComplete\Lib\RACodeComplete.lib   Lib  /d /y || goto ERR_Exit
xcopy ..\FileBrowser\Lib\RAFile.lib            Lib  /d /y || goto ERR_Exit
xcopy ..\Grid\Lib\RAGrid.lib                   Lib  /d /y || goto ERR_Exit
xcopy ..\HexEd\Lib\RAHexEd.lib                 Lib  /d /y || goto ERR_Exit
xcopy ..\Property\Lib\RAProperty.lib           Lib  /d /y || goto ERR_Exit
xcopy ..\ResEd22\Lib\RAResEd.lib               Lib  /d /y || goto ERR_Exit
xcopy ..\SimEd\Lib\RAEdit.lib                  Lib  /d /y || goto ERR_Exit


set MasmBin=%PROGRAMFILES%\Masm32\Bin
set MasmInc=%PROGRAMFILES%\Masm32\Include
set MasmLib=%PROGRAMFILES%\Masm32\Lib


cd FbEditDLL
echo compiling RC (STDOUT: Make.log)
%MasmBin%\RC.EXE /v FbEditDLL.rc > ..\Make.log || goto ERR_Exit

echo compiling ASMs (STDOUT: Make.log)
%MasmBin%\ML.EXE /DDLL /c /coff /Cp /Zi /I"%MasmInc%" "FbEditDLL.asm" >> ..\Make.log || goto ERR_Exit


echo linking (STDOUT: Make.log)
%MasmBin%\LINK.EXE /verbose /SUBSYSTEM:WINDOWS /RELEASE /DLL /DEF:FbEditDLL.def /LIBPATH:"%MasmLib%" /OUT:FbEdit.dll FbEditDLL.obj FbEditDLL.res >> ..\Make.log || goto ERR_Exit




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
