@echo off
setlocal EnableExtensions
chcp 65001 >nul
title Keyboard Tweaks - Fretonex
color 0B

rem ===================== CONFIG =====================
set "YT_NAME=Fretonex"
rem YT_URL = recherche YouTube, PAS un lien de chaine confirme. Remplace par l URL exacte de ta chaine.
set "YT_URL=https://www.youtube.com/results?search_query=fretonex"
set "PSF=%TEMP%\fretonex_kbd.ps1"
set "BK_KB=%~dp0backup_keyboard.reg"
set "BK_AC=%~dp0backup_accessibility.reg"
set "BK_SC=%~dp0backup_scancode_map.reg"
set "REG_KB=HKCU\Control Panel\Keyboard"
set "REG_FK=HKCU\Control Panel\Accessibility\Keyboard Response"
set "REG_SK=HKCU\Control Panel\Accessibility\StickyKeys"
set "REG_TK=HKCU\Control Panel\Accessibility\ToggleKeys"
set "REG_KL=HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout"
set "GUID_USB=2a737441-1930-4402-8d77-b2bebba308a3"
set "GUID_SUSPEND=48e6b7a6-50f5-4782-a5d4-53bb8f07e226"
rem ==================================================

call :mkps
if not exist "%BK_KB%" reg export "%REG_KB%" "%BK_KB%" /y >nul 2>&1
if not exist "%BK_AC%" reg export "HKCU\Control Panel\Accessibility" "%BK_AC%" /y >nul 2>&1

:menu
cls
echo ==========================================================
echo                    KEYBOARD TWEAKS
echo ==========================================================
echo.
echo   [1]  Filter Keys : activer sans delai + ouvrir ses reglages
echo   [2]  Clavier rapide : delai de repetition mini, vitesse maxi
echo   [3]  Couper les popups Sticky / Toggle / Filter Keys
echo   [4]  USB selective suspend OFF         - admin
echo   [5]  Desactiver la touche Windows      - admin, redemarrage
echo   [6]  Reactiver la touche Windows       - admin, redemarrage
echo   [7]  TOUT appliquer : 1 + 2 + 3 + 4
echo   [8]  Restaurer les reglages Windows par defaut
echo.
echo   [Q]  Quitter
echo.
echo ----------------------------------------------------------
echo   YouTube : %YT_NAME%        [Y] pour ouvrir
echo ----------------------------------------------------------
choice /c 12345678YQ /n /m "Ton choix : "
if errorlevel 10 goto :quit
if errorlevel 9 goto :yt
if errorlevel 8 goto :c8
if errorlevel 7 goto :c7
if errorlevel 6 goto :c6
if errorlevel 5 goto :c5
if errorlevel 4 goto :c4
if errorlevel 3 goto :c3
if errorlevel 2 goto :c2
if errorlevel 1 goto :c1
goto :menu

:c1
call :do_filter
goto :done
:c2
call :do_fast
goto :done
:c3
call :do_popups
goto :done
:c4
call :do_usb_off
goto :done
:c5
call :do_win_off
goto :done
:c6
call :do_win_on
goto :done
:c7
call :do_filter
call :do_fast
call :do_popups
call :do_usb_off
goto :done
:c8
call :do_restore
goto :done

:yt
start "" "%YT_URL%"
goto :menu

:done
echo.
echo Termine. Appuie sur une touche pour revenir au menu...
pause >nul
goto :menu

:quit
del "%PSF%" >nul 2>&1
endlocal
exit /b 0

rem ===================== ACTIONS =====================

:do_filter
echo.
echo [1] Filter Keys est integre a Windows : rien a telecharger. Activation...
reg add "%REG_FK%" /v Flags /t REG_SZ /d 3 /f >nul
reg add "%REG_FK%" /v DelayBeforeAcceptance /t REG_SZ /d 0 /f >nul
reg add "%REG_FK%" /v AutoRepeatDelay /t REG_SZ /d 250 /f >nul
reg add "%REG_FK%" /v AutoRepeatRate /t REG_SZ /d 33 /f >nul
reg add "%REG_FK%" /v BounceTime /t REG_SZ /d 0 /f >nul
call :ps filter 3 0 250 33 0
start "" ms-settings:easeofaccess-keyboard
echo     OK : Filter Keys actif, page de reglages ouverte.
exit /b 0

:do_fast
echo.
echo [2] Delai de repetition mini, vitesse maxi...
reg add "%REG_KB%" /v KeyboardDelay /t REG_SZ /d 0 /f >nul
reg add "%REG_KB%" /v KeyboardSpeed /t REG_SZ /d 31 /f >nul
call :ps delay 0
call :ps speed 31
echo     OK : KeyboardDelay=0, KeyboardSpeed=31.
exit /b 0

:do_popups
echo.
echo [3] Popups Sticky / Toggle / Filter Keys...
reg add "%REG_SK%" /v Flags /t REG_SZ /d 506 /f >nul
reg add "%REG_TK%" /v Flags /t REG_SZ /d 58 /f >nul
call :ps sticky 506
call :ps toggle 58
set "FK="
for /f "tokens=3" %%A in ('reg query "%REG_FK%" /v Flags 2^>nul') do set "FK=%%A"
if "%FK%"=="126" call :fk_hotkey_off
echo     OK : raccourcis popup coupes.
exit /b 0

:fk_hotkey_off
reg add "%REG_FK%" /v Flags /t REG_SZ /d 122 /f >nul
call :ps filter 122 1000 1000 500 0
exit /b 0

:do_usb_off
echo.
echo [4] USB selective suspend OFF...
net session >nul 2>&1
if errorlevel 1 goto :noadmin
powercfg /setacvalueindex SCHEME_CURRENT %GUID_USB% %GUID_SUSPEND% 0
powercfg /setdcvalueindex SCHEME_CURRENT %GUID_USB% %GUID_SUSPEND% 0
powercfg /setactive SCHEME_CURRENT
echo     OK : USB selective suspend desactive sur le plan actuel.
exit /b 0

:usb_on
powercfg /setacvalueindex SCHEME_CURRENT %GUID_USB% %GUID_SUSPEND% 1
powercfg /setdcvalueindex SCHEME_CURRENT %GUID_USB% %GUID_SUSPEND% 1
powercfg /setactive SCHEME_CURRENT
exit /b 0

:do_win_off
echo.
echo [5] Desactivation de la touche Windows...
net session >nul 2>&1
if errorlevel 1 goto :noadmin
if not exist "%BK_SC%" reg export "%REG_KL%" "%BK_SC%" /y >nul 2>&1
reg add "%REG_KL%" /v "Scancode Map" /t REG_BINARY /d 00000000000000000300000000005BE000005CE000000000 /f >nul
echo     OK : redemarre le PC pour que ca prenne effet.
exit /b 0

:do_win_on
echo.
echo [6] Reactivation de la touche Windows...
net session >nul 2>&1
if errorlevel 1 goto :noadmin
reg delete "%REG_KL%" /v "Scancode Map" /f >nul 2>&1
echo     OK : redemarre le PC. Si tu avais une autre remap, double-clique backup_scancode_map.reg.
exit /b 0

:do_restore
echo.
echo [8] Retour aux reglages Windows par defaut...
reg add "%REG_KB%" /v KeyboardDelay /t REG_SZ /d 1 /f >nul
reg add "%REG_KB%" /v KeyboardSpeed /t REG_SZ /d 31 /f >nul
reg add "%REG_SK%" /v Flags /t REG_SZ /d 510 /f >nul
reg add "%REG_TK%" /v Flags /t REG_SZ /d 62 /f >nul
reg add "%REG_FK%" /v Flags /t REG_SZ /d 126 /f >nul
reg add "%REG_FK%" /v DelayBeforeAcceptance /t REG_SZ /d 1000 /f >nul
reg add "%REG_FK%" /v AutoRepeatDelay /t REG_SZ /d 1000 /f >nul
reg add "%REG_FK%" /v AutoRepeatRate /t REG_SZ /d 500 /f >nul
reg add "%REG_FK%" /v BounceTime /t REG_SZ /d 0 /f >nul
call :ps delay 1
call :ps speed 31
call :ps sticky 510
call :ps toggle 62
call :ps filter 126 1000 1000 500 0
net session >nul 2>&1
if errorlevel 1 echo     Note : USB selective suspend non remis, il faut les droits admin.
if not errorlevel 1 call :usb_on
echo     OK : valeurs par defaut remises. Backups .reg a cote du .bat pour tes anciennes valeurs.
exit /b 0

:noadmin
echo     [!] Cette option demande les droits administrateur.
echo     Clic droit sur le .bat puis Executer en tant qu administrateur.
exit /b 1

rem ===================== POWERSHELL HELPER =====================

:ps
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSF%" %1 %2 %3 %4 %5 %6
exit /b 0

:mkps
>"%PSF%" echo param([string]$Mode,[int]$A=0,[int]$B=0,[int]$C=0,[int]$D=0,[int]$E=0)
>>"%PSF%" echo $sig = '[DllImport("user32.dll", SetLastError=true)] public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, uint[] pvParam, uint fWinIni);'
>>"%PSF%" echo Add-Type -MemberDefinition $sig -Name K -Namespace W
>>"%PSF%" echo switch ($Mode) {
>>"%PSF%" echo   'delay'  { [void][W.K]::SystemParametersInfo(0x17, $A, $null, 3) }
>>"%PSF%" echo   'speed'  { [void][W.K]::SystemParametersInfo(0x0B, $A, $null, 3) }
>>"%PSF%" echo   'filter' { $s = [uint32[]]@(24,$A,$B,$C,$D,$E); [void][W.K]::SystemParametersInfo(0x33, 24, $s, 3) }
>>"%PSF%" echo   'sticky' { $s = [uint32[]]@(8,$A); [void][W.K]::SystemParametersInfo(0x3B, 8, $s, 3) }
>>"%PSF%" echo   'toggle' { $s = [uint32[]]@(8,$A); [void][W.K]::SystemParametersInfo(0x35, 8, $s, 3) }
>>"%PSF%" echo }
exit /b 0