namespace FINAL_PROJECT_ST2.Nhanvienbanhangform
{
    partial class FormXacNhan
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

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        
        private void InitializeComponent()
        {
            this.btnChiTiet = new System.Windows.Forms.Button();
            this.btnXoa = new System.Windows.Forms.Button();
            this.lblCauHoi = new System.Windows.Forms.Label();
            this.btnHuy = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // btnChiTiet
            // 
            this.btnChiTiet.Location = new System.Drawing.Point(30, 60);
            this.btnChiTiet.Name = "btnChiTiet";
            this.btnChiTiet.Size = new System.Drawing.Size(90, 30);
            this.btnChiTiet.TabIndex = 1;
            this.btnChiTiet.Text = "Xem chi tiết";
            this.btnChiTiet.Click += new System.EventHandler(this.btnChiTiet_Click);
            // 
            // btnXoa
            // 
            this.btnXoa.Location = new System.Drawing.Point(130, 60);
            this.btnXoa.Name = "btnXoa";
            this.btnXoa.Size = new System.Drawing.Size(90, 30);
            this.btnXoa.TabIndex = 2;
            this.btnXoa.Text = "Xóa hóa đơn";
            this.btnXoa.Click += new System.EventHandler(this.btnXoa_Click);
            // 
            // lblCauHoi
            // 
            this.lblCauHoi.AutoSize = true;
            this.lblCauHoi.Location = new System.Drawing.Point(40, 20);
            this.lblCauHoi.Name = "lblCauHoi";
            this.lblCauHoi.Size = new System.Drawing.Size(186, 16);
            this.lblCauHoi.TabIndex = 0;
            this.lblCauHoi.Text = "Bạn muốn làm gì với hóa đơn?";
            // 
            // btnHuy
            // 
            this.btnHuy.Location = new System.Drawing.Point(230, 60);
            this.btnHuy.Name = "btnHuy";
            this.btnHuy.Size = new System.Drawing.Size(90, 30);
            this.btnHuy.TabIndex = 3;
            this.btnHuy.Text = "Hủy";
            this.btnHuy.Click += new System.EventHandler(this.btnHuy_Click);
            // 
            // FormXacNhan
            // 
            this.ClientSize = new System.Drawing.Size(360, 120);
            this.Controls.Add(this.lblCauHoi);
            this.Controls.Add(this.btnChiTiet);
            this.Controls.Add(this.btnXoa);
            this.Controls.Add(this.btnHuy);
            this.Name = "FormXacNhan";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Lựa chọn";
            this.Load += new System.EventHandler(this.FormXacNhan_Load_1);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button btnChiTiet;
        private System.Windows.Forms.Button btnXoa;
        private System.Windows.Forms.Label lblCauHoi;
        private System.Windows.Forms.Button btnHuy;
    }
}