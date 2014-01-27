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
using System.Web.UI.HtmlControls;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {       
        if (!Page.IsPostBack)
        {
            TB_Search.Attributes.Add("onkeydown", "return (event.keyCode!=13);");   // add keydown condition to texbox
            LBL_TotalCount.Text = string.Format("{0} Movies in collection", GenerateMovieAlphaFilters());    // display movies
        }
        else if (Page.IsPostBackEventControlRegistered)
            LBL_TotalCount.Text = string.Format("{0} Movies in collection", GenerateMovieAlphaFilters());    // display movies
    }

    protected void Alpha_Menu_MenuItemClick(object sender, EventArgs e)
    {
        // redo movie list with filtered results
        LBL_TotalCount.Text = string.Format("{0} Movies in collection", GenerateMovieAlphaFilters());
    }

    protected void BTN_Search_Click(object sender, EventArgs e)
    {
        // redo movie list with filtered results
        LBL_TotalCount.Text = string.Format("Search found {0} results", GenerateMovieSearchFilter());
    }

    private int GenerateMovieAlphaFilters()
    {
        string sFilter = Alpha_Menu.SelectedItem.Value;
        // SELECT mov_smPoster, mov_title, mov_rating, mov_runTime 
        SqlDataReader sdr = Middleware.MovieDisplayContent(sFilter);

        return GenerateMovieTable(sdr);
    }

    private int GenerateMovieSearchFilter()
    {
        DIV_Movie.Controls.Clear();
        string sFilter = TB_Search.Text;
        // SELECT mov_smPoster, mov_title, mov_rating, mov_runTime 
        SqlDataReader sdr = Middleware.MovieDisplaySearchContent(sFilter);

        return GenerateMovieTable(sdr);
    }
    
    private int GenerateMovieTable(SqlDataReader sdr)
    {
        int iColumnCount = 0,
            iTotalCount = 0;

        while (sdr.Read())      // while data can be read
        {
            HtmlGenericControl cell = new HtmlGenericControl("div");       // create new movie cell instance

            // cell paramters
            cell.Attributes.Add("class", "Item");


            // get movie poster based off url in Db, load default if not found
            System.Web.UI.WebControls.Image imgPoster =
                new System.Web.UI.WebControls.Image();
            if (!sdr[0].ToString().ToLower().Contains("notfound"))
                imgPoster.ImageUrl = sdr[0].ToString();
            else
                imgPoster.ImageUrl = "~/Background_Images/MissingPoster.jpg";

            // set image dimensions
            imgPoster.Height = 200;
            imgPoster.Width = 140;
            imgPoster.ImageAlign = ImageAlign.Middle;

            // create movie label
            Label lInfoTitle = new Label();
            lInfoTitle.CssClass = "ItemTitle";
            //lInfoTitle.Height = 60;
            lInfoTitle.Text = "<br>" + sdr[1].ToString();

            // display other movie info
            Label lInfoExtra = new Label();
            lInfoExtra.CssClass = "ItemDiscription";
            lInfoExtra.Text = "Rating: " + sdr[2].ToString() +
                              "<br>" + "Runtime: " + sdr[3].ToString() + " minutes";

            // create more info buton
            Button bTemp = new Button();
            bTemp.Text = " *** More Info  *** ";
            bTemp.BackColor = Color.Goldenrod;
            bTemp.ForeColor = Color.Black;
            bTemp.Style.Value = "border-radius: 10px; font-size: 12pt;";
            // indicate more info event (javascript)
            bTemp.OnClientClick = "NavigateToMoreInfo('" + sdr[4] + "'); return false;";

            // add all controls to cell
            cell.Controls.Add(imgPoster);
            cell.Controls.Add(new LiteralControl("<br />"));
            cell.Controls.Add(lInfoTitle);
            cell.Controls.Add(new LiteralControl("<br />"));
            cell.Controls.Add(lInfoExtra);
            cell.Controls.Add(new LiteralControl("<br />"));
            cell.Controls.Add(bTemp);
            iColumnCount++;             // increase row place
            iTotalCount++;              // results found

            DIV_Movie.Controls.Add(cell);
        }
        
        return iTotalCount;
    }
}

