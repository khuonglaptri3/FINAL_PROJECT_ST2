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

namespace FINAL_PROJECT_ST2
{
    public partial class Uc_ThemKhachHang : UserControl
    {
        DatabaseHelper connect; 
        public Uc_ThemKhachHang()
        {
            connect = new DatabaseHelper();
            InitializeComponent();
            LoadDanhSachKhachHang();   
            
        }

        private void guna2Button3_Click(object sender, EventArgs e)
        {

        }
        private void LoadDanhSachKhachHang()
        {
            try
            {
                SqlConnection conn = connect.CreateConnection();
                conn.Open();

                SqlCommand cmd = new SqlCommand("SELECT * FROM v_TatCaKhachHang", conn);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                dgvKhachHang.DataSource = dt;
                dgvKhachHang.Columns[0].HeaderText = "Mã KH";
                dgvKhachHang.Columns[1].HeaderText = "Tên KH";
                dgvKhachHang.Columns[2].HeaderText = "Ngày Sinh";
                dgvKhachHang.Columns[3].HeaderText = "SĐT";
                dgvKhachHang.Columns[4].HeaderText = "Giới Tính";
                dgvKhachHang.Columns[5].HeaderText = "Thành Phố";
                dgvKhachHang.Columns[6].HeaderText = "Quận";
                dgvKhachHang.Columns[7].HeaderText = "Đường";
                dgvKhachHang.Columns[8].HeaderText = "Số Nhà";
                dgvKhachHang.Columns[9].HeaderText = "Mã Số Thẻ";
                dgvKhachHang.Columns[10].HeaderText = "Ngày Cấp";
                dgvKhachHang.Columns[11].HeaderText = "Điểm Tích Lũy";
                dgvKhachHang.Columns[12].HeaderText = "Loại Thẻ";
                // Đặt tất cả các cột là ReadOnly mặc định
                foreach (DataGridViewColumn col in dgvKhachHang.Columns)
                {
                    col.ReadOnly = true;
                }

                // Cho phép chỉnh sửa những cột cụ thể
                string[] editableCols = { "TenKH", "NgaySinh", "SDT", "GioiTinh", "ThanhPho", "Quan", "Duong", "SoNha" };

                foreach (string colName in editableCols)
                {
                    if (dgvKhachHang.Columns.Contains(colName))
                        dgvKhachHang.Columns[colName].ReadOnly = false;
                }

                conn.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi load khách hàng: " + ex.Message);
            }
        }
        //private void dgvKhachHang_RowValidating(object sender, DataGridViewCellCancelEventArgs e)
        //{
        //    if (dgvKhachHang.IsCurrentRowDirty)
        //    {
        //        try
        //        {
        //            var row = dgvKhachHang.Rows[e.RowIndex];

        //            string tenKH = row.Cells["TenKH"].Value?.ToString();
        //            string sdt = row.Cells["SDT"].Value?.ToString();
        //            string gioiTinh = row.Cells["GioiTinh"].Value?.ToString();
        //            string thanhPho = row.Cells["ThanhPho"].Value?.ToString();
        //            string quan = row.Cells["Quan"].Value?.ToString();
        //            string duong = row.Cells["Duong"].Value?.ToString();
        //            string soNha = row.Cells["SoNha"].Value?.ToString();
        //            object ngaysinhObj = row.Cells["NgaySinh"].Value;

        //            // Kiểm tra các trường bắt buộc
        //            if (string.IsNullOrWhiteSpace(tenKH) || string.IsNullOrWhiteSpace(sdt) || ngaysinhObj == null)
        //            {
        //                MessageBox.Show("Vui lòng nhập đầy đủ thông tin trước khi lưu!");
        //                e.Cancel = true;
        //                return;
        //            }

        //            DateTime ngaySinh = Convert.ToDateTime(ngaysinhObj);

        //            // Gọi SP qua DatabaseHelper
        //            DatabaseHelper db = new DatabaseHelper();

        //            SqlParameter[] prms = new SqlParameter[]
        //            {
        //        new SqlParameter("@TenKH", tenKH),
        //        new SqlParameter("@NgaySinh", ngaySinh),
        //        new SqlParameter("@SDT", sdt),
        //        new SqlParameter("@GioiTinh", gioiTinh ?? ""),
        //        new SqlParameter("@ThanhPho", thanhPho ?? ""),
        //        new SqlParameter("@Quan", quan ?? ""),
        //        new SqlParameter("@Duong", duong ?? ""),
        //        new SqlParameter("@SoNha", soNha ?? "")
        //            };

        //            int result = db.ExecuteNonQuery("sp_ThemKhachHang", prms);

        //            if (result > 0)
        //            {
        //                MessageBox.Show("✅ Thêm khách hàng thành công!");
        //                LoadDanhSachKhachHang();
        //            }
        //        }
        //        catch (Exception ex)
        //        {
        //            MessageBox.Show("Lỗi khi thêm dòng: " + ex.Message);
        //        }
        //    }
        //}
        private void dgvKhachHang_RowValidating(object sender, DataGridViewCellCancelEventArgs e)
        {
            if (!dgvKhachHang.IsCurrentRowDirty) return;

            try
            {
                var row = dgvKhachHang.Rows[e.RowIndex];
                if (row.IsNewRow) return;

                object maKHObj = row.Cells["MaKH"]?.Value;
                if (maKHObj != null && maKHObj != DBNull.Value && int.TryParse(maKHObj.ToString(), out int existingMaKH))
                {
                    // Nếu đã có MaKH -> dòng này là để UPDATE chứ không phải INSERT => bỏ qua ở đây
                    return;
                }

                // Đây là dòng mới -> Insert
                string tenKH = row.Cells["TenKH"]?.Value?.ToString();
                string sdt = row.Cells["SDT"]?.Value?.ToString();
                string gioiTinh = row.Cells["GioiTinh"]?.Value?.ToString() ?? "";
                string thanhPho = row.Cells["ThanhPho"]?.Value?.ToString() ?? "";
                string quan = row.Cells["Quan"]?.Value?.ToString() ?? "";
                string duong = row.Cells["Duong"]?.Value?.ToString() ?? "";
                string soNha = row.Cells["SoNha"]?.Value?.ToString() ?? "";
                object ngaysinhObj = row.Cells["NgaySinh"]?.Value;

                if (string.IsNullOrWhiteSpace(tenKH) || string.IsNullOrWhiteSpace(sdt) || ngaysinhObj == null)
                {
                    MessageBox.Show("❌ Vui lòng nhập đầy đủ Tên KH, SĐT, Ngày sinh!");
                    e.Cancel = true;
                    return;
                }

                DateTime ngaySinh = Convert.ToDateTime(ngaysinhObj);

                SqlConnection conn = connect.CreateConnection();
                conn.Open();

                SqlCommand cmd = new SqlCommand("sp_ThemKhachHang", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@TenKH", tenKH);
                cmd.Parameters.AddWithValue("@NgaySinh", ngaySinh);
                cmd.Parameters.AddWithValue("@SDT", sdt);
                cmd.Parameters.AddWithValue("@GioiTinh", gioiTinh);
                cmd.Parameters.AddWithValue("@ThanhPho", thanhPho);
                cmd.Parameters.AddWithValue("@Quan", quan);
                cmd.Parameters.AddWithValue("@Duong", duong);
                cmd.Parameters.AddWithValue("@SoNha", soNha);

                int result = cmd.ExecuteNonQuery();
                conn.Close();

                if (result > 0)
                {
                    MessageBox.Show("✅ Đã thêm khách hàng từ dòng mới!");
                    this.BeginInvoke(new MethodInvoker(() => LoadDanhSachKhachHang()));
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi khi thêm dòng: " + ex.Message);
                e.Cancel = true;
            }
        }

        private void dgvKhachHang_RowValidated(object sender, DataGridViewCellEventArgs e)
        {
            try
            {
                var row = dgvKhachHang.Rows[e.RowIndex];
                if (row.IsNewRow) return;

                // 🛡️ Kiểm tra nếu MaKH chưa có => dòng mới => KHÔNG update
                object maKHObj = row.Cells["MaKH"]?.Value;
                if (maKHObj == null || maKHObj == DBNull.Value || !int.TryParse(maKHObj.ToString(), out int maKH))
                {
                    // Đây là dòng mới hoặc MaKH chưa sinh ra → bỏ qua cập nhật
                    return;
                }

                // 🧠 Lúc này MaKH chắc chắn hợp lệ → tiếp tục update
                string tenKH = row.Cells["TenKH"]?.Value?.ToString() ?? "";
                string sdt = row.Cells["SDT"]?.Value?.ToString() ?? "";
                string gioiTinh = row.Cells["GioiTinh"]?.Value?.ToString() ?? "";
                string thanhPho = row.Cells["ThanhPho"]?.Value?.ToString() ?? "";
                string quan = row.Cells["Quan"]?.Value?.ToString() ?? "";
                string duong = row.Cells["Duong"]?.Value?.ToString() ?? "";
                string soNha = row.Cells["SoNha"]?.Value?.ToString() ?? "";
                object ngaysinhObj = row.Cells["NgaySinh"]?.Value;

                if (string.IsNullOrWhiteSpace(tenKH) || string.IsNullOrWhiteSpace(sdt) || ngaysinhObj == null || ngaysinhObj == DBNull.Value)
                    return;

                DateTime ngaySinh = Convert.ToDateTime(ngaysinhObj);

                SqlConnection conn = connect.CreateConnection();
                conn.Open();

                SqlCommand cmd = new SqlCommand("sp_CapNhatKhachHang", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@MaKH", maKH);
                cmd.Parameters.AddWithValue("@TenKH", tenKH);
                cmd.Parameters.AddWithValue("@NgaySinh", ngaySinh);
                cmd.Parameters.AddWithValue("@SDT", sdt);
                cmd.Parameters.AddWithValue("@GioiTinh", gioiTinh);
                cmd.Parameters.AddWithValue("@ThanhPho", thanhPho);
                cmd.Parameters.AddWithValue("@Quan", quan);
                cmd.Parameters.AddWithValue("@Duong", duong);
                cmd.Parameters.AddWithValue("@SoNha", soNha);

                cmd.ExecuteNonQuery();
                conn.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi khi cập nhật: " + ex.Message);
            }
        }






        private void guna2DataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }
    }
}
