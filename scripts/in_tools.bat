@echo off
chcp 65001 >nul
:: Demande automatique des privilèges Administrateur
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Demande d'élévation de privilèges administrateur...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

title Installation des Outils

echo =======================================================
echo INSTALLATION DES OUTILS
echo =======================================================
echo.

:: Installation de VSCode
echo [INFO] Installation de VSCode
winget install --id Microsoft.VisualStudioCode -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] Installation de VSCode réussie
) else (
    echo [ERROR] Installation échoué
)

echo.

:: Installation de Godot
echo [INFO] Installation de Godot
winget install --id GodotEngine.GodotEngine -e --silent --accept-source-agreements --accept-package-agreements >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] Installation de Godot réussie
) else (
    echo [ERROR] Installation de Godot échoué
)

echo.
echo =======================================================
echo INSTALLATIONS FINITS
echo =======================================================
echo.
pause