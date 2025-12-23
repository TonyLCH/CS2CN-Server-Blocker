# ============================================
# 完整自動化 Costura.Fody 配置與編譯
# ============================================

Write-Host "🚀 開始自動配置 Costura.Fody 並編譯單一 EXE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"
$csprojPath = "CS2CNBlocker\CS2CNBlocker.csproj"
$backupPath = "CS2CNBlocker\CS2CNBlocker.csproj.backup"

# 步驟 1: 備份專案檔
Write-Host "📋 [1/6] 備份專案檔..." -ForegroundColor Yellow
Copy-Item $csprojPath $backupPath -Force
Write-Host "✅ 備份完成: $backupPath" -ForegroundColor Green
Write-Host ""

# 步驟 2: 讀取並修改專案檔
Write-Host "📝 [2/6] 修改專案檔..." -ForegroundColor Yellow

$xml = [xml](Get-Content $csprojPath)
$namespace = @{ns = "http://schemas.microsoft.com/developer/msbuild/2003"}

# 添加 Costura.Fody Import（如果不存在）
$hasCosutraImport = $false
foreach ($import in $xml.Project.Import) {
    if ($import.Project -like "*Costura.Fody*") {
        $hasCosutraImport = $true
        break
    }
}

if (-not $hasCosutraImport) {
    # 在第一個 Import 之後添加 Costura Import
    $firstImport = $xml.Project.Import | Select-Object -First 1
    
    # 創建新的 Import 節點
    $cosuturaImport = $xml.CreateElement("Import", $xml.DocumentElement.NamespaceURI)
    $cosuturaImport.SetAttribute("Project", "..\packages\Costura.Fody.5.7.0\build\Costura.Fody.props")
    $cosuturaImport.SetAttribute("Condition", "Exists('..\packages\Costura.Fody.5.7.0\build\Costura.Fody.props')")
    
    # 插入到第一個 Import 之後
    $xml.Project.InsertAfter($cosuturaImport, $firstImport) | Out-Null
    
    Write-Host "   ✓ 添加 Costura.Fody.props Import" -ForegroundColor Green
}

# 添加 Fody.targets Import（在檔案末尾）
$hasFodyTargets = $false
foreach ($import in $xml.Project.Import) {
    if ($import.Project -like "*Fody.targets*") {
        $hasFodyTargets = $true
        break
    }
}

if (-not $hasFodyTargets) {
    # 在最後一個 Import 之後添加
    $fodyImport = $xml.CreateElement("Import", $xml.DocumentElement.NamespaceURI)
    $fodyImport.SetAttribute("Project", "..\packages\Fody.6.8.0\build\Fody.targets")
    $fodyImport.SetAttribute("Condition", "Exists('..\packages\Fody.6.8.0\build\Fody.targets')")
    
    $xml.Project.AppendChild($fodyImport) | Out-Null
    
    Write-Host "   ✓ 添加 Fody.targets Import" -ForegroundColor Green
}

# 更新 EnsureNuGetPackageBuildImports Target
$targetElement = $xml.Project.Target | Where-Object { $_.Name -eq "EnsureNuGetPackageBuildImports" }
if ($targetElement) {
    # 檢查是否已有 Fody 錯誤檢查
    $hasFodyError = $false
    foreach ($errorNode in $targetElement.Error) {
        if ($errorNode.Condition -like "*Fody.targets*") {
            $hasFodyError = $true
            break
        }
    }
    
    if (-not $hasFodyError) {
        # 添加 Fody.targets 檢查
        $errorElement1 = $xml.CreateElement("Error", $xml.DocumentElement.NamespaceURI)
        $errorElement1.SetAttribute("Condition", "!Exists('..\packages\Fody.6.8.0\build\Fody.targets')")
        $errorElement1.SetAttribute("Text", "`$([System.String]::Format('`$(ErrorText)', '..\packages\Fody.6.8.0\build\Fody.targets'))")
        $targetElement.AppendChild($errorElement1) | Out-Null
        
        # 添加 Costura.Fody.props 檢查
        $errorElement2 = $xml.CreateElement("Error", $xml.DocumentElement.NamespaceURI)
        $errorElement2.SetAttribute("Condition", "!Exists('..\packages\Costura.Fody.5.7.0\build\Costura.Fody.props')")
        $errorElement2.SetAttribute("Text", "`$([System.String]::Format('`$(ErrorText)', '..\packages\Costura.Fody.5.7.0\build\Costura.Fody.props'))")
        $targetElement.AppendChild($errorElement2) | Out-Null
        
        Write-Host "   ✓ 添加 Fody 錯誤檢查" -ForegroundColor Green
    }
}

# 儲存修改後的專案檔
$xml.Save((Resolve-Path $csprojPath).Path)
Write-Host "✅ 專案檔修改完成" -ForegroundColor Green
Write-Host ""

# 步驟 3: 確認 FodyWeavers.xml 存在
Write-Host "📝 [3/6] 檢查 FodyWeavers.xml..." -ForegroundColor Yellow
$fodyWeaversPath = "CS2CNBlocker\FodyWeavers.xml"
if (-not (Test-Path $fodyWeaversPath)) {
    Write-Host "⚠️  FodyWeavers.xml 不存在，正在建立..." -ForegroundColor Yellow
    & powershell -ExecutionPolicy Bypass -File .\Install-Costura.ps1 -SkipBuild
}
Write-Host "✅ FodyWeavers.xml 已就緒" -ForegroundColor Green
Write-Host ""

# 步驟 4: 清理並還原 NuGet
Write-Host "🧹 [4/6] 清理專案..." -ForegroundColor Yellow
msbuild CS2CNBlocker.sln /t:Clean /v:minimal /nologo
Write-Host "✅ 清理完成" -ForegroundColor Green
Write-Host ""

Write-Host "📦 [4/6] 還原 NuGet 套件..." -ForegroundColor Yellow
if (Test-Path "nuget.exe") {
    & .\nuget.exe restore CS2CNBlocker.sln
} else {
    Write-Host "⚠️  找不到 nuget.exe，跳過還原" -ForegroundColor Yellow
}
Write-Host ""

# 步驟 5: 編譯 Release 版本
Write-Host "🔨 [5/6] 編譯 Release 版本..." -ForegroundColor Yellow
Write-Host "   （編譯過程中 Fody 會自動嵌入 DLL）" -ForegroundColor Cyan
Write-Host ""

msbuild CS2CNBlocker.sln /p:Configuration=Release /v:normal /nologo

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ 編譯失敗！" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 可能的原因：" -ForegroundColor Yellow
    Write-Host "   1. Fody 套件未正確安裝" -ForegroundColor White
    Write-Host "   2. 專案檔配置有誤" -ForegroundColor White
    Write-Host ""
    Write-Host "🔧 建議操作：" -ForegroundColor Yellow
    Write-Host "   1. 還原專案檔: Copy-Item $backupPath $csprojPath -Force" -ForegroundColor White
    Write-Host "   2. 在 Visual Studio 中開啟專案" -ForegroundColor White
    Write-Host "   3. 重新載入專案並手動編譯" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "✅ 編譯成功！" -ForegroundColor Green
Write-Host ""

# 步驟 6: 檢查結果
Write-Host "🔍 [6/6] 檢查編譯結果..." -ForegroundColor Yellow

$exePath = "CS2CNBlocker\bin\Release\CS2CNBlocker.exe"
$exeFile = Get-Item $exePath
$exeSizeKB = [math]::Round($exeFile.Length / 1KB, 2)

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "✅ Costura.Fody 打包完成！" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

Write-Host "📊 檔案資訊：" -ForegroundColor Cyan
Write-Host "   位置: $exePath" -ForegroundColor White
Write-Host "   大小: $exeSizeKB KB" -ForegroundColor White
Write-Host ""

# 判斷是否成功嵌入
if ($exeSizeKB -gt 100) {
    Write-Host "🎉 成功！DLL 已嵌入 EXE 檔案中！" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 測試步驟：" -ForegroundColor Cyan
    Write-Host "   1. 建立測試資料夾" -ForegroundColor White
    Write-Host "   2. 只複製 CS2CNBlocker.exe 到測試資料夾" -ForegroundColor White
    Write-Host "   3. 執行 EXE，應該可以正常運行" -ForegroundColor White
    Write-Host ""
    
    # 詢問是否建立測試資料夾
    $response = Read-Host "是否建立測試資料夾並複製 EXE？ (Y/N)"
    if ($response -eq 'Y' -or $response -eq 'y') {
        $testDir = "Test-SingleExe"
        if (Test-Path $testDir) {
            Remove-Item $testDir -Recurse -Force
        }
        New-Item -ItemType Directory -Path $testDir | Out-Null
        Copy-Item $exePath $testDir\
        
        Write-Host "✅ 測試資料夾已建立: $testDir" -ForegroundColor Green
        Write-Host "📂 正在開啟測試資料夾..." -ForegroundColor Cyan
        Start-Sleep -Seconds 1
        Start-Process explorer.exe -ArgumentList (Resolve-Path $testDir)
        Write-Host ""
        Write-Host "🎮 請測試 EXE 是否能正常運行！" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  警告：EXE 檔案大小異常小（$exeSizeKB KB）" -ForegroundColor Yellow
    Write-Host "   DLL 可能未成功嵌入" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 請檢查編譯輸出中是否有 'Fody' 或 'Costura' 相關訊息" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "📁 輸出位置: $exePath" -ForegroundColor Cyan
Write-Host "💾 專案檔備份: $backupPath" -ForegroundColor DarkGray
Write-Host ""
