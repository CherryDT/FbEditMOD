@echo off

Set outd=.\Build\

XCopy Code\FbEdit\Inc\*.bi %outd%\Inc\ /R /Y
rem Copy SpreadSheet\SpreadSheet.inc \FbEdit\Inc

