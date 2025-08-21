@echo off
chcp 1251 >nul
setlocal enabledelayedexpansion

:: Проверка на запуск от имени администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Ошибка: Скрипт должен быть запущен от имени администратора.
    pause
    exit /b 1
)

:: Название задачи в планировщике
set "taskName=Karing"

:: Главное меню
:menu
cls
echo ==============================
echo  Меню управления автозапуском
echo ==============================
echo 1. Добавить Karing в автозапуск
echo 2. Удалить Karing из автозапуска
echo 3. Проверить задачу Karing
echo 4. Удалить старую задачу (Nekobox/Nekoray/Throne)
echo 5. Выход
echo ==============================
set /p choice="Выберите действие (1-5): "

if "%choice%"=="1" goto add_task
if "%choice%"=="2" goto delete_task
if "%choice%"=="3" goto check_task
if "%choice%"=="4" goto delete_old_tasks
:: DEBUG
if "%choice%"=="d" goto add_task
if "%choice%"=="5" exit /b 0

echo Неверный выбор. Введите цифру от 1 до 5
pause
goto menu

:: Добавление задачи
:add_task
set "scriptPath=%~dp0"
set "programFile=karing.exe"

if not exist "%scriptPath%%programFile%" (
    echo Ошибка: Файл %programFile% не найден в папке:
    echo %scriptPath%
    pause
    goto menu
)

:: Проверка существования задачи перед созданием
schtasks /query /tn "%taskName%" 2>&1 | find "Имя задачи" >nul
if %errorlevel% equ 0 (
    echo [i] Задача "%taskName%" уже существует
    pause
    goto menu
)

set "psArgument=-WindowStyle Hidden -ExecutionPolicy Bypass -Command"
set "psArgumentCommand=$wintun = Get-PnpDevice -Class Net | Where-Object { $_.FriendlyName -like '*Karing TUN*' }; if ($wintun) { pnputil /remove-device $wintun.InstanceId; }; "

:: DEBUG
if "%choice%"=="d" (
    set "psArgument=-ExecutionPolicy Bypass -Command"
    set "psArgumentCommand=$wintun = Get-PnpDevice -Class Net | Where-Object { $_.FriendlyName -like '*Karing TUN*' }; if ($wintun) { Write-Output ('Найден Wintun-адаптер: {0}' -f $wintun.InstanceId); pnputil /remove-device $wintun.InstanceId; Write-Output 'Wintun-адаптер удалён' } else { Write-Output 'Wintun-адаптер не найден' }; Pause"
)

:: Создание XML для задачи
echo Создание задачи для "%programFile%"...
(
  echo ^<?xml version="1.0" encoding="UTF-16"?^>
  echo ^<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"^>
  echo   ^<RegistrationInfo^>
  echo     ^<Description^>Запуск Karing при входе в систему^</Description^>
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
    echo [i] Задача "%taskName%" успешно создана
) else (
    echo [i] Ошибка создания задачи "%taskName%"
)
del "%scriptPath%task.xml" >nul 2>&1
pause
goto menu

:: Удаление задачи
:delete_task
schtasks /delete /tn "%taskName%" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [i] Задача "%taskName%" удалена
) else (
    echo [i] Задача "%taskName%" не найдена
)
pause
goto menu

:: Проверка задачи
:check_task
schtasks /query /tn "%taskName%" 2>&1 | find "Имя задачи" >nul
if %errorlevel% equ 0 (
    echo [i] Задача "%taskName%" существует
) else (
    echo [i] Задача "%taskName%" не найдена
)
pause
goto menu

:: Удаление старых задач
:delete_old_tasks
set "found="
for %%T in (Nekobox nekobox Nekoray nekoray Throne throne) do (
    if not defined found (
        schtasks /query /tn "%%T" 2>&1 | find "Имя задачи" >nul
        if !errorlevel! equ 0 (
            schtasks /delete /tn "%%T" /f >nul 2>&1
            if !errorlevel! equ 0 (
                echo [?] Удалена старая задача: "%%T"
                set "found=1"
            )
        )
    )
)

if not defined found (
    echo [i] Старые задачи не найдены
)
pause
goto menu