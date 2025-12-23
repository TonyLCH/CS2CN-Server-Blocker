# ✅ 完成 Costura.Fody 安裝的最後步驟

Costura.Fody 已經下載，但還需要手動完成專案檔配置。

## 🎯 完成步驟

### 方法 1：使用 Visual Studio（最簡單）⭐

1. **在 Visual Studio 中開啟專案**
   ```
   開啟 CS2CNBlocker.sln
   ```

2. **卸載並重新載入專案**
   ```
   右鍵點擊 CS2CNBlocker 專案
   -> 卸載專案 (Unload Project)
   -> 右鍵點擊 CS2CNBlocker 專案
   -> 重新載入專案 (Reload Project)
   ```

3. **或直接編輯 .csproj**
   ```
   右鍵點擊 CS2CNBlocker 專案
   -> 編輯專案檔
   ```

4. **在 `<Project>` 標籤開頭添加（第一行之後）：**

```xml
<Import Project="..\packages\Costura.Fody.5.7.0\build\Costura.Fody.props" Condition="Exists('..\packages\Costura.Fody.5.7.0\build\Costura.Fody.props')" />
```

5. **在 `</Project>` 結束標籤前添加：**

```xml
  <Import Project="..\packages\Fody.6.8.0\build\Fody.targets" Condition="Exists('..\packages\Fody.6.8.0\build\Fody.targets')" />
```

6. **在 `EnsureNuGetPackageBuildImports` Target 中添加檢查：**

找到這個區塊：
```xml
  <Target Name="EnsureNuGetPackageBuildImports" BeforeTargets="PrepareForBuild">
    <PropertyGroup>
      <ErrorText>...</ErrorText>
    </PropertyGroup>
    <Error Condition="!Exists('..\packages\System.ValueTuple.4.6.1\build\net471\System.ValueTuple.targets')" Text="..." />
  </Target>
```

在最後一個 `<Error />` 後添加：
```xml
    <Error Condition="!Exists('..\packages\Fody.6.8.0\build\Fody.targets')" Text="$([System.String]::Format('$(ErrorText)', '..\packages\Fody.6.8.0\build\Fody.targets'))" />
    <Error Condition="!Exists('..\packages\Costura.Fody.5.7.0\build\Costura.Fody.props')" Text="$([System.String]::Format('$(ErrorText)', '..\packages\Costura.Fody.5.7.0\build\Costura.Fody.props'))" />
```

### 方法 2：手動編輯（進階）

請按照以下完整範例修改 `CS2CNBlocker.csproj`：

**完整的專案檔範例（關鍵部分）：**

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="15.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="..\packages\Costura.Fody.5.7.0\build\Costura.Fody.props" Condition="Exists('..\packages\Costura.Fody.5.7.0\build\Costura.Fody.props')" />
  <Import Project="$(MSBuildExtensionsPath)\$(MSBuildToolsVersion)\Microsoft.Common.props" Condition="Exists('$(MSBuildExtensionsPath)\$(MSBuildToolsVersion)\Microsoft.Common.props')" />
  
  <!-- ... 其他內容 ... -->
  
  <Import Project="$(MSBuildToolsPath)\Microsoft.CSharp.targets" />
  <Import Project="..\packages\System.ValueTuple.4.6.1\build\net471\System.ValueTuple.targets" Condition="Exists('..\packages\System.ValueTuple.4.6.1\build\net471\System.ValueTuple.targets')" />
  <Import Project="..\packages\Fody.6.8.0\build\Fody.targets" Condition="Exists('..\packages\Fody.6.8.0\build\Fody.targets')" />
  
  <Target Name="EnsureNuGetPackageBuildImports" BeforeTargets="PrepareForBuild">
    <PropertyGroup>
      <ErrorText>This project references NuGet package(s) that are missing on this computer. Use NuGet Package Restore to download them.  For more information, see http://go.microsoft.com/fwlink/?LinkID=322105. The missing file is {0}.</ErrorText>
    </PropertyGroup>
    <Error Condition="!Exists('..\packages\System.ValueTuple.4.6.1\build\net471\System.ValueTuple.targets')" Text="$([System.String]::Format('$(ErrorText)', '..\packages\System.ValueTuple.4.6.1\build\net471\System.ValueTuple.targets'))" />
    <Error Condition="!Exists('..\packages\Fody.6.8.0\build\Fody.targets')" Text="$([System.String]::Format('$(ErrorText)', '..\packages\Fody.6.8.0\build\Fody.targets'))" />
    <Error Condition="!Exists('..\packages\Costura.Fody.5.7.0\build\Costura.Fody.props')" Text="$([System.String]::Format('$(ErrorText)', '..\packages\Costura.Fody.5.7.0\build\Costura.Fody.props'))" />
  </Target>
</Project>
```

---

## 🧪 測試配置是否成功

### 1. 清理並重新編譯

```powershell
# 清理
msbuild CS2CNBlocker.sln /t:Clean

# 重新編譯
msbuild CS2CNBlocker.sln /p:Configuration=Release /v:detailed
```

### 2. 檢查編譯輸出

在編譯輸出中應該看到類似：

```
Fody: Processing CS2CNBlocker
Costura: Embedded 9 assemblies
```

### 3. 檢查 EXE 大小

```powershell
Get-Item CS2CNBlocker\bin\Release\CS2CNBlocker.exe | Select-Object Name, Length
```

**預期結果：**
- ❌ 配置前：~26 KB
- ✅ 配置後：~800 KB（包含所有 DLL）

### 4. 測試獨立運行

```powershell
# 複製 EXE 到新資料夾
New-Item -ItemType Directory -Path TestSingleExe -Force
Copy-Item CS2CNBlocker\bin\Release\CS2CNBlocker.exe TestSingleExe\

# 嘗試運行（不應該需要 DLL）
cd TestSingleExe
.\CS2CNBlocker.exe
```

如果程式能正常運行，表示配置成功！ ✅

---

## 🐛 故障排除

### 問題 1：編譯時沒有看到 "Fody: Processing" 訊息

**解決方法：**
1. 確認 `FodyWeavers.xml` 存在於 `CS2CNBlocker\` 資料夾
2. 確認專案檔中已添加 Fody Import
3. 清理並重新編譯

### 問題 2：EXE 檔案大小沒有變化

**解決方法：**
```powershell
# 1. 清理
msbuild CS2CNBlocker.sln /t:Clean

# 2. 刪除 bin 和 obj 資料夾
Remove-Item CS2CNBlocker\bin -Recurse -Force
Remove-Item CS2CNBlocker\obj -Recurse -Force

# 3. 還原 NuGet
nuget restore CS2CNBlocker.sln

# 4. 重新編譯
msbuild CS2CNBlocker.sln /p:Configuration=Release
```

### 問題 3：編譯錯誤 "Fody.targets not found"

**解決方法：**
```powershell
# 確認套件已下載
dir packages\Fody.6.8.0\build\Fody.targets

# 如果不存在，重新下載
nuget install Fody -Version 6.8.0 -OutputDirectory packages
nuget install Costura.Fody -Version 5.7.0 -OutputDirectory packages
```

---

## 📝 完整配置檢查清單

- [ ] `FodyWeavers.xml` 存在於 `CS2CNBlocker\` 資料夾
- [ ] `packages\Fody.6.8.0\` 資料夾存在
- [ ] `packages\Costura.Fody.5.7.0\` 資料夾存在
- [ ] `packages.config` 包含 Fody 和 Costura.Fody
- [ ] `.csproj` 檔案開頭有 `Costura.Fody.props` Import
- [ ] `.csproj` 檔案結尾有 `Fody.targets` Import
- [ ] `EnsureNuGetPackageBuildImports` Target 包含 Fody 檢查

---

## 🎉 成功後的結果

編譯完成後，你會得到：

```
CS2CNBlocker\bin\Release\
├── CS2CNBlocker.exe        ← ~800 KB（包含所有 DLL）
├── CS2CNBlocker.exe.config
└── *.dll                    ← 這些 DLL 只是副本，EXE 已經包含它們
```

**發佈時只需要：**
- ✅ `CS2CNBlocker.exe`（單一檔案即可運行）
- ✅ `CS2CNBlocker.exe.config`（可選，包含設定）

---

需要幫助？請參考：
- [DLL-EMBED-GUIDE.md](DLL-EMBED-GUIDE.md) - 完整指南
- [Costura.Fody 官方文件](https://github.com/Fody/Costura)
