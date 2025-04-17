using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace FINAL_PROJECT_ST2
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new FINAL_PROJECT_ST2.ChucuahangForm.chucuahangform());
            //FINAL_PROJECT_ST2.Nhanvienbanhangform.Nhanvienbanhang()
        }
    }
}
