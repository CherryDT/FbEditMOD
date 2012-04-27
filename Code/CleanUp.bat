@echo off

FOR /D %%G in (*) DO (
	Pushd %%G
	IF EXIST "CleanUp.bat" (
		Echo CleanUp: %%G
		call CleanUp.bat
	)
	Popd
)