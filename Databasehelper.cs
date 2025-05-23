﻿using System;
using System.Data;
using System.Data.SqlClient;

namespace FINAL_PROJECT_ST2
{
    class DatabaseHelper
    {
        public static string CurrentConnectionString { get; private set; }
        public static string username { get; set; }
        public static string password { get; set; }   
        public string Username
        {
            get { return username; }
            set { username = value; }
        }
        public string Password
        {
            get { return password; }
            set { password = value; }
        }    

        // Đặt mặc định là Integrated Security
        static DatabaseHelper()
        {
            CurrentConnectionString = @"Data Source=KHUONG;Initial Catalog=khuong;User ID={user};Password={password};Encrypt=False;Trust Server Certificate=True";
            // Data Source=KHUONG\SQLEXPRESS;Initial Catalog=DATABASESCRIPS;Integrated Security=True;Encrypt=False;TrustServerCertificate=True
            //Data Source=KHUONG\SQLEXPRESS;Initial Catalog=QUAN_LY_CUA_HANG;Integrated Security=True;Encrypt=False;Trust Server Certificate=True
            // Data Source=KHUONG;Initial Catalog=Test;Integrated Security=True;Encrypt=False;Trust Server Certificate=True
        }
        // Data Source=KHUONG\SQLEXPRESS;Initial Catalog=ffff;Integrated Security=True;Encrypt=False;Trust Server Certificate=True
        //Cấu hình chuỗi kết nối bằng user/password SQL Server
        // Data Source=KHUONG\SQLEXPRESS;Initial Catalog=KHUONG;Integrated Security=True;Encrypt=False;Trust Server Certificate=True
        public static void SetConnection(string user, string password)
        {
            CurrentConnectionString = $"Data Source=KHUONG\\SQLEXPRESS;Initial Catalog=KHUONGGGG;User ID={user};Password={password};Encrypt=False;TrustServerCertificate=True";
        }
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
        public static string GetThongTinDangNhap(string tenTaiKhoan, string matKhau)
        {
            string query = "SELECT dbo.fn_GetThongTinDangNhap(@TenTaiKhoan, @MatKhau)";

            SqlParameter[] parameters = new SqlParameter[]
            {
        new SqlParameter("@TenTaiKhoan", tenTaiKhoan),
        new SqlParameter("@MatKhau", matKhau)
            };

            DatabaseHelper db = new DatabaseHelper();
            return db.ExecuteScalar<string>(query, parameters);
        }


    }
}
