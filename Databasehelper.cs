using System;
using System.Data;
using System.Data.SqlClient;

namespace FINAL_PROJECT_ST2
{
    class DatabaseHelper
    {
        public static string CurrentConnectionString { get; private set; }

        // Đặt mặc định là Integrated Security
        static DatabaseHelper()
        {
            CurrentConnectionString = @"Data Source=KHUONG;Initial Catalog=TEST_DATABASE;Integrated Security=True;Encrypt=False;TrustServerCertificate=True";
        }

        // Cấu hình chuỗi kết nối bằng user/password SQL Server
        //public static void SetConnection(string user, string password)
        //{
        //    CurrentConnectionString = $"Data Source=KHUONG;Initial Catalog=TEST_DATABASE;User ID={user};Password={password};Encrypt=False;TrustServerCertificate=True";
        //}
        public static void SetConnection(string user, string password)
        {
            //CurrentConnectionString = $"Data Source=KHUONG;Initial Catalog=TEST_DATABASE;User ID=hoasales;Password=sales456 ;Encrypt=False;TrustServerCertificate=True
            CurrentConnectionString = @"Data Source=KHUONG;Initial Catalog=TEST_DATABASE;Integrated Security=True;Encrypt=False;TrustServerCertificate=True";

        }
        // Tạo kết nối từ chuỗi tĩnh
        public SqlConnection CreateConnection()
        {
            return new SqlConnection(CurrentConnectionString);
        }

        // Truy vấn trả về bảng
        public DataTable ExecuteQuery(string query, SqlParameter[] parameters = null)
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = CreateConnection())
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                if (parameters != null)
                    cmd.Parameters.AddRange(parameters);

                using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                {
                    adapter.Fill(dt);
                }
            }

            return dt;
        }
        // Truy vấn trả về giá trị đơn giản (scalar)
        public T ExecuteScalar<T>(string query, SqlParameter[] parameters = null)
        {
            using (SqlConnection conn = CreateConnection())
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                if (parameters != null)
                    cmd.Parameters.AddRange(parameters);

                conn.Open();
                object result = cmd.ExecuteScalar();
                conn.Close();

                if (result != null && result != DBNull.Value)
                    return (T)Convert.ChangeType(result, typeof(T));
                else
                    return default(T);
            }
        }

    }
}
