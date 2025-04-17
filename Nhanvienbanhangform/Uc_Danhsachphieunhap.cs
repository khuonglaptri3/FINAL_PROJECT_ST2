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
    public partial class Uc_Danhsachphieunhap : UserControl
    {
        private DatabaseHelper connect; 
        public Uc_Danhsachphieunhap()
        {
            InitializeComponent();
            connect = new DatabaseHelper();
            LoadMatHang();   
        }
        private void LoadMatHang()
        {
            try
            {

                string query = "SELECT * FROM  vw_DanhSachHoaDonNhap";

                DataTable dt = connect.ExecuteQuery(query);
                dgvKhachHang.DataSource = dt;

            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi tải dữ liệu mặt hàng: " + ex.Message);
            }
        }
        private void dgvKhachHang_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void searchBut_Click(object sender, EventArgs e)
        {
            string tuKhoa = searchLabel.Text.Trim();

            if (string.IsNullOrEmpty(tuKhoa))
            {
                MessageBox.Show("⚠ Vui lòng nhập từ khóa tìm kiếm.");
                LoadMatHang(); // Gọi lại danh sách nếu không có từ khóa
                return;
            }

            try
            {
                SqlConnection conn = connect.CreateConnection();
                SqlCommand cmd = new SqlCommand("SELECT * FROM fn_TimKiemPhieuNhap(@TuKhoa)", conn);
                cmd.CommandType = CommandType.Text;
                cmd.Parameters.AddWithValue("@TuKhoa", "%" + tuKhoa + "%");

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                dgvKhachHang.DataSource = dt;
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi khi tìm kiếm: " + ex.Message);
            }
        }

        private void guna2Button1_Click(object sender, EventArgs e)
        {
            LoadMatHang();   
        }
    }
}
