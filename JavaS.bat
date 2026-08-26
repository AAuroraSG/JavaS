@echo off
setlocal enabledelayedexpansion

mkdir %AppData%\JavaS >nul 2>&1
set "cfg_P=%AppData%\JavaS\JavaS.ini"

REM ================================

if "%~1"=="" (
    echo JavaS [Error]: Argument Is Empty
    exit /b 1
)

REM ================================

for %%z in (%*) do (
    if /i "%%z"=="-h" goto :h
    if /i "%%z"=="--h" goto :h
    if /i "%%z"=="-help" goto :h
    if /i "%%z"=="--help" goto :h
)

REM ================================

set "arg1=%~1"

set "matched="
set "version="

if /i "!arg1:~0,2!"=="-v" (
    set "matched=1"
    set "version=!arg1:~2!"
    goto :check_version
)

if /i "!arg1:~0,3!"=="--v" (
    set "matched=2"
    set "version=!arg1:~3!"
    goto :check_version
)

if /i "!arg1:~0,8!"=="-version" (
    set "matched=4"
    set "version=!arg1:~8!"
    goto :check_version
)

if /i "!arg1:~0,9!"=="--version" (
    set "matched=8"
    set "version=!arg1:~9!"
    goto :check_version
)

:check_version
if defined matched (
    if defined version (
        set "jv=!version!"
    ) else (
        set "jv=0"
    )
    goto :verify

) else (
    echo JavaS [Error]: ParameterError
    exit /b 1
)

REM ================================

:verify
if !jv! neq 0 (
    for /f "delims=0123456789" %%y in ("!jv!") do (
        if not "%%y"=="" (
            echo JavaS [Error]: -v parameter is incorrect
            exit /b 1
        )
    )
) else (
    set "jv=-1"
)

if "%~2"=="" (
    echo Java [Error]: The java command is none
    exit /b 1
)

REM ================================

:mkcmd
set "cm="

:shift_loop
shift

if "%~1"=="" goto :shift_done

if not defined cm (
    set "cm=%~1"
) else (
    set "cm=!cm! %~1"
)

goto :shift_loop
:shift_done

if !jv! equ -1 (
    echo JavaS [Info]: default %JAVA_HOME%
    set "Path=%JAVA_HOME%\bin;%Path%"
    call !cm!
    exit /b 0
)

REM ================================

if not exist %cfg_P% (
    (
        echo [JavaPath]
        echo ; java17 = C:\Program Files\java\java-17
        echo java8  =
        echo java11 =
        echo java17 =
        echo java21 =
        echo java25 =
        echo java26 =
    ) > !cfg_P!
    echo JavaS [Error]: File "!cfg_p!" isn't found and auto create
    exit /b 1
)

REM ================================

:sjp
set "jp="
for /f "usebackq tokens=1,* delims==" %%a in ("%cfg_P%") do (
    set "KEY=%%a"
    set "KEY=!KEY: =!"
    
    set "first=!KEY:~0,1!"
    
    if not "!first!"=="#" if not "!first!"==";" if not "!first!"=="[" (
        set "VALUE=%%b"
        for /f "tokens=*" %%c in ("!VALUE!") do set "VALUE=%%c"
        
        if "!KEY!"=="java%jv%" (
            set "jp=!VALUE!"
        )
    )
)


if not defined jp (
    echo JavaS [Error]: File "!cfg_p!" is Empty
    exit /b 1
) else (
    set "JAVA_HOME=!jp!"
    set "Path=!jp!\bin;%Path%"
)

call !cm!

exit /b 0

REM ================================

goto :End

:h
echo JavaS Version: 0.0.5
echo JavaS ^<-h ^| --help^>
echo     -h ^| --help : Show help
echo     When the help parameter is in any position,
echo     it will be treated as the command "JavaS -h"
echo     But if you want to run "JavaS -v* java -h",
echo     you can use the command "JavaS -v* java"
echo JavaS ^<-v ^| --version^>[java version] ^<command^> [args]
echo     -v ^| --version : java version
echo     ^<command^> [args]: java command


REM ================================

:End

exit /b 0