
@echo off

if "%RUNNING%"=="1" goto ERR_Exit
set RUNNING=1

path %path%;c:\masm32;z:\programme\radasm;z:\programme\fb;Z:\Programme\CodeBlocks\MinGW\bin

echo .
echo *** build RACodeComplete ***
cd Code\CustomControl\RACodeComplete
call make.bat || goto ERR_Exit
cd ..\..\..


echo .
echo *** build RAEdit ***
cd Code\CustomControl\RAEdit
call make.bat || goto ERR_Exit
cd ..\..\..


echo .
echo *** build RAFile ***
cd Code\CustomControl\RAFile
call make.bat || goto ERR_Exit
cd ..\..\..


echo .
echo *** build RAGrid ***
cd Code\CustomControl\RAGrid
call make.bat || goto ERR_Exit
cd ..\..\..


echo .
echo *** build RAHexEd ***
cd Code\CustomControl\RAHexEd
call make.bat || goto ERR_Exit
cd ..\..\..


echo .
echo *** build RAProject ***
cd Code\CustomControl\RAProject
call make.bat || goto ERR_Exit
cd ..\..\..


echo .
echo *** build RAProperty ***
cd Code\CustomControl\RAProperty
call make.bat || goto ERR_Exit
cd ..\..\..


echo .
echo *** build RAResEd ***
cd Code\CustomControl\RAResEd
call make.bat || goto ERR_Exit
cd ..\..\..


echo .
echo *** build RATools ***
cd Code\CustomControl\RATools
call make.bat || goto ERR_Exit
cd ..\..\..


echo .
echo *** build VKDebug ***
cd Code\VKDebug
call make.bat || goto ERR_Exit
cd ..\..


echo .
echo *** build FBEditDLL ***
cd Code\FBEditDLL
call make.bat || goto ERR_Exit
cd ..\..


echo .
echo *** build FBEditLNG ***
cd Code\Tools\FBEditLNG
call make.bat || goto ERR_Exit
cd ..\..\..


echo .
echo *** build MakeApi ***
cd Code\Tools\MakeApi
call make.bat || goto ERR_Exit
cd ..\..\..


echo .
echo *** build FBEdit ***
cd Code\FBEdit
call make.bat || goto ERR_Exit
cd ..\..



















:OK_Exit
set RUNNING=
echo .
echo ------------------------
echo --- OK - Batch ready ---
echo ------------------------
echo .
echo .
echo .
exit /b 0

:ERR_Exit
set RUNNING=
echo .
echo ********************************
echo *** ERROR - Batch terminated ***
echo ********************************
echo .
echo .
echo .
exit /b 1
