@echo off
:: ============================================================================
::  Advanced Windows Network Troubleshooting Toolkit
::  Windows 10 / 11 endpoint network diagnostics
::  Author: Frank Chisom Emmanuel
::
::  Read-only options (1-7, 9) make no changes to the system.
::  Option 8 resets the network stack and asks for confirmation first.
::  Run as Administrator for full output.
:: ============================================================================
setlocal EnableExtensions EnableDelayedExpansion
title Network Troubleshooting Toolkit

set "TARGET=8.8.8.8"
set "DNSNAME=www.microsoft.com"
set "LOGDIR=%USERPROFILE%\Desktop\NetDiag"

net session >nul 2>&1
if errorlevel 1 (set "ADMIN=No") else (set "ADMIN=Yes")

:menu
cls
echo ==============================================================
echo   Network Troubleshooting Toolkit      Admin: %ADMIN%
echo   Host: %COMPUTERNAME%   User: %USERNAME%
echo ==============================================================
echo   1. Adapter and IP configuration
echo   2. Connectivity test (gateway, internet, DNS)
echo   3. DNS diagnostics
echo   4. Route and path trace
echo   5. Wi-Fi diagnostics
echo   6. Proxy and firewall status
echo   7. Listening ports and active connections
echo   8. Repair: reset network stack (makes changes)
echo   9. Full report to file
echo   0. Exit
echo ==============================================================
set "CHOICE="
set /p "CHOICE=Select an option: "

if "%CHOICE%"=="1" (call :adapters & pause & goto menu)
if "%CHOICE%"=="2" (call :connectivity & pause & goto menu)
if "%CHOICE%"=="3" (call :dns & pause & goto menu)
if "%CHOICE%"=="4" (call :route & pause & goto menu)
if "%CHOICE%"=="5" (call :wifi & pause & goto menu)
if "%CHOICE%"=="6" (call :proxyfw & pause & goto menu)
if "%CHOICE%"=="7" (call :ports & pause & goto menu)
if "%CHOICE%"=="8" (call :repair & pause & goto menu)
if "%CHOICE%"=="9" (call :report & pause & goto menu)
if "%CHOICE%"=="0" goto end
goto menu

:: ---------------------------------------------------------------------------
:adapters
echo.
echo [ Adapter and IP configuration ]
ipconfig /all
echo.
echo [ Adapter link state ]
netsh interface show interface
exit /b

:: ---------------------------------------------------------------------------
:connectivity
echo.
echo [ Connectivity test ]
set "GW="
for /f "tokens=3" %%G in ('route print -4 0.0.0.0 ^| findstr /r /c:"^ *0\.0\.0\.0"') do (
    if not defined GW set "GW=%%G"
)
if not defined GW (
    echo   Default gateway : NOT FOUND - check adapter, cable or DHCP
    exit /b
)
echo   Default gateway : %GW%

ping -n 2 -w 1500 %GW% >nul
if errorlevel 1 (echo   Gateway reachable  : FAIL - local network problem) else (echo   Gateway reachable  : OK)

ping -n 2 -w 1500 %TARGET% >nul
if errorlevel 1 (echo   Internet by IP     : FAIL - upstream or firewall problem) else (echo   Internet by IP     : OK)

nslookup %DNSNAME% >nul 2>&1
if errorlevel 1 (echo   DNS resolution     : FAIL - DNS problem) else (echo   DNS resolution     : OK)

ping -n 2 -w 1500 %DNSNAME% >nul
if errorlevel 1 (echo   Internet by name   : FAIL) else (echo   Internet by name   : OK)
echo.
echo   Reading the result:
echo     Gateway FAIL                  = adapter, cable, Wi-Fi or VLAN
echo     Gateway OK, IP FAIL           = router, ISP or firewall
echo     IP OK, DNS FAIL               = DNS server or DNS filtering
echo     All OK but browsing fails     = proxy, PAC or certificate issue (option 6)
exit /b

:: ---------------------------------------------------------------------------
:dns
echo.
echo [ Configured DNS servers ]
netsh interface ip show dnsservers
echo.
echo [ Resolution test: %DNSNAME% ]
nslookup %DNSNAME%
echo.
echo [ Resolution against public resolver 1.1.1.1 ]
nslookup %DNSNAME% 1.1.1.1
echo.
echo [ Hosts file entries ]
findstr /v /b /c:"#" "%SystemRoot%\System32\drivers\etc\hosts" | findstr /r /v "^$"
echo.
echo [ DNS client cache: first 40 lines ]
powershell -NoProfile -Command "ipconfig /displaydns | Select-Object -First 40"
exit /b

:: ---------------------------------------------------------------------------
:route
echo.
echo [ IPv4 routing table ]
route print -4
echo.
echo [ Path to %TARGET% ]
tracert -d -h 15 -w 1000 %TARGET%
echo.
echo [ ARP cache ]
arp -a
exit /b

:: ---------------------------------------------------------------------------
:wifi
echo.
echo [ Wi-Fi interface ]
netsh wlan show interfaces
echo.
echo [ Saved profiles ]
netsh wlan show profiles
echo.
echo [ Driver ]
netsh wlan show drivers | findstr /i "Driver Vendor Version Date Radio"
echo.
echo   Tip: repeated disconnects are often power management.
echo   Device Manager, adapter Properties, Power Management, untick
echo   "Allow the computer to turn off this device to save power".
exit /b

:: ---------------------------------------------------------------------------
:proxyfw
echo.
echo [ WinHTTP proxy ]
netsh winhttp show proxy
echo.
echo [ User proxy settings ]
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable 2>nul
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer 2>nul
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL 2>nul
echo.
echo   An unexpected ProxyServer or AutoConfigURL is a security finding,
echo   not only a connectivity fault. Escalate before removing it.
echo.
echo [ Firewall profiles ]
netsh advfirewall show allprofiles state
exit /b

:: ---------------------------------------------------------------------------
:ports
echo.
echo [ Listening TCP ports ]
netstat -ano -p tcp | findstr /i "LISTENING"
echo.
echo [ Established connections ]
netstat -ano -p tcp | findstr /i "ESTABLISHED"
echo.
echo   Match the PID in the last column with: tasklist /fi "PID eq <pid>"
exit /b

:: ---------------------------------------------------------------------------
:repair
echo.
echo [ Repair: reset network stack ]
if /i not "%ADMIN%"=="Yes" (
    echo   This option needs an elevated prompt. Right-click, Run as administrator.
    exit /b
)
echo   This will flush DNS, release and renew DHCP, and reset Winsock and TCP/IP.
echo   Static IP settings may be lost. A restart is required afterwards.
set "CONFIRM="
set /p "CONFIRM=Type YES to continue: "
if /i not "%CONFIRM%"=="YES" (
    echo   Cancelled. No changes made.
    exit /b
)
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
ipconfig /all > "%LOGDIR%\pre-reset-ipconfig.txt"
echo   Saved current configuration to %LOGDIR%\pre-reset-ipconfig.txt
ipconfig /flushdns
ipconfig /release
ipconfig /renew
netsh winsock reset
netsh int ip reset
echo.
echo   Done. Restart the computer to complete the reset.
exit /b

:: ---------------------------------------------------------------------------
:report
if not exist "%LOGDIR%" mkdir "%LOGDIR%"
for /f %%T in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set "STAMP=%%T"
set "OUT=%LOGDIR%\netdiag-%COMPUTERNAME%-%STAMP%.txt"
echo   Writing report, this takes about a minute...
(
    echo Network diagnostic report
    echo Host: %COMPUTERNAME%   User: %USERNAME%   Admin: %ADMIN%
    echo Generated: %DATE% %TIME%
    echo ==============================================================
    call :adapters
    call :connectivity
    call :dns
    call :route
    call :wifi
    call :proxyfw
    call :ports
) > "%OUT%" 2>&1
echo   Report saved: %OUT%
exit /b

:end
endlocal
exit /b 0
