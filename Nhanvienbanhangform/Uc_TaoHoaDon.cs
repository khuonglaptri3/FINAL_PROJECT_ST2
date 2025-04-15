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
    public partial class Uc_TaoHoaDon : UserControl
    {
        private DatabaseHelper connect; 
        public Uc_TaoHoaDon()
        {
            InitializeComponent();
            connect = new DatabaseHelper(); 
        }

        private void btnThongTinKH_Click(object sender, EventArgs e)
        {
            string tuKhoa = txtID.Text.Trim();
            if (string.IsNullOrEmpty(tuKhoa))
            {
                MessageBox.Show("⚠ Vui lòng nhập ID khách hàng để tìm kiếm.");  
                return;
            }
            try
            {
                SqlConnection conn = connect.CreateConnection();
                conn.Open();

                SqlCommand cmd = new SqlCommand("sp_TimKiemKhachHangNhanh", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TuKhoa", tuKhoa);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                dgvKhachHang.DataSource = dt;
                conn.Close();



                if (dt.Rows.Count > 0)
                {
                    hovatenlabel.Text = dt.Rows[0]["TenKH"].ToString();
                    Sdtlabel.Text = dt.Rows[0]["SDT"].ToString();
                }
                else
                {
                    hovatenlabel.Text = "Không tìm thấy";
                    Sdtlabel.Text = "";
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi tìm khách hàng: " + ex.Message);
            }
            /*
                         if (string.IsNullOrEmpty(tuKhoa))
            {
                MessageBox.Show("⚠ Vui lòng nhập từ khóa tìm kiếm.");
                LoadDanhSachKhachHang(); // Load lại danh sách nếu không có từ khóa 
                return;
            }

            try
            {
                SqlConnection conn = connect.CreateConnection();
                conn.Open();

                SqlCommand cmd = new SqlCommand("sp_TimKiemKhachHangNhanh", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@TuKhoa", tuKhoa);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                dgvKhachHang.DataSource = dt;
                conn.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi khi tìm kiếm: " + ex.Message);
            }
             */
        }

        private void guna2Panel1_Paint(object sender, PaintEventArgs e)
        {

        }

        private void Taohoadonbut_Click(object sender, EventArgs e)
        {
            int maKH;
            if (!int.TryParse(txtID.Text.Trim(), out maKH))
            {
                MessageBox.Show("ID khách hàng không hợp lệ!");
                return;
            }
            try
            {
                SqlConnection conn = connect.CreateConnection();
                conn.Open();
                SqlCommand cmd = new SqlCommand("sp_TaoHoaDon", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@MaKH", maKH);
                int maHD = Convert.ToInt32(cmd.ExecuteScalar());
                MaHDlabel.Text = maHD.ToString();
                ngaylabel.Text = DateTime.Now.ToString("dd/MM/yyyy");
                SqlCommand cmdChiTiet = new SqlCommand("sp_LayChiTietHoaDon", conn);
                cmdChiTiet.CommandType = CommandType.StoredProcedure;
                cmdChiTiet.Parameters.AddWithValue("@MaHD", maHD);
                SqlDataAdapter da = new SqlDataAdapter(cmdChiTiet);
                DataTable dt = new DataTable();
                da.Fill(dt);
                dvgChitietmua.DataSource = dt;
                conn.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tạo hóa đơn: " + ex.Message);
            }
        }

    }
}
