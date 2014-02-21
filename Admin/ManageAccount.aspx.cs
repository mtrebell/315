using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        using (SqlDataReader sdr = Middleware.GetNonAdminUsers())
        {
            while (sdr.Read())
                RowControl(sdr[0].ToString(), sdr[1].ToString(), sdr[2].ToString());
        }
    }

    private void RowControl(string sUserID, string sUserName, string sDateAdded)
    {
        string sRowID = "Row" + sUserID;
        TableRow hgcRow = new TableRow();    
        hgcRow.ID = sRowID;
        hgcRow.ClientIDMode = System.Web.UI.ClientIDMode.Static;

        using (TableCell hgcCol1 = new TableCell())
        {
            using (HtmlGenericControl hgcUserID = new HtmlGenericControl("p"))
            { hgcUserID.InnerText = sUserID; hgcCol1.Controls.Add(hgcUserID); }
            hgcCol1.CssClass = "UserCell";
            hgcRow.Controls.Add(hgcCol1);
        }

        using (TableCell hgcCol2 = new TableCell())
        {
            using (HtmlGenericControl hgcUserName = new HtmlGenericControl("p"))
            { hgcUserName.InnerText = sUserName; hgcCol2.Controls.Add(hgcUserName); }
            hgcCol2.CssClass = "UserCell";
            hgcRow.Controls.Add(hgcCol2);
        }

        using (TableCell hgcCol3 = new TableCell())
        {
            using (HtmlGenericControl hgcDateAdded = new HtmlGenericControl("p"))
            { hgcDateAdded.InnerText = sDateAdded; hgcCol3.Controls.Add(hgcDateAdded); }
            hgcCol3.CssClass = "UserCell";
            hgcRow.Controls.Add(hgcCol3);
        }

        using (TableCell hgcCol4 = new TableCell())
        {
            using (HtmlButton hgcDelete = new HtmlButton())
            {
                hgcDelete.InnerText = "Delete";
                hgcDelete.Attributes.Add("class", "DeleteButton");
                hgcDelete.Attributes.Add("onclick", "RemoveRow('" + sRowID + "','" + sUserID + "','" + sUserName + "'); return false;");
                hgcCol4.Controls.Add(hgcDelete);
            }
            hgcCol4.CssClass = "UserCell";
            hgcRow.Controls.Add(hgcCol4);
        }
        UserTable.Rows.Add(hgcRow);
    }

    [WebMethod()]
    public static int DeleteUser(string sUserID, string sUserName)
    {
        // delete the user data from all personal tables the user unique id
        Middleware.DeleteUserData(Guid.Parse(sUserID)); 
        // delete user account from all asp user tables
        Membership.DeleteUser(sUserName);
        return 0;
    }
}