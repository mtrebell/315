﻿using System;
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
    private static Thread _tUpload = null;

    // connection string to database
    private static string sConnect = ConfigurationManager.ConnectionStrings["InternalConnectionString"].ConnectionString;

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
    [WebMethod()]
    public static int RunServer(object hiddenListContent, object imageRootPath)
    {
        _tUpload = new Thread(
            delegate()
            {
                string sImageRoot = ((string)imageRootPath).Replace('~', '\\');
                GetIMDBData(new string[] { sConnect, (string) hiddenListContent, sImageRoot });
            });
        _tUpload.IsBackground = true;
        _tUpload.Start();

        return 0;
    }

    /// <summary>
    /// Cancel Scraper event 
    /// </summary>

    [WebMethod()]
    public static int CancelServer()
    {
        if (_tUpload != null)
            _tUpload.Abort();

        return 0;
    }

    #endregion
    /// <summary>
    /// Scraper Method
    /// Used in thead call to compare all filenames in library against a database
    /// search
    /// </summary> 
    private static void GetIMDBData(object state)
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
            string sTitle, sExt, sSize;
            SplitFileInfo(sFile, out sTitle, out sExt, out sSize);

            // if it is in the media filter type
            if (IsMediaContent(sExt))
            {
                // if title is not currently in the database
                if (!TitleExists(sTitle, connect))
                {
                    Console.WriteLine(sTitle + " does not exist");
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
    private static bool IsMediaContent(string ext)
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
    private static void SplitFileInfo(string sInput, out string sTitle, out string sExtension, out string sSize)
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
    private static void UpdateDataBase(IMDb IMDbIn, string sTitle, string sFileExt, string sFileSize, string connect, string imagePath)
    {
        string sSize = string.Format("{0:f3} MBytes", long.Parse(sFileSize)/(1024.0 * 1024.0));   // convert byte size to Mbytes
        Regex rgx = new Regex("[^a-zA-Z0-9 -]");   // remove non alpha characters

        string sMovieTitle = rgx.Replace(sTitle, "");    // get stripped movie title

        #region Build Genre Code
        Dictionary<string, string> dicGenres = new Dictionary<string, string>();
        using (SqlDataReader sdr = Middleware.GetAllGenreOptions())
        {
            while (sdr.Read())
                dicGenres.Add(sdr.GetString(1).ToLower().Trim(), ((int) sdr.GetSqlInt32(0)).ToString("00").ToLower().Trim());
            sdr.Close();
        }

        StringBuilder sbGenreCode = new StringBuilder();
        if (IMDbIn.Genres != null)
        { 
            foreach (string s in IMDbIn.Genres)
                if (dicGenres.ContainsKey(s.ToLower().Trim()))
                    sbGenreCode.Append(s.ToLower().Trim()).Append(", ");
        }
        #endregion
        
        try
        {
            using (SqlConnection con = new SqlConnection(connect)) //create database connection
            {
                con.Open(); // create insert condition
                using (SqlCommand ins = new SqlCommand(
                        "INSERT INTO MovieSummary (mov_id, mov_title, mov_plot, mov_genre, mov_size, mov_fileType, mov_runtime,mov_rating, mov_smPoster, mov_lgPoster, mov_imdbUrl)" +
                                    "VALUES (@Mid, @Ti, @Pl, @Gr, @Si, @Fi, @Rt, @Ra, @Sm, @Lg, @Im )", con))
                {
                    // add all imdb parameters to insert statement
                    ins.Parameters.AddWithValue("@Mid", IMDbIn.Id);
                    ins.Parameters.AddWithValue("@Ti", sTitle);
                    ins.Parameters.AddWithValue("@Pl", IMDbIn.Plot);
                    ins.Parameters.AddWithValue("@Si", sSize);
                    ins.Parameters.AddWithValue("@Fi", sFileExt);
                    ins.Parameters.AddWithValue("@Rt", IMDbIn.Runtime);
                    ins.Parameters.AddWithValue("@Ra", IMDbIn.Rating);
                    ins.Parameters.AddWithValue("@Im", IMDbIn.ImdbURL.ToString());

                    #region Determine IMDB Image Posters
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
                    #endregion

                    ins.Parameters.AddWithValue("@Gr", sbGenreCode.Length > 0 ?
                        sbGenreCode.ToString(): dicGenres["unassigned"]);

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

    public static byte[] getImageFromURL(String sURL)
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
    private static bool TitleExists(string sMovieTitle, string connect)
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