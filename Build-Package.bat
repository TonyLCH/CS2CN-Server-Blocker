@echo off
echo ============================================
echo CS2CNBlocker 快速打包工具
echo ============================================
echo.

REM 編譯 Release 版本
echo [1/3] 正在編譯 Release 版本...
dotnet build CS2CNBlocker\CS2CNBlocker.csproj -c Release

if %errorlevel% neq 0 (
    echo 編譯失敗！
    pause
    exit /b 1
)

REM 創建發佈資料夾
echo [2/3] 創建發佈資料夾...
if exist "Release-Package" rmdir /s /q "Release-Package"
mkdir "Release-Package"

REM 複製檔案
echo [3/3] 複製檔案...
xcopy "CS2CNBlocker\bin\Release\*.*" "Release-Package\" /s /y

echo.
echo ============================================
echo 打包完成！
echo ============================================
echo.
echo 輸出位置: Release-Package\
echo 主程式: CS2CNBlocker.exe
echo.
echo 注意: 需要將整個資料夾一起發佈（包含所有 DLL）
echo.

start explorer.exe "Release-Package"
pause
