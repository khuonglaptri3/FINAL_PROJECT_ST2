using FINAL_PROJECT_ST2.Nhanvienbanhangform;
using Guna.UI2.WinForms;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Windows.Forms.DataVisualization.Charting;

namespace FINAL_PROJECT_ST2.ChucuahangForm
{
    public partial class chucuahangform : Form
    {
        DatabaseHelper connect;  
        public chucuahangform()
        {
            InitializeComponent();
            connect = new DatabaseHelper();  
            pnlDoanhThu.BackColor = Color.LightGreen;
            pnlHoaDon.BackColor = Color.LightSkyBlue;
            panel9.BackColor = Color.LightGray;
            LoadDashboardTongQuan();
            LoadTopBanChayVaoGrid(); // Tải dữ liệu top bán chạy vào DataGridView   
            LoadSanPhamSapHet();
            LoadPieChartTyLeDoanhThu();
            LoadSanPhamBanCham();

        }
        private void LoadDashboardTongQuan()
        {
            try
            {
                // 💰 Doanh thu hôm nay
                decimal doanhThu = connect.ExecuteScalar<decimal>("SELECT dbo.fn_DoanhThuHomNay()");
                lblDoanhThu.Text = $"💰 Doanh thu hôm nay: {doanhThu:N0} VNĐ";

                // 🧾 Số hóa đơn hôm nay
                int soHoaDon = connect.ExecuteScalar<int>("SELECT dbo.fn_SoHoaDonHomNay()");
                lblHoaDon.Text = $"🧾 Số hóa đơn hôm nay: {soHoaDon}";

                // 👥 Tổng khách hàng
                int tongKH = connect.ExecuteScalar<int>("SELECT dbo.fn_TongSoKhachHang()");
                lblKhachHang.Text = $"👥 Tổng khách hàng: {tongKH}";
                int spSapHet = connect.ExecuteScalar<int>("SELECT dbo.fn_SoLuongSanPhamSapHetHang()");
                lblSoLuongSapHet.Text = $"📦 SL sản phẩm sắp hết hàng: {spSapHet}";

            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi tải dữ liệu tổng quan: " + ex.Message);
            }
        }
        private void LoadTopBanChayVaoGrid()
        {
            try
            {
                DataTable dt = connect.ExecuteQuery("SELECT * FROM vw_Top3SanPhamBanChay");

                dgvTopBanChay.DataSource = dt;

                // Tuỳ chỉnh hiển thị cho đẹp hơn
                dgvTopBanChay.Columns["TenSP"].HeaderText = "Tên sản phẩm";
                dgvTopBanChay.Columns["SoLuongBan"].HeaderText = "Số lượng bán";

                dgvTopBanChay.Columns["TenSP"].Width = 200;
                dgvTopBanChay.Columns["SoLuongBan"].Width = 120;

                dgvTopBanChay.ReadOnly = true;
                dgvTopBanChay.AllowUserToAddRows = false;
                dgvTopBanChay.AllowUserToDeleteRows = false;
                dgvTopBanChay.RowHeadersVisible = false;
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi khi tải dữ liệu top bán chạy: " + ex.Message);
            }
        }
        private void LoadSanPhamSapHet()
        {
            try
            {
                DataTable dt = connect.ExecuteQuery("SELECT * FROM vw_SanPhamSapHetHang");

                dgvSapHetHang.DataSource = dt;

                dgvSapHetHang.Columns["MaSP"].HeaderText = "Mã SP";
                dgvSapHetHang.Columns["TenSP"].HeaderText = "Tên sản phẩm";
                dgvSapHetHang.Columns["SLTonKho"].HeaderText = "Tồn kho";

                dgvSapHetHang.Columns["TenSP"].Width = 200;
                dgvSapHetHang.Columns["SLTonKho"].Width = 80;

                dgvSapHetHang.ReadOnly = true;
                dgvSapHetHang.AllowUserToAddRows = false;
                dgvSapHetHang.AllowUserToDeleteRows = false;
                dgvSapHetHang.RowHeadersVisible = false;
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi khi tải sản phẩm sắp hết hàng: " + ex.Message);
            }
        }
        private void LoadPieChartTyLeDoanhThu()
        {
            DataTable dt = connect.ExecuteQuery("SELECT * FROM vw_TyLeDoanhThuTheoLoai");

            chartDoanhThu.Series.Clear();
            chartDoanhThu.Series.Add("DoanhThu");
            chartDoanhThu.Series["DoanhThu"].ChartType = SeriesChartType.Pie;

            chartDoanhThu.Series["DoanhThu"].Points.Clear();

            foreach (DataRow row in dt.Rows)
            {
                string tenLoai = row["TenLoai"].ToString();
                double doanhThu = Convert.ToDouble(row["DoanhThu"]);
                chartDoanhThu.Series["DoanhThu"].Points.AddXY(tenLoai, doanhThu);
            }

            chartDoanhThu.Legends[0].Enabled = true;
        }
        private void LoadSanPhamBanCham()
        {
            try
            {
                DataTable dt = connect.ExecuteQuery("SELECT * FROM vw_SanPhamBanCham");

                dgvBanCham.DataSource = dt;

                dgvBanCham.Columns["MaSP"].HeaderText = "Mã SP";
                dgvBanCham.Columns["TenSP"].HeaderText = "Tên sản phẩm";
                dgvBanCham.Columns["SLTonKho"].HeaderText = "Tồn kho";

                dgvBanCham.Columns["TenSP"].Width = 200;
                dgvBanCham.Columns["SLTonKho"].Width = 80;

                dgvBanCham.ReadOnly = true;
                dgvBanCham.AllowUserToAddRows = false;
                dgvBanCham.AllowUserToDeleteRows = false;
                dgvBanCham.RowHeadersVisible = false;
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi khi tải sản phẩm bán chậm: " + ex.Message);
            }
        }




        private void SalesForm_Load(object sender, EventArgs e)
        {

        }

        private void guna2Panel1_Paint(object sender, PaintEventArgs e)
        {

        }

        private void button_course_Click(object sender, EventArgs e)
        {

        }

        private void tblMain_Paint(object sender, PaintEventArgs e)
        {

        }

        private void label10_Click(object sender, EventArgs e)
        {
            Application.Exit();      
        }

        private void button_printsore_Click(object sender, EventArgs e)
        {
            this.Hide(); // Ẩn form hiện tại     
            FINAL_PROJECT_ST2.Nhanvienbanhangform.Nhanvienbanhang nhanvienbanhang = new FINAL_PROJECT_ST2.Nhanvienbanhangform.Nhanvienbanhang();
            nhanvienbanhang.Show(); // Hiện form mới     
        }

        private void label8_Click(object sender, EventArgs e)
        {

        }

        private void dgvSapHetHang_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void label6_Click(object sender, EventArgs e)
        {

        }

        private void chart1_Click(object sender, EventArgs e)
        {

        }

        private void dgvBanCham_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void lblHoaDon_Click(object sender, EventArgs e)
        {

        }

        private void button_newcourse_Click(object sender, EventArgs e)
        {
            backgound.Controls.Clear();
            UC_nhacungung    uc = new UC_nhacungung();   
            uc.Dock = DockStyle.Fill;
            backgound.Controls.Add(uc);
        }
    }
    
}
