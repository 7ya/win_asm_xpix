@echo off

echo        Assembling library modules.
echo.
\masm32\bin\ml /c /coff colorstatic.asm
\masm32\bin\lib *.obj /out:colorstatic.lib

dir colorstatic.*

@echo off
pause