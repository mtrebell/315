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
using System.Security.Cryptography;

public partial class _Default : System.Web.UI.Page
{
    private static string sConnectionString = Middleware.ConnectionString;
    private static string sUpload;
    private static string sImages;

    public string ServerRootPath
    {
        get
        {
            string sPath = Server.MapPath("Image_Posters/").Replace("/", "\\");
            sPath = sPath.Replace('\\', '~');
            return sPath;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
            createAccordianUsingRepeater();

        sUpload = Server.MapPath("~/Upload");
        sImages = Server.MapPath("~/Image_Posters");

        using (SqlDataReader sdr = Middleware.MovieDisplayContent())
        {
            StringBuilder sb = new StringBuilder();
            if (sdr.HasRows)
            {
                while (sdr.Read())
                    sb.Append(sdr[4].ToString()).Append('|');
                sb.Remove(sb.Length - 1, 1);

                hf_usedindexes.Value = sb.ToString();
            }
        }

        using (SqlDataReader sdr = Middleware.GetAllGenreOptions())
        {
            while (sdr.Read())
            {
                Edit_mov_genre.Items.Add(sdr[1].ToString());
                Add_mov_genre.Items.Add(sdr[1].ToString());
            }
        }
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
            sb.Append(sdr[9].ToString().Replace("~", "..")).Append('|').Append(sdr[10].ToString().Replace("~", "..")).Append('|');
            sb.Append(sdr[11].ToString()).Append('|').Append(sdr[12].ToString()).Append('|').Append(sdr[13].ToString()).Append('|');
            sb.Append(sdr[14]).Append("|").Append(sdr[15]).Append("|").Append(sdr[16]).Append("|");       
            sb.Append(sdr[17]).Append("|").Append(sdr[18]).Append("|").Append(sdr[19]).Append("|"); 
            sb.Append(sdr[20]).Append("|").Append(sdr[21].ToString());
        }
        return sb.ToString();
    }

    [WebMethod()]
    public static string commitUpdateDB(string mov_id, string mov_title, string mov_plot, string mov_genre, string mov_size, 
			string mov_fileType, string mov_dateAdded, string mov_rating, string mov_rottenID, float mov_rottenRating, string mov_runTime, string mov_lgPoster, 
			string mov_smPoster, string mov_directors, string mov_writers, string mov_cast, string mov_producers, string mov_oscars, 
            string mov_nominations, string mov_plotkeywords, string mov_trailer, string mov_imdbUrl, bool updatedLg, bool updatedSm)
    {
        string lgPoster = "",
               smPoster = "";

        using (SqlDataReader sdr = Middleware.CheckChange(mov_id))
        {
            sdr.Read();
            lgPoster = sdr[0].ToString().Replace("~", "..");
            smPoster = sdr[1].ToString().Replace("~", "..");
        }

        if (updatedLg)
            lgPoster= TransferImageFromUpload(mov_lgPoster, "lg");
        if (updatedSm)
            smPoster = TransferImageFromUpload(mov_smPoster, "sm");

        Middleware.UpdateEntry(mov_id, mov_title, mov_plot, mov_genre, mov_size, mov_fileType, mov_dateAdded,
            mov_rating, mov_rottenID, mov_rottenRating, mov_runTime, lgPoster.Replace("..", "~"), smPoster.Replace("..", "~"),
            mov_directors, mov_writers, mov_cast, mov_producers, mov_oscars, mov_nominations, mov_plotkeywords,
            mov_trailer, mov_imdbUrl, "UpdateTitle");

        foreach (FileInfo f in new DirectoryInfo(sUpload).EnumerateFiles())
            File.Delete(f.FullName);

        StringBuilder sb = new StringBuilder();
        sb.Append(mov_id).Append("|").Append(mov_title).Append("|").Append(mov_plot).Append("|");                //  0 -  2
        sb.Append(mov_genre).Append("|").Append(mov_size).Append("|").Append(mov_fileType).Append("|");          //  3 -  5
        sb.Append(mov_dateAdded).Append("|").Append(mov_rating).Append("|");                                     //  6 -  7
        sb.Append(mov_runTime).Append("|").Append(lgPoster).Append("|").Append(smPoster).Append("|");            //  8 - 10
        sb.Append(mov_directors).Append("|").Append(mov_writers).Append("|").Append(mov_cast).Append("|");       // 11 - 13
        sb.Append(mov_producers).Append("|").Append(mov_oscars).Append("|").Append(mov_nominations).Append("|"); // 14 - 16
        sb.Append(mov_plotkeywords).Append("|").Append(mov_trailer).Append("|").Append(mov_imdbUrl).Append('|'); // 17 - 19
        sb.Append(mov_rottenID).Append('|').Append(mov_rottenRating);                                            // 20 - 21

        return sb.ToString();
    }

    [WebMethod()]
    public static string AddEntryDB(string mov_id, string mov_title, string mov_plot, string mov_genre, string mov_size,
            string mov_fileType, string mov_rating, string mov_rottenID, float mov_rottenRating, string mov_runTime, string mov_lgPoster,
            string mov_smPoster, string mov_directors, string mov_writers, string mov_cast, string mov_producers, string mov_oscars,
            string mov_nominations, string mov_plotkeywords, string mov_trailer, string mov_imdbUrl, bool updatedLg, bool updatedSm)
    {
        string lgPoster = "",
               smPoster = "";

        if (updatedLg)
            lgPoster = TransferImageFromUpload(mov_lgPoster, "lg");
        if (updatedSm)
            smPoster = TransferImageFromUpload(mov_smPoster, "sm");

        Middleware.UpdateEntry(mov_id, mov_title, mov_plot, mov_genre, mov_size, mov_fileType, DateTime.Now.ToShortDateString(),
            mov_rating, mov_rottenID, mov_rottenRating, mov_runTime, lgPoster.Replace("..", "~"), smPoster.Replace("..", "~"),
            mov_directors, mov_writers, mov_cast, mov_producers, mov_oscars, mov_nominations, mov_plotkeywords,
            mov_trailer, mov_imdbUrl, "InsertTitle");

        StringBuilder sb = new StringBuilder();
        sb.Append(mov_id).Append("|").Append(mov_title).Append("|").Append(mov_plot).Append("|");                //  0 -  2
        sb.Append(mov_genre).Append("|").Append(mov_size).Append("|").Append(mov_fileType).Append("|");          //  3 -  5
        sb.Append(DateTime.Now.ToShortDateString()).Append("|").Append(mov_rating).Append("|");                  //  6 -  7
        sb.Append(mov_runTime).Append("|").Append(lgPoster.Replace("~", ".."));                                  //  8 -  9
        sb.Append("|").Append(smPoster.Replace("~", "..")).Append("|");                                          //      10
        sb.Append(mov_directors).Append("|").Append(mov_writers).Append("|").Append(mov_cast).Append("|");       // 11 - 13
        sb.Append(mov_producers).Append("|").Append(mov_oscars).Append("|").Append(mov_nominations).Append("|"); // 14 - 16
        sb.Append(mov_plotkeywords).Append("|").Append(mov_trailer).Append("|").Append(mov_imdbUrl).Append('|'); // 17 - 19
        sb.Append(mov_rottenID).Append('|').Append(mov_rottenRating);                                            // 20 - 21

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
            Middleware.ConnectionString);
        DataTable dt = new DataTable();
        SqlCommand cmd = new SqlCommand();
        SqlDataAdapter da = new SqlDataAdapter();

        cmd = new SqlCommand("SelectTitle", conn);
        cmd.CommandType = CommandType.StoredProcedure;
        da.SelectCommand = cmd;
        da.Fill(dt);

        return dt;
    }

    private static string TransferImageFromUpload(string newImg, string type)
    {
        string newImageName = newImg.Substring(newImg.LastIndexOf("/") + 1, 
            newImg.Length - newImg.LastIndexOf("/") -1);
        string newImageExt = newImageName.Substring(newImageName.LastIndexOf("."),
            newImageName.Length - newImageName.LastIndexOf("."));

        string newConverted = 
            GetMd5Hash(MD5.Create(), newImageName.Replace(newImageExt,"") + type) + newImageExt;

        if (File.Exists(Path.Combine(sUpload, newImageName)))
        {
            if (File.Exists(Path.Combine(sImages, newConverted)))
                File.Delete(Path.Combine(sImages, newConverted));
            File.Move(Path.Combine(sUpload, newImageName), Path.Combine(sImages, newConverted));
        }

        return "../Image_Posters/" + newConverted;
    }

    private static string GetMd5Hash(MD5 md5Hash, string input)
    {
        // Convert the input string to a byte array and compute the hash. 
        byte[] data = md5Hash.ComputeHash(Encoding.UTF8.GetBytes(input));

        // Create a new Stringbuilder to collect the bytes 
        // and create a string.
        StringBuilder sBuilder = new StringBuilder();

        // Loop through each byte of the hashed data  
        // and format each one as a hexadecimal string. 
        for (int i = 0; i < data.Length; i++)
        {
            sBuilder.Append(data[i].ToString("x2"));
        }

        // Return the hexadecimal string. 
        return sBuilder.ToString();
    }
}