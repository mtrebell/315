using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.SqlClient;

/// <summary>
/// Summary description for Class
/// </summary>
public class Recomender
{
    double cap = 0.65;
    double weight=0.5;
  
    //Returns the average rating of each movie, normalized by user averages
    //This is to account for users who often very vote high or very low
    public Dictionary<String,double[]> getNormalizedRatings()
    {
        Dictionary<String,double[]> ratings = new Dictionary<String,double[]>();
        Dictionary<String,int> userAvg = getUserAvgs();

        SqlDataReader rdr = Middleware.GetMovieRatings();

        while (rdr.Read())
        {
            string movie = rdr["mov_id"].ToString();
            string user = rdr["user_id"].ToString();
            int rating = Convert.ToInt32(rdr["rating"]);

            //These variables will be used to calculate movie normalized cosine dist
            if (rating != 0)
            {
               int avg;
               userAvg.TryGetValue(user, out avg);
               double value = rating - avg;

                double[] var = new double[2];
                if( ratings.TryGetValue( movie, out var ) )
                {
                    var[0] = var[0] + value;
                    var[1] = var[1] + value*value;
                }
                else
                {
                    var[0] = value;
                    var[1] = value*value;
                }
                ratings.Add(movie,var);
            }
            }
            
        return ratings;
}

    public Dictionary<string, int> getUserAvgs()
    {
        Dictionary<string,int> userAvg = new Dictionary<string,int>();
        SqlDataReader rdr = Middleware.GetUserAverages();
        while (rdr.Read())
        {
            string user = rdr["users_id"].ToString();
            int rating = Convert.ToInt32(rdr["rating"]);
            userAvg.Add(user, rating);
        }
        return userAvg;
    }

    public Dictionary<string, int> getMovieAvgs()
    {
        Dictionary<string, int> movAvg = new Dictionary<string, int>();
        SqlDataReader rdr = Middleware.GetMovieAverages();
        while (rdr.Read())
        {
            string user = rdr["mov_id"].ToString();
            int rating = Convert.ToInt32(rdr["rating"]);
            movAvg.Add(user, rating);
        }
        return movAvg;
    }


    public Dictionary<string, List<int>> getSystemRatings()
    {
        Dictionary<string, List<int>> sysRating = new Dictionary<string, List<int>>();
        SqlDataReader rdr = Middleware.GetMovieAverages();
        while (rdr.Read())
        {
            List<int> rating = new List<int>();
            string user = rdr["mov_id"].ToString();
            rating.Add(Convert.ToInt32(rdr["mov_rating"]));
            rating.Add(Convert.ToInt32(rdr["mov_rottenRating"]));
            sysRating.Add(user, rating);
        }
        return sysRating;
    }

    public Dictionary<string, Dictionary<string, double>> getSimilarity(Dictionary<string, double[]> ratings)
    {
        Dictionary<string, Dictionary<String, double>> similarity = new Dictionary<string, Dictionary<string, double>>();
        foreach (string key in ratings.Keys)
        {
            int count = 0;
            double[] movie;
            ratings.TryGetValue(key, out movie);

            Dictionary<string, double> temp = new Dictionary<string, double>();
            foreach (string comp in ratings.Keys)
            {
                double[] movieComp;
                if (similarity.TryGetValue(comp, out temp))
                    continue;

                ratings.TryGetValue(comp, out movieComp);

                //Normalized Cosine Dist
                double sim = movie[0] * movieComp[0] / (movie[1] * movie[1]);
                if ( sim > 0.7 && count <50 ) //stops our model from growing to large
                {
                    temp.Add(comp, sim);
                    count++;
                }
            
            }
            similarity.Add(key, temp);
        }
        return similarity;
    }


    //This is being reworked to be more effeciet
    public void writeModel(Dictionary<string,int> ratings,Dictionary<string, Dictionary<string, double>> values)
    {
        List<Model> model = new List<Model>();

        foreach (string key in ratings.Keys)
        {
            Dictionary<string, double> value;
            values.TryGetValue(key, out value);

            foreach (string match in value.Keys)
            {
                int r1, r2;
                double similarity;

                ratings.TryGetValue(key, out r1);
                ratings.TryGetValue(match, out r2);
                value.TryGetValue(match, out similarity);

                Model m = new Model(key, match, similarity, r1 * 1000 + r2);
                model.Add(m);
            }
        }
        Middleware.AddSimilar(model);
    }

    public double getProb(Guid user,string movie)
    {
        double p = 0;
        int count = 0;
        //sql call similar that has watched
        SqlDataReader rdr = Middleware.GetSimilarMovie(user,movie);
         while (rdr.Read())
         {
             count++;
             string match = rdr[0].ToString();
             int rating =Convert.ToInt32(rdr[1]);

             //Extract the rating
             if (match.CompareTo(movie) == 0)
                 rating = (int)rating/1000; 
             else
                 rating = rating%1000;

             //similarity*rating
             p += Convert.ToInt32(rdr[2])*rating;
         }

         if (count == 0)
             return 0;

        return p/count;
    }


      public class Model
    {
        public string movie;
        public string match;
        public double similarity;
        public int rating; //two ratings combined

        public Model(string movie, string match, double similarity, int rating)
        {
            this.movie = movie;
            this.match = match;
            this.similarity = similarity;
            this.rating = rating;
        }
    }
}


    