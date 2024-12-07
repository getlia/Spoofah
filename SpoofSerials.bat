@echo off
:: Check if the batch file has admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This program requires administrator privileges. Requesting elevation...
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)
 
:: Proceed after gaining admin privileges
@echo off
cls
 
TITLE Spoofer %RANDOM%
 
:: Section 1: First Script (Refreshing Serials and Running AsDeviceCheck Commands)
pushd %~dp0
setlocal EnableDelayedExpansion
set "charset=ABCDEF0123456789"
set "result="
 
:: Generate a random result string
for /l %%i in (1,1,7) do (
    set /a index=!random! %% 16
    for %%j in (!index!) do (
        set "result=!result!!charset:~%%j,1!"
    )
)
set "result=!result!_"
for /l %%i in (1,1,10) do (
    set /a index=!random! %% 16
    for %%j in (!index!) do (
        set "result=!result!!charset:~%%j,1!"
    )
)
 
:: Run AsDeviceCheck commands
AsDeviceCheck /BS !result!
AsDeviceCheck /SS "Default string"
AsDeviceCheck /SU auto
AsDeviceCheck /SK "To Be Filled By O.E.M."
AsDeviceCheck /PSN "To Be Filled By O.E.M."
AsDeviceCheck /BM "Micro-Star International Co., Ltd."
AsDeviceCheck /SM "Micro-Star International Co., Ltd."
AsDeviceCheck /BV "American Megatrends International, LLC. A.BO, 10/01/2023"
AsDeviceCheck /BP "B450M MORTAR MAX (MS-7B89)"
AsDeviceCheck /SP "B450M MORTAR MAX (MS-7B89)"
AsDeviceCheck /SV "American Megatrends International, LLC. A.BO, 10/01/2023"
AsDeviceCheck /IVN "American Megatrends International, LLC."
AsDeviceCheck /IV "10/01/2023"
AsDeviceCheck /ID "10/01/2023"
 
:: Change Volume IDs
for %%A in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%A:\" (
        set newID=
        :generateID
        set /a digit1=!random! %% 10000
        set part1=0000!digit1!
        set part1=!part1:~-4!
        set /a digit2=!random! %% 10000
        set part2=0000!digit2!
        set part2=!part2:~-4!
        set newID=!part1!-!part2!
        VolumeID %%A: !newID! -nobanner /accepteula
    )
)
 
echo.
echo Refreshing Serials, Please Wait.
net stop winmgmt /y >nul 2>&1
net1 stop winmgmt /y >nul 2>&1
timeout /t 2 /nobreak >nul 2>&1
net start winmgmt /y >nul 2>&1
net1 start winmgmt /y >nul 2>&1
echo.
 

set AMIDEWIN_PATH=C:\Windows\IME\AMIDEWINx64.exe
echo Hold on (We're doing the second part)
 
"%AMIDEWIN_PATH%" /IVN %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /IV %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /SM %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /SP %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /SV %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /SS %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /SU %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /SK %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /SF %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /BM %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /BP %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /BV %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /BS %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /BT %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /BLC %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /CM %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /CV %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /CS %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /CA %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /CSK %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /PSN %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /PAT %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /PPN %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /OS 1 %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /OS 2 %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /OS 3 %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /OS 4 %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /OS 5 %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /OS 6 %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /OS 7 %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /OS 8 %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /OS 9 %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /OS 10 %RANDOM%-%RANDOM%
"%AMIDEWIN_PATH%" /OS 11 %RANDOM%-%RANDOM%
 
echo Perm Spoof Done. Restart Please (:
pause