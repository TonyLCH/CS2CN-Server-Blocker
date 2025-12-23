# 🎯 DLL 打包進 EXE - 完整指南

## 三種方案比較

| 方案 | 難度 | 優點 | 缺點 | 檔案大小 |
|------|------|------|------|----------|
| **Costura.Fody** ⭐ | 中 | 自動化、穩定 | 需要配置 | ~800 KB |
| **ILMerge** | 中 | 完全合併 | 可能有相容性問題 | ~600 KB |
| **資源嵌入** | 難 | 完全控制 | 需要寫解壓代碼 | ~500 KB |

---

## 🥇 方案 1：Costura.Fody（最推薦）

### 優點
- ✅ 自動在編譯時嵌入 DLL
- ✅ 執行時自動解壓到記憶體
- ✅ 無需修改程式碼
- ✅ 支援大部分 .NET DLL

### 安裝步驟

#### 方法 A：使用自動安裝腳本（推薦）

```powershell
# 執行自動安裝腳本
powershell -ExecutionPolicy Bypass -File .\Install-Costura.ps1
```

#### 方法 B：手動安裝

**1. 在 Visual Studio 中安裝 NuGet 套件**

```
右鍵點擊專案 CS2CNBlocker
-> 管理 NuGet 套件
-> 搜尋 "Costura.Fody"
-> 安裝 Costura.Fody
-> 安裝 Fody
```

**2. 建立 FodyWeavers.xml**

在 `CS2CNBlocker\` 資料夾中建立 `FodyWeavers.xml`：

```xml
<?xml version="1.0" encoding="utf-8"?>
<Weavers xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="FodyWeavers.xsd">
  <Costura>
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
  </Costura>
</Weavers>
```

**3. 編譯專案**

```powershell
msbuild CS2CNBlocker.sln /p:Configuration=Release
```

**4. 測試**

編譯後的 `CS2CNBlocker.exe` 已經包含所有 DLL，可以單獨運行！

---

## 🥈 方案 2：ILMerge

### 使用現有的 Build-SingleExe.ps1

```powershell
# 執行 ILMerge 打包腳本
powershell -ExecutionPolicy Bypass -File .\Build-SingleExe.ps1
```

這個腳本會：
1. 下載 ILMerge 工具
2. 編譯專案
3. 合併所有 DLL 到單一 EXE
4. 輸出到 `Release-Package\CS2CNBlocker-Standalone.exe`

---

## 🥉 方案 3：手動資源嵌入

這需要修改程式碼，在程式啟動時解壓 DLL。

**不推薦**，因為 Costura.Fody 已經自動做這件事了。

---

## 📊 檔案大小比較

### 使用 Costura.Fody 前後對比

**打包前（Portable 版本）：**
```
CS2CNBlocker.exe                    26 KB
System.*.dll                     1,200 KB
總計                             1,226 KB
```

**打包後（Single EXE）：**
```
CS2CNBlocker.exe                   800 KB  ← 包含所有 DLL
總計                               800 KB
```

---

## 🎯 推薦使用流程

### 1. 安裝 Costura.Fody

```powershell
# 自動安裝
.\Install-Costura.ps1
```

### 2. 編譯專案

```powershell
msbuild CS2CNBlocker.sln /p:Configuration=Release
```

### 3. 測試單一 EXE

```powershell
# 複製 EXE 到新資料夾測試
mkdir Test
copy CS2CNBlocker\bin\Release\CS2CNBlocker.exe Test\
cd Test
.\CS2CNBlocker.exe
```

如果程式正常運行，表示所有 DLL 都已成功嵌入！

### 4. 發佈

只需要發佈單一 `CS2CNBlocker.exe` 檔案（約 800 KB）

---

## 🐛 常見問題

### Q1: Costura.Fody 安裝後編譯失敗？

**A:** 嘗試以下步驟：
1. 清理專案：`msbuild CS2CNBlocker.sln /t:Clean`
2. 還原 NuGet：`nuget restore CS2CNBlocker.sln`
3. 重新編譯：`msbuild CS2CNBlocker.sln /p:Configuration=Release`

### Q2: 編譯後 EXE 還是很小，DLL 沒嵌入？

**A:** 檢查：
1. `FodyWeavers.xml` 是否在專案根目錄
2. NuGet 套件是否正確安裝：`packages\Costura.Fody.5.7.0\`
3. 編譯輸出中是否有 "Fody/Costura" 相關訊息

### Q3: 執行時出現 "找不到 DLL" 錯誤？

**A:** 可能原因：
1. 某些 DLL 沒有在 `FodyWeavers.xml` 中列出
2. 嘗試添加 `<IncludeAssemblies />` 來嵌入所有 DLL

### Q4: ILMerge 和 Costura.Fody 哪個好？

**A:** 比較：

| 特性 | Costura.Fody | ILMerge |
|-----|--------------|---------|
| 自動化 | ✅ 編譯時自動 | ❌ 需要手動執行 |
| 穩定性 | ✅ 很好 | ⚠️ 可能有問題 |
| 檔案大小 | 800 KB | 600 KB |
| 相容性 | ✅ 很好 | ⚠️ 某些 DLL 無法合併 |

**結論：推薦使用 Costura.Fody**

---

## 📝 Costura.Fody 進階配置

### 選擇性嵌入 DLL

只嵌入特定 DLL：

```xml
<Costura>
  <IncludeAssemblies>
    System.Text.Json
    System.Memory
  </IncludeAssemblies>
</Costura>
```

### 排除特定 DLL

```xml
<Costura>
  <ExcludeAssemblies>
    System.Core
  </ExcludeAssemblies>
</Costura>
```

### 嵌入原生 DLL（x86/x64）

```xml
<Costura>
  <Unmanaged32Assemblies>
    native32.dll
  </Unmanaged32Assemblies>
  <Unmanaged64Assemblies>
    native64.dll
  </Unmanaged64Assemblies>
</Costura>
```

---

## 🚀 快速開始（TL;DR）

```powershell
# 1. 安裝 Costura.Fody
.\Install-Costura.ps1

# 2. 編譯
msbuild CS2CNBlocker.sln /p:Configuration=Release

# 3. 完成！
# 輸出：CS2CNBlocker\bin\Release\CS2CNBlocker.exe（單一檔案）
```

---

## 📚 相關連結

- [Costura.Fody GitHub](https://github.com/Fody/Costura)
- [Fody 官方文件](https://github.com/Fody/Fody)
- [ILMerge 官方文件](https://github.com/dotnet/ILMerge)

---

**最後更新：** 2025-01-23
