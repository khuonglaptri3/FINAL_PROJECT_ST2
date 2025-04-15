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
    public partial class TimkiemkhachhangForm : UserControl
    {
        private DatabaseHelper connect; 
        public TimkiemkhachhangForm()
        {
            InitializeComponent();
            connect = new DatabaseHelper();
            LoadDanhSachKhachHang(); 
        }

        private void guna2DataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
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
                conn.Close();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi load khách hàng: " + ex.Message);
            }
        }

        private void Deletebut_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtID.Text))
            {
                MessageBox.Show("⚠ Vui lòng nhập ID khách hàng cần xóa.", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (!int.TryParse(txtID.Text, out int maKH))
            {
                MessageBox.Show("❌ ID phải là số nguyên hợp lệ.", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            DialogResult result = MessageBox.Show($"Bạn có chắc chắn muốn xóa khách hàng có ID = {maKH}?",
                                                  "Xác nhận xóa", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

            if (result == DialogResult.Yes)
            {
                try
                {
                    SqlConnection conn = connect.CreateConnection();
                    conn.Open();

                    SqlCommand cmd = new SqlCommand("sp_XoaKhachHang", conn);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@MaKH", maKH);

                    cmd.ExecuteNonQuery();
                    conn.Close();

                    MessageBox.Show("✅ Đã xóa khách hàng thành công.", "Thành công", MessageBoxButtons.OK, MessageBoxIcon.Information);

                    // Refresh danh sách
                    LoadDanhSachKhachHang();
                    txtID.Clear(); // Xoá nội dung textbox sau khi xóa
                }
                catch (SqlException ex)
                {
                    MessageBox.Show("❌ Không thể xóa khách hàng: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }

        private void guna2Button1_Click(object sender, EventArgs e)
        {
            string tuKhoa = txtSearch.Text.Trim();

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
        }
    }
}
