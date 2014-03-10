//Baed off of http://www.robgreen.me/post/Getting-Started-With-The-YouTube-API-in-C.aspx

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

