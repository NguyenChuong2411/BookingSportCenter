@echo off
setlocal

REM Resolve adb path (use env var or default SDK path)
set "ADB_EXE="
if defined ANDROID_SDK_ROOT if exist "%ANDROID_SDK_ROOT%\platform-tools\adb.exe" set "ADB_EXE=%ANDROID_SDK_ROOT%\platform-tools\adb.exe"
if not defined ADB_EXE if defined ANDROID_HOME if exist "%ANDROID_HOME%\platform-tools\adb.exe" set "ADB_EXE=%ANDROID_HOME%\platform-tools\adb.exe"
if not defined ADB_EXE if exist "%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools\adb.exe" set "ADB_EXE=%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools\adb.exe"

REM Start AuthService
start "AuthService" powershell -NoExit -Command "cd %~dp0backend_api\AuthService; dotnet run --urls http://0.0.0.0:5236"

REM Start BookingSport
start "BookingSport" powershell -NoExit -Command "cd %~dp0backend_api\BookingSport; dotnet run --urls http://0.0.0.0:5253"

REM Setup adb reverse for physical Android device
if defined ADB_EXE (
	"%ADB_EXE%" reverse tcp:5236 tcp:5236
	"%ADB_EXE%" reverse tcp:5253 tcp:5253
) else (
	echo adb.exe not found. Please install Android SDK Platform-Tools or add adb to PATH.
)

REM Run Flutter app (use localhost for adb reverse)
start "Flutter" powershell -NoExit -Command "cd %~dp0app_mobile; flutter run --dart-define=API_HOST=http://127.0.0.1"

endlocal
