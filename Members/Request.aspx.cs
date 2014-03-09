using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        rptAccordian.DataSource = createDataTable();
        rptAccordian.DataBind();
    }


    public DataTable createDataTable()
    {
        System.Data.SqlClient.SqlConnection conn =
            new System.Data.SqlClient.SqlConnection(
            Middleware.ConnectionString);
        DataTable dt = new DataTable();
        SqlCommand cmd = new SqlCommand();
        SqlDataAdapter da = new SqlDataAdapter();

        cmd = new SqlCommand("GetRequests", conn);
        cmd.CommandType = CommandType.StoredProcedure;
        da.SelectCommand = cmd;
        da.Fill(dt);

        return dt;
    }

    [WebMethod()]
    public static int DeleteRequest(int request_id)
    {
        Middleware.DeleteRequest(request_id);
        return request_id;
    }

    [WebMethod()]
    public static string InsertRequest(string sTitle)
    {
        string sOut = Middleware.InsertRequest((Guid) Membership.GetUser().ProviderUserKey, sTitle);
        string sReturn = string.Format("<tr id=\"{0}tr\">{1}<td>{2}</td><td>{3}</td><td>{4}</td>{5}</tr>", 
            sOut, 
            Roles.GetRolesForUser(Membership.GetUser().UserName).Contains<string>("Administrator") ?
                "<td>" + sOut + "</td>" : string.Empty,
            Membership.GetUser().UserName,
            DateTime.Now.ToShortDateString() + " " + DateTime.Now.ToShortTimeString(),
            sTitle,
            Roles.GetRolesForUser(Membership.GetUser().UserName).Contains<string>("Administrator") ?
                string.Format("<td><input type=\"button\" id=\"{0}\" class=\"Button\" value=\"Delete\"" +
                "onclick=\"DeleteRequest({1}); return false;\" /></td>", sOut, sOut) : string.Empty
        );
        return sReturn;
    }
}