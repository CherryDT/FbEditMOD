
@echo off

set IncFile=".\Inc\SVNVersion.bi"

if /i "%compilin_bname%"=="FbEdit" (
    echo *** reading SVN Revision ***
	echo #define SVN_REV "$WCREV$$WCMODS? - modified:$" > %IncFile%
    SubWCRev.exe "%CD%\..\.." %IncFile% %IncFile%  || goto :ERR_Exit
) else (
    echo skipped
)



:OK_Exit
exit 0


:ERR_Exit
echo *** ERROR - Reading SVN Revision ***
echo #define SVN_REV "undefined" > %IncFile%
exit 0

