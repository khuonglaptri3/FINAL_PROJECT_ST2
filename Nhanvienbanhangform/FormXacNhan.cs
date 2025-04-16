using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace FINAL_PROJECT_ST2.Nhanvienbanhangform
{
    public partial class FormXacNhan : Form
    {
        public FormXacNhan()
        {
            InitializeComponent();
        }

        private void FormXacNhan_Load(object sender, EventArgs e)
        {

        }
        public enum LuaChon { Huy, ChiTiet, Xoa }

        public LuaChon LuaChonNguoiDung { get; private set; } = LuaChon.Huy;

        public FormXacNhan(int maHD)
        {
            InitializeComponent();
            lblCauHoi.Text = $"Bạn muốn làm gì với hóa đơn {maHD}?";
        }

        private void btnChiTiet_Click(object sender, EventArgs e)
        {
            LuaChonNguoiDung = LuaChon.ChiTiet;
            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        private void btnXoa_Click(object sender, EventArgs e)
        {
            LuaChonNguoiDung = LuaChon.Xoa;
            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        private void btnHuy_Click(object sender, EventArgs e)
        {
            LuaChonNguoiDung = LuaChon.Huy;
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }

        private void FormXacNhan_Load_1(object sender, EventArgs e)
        {

        }
    }
}
