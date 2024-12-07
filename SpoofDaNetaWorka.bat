@echo off
:: Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrator privileges. Requesting elevation...
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)
 
:: Dynamically get the name of the first active network adapter
for /f "skip=1 tokens=*" %%A in ('wmic nic where NetEnabled=True get NetConnectionID') do (
    set "adapterName=%%A"
    goto :foundAdapter
)
 
:foundAdapter
:: Trim any trailing whitespace from the adapter name
for /f "tokens=* delims= " %%B in ("%adapterName%") do set "adapterName=%%B"
 
echo Detected network adapter: "%adapterName%"
 
:: Apply network settings using WMIC and Registry edits
echo Configuring adapter settings for "%adapterName%"...
 
:: Disable ARP Offload (Registry Example)
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableARP /t REG_DWORD /d 0 /f >nul 2>&1
 
:: Disable IPv4 Checksum Offload (Registry Example)
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableIPChecksum /t REG_DWORD /d 0 /f >nul 2>&1
 
:: Disable Flow Control (Example for Ethernet)
for /f "tokens=1,2*" %%A in ('wmic nicconfig where IPEnabled=true get SettingID /format:list') do (
    if /i "%%A"=="SettingID" (
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%B" /v FlowControl /t REG_DWORD /d 0 /f >nul 2>&1
    )
)
 
:: Clear ARP Cache
echo Clearing ARP cache...
arp -d
netsh interface ip delete arpcache
 
:: Refresh DNS and Reset Winsock
echo Refreshing DNS and resetting network components...
ipconfig /flushdns
ipconfig /registerdns
ipconfig /release
ipconfig /renew
netsh winsock reset
 
:: Generate and implement a random MAC address
echo Spoofing MAC Address. It is not stuck; just wait.
setlocal enabledelayedexpansion
 
FOR /F "tokens=1" %%a IN ('wmic nic where physicaladapter^=true get deviceid ^| findstr [0-9]') DO (
    CALL :MAC
    FOR %%b IN (0 00 000) DO (
        REG QUERY HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\%%b%%a >NUL 2>NUL && (
            REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\%%b%%a /v NetworkAddress /t REG_SZ /d !MAC! /f >NUL 2>NUL
        )
    )
)
 
:: Disable power saving mode for network adapters
FOR /F "tokens=1" %%a IN ('wmic nic where physicaladapter^=true get deviceid ^| findstr [0-9]') DO (
    FOR %%b IN (0 00 000) DO (
        REG QUERY HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\%%b%%a >NUL 2>NUL && (
            REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\%%b%%a /v PnPCapabilities /t REG_DWORD /d 24 /f >NUL 2>NUL
        )
    )
)
 
timeout /t 5 /nobreak >nul 2>&1
 
:: Reset NIC adapters so the new MAC address is implemented and the power saving mode is disabled
FOR /F "tokens=2 delims=, skip=2" %%a IN ('"wmic nic where (netconnectionid like '%%') get netconnectionid,netconnectionstatus /format:csv"') DO (
    netsh interface set interface name="%%a" disable >NUL 2>NUL
    netsh interface set interface name="%%a" enable >NUL 2>NUL
)
 
echo MAC Spoof Complete.
 
:: Additional Network Adapter Configurations
echo Spoofing additional adapter settings. It is not stuck; just wait.
FOR /F "tokens=1" %%a IN ('wmic nic where physicaladapter^=true get deviceid ^| findstr [0-9]') DO (
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\%%a" /v PnPCapabilities /t REG_DWORD /d 24 /f >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableTaskOffload /t REG_DWORD /d 1 /f >nul 2>&1
)
 
echo Network configurations complete.
 
:: Prompt user to hit Enter to close the command window
echo Press Enter to close this window.
pause >nul
 
:MAC
:: Generates semi-random MAC address
SET COUNT=0
SET GEN=ABCDEF0123456789
SET GEN2=26AE
SET MAC=
 
:MACLOOP
SET /a COUNT+=1
SET RND=%random%
SET /A RND=RND%%16
SET RNDGEN=!GEN:~%RND%,1!
SET /A RND2=RND%%4
SET RNDGEN2=!GEN2:~%RND2%,1!
 
IF "!COUNT!" EQU "2" (
    SET MAC=!MAC!!RNDGEN2!
) ELSE (
    SET MAC=!MAC!!RNDGEN!
)
 
IF !COUNT! LEQ 11 GOTO MACLOOP
GOTO :EOF