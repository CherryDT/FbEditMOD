
@echo off
mode con: cols=160

call:GetIniValue "..\..\Make.ini" "MasmHome" MasmHome
call:GetIniValue "..\..\Make.ini" "FBHome" FBHome


echo .
echo *** compling BAS modules ***
"%FBHome%\fbc.exe" -v -c Src\GetOutpWindow.bas -o GetOutpWindow.o > Make.log || goto ERR_Exit


echo .
echo *** assembling ASM modules ***
"%MasmHome%\bin\ml.exe" /c /coff /I"%MasmHome%\Include" Src\fpudump.asm >> Make.log || goto ERR_Exit
"%MasmHome%\bin\ml.exe" /c /coff /I"%MasmHome%\Include" Src\hexdump.asm >> Make.log || goto ERR_Exit
"%MasmHome%\bin\ml.exe" /c /coff /I"%MasmHome%\Include" Src\spy.asm     >> Make.log || goto ERR_Exit
"%MasmHome%\bin\ml.exe" /c /coff /I"%MasmHome%\Include" Src\trapex.asm  >> Make.log || goto ERR_Exit


echo .
echo *** linking library ***
"%MasmHome%\bin\polib.exe" /verbose /out:Build\VKDebug.lib *.obj *.o >> Make.log || goto ERR_Exit


echo .
echo *** exposing libraries ***
xcopy Build\VKDebug.lib Build\libVKDebug.a /d /y || goto ERR_Exit
xcopy "%MasmHome%\lib\masm32.lib" Build\libmasm32.a /d /y || goto ERR_Exit
xcopy Src\VKDebug.inc Build\VKDebug.inc /d /y || goto ERR_Exit
xcopy Src\VKDebug.bi Build\VKDebug.bi /d /y || goto ERR_Exit



echo .
echo *** cleanup ***
del *.obj *.o  || goto ERR_Exit


:OK_Exit
echo .
echo ------------------------
echo --- OK - Batch ready ---
echo ------------------------
echo .
echo .
echo .
exit /b 0

:ERR_Exit
echo .
echo ********************************
echo *** ERROR - Batch terminated ***
echo ********************************
echo .
echo .
echo .
Make.log
exit /b 1


rem This function reads a value from an INI file and stored it in a variable
rem %1 = name of ini file to search in.
rem %2 = search term to look for
rem %3 = variable to place search result (result with double expansion)
:GetIniValue
for /F "eol=; eol=[ tokens=1,2* delims==" %%i in ('findstr /b /l /i %~2= %1') do call set %3=%%~j
goto:eof


