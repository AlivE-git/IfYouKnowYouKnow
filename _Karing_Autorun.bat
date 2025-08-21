@echo off
chcp 1251 >nul
setlocal enabledelayedexpansion

:: �������� �� ������ �� ����� ��������������
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ������: ������ ������ ���� ������� �� ����� ��������������.
    pause
    exit /b 1
)

:: �������� ������ � ������������
set "taskName=Karing"

:: ������� ����
:menu
cls
echo ==============================
echo  ���� ���������� ������������
echo ==============================
echo 1. �������� Karing � ����������
echo 2. ������� Karing �� �����������
echo 3. ��������� ������ Karing
echo 4. ������� ������ ������ (Nekobox/Nekoray/Throne)
echo 5. �����
echo ==============================
set /p choice="�������� �������� (1-5): "

if "%choice%"=="1" goto add_task
if "%choice%"=="2" goto delete_task
if "%choice%"=="3" goto check_task
if "%choice%"=="4" goto delete_old_tasks
:: DEBUG
if "%choice%"=="d" goto add_task
if "%choice%"=="5" exit /b 0

echo �������� �����. ������� ����� �� 1 �� 5
pause
goto menu

:: ���������� ������
:add_task
set "scriptPath=%~dp0"
set "programFile=karing.exe"

if not exist "%scriptPath%%programFile%" (
    echo ������: ���� %programFile% �� ������ � �����:
    echo %scriptPath%
    pause
    goto menu
)

:: �������� ������������� ������ ����� ���������
schtasks /query /tn "%taskName%" 2>&1 | find "��� ������" >nul
if %errorlevel% equ 0 (
    echo [i] ������ "%taskName%" ��� ����������
    pause
    goto menu
)

set "psArgument=-WindowStyle Hidden -ExecutionPolicy Bypass -Command"
set "psArgumentCommand=$wintun = Get-PnpDevice -Class Net | Where-Object { $_.FriendlyName -like '*Karing TUN*' }; if ($wintun) { pnputil /remove-device $wintun.InstanceId; }; "

:: DEBUG
if "%choice%"=="d" (
    set "psArgument=-ExecutionPolicy Bypass -Command"
    set "psArgumentCommand=$wintun = Get-PnpDevice -Class Net | Where-Object { $_.FriendlyName -like '*Karing TUN*' }; if ($wintun) { Write-Output ('������ Wintun-�������: {0}' -f $wintun.InstanceId); pnputil /remove-device $wintun.InstanceId; Write-Output 'Wintun-������� �����' } else { Write-Output 'Wintun-������� �� ������' }; Pause"
)

:: �������� XML ��� ������
echo �������� ������ ��� "%programFile%"...
(
  echo ^<?xml version="1.0" encoding="UTF-16"?^>
  echo ^<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"^>
  echo   ^<RegistrationInfo^>
  echo     ^<Description^>������ Karing ��� ����� � �������^</Description^>
  echo     ^<Author^>%username%^</Author^>
  echo   ^</RegistrationInfo^>
  echo   ^<Triggers^>
  echo     ^<LogonTrigger^>
  echo       ^<Enabled^>true^</Enabled^>
  echo       ^<UserId^>%username%^</UserId^>
  echo     ^</LogonTrigger^>
  echo   ^</Triggers^>
  echo   ^<Principals^>
  echo     ^<Principal id="Author"^>
  echo       ^<UserId^>%username%^</UserId^>
  echo       ^<LogonType^>InteractiveToken^</LogonType^>
  echo       ^<RunLevel^>HighestAvailable^</RunLevel^>
  echo     ^</Principal^>
  echo   ^</Principals^>
  echo   ^<Settings^>
  echo     ^<MultipleInstancesPolicy^>IgnoreNew^</MultipleInstancesPolicy^>
  echo     ^<DisallowStartIfOnBatteries^>false^</DisallowStartIfOnBatteries^>
  echo     ^<StopIfGoingOnBatteries^>false^</StopIfGoingOnBatteries^>
  echo     ^<AllowHardTerminate^>true^</AllowHardTerminate^>
  echo     ^<StartWhenAvailable^>true^</StartWhenAvailable^>
  echo     ^<RunOnlyIfNetworkAvailable^>false^</RunOnlyIfNetworkAvailable^>
  echo     ^<IdleSettings^>
  echo       ^<StopOnIdleEnd^>false^</StopOnIdleEnd^>
  echo       ^<RestartOnIdle^>false^</RestartOnIdle^>
  echo     ^</IdleSettings^>
  echo     ^<AllowStartOnDemand^>true^</AllowStartOnDemand^>
  echo     ^<Enabled^>true^</Enabled^>
  echo     ^<Hidden^>false^</Hidden^>
  echo     ^<RunOnlyIfIdle^>false^</RunOnlyIfIdle^>
  echo     ^<DisallowStartOnRemoteAppSession^>false^</DisallowStartOnRemoteAppSession^>
  echo     ^<UseUnifiedSchedulingEngine^>true^</UseUnifiedSchedulingEngine^>
  echo     ^<WakeToRun^>false^</WakeToRun^>
  echo     ^<ExecutionTimeLimit^>PT0S^</ExecutionTimeLimit^>
  echo     ^<Priority^>7^</Priority^>
  echo   ^</Settings^>
  echo   ^<Actions Context="Author"^>
  echo     ^<Exec^>
  echo       ^<Command^>powershell.exe^</Command^>
  echo       ^<Arguments^>%psArgument% "%psArgumentCommand%"^</Arguments^>
  echo     ^</Exec^>
  echo     ^<Exec^>
  echo       ^<Command^>%scriptPath%%programFile%^</Command^>
  echo     ^</Exec^>
  echo   ^</Actions^>
  echo ^</Task^>
) > "%scriptPath%task.xml"

schtasks /create /tn "%taskName%" /xml "%scriptPath%task.xml" /f
if %errorlevel% equ 0 (
    echo [i] ������ "%taskName%" ������� �������
) else (
    echo [i] ������ �������� ������ "%taskName%"
)
del "%scriptPath%task.xml" >nul 2>&1
pause
goto menu

:: �������� ������
:delete_task
schtasks /delete /tn "%taskName%" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [i] ������ "%taskName%" �������
) else (
    echo [i] ������ "%taskName%" �� �������
)
pause
goto menu

:: �������� ������
:check_task
schtasks /query /tn "%taskName%" 2>&1 | find "��� ������" >nul
if %errorlevel% equ 0 (
    echo [i] ������ "%taskName%" ����������
) else (
    echo [i] ������ "%taskName%" �� �������
)
pause
goto menu

:: �������� ������ �����
:delete_old_tasks
set "found="
for %%T in (Nekobox nekobox Nekoray nekoray Throne throne) do (
    if not defined found (
        schtasks /query /tn "%%T" 2>&1 | find "��� ������" >nul
        if !errorlevel! equ 0 (
            schtasks /delete /tn "%%T" /f >nul 2>&1
            if !errorlevel! equ 0 (
                echo [?] ������� ������ ������: "%%T"
                set "found=1"
            )
        )
    )
)

if not defined found (
    echo [i] ������ ������ �� �������
)
pause
goto menu