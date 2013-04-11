@echo off

set outd=.\Build\

echo .
echo *** exhibit DLLs ***

xcopy Code\FbEditDLL\Build\FbEdit.dll                   %outd%   /d /y || goto ERR_Exit

xcopy Code\RACodeComplete\Build\RACodeComplete.dll      %outd%   /d /y || goto ERR_Exit
xcopy Code\RAFile\Build\RAFile.dll                      %outd%   /d /y || goto ERR_Exit
xcopy Code\RAGrid\Build\RAGrid.dll                      %outd%   /d /y || goto ERR_Exit
xcopy Code\RAProperty\Build\RAProperty.dll              %outd%   /d /y || goto ERR_Exit
xcopy Code\RAProject\Build\RAProject.dll                %outd%   /d /y || goto ERR_Exit
::xcopy Code\RAResEd\Build\RAResEd.dll                    %outd%   /d /y || goto ERR_Exit
xcopy Code\RAEdit\Build\RAEdit.dll                      %outd%   /d /y || goto ERR_Exit
xcopy Code\RAHexEd\Build\RAHexEd.dll                    %outd%   /d /y || goto ERR_Exit
xcopy Code\Other\SpreadSheet\SprSht.dll                 %outd%   /d /y || goto ERR_Exit

xcopy Code\Samples\CustCtrl\FBEPictView\FBEPictView.dll %outd%   /d /y || goto ERR_Exit
xcopy Code\Samples\CustCtrl\FBEVideo\FBEVideo.dll       %outd%   /d /y || goto ERR_Exit
xcopy Code\Samples\CustCtrl\FBEWeb\FBEWeb.dll           %outd%   /d /y || goto ERR_Exit



:OK_Exit
echo .
echo ------------------------
echo --- OK - Batch ready ---
echo ------------------------
echo .
echo .
echo .
pause
exit 0

:ERR_Exit
echo .
echo ********************************
echo *** ERROR - Batch terminated ***
echo ********************************
echo .
echo .
echo .
pause
exit 1
