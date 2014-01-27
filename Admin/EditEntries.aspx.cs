using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;

public partial class _Default : System.Web.UI.Page
{
    private string sConnectionString = ConfigurationManager.ConnectionStrings["InternalConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void BTN_ClearAllMedia_Click(object sender, EventArgs e)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(sConnectionString);  // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())                      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // call stored procedure
            comm.CommandText = "ClearMediaDB";                   // name of procedure
            // Make Parameter
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute procedure 
        }
        string sPath = Server.MapPath("~/Image_Posters/");
        foreach (string s in Directory.GetFiles(sPath))
            File.Delete(s);

        GV_EditDatabase.DataBind();
    }
}