@echo off


rem rename masm32 output file from .obj to .o



if %compilin_bname% == intsqrt ( 
    move /y intsqrt.obj intsqrt.o
)

rem        return value must be zero
rem        otherwise build is stopped
exit 0

