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
    private static string sConnectionString =
    ConfigurationManager.ConnectionStrings["InternalConnectionString"].ConnectionString;

    /// <summary>
    /// Used to find all movie database information based off first character in title
    /// if no letter is selected * , finds all database items
    /// </summary>
    /// <param name="sMovieFilter">letter filter string</param>
    /// <returns>returned datasource of filtered info</returns>
    public static SqlDataReader MovieDisplayContent()
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(sConnectionString);  // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())                      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // call stored procedure
            comm.CommandText = "MovieCollectionGrab";                   // name of procedure
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
        SqlConnection conn = new SqlConnection(sConnectionString);  // create database connection
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
    public static SqlDataReader FavoritesDisplayContent(Guid gUser)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(sConnectionString);
        conn.Open();
        using (SqlCommand comm = new SqlCommand())
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // query is stored procedure
            comm.CommandText = "MovieFavoritesFilter";          // call procedure name
            // Make Parameter
            SqlParameter pUserID = new SqlParameter("@UserID", System.Data.SqlDbType.UniqueIdentifier);
            pUserID.Value = gUser;  // apply user id filter
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
        SqlConnection conn = new SqlConnection(sConnectionString);  // create database connection
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
    public static string DeleteFromFavorites(int iMovID, Guid gUser)
    {
        SqlDataReader reader = null; // return object
        string sReturn = "";
        SqlConnection conn = new SqlConnection(sConnectionString);  // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate as procedure
            comm.CommandText = "DeleteFavorites";               // indicate procedure name
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
    public static string InsertIntoFavorites(string iMovID, Guid gUser)
    {
        SqlDataReader reader = null; // return object
        string sReturn = "";
        SqlConnection conn = new SqlConnection(sConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate query as procedure
            comm.CommandText = "InsertFavorites";           // indicate procedure name
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
        SqlConnection conn = new SqlConnection(sConnectionString); // create database connection
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
        SqlConnection conn = new SqlConnection(sConnectionString); // create database connection
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
        SqlConnection conn = new SqlConnection(sConnectionString);      // create database connection
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
    public static void InsertRequest(Guid gUser, string sTitle)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(sConnectionString);  // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())  // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // query as procedure
            comm.CommandText = "RequestInsert";         // indicate procedure name
            // Make Parameter
            SqlParameter pUserID = new SqlParameter("@UserID", System.Data.SqlDbType.UniqueIdentifier);
            SqlParameter pMovieTitle = new SqlParameter("@Title", System.Data.SqlDbType.NVarChar, 150);
            pUserID.Value = gUser;          // user id filter
            pMovieTitle.Value = sTitle;     // title filter

            pUserID.Direction = System.Data.ParameterDirection.Input;
            pMovieTitle.Direction = System.Data.ParameterDirection.Input;

            // Add the parameter
            comm.Parameters.Add(pUserID);
            comm.Parameters.Add(pMovieTitle);
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
        SqlConnection conn = new SqlConnection(sConnectionString); // create database connection
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
        SqlConnection conn = new SqlConnection(sConnectionString); // create database connection
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
        string mov_fileType, string mov_dateAdded, string mov_rating, string mov_runTime, string mov_lgPoster,
        string mov_smPoster, string mov_trailer, string mov_imdbUrl, string proc)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(sConnectionString); // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // indicate query as procedure
            comm.CommandText = proc;           // indicate procedure name

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

            SqlParameter pTrailer = new SqlParameter("@mov_trailer", System.Data.SqlDbType.NVarChar, 1500);
            pTrailer.Value = mov_trailer;    // assign movie id filter
            pTrailer.Direction = System.Data.ParameterDirection.Input;

            SqlParameter pImdbUrl = new SqlParameter("@mov_imdbUrl", System.Data.SqlDbType.NVarChar, 255);
            pImdbUrl.Value = mov_imdbUrl;    // assign movie id filter
            pImdbUrl.Direction = System.Data.ParameterDirection.Input;

            comm.Parameters.AddRange(new SqlParameter[] { pMovieID, pTitle, pPlot, pGenre, pSize, pFileType,
                pDateAdded, pRating, pRunTime, pLgPoster, pSmPoster, pTrailer, pImdbUrl} );
            reader = comm.ExecuteReader(System.Data.CommandBehavior.CloseConnection);   // execute query
        }
        return "Success";      // return filtered dataset
    }

    public static SqlDataReader CheckChange(string sMovID)
    {
        SqlDataReader reader = null; // return object
        string sReturn = "";
        SqlConnection conn = new SqlConnection(sConnectionString); // create database connection
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
}