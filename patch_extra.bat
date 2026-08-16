@echo off
setlocal EnableDelayedExpansion

set ROM=ssb64asm_extra.z64
set LOG=output.log
set ASM=%~dp0smashremix\assembler

echo. > "%ROM%"
echo Building "%ROM%"...

"%ASM%\bass.exe" -o "%ROM%" main.asm -sym logfile.log > "%LOG%" 2>&1

if %ERRORLEVEL% neq 0 (
    echo BUILD FAILED
    echo.
    echo ==== Last 10 lines of %LOG% ====

    for /f %%A in ('find /c /v "" ^< "%LOG%"') do set TOTAL=%%A
    set /a SKIP=!TOTAL!-10
    if !SKIP! LSS 0 set SKIP=0

    if !SKIP! GTR 0 (
        more +!SKIP! "%LOG%"
    ) else (
        type "%LOG%"
    )
    exit /b 1
)

echo BUILD SUCCESS

"%ASM%\rn64crc.exe" -u "%ROM%" >> "%LOG%" 2>&1
if errorlevel 1 (
    echo CRC UPDATE FAILED
    type "%LOG%"
    exit /b 1
)

echo Build log exported to "%LOG%"
exit /b 0
