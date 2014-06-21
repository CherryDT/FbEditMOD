
@echo off


echo .
echo *** build RACodeComplete ***
cd Code\RACodeComplete
call make.bat || goto ERR_Exit
cd ..\..


echo .
echo *** build RAEdit ***
cd Code\RAEdit
call make.bat || goto ERR_Exit
cd ..\..


echo .
echo *** build RAFile ***
cd Code\RAFile
call make.bat || goto ERR_Exit
cd ..\..


echo .
echo *** build RAGrid ***
cd Code\RAGrid
call make.bat || goto ERR_Exit
cd ..\..


echo .
echo *** build RAHexEd ***
cd Code\RAHexEd
call make.bat || goto ERR_Exit
cd ..\..


echo .
echo *** build RAProject ***
cd Code\RAProject
call make.bat || goto ERR_Exit
cd ..\..


echo .
echo *** build RAProperty ***
cd Code\RAProperty
call make.bat || goto ERR_Exit
cd ..\..


echo .
echo *** build RAResEd ***
cd Code\RAResEd
call make.bat || goto ERR_Exit
cd ..\..


echo .
echo *** build RATools ***
cd Code\RATools
call make.bat || goto ERR_Exit
cd ..\..


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
