using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;
using System.Data;
using System.Web.Services;
using System.Text;

public partial class _Default : System.Web.UI.Page
{
    private static string sConnectionString = ConfigurationManager.ConnectionStrings["InternalConnectionString"].ConnectionString;

    public string ServerRootPath
    {
        get
        {
            string sPath = Server.MapPath("~/Image_Posters/").Replace("/", "\\");
            sPath = sPath.Replace('\\', '~');
            return sPath;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
            createAccordianUsingRepeater();
    }


    [WebMethod()]
    public static int DeleteAllMedia(string sPath)
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
        string sImageRoot = (sPath).Replace('~', '\\');
        foreach (string s in Directory.GetFiles(sImageRoot))
            File.Delete(s);

        return 0;
    }

    [WebMethod()]
    public static int DeleteEntryDb(string sPath, string mov_id)
    {
        string  s = Middleware.DeleteEntry(mov_id);
        return 0;
    }

    [WebMethod()]
    public static string UpdateEntryDb(string sPath, string mov_id)
    {
        StringBuilder sb = new StringBuilder();
        using (SqlDataReader sdr = Middleware.GetMovieData(mov_id))
        {
            sdr.Read();
            sb.Append(sdr[0].ToString()).Append('|').Append(sdr[1].ToString()).Append('|').Append(sdr[2].ToString()).Append('|');
            sb.Append(sdr[3].ToString()).Append('|').Append(sdr[4].ToString()).Append('|').Append(sdr[5].ToString()).Append('|');
            sb.Append(sdr[6].ToString()).Append('|').Append(sdr[7].ToString()).Append('|').Append(sdr[8].ToString()).Append('|');
            sb.Append(sdr[9].ToString().Replace("~", "..")).Append('|').Append(sdr[10].ToString().Replace("~", "..")).Append('|').Append(sdr[11].ToString()).Append('|');
            sb.Append(sdr[12].ToString());
        }
        return sb.ToString();
    }


    public void createAccordianUsingRepeater()
    {
        rptAccordian.DataSource = createDataTable();
        rptAccordian.DataBind();
    }

    public DataTable createDataTable()
    {
        System.Data.SqlClient.SqlConnection conn =
            new System.Data.SqlClient.SqlConnection(
            ConfigurationManager.ConnectionStrings["InternalConnectionString"].ConnectionString);
        DataTable dt = new DataTable();
        SqlCommand cmd = new SqlCommand();
        SqlDataAdapter da = new SqlDataAdapter();

        cmd = new SqlCommand("SelectTitle", conn);
        cmd.CommandType = CommandType.StoredProcedure;
        da.SelectCommand = cmd;
        da.Fill(dt);

        return dt;
    }
}