
@echo off
mode con: cols=160


call:GetIniValue "..\..\..\Make.ini" "FBHome" FBHome

echo .
echo *** building DLL and import library (FBEdit support) ***
"%FBHome%\fbc" -s gui -dll -export -w all -v "Src\Addin.bas" "Src\FbShowVars.rc" -x "Build\FbShowVars.dll" > Make.log || goto ERR_Exit

echo .
echo *** building LIB (client support) ***
"%FBHome%\fbc" -lib -w all -v "Src\ShowVars.bas" -x "Build\libShowVars.a" >> Make.log || goto ERR_Exit

echo .
echo *** Expose BI (client support), TXT help file ***
xcopy Src\ShowVars.bi Build /d /y || goto ERR_Exit
xcopy fbShowVars.txt Build /d /y || goto ERR_Exit




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
