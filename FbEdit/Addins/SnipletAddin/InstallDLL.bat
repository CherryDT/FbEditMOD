
@echo off


rem    /y    =>   skip user confirmation
xcopy SnipletAddin.dll  ..\..\..\..\..\Addins\   /d /y   || goto ERR_Exit





:OK_Exit
echo .
echo .
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
echo .
echo .
echo ********************************
echo *** ERROR - Batch terminated ***
echo ********************************
echo .
echo .
echo .
pause
exit
