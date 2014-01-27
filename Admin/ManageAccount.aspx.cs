using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void GridView_Acoounts_SelectedIndexChanged(object sender, EventArgs e)
    {
        // delete the user data from all personal tables the user unique id
        Middleware.DeleteUserData(Guid.Parse(GridView_Accounts.SelectedRow.Cells[0].Text)); 
        // delete user account from all asp user tables
        Membership.DeleteUser(GridView_Accounts.SelectedRow.Cells[1].Text);
        GridView_Accounts.SelectedIndex = -1;   // reset selected index
        GridView_Accounts.DataBind();           // reshow database
    }
}