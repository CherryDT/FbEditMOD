
@echo off


echo.
echo *** compiling bas files ***
if /i "%1"=="DEBUG" (
    echo DEBUG
    fbc -v -g "Src\MakeApi.Bas" "Res\MakeApi.Rc" -x "Build\MakeApi.exe" > Make.log || goto ERR_Exit
) else ( 
    echo RELEASE
    fbc -s gui -v "Src\MakeApi.Bas" "Res\MakeApi.Rc" -x "Build\MakeApi.exe" > Make.log || goto ERR_Exit
)


echo.
echo *** exhibit doc files ***
xcopy  /f /y "MakeApi.txt" "Build\*"  >> Make.log || goto ERR_Exit


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
