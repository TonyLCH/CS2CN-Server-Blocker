using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Net.Http;
using System.Text.Json; // 改用內建庫
using System.Threading.Tasks;
using System.Windows.Forms;

namespace CS2CNBlocker
{
    public partial class Form1 : Form
    {
        // 定義要封鎖的節點代碼
        private readonly string[] targetNodes = { "hkg", "pvg", "tsn", "can", "sha", "hgh", "beij" };
        private const string RuleName = "CS_SDR_Block_Rule";

        public Form1()
        {
            InitializeComponent();
            // 設定圓角按鈕效果
            SetButtonRoundedCorners(btnBlock, 8);
            SetButtonRoundedCorners(btnUnblock, 8);
        }

        // 創建圓角按鈕效果
        private void SetButtonRoundedCorners(Button btn, int radius)
        {
            System.Drawing.Drawing2D.GraphicsPath path = new System.Drawing.Drawing2D.GraphicsPath();
            path.StartFigure();
            path.AddArc(new Rectangle(0, 0, radius, radius), 180, 90);
            path.AddArc(new Rectangle(btn.Width - radius, 0, radius, radius), 270, 90);
            path.AddArc(new Rectangle(btn.Width - radius, btn.Height - radius, radius, radius), 0, 90);
            path.AddArc(new Rectangle(0, btn.Height - radius, radius, radius), 90, 90);
            path.CloseFigure();
            btn.Region = new System.Drawing.Region(path);
        }

        // 按鈕懸停效果
        private void btnBlock_MouseEnter(object sender, EventArgs e)
        {
            btnBlock.Font = new System.Drawing.Font("Microsoft JhengHei UI", 11.5F, System.Drawing.FontStyle.Bold);
        }

        private void btnBlock_MouseLeave(object sender, EventArgs e)
        {
            btnBlock.Font = new System.Drawing.Font("Microsoft JhengHei UI", 11F, System.Drawing.FontStyle.Bold);
        }

        private void btnUnblock_MouseEnter(object sender, EventArgs e)
        {
            btnUnblock.Font = new System.Drawing.Font("Microsoft JhengHei UI", 11.5F, System.Drawing.FontStyle.Bold);
        }

        private void btnUnblock_MouseLeave(object sender, EventArgs e)
        {
            btnUnblock.Font = new System.Drawing.Font("Microsoft JhengHei UI", 11F, System.Drawing.FontStyle.Bold);
        }

        private async void btnBlock_Click(object sender, EventArgs e)
        {
            btnBlock.Enabled = false;
            btnUnblock.Enabled = false;
            progressBar.Visible = true;
            lblStatus.Text = "🔄  正在獲取 Steam SDR 配置...";
            lblStatus.ForeColor = System.Drawing.Color.FromArgb(33, 150, 243);

            try
            {
                List<string> ips = await GetSdrIps();
                if (ips.Count > 0)
                {
                    lblStatus.Text = "🔧  正在套用防火牆規則...";
                    ApplyBlockRules(ips);
                    lblStatus.Text = $"✅  成功封鎖 {ips.Count} 個 IP 位址";
                    lblStatus.ForeColor = System.Drawing.Color.FromArgb(76, 175, 80);
                    MessageBox.Show($"已從 Steam SDR 獲取並封鎖 {ips.Count} 個伺服器 IP。\n\n封鎖節點：hkg, pvg, tsn, can, sha, hgh, beij", "封鎖完成", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                else
                {
                    lblStatus.Text = "⚠️  未偵測到指定地區的 IP";
                    lblStatus.ForeColor = System.Drawing.Color.FromArgb(255, 152, 0);
                    MessageBox.Show("未找到目標節點的 IP 位址。\n請確認網路連線正常。", "提示", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
            catch (Exception ex)
            {
                lblStatus.Text = "❌  錯誤：" + ex.Message;
                lblStatus.ForeColor = System.Drawing.Color.FromArgb(244, 67, 54);
                MessageBox.Show($"發生錯誤：\n{ex.Message}\n\n請確認以管理員身分執行。", "錯誤", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally 
            { 
                btnBlock.Enabled = true;
                btnUnblock.Enabled = true;
                progressBar.Visible = false;
            }
        }

        private void btnUnblock_Click(object sender, EventArgs e)
        {
            try
            {
                btnBlock.Enabled = false;
                btnUnblock.Enabled = false;
                progressBar.Visible = true;
                lblStatus.Text = "🔧  正在刪除防火牆規則...";
                lblStatus.ForeColor = System.Drawing.Color.FromArgb(33, 150, 243);
                
                RunNetsh($"advfirewall firewall delete rule name=\"{RuleName}\"");
                
                lblStatus.Text = "✅  已解除封鎖，恢復連線";
                lblStatus.ForeColor = System.Drawing.Color.FromArgb(76, 175, 80);
                MessageBox.Show("已成功刪除防火牆規則。\n現在可以連接到所有 CS2 伺服器。", "恢復完成", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                lblStatus.Text = "❌  恢復失敗：" + ex.Message;
                lblStatus.ForeColor = System.Drawing.Color.FromArgb(244, 67, 54);
                MessageBox.Show($"恢復失敗：\n{ex.Message}\n\n請確認以管理員身分執行。", "錯誤", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                btnBlock.Enabled = true;
                btnUnblock.Enabled = true;
                progressBar.Visible = false;
            }
        }

        private async Task<List<string>> GetSdrIps()
        {
            using (HttpClient client = new HttpClient())
            {
                // 獲取 API 資料
                byte[] data = await client.GetByteArrayAsync("https://api.steampowered.com/ISteamApps/GetSDRConfig/v1/?appid=730");

                // 使用 JsonDocument 解析 (無需定義複雜的 Class)
                using (JsonDocument doc = JsonDocument.Parse(data))
                {
                    List<string> ipList = new List<string>();
                    JsonElement root = doc.RootElement;

                    if (root.TryGetProperty("pops", out JsonElement pops))
                    {
                        foreach (JsonProperty pop in pops.EnumerateObject())
                        {
                            string popId = pop.Name.ToLower();
                            // 檢查是否為目標區域
                            if (targetNodes.Contains(popId))
                            {
                                if (pop.Value.TryGetProperty("relays", out JsonElement relays))
                                {
                                    foreach (JsonElement relay in relays.EnumerateArray())
                                    {
                                        if (relay.TryGetProperty("ipv4", out JsonElement ipv4))
                                        {
                                            ipList.Add(ipv4.GetString());
                                        }
                                    }
                                }
                            }
                        }
                    }
                    return ipList.Distinct().ToList();
                }
            }
        }

        private void ApplyBlockRules(List<string> ips)
        {
            string ipCsv = string.Join(",", ips);
            // 1. 先清除舊規則
            RunNetsh($"advfirewall firewall delete rule name=\"{RuleName}\"");
            // 2. 新增封鎖規則 (Outbound)
            RunNetsh($"advfirewall firewall add rule name=\"{RuleName}\" dir=out action=block remoteip={ipCsv} enable=yes");
        }

        private void RunNetsh(string args)
        {
            ProcessStartInfo psi = new ProcessStartInfo("netsh", args)
            {
                CreateNoWindow = true,
                UseShellExecute = false,
                WindowStyle = ProcessWindowStyle.Hidden,
                Verb = "runas" // 要求管理員權限
            };
            Process.Start(psi)?.WaitForExit();
        }
    }
}