
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Drawing;
using System.Web.Security;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.HtmlControls;
public partial class GetMovieList : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        SqlDataReader sdr = Middleware.MovieDisplayContent();
        GenerateMovieTable(sdr);

    }
    private int foo ()
    {
        return 0;
    }
    private int GenerateMovieTable(SqlDataReader sdr)
    {
        int iTotalCount = 0;

        while (sdr.Read())      // while data can be read
        {
            HtmlGenericControl cell = new HtmlGenericControl("div");       // create new movie cell instance

            cell.Attributes.Add("id", "movID_" + sdr["mov_id"].ToString());
            cell.Attributes.Add("class", "cover");
            // cell paramters

            if (iTotalCount < 20)
            {
                System.Web.UI.WebControls.Image imgPoster = new System.Web.UI.WebControls.Image();
                imgPoster.Attributes.Add("id", "movID_" + sdr["mov_id"].ToString());

                if (!sdr[0].ToString().ToLower().Contains("notfound"))
                {
                    imgPoster.ImageUrl = sdr[0].ToString();
                } else {
                    imgPoster.Attributes.Add("class", "missing_poster");
                    imgPoster.ImageUrl = "~/Background_Images/MissingPoster.jpg";
                }

                cell.Controls.Add(imgPoster);
                
            }
            else
            {
                cell.Attributes.Add("class", "cover cover-not-loaded");

                if (!sdr[0].ToString().ToLower().Contains("notfound"))
                {
                    cell.Attributes.Add("dataClass", "missing_poster");
                    cell.Attributes.Add("dataUrl", sdr[0].ToString().Replace("~/", ""));
                } else {
                    cell.Attributes.Add("dataUrl", "Background_Images/MissingPoster.jpg");
                    cell.Attributes.Add("dataClass", "missing_poster");
                }
            }

            HtmlGenericControl info = new HtmlGenericControl("div");       // create new movie cell instance
            info.Attributes.Add("id", "info");
            info.Attributes.Add("class", "hidden");
            for (int i = 0; i < sdr.FieldCount; i++)
            {
                HtmlGenericControl field = new HtmlGenericControl("p");       // create new movie cell instance
                field.Attributes.Add("id", sdr.GetName(i));
                field.InnerText = sdr.GetValue(i).ToString().Replace("~/", "");
                info.Controls.Add(field);
            }
            cell.Controls.Add(info);
            
            Controls.Add(cell);
            //Controls.Add(imgPoster);
            iTotalCount ++;
            //if (iTotalCount > 20)
              //  break;
        }
        
        return iTotalCount;
    }
}