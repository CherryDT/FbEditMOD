@echo off

mkdir .\Build

call GetAddins.bat
call GetCustomControls.bat
call GetIncludeFiles.bat
call GetDataFiles.bat
call GetProjectSamples.bat

copy ChangeLog.txt .\Build\