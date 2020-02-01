@ECHO OFF
SETLOCAL EnableDelayedExpansion

SET cmds[0]=rakudobrew
SET cmds[1]=p6env
FOR /L %%x in (0,1,1) DO (
    where !cmds[%%x]! >NUL 2>NUL
    IF !ERRORLEVEL! EQU 0 (
        ECHO A previous !cmds[%%x]! installation was found. rakubrew can not be used in
        ECHO parallel with other Raku version managers.
        ECHO Please remove !cmds[%%x]! before installing rakubrew.
        EXIT /B 1
    )
)

SET TMP_DIR=%TEMP%.\rakubrewtmpdir
RMDIR /Q /S "%TMP_DIR%" 2>NUL
MD "%TMP_DIR%"

ECHO Downloading rakubrew...

ECHO Dim whr: Set whr = CreateObject("WinHttp.WinHttpRequest.5.1")  >> "%TMP_DIR%\dl.vbs"
ECHO whr.Open "GET", "https://rakubrew.org/win/rakubrew.exe", False >> "%TMP_DIR%\dl.vbs"
ECHO whr.Send: Dim bs: Set bs = CreateObject("ADODB.Stream")        >> "%TMP_DIR%\dl.vbs"
ECHO bs.Type = 1: bs.Open: bs.Write whr.ResponseBody                >> "%TMP_DIR%\dl.vbs"
ECHO bs.SaveToFile "%TMP_DIR%\rakubrew.exe", 2                      >> "%TMP_DIR%\dl.vbs"
cscript /nologo "%TMP_DIR%\dl.vbs"

FOR /F "delims=" %%i IN ('"%TMP_DIR%\rakubrew.exe" home') DO SET RAKUBREW_HOME=%%i

IF EXIST "%RAKUBREW_HOME%\bin\rakubrew.exe" (
    ECHO A previous rakubrew installation was found here: %RAKUBREW_HOME%
    ECHO You should just upgrade your installation instead of installing over it!
    ECHO You can run
    ECHO     rakubrew self-upgrade
    ECHO to do so.

    RMDIR /Q /S "%TMP_DIR%"
    EXIT /B 1
)

ECHO Installing rakubrew to %RAKUBREW_HOME% ...
ECHO.

MD "%RAKUBREW_HOME%\bin" 2>NUL
MOVE "%TMP_DIR%\rakubrew.exe" "%RAKUBREW_HOME%\bin\rakubrew.exe" >NUL
RMDIR /Q /S "%TMP_DIR%"

REM Further installation instructions
"%RAKUBREW_HOME%\bin\rakubrew.exe" init
