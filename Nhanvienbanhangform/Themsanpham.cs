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


        private void Themsanpham_Load(object sender, EventArgs e)
        {

        }

        private void dgvcacsanpham_CellContentClick_1(object sender, DataGridViewCellEventArgs e)
        {

        }
    }
}
