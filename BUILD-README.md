# 📦 CS2CNBlocker 打包說明

## 🎯 三種打包方式

### 方式 1：簡易打包（推薦）✅
**檔案：** `Build-Portable.ps1`

這會建立一個包含所有檔案的可攜式版本：

```powershell
# 在 PowerShell 中執行
.\Build-Portable.ps1
```

**優點：**
- ✅ 快速簡單
- ✅ 包含所有依賴項
- ✅ 可選擇建立 ZIP 壓縮檔
- ✅ 100% 可用

**缺點：**
- ❌ 需要整個資料夾（不是單一 EXE）

---

### 方式 2：ILMerge 單檔打包
**檔案：** `Build-SingleExe.ps1`

這會將所有 DLL 合併到單一 EXE：

```powershell
# 在 PowerShell 中執行
.\Build-SingleExe.ps1
```

**優點：**
- ✅ 真正的單一 EXE 檔案
- ✅ 自動下載 ILMerge 工具

**缺點：**
- ⚠️ 可能遇到相容性問題
- ⚠️ 檔案較大

---

### 方式 3：快速批次檔
**檔案：** `Build-Package.bat`

最簡單的打包方式：

```batch
# 直接雙擊執行
Build-Package.bat
```

---

## 🚀 使用步驟

### 1. 編譯專案

```powershell
# 方法 A：使用 Visual Studio
# 在 VS 中選擇 "Release" 模式，然後按 Ctrl+Shift+B

# 方法 B：使用命令列
dotnet build CS2CNBlocker.sln -c Release
```

### 2. 執行打包腳本

```powershell
# 推薦使用
.\Build-Portable.ps1

# 或單檔版本
.\Build-SingleExe.ps1
```

### 3. 發佈

- **Portable 版本：** 將 `Release-SingleExe` 資料夾打包成 ZIP
- **Single EXE 版本：** 直接發佈 `Release-Package\CS2CNBlocker-Standalone.exe`

---

## 📋 系統需求

### 執行環境
- Windows 7/8/10/11
- .NET Framework 4.7.2 或更高版本
- 管理員權限

### 開發環境
- Visual Studio 2019/2022
- 或 .NET Framework 4.7.2 SDK
- PowerShell 5.1 或更高版本

---

## ⚙️ 進階：手動安裝 Costura.Fody

如果要使用 Costura.Fody 自動嵌入 DLL：

### 1. 使用 NuGet 套件管理器

在 Visual Studio 中：
1. 右鍵點擊 CS2CNBlocker 專案
2. 選擇「管理 NuGet 套件」
3. 搜尋並安裝：
   - `Costura.Fody`
   - `Fody`

### 2. 使用 Package Manager Console

```powershell
Install-Package Costura.Fody -Version 5.7.0
Install-Package Fody -Version 6.8.0
```

### 3. 建立 FodyWeavers.xml

在專案根目錄建立 `FodyWeavers.xml`：

```xml
<?xml version="1.0" encoding="utf-8"?>
<Weavers xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="FodyWeavers.xsd">
  <Costura>
    <IncludeAssemblies>
      System.Buffers
      System.Memory
      System.Numerics.Vectors
      System.Runtime.CompilerServices.Unsafe
      System.Text.Encodings.Web
      System.Text.Json
      System.Threading.Tasks.Extensions
      Microsoft.Bcl.AsyncInterfaces
      System.IO.Pipelines
    </IncludeAssemblies>
  </Costura>
</Weavers>
```

### 4. 重新編譯

編譯後會自動產生單一 EXE！

---

## 🐛 常見問題

### Q1: PowerShell 腳本無法執行？

```powershell
# 執行此命令啟用腳本執行
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### Q2: 找不到 MSBuild？

確保已安裝 Visual Studio 或使用：
```powershell
dotnet build CS2CNBlocker.sln -c Release
```

### Q3: ILMerge 合併失敗？

某些 .NET Framework DLL 無法合併，建議使用 Portable 版本。

### Q4: 執行時缺少 DLL？

確保：
1. 發佈時包含所有 DLL 檔案
2. 目標電腦已安裝 .NET Framework 4.7.2

---

## 📁 輸出檔案說明

### Portable 版本 (Release-SingleExe/)
```
CS2CNBlocker.exe              ← 主程式
CS2CNBlocker.exe.config       ← 設定檔
System.*.dll                  ← 系統依賴項
Microsoft.*.dll               ← 微軟依賴項
```

### Single EXE 版本 (Release-Package/)
```
CS2CNBlocker-Standalone.exe   ← 完整單檔程式
```

---

## 📝 授權與注意事項

- 本工具僅供教育和研究用途
- 需要管理員權限執行
- 修改防火牆規則前請備份設定
- 使用前請確保了解程式功能

---

## 🔗 相關資源

- [ILMerge 官方文件](https://github.com/dotnet/ILMerge)
- [Costura.Fody GitHub](https://github.com/Fody/Costura)
- [.NET Framework 下載](https://dotnet.microsoft.com/download/dotnet-framework)

---

**建立日期：** 2025-01-23  
**作者：** CS2CNBlocker Team
