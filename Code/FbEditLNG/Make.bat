
@echo off


call:GetIniValue "..\..\Make.ini" "FBHome" FBHome

echo.
echo *** compiling .rc ***
windres --output-format=coff -I ../FbEdit  "Res\FbEditLNG.Rc" "FbEditLNG.Rc.o" > Make.log || goto ERR_Exit

echo.
echo *** compiling .bas ***
"%FBHome%\fbc" -c -v -m FbEditLNG "Src\FbEditLNG.bas" -o "FbEditLNG.o" >> Make.log || goto ERR_Exit

echo.
echo *** linking .exe ***
"%FBHome%\fbc" -s gui -v "FbEditLNG.o" "FbEditLNG.Rc.o" -x "Build\FbEditLNG.exe" >> Make.log || goto ERR_Exit

echo .
echo *** cleanup ***
del FbEditLNG.Rc.o || goto ERR_Exit
del FbEditLNG.o || goto ERR_Exit




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
