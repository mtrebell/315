using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.UI;
using System.Web.Security;


/// <summary>
/// Summary description for Class
/// </summary>
public partial class _Default : System.Web.UI.Page
{
    static double cap = 6;
    double weight = 0.5;
    private static Recomender r = new Recomender();

    [WebMethod]
    public static void buildModel()
    {

        Dictionary<String, Dictionary<String, double>> normRatings = r.getNormalizedRatings();

        //Building similatiry martix
        Dictionary<String, Dictionary<String, double>> movieSimilarity = r.getSimilarity(normRatings);

        r.writeModel(r.getMovieAvgs(), movieSimilarity);
    }

    [WebMethod]
    public static List<string> allRecomendations()
    {
        List<string> recomend = new List<string>();

        Guid gUser;
        MembershipUser user = Membership.GetUser();
        if (user == null)
        {
            gUser = new Guid();
        }
        else
        {
            gUser = (Guid)user.ProviderUserKey;
        }
        
        SqlDataReader rdr = Middleware.GetUnwatchedMovie(gUser);
        while (rdr.Read())
        {
            string movie = rdr["mov_id"].ToString();

            double prob = r.getProb(gUser,movie);
            if (prob > cap)
                recomend.Add(movie);

        }

        if (recomend.Count < 20)
        {
            rdr = Middleware.GetTopMovie();
            while (rdr.Read())
            {
                recomend.Add(rdr["mov_id"].ToString());
            }
        }

        return recomend;
    }

}


