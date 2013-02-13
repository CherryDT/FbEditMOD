@echo off

Set outd=.\Build\


:: Language Files
Mkdir %outd%\Language
Copy Data\Language\*.* %outd%\Language\


:: Help Files
MkDir %outd%\Help
Copy Docs\Help\FbEditHelp.chm %outd%\Help\


:: Template Files
Mkdir %outd%\Templates
XCopy Data\Templates\*.* %outd%\Templates\ /R /Y /S


:: Sniplet Files
Mkdir %outd%\Sniplets
XCopy Data\Sniplets\*.* %outd%\Sniplets\ /R /Y /S


:: Font Files
Copy Data\Fonts\*.* %outd%\


:: API Files
Mkdir %outd%\Api
Copy Data\Api\*.* %outd%\Api\
