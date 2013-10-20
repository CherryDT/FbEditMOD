
@echo off


fbc -v -dll -Wl -e,_MyDllMain@12 -x ..\DemoCtrl.dll DemoCtrl.bas DemoCtrl.rc || goto ERR_Exit


:: *** cleanup ***
del "..\*.a"
del "*.o"


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
exit /b 1
