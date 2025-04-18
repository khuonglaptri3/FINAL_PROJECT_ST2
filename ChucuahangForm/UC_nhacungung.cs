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
    public partial class UC_nhacungung : UserControl
    {
        DatabaseHelper connect;
        private bool isAddingRow = false;
        public UC_nhacungung()
        {
            InitializeComponent();
            connect = new DatabaseHelper();
            LoadDanhSachNhaCungUng();
            dgvNhaCungUng.CellDoubleClick += dgvNhaCungUng_CellDoubleClick;       // Xoá
            dgvNhaCungUng.RowValidating += dgvNhaCungUng_RowValidating;
            dgvNhaCungUng.RowValidated += dgvNhaCungUng_RowValidated;

        }
        private void LoadDanhSachNhaCungUng()
        {
            try
            {
                DataTable dt = connect.ExecuteQuery("SELECT * FROM vw_DanhSachNhaCungUng");

                dgvNhaCungUng.DataSource = dt;

                // Tuỳ chỉnh hiển thị
                dgvNhaCungUng.Columns["MaNCU"].HeaderText = "Mã NCC";
                dgvNhaCungUng.Columns["TenNCU"].HeaderText = "Tên nhà cung ứng";
                dgvNhaCungUng.Columns["SDT"].HeaderText = "SĐT";
                dgvNhaCungUng.Columns["Email"].HeaderText = "Email";
                dgvNhaCungUng.Columns["ThanhPho"].HeaderText = "Thành phố";
                dgvNhaCungUng.Columns["Quan"].HeaderText = "Quận";
                dgvNhaCungUng.Columns["Duong"].HeaderText = "Đường";
                dgvNhaCungUng.Columns["SoNha"].HeaderText = "Số nhà";

                dgvNhaCungUng.ReadOnly = false; // Nếu cho chỉnh trực tiếp
                dgvNhaCungUng.AllowUserToAddRows = false;
                dgvNhaCungUng.RowHeadersVisible = false;
                dgvNhaCungUng.Columns["MaNCU"].ReadOnly = true;
                dgvNhaCungUng.AllowUserToAddRows = true; 

            }


            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi khi tải danh sách nhà cung ứng: " + ex.Message);
            }
        }

        private void dgvNhaCungUng_RowValidating(object sender, DataGridViewCellCancelEventArgs e)
        {
            if (!dgvNhaCungUng.IsCurrentRowDirty) return;

            var row = dgvNhaCungUng.Rows[e.RowIndex];
            if (row.IsNewRow) return;

            object maNCUObj = row.Cells["MaNCU"]?.Value;
            if (maNCUObj != null && maNCUObj != DBNull.Value && int.TryParse(maNCUObj.ToString(), out _))
            {
                // Đã có mã → dòng này là update, không phải thêm
                return;
            }

            try
            {
                string tenNCU = row.Cells["TenNCU"]?.Value?.ToString() ?? "";
                string sdt = row.Cells["SDT"]?.Value?.ToString() ?? "";
                string email = row.Cells["Email"]?.Value?.ToString() ?? "";
                string thanhPho = row.Cells["ThanhPho"]?.Value?.ToString() ?? "";
                string quan = row.Cells["Quan"]?.Value?.ToString() ?? "";
                string duong = row.Cells["Duong"]?.Value?.ToString() ?? "";
                string soNha = row.Cells["SoNha"]?.Value?.ToString() ?? "";

                if (string.IsNullOrWhiteSpace(tenNCU) || string.IsNullOrWhiteSpace(sdt) || string.IsNullOrWhiteSpace(email))
                {
                    MessageBox.Show("❌ Vui lòng nhập đủ Tên nhà cung ứng, SDT và Email!", "Cảnh báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    e.Cancel = true;
                    return;
                }

                SqlConnection conn = connect.CreateConnection();
                conn.Open();

                SqlCommand cmd = new SqlCommand("sp_ThemNhaCungUng", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@TenNCU", tenNCU);
                cmd.Parameters.AddWithValue("@SDT", sdt);
                cmd.Parameters.AddWithValue("@Email", email);
                cmd.Parameters.AddWithValue("@ThanhPho", thanhPho);
                cmd.Parameters.AddWithValue("@Quan", quan);
                cmd.Parameters.AddWithValue("@Duong", duong);
                cmd.Parameters.AddWithValue("@SoNha", soNha);

                int result = cmd.ExecuteNonQuery();
                conn.Close();

                if (result > 0)
                {
                    MessageBox.Show("✅ Đã thêm nhà cung ứng mới!");
                    this.BeginInvoke(new MethodInvoker(() => LoadDanhSachNhaCungUng()));
                }
            }
            catch (SqlException ex)
            {
                MessageBox.Show("❌ Lỗi thêm nhà cung ứng: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                e.Cancel = true;
            }
        }
        private void dgvNhaCungUng_RowValidated(object sender, DataGridViewCellEventArgs e)
        {
            var row = dgvNhaCungUng.Rows[e.RowIndex];
            if (row.IsNewRow) return;

            object maNCUObj = row.Cells["MaNCU"]?.Value;
            if (maNCUObj == null || maNCUObj == DBNull.Value || !int.TryParse(maNCUObj.ToString(), out int maNCU))
                return; // Dòng chưa có mã hoặc chưa sinh mã

            try
            {
                string tenNCU = row.Cells["TenNCU"]?.Value?.ToString() ?? "";
                string sdt = row.Cells["SDT"]?.Value?.ToString() ?? "";
                string email = row.Cells["Email"]?.Value?.ToString() ?? "";
                string thanhPho = row.Cells["ThanhPho"]?.Value?.ToString() ?? "";
                string quan = row.Cells["Quan"]?.Value?.ToString() ?? "";
                string duong = row.Cells["Duong"]?.Value?.ToString() ?? "";
                string soNha = row.Cells["SoNha"]?.Value?.ToString() ?? "";

                if (string.IsNullOrWhiteSpace(tenNCU) || string.IsNullOrWhiteSpace(sdt) || string.IsNullOrWhiteSpace(email))
                    return;

                SqlConnection conn = connect.CreateConnection();
                conn.Open();

                SqlCommand cmd = new SqlCommand("sp_CapNhatNhaCungUng", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.AddWithValue("@MaNCU", maNCU);
                cmd.Parameters.AddWithValue("@TenNCU", tenNCU);
                cmd.Parameters.AddWithValue("@SDT", sdt);
                cmd.Parameters.AddWithValue("@Email", email);
                cmd.Parameters.AddWithValue("@ThanhPho", thanhPho);
                cmd.Parameters.AddWithValue("@Quan", quan);
                cmd.Parameters.AddWithValue("@Duong", duong);
                cmd.Parameters.AddWithValue("@SoNha", soNha);

                cmd.ExecuteNonQuery();
                conn.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi cập nhật nhà cung ứng: " + ex.Message);
            }
        }



        private void dgvNhaCungUng_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0) // Không xử lý header
            {
                var row = dgvNhaCungUng.Rows[e.RowIndex];
                string tenNCU = row.Cells["TenNCU"].Value?.ToString();
                int maNCU = Convert.ToInt32(row.Cells["MaNCU"].Value);

                DialogResult result = MessageBox.Show($"Bạn có chắc muốn xoá nhà cung ứng:\n\n📦 {tenNCU} (Mã: {maNCU})?", "Xác nhận xoá", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);

                if (result == DialogResult.Yes)
                {
                    try
                    {
                        string sql = "EXEC sp_XoaNhaCungUng @MaNCU";
                        SqlParameter[] prms = { new SqlParameter("@MaNCU", maNCU) };

                        connect.ExecuteQuery(sql, prms);
                        MessageBox.Show("✅ Xoá thành công!", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Information);

                        LoadDanhSachNhaCungUng(); // Refresh lại danh sách
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show("❌ Lỗi xoá: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
            }
        }




        private void dgvcacnhacungung_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void guna2Button1_Click(object sender, EventArgs e)
        {
            LoadDanhSachNhaCungUng(); // Gọi lại view đầy đủ     
        }

        private void searchBut_Click(object sender, EventArgs e)
        {
            string tukhoa = txtSearchNCU.Text.Trim();

            if (string.IsNullOrWhiteSpace(tukhoa))
            {
                LoadDanhSachNhaCungUng(); // Gọi lại view đầy đủ
                return;
            }

            string sql = "EXEC sp_TimNhaCungUngTheoTuKhoa @TuKhoa";
            SqlParameter[] prms = { new SqlParameter("@TuKhoa", tukhoa) };

            try
            {
                DataTable dt = connect.ExecuteQuery(sql, prms);
                dgvNhaCungUng.DataSource = dt; // 👉 Kết quả hiển thị lên DataGridView

                if (dt.Rows.Count == 0)
                    txtSearchNCU.Text = $"❌ Không tìm thấy kết quả cho \"{tukhoa}\".";
                else
                    txtSearchNCU.Text = $"🔍 Tìm thấy {dt.Rows.Count} kết quả cho \"{tukhoa}\".";
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi tìm kiếm: " + ex.Message);
            }
        }

        private void searchLabel_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
