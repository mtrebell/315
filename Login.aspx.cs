using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using System.Web.Services;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod()]
    public static bool UserNameInUse(string sUserName)
    {
        return (Membership.GetUser(sUserName) != null ? false : true);
    }

    protected void CreateUserBTN_Click1(object sender, EventArgs e)
    {
        if (Page.IsValid)
        {
            // If the user was ALLOWED to self-register, then want to add him to appropriate role,
            //  otherwise the user merely has a login, but probably not authorized in any other way

            Membership.CreateUser(UserNameTB.Text, PasswordTB.Text);
            Roles.AddUserToRole(UserNameTB.Text, "Members");

            // Same as above, considered logged in, so set his Session too..
            Session.Add("Members", UserNameTB.Text);
            FormsAuthentication.SetAuthCookie(UserNameTB.Text, false);
            Response.Redirect("MainPage.aspx");
        }
    }
}