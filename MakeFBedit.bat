:: makeFbEdit.bat
:: This file help everyone that wants to build FbEdit and dont have an old FbEdit intalled
:: @Author Porfirio Ribeiro
:: @Usage Set the path to FreeBasic and run the file
:: @depends FreeBasic compiler

@echo off

:: Dont forget to set the path if you dont have FreeBasic on your PATH env
::set PATH=%PATH%;c:\FreeBasic\

cd Code\FbEdit
fbc -s gui FbEdit.bas FbEdit.rc -x ..\..\Build\FbEdit.exe

echo Make Done
@echo on