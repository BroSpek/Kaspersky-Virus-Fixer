:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                                                         ::
::  Kaspersky Virus Fixer v1.3.1 by Abd Halim @ Angah ICT  ::
::                                                         ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@ECHO off
COLOR 09
SET title=KASPERSKY VIRUS FIXER v1.3.1
TITLE %title%

:: invoke admin
PUSHD "%CD%"
CD /d "%~dp0"
( NET file || ( POWERSHELL -command start-process '%0' -verb RUNAS -argumentlist '%* '& EXIT /b ) ) >NUL 2>NUL

::########### SCRIPT GLOBAL VARIABLES #############::
SET null=
SET kis=kaspersky internet security 2017
SET kis_bat="*Kaspersky Internet Security 2017).bat"
SET startup=Microsoft\Windows\Start Menu\Programs\Startup
SET usr_start=%APPDATA%\%startup%
SET sys_start=%PROGRAMDATA%\%startup%
SET er1=A& SET er2=B& SET er3=C& SET er4=D& SET er5=E& SET er6=F& SET er7=G& SET er8=H& SET er9=I& SET er10=J& SET er11=K& SET er12=L& SET er13=M& SET er14=N& SET er15=O& SET er16=P& SET er17=Q& SET er18=R& SET er19=S& SET er20=T& SET er21=U& SET er22=V& SET er23=W& SET er24=X& SET er25=Y& SET er26=Z

::################## MAIN SCRIPT ##################::
::============== Page 1 - Disclaimer ==============::
SET subtitle=[ %title% ]
SET msg=This small script will help you to remove virus that is related to:
CALL :header
ECHO. "Secured by Kaspersky Internet Security 2017".
ECHO. & ECHO. This script comes with no warranty. Use at your own risk.
ECHO. & CHOICE /c ax /n /m "Press [A] to agree and continue, [X] to exit: "
IF %ERRORLEVEL%==2 EXIT
IF %ERRORLEVEL%==1 GOTO choose

::============= Page 2 - Choose Action ============::
:choose
SET subtitle=[ %title% ]
SET msg=Choose an option:
CALL :header & ECHO.
ECHO. Press [U] to fix USB drive.
ECHO. Press [C] to convert USB drive File System into NTFS.
ECHO. Press [S] to fix system.
ECHO. Press [P] to check for update.
ECHO. Press [X] to exit.
ECHO. & CHOICE /c ucspx /n /m " Choose: " 
IF %ERRORLEVEL%==5 EXIT
IF %ERRORLEVEL%==4 START https://github.com/BroSpek/Kaspersky-Virus-Fixer/releases/latest
IF %ERRORLEVEL%==3 CALL :clean_sys
IF %ERRORLEVEL%==2 CALL :convert_fs
IF %ERRORLEVEL%==1 CALL :clean_usb
GOTO choose
EXIT /b %ERRORLEVEL%

::################### FUNCTIONS ###################::
:clean_usb
SET subtitle=[ FIX USB DRIVE ]
CALL :header
ECHO. & ECHO. Detected USB drive(s):
SETLOCAL
	FOR /f "usebackq skip=1 tokens=*" %%i in ( `WMIC logicaldisk WHERE drivetype^=2 GET deviceid^, volumename^, filesystem` ) do ECHO: %%i
ENDLOCAL

SETLOCAL enableDelayedExpansion
	CHOICE /c ABCDEFGHIJKLMNOPQRSTUVWXYZ /n /m "Choose a USB drive to fix or press A to return: "
	SET root=!er%ERRORLEVEL%!
	IF %root% EQU A GOTO choose
	::IF %root% LSS D SET msg=ERROR: Drive letter must be between D and Z. && GOTO clean_usb
	::IF %root% GTR Z SET msg=ERROR: Drive letter must be between D and Z. && GOTO clean_usb
	CALL :check_remv
	IF %remv%==n SET msg=ERROR: Choose a drive letter from the list. && GOTO clean_usb

	:: fixing...
	SET svi=%root%:\system volume information
	SET msg=INFO: USB drive %root%: selected.
	CALL :check_ntfs
	IF %ntfs%==y set msg=ERROR: I cannot process NTFS drive. Sorry. && GOTO clean_usb
	CALL :header
	CD /d %root%:\
	IF EXIST %kis_bat% DEL /f %kis_bat%
	CD /d "%svi%"
	DIR /A /B "%svi%" | FINDSTR .*>NUL && ATTRIB -h -s /d
	IF EXIST "%kis%" RD /s /q "%kis%" >NUL 2>NUL
	IF EXIST "indexervolumeguid" DEL "indexervolumeguid" >NUL 2>NUL
	IF EXIST "wpsettings.dat" DEL "wpsettings.dat" >NUL 2>NUL
	FOR /d %%i in ( "%svi%\*" ) do MOVE "%%i" "%root%:\%%~nxi"
	DIR /A /B "%svi%" | FINDSTR .*>NUL && MOVE "%svi%\*.*" "%root%:\"
	ECHO. & ECHO. RESULT: Done. Please check drive %root%: content.
ENDLOCAL

CALL :final
GOTO choose
EXIT /b %ERRORLEVEL%

:convert_fs
SET subtitle=[ CONVERT USB DRIVE ]
CALL :header
ECHO. & ECHO. Detected USB drive(s):
SETLOCAL
	FOR /f "usebackq skip=1 tokens=*" %%i in ( `WMIC logicaldisk WHERE drivetype^=2 GET deviceid^, volumename^, filesystem` ) do ECHO: %%i
ENDLOCAL

SETLOCAL enableDelayedExpansion
	ECHO. WARNING: Please backup your files before doing this.
	ECHO. & CHOICE /c ABCDEFGHIJKLMNOPQRSTUVWXYZ /n /m "Choose a USB drive to convert or press A to return: "
	SET root=!er%ERRORLEVEL%!
	IF %root% EQU A GOTO choose
	::IF %root% LSS D SET msg=ERROR: Drive letter must be between D and Z. && GOTO convert_fs
	::IF %root% GTR Z SET msg=ERROR: Drive letter must be between D and Z. && GOTO convert_fs
	CALL :check_remv
	IF %remv%==n SET msg=ERROR: Choose a drive letter from the list. && GOTO convert_fs

	:: converting...
	CALL :check_ntfs
	IF %ntfs%==y SET msg=ERROR: Drive %root%: is already in NTFS format. && GOTO convert_fs
	CLS
	ECHO. & ECHO. This may take a while. Please be patient.
	ECHO. & SET /p <NUL=1. Checking and fixing file system... & CHKDSK %root%: /f /x >NUL 2>NUL
	ECHO. & ECHO. & SET /p <NUL=2. Converting file system... & CONVERT %root%: /fs:ntfs >NUL 2>NUL
	WMIC logicaldisk WHERE caption="%root%:" GET filesystem | FIND "NTFS" >NUL && SET ntfs=y || SET ntfs=n
	IF %ntfs%==y ( ECHO. Done. ) ELSE ( ECHO. Ooops. Conversion failed, please try again. )
	ECHO.
ENDLOCAL

CALL :final
GOTO choose
EXIT /b %ERRORLEVEL%

:clean_sys
SET subtitle=[ FIX SYSTEM ]
CALL :header
IF EXIST "%APPDATA%\%kis%" (
	CD /d "%APPDATA%"
	CALL :killtask "explorers.exe"
	CALL :killtask "spoolsvc.exe"
	CALL :killtask "spoolsvc.exe"
	RD /s /q "%kis%"
	CD /d "%usr_start%"
	CALL :shortcut
	CD /d "%sys_start%"
	CALL :shortcut
	SET msg=RESULT: Done. Kaspersky Virus has been removed.
) ELSE (
	SET msg=RESULT: Done. Kaspersky Virus not found.
)
CALL :header
CALL :final
GOTO choose
EXIT /b %ERRORLEVEL%

:header
CLS
ECHO. & ECHO. %subtitle%
ECHO. & ECHO. %msg%
SET msg=%null%
EXIT /b %ERRORLEVEL%

:check_remv
WMIC logicaldisk WHERE caption="%root%:" GET drivetype | FIND "2">NUL && SET remv=y || SET remv=n
EXIT /b %ERRORLEVEL%

:check_ntfs
WMIC logicaldisk WHERE caption="%root%:" GET filesystem | FIND "NTFS">NUL && SET ntfs=y || SET ntfs=n
EXIT /b %ERRORLEVEL%

:killtask
TASKLIST /fi "imagename eq %*" 2>NUL | FIND /i /n "%*" >NUL 2>NUL
IF "%ERRORLEVEL%"=="0" taskkill /f /im %*
EXIT /b %ERRORLEVEL%

:shortcut
IF EXIST explorers.lnk DEL explorers.lnk
IF EXIST svhost.lnk DEL svhost.lnk
IF EXIST spoolsvc.lnk DEL spoolsvc.lnk
EXIT /b %ERRORLEVEL%

:final
ECHO. & SET /p <NUL=Going back to main menu, press any key . . . & PAUSE >NUL 2>NUL
EXIT /b %ERRORLEVEL%
