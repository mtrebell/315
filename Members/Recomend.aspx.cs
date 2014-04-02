using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.UI;


/// <summary>
/// Summary description for Class
/// </summary>
public partial class _Default : System.Web.UI.Page
{
    static double cap = 0.65;
    double weight = 0.5;
    private static Recomender r = new Recomender();

    [WebMethod]
    public static void buildModel()
    {

        Dictionary<string, double[]> normRatings = r.getNormalizedRatings();

        //Building similatiry martix
        Dictionary<string, Dictionary<string, double>> movieSimilarity = r.getSimilarity(normRatings);

        r.writeModel(r.getMovieAvgs(), movieSimilarity);

    }

  

    [WebMethod]
    public static List<string> allRecomendations(Guid user)
    {
        List<string> recomend = new List<string>();
        List<string> extra = new List<string>();
        //getnotwatched
        SqlDataReader rdr = Middleware.GetUnwatchedMovie(user);
        while (rdr.Read())
        {
            string movie = rdr["mov_id"].ToString();

            double prob = r.getProb(user,movie);
            if (prob > cap)
                recomend.Add(movie);
            else if (prob > 0.45)
                extra.Add(movie);
        }

        if (recomend.Count < 20)
        {
            //just reccomend unwatched
        }

        return recomend;
    }

}


