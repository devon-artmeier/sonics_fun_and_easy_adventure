@echo off

set ROM=happy.gen
set /a "PAD=1"

if not exist out mkdir out
cd src
..\bin\asm68k /m /p Main.asm, ../out/%ROM%, , ../out/listings.lst
echo.
if "%PAD%"=="1" ..\bin\rompad ../out/%ROM% 255 0
..\bin\fixheader ../out/%ROM%
echo.

pause