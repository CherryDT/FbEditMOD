
@echo off

if /i %compilin_bname%==FbEdit (
    echo *** exhibit EXE ***
    copy /y ..\..\Build\FbEdit.exe Build\FbEdit.exe || goto :ERR_Exit
) else (
    echo skipped
)


:OK_Exit
exit 0


:ERR_Exit
echo *** ERROR - Batch terminated ***
exit 1

