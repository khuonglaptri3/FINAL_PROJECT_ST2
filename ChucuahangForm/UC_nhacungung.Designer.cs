namespace FINAL_PROJECT_ST2.ChucuahangForm
{
    partial class UC_nhacungung
    {
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

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

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle7 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle8 = new System.Windows.Forms.DataGridViewCellStyle();
            System.Windows.Forms.DataGridViewCellStyle dataGridViewCellStyle9 = new System.Windows.Forms.DataGridViewCellStyle();
            this.guna2AnimateWindow1 = new Guna.UI2.WinForms.Guna2AnimateWindow(this.components);
            this.guna2Button1 = new Guna.UI2.WinForms.Guna2Button();
            this.txtSearchNCU = new Guna.UI2.WinForms.Guna2TextBox();
            this.btnSearchNCU = new Guna.UI2.WinForms.Guna2Button();
            this.dgvNhaCungUng = new Guna.UI2.WinForms.Guna2DataGridView();
            ((System.ComponentModel.ISupportInitialize)(this.dgvNhaCungUng)).BeginInit();
            this.SuspendLayout();
            // 
            // guna2Button1
            // 
            this.guna2Button1.DisabledState.BorderColor = System.Drawing.Color.DarkGray;
            this.guna2Button1.DisabledState.CustomBorderColor = System.Drawing.Color.DarkGray;
            this.guna2Button1.DisabledState.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(169)))), ((int)(((byte)(169)))), ((int)(((byte)(169)))));
            this.guna2Button1.DisabledState.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(141)))), ((int)(((byte)(141)))), ((int)(((byte)(141)))));
            this.guna2Button1.Font = new System.Drawing.Font("Microsoft YaHei UI", 16.2F, ((System.Drawing.FontStyle)((System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic))));
            this.guna2Button1.ForeColor = System.Drawing.Color.White;
            this.guna2Button1.Location = new System.Drawing.Point(1201, 547);
            this.guna2Button1.Name = "guna2Button1";
            this.guna2Button1.Size = new System.Drawing.Size(140, 42);
            this.guna2Button1.TabIndex = 15;
            this.guna2Button1.Text = "Reset";
            this.guna2Button1.Click += new System.EventHandler(this.guna2Button1_Click);
            // 
            // txtSearchNCU
            // 
            this.txtSearchNCU.Cursor = System.Windows.Forms.Cursors.IBeam;
            this.txtSearchNCU.DefaultText = "";
            this.txtSearchNCU.DisabledState.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(208)))), ((int)(((byte)(208)))), ((int)(((byte)(208)))));
            this.txtSearchNCU.DisabledState.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(226)))), ((int)(((byte)(226)))), ((int)(((byte)(226)))));
            this.txtSearchNCU.DisabledState.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(138)))), ((int)(((byte)(138)))), ((int)(((byte)(138)))));
            this.txtSearchNCU.DisabledState.PlaceholderForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(138)))), ((int)(((byte)(138)))), ((int)(((byte)(138)))));
            this.txtSearchNCU.FocusedState.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(94)))), ((int)(((byte)(148)))), ((int)(((byte)(255)))));
            this.txtSearchNCU.Font = new System.Drawing.Font("Segoe UI", 10.8F, ((System.Drawing.FontStyle)((System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic))), System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.txtSearchNCU.HoverState.BorderColor = System.Drawing.Color.FromArgb(((int)(((byte)(94)))), ((int)(((byte)(148)))), ((int)(((byte)(255)))));
            this.txtSearchNCU.Location = new System.Drawing.Point(222, 425);
            this.txtSearchNCU.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.txtSearchNCU.Name = "txtSearchNCU";
            this.txtSearchNCU.PlaceholderText = "";
            this.txtSearchNCU.SelectedText = "";
            this.txtSearchNCU.Size = new System.Drawing.Size(525, 42);
            this.txtSearchNCU.TabIndex = 14;
            this.txtSearchNCU.TextChanged += new System.EventHandler(this.searchLabel_TextChanged);
            // 
            // btnSearchNCU
            // 
            this.btnSearchNCU.DisabledState.BorderColor = System.Drawing.Color.DarkGray;
            this.btnSearchNCU.DisabledState.CustomBorderColor = System.Drawing.Color.DarkGray;
            this.btnSearchNCU.DisabledState.FillColor = System.Drawing.Color.FromArgb(((int)(((byte)(169)))), ((int)(((byte)(169)))), ((int)(((byte)(169)))));
            this.btnSearchNCU.DisabledState.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(141)))), ((int)(((byte)(141)))), ((int)(((byte)(141)))));
            this.btnSearchNCU.Font = new System.Drawing.Font("Microsoft YaHei UI", 16.2F, ((System.Drawing.FontStyle)((System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic))));
            this.btnSearchNCU.ForeColor = System.Drawing.Color.White;
            this.btnSearchNCU.Location = new System.Drawing.Point(3, 424);
            this.btnSearchNCU.Name = "btnSearchNCU";
            this.btnSearchNCU.Size = new System.Drawing.Size(188, 42);
            this.btnSearchNCU.TabIndex = 13;
            this.btnSearchNCU.Text = "Search";
            this.btnSearchNCU.Click += new System.EventHandler(this.searchBut_Click);
            // 
            // dgvNhaCungUng
            // 
            this.dgvNhaCungUng.AllowUserToResizeColumns = false;
            this.dgvNhaCungUng.AllowUserToResizeRows = false;
            dataGridViewCellStyle7.BackColor = System.Drawing.Color.White;
            this.dgvNhaCungUng.AlternatingRowsDefaultCellStyle = dataGridViewCellStyle7;
            dataGridViewCellStyle8.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle8.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(100)))), ((int)(((byte)(88)))), ((int)(((byte)(255)))));
            dataGridViewCellStyle8.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            dataGridViewCellStyle8.ForeColor = System.Drawing.Color.White;
            dataGridViewCellStyle8.SelectionBackColor = System.Drawing.SystemColors.Highlight;
            dataGridViewCellStyle8.SelectionForeColor = System.Drawing.SystemColors.HighlightText;
            dataGridViewCellStyle8.WrapMode = System.Windows.Forms.DataGridViewTriState.True;
            this.dgvNhaCungUng.ColumnHeadersDefaultCellStyle = dataGridViewCellStyle8;
            this.dgvNhaCungUng.ColumnHeadersHeight = 50;
            dataGridViewCellStyle9.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft;
            dataGridViewCellStyle9.BackColor = System.Drawing.Color.White;
            dataGridViewCellStyle9.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F);
            dataGridViewCellStyle9.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(71)))), ((int)(((byte)(69)))), ((int)(((byte)(94)))));
            dataGridViewCellStyle9.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(231)))), ((int)(((byte)(229)))), ((int)(((byte)(255)))));
            dataGridViewCellStyle9.SelectionForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(71)))), ((int)(((byte)(69)))), ((int)(((byte)(94)))));
            dataGridViewCellStyle9.WrapMode = System.Windows.Forms.DataGridViewTriState.False;
            this.dgvNhaCungUng.DefaultCellStyle = dataGridViewCellStyle9;
            this.dgvNhaCungUng.Dock = System.Windows.Forms.DockStyle.Top;
            this.dgvNhaCungUng.EditMode = System.Windows.Forms.DataGridViewEditMode.EditOnEnter;
            this.dgvNhaCungUng.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(231)))), ((int)(((byte)(229)))), ((int)(((byte)(255)))));
            this.dgvNhaCungUng.Location = new System.Drawing.Point(0, 0);
            this.dgvNhaCungUng.Name = "dgvNhaCungUng";
            this.dgvNhaCungUng.ReadOnly = true;
            this.dgvNhaCungUng.RowHeadersVisible = false;
            this.dgvNhaCungUng.RowHeadersWidth = 51;
            this.dgvNhaCungUng.RowTemplate.Height = 24;
            this.dgvNhaCungUng.Size = new System.Drawing.Size(1341, 418);
            this.dgvNhaCungUng.TabIndex = 12;
            this.dgvNhaCungUng.ThemeStyle.AlternatingRowsStyle.BackColor = System.Drawing.Color.White;
            this.dgvNhaCungUng.ThemeStyle.AlternatingRowsStyle.Font = null;
            this.dgvNhaCungUng.ThemeStyle.AlternatingRowsStyle.ForeColor = System.Drawing.Color.Empty;
            this.dgvNhaCungUng.ThemeStyle.AlternatingRowsStyle.SelectionBackColor = System.Drawing.Color.Empty;
            this.dgvNhaCungUng.ThemeStyle.AlternatingRowsStyle.SelectionForeColor = System.Drawing.Color.Empty;
            this.dgvNhaCungUng.ThemeStyle.BackColor = System.Drawing.Color.White;
            this.dgvNhaCungUng.ThemeStyle.GridColor = System.Drawing.Color.FromArgb(((int)(((byte)(231)))), ((int)(((byte)(229)))), ((int)(((byte)(255)))));
            this.dgvNhaCungUng.ThemeStyle.HeaderStyle.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(100)))), ((int)(((byte)(88)))), ((int)(((byte)(255)))));
            this.dgvNhaCungUng.ThemeStyle.HeaderStyle.BorderStyle = System.Windows.Forms.DataGridViewHeaderBorderStyle.None;
            this.dgvNhaCungUng.ThemeStyle.HeaderStyle.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.dgvNhaCungUng.ThemeStyle.HeaderStyle.ForeColor = System.Drawing.Color.White;
            this.dgvNhaCungUng.ThemeStyle.HeaderStyle.HeaightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.DisableResizing;
            this.dgvNhaCungUng.ThemeStyle.HeaderStyle.Height = 50;
            this.dgvNhaCungUng.ThemeStyle.ReadOnly = true;
            this.dgvNhaCungUng.ThemeStyle.RowsStyle.BackColor = System.Drawing.Color.White;
            this.dgvNhaCungUng.ThemeStyle.RowsStyle.BorderStyle = System.Windows.Forms.DataGridViewCellBorderStyle.SingleHorizontal;
            this.dgvNhaCungUng.ThemeStyle.RowsStyle.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.dgvNhaCungUng.ThemeStyle.RowsStyle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(71)))), ((int)(((byte)(69)))), ((int)(((byte)(94)))));
            this.dgvNhaCungUng.ThemeStyle.RowsStyle.Height = 24;
            this.dgvNhaCungUng.ThemeStyle.RowsStyle.SelectionBackColor = System.Drawing.Color.FromArgb(((int)(((byte)(231)))), ((int)(((byte)(229)))), ((int)(((byte)(255)))));
            this.dgvNhaCungUng.ThemeStyle.RowsStyle.SelectionForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(71)))), ((int)(((byte)(69)))), ((int)(((byte)(94)))));
            this.dgvNhaCungUng.CellContentClick += new System.Windows.Forms.DataGridViewCellEventHandler(this.dgvcacnhacungung_CellContentClick);
            // 
            // UC_nhacungung
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.guna2Button1);
            this.Controls.Add(this.txtSearchNCU);
            this.Controls.Add(this.btnSearchNCU);
            this.Controls.Add(this.dgvNhaCungUng);
            this.Name = "UC_nhacungung";
            this.Size = new System.Drawing.Size(1341, 589);
            ((System.ComponentModel.ISupportInitialize)(this.dgvNhaCungUng)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private Guna.UI2.WinForms.Guna2AnimateWindow guna2AnimateWindow1;
        private Guna.UI2.WinForms.Guna2Button guna2Button1;
        private Guna.UI2.WinForms.Guna2TextBox txtSearchNCU;
        private Guna.UI2.WinForms.Guna2Button btnSearchNCU;
        private Guna.UI2.WinForms.Guna2DataGridView dgvNhaCungUng;
    }
}
