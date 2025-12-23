using System;
using System.ComponentModel;
using System.Drawing;
using System.Windows.Forms;

namespace CS2CNBlocker
{
    public partial class Form1 : Form
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private IContainer components = null;

        // 定義 UI 元件
        private Button btnBlock;
        private Button btnUnblock;
        private Label lblStatus;
        private GroupBox groupBoxActions;
        private GroupBox groupBoxInfo;
        private ListBox listBoxNodes;
        private Label lblNodesTitle;
        private ProgressBar progressBar;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Form1));
            this.btnBlock = new System.Windows.Forms.Button();
            this.btnUnblock = new System.Windows.Forms.Button();
            this.lblStatus = new System.Windows.Forms.Label();
            this.groupBoxActions = new System.Windows.Forms.GroupBox();
            this.groupBoxInfo = new System.Windows.Forms.GroupBox();
            this.listBoxNodes = new System.Windows.Forms.ListBox();
            this.lblNodesTitle = new System.Windows.Forms.Label();
            this.progressBar = new System.Windows.Forms.ProgressBar();
            this.groupBoxActions.SuspendLayout();
            this.groupBoxInfo.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnBlock
            // 
            this.btnBlock.BackColor = System.Drawing.Color.FromArgb(244, 67, 54);
            this.btnBlock.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnBlock.FlatAppearance.BorderSize = 0;
            this.btnBlock.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(198, 40, 40);
            this.btnBlock.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(229, 57, 53);
            this.btnBlock.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnBlock.Font = new System.Drawing.Font("Microsoft JhengHei UI", 11F, System.Drawing.FontStyle.Bold);
            this.btnBlock.ForeColor = System.Drawing.Color.White;
            this.btnBlock.Location = new System.Drawing.Point(20, 30);
            this.btnBlock.Margin = new System.Windows.Forms.Padding(0);
            this.btnBlock.Name = "btnBlock";
            this.btnBlock.Size = new System.Drawing.Size(240, 55);
            this.btnBlock.TabIndex = 0;
            this.btnBlock.Text = "🛑  封鎖中國伺服器";
            this.btnBlock.UseVisualStyleBackColor = false;
            this.btnBlock.Click += new System.EventHandler(this.btnBlock_Click);
            this.btnBlock.MouseEnter += new System.EventHandler(this.btnBlock_MouseEnter);
            this.btnBlock.MouseLeave += new System.EventHandler(this.btnBlock_MouseLeave);
            // 
            // btnUnblock
            // 
            this.btnUnblock.BackColor = System.Drawing.Color.FromArgb(76, 175, 80);
            this.btnUnblock.Cursor = System.Windows.Forms.Cursors.Hand;
            this.btnUnblock.FlatAppearance.BorderSize = 0;
            this.btnUnblock.FlatAppearance.MouseDownBackColor = System.Drawing.Color.FromArgb(56, 142, 60);
            this.btnUnblock.FlatAppearance.MouseOverBackColor = System.Drawing.Color.FromArgb(67, 160, 71);
            this.btnUnblock.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnUnblock.Font = new System.Drawing.Font("Microsoft JhengHei UI", 11F, System.Drawing.FontStyle.Bold);
            this.btnUnblock.ForeColor = System.Drawing.Color.White;
            this.btnUnblock.Location = new System.Drawing.Point(20, 95);
            this.btnUnblock.Margin = new System.Windows.Forms.Padding(0);
            this.btnUnblock.Name = "btnUnblock";
            this.btnUnblock.Size = new System.Drawing.Size(240, 55);
            this.btnUnblock.TabIndex = 1;
            this.btnUnblock.Text = "✅  恢復全部連線";
            this.btnUnblock.UseVisualStyleBackColor = false;
            this.btnUnblock.Click += new System.EventHandler(this.btnUnblock_Click);
            this.btnUnblock.MouseEnter += new System.EventHandler(this.btnUnblock_MouseEnter);
            this.btnUnblock.MouseLeave += new System.EventHandler(this.btnUnblock_MouseLeave);
            // 
            // lblStatus
            // 
            this.lblStatus.BackColor = System.Drawing.Color.White;
            this.lblStatus.Font = new System.Drawing.Font("Microsoft JhengHei UI", 10F);
            this.lblStatus.ForeColor = System.Drawing.Color.FromArgb(66, 66, 66);
            this.lblStatus.Location = new System.Drawing.Point(20, 345);
            this.lblStatus.Name = "lblStatus";
            this.lblStatus.Padding = new System.Windows.Forms.Padding(15, 10, 15, 10);
            this.lblStatus.Size = new System.Drawing.Size(540, 40);
            this.lblStatus.TabIndex = 0;
            this.lblStatus.Text = "🟢  狀態：就緒";
            this.lblStatus.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // groupBoxActions
            // 
            this.groupBoxActions.BackColor = System.Drawing.Color.White;
            this.groupBoxActions.Controls.Add(this.progressBar);
            this.groupBoxActions.Controls.Add(this.btnBlock);
            this.groupBoxActions.Controls.Add(this.btnUnblock);
            this.groupBoxActions.Font = new System.Drawing.Font("Microsoft JhengHei UI", 10F, System.Drawing.FontStyle.Bold);
            this.groupBoxActions.ForeColor = System.Drawing.Color.FromArgb(33, 33, 33);
            this.groupBoxActions.Location = new System.Drawing.Point(20, 20);
            this.groupBoxActions.Name = "groupBoxActions";
            this.groupBoxActions.Padding = new System.Windows.Forms.Padding(10);
            this.groupBoxActions.Size = new System.Drawing.Size(280, 310);
            this.groupBoxActions.TabIndex = 0;
            this.groupBoxActions.TabStop = false;
            this.groupBoxActions.Text = "⚙️  控制面板";
            // 
            // groupBoxInfo
            // 
            this.groupBoxInfo.BackColor = System.Drawing.Color.White;
            this.groupBoxInfo.Controls.Add(this.lblNodesTitle);
            this.groupBoxInfo.Controls.Add(this.listBoxNodes);
            this.groupBoxInfo.Font = new System.Drawing.Font("Microsoft JhengHei UI", 10F, System.Drawing.FontStyle.Bold);
            this.groupBoxInfo.ForeColor = System.Drawing.Color.FromArgb(33, 33, 33);
            this.groupBoxInfo.Location = new System.Drawing.Point(320, 20);
            this.groupBoxInfo.Name = "groupBoxInfo";
            this.groupBoxInfo.Padding = new System.Windows.Forms.Padding(10);
            this.groupBoxInfo.Size = new System.Drawing.Size(240, 310);
            this.groupBoxInfo.TabIndex = 1;
            this.groupBoxInfo.TabStop = false;
            this.groupBoxInfo.Text = "📍  封鎖節點";
            // 
            // lblNodesTitle
            // 
            this.lblNodesTitle.Font = new System.Drawing.Font("Microsoft JhengHei UI", 9F);
            this.lblNodesTitle.ForeColor = System.Drawing.Color.FromArgb(117, 117, 117);
            this.lblNodesTitle.Location = new System.Drawing.Point(20, 30);
            this.lblNodesTitle.Name = "lblNodesTitle";
            this.lblNodesTitle.Size = new System.Drawing.Size(200, 20);
            this.lblNodesTitle.TabIndex = 0;
            this.lblNodesTitle.Text = "將封鎖以下節點的連線：";
            // 
            // listBoxNodes
            // 
            this.listBoxNodes.BackColor = System.Drawing.Color.FromArgb(250, 250, 250);
            this.listBoxNodes.BorderStyle = System.Windows.Forms.BorderStyle.None;
            this.listBoxNodes.Font = new System.Drawing.Font("Consolas", 10F);
            this.listBoxNodes.ForeColor = System.Drawing.Color.FromArgb(66, 66, 66);
            this.listBoxNodes.FormattingEnabled = true;
            this.listBoxNodes.ItemHeight = 16;
            this.listBoxNodes.Items.AddRange(new object[] {
            "🇭🇰  hkg     香港",
            "🇨🇳  pvg     上海浦東",
            "🇨🇳  tsn     天津",
            "🇨🇳  can     廣州",
            "🇨🇳  sha     上海",
            "🇨🇳  hgh     杭州",
            "🇨🇳  beij    北京"});
            this.listBoxNodes.Location = new System.Drawing.Point(20, 60);
            this.listBoxNodes.Name = "listBoxNodes";
            this.listBoxNodes.SelectionMode = System.Windows.Forms.SelectionMode.None;
            this.listBoxNodes.Size = new System.Drawing.Size(200, 224);
            this.listBoxNodes.TabIndex = 0;
            // 
            // progressBar
            // 
            this.progressBar.Location = new System.Drawing.Point(20, 270);
            this.progressBar.MarqueeAnimationSpeed = 20;
            this.progressBar.Name = "progressBar";
            this.progressBar.Size = new System.Drawing.Size(240, 6);
            this.progressBar.Style = System.Windows.Forms.ProgressBarStyle.Marquee;
            this.progressBar.TabIndex = 3;
            this.progressBar.Visible = false;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 14F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(240, 242, 245);
            this.ClientSize = new System.Drawing.Size(580, 400);
            this.Controls.Add(this.lblStatus);
            this.Controls.Add(this.groupBoxInfo);
            this.Controls.Add(this.groupBoxActions);
            this.Font = new System.Drawing.Font("Microsoft JhengHei UI", 9F);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.Name = "Form1";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "CS2 Server Blocker - 伺服器封鎖工具";
            this.groupBoxActions.ResumeLayout(false);
            this.groupBoxInfo.ResumeLayout(false);
            this.ResumeLayout(false);

        }
    }
}
