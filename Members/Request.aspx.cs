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
        GridView_Request.DataBind();        // rebind current requests list
    }
    protected void BTN_AddRequest_Click(object sender, EventArgs e)
    {
        Guid gUserID = (Guid)Membership.GetUser().ProviderUserKey;      // if request made, get user id
        Middleware.InsertRequest(gUserID, TB_Title.Text);               // launch insert query
        GridView_Request.DataBind();        // reshow gridview
    }
    protected void GridView_Request_Load(object sender, EventArgs e)
    {
        // if user is part of administrator, show delete column in gridview
        if (!User.IsInRole("Administrator"))                        
            for (int i = 0; i < GridView_Request.Columns.Count; i++)
                if(GridView_Request.Columns[i] is CommandField)
                    GridView_Request.Columns[i].Visible = false;
    }
}