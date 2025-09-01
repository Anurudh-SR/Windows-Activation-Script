@echo off
echo Windows activation Script
echo ====================================================
echo. 
echo System information:
echo ====================================================
setlocal enabledelayedexpansion

:: ----------- GLOBAL FILE PATHS -----------
set "HOME_KEY_FILE=C:\Users\User\Desktop\win pro.txt"
set "PRO_KEY_FILE=C:\Users\User\Desktop\win pro.txt"
set "DISK_SCRIPT=C:\Users\User\Desktop\diskini.ps1"
:: -----------------------------------------

:: Display system info
call :ShowSystemInfo

:PromptChoice
echo Choose an option:
echo 1. Activate and Initialize disk
echo 2. Initialize disk only
echo.
set /p choice=Select (1 or 2): 
if "%choice%"=="1" goto ActivateAndInitialize
if "%choice%"=="2" goto InitializeOnly
echo Invalid choice. Please enter 1 or 2.
echo.
goto PromptChoice

:: --------------------------
:ShowSystemInfo
:: CPU
set "cpu="
for /f "skip=1 tokens=*" %%i in ('wmic cpu get name ^| findstr /r /v "^$"') do (
    set "cpu=%%i"
    goto :printCPU
)
:printCPU
echo CPU       : %cpu%
echo.
:: Motherboard
set "mobo="
for /f "skip=1 tokens=1 delims=" %%i in ('wmic baseboard get product ^| findstr /r /v "^$"') do (
    set "mobo=%%i"
    goto :printMobo
)
:printMobo
echo Mobo      : %mobo%
echo.
:: GPU
echo GPU       :
for /f "skip=1 tokens=*" %%i in ('wmic path Win32_VideoController get Name ^| findstr /r /v "^$"') do (
    echo.            %%i
)
echo.
:: RAM in GB using powershell
for /f "delims=" %%r in ('powershell -command "([int]((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB))"') do set "ram=%%r"
echo RAM       : %ram% GB
echo.
:: Memory Frequency
echo Frequency :
for /f "skip=1 tokens=*" %%i in ('wmic memorychip get speed ^| findstr /r /v "^$"') do (
    set "freq=%%i"
    for /f "tokens=* delims= " %%a in ("!freq!") do set freq=%%a
    echo.            !freq!    MHz
)
echo.
:: Disks
echo Disks     :
for /f "skip=1 tokens=*" %%i in ('wmic diskdrive get Model ^| findstr /r /v "^$"') do (
    echo.            %%i
)
echo.
exit /b
:: --------------------------

:ActivateAndInitialize
setlocal enabledelayedexpansion
echo Running disk initialization script...
set "diskOutput="
for /f "delims=" %%A in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%DISK_SCRIPT%"') do (
    set "line=%%A"
    if defined diskOutput (
        set "diskOutput=!diskOutput!^&echo !line!"
    ) else (
        set "diskOutput=echo !line!"
    )
)
if not defined diskOutput (
    echo No disk information returned.
) else (
    echo Disk initialization output:
    cmd /v:on /c "!diskOutput!"
)
echo.

:: Check if Windows is already activated
set "status="
for /f "tokens=2 delims==" %%s in ('wmic path SoftwareLicensingProduct where "PartialProductKey is not null" get LicenseStatus /value ^| find "="') do (
    set "status=%%s"
    if defined status goto CheckActivation
)
:CheckActivation
if "%status%"=="1" (
    echo Windows is already activated.
    endlocal
    pause
    exit /b
)
echo Proceeding with Windows activation...
echo.

:: Detect Windows Edition
for /f "tokens=2 delims==" %%a in ('wmic os get caption /value ^| find "="') do (
    set "edition=%%a"
)
echo Detected Windows Edition: %edition%

:: Select correct license key file using global variable
set "file="
if /i "%edition%"=="Microsoft Windows 10 Home" (
    set "file=%HOME_KEY_FILE%"
) else if /i "%edition%"=="Microsoft Windows 11 Home" (
    set "file=%HOME_KEY_FILE%"
) else if /i "%edition%"=="Microsoft Windows 10 Pro" (
    set "file=%PRO_KEY_FILE%"
) else if /i "%edition%"=="Microsoft Windows 11 Pro" (
    set "file=%PRO_KEY_FILE%"
)
if not defined file (
    echo ERROR: Unsupported Windows edition: %edition%
    pause
    exit /b
)

:: Prepare temp file
set "tempfile=%file%.tmp"
set "foundKey="
set "modifiedKey="
set "unusedFound=0"

:: Process each line in the selected file
(for /f "usebackq tokens=* delims=" %%a in ("%file%") do (
    set "line=%%a"
    if "!line:~-2!"==" *" (
       echo !line!
    ) else (
        set "unusedFound=1"
        if not defined foundKey (
            set "foundKey=!line!"
            set "modifiedKey=!line! *"
            echo !modifiedKey!
        ) else (
            echo !line!
        )
    )
)) > "%tempfile%"
if "!unusedFound!"=="0" (
    del "%tempfile%" >nul 2>&1
    echo No unused keys available in %file%.
    endlocal
    pause
    exit /b
)
echo %foundKey% | clip
move /Y "%tempfile%" "%file%" >nul
echo Key "%foundKey%" copied to clipboard and marked as used.
echo Installing product key...
cscript //nologo %windir%\system32\slmgr.vbs /ipk %foundKey%
echo Activating Windows...
cscript //nologo %windir%\system32\slmgr.vbs /ato
echo Checking activation status...
for /f "tokens=2 delims==" %%s in ('wmic path SoftwareLicensingProduct where "PartialProductKey is not null" get LicenseStatus /value ^| find "="') do (
    set "status=%%s"
)
if "!status!"=="1" (
    echo Windows is activated.
) else (
    echo Windows is NOT activated.
)
endlocal
pause
exit /b
:: --------------------------

:InitializeOnly
setlocal enabledelayedexpansion
echo Running disk initialization script...
set "diskOutput="
for /f "delims=" %%A in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%DISK_SCRIPT%"') do (
    set "line=%%A"
    if defined diskOutput (
        set "diskOutput=!diskOutput!^&echo !line!"
    ) else (
        set "diskOutput=echo !line!"
    )
)
if not defined diskOutput (
    echo No disk information returned.
) else (
    echo Disk initialization output:
    cmd /v:on /c "!diskOutput!"
)
pause
exit /b
