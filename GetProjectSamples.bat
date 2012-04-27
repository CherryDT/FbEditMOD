@echo off

Set outd=.\Build\

Mkdir %outd%\Projects

XCopy Code\SampleProjects\*.* %outd%\Projects\ /R /Y /E /EXCLUDE:Filter.txt
XCopy Code\Addins\*.* %outd%\Projects\Addins\ /R /Y /E /EXCLUDE:Filter.txt
XCopy Code\Tools\*.* %outd%\Projects\Applications\ /R /Y /E /EXCLUDE:Filter.txt
