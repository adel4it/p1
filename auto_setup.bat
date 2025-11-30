@echo off
:: =========================================================
::  AUTO-INSTALL OR RUN FLASK APP
:: =========================================================

:: ---- FORCE ADMIN MODE ----
>nul 2>&1 "%SystemRoot%\system32\cacls.exe" "%SystemRoot%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

title DAB111_G13_Project - Auto Install & Run
echo ===============================================
echo      Auto Install & Run Flask Application
echo ===============================================
echo.

:: ---------------------------------------------
:: 0) CHECK / INSTALL PYTHON
:: ---------------------------------------------
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python NOT found. Downloading Python installer...
    powershell -Command "Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe -OutFile python_installer.exe"

    if not exist python_installer.exe (
        echo [ERROR] Failed to download Python installer.
        pause
        exit /b
    )

    echo Installing Python silently...
    python_installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_pip=1 SimpleInstall=1 TargetDir="C:\Python312"
    timeout /t 15 >nul
)

python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python installation FAILED.
    pause
    exit /b
)

echo Python is ready.
echo.

:: ---------------------------------------------
:: Ask for project location
:: ---------------------------------------------
set /p target_path=Enter FULL path to the project folder: 
set /p folder_name=Enter project folder name (no spaces): 

set full_path=%target_path%\%folder_name%
mkdir "%full_path%" 2>nul

:: ---------------------------------------------
:: CHECK if project already exists
:: ---------------------------------------------
if exist "%full_path%\src\app.py" (
    echo Project already exists. Running it...
    cd /d "%full_path%\src"
) else (
    echo Downloading and installing project...
    cd /d "%full_path%"
    powershell -Command "Invoke-WebRequest -Uri https://github.com/Adel4itca/DAB111_G13_Project/archive/refs/heads/main.zip -OutFile project.zip"
    powershell -Command "Expand-Archive project.zip -DestinationPath . -Force"
    del project.zip
    ren DAB111_G13_Project-main src
    cd src

    :: ---------------------------------------------
    :: Create and activate venv
    :: ---------------------------------------------
    echo Creating virtual environment...
    python -m venv venv
    call venv\Scripts\activate.bat

    echo Installing requirements...
    python -m pip install -r requirements.txt
)

:: ---------------------------------------------
:: Create desktop shortcut (if not exist)
:: ---------------------------------------------
set SHORTCUT=%USERPROFILE%\Desktop\DBA111.url
if not exist "%SHORTCUT%" (
    echo Creating desktop shortcut to http://127.0.0.1:5000 ...
    echo [InternetShortcut] > "%SHORTCUT%"
    echo URL=http://127.0.0.1:5000 >> "%SHORTCUT%"
    echo IconIndex=0 >> "%SHORTCUT%"
    echo IconFile=%SystemRoot%\system32\shell32.dll >> "%SHORTCUT%"
    echo Shortcut created!
)

:: ---------------------------------------------
:: Run Flask app
:: ---------------------------------------------
echo Starting Flask app...
call venv\Scripts\activate.bat
start "" python app.py

echo Opening browser...
start "" http://127.0.0.1:5000

pause
