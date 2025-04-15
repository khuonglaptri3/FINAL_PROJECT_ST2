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
    public partial class Nhanvienbanhang: Form
    {
        DatabaseHelper connect; 
        public Nhanvienbanhang()
        {
            connect = new DatabaseHelper();
            InitializeComponent();
            //showallmembership(); 
        }
        //private void showallmembership()
        //{
        //    try
        //    {
        //        SqlConnection conn = connect.CreateConnection();
        //        conn.Open();

        //        string query = "SELECT * FROM v_TatCaKhachHang";
        //        SqlCommand cmd = new SqlCommand(query, conn);
        //        SqlDataAdapter da = new SqlDataAdapter(cmd);
        //        DataTable dt = new DataTable();
        //        da.Fill(dt);

        //        guna2DataGridView1.DataSource = dt;
        //        guna2DataGridView1.Columns[0].HeaderText = "Mã KH";
        //        guna2DataGridView1.Columns[1].HeaderText = "Tên KH";
        //        guna2DataGridView1.Columns[2].HeaderText = "Ngày Sinh";
        //        guna2DataGridView1.Columns[3].HeaderText = "SĐT";
        //        guna2DataGridView1.Columns[4].HeaderText = "Giới Tính";
        //        guna2DataGridView1.Columns[5].HeaderText = "Thành Phố";
        //        guna2DataGridView1.Columns[6].HeaderText = "Quận";
        //        guna2DataGridView1.Columns[7].HeaderText = "Đường";
        //        guna2DataGridView1.Columns[8].HeaderText = "Số Nhà";
        //        guna2DataGridView1.Columns[9].HeaderText = "Mã Số Thẻ";
        //        guna2DataGridView1.Columns[10].HeaderText = "Ngày Cấp";
        //        guna2DataGridView1.Columns[11].HeaderText = "Điểm Tích Lũy";
        //        guna2DataGridView1.Columns[12].HeaderText = "Loại Thẻ";
               


        //        guna2DataGridView1.DefaultCellStyle.Font = new Font("Segoe UI", 10); // Hoặc font bạn thích
        //        guna2DataGridView1.ColumnHeadersDefaultCellStyle.Font = new Font("Segoe UI", 11, FontStyle.Bold);

        //        guna2DataGridView1.ScrollBars = ScrollBars.Both;

        //        conn.Close();
        //    }
        //    catch (Exception ex)
        //    {
        //        MessageBox.Show("Lỗi khi hiển thị thẻ thành viên: " + ex.Message);
        //    }
        //}


        private void Nhanvienbanhang_Load(object sender, EventArgs e)
        {

        }

        private void label1_Click(object sender, EventArgs e)
        {
           Application.Exit(); 
        }

        private void panel1_Paint(object sender, PaintEventArgs e)
        {

        }

        private void guna2DataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void guna2Panel1_Paint(object sender, PaintEventArgs e)
        {

        }

        private void button_newcourse_Click(object sender, EventArgs e)
        {
            guna2Panel1.Controls.Clear(); // Xóa control cũ
            Uc_ThemKhachHang uc = new Uc_ThemKhachHang();
            uc.Dock = DockStyle.Fill;
            guna2Panel1.Controls.Add(uc); // Thêm UC vào panel
        }

        private void guna2Panel1_Paint_1(object sender, PaintEventArgs e)
        {


        }

        private void button_managecourse_Click(object sender, EventArgs e)
        {
            guna2Panel1.Controls.Clear();   
            TimkiemkhachhangForm uc = new TimkiemkhachhangForm();    
            uc.Dock = DockStyle.Fill;    
            guna2Panel1.Controls.Add(uc);     

        }

        private void button_newscore_Click(object sender, EventArgs e)
        {
            guna2Panel1.Controls.Clear();
            Uc_TaoHoaDon uc_TaoHoaDon = new Uc_TaoHoaDon();  
            uc_TaoHoaDon.Dock = DockStyle.Fill;
            guna2Panel1.Controls.Add(uc_TaoHoaDon); 
        }
    }
}
