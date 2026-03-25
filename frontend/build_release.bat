@echo off
set JAVA_TOOL_OPTIONS=-Djava.net.preferIPv4Stack=true
set _JAVA_OPTIONS=-Djava.net.preferIPv4Stack=true

REM Ensure loopback adapter exists
netsh interface ipv4 set address "Loopback Pseudo-Interface 1" static 127.0.0.1 255.0.0.0 2>nul

cd /d C:\Users\Administrator\Desktop\Sanzen-app-new\frontend\android
call gradlew.bat clean 2>nul
cd /d C:\Users\Administrator\Desktop\Sanzen-app-new\frontend

REM Try with --no-daemon
call flutter build appbundle --release --no-tree-shake-icons
if %ERRORLEVEL% NEQ 0 (
    echo Flutter build failed. Trying direct Gradle...
    cd /d C:\Users\Administrator\Desktop\Sanzen-app-new\frontend\android
    call gradlew.bat bundleRelease --no-daemon -Dorg.gradle.internal.launcher.welcomeMessageEnabled=false
)

echo Build completed with code %ERRORLEVEL%
dir /s /b ..\build\app\outputs\bundle\release\*.aab 2>nul
