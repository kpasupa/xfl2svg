@echo off
setlocal enabledelayedexpansion

set "XFL2SVG=C:\Users\Admin\AppData\Local\Packages\PythonSoftwareFoundation.Python.3.12_qbz5n2kfra8p0\LocalCache\local-packages\Python312\Scripts\xfl2svg.exe"
set "BAT_DIR=%~dp0"
set "OUTPUT=%BAT_DIR%output"

:: ============================================================
:: DEFAULT VALUES — set value to skip prompt, leave "" to ask
:: ============================================================
:: Input folder (folder that contains LIBRARY)
set "XFL_DEFAULT=%BAT_DIR%xfl"
:: Remove background: y / n
set "DEFAULT_NO_BG=y"
:: Center content in viewport: y / n
set "DEFAULT_CENTER=y"
:: Stage width  — leave "" to keep 550
set "DEFAULT_WIDTH="
:: Stage height — leave "" to keep 400
set "DEFAULT_HEIGHT="
:: Symbol name  — leave "" to ask, enter name to skip prompt
set "DEFAULT_SYMBOL="
:: ============================================================

echo === XFL to SVG Converter ===
echo.

:: Input folder
set "XFL_ROOT=%XFL_DEFAULT%"
if not exist "%XFL_ROOT%\" (
    echo Default input folder not found: %XFL_ROOT%
    echo (Enter the folder that contains LIBRARY, or the LIBRARY folder itself)
    set /p "XFL_ROOT=Enter XFL folder path: "
)
echo Input : %XFL_ROOT%
echo Output: %OUTPUT%
echo.

:: Override stage size
set "WIDTH=%DEFAULT_WIDTH%"
set "HEIGHT=%DEFAULT_HEIGHT%"
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
set "NO_BG_IN=%DEFAULT_NO_BG%"
if "!NO_BG_IN!"=="" set /p "NO_BG_IN=Remove background? [Y/n]: "
if "!NO_BG_IN!"=="" set "NO_BG_IN=y"
set "NO_BG_ARG="
if /i "!NO_BG_IN!"=="y" set "NO_BG_ARG=--no-background"

:: Center content
set "CENTER_IN=%DEFAULT_CENTER%"
if "!CENTER_IN!"=="" set /p "CENTER_IN=Center content in viewport? [Y/n]: "
if "!CENTER_IN!"=="" set "CENTER_IN=y"
set "CENTER_ARG="
if /i "!CENTER_IN!"=="y" set "CENTER_ARG=--center"

:: Build args
set "EXTRA_ARGS=!NO_BG_ARG! !CENTER_ARG!"
set "SIZE_ARGS="
if not "!WIDTH!"=="" set "SIZE_ARGS=--width !WIDTH! --height !HEIGHT!"

:: List available symbols
echo.
echo Available symbols:
"%XFL2SVG%" "%XFL_ROOT%" "_" "." --print-symbols 2>nul
echo.

:: Symbol selection
set "SYMBOL=%DEFAULT_SYMBOL%"
if "!SYMBOL!"=="" set /p "SYMBOL=Enter symbol name (or press Enter for all): "

:: Create output folder
if not exist "%OUTPUT%\" mkdir "%OUTPUT%"

if "!SYMBOL!"=="" (
    echo Rendering all symbols...
    for /f "skip=1 tokens=*" %%s in ('"%XFL2SVG%" "%XFL_ROOT%" "_" "." --print-symbols 2^>nul') do (
        echo   %%s
        "%XFL2SVG%" "%XFL_ROOT%" "%%s" "%OUTPUT%" !SIZE_ARGS! !EXTRA_ARGS!
    )
) else (
    "%XFL2SVG%" "%XFL_ROOT%" "!SYMBOL!" "%OUTPUT%" !SIZE_ARGS! !EXTRA_ARGS!
)

echo.
echo Done! Output: %OUTPUT%
pause
