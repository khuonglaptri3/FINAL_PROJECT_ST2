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

        private void dvgChitietmua_CellValueChanged(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0)
            {
                try
                {
                    int maHD = int.Parse(MaHDlabel.Text);
                    int maSP = Convert.ToInt32(dvgChitietmua.Rows[e.RowIndex].Cells["MaSP"].Value);
                    int soLuong = Convert.ToInt32(dvgChitietmua.Rows[e.RowIndex].Cells["SoLuong"].Value);
                    float vat = Convert.ToSingle(dvgChitietmua.Rows[e.RowIndex].Cells["VAT"].Value);
                    float chietKhau = Convert.ToSingle(dvgChitietmua.Rows[e.RowIndex].Cells["ChietKhau"].Value);

                    string query = "EXEC sp_SuaChiTietHoaDon @MaHD, @MaSP, @SoLuong, @ChietKhau, @VAT";
                    SqlParameter[] parameters = new SqlParameter[]
                    {
                new SqlParameter("@MaHD", maHD),
                new SqlParameter("@MaSP", maSP),
                new SqlParameter("@SoLuong", soLuong),
                new SqlParameter("@ChietKhau", chietKhau),
                new SqlParameter("@VAT", vat)
                    };

                    connect.ExecuteQuery(query, parameters);
                    LoadChiTietHoaDon(maHD); // Refresh lại sau khi sửa
                    LoadMatHang();



                }
                catch (Exception ex)
                {
                    MessageBox.Show("Lỗi cập nhật chi tiết hóa đơn: " + ex.Message);
                }
            }
        }

        private void grvSanpham_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0 && MaHDlabel.Text != "")
            {
                try
                {
                    int maHD = int.Parse(MaHDlabel.Text);
                    int maSP = Convert.ToInt32(grvsanpham.Rows[e.RowIndex].Cells["MaSP"].Value);
                    int soLuong = 1; // Số lượng mặc định
                    float chietKhau = 0; // Chiết khấu mặc định
                    float vat = 0; // VAT mặc định

                    string query = "EXEC sp_ThemChiTietHoaDon @MaHD, @MaSP, @SoLuong, @ChietKhau, @VAT";
                    SqlParameter[] parameters = new SqlParameter[]
                    {
                new SqlParameter("@MaHD", maHD),
                new SqlParameter("@MaSP", maSP),
                new SqlParameter("@SoLuong", soLuong),
                new SqlParameter("@ChietKhau", chietKhau),
                new SqlParameter("@VAT", vat)
                    };

                   connect.ExecuteQuery(query, parameters);
                    LoadChiTietHoaDon(maHD);
                    LoadMatHang(); 
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Lỗi khi thêm sản phẩm vào hóa đơn: " + ex.Message);
                }
            }
        }

        private void LoadChiTietHoaDon(int maHD)
        {
            string query = "EXEC sp_LayChiTietHoaDon @MaHD";

            SqlParameter[] parameters = new SqlParameter[]
            {
        new SqlParameter("@MaHD", maHD)
            };

            DataTable dt = connect.ExecuteQuery(query, parameters);
            dvgChitietmua.DataSource = dt;
            dvgChitietmua.ReadOnly = false;
            foreach (DataGridViewColumn col in dvgChitietmua.Columns)
            {
                col.ReadOnly = true;
            }
            dvgChitietmua.Columns["SoLuong"].ReadOnly = false;
            dvgChitietmua.Columns["VAT"].ReadOnly = false;
            dvgChitietmua.Columns["ChietKhau"].ReadOnly = false;

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
        }

        private void guna2Panel1_Paint(object sender, PaintEventArgs e)
        {

        }
        private void LoadMatHang()
        {
            try
            {
                
                string query = "SELECT * FROM vw_DanhSachMatHang";

                DataTable dt = connect.ExecuteQuery(query);
                grvsanpham.DataSource = dt; 

            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi tải dữ liệu mặt hàng: " + ex.Message);
            }
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
                LoadMatHang();
                LoadLoaiSanPham();   
                conn.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi tạo hóa đơn: " + ex.Message);
            }
        }
        private void cbLoaiSP_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Tránh lỗi khi ComboBox chưa load xong dữ liệu
            if (loaisanphamcombox.SelectedValue == null || loaisanphamcombox.SelectedIndex == -1)
                return;

            // Đảm bảo SelectedValue là int (MaLoai)
            if (int.TryParse(loaisanphamcombox.SelectedValue.ToString(), out int maLoai))
            {
                try
                {
                    SqlParameter[] param = {
                new SqlParameter("@MaLoai", maLoai)
            };

                    DataTable dt = connect.ExecuteQuery("EXEC sp_LaySanPhamTheoLoai @MaLoai", param);
                    grvsanpham.DataSource = dt;
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Lỗi khi lọc sản phẩm theo loại: " + ex.Message);
                }
            }
        }


        private void LoadLoaiSanPham()
        {
            string query = "sp_LayLoaiSanPham";
            SqlParameter[] param = null; // không có tham số

            DataTable dt = connect.ExecuteQuery(query, param);

            loaisanphamcombox.DataSource = dt;
            loaisanphamcombox.DisplayMember = "TenLoai";
            loaisanphamcombox.ValueMember = "MaLoai";
        }
        private void XoaChiTietHoaDon(int maHD, int maSP)
        {
            try
            {
                string query = "EXEC sp_XoaChiTietHoaDon @MaHD, @MaSP";

                SqlParameter[] param = new SqlParameter[]
                {
            new SqlParameter("@MaHD", maHD),
            new SqlParameter("@MaSP", maSP)
                };

                connect.ExecuteQuery(query, param); 
                MessageBox.Show("Đã xóa sản phẩm khỏi hóa đơn");

                LoadChiTietHoaDon(maHD); 
                LoadMatHang(); 
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi xóa: " + ex.Message);
            }
        }
        private void dvgChitietmua_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0 && e.ColumnIndex >= 0)
            {
                int maHD = Convert.ToInt32(MaHDlabel.Text); // giả sử mã hóa đơn đang hiển thị
                int maSP = Convert.ToInt32(dvgChitietmua.Rows[e.RowIndex].Cells["MaSP"].Value);

                if (MessageBox.Show("Xóa sản phẩm này khỏi hóa đơn?", "Xác nhận", MessageBoxButtons.YesNo) == DialogResult.Yes)
                {
                    XoaChiTietHoaDon(maHD, maSP);
                }
            }
        }




        private void Uc_TaoHoaDon_Load(object sender, EventArgs e)
        {

        }

        private void grvsanpham_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void dvgChitietmua_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }
    }
}
