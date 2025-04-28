using FINAL_PROJECT_ST2.ChucuahangForm;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace FINAL_PROJECT_ST2.Nhanvienbanhangform
{
    public partial class Nhanvienbanhang: Form
    {
        DatabaseHelper connect; 
        public Nhanvienbanhang()
        {
            connect = new DatabaseHelper();
            InitializeComponent();
            hienthithongtinnhanvien();
        }
        public void hienthithongtinnhanvien()
        {
            string thongTin = DatabaseHelper.GetThongTinDangNhap(connect.Username, connect.Password);

            if (!thongTin.Contains("không hợp lệ"))
            {
                lblWelcome.Text = "👋 Xin chào: " + thongTin.Split('-')[0].Trim();
                lblRole.Text = "🔐 Vai trò: " + thongTin.Split('-')[1].Trim();
            }
            else
            {
                MessageBox.Show("❌ " + thongTin, "Lỗi đăng nhập", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }

        }


        private void Nhanvienbanhang_Load(object sender, EventArgs e)
        {

        }

        private void label1_Click(object sender, EventArgs e)
        {
           Application.Exit(); 
        }

        private void panel1_Paint(object sender, PaintEventArgs e)
        {

        }

        private void guna2DataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void guna2Panel1_Paint(object sender, PaintEventArgs e)
        {

        }

        private void button_newcourse_Click(object sender, EventArgs e)
        { try
            {
                guna2Panel1.Controls.Clear(); // Xóa control cũ
                Uc_ThemKhachHang uc = new Uc_ThemKhachHang();
                uc.Dock = DockStyle.Fill;
                guna2Panel1.Controls.Add(uc); // Thêm UC vào panel
            }
            catch (Exception ex)
            {
                MessageBox.Show(" Ban khong co quyen de truy cap  ");
            }
        }

        private void guna2Panel1_Paint_1(object sender, PaintEventArgs e)
        {


        }

        private void button_managecourse_Click(object sender, EventArgs e)

        {
            try
            {
                guna2Panel1.Controls.Clear();
                TimkiemkhachhangForm uc = new TimkiemkhachhangForm();
                uc.Dock = DockStyle.Fill;
                guna2Panel1.Controls.Add(uc);
            }
            catch (Exception ex)
            {
                MessageBox.Show(" Ban khong co quyen de truy cap  " + ex.Message);

            }
        }

        private void button_newscore_Click(object sender, EventArgs e)
        {
            try
            {
                guna2Panel1.Controls.Clear();
                Uc_TaoHoaDon uc_TaoHoaDon = new Uc_TaoHoaDon();
                uc_TaoHoaDon.Dock = DockStyle.Fill;
                guna2Panel1.Controls.Add(uc_TaoHoaDon);
            }
            catch (Exception ex)
            {
                MessageBox.Show(" Ban khong co quyen de truy cap  " + ex.Message);
            }   
        }

        private void button_printsore_Click(object sender, EventArgs e)
        {
            try
            {
                guna2Panel1.Controls.Clear();
                Uchoadondaban uc = new Uchoadondaban();
                uc.Dock = DockStyle.Fill;
                guna2Panel1.Controls.Add(uc);
            }
            catch (Exception ex)
            {
                MessageBox.Show(" Ban khong co quyen de truy cap  " + ex.Message);
            }
        }

        private void button3_Click(object sender, EventArgs e)
        {
            try
            {
                guna2Panel1.Controls.Clear();
                Themsanpham uc = new Themsanpham();
                uc.Dock = DockStyle.Fill;
                guna2Panel1.Controls.Add(uc);
            }
            catch (Exception ex)
            {
                MessageBox.Show(" Ban khong co quyen de truy cap  " + ex.Message);

            }
        }

        private void button6_Click(object sender, EventArgs e)
        {
            try
            {
                guna2Panel1.Controls.Clear();
                Themtaomoiphieunhap uc = new Themtaomoiphieunhap();
                uc.Dock = DockStyle.Fill;
                guna2Panel1.Controls.Add(uc);
            }
            catch (Exception ex)
            {
                MessageBox.Show(" Ban khong co quyen de truy cap  " + ex.Message);
            }
        }

        private void button5_Click(object sender, EventArgs e)
        {
            try
            {
                guna2Panel1.Controls.Clear();
                Uc_chitietnhap uc = new Uc_chitietnhap();
                uc.Dock = DockStyle.Fill;
                guna2Panel1.Controls.Add(uc);
            }
            catch (Exception ex)
            {
                MessageBox.Show(" Ban khong co quyen de truy cap  " + ex.Message);

            }
        }

        private void button4_Click(object sender, EventArgs e)
        {
            try
            {
                guna2Panel1.Controls.Clear();
                Uc_Danhsachphieunhap uc_Danhsachphieunhap = new Uc_Danhsachphieunhap();
                uc_Danhsachphieunhap.Dock = DockStyle.Fill;
                guna2Panel1.Controls.Add(uc_Danhsachphieunhap);
            }
            catch (Exception ex)
            {
                MessageBox.Show(" Ban khong co quyen de truy cap  " + ex.Message);

            }
        }

        private void panel_slide_Paint(object sender, PaintEventArgs e)
        {

        }

        private void button2_Click(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {

        }

        private void Panel_subscore_Paint(object sender, PaintEventArgs e)
        {

        }

        private void button_score_Click(object sender, EventArgs e)
        {

        }

        private void panel_subcourse_Paint(object sender, PaintEventArgs e)
        {

        }

        private void button_course_Click(object sender, EventArgs e)
        {

        }

        private void panel3_Paint(object sender, PaintEventArgs e)
        {

        }

        private void label3_Click(object sender, EventArgs e)
        {

        }

        private void label4_Click(object sender, EventArgs e)
        {
            try
            {
                this.Hide();
                chucuahangform chucuahangform = new chucuahangform();
                chucuahangform.Show();
            }
            catch (Exception ex)
            {
                MessageBox.Show(" Ban khong co quyen de truy cap  " );

            }
        }
    }
}
