

:: under revision

:: %4 = CustomCtrlTut.o
::if exist %4 del %4



:: %2 = CustomCtrlTut.bas
:: %3 = CustomCtrlTut.res
fbc -c CustCtrl.bas 
fbc -c CustCtrl.rc



:: %1 = CustomCtrlTut.dll
:: %3 = CustomCtrlTut.res
:: %4 = CustomCtrlTut.o
fbc -dll -l kernel32 -l gdi32 -l user32 -x CustCtrl.dll CustCtrl.o CustCtrl.rc.o

