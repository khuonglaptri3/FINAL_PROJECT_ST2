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

namespace FINAL_PROJECT_ST2.ChucuahangForm
{
    
    public partial class Uc_NhanVien : UserControl
    {
        DatabaseHelper connect; 
        public Uc_NhanVien()
        {
            InitializeComponent();
            connect = new DatabaseHelper();
            LoadDanhSachNhanVien();
            dgvNhanVien.CellDoubleClick += dgvNhanVien_CellDoubleClick; // Xoá  
            dgvNhanVien.RowValidating += dgvNhanVien_RowValidating; // Thêm 
            dgvNhanVien.RowValidated += dgvNhanVien_RowValidated; // Cập nhật   

        }
        private void LoadDanhSachNhanVien()
        {
            try
            {
                DataTable dt = connect.ExecuteQuery("SELECT * FROM vw_NhanVien");

                dgvNhanVien.DataSource = dt;

                dgvNhanVien.Columns["MaNV"].HeaderText = "Mã NV";
                dgvNhanVien.Columns["TenNV"].HeaderText = "Tên nhân viên";
                dgvNhanVien.Columns["SDT"].HeaderText = "SĐT";
                dgvNhanVien.Columns["NgaySinh"].HeaderText = "Ngày sinh";
                dgvNhanVien.Columns["GioiTinh"].HeaderText = "Giới tính";
                dgvNhanVien.Columns["ThanhPho"].HeaderText = "Thành phố";
                dgvNhanVien.Columns["Quan"].HeaderText = "Quận";
                dgvNhanVien.Columns["Duong"].HeaderText = "Đường";
                dgvNhanVien.Columns["SoNha"].HeaderText = "Số nhà";
                dgvNhanVien.Columns["MaNND"].HeaderText = "Mã nhóm";

                dgvNhanVien.ReadOnly = false;
                dgvNhanVien.AllowUserToAddRows = true;
                dgvNhanVien.RowHeadersVisible = false;
                dgvNhanVien.Columns["MaNV"].ReadOnly = true;
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi khi tải danh sách nhân viên: " + ex.Message);
            }
        }

        private void dgvNhanVien_RowValidating(object sender, DataGridViewCellCancelEventArgs e)
        {
            if (!dgvNhanVien.IsCurrentRowDirty) return;

            var row = dgvNhanVien.Rows[e.RowIndex];
            if (row.IsNewRow) return;

            object maNVObj = row.Cells["MaNV"]?.Value;
            if (maNVObj != null && maNVObj != DBNull.Value && int.TryParse(maNVObj.ToString(), out _))
                return;

            try
            {
                string tenNV = row.Cells["TenNV"]?.Value?.ToString() ?? "";
                string sdt = row.Cells["SDT"]?.Value?.ToString() ?? "";
                string gioiTinh = row.Cells["GioiTinh"]?.Value?.ToString() ?? "";
                string thanhPho = row.Cells["ThanhPho"]?.Value?.ToString() ?? "";
                string quan = row.Cells["Quan"]?.Value?.ToString() ?? "";
                string duong = row.Cells["Duong"]?.Value?.ToString() ?? "";
                string soNha = row.Cells["SoNha"]?.Value?.ToString() ?? "";
                object ngaySinhObj = row.Cells["NgaySinh"]?.Value;
                object maNNDObj = row.Cells["MaNND"]?.Value;

                if (string.IsNullOrWhiteSpace(tenNV) || string.IsNullOrWhiteSpace(sdt) || ngaySinhObj == null || maNNDObj == null)
                {
                    MessageBox.Show("❌ Vui lòng nhập đủ thông tin!");
                    e.Cancel = true;
                    return;
                }

                SqlCommand cmd = new SqlCommand("sp_ThemNhanVien", connect.CreateConnection());
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@MaNND", maNNDObj);
                cmd.Parameters.AddWithValue("@TenNV", tenNV);
                cmd.Parameters.AddWithValue("@NgaySinh", Convert.ToDateTime(ngaySinhObj));
                cmd.Parameters.AddWithValue("@SDT", sdt);
                cmd.Parameters.AddWithValue("@GioiTinh", gioiTinh);
                cmd.Parameters.AddWithValue("@ThanhPho", thanhPho);
                cmd.Parameters.AddWithValue("@Quan", quan);
                cmd.Parameters.AddWithValue("@Duong", duong);
                cmd.Parameters.AddWithValue("@SoNha", soNha);

                SqlParameter outputParam = new SqlParameter("@MaNV_Moi", SqlDbType.Int)
                {
                    Direction = ParameterDirection.Output
                };
                cmd.Parameters.Add(outputParam);

                cmd.Connection.Open();
                cmd.ExecuteNonQuery();
                cmd.Connection.Close();

                int maNV = Convert.ToInt32(outputParam.Value);
                string tenDangNhap = "user" + maNV;
                string matKhau = "123456";

                // 🔵 Lấy MaNND dựa trên MaNV mới
                int maNND = -1;
                using (SqlCommand cmdGetMaNND = new SqlCommand("SELECT dbo.fn_GetMaNND_By_MaNV(@MaNV)", connect.CreateConnection()))
                {
                    cmdGetMaNND.CommandType = CommandType.Text;
                    cmdGetMaNND.Parameters.AddWithValue("@MaNV", maNV);

                    cmdGetMaNND.Connection.Open();
                    object maNNDFromDB = cmdGetMaNND.ExecuteScalar();
                    cmdGetMaNND.Connection.Close();

                    if (maNNDFromDB != null)
                        maNND = Convert.ToInt32(maNNDFromDB);
                    else
                    {
                        MessageBox.Show("❌ Không tìm thấy MaNND cho nhân viên mới.");
                        return;
                    }
                }

                // 🔐 Gọi thủ tục tạo login + user + gán role
                SqlCommand cmdLogin = new SqlCommand("sp_TaoLoginChoNhanVien", connect.CreateConnection());
                cmdLogin.CommandType = CommandType.StoredProcedure;
                cmdLogin.Parameters.AddWithValue("@TenDangNhap", tenDangNhap);
                cmdLogin.Parameters.AddWithValue("@MatKhau", matKhau);
                cmdLogin.Parameters.AddWithValue("@MaNND", maNND); // 🔥 Gửi đúng MaNND
                cmdLogin.Connection.Open();
                cmdLogin.ExecuteNonQuery();
                cmdLogin.Connection.Close();

                MessageBox.Show($"✅ Thêm nhân viên thành công!\n🔐 Tài khoản: {tenDangNhap}\n🔑 Mật khẩu: {matKhau}");

                this.BeginInvoke(new MethodInvoker(() => LoadDanhSachNhanVien()));
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi khi thêm nhân viên: " + ex.Message);
                e.Cancel = true;
            }
        }


        private void dgvNhanVien_RowValidated(object sender, DataGridViewCellEventArgs e)
        {
            var row = dgvNhanVien.Rows[e.RowIndex];
            if (row.IsNewRow) return;

            object maNVObj = row.Cells["MaNV"]?.Value;
            if (maNVObj == null || !int.TryParse(maNVObj.ToString(), out int maNV))
                return;

            try
            {
                SqlCommand cmd = new SqlCommand("sp_CapNhatNhanVien", connect.CreateConnection());
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@MaNV", maNV);
                cmd.Parameters.AddWithValue("@MaNND", row.Cells["MaNND"]?.Value ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@TenNV", row.Cells["TenNV"]?.Value ?? "");
                cmd.Parameters.AddWithValue("@NgaySinh", row.Cells["NgaySinh"]?.Value ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@SDT", row.Cells["SDT"]?.Value ?? "");
                cmd.Parameters.AddWithValue("@GioiTinh", row.Cells["GioiTinh"]?.Value ?? "");
                cmd.Parameters.AddWithValue("@ThanhPho", row.Cells["ThanhPho"]?.Value ?? "");
                cmd.Parameters.AddWithValue("@Quan", row.Cells["Quan"]?.Value ?? "");
                cmd.Parameters.AddWithValue("@Duong", row.Cells["Duong"]?.Value ?? "");
                cmd.Parameters.AddWithValue("@SoNha", row.Cells["SoNha"]?.Value ?? "");

                cmd.Connection.Open();
                cmd.ExecuteNonQuery();
                cmd.Connection.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi cập nhật nhân viên: " + ex.Message);
            }
        }


        private void dgvNhanVien_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0)
            {
                var row = dgvNhanVien.Rows[e.RowIndex];
                int maNV = Convert.ToInt32(row.Cells["MaNV"].Value);
                string tenNV = row.Cells["TenNV"].Value?.ToString();
                string tenDangNhap = "user" + maNV;

                DialogResult result = MessageBox.Show(
                    $"Bạn có chắc muốn xoá nhân viên:\n\n👤 {tenNV} (Mã: {maNV})?",
                    "Xác nhận xoá",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Warning);

                if (result == DialogResult.Yes)
                {
                    try
                    {
                        // 1. Xoá nhân viên → trigger sẽ xoá DANG_NHAP
                        SqlParameter[] prms = { new SqlParameter("@MaNV", maNV) };
                        connect.ExecuteQuery("EXEC sp_XoaNhanVien @MaNV", prms);

                        // 2. Gọi thủ tục xoá LOGIN/USER trên SQL
                        SqlParameter[] prmLogin = { new SqlParameter("@TenDangNhap", tenDangNhap) };
                        connect.ExecuteQuery("EXEC sp_XoaLoginNhanVien @TenDangNhap", prmLogin);

                        MessageBox.Show("✅ Đã xoá nhân viên và tài khoản SQL thành công!");
                        LoadDanhSachNhanVien(); // Refresh lại danh sách
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show("❌ Không thể xoá: " + ex.Message);
                    }
                }
            }
        }


        private void btnSearchNCU_Click(object sender, EventArgs e)
        {
            string keyword = txtSearchNV.Text.Trim();

            if (string.IsNullOrEmpty(keyword))
            {
                LoadDanhSachNhanVien();
                lblSearchResult.Text = "📋 Hiển thị toàn bộ nhân viên.";
                return;
            }

            string sql = "SELECT * FROM fn_TimKiemNhanVien(@TuKhoa)";
            SqlParameter[] prms = { new SqlParameter("@TuKhoa", keyword) };

            DataTable dt = connect.ExecuteQuery(sql, prms);
            dgvNhanVien.DataSource = dt;

            lblSearchResult.Text = dt.Rows.Count > 0
                ? $"🔍 Tìm thấy {dt.Rows.Count} kết quả cho \"{keyword}\"."
                : $"❌ Không có kết quả cho \"{keyword}\".";
        }





        private void dgvNhaCungUng_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }


        private void guna2Button1_Click(object sender, EventArgs e)
        {

        }

        private void txtSearchNCU_TextChanged(object sender, EventArgs e)
        {

        }

        private void txtSearchNV_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
