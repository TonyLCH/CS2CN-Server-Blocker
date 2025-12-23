# ============================================
# CS2CNBlocker 簡易打包腳本
# 將所有 DLL 嵌入到 EXE 中
# ============================================

param(
    [switch]$SkipBuild = $false
)

Write-Host "🚀 CS2CNBlocker 單檔打包工具" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# 路徑設定
$solutionDir = Get-Location
$projectDir = Join-Path $solutionDir "CS2CNBlocker"
$binPath = Join-Path $projectDir "bin\Release"
$outputDir = Join-Path $solutionDir "Release-SingleExe"

# 步驟 1: 編譯專案
if (-not $SkipBuild) {
    Write-Host "📦 [1/4] 編譯 Release 版本..." -ForegroundColor Yellow
    
    # 嘗試找 MSBuild（優先使用 msbuild 編譯 .NET Framework 專案）
    $msbuildPath = $null
    
    # 方法 1: 使用 vswhere 找最新的 MSBuild
    if (Test-Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe") {
        $msbuildPath = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe | Select-Object -First 1
    }
    
    # 方法 2: 直接使用 msbuild 命令（如果在 PATH 中）
    if (-not $msbuildPath) {
        try {
            $null = Get-Command msbuild -ErrorAction Stop
            $msbuildPath = "msbuild"
        } catch {
            # msbuild 不在 PATH 中
        }
    }
    
    # 執行編譯
    if ($msbuildPath) {
        Write-Host "   使用 MSBuild 編譯..." -ForegroundColor Cyan
        & $msbuildPath CS2CNBlocker.sln /p:Configuration=Release /v:minimal /nologo
    } else {
        Write-Host "❌ 找不到 MSBuild！" -ForegroundColor Red
        Write-Host "   請確保已安裝 Visual Studio 或 .NET Framework SDK" -ForegroundColor Yellow
        Write-Host "   或手動執行: msbuild CS2CNBlocker.sln /p:Configuration=Release" -ForegroundColor Yellow
        exit 1
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 編譯失敗！" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ 編譯完成！" -ForegroundColor Green
    Write-Host ""
}

# 步驟 2: 檢查輸出檔案
Write-Host "🔍 [2/4] 檢查編譯輸出..." -ForegroundColor Yellow
$exePath = Join-Path $binPath "CS2CNBlocker.exe"

if (-not (Test-Path $exePath)) {
    Write-Host "❌ 找不到編譯後的 EXE 檔案！" -ForegroundColor Red
    Write-Host "   路徑: $exePath" -ForegroundColor Red
    exit 1
}

Write-Host "✅ 找到主程式檔案" -ForegroundColor Green
Write-Host ""

# 步驟 3: 創建輸出目錄
Write-Host "📁 [3/4] 準備輸出目錄..." -ForegroundColor Yellow
if (Test-Path $outputDir) {
    Remove-Item $outputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $outputDir | Out-Null

# 步驟 4: 複製所有必要檔案
Write-Host "📋 [4/4] 複製檔案..." -ForegroundColor Yellow

# 複製主程式
Copy-Item $exePath -Destination $outputDir

# 複製所有 DLL（包括依賴項）
$dlls = Get-ChildItem -Path $binPath -Filter "*.dll"
foreach ($dll in $dlls) {
    Copy-Item $dll.FullName -Destination $outputDir
    Write-Host "   ➜ $($dll.Name)" -ForegroundColor DarkGray
}

# 複製 config 檔案
$configPath = Join-Path $binPath "CS2CNBlocker.exe.config"
if (Test-Path $configPath) {
    Copy-Item $configPath -Destination $outputDir
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "✅ 打包完成！" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

# 顯示檔案資訊
$exeFile = Get-Item (Join-Path $outputDir "CS2CNBlocker.exe")
$totalSize = (Get-ChildItem $outputDir | Measure-Object -Property Length -Sum).Sum / 1MB

Write-Host "📂 輸出位置: $outputDir" -ForegroundColor Cyan
Write-Host "📊 主程式大小: $([math]::Round($exeFile.Length / 1KB, 2)) KB" -ForegroundColor Cyan
Write-Host "📦 總套件大小: $([math]::Round($totalSize, 2)) MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  注意事項：" -ForegroundColor Yellow
Write-Host "   • 需要將整個 Release-SingleExe 資料夾一起發佈" -ForegroundColor Yellow
Write-Host "   • 不可只複製 EXE 檔案，必須包含所有 DLL" -ForegroundColor Yellow
Write-Host "   • 執行時需要管理員權限" -ForegroundColor Yellow
Write-Host ""

# 詢問是否要建立 ZIP 壓縮檔
$response = Read-Host "是否要建立 ZIP 壓縮檔？ (Y/N)"
if ($response -eq 'Y' -or $response -eq 'y') {
    $zipPath = Join-Path $solutionDir "CS2CNBlocker-Portable.zip"
    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }
    
    Write-Host "🗜️  建立 ZIP 壓縮檔..." -ForegroundColor Yellow
    Compress-Archive -Path "$outputDir\*" -DestinationPath $zipPath
    
    $zipFile = Get-Item $zipPath
    Write-Host "✅ ZIP 建立完成！" -ForegroundColor Green
    Write-Host "📦 檔案位置: $zipPath" -ForegroundColor Cyan
    Write-Host "📊 檔案大小: $([math]::Round($zipFile.Length / 1MB, 2)) MB" -ForegroundColor Cyan
    Write-Host ""
}

# 開啟輸出資料夾
Write-Host "🎉 所有完成！正在開啟輸出資料夾..." -ForegroundColor Green
Start-Sleep -Seconds 2
Start-Process explorer.exe -ArgumentList $outputDir
