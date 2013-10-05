@echo off
echo start of PREBUILD.BAT

echo build type = %build_type%
echo compiling: %compilin_bname%

if %compilin_bname% == test1 ( 
    echo here we do stuff for test1
)


if %compilin_bname% == test2 ( 
    echo here we do stuff for test2
)


echo end of PREBUILD.BAT
 
rem        return value must be zero
rem        otherwise build is stopped
exit 0
