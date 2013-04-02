
@echo off

set MasmHome=%PROGRAMFILES(x86)%\Masm32
set FbcHome=%PROGRAMFILES(x86)%\FreeBasic 0.24.0

echo .
echo *** assembling ***
"%MasmHome%\Bin\ML.EXE" /c /coff /I"%MasmHome%\Include" "Src\intsqrt.asm" || goto ERR_Exit

echo .
echo *** compiling / linking ***
"%FbcHome%\fbc.exe" -g -v -s console Src\MixLang_Test.bas -a intsqrt.obj -x MixLang_Test.exe || goto ERR_Exit

echo .
echo *** cleanup ***
erase *.obj *.o || goto ERR_Exit



:OK_Exit
echo .
echo ------------------------
echo --- OK - Batch ready ---
echo ------------------------
pause
exit 0

:ERR_Exit
echo .
echo ********************************
echo *** ERROR - Batch terminated ***
echo ********************************
pause
exit 1
