@echo off
title puush uploader
echo Started puush uploader 
:::It uploads the file in the configured folder and delete it locally.
::config
set use_api_key_to_login=1
::set value to 1 for api key login
set account_mail=foo@bar.com
set password=foobar
set api_key=FA10A1234D513C16250DC60A8E5D2FBE
::put your API key here if you enabled API key login
set enable_md5=0
::set value to 1 to enable upload (not really needed)
set folder_location=.\uploads\
set puush_url=http://puush.me/api
set curl_binary=curl.exe
set verbose=1
::set value to 1 to enable verbose mode
set copy_to_clipboard=1
::1 to enable it
::::::::::End of config::::::::::
if NOT EXIST "%curl_binary%" echo curl binary is not exist, Quitting... & goto :EOF
if NOT EXIST "%folder_location%\*" mkdir %folder_location%
::check password or api key correct
if "%use_api_key_to_login%"=="1" goto :api_login
for /f "usebackq tokens=1-4 delims=," %%a in (`%curl_binary% -LSs -F "e=%account_mail%;p=%password%" %puush_url%/auth`) do (
    if "%%a"=="-1" echo Failed to auth with mail and password. & pause & goto :EOF
    echo Login with mail and password successful.
    set api_key=%%b
)
goto :start
:api_login
for /f "usebackq tokens=1-4 delims=," %%a in (`%curl_binary% -LSs -F "k=%api_key%" %puush_url%/auth`) do (
    if "%%a"=="-1" echo Failed to auth with token. & pause & goto :EOF
    echo Login with API key sucessful.
    set api_key=%%b
)

if EXIST "%~1" call :upload "%~fnx1" & goto :EOF
:start
for %%i in (%folder_location%\*) do (
    move /y %%i puush%%~xi
    call :upload puush%%~xi
    if "%sucess%"=="1" del puush%%~xi
)
goto :start
:upload
echo Uploading "%~1"...
if "%enable_md5%"=="1" (
    call :md5hash "%~1" md5
    for /f "usebackq tokens=*" %%a in (`%curl_binary% -LSs -F "z=\"poop\"" -F "k=%api_key%" -F "f=@%~1" -F "c=%md5%" %puush_url%/up `) do (
        if "%verbose%"=="1" echo API Response: %%a
        set upload_result=%%a
    )
) else (
    for /f "usebackq tokens=*" %%a in (`%curl_binary% -LSs -F "z=\"poop\"" -F "k=%api_key%" -F "f=@%~1" %md5_arg% %puush_url%/up `) do (
        if "%verbose%"=="1" echo API Response: %%a
        set upload_result=%%a
    )
)
for /f "tokens=1-4 delims=," %%a in ("%upload_result%") do (
    set /a "error_code=%%a" 2>nul
    if NOT "%%a"=="0" echo Error on uploading %~1 , error code %error_code% & set "sucess=0" & goto :EOF
    set "sucess=1"
    echo %%b
    if "%copy_to_clipboard%"="1" echo. | set/p"=%%b" | clip & echo URL copied to clipboard.
    ::Yes, BELL character(ASCII 07)
)
goto :eof
:md5hash
:md5hash_redo
for /f usebackq %%a in (`gethash.bat "%~1" md5`) do (
    if NOT "%errorlevel%"=="0" goto :md5hash_redo
    set %~2=%%a
)
goto :eof
