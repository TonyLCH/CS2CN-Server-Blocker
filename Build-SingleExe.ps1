# ============================================
# CS2CNBlocker 單檔 EXE 打包腳本
# ============================================

Write-Host "🚀 開始打包 CS2CNBlocker..." -ForegroundColor Cyan

# 設定路徑
$projectDir = "CS2CNBlocker"
$binPath = Join-Path $projectDir "bin\Release"
$outputDir = "Release-Package"
$ilmergePath = "tools\ILMerge.exe"

# 檢查是否已編譯 Release 版本
if (-not (Test-Path $binPath)) {
    Write-Host "⚠️  找不到 Release 編譯檔案，正在編譯..." -ForegroundColor Yellow
    msbuild CS2CNBlocker.sln /p:Configuration=Release /v:minimal
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 編譯失敗！" -ForegroundColor Red
        exit 1
    }
}

# 創建輸出目錄
if (Test-Path $outputDir) {
    Remove-Item $outputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $outputDir | Out-Null

# 下載 ILMerge（如果不存在）
if (-not (Test-Path $ilmergePath)) {
    Write-Host "📥 下載 ILMerge 工具..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "tools" -Force | Out-Null
    
    $ilmergeNuget = "https://www.nuget.org/api/v2/package/ilmerge/3.0.41"
    $tempZip = "tools\ilmerge.zip"
    
    Invoke-WebRequest -Uri $ilmergeNuget -OutFile $tempZip
    Expand-Archive -Path $tempZip -DestinationPath "tools\ilmerge-temp" -Force
    
    Copy-Item "tools\ilmerge-temp\tools\net452\ILMerge.exe" -Destination "tools\"
    Remove-Item "tools\ilmerge-temp" -Recurse -Force
    Remove-Item $tempZip -Force
}

# 使用 ILMerge 合併所有 DLL
Write-Host "🔧 合併 DLL 到單一 EXE..." -ForegroundColor Cyan

$mainExe = Join-Path $binPath "CS2CNBlocker.exe"
$outputExe = Join-Path $outputDir "CS2CNBlocker-Standalone.exe"

# 取得所有需要合併的 DLL
$dlls = Get-ChildItem -Path $binPath -Filter "*.dll" | Where-Object { 
    $_.Name -notlike "System.*" -and 
    $_.Name -notlike "Microsoft.*.dll" -and
    $_.Name -notlike "mscorlib.dll"
} | ForEach-Object { $_.FullName }

# 建立 ILMerge 命令
$ilmergeArgs = @(
    "/out:$outputExe",
    "/target:winexe",
    "/ndebug",
    "/targetplatform:v4,C:\Windows\Microsoft.NET\Framework64\v4.0.30319",
    $mainExe
) + $dlls

Write-Host "📦 執行合併..." -ForegroundColor Yellow
& $ilmergePath $ilmergeArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 打包成功！" -ForegroundColor Green
    Write-Host ""
    Write-Host "📂 輸出位置: $outputExe" -ForegroundColor Green
    Write-Host "📊 檔案大小: $((Get-Item $outputExe).Length / 1KB) KB" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🎉 你現在可以只用單一 EXE 檔案執行程式！" -ForegroundColor Green
    
    # 開啟輸出資料夾
    Start-Process explorer.exe -ArgumentList $outputDir
} else {
    Write-Host "❌ 合併失敗！" -ForegroundColor Red
    exit 1
}
