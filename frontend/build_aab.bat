@echo off
set JAVA_TOOL_OPTIONS=-Djava.net.preferIPv4Stack=true
set _JAVA_OPTIONS=-Djava.net.preferIPv4Stack=true
cd /d C:\Users\Administrator\Desktop\Sanzen-app-new\frontend
call flutter build appbundle --release
echo BUILD DONE with exit code %ERRORLEVEL%
pause
