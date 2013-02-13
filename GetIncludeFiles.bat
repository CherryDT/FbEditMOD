@echo off

Set outd=.\Build\

XCopy Code\FbEdit\Inc\RA*.bi %outd%\Inc\ /R /Y
XCopy Code\FbEdit\Inc\ShowVars.bi %outd%\Inc\ /R /Y
XCopy Code\FbEdit\Inc\SpreadSheet.bi %outd%\Inc\ /R /Y

XCopy Code\FbEdit\Inc\Addins.bi %outd%\Inc\ /R /Y
