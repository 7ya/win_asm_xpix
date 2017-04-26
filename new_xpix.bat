@echo off
if not exist rsrc.rc goto over1
\MASM32\BIN\Rc.exe /v rsrc.rc
\MASM32\BIN\Cvtres.exe /machine:ix86 rsrc.res
:over1
if exist %1.obj del new_xpix.obj
if exist %1.exe del new_xpix.exe
\MASM32\BIN\Ml.exe /c /coff new_xpix.asm
if errorlevel 1 goto errasm
if not exist rsrc.obj goto nores
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS new_xpix.obj rsrc.obj
if errorlevel 1 goto errlink
dir new_xpix.*
goto TheEnd
:nores
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS new_xpix.obj
if errorlevel 1 goto errlink
dir new_xpix.*
goto TheEnd
:errlink
echo _
echo Link error
goto errexit
:errasm
echo _
echo Assembly Error
goto errexit
:TheEnd
new_xpix.exe
goto eeexit
:errexit
pause
:eeexit
