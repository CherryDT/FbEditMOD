@echo off


:: rename masm32 output file from .obj to .o

echo COMPILIN_BNAME=%COMPILIN_BNAME%
echo BUILD_TYPE=%BUILD_TYPE%


if %COMPILIN_BNAME% == intsqrt (
    echo renaming intsqrt.obj to Src\intsqrt.o
    move /y intsqrt.obj Src\intsqrt.o || goto ERR_Exit
) else ( 
    echo skipped
)

::        return value must be zero
::        otherwise build will be stopped

:OK_Exit
exit /b 0

:ERR_Exit
exit /b 1

