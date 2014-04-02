using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data.SqlClient;
using System.Configuration;

/// <summary>
/// Summary description for Middleware
/// </summary>
public static class Middleware
{
    public static string ConnectionString
    {
        get
        {
            return ConfigurationManager.ConnectionStrings["InternalConnectionString"].ConnectionString;
        }
    }

    /// <summary>
    /// Used to find all movie database information based off first character in title
    /// if no letter is selected * , finds all database items
    /// </summary>
    /// <param name="sMovieFilter">letter filter string</param>
    /// <returns>returned datasource of filtered info</returns>
    public static SqlDataReader MovieDisplayContent(Guid gUser)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString);  // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())                      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // call stored procedure
            comm.CommandText = "MovieCollectionGrab";                   // name of procedure

            SqlParameter pUserID = new SqlParameter("@UserID", System.Data.SqlDbType.UniqueIdentifier);
            pUserID.Value = gUser;  // apply user id filter
            pUserID.Direction = System.Data.ParameterDirection.Input;
            // Add the parameter
            comm.Parameters.Add(pUserID);

            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute procedure 
        }
        return reader;  // return result set
    }

    /// <summary>
    /// Used to find all movie database information based off any character string in textbox character in title
    /// if no letter is selected, finds all database items
    /// </summary>
    /// <param name="sMovieFilter">filter string</param>
    /// <returns>returned datasource of filtered info</returns>
    public static SqlDataReader MovieDisplaySearchContent(string sMovieFilter)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString);  // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())                  // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // call stored procedure
            comm.CommandText = "MovieSearchFilter";                     // name of procedure    
            // Make Parameter
            SqlParameter pCustomerID = new SqlParameter("@Filter", System.Data.SqlDbType.NVarChar, 100);
            pCustomerID.Value = sMovieFilter;   // apply filter value
            pCustomerID.Direction = System.Data.ParameterDirection.Input;
            // Add the parameter
            comm.Parameters.Add(pCustomerID);
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute command
        }
        return reader;  // return result set
    }

    /// <summary>
    /// collecs all information on favorite movies from favorites table for a particular user
    /// 
    /// </summary>
    /// <param name="gUser">unique user id for filter</param>
    /// <returns>return data set</returns>
    public static SqlDataReader ReviewsDisplayContent(string mov_id)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString);
        conn.Open();
        using (SqlCommand comm = new SqlCommand())
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // query is stored procedure
            comm.CommandText = "MovieReviewsFilter";          // call procedure name
            // Make Parameter
            SqlParameter pUserID = new SqlParameter("@MovID", System.Data.SqlDbType.NVarChar, 100);
            pUserID.Value = mov_id;  // apply user id filter
            pUserID.Direction = System.Data.ParameterDirection.Input;
            // Add the parameter
            comm.Parameters.Add(pUserID);
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute stored procedure
        }   
        return reader;      // return filtered dataset
    }

    /// <summary>
    /// used to get the extra information from the movie summary database
    /// </summary>
    /// <param name="iMovieIndex">indicates the movie index requested</param>
    /// <returns>returns the dataset</returns>
    public static SqlDataReader MovieDisplayMoreInfo(int iMovieIndex)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString);  // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())          // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; //assign query as procedure
            comm.CommandText = "MovieMoreInfo";         // indicate procedure
            // Make Parameter
            SqlParameter pMoreInfoID = new SqlParameter("@Index", System.Data.SqlDbType.NChar);
            pMoreInfoID.Value = iMovieIndex;        // assign procedure filter variable
            pMoreInfoID.Direction = System.Data.ParameterDirection.Input;
            // Add the parameter
            comm.Parameters.Add(pMoreInfoID);
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query
        }
        return reader;      // return filtered dataset
    }


    /// <summary>
    /// Deletes entries from the favorites list based off user and movie index
    /// </summary>
    /// <param name="iMovID">movie to remove</param>
    /// <param name="gUser">the user to remove movie from</param>
    /// <returns>return progress message</returns>
    public static string DeleteFromReviews(int iMovID, Guid gUser)
    {
        SqlDataReader reader = null; // return object
        string sReturn = "";
        SqlConnection conn = new SqlConnection(ConnectionString);  // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate as procedure
            comm.CommandText = "DeleteReviews";               // indicate procedure name
            // Make Parameter
            SqlParameter pUserID = new SqlParameter("@UserID", System.Data.SqlDbType.UniqueIdentifier);
            SqlParameter pMovieID = new SqlParameter("@MovID", System.Data.SqlDbType.Int);
            SqlParameter pOutput = new SqlParameter("@output", System.Data.SqlDbType.NVarChar, 100);
            pUserID.Value = gUser;      // assign user filter
            pMovieID.Value = iMovID;    // assign movie filter

            pUserID.Direction = System.Data.ParameterDirection.Input;
            pMovieID.Direction = System.Data.ParameterDirection.Input;
            pOutput.Direction = System.Data.ParameterDirection.Output;

            // Add the parameter
            comm.Parameters.Add(pUserID);
            comm.Parameters.Add(pMovieID);
            comm.Parameters.Add(pOutput);
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query

            sReturn = pOutput.Value.ToString(); // get output value
        }
        return sReturn;
    }

    /// <summary>
    /// Inserts movie into favorites database based off movie id and user id
    /// </summary>
    /// <param name="iMovID">movie id to add</param>
    /// <param name="gUser">user id to assign movie to</param>
    /// <returns>return progress message</returns>
    public static string InsertIntoReviews(string iMovID, Guid gUser, float rating, string review)
    {
        SqlDataReader reader = null; // return object
        string sReturn = "";
        SqlConnection conn = new SqlConnection(ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate query as procedure
            comm.CommandText = "InsertReview";           // indicate procedure name
            // Make Parameter
            SqlParameter pUserID = new SqlParameter("@UserID", System.Data.SqlDbType.UniqueIdentifier);
            SqlParameter pMovieID = new SqlParameter("@MovID", System.Data.SqlDbType.NVarChar, 100);
            SqlParameter pOutput = new SqlParameter("@output", System.Data.SqlDbType.NVarChar, 100);
            pUserID.Value = gUser;      // assign user filter
            pMovieID.Value = iMovID;    // assign movie id filter

            pUserID.Direction = System.Data.ParameterDirection.Input;
            pMovieID.Direction = System.Data.ParameterDirection.Input;
            pOutput.Direction = System.Data.ParameterDirection.Output;

            // Add the parameter
            comm.Parameters.Add(pUserID);
            comm.Parameters.Add(pMovieID);
            comm.Parameters.Add(pOutput);
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection); // execute query

            sReturn = pOutput.Value.ToString(); // get output value
        }
        return sReturn;
    }

    public static SqlDataReader GetAllGenreOptions()
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate query as procedure
            comm.CommandText = "GetAllGenres";           // indicate procedure name
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query
        }
        return reader;      // return filtered dataset
    }

    public static SqlDataReader GetNonAdminUsers()
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate query as procedure
            comm.CommandText = "GetNonAdminUsers";           // indicate procedure name
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query
        }
        return reader;      // return filtered dataset
    }

    /// <summary>
    /// Deletes all secondary info related to users from remaining databases not asp login related
    /// </summary>
    /// <param name="gUser">user id to delete info for</param>
    /// <returns>return progress message</returns>
    public static string DeleteUserData(Guid gUser)
    {
        SqlDataReader reader = null; // return object
        string sReturn = "";
        SqlConnection conn = new SqlConnection(ConnectionString);      // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate query as procedure
            comm.CommandText = "DeleteUserData";        // assign procedure name
            // Make Parameter
            SqlParameter pUserID = new SqlParameter("@UserID", System.Data.SqlDbType.UniqueIdentifier);
            SqlParameter pOutput = new SqlParameter("@output", System.Data.SqlDbType.NVarChar, 100);
            pUserID.Value = gUser;  // indicate user id filter

            pUserID.Direction = System.Data.ParameterDirection.Input;
            pOutput.Direction = System.Data.ParameterDirection.Output;

            // Add the parameter
            comm.Parameters.Add(pUserID);
            comm.Parameters.Add(pOutput);
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query

            sReturn = pOutput.Value.ToString(); // get output value
        }
        return sReturn;
    }

    /// <summary>
    /// Used to add request titles to the request table in database
    /// </summary>
    /// <param name="gUser">user id of requester</param>
    /// <param name="sTitle">title being rrequested</param>
    public static string InsertRequest(Guid gUser, string sTitle)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString);  // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())  // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // query as procedure
            comm.CommandText = "RequestInsert";         // indicate procedure name
            // Make Parameter
            SqlParameter pUserID = new SqlParameter("@UserID", System.Data.SqlDbType.UniqueIdentifier);
            SqlParameter pMovieTitle = new SqlParameter("@Title", System.Data.SqlDbType.NVarChar, 150);
            SqlParameter pOutputIdx = new SqlParameter("@Output", System.Data.SqlDbType.NVarChar, 50);
            pUserID.Value = gUser;          // user id filter
            pMovieTitle.Value = sTitle;     // title filter
            

            pUserID.Direction = System.Data.ParameterDirection.Input;
            pMovieTitle.Direction = System.Data.ParameterDirection.Input;
            pOutputIdx.Direction = System.Data.ParameterDirection.Output;

            // Add the parameter
            comm.Parameters.Add(pUserID);
            comm.Parameters.Add(pMovieTitle);
            comm.Parameters.Add(pOutputIdx);
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query
            return (string) comm.Parameters["@Output"].Value;
        }
    }

    /// <summary>
    /// Used to add request titles to the request table in database
    /// </summary>
    /// <param name="gUser">user id of requester</param>
    /// <param name="sTitle">title being rrequested</param>
    public static void DeleteRequest(int request_id)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString);  // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())  // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // query as procedure
            comm.CommandText = "RequestDelete";         // indicate procedure name
            // Make Parameter
            SqlParameter pRequestID = new SqlParameter("@request_id", System.Data.SqlDbType.Int);
            pRequestID.Value = request_id;          // user id filter
            pRequestID.Direction = System.Data.ParameterDirection.Input;

            // Add the parameter
            comm.Parameters.Add(pRequestID);
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query
        }
    }

    /// <summary>
    /// remove entry from content database
    /// </summary>
    /// <param name="sMovID">movie id to add</param>
    /// <returns>return progress message</returns>
    public static string DeleteEntry(string sMovID)
    {
        SqlDataReader reader = null; // return object
        string sReturn = "";
        SqlConnection conn = new SqlConnection(ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate query as procedure
            comm.CommandText = "DeleteTitle";           // indicate procedure name
            // Make Parameter
            SqlParameter pMovieID = new SqlParameter("@mov_id", System.Data.SqlDbType.NVarChar, 100);
            SqlParameter pOutput = new SqlParameter("@output", System.Data.SqlDbType.NVarChar, 100);
            pMovieID.Value = sMovID;    // assign movie id filter

            pMovieID.Direction = System.Data.ParameterDirection.Input;
            pOutput.Direction = System.Data.ParameterDirection.Output;

            // Add the parameter
            comm.Parameters.Add(pMovieID);
            comm.Parameters.Add(pOutput);
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection); // execute query

            sReturn = pOutput.Value.ToString(); // get output value
        }
        return sReturn;
    }

    public static SqlDataReader GetMovieData(string sMovID)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate query as procedure
            comm.CommandText = "SelectTitleInfo";           // indicate procedure name

            SqlParameter pMovieID = new SqlParameter("@mov_id", System.Data.SqlDbType.NVarChar, 100);
            pMovieID.Value = sMovID;    // assign movie id filter
            pMovieID.Direction = System.Data.ParameterDirection.Input;

            comm.Parameters.Add(pMovieID);
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query
        }
        return reader;      // return filtered dataset
    }

    public static string UpdateEntry(string mov_id, string mov_title, string mov_plot, string mov_genre, string mov_size,
            string mov_fileType, string mov_dateAdded, string mov_rating, string mov_rottenID, float mov_rottenRating, string mov_runTime, string mov_lgPoster,
            string mov_smPoster, string mov_directors, string mov_writers, string mov_cast, string mov_producers, string mov_oscars,
            string mov_nominations, string mov_plotkeywords, string mov_trailer, string mov_imdbUrl, string proc)
    {         
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandText = proc;           // indicate procedure name
            comm.CommandType = System.Data.CommandType.StoredProcedure;

            SqlParameter pMovieID = new SqlParameter("@mov_id", System.Data.SqlDbType.NVarChar, 100);
            pMovieID.Value = mov_id;    // assign movie id filter
            pMovieID.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pTitle = new SqlParameter("@mov_title", System.Data.SqlDbType.NVarChar, 100);
            pTitle.Value = mov_title;    // assign movie id filter
            pTitle.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pPlot = new SqlParameter("@mov_plot", System.Data.SqlDbType.NVarChar, 1500);
            pPlot.Value = mov_plot;    // assign movie id filter
            pPlot.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pGenre = new SqlParameter("@mov_genre", System.Data.SqlDbType.NVarChar, 200);
            pGenre.Value = mov_genre;    // assign movie id filter
            pGenre.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pSize = new SqlParameter("@mov_size", System.Data.SqlDbType.NVarChar, 25);
            pSize.Value = mov_size;    // assign movie id filter
            pSize.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pFileType = new SqlParameter("mov_fileType", System.Data.SqlDbType.NVarChar, 10);
            pFileType.Value = mov_fileType;    // assign movie id filter
            pFileType.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pDateAdded = new SqlParameter("@mov_dateAdded", System.Data.SqlDbType.DateTime);
            pDateAdded.Value = mov_dateAdded;    // assign movie id filter
            pDateAdded.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pRating = new SqlParameter("@mov_rating", System.Data.SqlDbType.Float);
            pRating.Value = mov_rating;    // assign movie id filter
            pRating.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pRunTime = new SqlParameter("@mov_runTime", System.Data.SqlDbType.NVarChar, 25);
            pRunTime.Value = mov_runTime;    // assign movie id filter
            pRunTime.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pLgPoster = new SqlParameter("@mov_lgPoster", System.Data.SqlDbType.NVarChar, 255);
            pLgPoster.Value = mov_lgPoster;    // assign movie id filter
            pLgPoster.Direction = System.Data.ParameterDirection.Input;


            SqlParameter pSmPoster = new SqlParameter("@mov_smPoster", System.Data.SqlDbType.NVarChar, 255);
            pSmPoster.Value = mov_smPoster;    // assign movie id filter
            pSmPoster.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pDirectors = new SqlParameter("@mov_directors", System.Data.SqlDbType.NVarChar, 255);
            pDirectors.Value = mov_directors;   // assign movie id filter
            pDirectors.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pWriters = new SqlParameter("@mov_writers", System.Data.SqlDbType.NVarChar, 255);
            pWriters.Value = mov_writers;    // assign movie id filter
            pWriters.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pCast = new SqlParameter("@mov_cast", System.Data.SqlDbType.NVarChar, 500);
            pCast.Value = mov_cast;    // assign movie id filter
            pCast.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pProducers = new SqlParameter("@mov_producers", System.Data.SqlDbType.NVarChar, 255);
            pProducers.Value = mov_producers;   // assign movie id filter
            pProducers.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pOscars = new SqlParameter("@mov_oscars", System.Data.SqlDbType.NVarChar, 5);
            pOscars.Value = mov_oscars;    // assign movie id filter
            pOscars.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pNominations = new SqlParameter("@mov_nominations", System.Data.SqlDbType.NVarChar, 5);
            pNominations.Value = mov_nominations;   // assign movie id filter
            pNominations.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pPlotKeywords = new SqlParameter("@mov_plotkeywords", System.Data.SqlDbType.NVarChar, 255);
            pPlotKeywords.Value = mov_plotkeywords;   // assign movie id filter
            pPlotKeywords.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pTrailer = new SqlParameter("@mov_trailer", System.Data.SqlDbType.NVarChar, 1500);
            pTrailer.Value = mov_trailer;    // assign movie id filter
            pTrailer.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pImdbUrl = new SqlParameter("@mov_imdbUrl", System.Data.SqlDbType.NVarChar, 255);
            pImdbUrl.Value = mov_imdbUrl;    // assign movie id filter
            pImdbUrl.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pRottenID = new SqlParameter("@mov_rottenID", System.Data.SqlDbType.NVarChar, 100);
            pRottenID.Value = mov_rottenID.ToString();    // assign movie id filter
            pRottenID.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pRottenRating = new SqlParameter("@mov_rottenRating", System.Data.SqlDbType.Float);
            pRottenRating.Value = mov_rottenRating;    // assign movie id filter
            pRottenRating.Direction = System.Data.ParameterDirection.Input;

            comm.Parameters.AddRange(new SqlParameter[] { pMovieID, pTitle, pPlot, pGenre, pSize, pFileType,
                pDateAdded, pRating, pRunTime, pLgPoster, pSmPoster, pDirectors, pWriters, pCast, pProducers, pOscars,
                pNominations, pPlotKeywords, pTrailer, pImdbUrl, pRottenID, pRottenRating});
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query
        }
        return "Success";      // return filtered dataset
    }

    public static SqlDataReader CheckChange(string sMovID)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate query as procedure
            comm.CommandText = "DetermineChanges";           // indicate procedure name
            // Make Parameter
            SqlParameter pMovieID = new SqlParameter("@mov_id", System.Data.SqlDbType.NVarChar, 100);
            pMovieID.Value = sMovID;    // assign movie id filter
            pMovieID.Direction = System.Data.ParameterDirection.Input;
            // Add the parameter
            comm.Parameters.Add(pMovieID);
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection); // execute query
        }
        return reader;
    }

    public static SqlDataReader GetUserAverages()
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate query as procedure

            comm.CommandText = "GetUserAverages";           // indicate procedure name

            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query
        }
        return reader;      // return filtered dataset
    }

    public static SqlDataReader GetMovieAverages()
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate query as procedure
            comm.CommandText = "GetMovieAverages";           // indicate procedure name

            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query
        }
        return reader;      // return filtered datase
    }

    public static SqlDataReader GetMovieRatings()
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate query as procedure
            comm.CommandText = "GetMovieRatings";           // indicate procedure name

            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query
        }
        return reader;      // return filtered dataset
    }

    public static SqlDataReader GetSimilarMovie(Guid user,string movie)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate query as procedure
            comm.CommandText = "GetSimilarMovie";           // indicate procedure name

            //for each movie in movies???
            SqlParameter pMovieID = new SqlParameter("@mov_id", System.Data.SqlDbType.NVarChar, 100);
            SqlParameter pUserID = new SqlParameter("@user", System.Data.SqlDbType.NVarChar, 100);

            pMovieID.Value = movie;    // assign movie id filter
            pUserID.Value = movie;

            pMovieID.Direction = System.Data.ParameterDirection.Input;
            pUserID.Direction = System.Data.ParameterDirection.Input;

            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query
        }
        return reader;      // return filtered dataset
    }

    public static SqlDataReader GetUnwatchedMovie(Guid user)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate query as procedure
            comm.CommandText = "GetUnwatchedMovie";           // indicate procedure name

            //for each movie in movies
            SqlParameter pUserID = new SqlParameter("@user_id", System.Data.SqlDbType.NVarChar, 100);
            pUserID.Value = user;    // assign movie id filter
            pUserID.Direction = System.Data.ParameterDirection.Input;

            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query
        }
        return reader;      // return filtered dataset
    }
    
    public static string AddSimilar(List<Recomender.Model> movies)
   {
       SqlDataReader reader = null; 
       string sReturn;
       SqlConnection conn = new SqlConnection(ConnectionString); // create database connection
       conn.Open();
       using (SqlCommand comm = new SqlCommand())      // create query
       {
            comm.CommandText = "AddSimilar";           // indicate procedure name
            // Make Parameter
            SqlParameter pMovieID = new SqlParameter("@mov_id", System.Data.SqlDbType.NVarChar, 100);
            SqlParameter pMatch = new SqlParameter("@match", System.Data.SqlDbType.NVarChar, 100);
            SqlParameter pSimilar = new SqlParameter("@similar", System.Data.SqlDbType.NVarChar, 100);
            SqlParameter pRating = new SqlParameter("@rating", System.Data.SqlDbType.NVarChar, 100);
            SqlParameter pOutput = new SqlParameter("@output", System.Data.SqlDbType.NVarChar, 100);

            pMovieID.Direction = System.Data.ParameterDirection.Input;
            pMatch.Direction = System.Data.ParameterDirection.Input;
            pSimilar.Direction = System.Data.ParameterDirection.Input;
            pRating.Direction = System.Data.ParameterDirection.Input;
            pOutput.Direction = System.Data.ParameterDirection.Output;

                 foreach (Recomender.Model m in movies)
                 {
                     pMovieID.Value = m.movie;
                     pMatch.Value = m.match;
                     pSimilar.Value = m.similarity;
                     pRating.Value = m.rating;

                     comm.Parameters.Add(pMovieID);
                     comm.Parameters.Add(pMatch);
                     comm.Parameters.Add(pSimilar);
                     comm.Parameters.Add(pRating);
                     }
                 
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection); // execute query

            sReturn = pOutput.Value.ToString(); // get output value
        }
        return sReturn;
    }

    public static SqlDataReader GetRottenID(string mov_id)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate query as procedure
            comm.CommandText = "GetRottenID";           // indicate procedure name

            //for each movie in movies
            SqlParameter pMovieID = new SqlParameter("@user_id", System.Data.SqlDbType.NVarChar, 100);
            pMovieID.Value = mov_id;    // assign movie id filter
            pMovieID.Direction = System.Data.ParameterDirection.Input;

            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query
        }
        return reader;      // return filtered dataset
    }

     public static SqlDataReader GetSystemRatings()
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(ConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate query as procedure
            comm.CommandText = "IMDBRottenRating";           // indicate procedure name
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query
        }
        return reader;      // return filtered dataset
    }
    

}