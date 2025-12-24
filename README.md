# 🛑 CS2 Server Blocker - CS2 伺服器封鎖工具

<div align="center">

![Version](https://img.shields.io/badge/version-1.0-blue)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)
![.NET Framework](https://img.shields.io/badge/.NET%20Framework-4.7.2-purple)
![License](https://img.shields.io/badge/license-MIT-green)

**一鍵封鎖可能含大量機器人的中國/香港 CS2 伺服器，優化配對與遊戲體驗**

[功能特色](#-功能特色) • [快速開始](#-快速開始) • [使用說明](#-使用說明) • [常見問題](#-常見問題)

</div>

---

## 📖 簡介

CS2 Server Blocker 是一個 Windows 桌面應用程式，專為 Counter-Strike 2 玩家設計。本工具的主要目的是幫助玩家避免被配對到含大量機器人（bots）或疑似自動化帳號的中國/香港伺服器，從而提升遊戲配對品質與整體體驗。它會自動從 Steam SDR API 獲取目標地區伺服器 IP，並透過 Windows 防火牆封鎖這些遠端 IP（出站），以降低與不想要的伺服器建立連線的機率。

> 注意：本工具以封鎖伺服器 IP 為主，無法直接識別伺服器內的玩家是否為機器人（bot）。它是基於目標節點與伺服器清單來降低連上某些地區伺服器的機會，並不能保證 100% 避免遇到機器人或其他自動化行為。

## ✨ 功能特色

- 🎯 **一鍵封鎖** - 自動獲取並封鎖指定地區（中國/香港）伺服器 IP 範圍
- 🤖 **針對性目的** - 旨在降低連上含大量機器人的伺服器的機率，優化配對品質
- 🌐 **多節點支援** - 支援封鎖 7 個中國/香港節點
- ⚡ **快速恢復** - 一鍵移除防火牆規則，恢復所有連線
- 🛡️ **安全可靠** - 僅修改防火牆規則，不會改變系統其他設定

## 📍 支援的封鎖節點

| 節點代碼 | 地區 | 說明 |
|---------|------|------|
| 🇭🇰 hkg | 香港 | Hong Kong |
| 🇨🇳 pvg | 上海浦東 | Shanghai Pudong |
| 🇨🇳 tsn | 天津 | Tianjin |
| 🇨🇳 can | 廣州 | Guangzhou (Canton) |
| 🇨🇳 sha | 上海 | Shanghai |
| 🇨🇳 hgh | 杭州 | Hangzhou |
| 🇨🇳 beij | 北京 | Beijing |

## 🚀 快速開始

### 系統需求

- ✅ Windows 7 / 8 / 10 / 11
- ✅ .NET Framework 4.7.2 或更高版本
- ✅ 管理員權限（修改防火牆需要）

### 下載安裝

#### 方式 1：下載 Release 版本（推薦）

1. 前往 [Releases](../../releases) 頁面
2. 下載最新版本的 `CS2CNBlocker.exe`
4. **以管理員身分執行** `CS2CNBlocker.exe`

#### 方式 2：從原始碼編譯

```bash
# 1. Clone 專案
git clone https://github.com/yourusername/CS2CNBlocker.git
cd CS2CNBlocker

# 2. 使用 MSBuild 編譯
msbuild CS2CNBlocker.sln /p:Configuration=Release

# 3. 執行打包腳本
powershell -ExecutionPolicy Bypass -File .\Build-Portable.ps1 -SkipBuild
```

## 📱 使用說明

### 封鎖伺服器（建議用法）

1. **以管理員身分執行** 程式
2. 點擊 **🛑 封鎖中國伺服器**（或選擇欲封鎖的節點）
3. 程式會從 Steam SDR API 取得該節點的伺服器 IP 列表，並以 Windows 防火牆建立出站封鎖規則
4. 顯示 ✅ 成功訊息後，該些遠端 IP 的出站連線會被阻擋

建議在遊戲前執行封鎖，並在配對品質仍不理想時嘗試重新封鎖或重啟遊戲以清除快取。

### 恢復連線

1. 點擊 **✅ 恢復全部連線**
2. 程式會自動移除防火牆中的 `CS_SDR_Block_Rule`（或相關規則）
3. 顯示成功訊息後即可恢復與所有伺服器的連線

### 狀態指示

| 圖示 | 狀態 | 說明 |
|-----|------|------|
| 🟢 | 就緒 | 程式已準備就緒 |
| 🔄 | 處理中 | 正在獲取伺服器資料 |
| 🔧 | 處理中 | 正在套用/移除防火牆規則 |
| ✅ | 成功 | 操作成功完成 |
| ⚠️ | 警告 | 未找到伺服器或其他警告 |
| ❌ | 錯誤 | 操作失敗 |

## 🎮 使用場景

### 適合使用的情況

- ✅ 經常被配對到高延遲或含大量機器人的中國/香港伺服器
- ✅ 想主動降低連上某些地區伺服器的機率以提升匹配體驗
- ✅ 希望在不改變遊戲設定的前提下優化連線品質

### 不建議使用的情況

- ❌ 你本身就在中國/香港地區（會封鎖離你最近的伺服器，反而降低體驗）
- ❌ 你在進行跨區或特定區域測試（會阻斷目標地區伺服器）
- ❌ 你的網路本身就有問題（請先排查本地網路）

## 🔧 技術細節

### 工作原理

1. **API 查詢** - 向 Steam SDR API 查詢 CS2 伺服器配置
2. **IP 篩選** - 從返回的 JSON 資料中篩選目標節點的 IPv4 位址
3. **防火牆規則** - 使用 `netsh` 命令建立 Windows 防火牆規則
4. **封鎖方向** - 設定為 Outbound（出站）規則，阻止連接到指定 IP

### 防火牆規則

- **規則名稱：** `CS_SDR_Block_Rule`
- **方向：** Outbound（出站）
- **動作：** Block（封鎖）
- **協定：** All
- **範圍：** 遠端 IP 位址

### 技術棧

- **語言：** C# 7.3
- **框架：** .NET Framework 4.7.2
- **UI：** Windows Forms
- **API：** System.Text.Json
- **網路：** HttpClient

## 🐛 常見問題

### Q1: 為什麼需要管理員權限？

**A:** 修改 Windows 防火牆規則需要管理員權限。請務必右鍵點擊程式，選擇「以管理員身分執行」。

### Q2: 封鎖後還是連到中國伺服器/仍遇到機器人？

**A:** 可能原因：
1. 防火牆規則未正確套用 - 重新執行程式並確認成功訊息  
2. Steam SDR 更新了伺服器 IP - 重新執行封鎖操作以取得最新清單  
3. 遊戲有快取或配對機制 - 重新啟動 CS2 或嘗試重新配對  
4. 本工具基於節點/伺服器 IP 封鎖，無法完全辨識伺服器內玩家是否為機器人

### Q3: 會影響其他遊戲嗎？

**A:** 本工具僅封鎖特定的 CS2 伺服器 IP，如果其他遊戲使用相同伺服器 IP（少見）可能受到影響。一般情況下不會影響其他遊戲或系統功能。

### Q4: 如何確認封鎖是否生效？

**A:** 可以透過以下方式確認：
1. 開啟 Windows 防火牆進階設定  
2. 查看輸出規則中是否有 `CS_SDR_Block_Rule`  
3. 或使用命令：`netsh advfirewall firewall show rule name=CS_SDR_Block_Rule`

### Q5: 程式無法啟動或出現錯誤？

**A:** 檢查清單：
- ✅ 是否以管理員身分執行
- ✅ 是否安裝 .NET Framework 4.7.2 或更高版本
- ✅ 防毒軟體是否攔截（加入白名單）
- ✅ Windows 防火牆是否啟用

### Q6: 解除封鎖後還是無法連線？

**A:** 嘗試以下步驟：
1. 確認看到「恢復成功」訊息  
2. 重新啟動 CS2  
3. 檢查 Windows 防火牆中是否還有相關規則  
4. 使用 `netsh advfirewall reset` 重置防火牆（慎用）

## ⚠️ 關於「機器人」與配對品質

- 「機器人（bot）」在此可指伺服器內大量自動化帳號、可疑行為或非人類控制的玩家，但本工具不會檢測玩家行為或帳號狀態。  
- 若你懷疑某些伺服器常出現大量機器人，封鎖這些伺服器節點可以降低與該類伺服器配對的機率，進而改善體驗。  
- 仍建議結合遊戲內回報、社群討論與官方公告來確認哪些伺服器或節點有問題。

## 📦 開發與編譯

### 編譯專案

```powershell
# 使用 MSBuild
msbuild CS2CNBlocker.sln /p:Configuration=Release

# 或使用 Visual Studio
# 選擇 Release 模式，按 Ctrl+Shift+B
```

### 打包發佈

```powershell
# 方式 1：可攜式打包（包含所有 DLL）
.\Build-Portable.ps1

# 方式 2：單檔打包（使用 ILMerge）
.\Build-SingleExe.ps1

# 方式 3：快速批次
.\Build-Package.bat
```

詳細說明請參考 [BUILD-README.md](BUILD-README.md)

## 🤝 貢獻

歡迎提交 Issue 和 Pull Request！


## 📄 授權

本專案採用 MIT 授權 - 詳見 [LICENSE](LICENSE) 檔案

## ⚠️ 免責聲明

- 本工具僅供教育和研究用途
- 作者不對使用本工具造成的任何後果負責
- 請自行評估風險並負責任地使用

---

<div align="center">

**如果這個專案對你有幫助，請給一個 ⭐️ Star！**

Made with ❤️ for CS2 Players

</div>
