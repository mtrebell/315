using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;
using System.Text.RegularExpressions;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string sTemp = HttpContext.Current.Request.Url.AbsoluteUri;     // get current url 
        
        Regex r = new Regex("[^0-9.]");     // only collect numeric characters

        sTemp = r.Replace(sTemp, "");           // remove all non numbers
        int iEliminate = sTemp.IndexOf('.');    // get place holder 

        sTemp = sTemp.Remove(0, iEliminate + 1);    // eleimate rogue period

        int iMovieIndex= -1;
        try
        {
            iMovieIndex = int.Parse(sTemp.Replace("MoreInfo.aspx?idx=", ""));   // get movie index from url
        }
        catch (FormatException)
        {
            iMovieIndex = -1;
        }
        if (iMovieIndex != -1)
            ShowMoreInfo(iMovieIndex);      // launch show info
       
        else
            DIV_Plot.InnerHtml = ("Movie Content Not Found");
    }

    private void ShowMoreInfo(int iInput)
    {
        if (iInput != -1)
        {
            // SELECT mov_smPoster, mov_title, mov_rating, mov_runTime 
            SqlDataReader sdr = Middleware.MovieDisplayMoreInfo(iInput);    // get database info
            while (sdr.Read())
            {
                //Display all movie information to screen
                System.Web.UI.WebControls.Image imgPoster = new System.Web.UI.WebControls.Image();
                if (!sdr[0].ToString().ToLower().Contains("notfound"))
                    IMG_Poster.ImageUrl = sdr[0].ToString();
                else
                    IMG_Poster.ImageUrl = "~/Background_Images/MissingPoster.jpg";

                imgPoster.Height = 400;
                imgPoster.Width = 280;

                LBL_Title.Text = sdr[1].ToString();
                LBL_Rating.Text = "Rating: " + sdr[3].ToString();
                LBL_Runtime.Text = "Runtime: " + sdr[2].ToString();
                LBL_File_Size.Text = "File Type: " + sdr[4].ToString() + " - Size: " + sdr[5].ToString();
                LBL_Date.Text = "Date Added: " + sdr[6].ToString();
                DIV_Plot.InnerHtml =  sdr[7].ToString().Length > 1 ? sdr[7].ToString() : "No Plot Synopsis";
                BTN_imdb.PostBackUrl = sdr[8].ToString();
            }
        }
    }

    /// <summary>
    /// Add as favorite to database using url movie index
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void BTN_Favorite_Click(object sender, EventArgs e)
    {
        string sTemp = HttpContext.Current.Request.Url.AbsoluteUri;
        
        Regex r = new Regex("[^0-9.]");     // remove all non numerics

        sTemp = r.Replace(sTemp, "");       // removal
        int iEliminate = sTemp.IndexOf('.');    // remove rogue period

        sTemp = sTemp.Remove(0, iEliminate + 1);

        string sMovieIndex= "";
        try
        {
            sMovieIndex = sTemp.Replace("MoreInfo.aspx?idx=", "");   // get movie index
        }
        catch (FormatException)
        {
            sMovieIndex = "";
        }
        if (sMovieIndex != "")
        {
            Guid gUserID = (Guid)Membership.GetUser().ProviderUserKey;  // get current user
            Middleware.InsertIntoFavorites(sMovieIndex, gUserID);       // add to favorites table
        }
    }
}

