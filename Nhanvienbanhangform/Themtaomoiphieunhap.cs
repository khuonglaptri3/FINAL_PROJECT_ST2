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
    public partial class Themtaomoiphieunhap : UserControl
    {
        private DatabaseHelper connect;  
        public Themtaomoiphieunhap()
        {
            InitializeComponent();
            connect = new DatabaseHelper();  
            Loadnhacungung();
            dgvcacnhacungung.CellClick += dgvNhaCungUng_CellClick;
        }
        private void Loadnhacungung()
        {
            try
            {

                string query = "SELECT * FROM vw_TatCaNhaCungUng";

                DataTable dt = connect.ExecuteQuery(query);
                dgvcacnhacungung.DataSource = dt;

            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi tải dữ liệu mặt hàng: " + ex.Message);
            }
        }
        private void dgvcacnhacungung_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void searchBut_Click(object sender, EventArgs e)
        {
            string tuKhoa = searchLabel.Text.Trim();

            if (string.IsNullOrEmpty(tuKhoa))
            {
                MessageBox.Show("⚠ Vui lòng nhập từ khóa tìm kiếm.");
                Loadnhacungung(); // Gọi lại danh sách nếu không có từ khóa
                return;
            }

            try
            {
                SqlConnection conn = connect.CreateConnection();
                SqlCommand cmd = new SqlCommand("SELECT * FROM dbo.fn_TimNhaCungUng(@TuKhoa)", conn);
                cmd.CommandType = CommandType.Text;
                cmd.Parameters.AddWithValue("@TuKhoa", "%" + tuKhoa + "%");

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

              dgvcacnhacungung.DataSource = dt;
            }
            catch (Exception ex)
            {
                MessageBox.Show("❌ Lỗi khi tìm kiếm: " + ex.Message);
            }
        }
        private void dgvNhaCungUng_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            // Kiểm tra tránh click vào tiêu đề cột
            if (e.RowIndex >= 0)
            {
                // Lấy thông tin từ dòng được chọn
                int maNCU = Convert.ToInt32(dgvcacnhacungung.Rows[e.RowIndex].Cells["MaNCU"].Value);
                string tenNCU = dgvcacnhacungung.Rows[e.RowIndex].Cells["TenNCU"].Value.ToString();

                DialogResult result = MessageBox.Show(
                    $"Bạn có muốn tạo hóa đơn nhập hàng với nhà cung ứng:\n\n👉 {tenNCU} (ID: {maNCU})?",
                    "Xác nhận tạo hóa đơn",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Question);

                if (result == DialogResult.Yes)
                {
                    try
                    {
                        SqlConnection conn = connect.CreateConnection();
                        SqlCommand cmd = new SqlCommand("sp_TaoPhieuNhap", conn);
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@MaNCU", maNCU);

                        conn.Open();
                        object resultObj = cmd.ExecuteScalar(); // trả về MaHDN
                        int maHDN = Convert.ToInt32(resultObj);
                        conn.Close();

                        // Hiển thị thông tin hóa đơn mới
                        string thongTin = $"✅ Đã tạo phiếu nhập hàng!\n\n"
                                        + $"🆔 Mã hóa đơn: {maHDN}\n"
                                        + $"🏢 Nhà cung ứng: {tenNCU}\n"
                                        + $"📅 Ngày đặt: {DateTime.Now:dd/MM/yyyy}";
                        MessageBox.Show(thongTin, "Thông tin phiếu nhập", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show("❌ Lỗi khi tạo phiếu nhập: " + ex.Message);
                    }
                }
            }   
        }

        private void guna2Button1_Click(object sender, EventArgs e)
        {
        Loadnhacungung(); 
        }

        private void searchLabel_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
