@echo off


:: rename masm32 output file from .obj to .o



if %compilin_bname% == intsqrt (
    echo renaming intsqrt.obj to Src\intsqrt.o
    move /y intsqrt.obj Src\intsqrt.o
) else ( 
    echo skipped
)

::        return value must be zero
::        otherwise build will be stopped
exit 0

