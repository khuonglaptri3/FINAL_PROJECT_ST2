using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace FINAL_PROJECT_ST2.Nhanvienbanhangform
{
    public partial class Uc_chitietnhap : UserControl
    {
        private DatabaseHelper connect; // Khai báo biến kết nối    
        public Uc_chitietnhap()
        {
            InitializeComponent();
            connect = new DatabaseHelper(); // Khởi tạo kết nối 
            
        }

        private void Uc_chitietnhap_Load(object sender, EventArgs e)
        {

        }


        private void Taohoadonbut_Click(object sender, EventArgs e)
        {
            if (!int.TryParse(txtMaHDN.Text.Trim(), out int maHDN))
            {
                MessageBox.Show("⚠ Vui lòng nhập mã hóa đơn hợp lệ.");
                return;
            }

            try
            {
                SqlConnection conn = connect.CreateConnection();
                SqlCommand cmd = new SqlCommand("SELECT * FROM fn_LayThongTinPhieuNhap(@MaHDN)", conn);
                cmd.CommandType = CommandType.Text;
                cmd.Parameters.AddWithValue("@MaHDN", maHDN);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                LoadLoaiSanPham();
                LoadChiTietNhap(maHDN); // Gọi hàm để tải chi tiết hóa đơn nhập 


                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    MaNCClabel.Text = row["MaNCU"].ToString();
                    TenNCClabel.Text = row["TenNCU"].ToString();
                    SDTlabel.Text = row["SDT"].ToString();
                }
                else
                {
                    MessageBox.Show("❌ Không tìm thấy hóa đơn nhập nào với mã đó.", "Thông báo");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi khi truy vấn: " + ex.Message);
            }
        }
        private void LoadLoaiSanPham()
        {
            try
            {
                string query = "sp_LayLoaiSanPham";
                SqlParameter[] param = null;

                DataTable dt = connect.ExecuteQuery(query, param);

                loaisanphamcombox.DataSource = dt;
                loaisanphamcombox.DisplayMember = "TenLoai";
                loaisanphamcombox.ValueMember = "MaLoai";
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi load loại sản phẩm: " + ex.Message);
            }
        }
        private void LoadMatHang()
        {
            try
            {

                string query = "SELECT * FROM v_TatCaSanPham";

                DataTable dt = connect.ExecuteQuery(query);
                grvsanpham.DataSource = dt;

            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi tải dữ liệu mặt hàng: " + ex.Message);
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
        private void LoadChiTietNhap(int maHDN)
        {
            try
            {
                string query = "EXEC sp_LayChiTietNhapTheoHDN @MaHDN";
                SqlParameter[] parameters = {
            new SqlParameter("@MaHDN", maHDN)
        };

                DatabaseHelper db = new DatabaseHelper(); // dùng helper của bạn
                DataTable dt = db.ExecuteQuery(query, parameters);

                dvgChitietmua.DataSource = dt; // tên DataGridView hiển thị bên phải
                foreach (DataGridViewColumn col in dvgChitietmua.Columns)
                {
                    // Chỉ cho phép chỉnh sửa 3 cột này
                    if (col.Name == "SoLuong" || col.Name == "DonGia" || col.Name == "VAT")
                    {
                        col.ReadOnly = false;
                    }
                    else
                    {
                        col.ReadOnly = true;
                    }
                }

            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi khi tải chi tiết hóa đơn nhập: " + ex.Message);
            }
        }

        private void grvsanpham_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0)
            {
                // Lấy MaHDN từ textbox
                if (!int.TryParse(txtMaHDN.Text.Trim(), out int maHDN))
                {
                    MessageBox.Show("⚠ Vui lòng nhập mã hóa đơn hợp lệ trước khi thêm sản phẩm.");
                    return;
                }

                // Lấy MaSP từ dòng được chọn
                int maSP = Convert.ToInt32(grvsanpham.Rows[e.RowIndex].Cells["MaSP"].Value);

                int soLuong = 1; // 👈 Mặc định luôn = 1
                float vat = 0;   // Nếu không có TextBox VAT thì cho mặc định
                float chietKhau = 0;

                try
                {
                    SqlConnection conn = connect.CreateConnection();
                    SqlCommand cmd = new SqlCommand("sp_ThemChiTietNhap", conn);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@MaHDN", maHDN);
                    cmd.Parameters.AddWithValue("@MaSP", maSP);
                    cmd.Parameters.AddWithValue("@SoLuong", soLuong);
                    cmd.Parameters.AddWithValue("@ChietKhau", chietKhau);
                    cmd.Parameters.AddWithValue("@VAT", vat);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                    conn.Close();

                    MessageBox.Show("✅ Đã thêm sản phẩm vào chi tiết phiếu nhập.");
                    LoadChiTietNhap(maHDN);
                    LoadMatHang(); // Load lại sản phẩm nếu cần 
                }
                catch (Exception ex)
                {
                    MessageBox.Show("❌ Lỗi khi thêm sản phẩm: " + ex.Message);
                }
            }
        }
        private void dvgChiTietNhap_CellValueChanged(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0)
            {
                try
                {
                    int maHDN = int.Parse(txtMaHDN.Text);
                    int maSP = Convert.ToInt32(dvgChitietmua.Rows[e.RowIndex].Cells["MaSP"].Value);
                    int soLuong = Convert.ToInt32(dvgChitietmua.Rows[e.RowIndex].Cells["SoLuong"].Value);
                    float vat = Convert.ToSingle(dvgChitietmua.Rows[e.RowIndex].Cells["VAT"].Value);
                    float chietKhau = Convert.ToSingle(dvgChitietmua.Rows[e.RowIndex].Cells["ChietKhau"].Value);

                    string query = "EXEC sp_SuaChiTietNhap @MaHDN, @MaSP, @SoLuong, @ChietKhau, @VAT";
                    SqlParameter[] parameters = new SqlParameter[]
                    {
                new SqlParameter("@MaHDN", maHDN),
                new SqlParameter("@MaSP", maSP),
                new SqlParameter("@SoLuong", soLuong),
                new SqlParameter("@ChietKhau", chietKhau),
                new SqlParameter("@VAT", vat)
                    };

                    connect.ExecuteQuery(query, parameters);
                    LoadChiTietNhap(maHDN); // Refresh chi tiết
                    LoadMatHang() ; // Load lại sản phẩm nếu cần
                }
                catch (Exception ex)
                {
                    MessageBox.Show("❌ Lỗi cập nhật chi tiết nhập: " + ex.Message);
                }
            }
        }

        private void dgvChiTietNhap_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0)
            {
                // Lấy mã sản phẩm và tên sản phẩm từ dòng được click
                int maSP = Convert.ToInt32(dvgChitietmua.Rows[e.RowIndex].Cells["MaSP"].Value);
                string tenSP = dvgChitietmua.Rows[e.RowIndex].Cells["TenSP"].Value.ToString();
                int maHDN = Convert.ToInt32(txtMaHDN.Text);

                // Hỏi người dùng có muốn xóa không
                DialogResult result = MessageBox.Show(
                    $"Bạn có muốn xóa sản phẩm '{tenSP}' khỏi phiếu nhập không?",
                    "Xác nhận xóa",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Question
                );

                if (result == DialogResult.Yes)
                {
                    try
                    {
                        using (SqlConnection conn = connect.CreateConnection() )
                        {
                            conn.Open();
                            SqlCommand cmd = new SqlCommand("sp_XoaChiTietNhap", conn);
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.AddWithValue("@MaHDN", maHDN);
                            cmd.Parameters.AddWithValue("@MaSP", maSP);
                            cmd.ExecuteNonQuery();
                        }

                        MessageBox.Show("✅ Đã xóa sản phẩm khỏi phiếu nhập.");

                        // Refresh lại dữ liệu chi tiết nhập
                        LoadChiTietNhap(maHDN);
                        LoadMatHang(); // Load lại sản phẩm nếu cần 
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show("❌ Lỗi khi xóa: " + ex.Message);
                    }
                }
            }
        }


        private void grvsanpham_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void dvgChitietmua_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }
    }
}
