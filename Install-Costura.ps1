# ============================================
# 安裝 Costura.Fody - 自動將 DLL 嵌入 EXE
# ============================================

Write-Host "🚀 安裝 Costura.Fody - DLL 嵌入工具" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$projectDir = "CS2CNBlocker"
$packagesConfigPath = Join-Path $projectDir "packages.config"
$fodyWeaversPath = Join-Path $projectDir "FodyWeavers.xml"

# 步驟 1: 下載 NuGet.exe
Write-Host "📥 [1/5] 下載 NuGet.exe..." -ForegroundColor Yellow
$nugetPath = "nuget.exe"
if (-not (Test-Path $nugetPath)) {
    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -OutFile $nugetPath
    Write-Host "✅ NuGet.exe 下載完成" -ForegroundColor Green
} else {
    Write-Host "✅ NuGet.exe 已存在" -ForegroundColor Green
}
Write-Host ""

# 步驟 2: 更新 packages.config
Write-Host "📝 [2/5] 更新 packages.config..." -ForegroundColor Yellow

$packagesXml = @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="Costura.Fody" version="5.7.0" targetFramework="net472" developmentDependency="true" />
  <package id="Fody" version="6.8.0" targetFramework="net472" developmentDependency="true" />
  <package id="Microsoft.Bcl.AsyncInterfaces" version="10.0.1" targetFramework="net472" />
  <package id="System.Buffers" version="4.6.1" targetFramework="net472" />
  <package id="System.IO.Pipelines" version="10.0.1" targetFramework="net472" />
  <package id="System.Memory" version="4.6.3" targetFramework="net472" />
  <package id="System.Numerics.Vectors" version="4.6.1" targetFramework="net472" />
  <package id="System.Runtime.CompilerServices.Unsafe" version="6.1.2" targetFramework="net472" />
  <package id="System.Text.Encodings.Web" version="10.0.1" targetFramework="net472" />
  <package id="System.Text.Json" version="10.0.1" targetFramework="net472" />
  <package id="System.Threading.Tasks.Extensions" version="4.6.3" targetFramework="net472" />
  <package id="System.ValueTuple" version="4.6.1" targetFramework="net472" />
</packages>
"@

Set-Content -Path $packagesConfigPath -Value $packagesXml -Encoding UTF8
Write-Host "✅ packages.config 更新完成" -ForegroundColor Green
Write-Host ""

# 步驟 3: 還原 NuGet 套件
Write-Host "📦 [3/5] 還原 NuGet 套件..." -ForegroundColor Yellow
& .\nuget.exe restore CS2CNBlocker.sln
Write-Host "✅ NuGet 套件還原完成" -ForegroundColor Green
Write-Host ""

# 步驟 4: 建立 FodyWeavers.xml
Write-Host "📝 [4/5] 建立 FodyWeavers.xml..." -ForegroundColor Yellow

$fodyWeaversXml = @"
<?xml version="1.0" encoding="utf-8"?>
<Weavers xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="FodyWeavers.xsd">
  <Costura>
    <!-- 嵌入所有依賴的 DLL -->
    <IncludeAssemblies>
      Microsoft.Bcl.AsyncInterfaces
      System.Buffers
      System.IO.Pipelines
      System.Memory
      System.Numerics.Vectors
      System.Runtime.CompilerServices.Unsafe
      System.Text.Encodings.Web
      System.Text.Json
      System.Threading.Tasks.Extensions
    </IncludeAssemblies>
    
    <!-- 不嵌入這些 DLL（系統 DLL） -->
    <Unmanaged32Assemblies />
    <Unmanaged64Assemblies />
    
    <!-- 移除嵌入的 DLL 資源 -->
    <CreateTemporaryAssemblies>false</CreateTemporaryAssemblies>
  </Costura>
</Weavers>
"@

Set-Content -Path $fodyWeaversPath -Value $fodyWeaversXml -Encoding UTF8
Write-Host "✅ FodyWeavers.xml 建立完成" -ForegroundColor Green
Write-Host ""

# 步驟 5: 修改專案檔
Write-Host "📝 [5/5] 檢查專案檔配置..." -ForegroundColor Yellow

$csprojPath = Join-Path $projectDir "CS2CNBlocker.csproj"
$csprojContent = Get-Content $csprojPath -Raw

if ($csprojContent -notlike "*Fody.targets*") {
    Write-Host "⚠️  需要手動添加 Fody 到專案檔" -ForegroundColor Yellow
    Write-Host "   請在專案中右鍵點擊 -> 重新載入專案" -ForegroundColor Yellow
} else {
    Write-Host "✅ 專案檔配置正確" -ForegroundColor Green
}
Write-Host ""

Write-Host "============================================" -ForegroundColor Green
Write-Host "✅ Costura.Fody 安裝完成！" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 下一步操作：" -ForegroundColor Cyan
Write-Host "   1. 在 Visual Studio 中重新載入專案" -ForegroundColor White
Write-Host "   2. 編譯 Release 版本：msbuild CS2CNBlocker.sln /p:Configuration=Release" -ForegroundColor White
Write-Host "   3. 編譯後的 EXE 會自動包含所有 DLL！" -ForegroundColor White
Write-Host ""
Write-Host "🎯 測試編譯（可選）：" -ForegroundColor Cyan
$response = Read-Host "是否立即編譯測試？ (Y/N)"
if ($response -eq 'Y' -or $response -eq 'y') {
    Write-Host ""
    Write-Host "🔨 開始編譯..." -ForegroundColor Yellow
    msbuild CS2CNBlocker.sln /p:Configuration=Release /v:minimal /nologo
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ 編譯成功！" -ForegroundColor Green
        
        $exePath = "CS2CNBlocker\bin\Release\CS2CNBlocker.exe"
        $exeSize = (Get-Item $exePath).Length / 1KB
        
        Write-Host "📊 主程式資訊：" -ForegroundColor Cyan
        Write-Host "   位置: $exePath" -ForegroundColor White
        Write-Host "   大小: $([math]::Round($exeSize, 2)) KB" -ForegroundColor White
        Write-Host ""
        Write-Host "🎉 現在 EXE 檔案已包含所有 DLL！" -ForegroundColor Green
        
        # 檢查輸出目錄
        $dllCount = (Get-ChildItem "CS2CNBlocker\bin\Release\*.dll" | Where-Object { $_.Name -notlike "System.*" }).Count
        if ($dllCount -gt 0) {
            Write-Host "⚠️  注意: bin\Release 資料夾仍有 DLL 檔案，但 EXE 可獨立運行" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ 編譯失敗，請檢查錯誤訊息" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📖 詳細說明請參考 BUILD-README.md" -ForegroundColor Cyan
