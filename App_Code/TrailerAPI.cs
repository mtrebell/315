using Google.GData.Client;
using Google.YouTube;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for TrailerAPI
/// </summary>
public static class TrailerAPI
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
        YouTubeRequestSettings settings = new YouTubeRequestSettings("Media App", developerKey);
        YouTubeRequest request = new YouTubeRequest(settings);

        Feed<Video> result = request.Get<Video>(new Uri(baseUrl + title));

        extracedVideo[] ids = (from video in result.Entries
                                select new extracedVideo() { VideoId = video.VideoId }).ToArray();

        return ids;
    }
}
