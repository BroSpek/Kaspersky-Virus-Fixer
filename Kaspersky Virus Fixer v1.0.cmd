:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                                                       ::
::  Kaspersky Virus Fixer v1.0 by Abd Halim @ Angah ICT  ::
::                                                       ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
set title=Kaspersky Virus Fixer v1.0
title %title%

::########### SCRIPT GLOBAL VARIABLES #############::
set kis=kaspersky internet security 2017
set usr_start=%appdata%\Microsoft\Windows\Start Menu\Programs\Startup
set sys_start=%programdata%\Microsoft\Windows\Start Menu\Programs\Startup
set er1=A&set er2=B&set er3=C&set er4=D&set er5=E&set er6=F&set er7=G&set er8=H&set er9=I&set er10=J&set er11=K&set er12=L&set er13=M&set er14=N&set er15=O&set er16=P&set er17=Q&set er18=R&set er19=S&set er20=T&set er21=U&set er22=V&set er23=W&set er24=X&set er25=Y&set er26=Z

::################## MAIN SCRIPT ##################::
::============== Page 1 - Disclaimer ==============::
set msg=This small script will help you to remove virus that is related to:
call :header
echo. "Protected by Kaspersky Internet Security 2017".
echo.
echo. This script comes with no warranty. Use at your own risk.
echo.
choice /c ax /n /m "Press [A] to agree and continue, [X] to exit: "
if %errorlevel%==2 exit
if %errorlevel%==1 goto choose

::============= Page 2 - Choose Action ============::
:choose
set msg=Choose an option:
call :header
echo.
echo. Press [U] to fix USB drive.
echo. Press [S] to fix system.
echo. Press [P] to check for update.
echo. Press [X] to exit.
echo.
choice /c uspx /n /m " Choose: " 
if %errorlevel%==4 exit
if %errorlevel%==3 start https://github.com/BroSpek/Kaspersky-Virus-Fixer/releases
if %errorlevel%==2 call :clean_sys
if %errorlevel%==1 call :clean_usb
goto choose
exit /b %errorlevel%

::################### FUNCTIONS ###################::
:clean_usb
call :header
echo.
echo. Detected USB drive(s):
setlocal
for /f "usebackq skip=1 tokens=*" %%i in (`wmic logicaldisk where drivetype^=2 get deviceid^, volumename`) do echo: %%i
endlocal
::------
setlocal enableDelayedExpansion
choice /c ABCDEFGHIJKLMNOPQRSTUVWXYZ /n /m "Choose a USB drive to fix or press A to return: "
set root=!er%errorlevel%!
if %root% equ A goto choose
if %root% lss D set msg=ERROR: Drive letter must be between D and Z. && goto clean_usb
if %root% gtr Z set msg=ERROR: Drive letter must be between D and Z. && goto clean_usb
if exist "%root%:\" (
	echo Drive letter exist!
) else (
	set msg=ERROR: Drive letter %root%: is currently unused.
	goto clean_usb
)
set svi=%root%:\system volume information
set msg=INFO: USB drive %root%: selected.
call :header
cd /d "%svi%"
dir /A /B "%svi%" | findstr .*>NUL && attrib -h -s /d
if exist "%kis%" rd /s /q "%kis%" 2>NUL
if exist "indexervolumeguid" del "indexervolumeguid" 2>NUL
if exist "wpsettings.dat" del "wpsettings.dat" 2>NUL
for /d %%i in ("%svi%\*") do move "%%i" "%root%:\%%~nxi"
dir /A /B "%svi%" | findstr .*>NUL && move "%svi%\*.*" "%root%:\"
echo.
echo. RESULT: Done. Please check drive %root%: content.
endlocal
::------
call :final
goto choose
exit /b %errorlevel%

:clean_sys
call :header
if exist "%appdata%\%kis%" (
	cd /d "%appdata%"
	call :killtask "explorers.exe"
	call :killtask "spoolsvc.exe"
	call :killtask "spoolsvc.exe"
	rd /s /q "%kis%"
	cd /d "%usr_start%"
	call :shortcut
	cd /d "%sys_start%"
	call :shortcut
	set msg=RESULT: Done. Kaspersky Virus has been removed.
) else (
	set msg=RESULT: Done. Kaspersky Virus not found.
)
call :header
call :final
goto choose
exit /b %errorlevel%

:header
cls
echo.
echo. %title%
echo.
echo. %msg%
set "msg="
exit /b %errorlevel%

:killtask
tasklist /FI "IMAGENAME eq %*" 2>NUL | find /I /N "%*">NUL 2>NUL
if "%ERRORLEVEL%"=="0" taskkill /f /im %*
exit /b %errorlevel%

:shortcut
if exist explorers.lnk del explorers.lnk
if exist svhost.lnk del svhost.lnk
if exist spoolsvc.lnk del spoolsvc.lnk
exit /b %errorlevel%

:final
echo.
set/p<nul = Going back to main menu, press any key . . .&pause>nul