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
using Newtonsoft.Json;

public partial class _Default : System.Web.UI.Page
{
    private static Guid userid; 
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["User"] != null)
        {
            string username = Session["User"].ToString();
            userid = (Guid) Membership.GetUser(username).ProviderUserKey;
        }
    }
    protected void Login1_LoggedIn(object sender, EventArgs e)
    {
        // Save Session["User"] as UserName, also available from Page.User.Identity.Name on allowed pages
        Session.Add("User", Login1.UserName);

        // Access User Properties : LastLogin etc,
        MembershipUser o = Membership.GetUser(Login1.UserName);

        // This is ID field in the User table if desired, but UserName is unique too,
        //  so either can be used as a "key", Guid is the primary key so it is slightly faster..
        userid = (Guid)o.ProviderUserKey;
    }

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
                    sb.Append("<div>");
                    foreach (Reviews review in jrMovieBase.reviews)
                    {
                        sb.Append(string.Format("<p class=\"ui-review ui-rotten theme\"><b>{0}</b></p>{1}<hr />", 
                            review.quote.Equals(string.Empty) ? "No quote available" : review.quote,
                            review.links.review != null && !review.links.review.Equals(string.Empty) ?
                                "<a href=\"" + review.links.review + "\" target=\"blank\" >See Full Review</a>" : "No review found"));
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
            sb.Append("<div>");
            if (reviewList.Count <= 0)
                return "Sorry no reviews were found for this movie";

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

    [WebMethod()]
    public static string getURL(string mov_id)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(Middleware.ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.Text; // indicate query as procedure
            comm.CommandText = string.Format("Select [mov_trailer] From [MovieSummary] Where [mov_id] = '{0}'", mov_id);
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection); // execute query

            if (reader.HasRows)
            {
                reader.Read();
                return reader[0].ToString();
            }
        }
        return "";
    }

    [WebMethod()]
    public static string SaveRating(string mov_id, float rating, string review)
    {
        return Middleware.InsertIntoReviews(mov_id, userid, rating, review);
    }
    public class userinfo
    {
        public userinfo(string rating, string review)
        {
            UserRating = rating;
            UserReview = review;
        }

        public string UserRating,
                      UserReview;
    }

    public class results
    {
        public userinfo self;
        public List<userinfo> others = new List<userinfo>();

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder();
            if (self != null)
                sb.Append(self.UserRating).Append("<split>").Append(self.UserReview);
            sb.Append("<divide>");

            if (others.Count > 0) {
                foreach (userinfo other in others)
                    sb.Append(other.UserRating).Append("<split>").Append(other.UserReview).Append("<end>");
                sb.Remove(sb.Length - 5, 5);
            }
            
            return sb.ToString();
        }
    }


    [WebMethod()]
    public static string GetUserReviews(string mov_id)
    {
        results rReviewObjects = new results();

        using (SqlDataReader sdr = Middleware.GetUserReviewContent(mov_id))
        {
            if (!sdr.HasRows)
                return "<div><p>This movie has not been reviewed yet.</p></div>";

            while (sdr.Read())
            {
                if (((Guid)sdr[2]).Equals(userid))
                    rReviewObjects.self = new userinfo(sdr[0].ToString(), sdr[1].ToString());
                else
                    rReviewObjects.others.Add(new userinfo(sdr[0].ToString(), sdr[1].ToString()));
            }
        }

        return rReviewObjects.ToString();
    }

}
