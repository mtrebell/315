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
    public static SqlDataReader MovieDisplayContent(string sMovieFilter)
    {
        SqlDataReader reader = null; // return object
        SqlConnection conn = new SqlConnection(sConnectionString);  // create database connection
        conn.Open();
        using (SqlCommand comm = new SqlCommand())                      // create query
        {
            comm.Connection = conn;
            comm.CommandType = System.Data.CommandType.StoredProcedure; // call stored procedure
            comm.CommandText = "MovieAlphabetFilter";                   // name of procedure
            // Make Parameter
            SqlParameter pCustomerID = new SqlParameter("@Filter", System.Data.SqlDbType.NChar);
            pCustomerID.Value = sMovieFilter;       // assign filter value
            pCustomerID.Direction = System.Data.ParameterDirection.Input;
            // Add the parameter
            comm.Parameters.Add(pCustomerID);
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
    public static string InsertIntoFavorites(int iMovID, Guid gUser)
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
            SqlParameter pMovieID = new SqlParameter("@MovID", System.Data.SqlDbType.Int);
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
}