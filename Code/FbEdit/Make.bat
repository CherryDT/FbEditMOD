
@echo off

call:GetIniValue "..\..\Make.ini" "FBHome" FBHome


set BFLAGS_MODULE_GENGAS=-c -v -w param -w escape -w all -w next
set BFLAGS_MODULE_GENGCC=-c -v -w param -w escape -w all -w next -gen gcc -O 2
set BFLAGS_MAIN=-v -s gui -w param -w escape -w all -w next


echo .
echo *** compiling modules ***
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\Environment.bas"       > make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\Language.bas"         >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\IniFile.bas"          >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\Project.bas"          >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGCC% "Src\ZStringHandling.bas"  >> make.log || goto ERR_Exit
echo 6 ...
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\GUIHandling.bas"      >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\SpecHandling.bas"     >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\CoTxEd.bas"           >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\Goto.bas"             >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\EditorOpt.bas"        >> make.log || goto ERR_Exit
echo 5 ...
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\TabTool.bas"          >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\Make.bas"             >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\GenericOpt.bas"       >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\CodeComplete.bas"     >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\FileIO.bas"           >> make.log || goto ERR_Exit
echo 4 ...
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\Misc.bas"             >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\Property.bas"         >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\Splash.bas"           >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\CBH_Dialog.Bas"       >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\Find.bas"             >> make.log || goto ERR_Exit
echo 3 ...
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\HexFind.bas"          >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\LineQueue.bas"        >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\Toolbar.bas"          >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\ResEd.bas"            >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\ResEdOpt.bas"         >> make.log || goto ERR_Exit
echo 2 ...
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\About.bas"            >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\BlockInsert.bas"      >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\ZStringHandling2.bas" >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\CreateTemplate.bas"   >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\Export.bas"           >> make.log || goto ERR_Exit
echo 1 ...
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\Addins.bas"           >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\DebugOpt.bas"         >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\CustomFilter.bas"     >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\HexEd.bas"            >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\FileMonitor.bas"      >> make.log || goto ERR_Exit
"%FBHome%\FBC.EXE" %BFLAGS_MODULE_GENGAS% "Src\Statusbar.bas"        >> make.log || goto ERR_Exit



echo .
echo *** compiling main ***
"%FBHome%\FBC.EXE" %BFLAGS_MAIN%  "Src\FbEdit.bas"          ^
                                  "Res\FbEdit.rc"           ^
                                  "Src\Environment.o"       ^
                                  "Src\Language.o"          ^
                                  "Src\IniFile.o"           ^
                                  "Src\Project.o"           ^
                                  "Src\ZStringHandling.o"   ^
                                  "Src\GUIHandling.o"       ^
                                  "Src\SpecHandling.o"      ^
                                  "Src\CoTxEd.o"            ^
                                  "Src\Goto.o"              ^
                                  "Src\EditorOpt.o"         ^
                                  "Src\TabTool.o"           ^
                                  "Src\Make.o"              ^
                                  "Src\GenericOpt.o"        ^
                                  "Src\CodeComplete.o"      ^
                                  "Src\FileIO.o"            ^
                                  "Src\Misc.o"              ^
                                  "Src\Property.o"          ^
                                  "Src\Splash.o"            ^
                                  "Src\CBH_Dialog.o"        ^
                                  "Src\Find.o"              ^
                                  "Src\HexFind.o"           ^
                                  "Src\LineQueue.o"         ^
                                  "Src\Toolbar.o"           ^
                                  "Src\ResEd.o"             ^
                                  "Src\ResEdOpt.o"          ^
                                  "Src\About.o"             ^
                                  "Src\BlockInsert.o"       ^
                                  "Src\ZStringHandling2.o"  ^
                                  "Src\CreateTemplate.o"    ^
                                  "Src\Export.o"            ^
                                  "Src\Addins.o"            ^
                                  "Src\DebugOpt.o"          ^
                                  "Src\CustomFilter.o"      ^
                                  "Src\HexEd.o"             ^
                                  "Src\FileMonitor.o"       ^
                                  "Src\Statusbar.o"         ^
                                  -x "Build\FbEdit.exe" >> make.log || goto ERR_Exit



echo .
echo *** cleanup ***
del "Src\*.o" || goto ERR_Exit



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
make.log
exit /b 1


rem This function reads a value from an INI file and stored it in a variable
rem %1 = name of ini file to search in.
rem %2 = search term to look for
rem %3 = variable to place search result (result with double expansion)
:GetIniValue
for /F "eol=; eol=[ tokens=1,2* delims==" %%i in ('findstr /b /l /i %~2= %1') do call set %3=%%~j
goto:eof


