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
    }
    protected void Login1_LoggedIn(object sender, EventArgs e)
    {
        // Save Session["User"] as UserName, also available from Page.User.Identity.Name on allowed pages
        Session.Add("User", Login1.UserName);

        // Access User Properties : LastLogin etc,
        MembershipUser o = Membership.GetUser(Login1.UserName);

        // This is ID field in the User table if desired, but UserName is unique too,
        //  so either can be used as a "key", Guid is the primary key so it is slightly faster..
        Guid userid = (Guid)o.ProviderUserKey;
    }
//    protected void CreateUserWizard1_CreatedUser(object sender, EventArgs e)
//    {
        // If the user was ALLOWED to self-register, then want to add him to appropriate role,
        //  otherwise the user merely has a login, but probably not authorized in any other way
//        Roles.AddUserToRole(CreateUserWizard1.UserName, "Members");

        // Same as above, considered logged in, so set his Session too..
//        Session.Add("Members", Login1.UserName);
//    }
}
