//Based off of http://www.robgreen.me/post/Getting-Started-With-The-YouTube-API-in-C.aspx
//FOR ADD TO DATA BASE
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Configuration;
using Google.YouTube;
using Google.GData.YouTube;
using Google.GData.Client;
using Google.GData.Extensions;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        VideosRepeater.DataSource = YouTubeVideoHelper.search("wolverine");
        VideosRepeater.DataBind();
    }

    public class YouTubeVideoHelper
    {
        const string developerKey = "AIzaSyAhwQhub_CAS9-u-1EGVkDFSP9q24aRSuk";
        const string baseUrl = "https://gdata.youtube.com/feeds/api/videos?max-results=1&q=Offical Trailer ";

        public class extracedVideo
        {
            public string VideoId { get; set; }
        }

        public static extracedVideo[] search(string title)
        {
            //Name and key for authentication
            YouTubeRequestSettings settings = new YouTubeRequestSettings("Meida App", developerKey);
            YouTubeRequest request = new YouTubeRequest(settings);

            Feed<Video> result = request.Get<Video>(new Uri(baseUrl + title));

            extracedVideo[] ids = (from video in result.Entries
                                   select new extracedVideo() { VideoId = video.VideoId }).ToArray();

            return ids;
        }
    }
}

/*** FOR MAIN.ASPX.CS
*[WebMethod()]
*string getURL(string mov_id){
 * SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(Middleware.ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.Text; // indicate query as procedure
            comm.CommandText = string.Format("Select [mov_id] From [MovieSummary] Where [mov_id] = '{0}'", mov_id);
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection); // execute query

            if (reader.HasRows)
            {
                reader.Read();
                return reader[0].ToString();
             }
        }
 }

//--------for main.aspx---------//
 
button = Traler id = mov_id onclick = getTrailer(this.id)
 
getTrailer(movieId)
$.ajax({
		type: "GET",
		url: main.aspx/getUrl
		data: movieId
		dataType:"json",
success: function(response){
	console.log(response);			
if(response.data.items){
var movie = response.data.items[0];
var id=movie.id;
//Add video	
var frame="<iframe  type='text/html' width='425' height='349' src=' http://www.youtube.com/embed/" +id+ "' frameborder='0'></iframe>";

$("#trailer").html(frame);		
}
*/