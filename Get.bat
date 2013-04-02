

:: under construction

@echo off

echo .
echo *** get FbEdit.dll ***
xcopy Code\FbEditDLL\Build\FbEdit.dll Build /d /y || goto ERR_Exit




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
pause
exit 1
