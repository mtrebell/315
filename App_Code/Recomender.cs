//Based off http://infolab.stanford.edu/~ullman/mmds/ch9.pdf

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
    double weight = 0.5;
    //Returns the average rating of each movie, normalized by user averages
    //This is to account for users who often very vote high or very low
    public Dictionary<String, Dictionary<String, double>> getNormalizedRatings()
    {
        Dictionary<String, Dictionary<String, double>> ratings = new Dictionary<String, Dictionary<String, double>>();
        Dictionary<String, int> userAvg = getUserAvgs();
        Dictionary<string, double[]> sysRating = getSystemRatings();

        SqlDataReader rdr = Middleware.GetMovieRatings();

        while (rdr.Read())
        {
            string movie = rdr["mov_id"].ToString();
            string user = rdr["users_id"].ToString();
            double rating = Convert.ToInt32(rdr["rating"]);

            //NORMALIZE RATING HERE

            Dictionary<String, double> value;

            if (rating != 0 )
            {
                if (ratings.TryGetValue(movie, out value))
                {
                    ratings.Remove(movie);
                }
                else
                {
                    value = new Dictionary<string, double>();
                }

                value.Add(user, rating);
                ratings.Add(movie, value);
            }
        }

        //Add system ratings
        double[] IRating = Middleware.IMDBRottenAvg();
       foreach(string movie in sysRating.Keys)
        {
            double IMDB = IRating[0];
            double rotten = IRating[1];

            double[] s;
            if (sysRating.TryGetValue(movie, out s))
            {
                s[0] -= IMDB;
                s[1] -= rotten;

                Dictionary<string, double> value;
                if (ratings.TryGetValue(movie, out value))
                {
                    ratings.Remove(movie);
                }
                else
                {
                    value = new Dictionary<string, double>();
                }
                value.Add("1", s[0]);
                value.Add("2", s[1]);
                ratings.Add(movie, value);
            }
        }
        return ratings;
    }

    public Dictionary<string, int> getUserAvgs()
    {
        Dictionary<string, int> userAvg = new Dictionary<string, int>();
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
            int rating = Convert.ToInt32(rdr[1]);
            movAvg.Add(user, rating);
        }
        return movAvg;
    }


    public Dictionary<string, double[]> getSystemRatings()
    {
        Dictionary<string, double[]> sysRating = new Dictionary<string, double[]>();
        SqlDataReader rdr = Middleware.GetSystemRatings();
        while (rdr.Read())
        {
            double[] rating = new double[2];
            string user = rdr["mov_id"].ToString();
            rating[0] = (Convert.ToInt32(rdr["mov_rating"]));
            rating[1] = (Convert.ToInt32(rdr["mov_rottenRating"]));
            sysRating.Add(user, rating);
        }
        return sysRating;
    }


    public Dictionary<String, Dictionary<String, double>> getSimilarity(Dictionary<String, Dictionary<String, double>> ratings)
    {
        Dictionary<string, Dictionary<String, double>> similarity = new Dictionary<string, Dictionary<string, double>>();
        foreach (string key in ratings.Keys)
        {
            int count = 0;
            Dictionary<String, double> movie;
            ratings.TryGetValue(key, out movie);

            Dictionary<string, double> temp = new Dictionary<string, double>(); ;
            foreach (string comp in ratings.Keys)
            {


                Dictionary<string, double> test = new Dictionary<string, double>();
                //Dont add the movie to a dictionary if it already added as key
                if (similarity.ContainsKey(comp))
                    continue;
                //Dont compare movie to itself
                if (comp.CompareTo(key) == 0)
                    continue;

                Dictionary<String, double> movieComp;
                double sim = 0;

                if (ratings.TryGetValue(comp, out movieComp))
                {
                    double m = 0;
                    double p = 0;
                    double MP = 0;

                    foreach (string user in movie.Keys)
                    {
                        double rating;

                        if (!movie.TryGetValue(user, out rating))
                            rating = 0;

                        p += rating * rating;

                        if (!movieComp.ContainsKey(user))
                            continue;

                        double compRating;

                        if (!movie.TryGetValue(user, out compRating))
                            compRating = 0;
                        //Almost always 0
                        MP += rating * compRating;
                    }

                    foreach (string user in movieComp.Keys)
                    {
                        double rating;

                        if (!movieComp.TryGetValue(user, out rating))
                            rating = 0;

                        m += rating * rating;
                    }
                    //Normalized Cosine Dist
                    if (p == 0 && m == 0)
                        sim = 0;
                    else
                        sim = MP / (Math.Sqrt(p)*Math.Sqrt(m)); //CHECK THE EQ
                }

                //With better data this should be limited to 50 matches
                temp.Add(comp, sim);
                count++;

            }
            similarity.Add(key, temp);
        }
        return similarity;
    }


    public void writeModel(Dictionary<string, int> ratings, Dictionary<string, Dictionary<string, double>> values)
    {
        Middleware.DeleteSimilar();

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
                if (value.TryGetValue(match, out similarity))
                {
                    Model m = new Model(key, match, similarity, r1 * 1000 + r2);
                    model.Add(m);
                }
            }
        }
        Middleware.AddSimilar(model);
    }

    public double getProb(Guid user, string movie)
    {
        double p = 0;
        int count = 0;
        Dictionary<string, int> similar = getSimilarMovie(movie);
        SqlDataReader rdr = Middleware.GetWatchedMovie(user);
        while (rdr.Read())
        {
            int s;
            string key = rdr["mov_id"].ToString();

            if (!similar.TryGetValue(key, out s))
                continue;

            count++;
            //similarity*rating
            p += Convert.ToInt32(rdr["similarity"]) * s;
        }

        if (count == 0)
            return 0;

        return p / count;
    }

    public Dictionary<string, int> getSimilarMovie(string movie)
    {
        Dictionary<string, int> similar = new Dictionary<string, int>();
        SqlDataReader rdr = Middleware.GetSimilarMovie(movie);
        while (rdr.Read())
        {
            string match = rdr[0].ToString();
            int similarity = Convert.ToInt32(rdr["similarity"]);

            if (match.CompareTo(movie) == 0)
                similar.Add(rdr[1].ToString(), similarity);
            else
                similar.Add(match, similarity);
        }

        return similar;
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