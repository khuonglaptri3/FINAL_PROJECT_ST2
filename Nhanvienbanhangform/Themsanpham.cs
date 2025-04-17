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
    public partial class Themsanpham : UserControl
    {
        private DatabaseHelper connect;  
        public Themsanpham()
        {
            InitializeComponent();
            connect = new DatabaseHelper();
            LoadMatHang();
            dgvcacsanpham.RowValidating += dgvcacsanpham_RowValidating;
            dgvcacsanpham.RowValidated += dgvcacsanpham_RowValidated;
        }
        private void LoadMatHang()
        {
            try
            {

                string query = "SELECT * FROM v_TatCaSanPham";

                DataTable dt = connect.ExecuteQuery(query);
                dgvcacsanpham.DataSource = dt;

            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi tải dữ liệu mặt hàng: " + ex.Message);
            }
        }
        private void dgvcacsanpham_RowValidating(object sender, DataGridViewCellCancelEventArgs e)
        {
            if (!dgvcacsanpham.IsCurrentRowDirty) return;

            try
            {
                var row = dgvcacsanpham.Rows[e.RowIndex];
                if (row.IsNewRow) return;

                object maSPObj = row.Cells["MaSP"]?.Value;
                if (maSPObj != null && maSPObj != DBNull.Value && int.TryParse(maSPObj.ToString(), out int existingMaSP))
                {
                    // Có MaSP rồi => không thêm mới
                    return;
                }

                // Lấy dữ liệu để insert
                string tenSP = row.Cells["TenSP"]?.Value?.ToString();
                object donGiaObj = row.Cells["DonGia"]?.Value;
                object slTonObj = row.Cells["SLTonKho"]?.Value;
                string donViTinh = row.Cells["DonViTinh"]?.Value?.ToString() ?? "";
                string size = row.Cells["Size"]?.Value?.ToString() ?? "";
                string moTa = row.Cells["MoTaChiTiet"]?.Value?.ToString() ?? "";
                object maLoaiObj = row.Cells["MaLoai"]?.Value;

                if (string.IsNullOrWhiteSpace(tenSP) || donGiaObj == null || slTonObj == null || maLoaiObj == null)
                {
                    MessageBox.Show("❌ Vui lòng nhập đầy đủ Tên SP, Đơn giá, SL tồn, Mã loại!");
                    e.Cancel = true;
                    return;
                }

                decimal donGia = Convert.ToDecimal(donGiaObj);
                int slTon = Convert.ToInt32(slTonObj);
                int maLoai = Convert.ToInt32(maLoaiObj);

                SqlConnection conn = connect.CreateConnection();
                conn.Open();

                SqlCommand cmd = new SqlCommand("sp_ThemSanPham", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@TenSP", tenSP);
                cmd.Parameters.AddWithValue("@DonGia", donGia);
                cmd.Parameters.AddWithValue("@SLTonKho", slTon);
                cmd.Parameters.AddWithValue("@DonViTinh", donViTinh);
                cmd.Parameters.AddWithValue("@Size", size);
                cmd.Parameters.AddWithValue("@MoTaChiTiet", moTa);
                cmd.Parameters.AddWithValue("@MaLoai", maLoai);

                int result = cmd.ExecuteNonQuery();
                conn.Close();

                if (result > 0)
                {
                    MessageBox.Show("✅ Đã thêm sản phẩm!");
                    this.BeginInvoke(new MethodInvoker(() => LoadMatHang()));
                }
            }
            catch (SqlException ex)
            {
                if (ex.Message.Contains("Mã loại sản phẩm không tồn tại"))
                {
                    MessageBox.Show("❌ Mã loại sản phẩm không tồn tại!", "Lỗi nhập", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
                else
                {
                    MessageBox.Show("❌ Lỗi SQL: " + ex.Message);
                }

                e.Cancel = true;
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi khác: " + ex.Message);
                e.Cancel = true;
            }
        }
        private void dgvcacsanpham_RowValidated(object sender, DataGridViewCellEventArgs e)
        {
            try
            {
                var row = dgvcacsanpham.Rows[e.RowIndex];
                if (row.IsNewRow) return;

                object maSPObj = row.Cells["MaSP"]?.Value;
                if (maSPObj == null || !int.TryParse(maSPObj.ToString(), out int maSP)) return;

                string tenSP = row.Cells["TenSP"]?.Value?.ToString() ?? "";
                object donGiaObj = row.Cells["DonGia"]?.Value;
                object slTonObj = row.Cells["SLTonKho"]?.Value;
                string donViTinh = row.Cells["DonViTinh"]?.Value?.ToString() ?? "";
                string size = row.Cells["Size"]?.Value?.ToString() ?? "";
                string moTa = row.Cells["MoTaChiTiet"]?.Value?.ToString() ?? "";
                object maLoaiObj = row.Cells["MaLoai"]?.Value;

                if (string.IsNullOrWhiteSpace(tenSP) || donGiaObj == null || slTonObj == null || maLoaiObj == null)
                    return;

                decimal donGia = Convert.ToDecimal(donGiaObj);
                int slTon = Convert.ToInt32(slTonObj);
                int maLoai = Convert.ToInt32(maLoaiObj);

                SqlConnection conn = connect.CreateConnection();
                conn.Open();

                SqlCommand cmd = new SqlCommand("sp_CapNhatSanPham", conn); // ông nhớ tạo sp này nếu chưa có
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@MaSP", maSP);
                cmd.Parameters.AddWithValue("@TenSP", tenSP);
                cmd.Parameters.AddWithValue("@DonGia", donGia);
                cmd.Parameters.AddWithValue("@SLTonKho", slTon);
                cmd.Parameters.AddWithValue("@DonViTinh", donViTinh);
                cmd.Parameters.AddWithValue("@Size", size);
                cmd.Parameters.AddWithValue("@MoTaChiTiet", moTa);
                cmd.Parameters.AddWithValue("@MaLoai", maLoai);


                cmd.ExecuteNonQuery(); 
                conn.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi khi cập nhật sản phẩm: " + ex.Message);
            }
        }




        private void Themsanpham_Load(object sender, EventArgs e)
        {

        }

        private void dgvcacsanpham_CellContentClick_1(object sender, DataGridViewCellEventArgs e)
        {

        }
    }
}
