
@echo off

setlocal enabledelayedexpansion

del Collect.log



:: ###############################################
:: collect Addin Files
:: ###############################################

set Collection=^
 "AdvEdit"^
 "Base Calc"^
 "Beautify"^
 "ChartabDBCS"^
 "ControlDefs"^
 "CP1251ToCP866"^
 "CustomFontAddin"^
 "FbDebug"^
 "FbEditLite"^
 "FBFileAssociation"^
 "Build\FbShowVars"^
 "FileTabStyle"^
 "HelpAddin"^
 "ProjectZip"^
 "QuickEval"^
 "ReallyRad"^
 "SnipletAddin"^
 "Test AIM_FILESTATE"^
 "Toolbar"^
 "TortoiseSVN"^
 "UndoSave"^
 "UpdateChecker"

echo .
echo *** get Addins ***

for %%S in (%Collection%) do (
    rem copying DLL
    rem delimit target with "*" to prevent prompting for "Does xxx specify a file name or directory name on the target (F = file, D = directory)?"
    xcopy /F /Y "%CD%\Code\Addins\%%~nS\%%~S.dll" "%CD%\Build\Addins\*" >> Collect.log || goto ERR_Exit

    rem copying TXT
    xcopy /F /Y "%CD%\Code\Addins\%%~nS\%%~S.txt" "%CD%\Build\Addins\Help\*" >> Collect.log || goto ERR_Exit
)



:: ###############################################
:: collect CustomControl Files
:: ###############################################

echo .
echo *** get CustomControls ***

set Collection=^
 "RACodeComplete"^
 "RAFile"^
 "RAGrid"^
 "RAProperty"^
 "RAProject"^
 "RAEdit"^
 "RAHexEd"

for %%S in (%Collection%) do (
    rem copying DLL
    xcopy /F /Y "%CD%\Code\CustomControl\%%~nS\Build\%%~nS.dll" "%CD%\Build\CustomControl\*" >> Collect.log || goto ERR_Exit
)

set Collection=^
 "FBEPictView"^
 "FBEVideo"^
 "FBEWeb"

for %%S in (%Collection%) do (
    rem copying DLL
    xcopy /F /Y "%CD%\Code\Samples\CustCtrl\%%~nS\%%~nS.dll" "%CD%\Build\CustomControl\*" >> Collect.log || goto ERR_Exit
)

xcopy /F /Y "%CD%\Code\CustomControl\SpreadSheet\SprSht.dll" "%CD%\Build\CustomControl\*" >> Collect.log || goto ERR_Exit



:: ###############################################
:: collect Language Files
:: ###############################################

echo .
echo *** get Language Files ***
xcopy /F /Y "%CD%\Data\Language\*.*" "%CD%\Build\Language\*" >> Collect.log || goto ERR_Exit



:: ###############################################
:: collect Help Files
:: ###############################################

echo .
echo *** get Help Files ***
xcopy /F /Y "%CD%\Docs\Help\*.chm" "%CD%\Build\Help\*" >> Collect.log || goto ERR_Exit
xcopy /F /Y "%CD%\Docs\Help\OldHelp\*.chm" "%CD%\Build\Help\*" >> Collect.log || goto ERR_Exit
xcopy /F /Y "%CD%\Redist\Docs\*.chm" "%CD%\Build\Help\*" >> Collect.log || goto ERR_Exit
xcopy /F /Y "%CD%\Code\CustomControl\RAResEd\Help\ResEd.chm" "%CD%\Build\Help\*" >> Collect.log || goto ERR_Exit



:: ###############################################
:: collect License Files
:: ###############################################

echo .
echo *** get License Files ***
xcopy /F /Y "%CD%\Redist\Licenses\*.*" "%CD%\Build\Licenses\*" >> Collect.log || goto ERR_Exit



:: ###############################################
:: collect Template Files
:: ###############################################

echo .
echo *** get Template Files ***
xcopy /F /Y "%CD%\Data\Templates\*.*" "%CD%\Build\Templates\*" >> Collect.log || goto ERR_Exit



:: ###############################################
:: collect Sniplet Files
:: ###############################################

echo .
echo *** get Sniplet Files ***
xcopy /F /Y /S "%CD%\Data\Sniplets\*.*" "%CD%\Build\Sniplets\*" >> Collect.log || goto ERR_Exit



:: ###############################################
:: collect Font Files
:: ###############################################

echo .
echo *** get Font Files ***
xcopy /F /Y "%CD%\Data\Fonts\*.*" "%CD%\Build\Fonts\*" >> Collect.log || goto ERR_Exit



:: ###############################################
:: collect API Files
:: ###############################################

echo .
echo *** get API Files ***
xcopy /F /Y "%CD%\Data\Api\*.*" "%CD%\Build\Api\*" >> Collect.log || goto ERR_Exit



:: ###############################################
:: collect Tools Files
:: ###############################################

echo .
xcopy /F /Y "%CD%\Code\Tools\FbEditLNG\Build\FbEditLNG.exe" "%CD%\Build\Tools\*" >> Collect.log || goto ERR_Exit
xcopy /F /Y "%CD%\Code\Tools\FbEditLNG\Build\Addins.lng" "%CD%\Build\Tools\*" >> Collect.log || goto ERR_Exit
xcopy /F /Y "%CD%\Code\Tools\MakeApi\Build\MakeApi.exe" "%CD%\Build\Tools\*" >> Collect.log || goto ERR_Exit
xcopy /F /Y "%CD%\Code\Tools\MakeApi\Build\MakeApi.txt" "%CD%\Build\Tools\*" >> Collect.log || goto ERR_Exit



:: ###############################################
:: collect Include Files
:: ###############################################

echo .
echo *** get Include Files ***
xcopy /F /Y "%CD%\Code\FbEdit\Inc\RA*.bi" "%CD%\Build\Inc\*" >> Collect.log || goto ERR_Exit
xcopy /F /Y "%CD%\Code\Addins\FbShowVars\Build\ShowVars.bi" "%CD%\Build\Inc\*" >> Collect.log || goto ERR_Exit
xcopy /F /Y "%CD%\Code\FbEdit\Inc\SpreadSheet.bi" "%CD%\Build\Inc\*" >> Collect.log || goto ERR_Exit
xcopy /F /Y "%CD%\Code\FbEdit\Inc\Addins.bi" "%CD%\Build\Inc\*" >> Collect.log || goto ERR_Exit



:: ###############################################
:: collect Project Sample Files
:: ###############################################

echo .
echo *** get Project Sample Files ***

:: create exclude filter
:: line feed hack
set LF= ^


:: space required, two empty lines required

set Filter=^
.obj!LF!^
.o!LF!^
.res!LF!^
.exe!LF!^
.undo!LF!^
\bak!LF!^
.tmp!LF!^
.temp

echo !Filter! > Filter.txt

xcopy /F /Y /E /EXCLUDE:Filter.txt "%CD%\Code\Samples\*.*" "%CD%\Build\Projects\*" >> Collect.log || goto ERR_Exit
xcopy /F /Y /E /EXCLUDE:Filter.txt "%CD%\Code\Addins\*.*" "%CD%\Build\Projects\Addins\*" >> Collect.log || goto ERR_Exit

del filter.txt



:: ###############################################
:: collect CustomFilter Files
:: ###############################################

echo .
echo *** get Custom Filter Files ***

:: create exclude filter
:: line feed hack
set LF= ^


:: space required, two empty lines required

set Filter=^
.obj!LF!^
.o!LF!^
.a!LF!^
.res!LF!^
.undo!LF!^
\bak!LF!^
.tmp!LF!^
.temp

echo !Filter! > filter.txt

xcopy /F /Y "%CD%\Code\Samples\Samples\CustomFilter\*.*" "%CD%\Build\CustomFilter\*" >> Collect.log || goto ERR_Exit

del filter.txt


:: ###############################################
:: collect FbEdit Main Files
:: ###############################################

echo .
echo *** get Main Files ***

xcopy /F /Y "%CD%\Code\FbEdit\Build\FbEdit.exe" "%CD%\Build\*" >> Collect.log || goto ERR_Exit
xcopy /F /Y "%CD%\ChangeLog.txt" "%CD%\Build\*" >> Collect.log || goto ERR_Exit

xcopy /F /Y "%CD%\Code\FbEditDLL\Build\FbEdit.dll" "%CD%\Build\*" >> Collect.log || goto ERR_Exit

xcopy /F /Y "%CD%\Data\FbEdit.ini" "%CD%\Build\*" >> Collect.log || goto ERR_Exit

echo .
echo *** get tre4.dll + license ***

xcopy /F /Y "%CD%\Requisite\tre*" "%CD%\Build\*" >> Collect.log || goto ERR_Exit







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
Collect.log
exit /b 1
