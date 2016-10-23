@echo off
if "%~1"=="" goto :help
if NOT EXIST "%~1" echo File not found. & goto :help
for /f "usebackq skip=2 tokens=*" %%a in (`certutil -hashfile "%~1" %~2`) do (
    set repl_space=%%a
    echo %repl_space: =%
    if NOT %errorlevel%==0 set=2>nul & rem :: make errorlevel to 1
    goto :eof
)
goto :eof
:help
echo gethash.bat <file> [HashAlgorithm]
echo This batch script use certutil to generate hash.
echo So it's only avaliable on Windows 2003, Windows Vista or above.
