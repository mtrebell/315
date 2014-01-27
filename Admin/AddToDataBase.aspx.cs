using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Threading;
using System.IO;
using System.Text.RegularExpressions;
using System.Data.SqlClient;
using System.Configuration;
using System.ComponentModel;
using System.Web.Services;
using System.Security.Cryptography;
using System.Net;
using System.Text;

public partial class _Default : System.Web.UI.Page
{
    public static int Percentage { get; set; }

    // connection string to database
    private string sConnect = ConfigurationManager.ConnectionStrings["InternalConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            MV_AddMedia.ActiveViewIndex = 1;
            Session["KillTask"] = "false";
        }

        Percentage = 0;
    }

    [WebMethod()]
    public static int GetProgress()
    {
        return Percentage;
    }

    #region button options
    /// <summary>
    /// Initialize Scraper event 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void AddSelected_Click(object sender, EventArgs e)
    {
        ThreadPool.QueueUserWorkItem(new WaitCallback(GetIMDBData),
            new string[] { sConnect, Request.Form["HiddenList"].ToString(), Server.MapPath("~/Image_Posters/")});

        Session["KillTask"] = "false";
        MV_AddMedia.ActiveViewIndex = 0;
    }

    protected void BTN_Cancel_Click(object sender, EventArgs e)
    {
        Session["KillTask"] = "true";
        MV_AddMedia.ActiveViewIndex = 1;
    }

    protected void Button1_Click(object sender, EventArgs e)
    {
        MV_AddMedia.ActiveViewIndex = 1;
    }
    #endregion
    /// <summary>
    /// Scraper Method
    /// Used in thead call to compare all filenames in library against a database
    /// search
    /// </summary> 
    private void GetIMDBData(object state)
    {
        #region Get Input arguments
        string[] saData = (string[]) state;
        string connect = saData[0],
               retention = saData[1],
               imagePath = saData[2];
        
        if (retention == null || connect == null)
            return;
        
        List<string> values = retention.TrimEnd('|').Split('|').ToList();   // split apart each file in list
        values.RemoveAll(value => value.Equals(string.Empty));              // remove blanks
        values.Sort();
        #endregion  
        
        int iCount = 0;
        // foreach filename 
        foreach (string sFile in values)
        {
            if (Session["KillTask"].Equals("true"))
                return;

            string sTitle, sExt, sSize;
            SplitFileInfo(sFile, out sTitle, out sExt, out sSize);

            // if it is in the media filter type
            if (IsMediaContent(sExt))
            {
                // if title is not currently in the database
                if (!TitleExists(sTitle, connect))
                {
                    Console.WriteLine(sTitle + " dows not exist");
                    IMDb oItem = new IMDb(sTitle, false);                 // Get IMDb database file from file name 
                    UpdateDataBase(oItem, sTitle, sExt, sSize, connect, imagePath);  // call method to add IMDb to database
                }
                else
                    Console.WriteLine(sTitle + " exists");
            }
            Percentage = (int) ((iCount++/ (float) values.Count) * 100);
        }
        Percentage = 100;
    }

    #region IMDB support functions
    /// <summary>
    /// Filter check for movie file extensions
    /// On reflection should have used regex
    /// </summary>
    /// <param name="fi">file info check</param>
    /// <returns></returns>
    private bool IsMediaContent(string ext)
    {
        List<string> lsExtensions = new List<string>() 
           { ".wmv", ".mkv", ".avi", "divx", "xvid", ".mp4",".mpeg", ".h264", ".x264", ".m2ts" };

        return lsExtensions.Contains(ext);
    }

    /// <summary>
    /// Breaks up the single file string input into its respective peices
    /// </summary>
    /// <param name="sInput">single file input</param>
    /// <param name="sTitle">file title</param>
    /// <param name="sExtension">file extension</param>
    /// <param name="sSize">size of file</param>
    private void SplitFileInfo(string sInput, out string sTitle, out string sExtension, out string sSize)
    {
        string[] saFileAttrib = sInput.Split('~');        // split file sub information

        // retrieve proper file name and extension
        int iExtIdx = saFileAttrib[0].LastIndexOf('.');
        sExtension = saFileAttrib[0].Substring(iExtIdx, saFileAttrib[0].Length - iExtIdx);
        sTitle = saFileAttrib[0].Substring(0, iExtIdx);
        sSize = saFileAttrib[2];
    }

    /// <summary>
    /// Database insert method 
    /// used to update the movie summary table in final project database
    /// </summary>
    /// <param name="IMDbIn">imdb info insert</param>
    /// <param name="fiIn">file info insert</param>
    private void UpdateDataBase(IMDb IMDbIn, string sTitle, string sFileExt, string sFileSize, string connect, string imagePath)
    {
        string sSize = string.Format("{0:f3} MBytes", long.Parse(sFileSize)/(1024.0 * 1024.0));   // convert byte size to Mbytes
        Regex rgx = new Regex("[^a-zA-Z0-9 -]");   // remove non alpha characters

        string sMovieTitle = rgx.Replace(sTitle, "");    // get stripped movie title
        
        try
        {
            using (SqlConnection con = new SqlConnection(connect)) //create database connection
            {
                con.Open(); // create insert condition
                using (SqlCommand ins = new SqlCommand(
                        "INSERT INTO MovieSummary (mov_title, mov_plot, mov_size, mov_fileType, mov_runtime,mov_rating, mov_smPoster, mov_lgPoster, mov_imdbUrl)" +
                                    "VALUES (@Ti, @Pl, @Si, @Fi, @Rt, @Ra, @Sm, @Lg, @Im )", con))
                {
                    // add all imdb parameters to insert statement
                    ins.Parameters.AddWithValue("@Ti", sTitle);
                    ins.Parameters.AddWithValue("@Pl", IMDbIn.Plot);
                    ins.Parameters.AddWithValue("@Si", sSize);
                    ins.Parameters.AddWithValue("@Fi", sFileExt);
                    ins.Parameters.AddWithValue("@Rt", IMDbIn.Runtime);
                    ins.Parameters.AddWithValue("@Ra", IMDbIn.Rating);
                    ins.Parameters.AddWithValue("@Im", IMDbIn.ImdbURL.ToString());

                    string rootImagePath = imagePath;
                    if (!Directory.Exists(rootImagePath))
                        Directory.CreateDirectory(rootImagePath);
            
                    byte[] imgSavesm = getImageFromURL(IMDbIn.Poster);
                    if (imgSavesm != null)
                    {
                        string hashSm = GetMd5Hash(MD5.Create(), sMovieTitle + "sm");
                        using (FileStream fs = new FileStream(Path.Combine(rootImagePath, hashSm + ".jpg"), FileMode.OpenOrCreate, FileAccess.Write))
                        {
                            fs.Write(imgSavesm, 0, imgSavesm.Length);
                            ins.Parameters.AddWithValue("@Sm", "~/Image_Posters/" + hashSm + ".jpg");
                            fs.Close();
                        }
                    }
                    else
                        ins.Parameters.AddWithValue("@Sm", "NOTFOUND");

                    byte[] imgSaveLg = getImageFromURL(IMDbIn.PosterFull);
                    if (imgSavesm != null)
                    {
                        string hashLg = GetMd5Hash(MD5.Create(), sMovieTitle + "lg");
                        using (FileStream fs = new FileStream(Path.Combine(rootImagePath, hashLg + ".jpg"), FileMode.OpenOrCreate, FileAccess.Write))
                        {
                            fs.Write(imgSavesm, 0, imgSavesm.Length);
                            ins.Parameters.AddWithValue("@Lg", "~/Image_Posters/" + hashLg + ".jpg");
                            fs.Close();
                        }
                    }
                    else
                        ins.Parameters.AddWithValue("@Lg", "NOTFOUND");
                    

                    ins.ExecuteNonQuery();  // run insert
                }
                con.Close();              
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
        }
    }

    public byte[] getImageFromURL(String sURL)
    {
        try
        {
            MemoryStream ms = new MemoryStream();
            if (sURL.Length == 0)
                return null;
            HttpWebRequest myRequest = (HttpWebRequest)WebRequest.Create(sURL);
            myRequest.Method = "GET";
            HttpWebResponse myResponse = (HttpWebResponse)myRequest.GetResponse();
            System.Drawing.Bitmap bmp = new System.Drawing.Bitmap(myResponse.GetResponseStream());
            myResponse.Close();

            bmp.Save(ms, System.Drawing.Imaging.ImageFormat.Jpeg);
            ms.Close();
            return ms.GetBuffer();
        }
        catch (ArgumentException)
        {
            return null;
        }
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

    /// <summary>
    /// Check to see if movie name already exist in the database
    /// </summary>
    /// <param name="fi">file info check</param>
    /// <returns>if found condition</returns>
    private bool TitleExists(string sMovieTitle, string connect)
    {
        try
        {
            Regex rgx = new Regex("[^a-zA-Z0-9 -]");                // regex condition, strip all non characters
            sMovieTitle = rgx.Replace(sMovieTitle, "");             // clean title
        }
        catch (ArgumentNullException)
        {
            return true;
        }

        SqlConnection conn = new SqlConnection(connect);       // create connection to database
        // create select condition for check
        SqlCommand cmd = new SqlCommand("Select mov_title from MovieSummary where mov_title like '%" + sMovieTitle + "%'", conn);
        SqlDataReader sReader = null;
        bool bExists = false;

        try
        {
            conn.Open();
            sReader = cmd.ExecuteReader();      // get database feedback
            if (sReader.HasRows)                // if file found indicates exist
                bExists = true;
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
        }
        finally
        { conn.Close(); }

        return bExists;
    }
    #endregion
}