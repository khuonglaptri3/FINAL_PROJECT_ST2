using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FINAL_PROJECT_ST2
{
    class DatabaseHelper
    {
        private string _connectionString;

        public string ConnectionString
        {
            get => _connectionString;
            set => _connectionString = value;
        }
        public DatabaseHelper()
        {
            ConnectionString = @"Data Source=KHUONG;Initial Catalog=TEST_DATABASE;Integrated Security=True;Encrypt=False;TrustServerCertificate=True";
        }
        public DatabaseHelper(string connectionString)
        {
            ConnectionString = connectionString;
        }
        public SqlConnection CreateConnection()
        {
            return new SqlConnection(ConnectionString);
        }
        // Truy vấn SELECT, trả về DataTable
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

}

}
