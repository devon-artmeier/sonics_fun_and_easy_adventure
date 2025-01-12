@echo off

set ROM=happy.gen
set /a "PAD=1"

..\bin\asm68k /m /p Main.asm, %ROM%, , _LISTINGS_.lst
echo.
if "%PAD%"=="1" ..\bin\rompad %ROM% 255 0
..\bin\fixheader %ROM%
echo.

pause
exit