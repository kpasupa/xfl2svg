@echo off
setlocal enabledelayedexpansion

set "XFL2SVG=C:\Users\Admin\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.12_qbz5n2kfra8p0\LocalCache\local-packages\Python312\Scripts\xfl2svg.exe"
set "BAT_DIR=%~dp0"
set "OUTPUT=%BAT_DIR%output"

:: ============================================================
:: XFL_CONFIG — path to your personal config file
:: Set to "" to skip and use XFL_DEFAULT values below
:: ============================================================
set "XFL_CONFIG=%BAT_DIR%config.bat"
:: ============================================================

:: ============================================================
:: XFL_DEFAULT — fallback values when config is missing/empty
:: ============================================================
set "DEFAULT_XFL=%BAT_DIR%xfl"
set "DEFAULT_NO_BG=y"
set "DEFAULT_CENTER=y"
set "DEFAULT_REMOVE_FRAME="
set "DEFAULT_WIDTH="
set "DEFAULT_HEIGHT="
set "DEFAULT_SYMBOL="
:: ============================================================

echo === XFL to SVG Converter ===
echo.

:: Load user config if set and file exists
if not "!XFL_CONFIG!"=="" (
    if exist "!XFL_CONFIG!" (
        echo Config: !XFL_CONFIG!
        call "!XFL_CONFIG!"
    ) else (
        echo Config: not found, using defaults
    )
) else (
    echo Config: none, using defaults
)
echo.

:: Apply defaults for anything not set by config
if "!XFL_ROOT!"==""        set "XFL_ROOT=%DEFAULT_XFL%"
if "!NO_BG_IN!"==""        set "NO_BG_IN=%DEFAULT_NO_BG%"
if "!CENTER_IN!"==""       set "CENTER_IN=%DEFAULT_CENTER%"
if "!FRAME_IN!"==""        set "FRAME_IN=%DEFAULT_REMOVE_FRAME%"
if "!WIDTH!"==""           set "WIDTH=%DEFAULT_WIDTH%"
if "!HEIGHT!"==""          set "HEIGHT=%DEFAULT_HEIGHT%"
if "!SYMBOL!"==""          set "SYMBOL=%DEFAULT_SYMBOL%"

:: Input folder — ask if still empty or not found
if "!XFL_ROOT!"=="" (
    set /p "XFL_ROOT=Enter XFL folder path: "
) else if not exist "!XFL_ROOT!\" (
    echo Input folder not found: !XFL_ROOT!
    set /p "XFL_ROOT=Enter XFL folder path: "
)
echo Input : !XFL_ROOT!
echo Output: %OUTPUT%
echo.

:: Override stage size — ask only if both still empty
if "!WIDTH!"=="" if "!HEIGHT!"=="" (
    set /p "OVERRIDE=Override stage size? [y/N]: "
    if /i "!OVERRIDE!"=="y" (
        set /p "WIDTH=Width  [550]: "
        set /p "HEIGHT=Height [400]: "
        if "!WIDTH!"==""  set "WIDTH=550"
        if "!HEIGHT!"=="" set "HEIGHT=400"
    )
)

:: No background
if "!NO_BG_IN!"=="" set /p "NO_BG_IN=Remove background? [Y/n]: "
if "!NO_BG_IN!"=="" set "NO_BG_IN=y"
set "NO_BG_ARG="
if /i "!NO_BG_IN!"=="y" set "NO_BG_ARG=--no-background"

:: Center content
if "!CENTER_IN!"=="" set /p "CENTER_IN=Center content in viewport? [Y/n]: "
if "!CENTER_IN!"=="" set "CENTER_IN=y"
set "CENTER_ARG="
if /i "!CENTER_IN!"=="y" set "CENTER_ARG=--center"

:: Remove outer frame: y=always remove, n=always keep, ""=auto (smart per symbol)
set "FRAME_ARG=--auto-frame"
if /i "!FRAME_IN!"=="y" set "FRAME_ARG=--no-frame"
if /i "!FRAME_IN!"=="n" set "FRAME_ARG="

:: Build args
set "EXTRA_ARGS=!NO_BG_ARG! !CENTER_ARG! !FRAME_ARG!"
set "SIZE_ARGS="
if not "!WIDTH!"=="" set "SIZE_ARGS=--width !WIDTH! --height !HEIGHT!"

:: List available symbols
echo.
echo Available symbols:
"%XFL2SVG%" "!XFL_ROOT!" "_" "." --print-symbols 2>nul
echo.

:: Symbol selection
if "!SYMBOL!"=="" set /p "SYMBOL=Enter symbol name (or press Enter for all): "

:: Create output folder
if not exist "%OUTPUT%\" mkdir "%OUTPUT%"

if "!SYMBOL!"=="" (
    echo Rendering all symbols...
    for /f "skip=1 tokens=*" %%s in ('"%XFL2SVG%" "!XFL_ROOT!" "_" "." --print-symbols 2^>nul') do (
        echo   %%s
        "%XFL2SVG%" "!XFL_ROOT!" "%%s" "%OUTPUT%" !SIZE_ARGS! !EXTRA_ARGS!
    )
) else (
    "%XFL2SVG%" "!XFL_ROOT!" "!SYMBOL!" "%OUTPUT%" !SIZE_ARGS! !EXTRA_ARGS!
)

echo.
echo Done! Output: %OUTPUT%
pause
