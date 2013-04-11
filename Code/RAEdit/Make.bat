
@echo off


call:GetIniValue "..\..\Make.ini" "MasmHome" MasmHome


set MasmBin=%MasmHome%\Bin
set MasmInc=%MasmHome%\Include
set MasmLib=%MasmHome%\Lib


echo .
echo *** compiling RC ***
"%MasmBin%\RC.EXE" /v /fo"RAEdit.res"  Src\RAEdit.rc > Make.log || goto ERR_Exit


echo .
echo *** compiling ASMs ***
"%MasmBin%\ML.EXE" /DDLL /c /coff /Cp /I"%MasmInc%" "Src\RAEdit.asm" >> Make.log || goto ERR_Exit


echo .
echo *** linking DLL ***
"%MasmBin%\LINK.EXE" /verbose /SUBSYSTEM:WINDOWS /RELEASE /DLL /DEF:Src\RAEdit.def /LIBPATH:"%MasmLib%" /OUT:"Build\RAEdit.dll" RAEdit.obj RAEdit.res >> Make.log || goto ERR_Exit
move Build\RAEdit.lib Build\libRAEdit.dll.a || goto ERR_Exit


echo .
echo *** compiling ASMs ***
"%MasmBin%\ML.EXE" /c /coff /Cp /I"%MasmInc%" "Src\RAEdit.asm" >> Make.log || goto ERR_Exit


echo .
echo *** building LIB ***
"%MasmBin%\POLIB.EXE" /verbose /OUT:"Build\RAEdit.lib" RAEdit.obj >> Make.log || goto ERR_Exit


echo .
echo *** exhibit INC ***
xcopy Src\RAEdit.inc Build /d /y || goto ERR_Exit


echo .
echo *** exhibit DOC ***
xcopy RAEdit.txt Build /d /y || goto ERR_Exit


echo .
echo *** cleanup ***
del RAEdit.obj || goto ERR_Exit
del RAEdit.res || goto ERR_Exit


:OK_Exit
echo .
echo ------------------------
echo --- OK - Batch ready ---
echo ------------------------
echo .
echo .
echo .
pause
exit 0

:ERR_Exit
echo .
echo ********************************
echo *** ERROR - Batch terminated ***
echo ********************************
echo .
echo .
echo .
Make.log
pause
exit 1


rem This function reads a value from an INI file and stored it in a variable
rem %1 = name of ini file to search in.
rem %2 = search term to look for
rem %3 = variable to place search result (result with double expansion)
:GetIniValue
for /F "eol=; eol=[ tokens=1,2* delims==" %%i in ('findstr /b /l /i %~2= %1') do call set %3=%%~j
goto:eof
