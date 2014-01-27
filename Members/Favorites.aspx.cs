using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.Security;

public partial class _Default : System.Web.UI.Page
{
    public delegate EventHandler delEHIntGuid(int i, Guid g);

    protected void Page_Load(object sender, EventArgs e)
    {
        Guid gUserID = (Guid)Membership.GetUser().ProviderUserKey;
        // SELECT mov_smPoster, mov_title, mov_rating, mov_runTime 
        SqlDataReader sdr = Middleware.FavoritesDisplayContent(gUserID);
        int iColumnCount = 0;

        TableRow trRow = new TableRow();    // create table row instance

        if (sdr.HasRows)        // if reader has row to read
        {
            while (sdr.Read())      // read data row
            {
                // if there are four movies in a row add to table start new row
                if (iColumnCount > 4)   
                {
                    iColumnCount = 0;
                    Table_Favorites.Rows.Add(trRow);
                    trRow = new TableRow();
                }

                TableCell cell = new TableCell();   // create new movie cell instance

                // cell paramters
                cell.HorizontalAlign = HorizontalAlign.Center;
                cell.ForeColor = Color.White;
                cell.Width = 200;
                cell.Height = 350;

                // get movie poster based off url in Db, load default if not found
                System.Web.UI.WebControls.Image imgPoster =
                    new System.Web.UI.WebControls.Image();
                if (sdr[0].ToString().Length > 1)
                    imgPoster.ImageUrl = sdr[0].ToString();
                else
                    imgPoster.ImageUrl = "~/Background_Images/MissingPoster.jpg";

                // set image dimensions
                imgPoster.Height = 200;
                imgPoster.Width = 140;

                // create movie label
                Label lInfoTitle = new Label();
                lInfoTitle.ForeColor = Color.Goldenrod;
                lInfoTitle.Height = 60;
                lInfoTitle.Text = "<br>" + sdr[1].ToString();

                // display other movie info
                Label lInfoExtra = new Label();
                lInfoExtra.ForeColor = Color.White;
                lInfoExtra.Text = "Rating: " + sdr[2].ToString() +
                                  "<br>" + "Runtime: " + sdr[3].ToString() + " minutes";

                // create more info buton
                Button bTemp = new Button();
                bTemp.Text = " *** More Info  *** ";
                bTemp.BackColor = Color.Goldenrod;
                bTemp.ForeColor = Color.Black;
                bTemp.Style.Value = "border-radius: 10px; font-size: 12pt;";

                // indicate more info event (javascript)
                bTemp.OnClientClick = "NavigateToMoreInfoFav('" + sdr[4] + "'); return false;";

                // create remove favorite button
                Button bTemp2 = new Button();
                bTemp2.Text = "Remove From Favorites";
                bTemp2.BackColor = Color.Goldenrod;
                bTemp2.ForeColor = Color.Black;
                bTemp2.Style.Value = "border-radius: 10px; font-size: 12pt;";

                int iHoldIndex = int.Parse(sdr[4].ToString());

                // event handler for removing favorit from database
                bTemp2.Click += delegate { Middleware.DeleteFromFavorites(iHoldIndex, gUserID);
                                           Page.Response.AddHeader("Refresh", "0");
                };

                // add all controls to cell
                cell.Controls.Add(imgPoster);
                cell.Controls.Add(new LiteralControl("<br />"));
                cell.Controls.Add(lInfoTitle);
                cell.Controls.Add(new LiteralControl("<br />"));
                cell.Controls.Add(lInfoExtra);
                cell.Controls.Add(new LiteralControl("<br />"));
                cell.Controls.Add(bTemp);
                cell.Controls.Add(new LiteralControl("<br />"));
                cell.Controls.Add(bTemp2);

                trRow.Cells.Add(cell);  // add cell to row
                iColumnCount++;         // increase row place
            }
            Table_Favorites.Rows.Add(trRow);    // add last row
        }
        else
        {
            Response.Write("Could not open favorites");
        }
    }
}
