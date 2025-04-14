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
    }
}
