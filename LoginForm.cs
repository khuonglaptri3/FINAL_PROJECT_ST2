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
            }
            else
            {
                    try
                    {
                    SqlConnection conn = connect.CreateConnection();    
                    conn.Open();     
                    bool check = false; // Biến kiểm tra đăng nhập   
                    using (SqlCommand cmd = new SqlCommand("SELECT dbo.fn_KiemTraDangNhap(@Tentaikhoan, @Matkhau)", conn ))
                        {
                            cmd.Parameters.AddWithValue("@Tentaikhoan", Username.Text);
                            cmd.Parameters.AddWithValue("@Matkhau", Password.Text);

                            // Dùng ExecuteScalar để lấy kết quả trả về từ hàm
                            object result = cmd.ExecuteScalar();
                            if (result != null)
                            {
                                check = Convert.ToBoolean(result);
                            }
                        }
                    // haha

                        if (check)
                        {
                            MessageBox.Show("Login successful", "Success Message", MessageBoxButtons.OK, MessageBoxIcon.Information);
                            // Có thể mở form chính tại đây
                        }
                        else
                        {
                            MessageBox.Show("Login failed", "Error Message", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        }
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show("Error connecting Database : " + ex.Message, "Error Message", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                    finally
                    {
                    
                    }
                }
            }

        private void panel2_Paint(object sender, PaintEventArgs e)
        {

        }
    }
    }    
