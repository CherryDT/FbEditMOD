@echo off

del .\Build\*.* /F /S /Q /A

for /D %%q in (.\Build\*) do rd /S/Q "%%q"

