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
            if (!int.TryParse(txtID.Text.Trim(), out int maKH))
            {
                MessageBox.Show("⚠ Vui lòng nhập số ID khách hàng hợp lệ.");
                return;
            }

            try
            {
                using (SqlConnection conn = connect.CreateConnection())
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("sp_TimKhachHangTheoID", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@MaKH", maKH);

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

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
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi tìm khách hàng: " + ex.Message);
            }
        }
        public void CapNhatTongTien(int maKH, int maHD)
        {
            SqlConnection conn = connect.CreateConnection();
            conn.Open();
            // Gọi stored procedure để cập nhật tổng tiền
            SqlCommand cmd = new SqlCommand("sp_UpdateTongTienTheoLoaiThe", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@MaKH", maKH);
                cmd.Parameters.AddWithValue("@MaHD", maHD);
                cmd.ExecuteNonQuery(); // giống như gọi "void"
            conn.Close();   
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
            btnThongTinKH.PerformClick(); // Gọi hàm tìm khách hàng để lấy thông tin  
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


        private void Xuathoadonbut_Click(object sender, EventArgs e)
        {
            try
            {
                string filePath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Desktop), $"HoaDon_{MaHDlabel.Text}.txt");

                using (StreamWriter sw = new StreamWriter(filePath, false, Encoding.UTF8))
                {
                    sw.WriteLine("=========== HÓA ĐƠN BÁN HÀNG ===========");
                    sw.WriteLine($"Mã hóa đơn: {MaHDlabel.Text}");
                    sw.WriteLine($"Ngày: {ngaylabel.Text}");
                    sw.WriteLine("----------------------------------------");

                    sw.WriteLine($"Khách hàng: {hovatenlabel.Text}");
                    sw.WriteLine($"SĐT: {Sdtlabel.Text}");
                    sw.WriteLine("----------------------------------------");

                    sw.WriteLine("Sản phẩm:");
                    sw.WriteLine("MaSP | Tên SP           | SL | Đơn giá | CK | VAT | Thành tiền");

                    foreach (DataGridViewRow row in dvgChitietmua.Rows)
                    {
                        if (!row.IsNewRow)
                        {
                            string masp = row.Cells["MaSP"].Value.ToString();
                            string tensp = row.Cells["TenSP"].Value.ToString().PadRight(15);
                            string soluong = row.Cells["SoLuong"].Value.ToString();
                            string dongia = Convert.ToDecimal(row.Cells["DonGia"].Value).ToString("N0");
                            string ck = row.Cells["ChietKhau"].Value.ToString();
                            string vat = row.Cells["VAT"].Value.ToString();
                            string thanhtien = Convert.ToDecimal(row.Cells["ThanhTien"].Value).ToString("N0");

                            sw.WriteLine($"{masp} | {tensp} | {soluong} | {dongia} | {ck} | {vat} | {thanhtien}");
                        }
                    }

                    sw.WriteLine("----------------------------------------");

                    // 🔥 Lấy tổng tiền từ hàm SQL
                    decimal tongTien = 0;
                    using (SqlConnection conn = connect.CreateConnection())
                    {
                        conn.Open();
                        SqlCommand cmd = new SqlCommand("SELECT dbo.fn_TongTienTheoKHVaHD(@MaKH, @MaHD)", conn);
                        cmd.Parameters.AddWithValue("@MaKH", int.Parse(txtID.Text)); // Label chứa mã khách hàng
                        cmd.Parameters.AddWithValue("@MaHD", int.Parse(MaHDlabel.Text)); // Label chứa mã hóa đơn

                        object result = cmd.ExecuteScalar();
                        if (result != DBNull.Value)
                            tongTien = Convert.ToDecimal(result);
                    }

                    sw.WriteLine($"TỔNG TIỀN: {tongTien:N0} VNĐ");
                    CapNhatTongTien(int.Parse(txtID.Text), int.Parse(MaHDlabel.Text));
                    using (SqlConnection conn = connect.CreateConnection())
                    {
                        conn.Open();
                        SqlCommand cmd = new SqlCommand("SELECT dbo.fn_TongTienTheoKHVaHD(@MaKH, @MaHD)", conn);
                        cmd.Parameters.AddWithValue("@MaKH", int.Parse(txtID.Text)); // Label chứa mã khách hàng
                        cmd.Parameters.AddWithValue("@MaHD", int.Parse(MaHDlabel.Text)); // Label chứa mã hóa đơn

                        object result = cmd.ExecuteScalar();
                        if (result != DBNull.Value)
                            tongTien = Convert.ToDecimal(result);
                    }
                    sw.WriteLine($"TỔNG TIỀN SAU KHI AP DUNG THE THANH VIEN: {tongTien:N0} VNĐ");
                    sw.WriteLine("========================================");
                    sw.WriteLine("Xin cảm ơn quý khách!");
                }

                MessageBox.Show("Xuất hóa đơn thành công!", "Thông báo");
                System.Diagnostics.Process.Start("explorer.exe", filePath);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi xuất hóa đơn: " + ex.Message);
            }
        }


    }
}
