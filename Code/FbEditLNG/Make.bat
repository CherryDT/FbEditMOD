
@echo off


call:GetIniValue "..\..\Make.ini" "FBHome" FBHome

echo.
echo *** compiling .rc ***

rem if installed use MinGW toolchain
windres --version
IF %ERRORLEVEL% EQU 9009 (
    echo windres not found
) else (
    windres --verbose --output-format=coff --include-dir="../FbEdit"  "Res\FbEditLNG.Rc" "FbEditLNG.Rc.o" > Make.log || goto ERR_Exit
    goto RC_Ready
)


rem if installed use MS DDK
RC /?
IF %ERRORLEVEL% EQU 9009 (
    echo RC not found
) else (
    RC /I ../FbEdit /FO "FbEditLNG.res" "Res\FbEditLNG.Rc" > Make.log || goto ERR_Exit
    CVTRES /MACHINE:IX86 /OUT:"FbEditLNG.Rc.o" "FbEditLNG.res"
    goto RC_Ready
)


rem dont use GoRC
"%FBHome%\bin\win32\GoRC.exe" /h
IF %ERRORLEVEL% EQU 9009 (
    echo GoRC not found
    goto ERR_Exit
) else (
    ::goto ERR_Exit
    REM TODO  (doesnt work)
    set INCLUDE="%CD%\..\FbEdit"
    "%FBHome%\bin\win32\GoRC.exe" /fo "FbEditLNG.Rc.obj" "Res\FbEditLNG.Rc" > Make.log || goto ERR_Exit
    rename FbEditLNG.Rc.obj FbEditLNG.Rc.o
)


:RC_Ready


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
del FbEditLNG.res




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
start Make.log
exit /b 1


rem This function reads a value from an INI file and stored it in a variable
rem %1 = name of ini file to search in.
rem %2 = search term to look for
rem %3 = variable to place search result (result with double expansion)
:GetIniValue
for /F "eol=; eol=[ tokens=1,2* delims==" %%i in ('findstr /b /l /i %~2= %1') do call set %3=%%~j
goto:eof
