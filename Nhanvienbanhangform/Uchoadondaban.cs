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
    public partial class Uchoadondaban : UserControl
    {
        private DatabaseHelper connect;  
        public Uchoadondaban()
        {
            InitializeComponent();
            connect = new DatabaseHelper();
            loadtoanbohoadon();  
        }
        private void dgvHoaDon_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0)
            {
                int maHD = Convert.ToInt32(dvgviewhoadon.Rows[e.RowIndex].Cells["MaHD"].Value);
                int maKH = Convert.ToInt32(dvgviewhoadon.Rows[e.RowIndex].Cells["MaKH"].Value);

                FormXacNhan f = new FormXacNhan(maHD);

                if (f.ShowDialog() == DialogResult.OK)
                {
                    switch (f.LuaChonNguoiDung)
                    {
                        case FormXacNhan.LuaChon.Xoa:
                            XoaHoaDon(maHD);
                            break;

                        case FormXacNhan.LuaChon.ChiTiet:
                            HienThiChiTietHoaDon(maHD, maKH);
                            break;

                        default:
                            break;
                    }
                }
            }
        }

        private void XoaHoaDon(int maHD)
        {
            using (SqlConnection conn = connect.CreateConnection())
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("sp_XoaHoaDon", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@MaHD", maHD);
                cmd.ExecuteNonQuery();

                MessageBox.Show("Đã xóa hóa đơn thành công!", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Information);

                loadtoanbohoadon(); // Load lại danh sách hóa đơn
            }
        }
        private void HienThiChiTietHoaDon(int maHD, int maKH)
        {
            using (SqlConnection conn = connect.CreateConnection())
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand("sp_LayChiTietHoaDonTheoKH", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@MaHD", maHD);
                cmd.Parameters.AddWithValue("@MaKH", maKH);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                dvgviewhoadon.DataSource = dt;

                // Optional: chỉnh font, căn chỉnh nếu cần
                dvgviewhoadon.DefaultCellStyle.Font = new Font("Segoe UI", 12);
                dvgviewhoadon.ColumnHeadersDefaultCellStyle.Font = new Font("Segoe UI", 12, FontStyle.Bold);
            }
        }





        private void dvgviewhoadon_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }
        public void TimKiemHoaDon(string tukhoa)
        {
            using (SqlConnection conn = connect.CreateConnection())
            {
                conn.Open();

                SqlCommand cmd = new SqlCommand("SELECT * FROM dbo.fn_TimHoaDonTheoKH(@TuKhoa)", conn);
                cmd.Parameters.AddWithValue("@TuKhoa", tukhoa);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                dvgviewhoadon.DataSource = dt;
                dvgviewhoadon.DefaultCellStyle.Font = new Font("Segoe UI", 12);
                dvgviewhoadon.ColumnHeadersDefaultCellStyle.Font = new Font("Segoe UI", 12, FontStyle.Bold);
            }
        }

        public void loadtoanbohoadon()
        {
            SqlConnection conn = connect.CreateConnection();     
            conn.Open();
            SqlCommand cmd = new SqlCommand("SELECT * FROM vw_HoaDonDaBan", conn);
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);    
            dvgviewhoadon.DataSource = dt;
            dvgviewhoadon.DefaultCellStyle.Font = new Font("Segoe UI", 12); // hoặc font và size khác ông thích
            dvgviewhoadon.ColumnHeadersDefaultCellStyle.Font = new Font("Segoe UI", 12, FontStyle.Bold);

        }

        private void Searchbut_Click(object sender, EventArgs e)
        {
            string tukhoa = txtSearch.Text.Trim();
            if (tukhoa == "")
            {
                loadtoanbohoadon();
                MessageBox.Show("Vui lòng nhập từ khóa tìm kiếm", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }
            else
            {
                TimKiemHoaDon(tukhoa);
            }
        }

        private void Uchoadondaban_Load(object sender, EventArgs e)
        {

        }
    }
}
