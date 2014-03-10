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
using System.Net;
using System.IO;
using System.Web.Services;
using System.Text;
using System.Web.Script.Serialization;

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

    public class Links
    {
        public string review { get; set; }
    }

    public class Reviews
    {
        public Links links;
        public string quote { get; set; }
    }

    public class JsonReviews
    {
        public Reviews[] reviews;
    }

    [WebMethod()]
    public static string GetRottenReviews(string imdbID)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(Middleware.ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.Text; // indicate query as procedure
            comm.CommandText = string.Format("Select [mov_rottenID] From [MovieSummary] Where [mov_id] = '{0}'", imdbID);
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection); // execute query

            if (reader.HasRows)
            {
                reader.Read();
                string rottenID = reader[0].ToString();
                if (rottenID.Equals("NOTFOUND"))
                    return "Sorry no reviews were found for this movie, the index may not exist.";

                string webAddr = string.Format("http://api.rottentomatoes.com/api/public/v1.0/movies/{1}/reviews.json?apikey={0}",
                                "jhgh2h3rvwnbwpzbf9m385ds&q", HttpUtility.HtmlEncode(rottenID));

                var httpWebRequest = (HttpWebRequest)WebRequest.Create(webAddr);
                httpWebRequest.ContentType = "application/json; charset=utf-8";
                httpWebRequest.Method = "GET";

                var httpResponse = (HttpWebResponse)httpWebRequest.GetResponse();
                JsonReviews jrMovieBase;
                using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
                {
                    JavaScriptSerializer ser = new JavaScriptSerializer();
                    string s = streamReader.ReadToEnd().Replace("\n", string.Empty);
                    jrMovieBase = ser.Deserialize<JsonReviews>(s);
                }
                if (jrMovieBase != null && jrMovieBase.reviews != null && jrMovieBase.reviews.Length > 0)
                {
                    StringBuilder sb = new StringBuilder();
                    sb.Append("<div style=\"margin-left: 20px;\" >");
                    foreach (Reviews review in jrMovieBase.reviews)
                    {
                        sb.Append(string.Format("<p class=\"ui-review ui-rotten theme\"><b>{0}</b></p>{1}<hr />", 
                            review.quote.Equals(string.Empty) ? "No quote available" : review.quote,
                            review.links.review != null && !review.links.review.Equals(string.Empty) ?
                                "<a href=\"" + review.links.review + "\" >See Full Review</a>" : "No review found"));
                    }
                    sb.Append("</div>");
                    return sb.ToString();
                }
                else
                    return "Sorry no reviews were found for this movie.";
            }
        }
        return "Sorry no reviews were found for this movie. IMDb index error";
    }

    [WebMethod()]
    public static string GetIMDbReviews(string imdbID)
    {
        StringBuilder sReturn = new StringBuilder();

        string sUrl = string.Format("http://www.imdb.com/title/{0}/reviews?ref_=tt_urv", imdbID);
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(sUrl);
        HttpWebResponse response = (HttpWebResponse)request.GetResponse();
        if (response.StatusCode == HttpStatusCode.OK)
        {
            Stream receiveStream = response.GetResponseStream();
            StreamReader readStream = null;
            if (response.CharacterSet == null)
                readStream = new StreamReader(receiveStream);
            else
                readStream = new StreamReader(receiveStream, Encoding.GetEncoding(response.CharacterSet));
            string data = readStream.ReadToEnd();
            response.Close();
            readStream.Close();

            int start = data.IndexOf("<div id=\"tn15content\">");
            int counterDiv = 1;
            int end = start;
            do
            {
                int temp;
                if ((temp = data.IndexOf("<div", end + 1)) > -1)
                {
                    counterDiv += 1;
                    end = temp;
                }
                if ((temp = data.IndexOf("</div", end + 1)) > -1)
                {
                    counterDiv -= 1;
                    end = temp;
                }
            }
            while (counterDiv > 0);

            string contentData = data.Substring(start, end - start);

            List<string> reviewList = new List<string>();
            int pos = 0;
            int hold = -1;
            do
            {
                if ((hold = contentData.IndexOf("<p>", pos)) > -1)
                {
                    start = hold + 3;
                    pos = hold + 3;
                }
                if ((hold = contentData.IndexOf("</p>", pos)) > -1)
                {
                    reviewList.Add(contentData.Substring(start, hold - start).Replace("\n", "").Replace("\t", ""));
                    pos = hold + 4;
                }
            }
            while (hold != -1);

            for(int i = reviewList.Count - 1; i > -1; i--)
                if (reviewList[i].Contains("<a"))
                    reviewList.RemoveAt(i);

            StringBuilder sb = new StringBuilder();
            sb.Append("<div style=\"margin-left: 20px;\" >");
            foreach (string s in reviewList)
            {
                s.Replace("<hr />", string.Empty);
                sb.Append(string.Format("<p class=\"ui-review ui-imdb theme\">{0}</p><hr />", s));
            }
            sb.Append("</div>");
            
            return sb.ToString();
        }
        return "An issue occured while getting reviews";
    }
}
