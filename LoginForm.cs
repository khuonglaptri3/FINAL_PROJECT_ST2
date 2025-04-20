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
    public partial class LoginForm : Form
    {
        DatabaseHelper connect;
        public LoginForm()
        {
            InitializeComponent();
            connect = new DatabaseHelper();
        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void label1_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void Loginbut_Click(object sender, EventArgs e)
        {
            if (Username.Text == "" || Password.Text == "")
            {
                MessageBox.Show("Please fill in the required information", "Error Message", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            try
            {
                // 🔐 Thiết lập lại connection string theo user SQL nhập vào
                DatabaseHelper.SetConnection(Username.Text, Password.Text);

                // 🔌 Tạo kết nối và mở thử (nếu sai user/pass → SQL Server sẽ báo lỗi)
                using (SqlConnection conn = new DatabaseHelper().CreateConnection())
                {
                    conn.Open(); // kiểm tra đăng nhập thật sự SQL Server

                    bool check = false;

                    // ✅ Kiểm tra tên đăng nhập + mật khẩu có tồn tại trong bảng DANG_NHAP không
                    using (SqlCommand cmd = new SqlCommand("SELECT dbo.fn_KiemTraDangNhap(@Tentaikhoan, @Matkhau)", conn))
                    {
                        cmd.Parameters.AddWithValue("@Tentaikhoan", Username.Text);
                        cmd.Parameters.AddWithValue("@Matkhau", Password.Text);

                        object result = cmd.ExecuteScalar();
                        if (result != null)
                        {
                            check = Convert.ToBoolean(result);
                        }
                    }

                    if (check)
                    {
                        MessageBox.Show("Login successful", "Success Message", MessageBoxButtons.OK, MessageBoxIcon.Information);

                        int maNND = -1;
                        using (SqlCommand cmd = new SqlCommand("SELECT dbo.fn_GetMaNND(@Tentaikhoan, @Matkhau)", conn))
                        {
                            cmd.Parameters.AddWithValue("@Tentaikhoan", Username.Text);
                            cmd.Parameters.AddWithValue("@Matkhau", Password.Text);
                            object result = cmd.ExecuteScalar();
                            if (result != null && result != DBNull.Value)
                                maNND = Convert.ToInt32(result);
                        }

                        // 👉 Phân quyền mở Form theo MaNND
                        switch (maNND)
                        {
                            case 2 :
                                new FINAL_PROJECT_ST2.Nhanvienbanhangform.Nhanvienbanhang().Show();
                                this.Hide();
                                break;
                            case 3:
                                new FINAL_PROJECT_ST2.ChucuahangForm.chucuahangform().Show();
                                this.Hide();
                                break;
                            case 4:
                                new FINAL_PROJECT_ST2.Nhanvienbanhangform.Nhanvienbanhang().Show();
                                this.Hide();
                                break;
                            default:
                                MessageBox.Show("Bạn không có quyền truy cập ứng dụng.", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                                break;
                        }
                    }
                    else
                    {
                        MessageBox.Show("Sai tài khoản hoặc mật khẩu.", "Đăng nhập thất bại", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi kết nối SQL Server: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void panel2_Paint(object sender, PaintEventArgs e)
        {

        }

        private void panel3_Paint(object sender, PaintEventArgs e)
        {

        }
    }
    }    
