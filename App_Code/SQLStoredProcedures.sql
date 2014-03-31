
if exists
(
	select[name]
	from sysobjects
	where [name] = 'GetAllGenres'
)
drop procedure GetAllGenres
go

GO
CREATE PROCEDURE GetAllGenres
AS 
    SELECT [genre_id], [genre]
    FROM dbo.Genre
	ORDER BY [genre]
GO




/*************************************************************/
if exists
(
	select[name]
	from sysobjects
	where [name] = 'MovieCollectionGrab'
)
drop procedure MovieCollectionGrab
go

GO
CREATE PROCEDURE MovieCollectionGrab
    @UserID uniqueidentifier
AS 
	SELECT S.*, R.mov_rating as mov_recommended
    FROM dbo.MovieSummary S
      LEFT JOIN dbo.Recomended R ON R.mov_ID = S.mov_ID AND R.users_id = @UserID 
	ORDER BY mov_title
GO

/*************************************************************/
if exists
(
	select[name]
	from sysobjects
	where [name] = 'MovieSearchFilter'
)
drop procedure MovieSearchFilter
go

GO
CREATE PROCEDURE MovieSearchFilter
    @Filter nvarchar(100) = ''
AS 

IF (@Filter = '')

    SELECT mov_smPoster, mov_title, mov_rating, mov_runTime, mov_id 
    FROM dbo.MovieSummary
	ORDER BY mov_title

ELSE
    SELECT mov_smPoster, mov_title, mov_rating, mov_runTime, mov_id  
    FROM dbo.MovieSummary
	WHERE mov_title like ('%' + @Filter + '%')
	ORDER BY mov_title
GO

/*************************************************************/


if exists
(
	select[name]
	from sysobjects
	where [name] = 'MovieMoreInfo'
)
drop procedure MovieMoreInfo
go

GO
CREATE PROCEDURE MovieMoreInfo
    @Index nvarchar(5) = ''
AS 
	SELECT mov_lgPoster, mov_title, mov_runTime, mov_rating, mov_fileType, mov_size, mov_dateAdded, mov_plot, mov_imdbUrl
	FROM dbo.MovieSummary
	WHERE mov_id = @Index
GO

/*************************************************************/

if exists
(
	select[name]
	from sysobjects
	where [name] = 'MovieReviewsFilter'
)
drop procedure MovieReviewsFilter
go

GO
CREATE PROCEDURE MovieReviewsFilter
    @MovID uniqueidentifier
AS 
    SELECT rating, review
    FROM dbo.UserReviews
	Where mov_id = @MovID	
	Order By dateModified		
GO

/*************************************************************/

/*************************************************************/


if exists
(
	select[name]
	from sysobjects
	where [name] = 'MovieRecentlyAdded'
)
drop procedure MovieRecentlyAdded
go

GO
CREATE PROCEDURE MovieRecentlyAdded
AS 
	SELECT mov_smPoster, mov_title, mov_rating, mov_runTime, mov_id  
	FROM dbo.MovieSummary
	WHERE DATEDIFF(day ,getdate(),mov_dateAdded) < 7
GO

/*************************************************************/

if exists
(
	select[name]
	from sysobjects
	where [name] = 'DeleteReviews'
)
drop procedure DeleteReviews
go

GO
CREATE PROCEDURE DeleteReviews
    @UserID uniqueidentifier,
	@MovID int,
    @Output varchar(100) output
AS 
	IF Exists
	( 
		SELECT review_id
		FROM dbo.Favorites
		Where users_id = @UserID
	)

	BEGIN
		DELETE
		FROM dbo.UserReviews
		WHERE @MovID = mov_id AND users_id = @UserID
	END

	IF @@ROWCOUNT > 0
		BEGIN
			select @Output = 'Record Deleted'
			return 0
		END	

	ELSE
		BEGIN
			select @Output = 'No Records deleted, possible error'
			return 1
		END
GO 

/*************************************************************/ 
if exists
(
	select[name]
	from sysobjects
	where [name] = 'InsertReview'
)
drop procedure InsertReview
go

GO
CREATE PROCEDURE InsertReview
    @UserID uniqueidentifier,
	@MovID int,
	@Rating float,
	@Review nvarchar(2000),
    @Output varchar(100) output
AS 
	IF NOT Exists
	( 
		SELECT review_id
		FROM dbo.UserReviews
		Where users_id = @UserID AND mov_id = @MovID
	)	
	BEGIN
		INSERT INTO dbo.UserReviews (mov_id, users_id, rating, review)
		VALUES (@MovID, @UserID, @Rating, @Review)
	END
	
	IF @@ROWCOUNT > 0
		BEGIN
			select @Output = 'Record Inserted'
			return 0
		END	

	ELSE
		BEGIN
			select @Output = 'No Records inserted, possible error'
			return 1
		END
GO

/*************************************************************/
if exists
(
	select[name]
	from sysobjects
	where [name] = 'GetNonAdminUsers'
)
drop procedure GetNonAdminUsers
go

GO
CREATE PROCEDURE GetNonAdminUsers
AS 
	BEGIN
	SELECT U.UserId, U.UserName, U.LastActivityDate 
	FROM vw_aspnet_Users AS U 
		INNER JOIN aspnet_UsersInRoles AS UR 
			ON U.UserId = UR.UserId 
			INNER JOIN aspnet_Roles AS R 
			ON UR.RoleId = R.RoleId 
	WHERE R.RoleName Not Like 'Administrator'
	END
GO

/*************************************************************/
if exists
(
	select[name]
	from sysobjects
	where [name] = 'DeleteUserData'
)
drop procedure DeleteUserData
go

GO
CREATE PROCEDURE DeleteUserData
    @UserID uniqueidentifier,
    @Output varchar(100) output
AS 
	IF Exists
	( 
		SELECT users_id
		FROM dbo.Favorites
		WHERE users_id = @UserID
	)

	BEGIN
		DELETE
		FROM dbo.UserReviews
		WHERE users_id = @UserID 
	
		DELETE
		FROM dbo.Requests
		Where users_id =  @UserID
	END

	IF @@ROWCOUNT > 0
		BEGIN
			select @Output = 'Record Deleted'
			return 0
		END	

	ELSE
		BEGIN
			select @Output = 'No Records deleted, possible error'
			return 1
		END
GO 

/*************************************************************/
if exists
(
	select[name]
	from sysobjects
	where [name] = 'RequestInsert'
)
drop procedure RequestInsert
go

GO
CREATE PROCEDURE RequestInsert
    @Title nvarchar(150) = '',
	@UserID uniqueidentifier, 
	@Output nvarchar(100) output
AS 

IF (@Title != '')
    Insert Into dbo.Requests (requestTitle, users_id)
    Values (@Title, @UserID)

	SELECT @Output = @@Identity
GO

if exists
(
	select[name]
	from sysobjects
	where [name] ='GetRequests'
)
drop procedure GetRequests
GO
/*-------------------------------------------------------------------*/

CREATE PROCEDURE GetRequests
AS
	SELECT	Requests.request_id, 
			aspnet_Users.UserName, 
			Requests.requestDate, 
			Requests.requestTitle 
	FROM	Requests 
				INNER JOIN aspnet_Users 
					ON Requests.users_id = aspnet_Users.UserId 
	ORDER BY Requests.requestTitle, Requests.requestDate 
GO

/*-------------------------------------------------------------------*/
if exists
(
	select[name]
	from sysobjects
	where [name] ='RequestDelete'
)
drop procedure RequestDelete
GO

CREATE PROCEDURE RequestDelete
@request_id int
AS
	DELETE 
	FROM [Requests] 
	WHERE [request_id] = @request_id
GO

/*************************************************************/

if exists
(
	select[name]
	from sysobjects
	where [name] = 'ClearMediaDB'
)
drop procedure ClearMediaDB
go

GO
CREATE PROCEDURE ClearMediaDB
AS
	Delete From FavoriteDetails
	Delete From Favorites
	Delete From MovieSummary
	Delete From Requests
GO

/*************************************************************/

if exists
(
	select[name]
	from sysobjects
	where [name] = 'DeleteTitle'
)
drop procedure DeleteTitle
GO

CREATE PROCEDURE DeleteTitle
     @mov_id nvarchar(100),
	 @Output varchar(100) output
AS
	DELETE FROM [MovieSummary] WHERE [mov_id] = @mov_id

	IF @@ROWCOUNT > 0
		BEGIN
			select @Output = 'Record Deleted'
			return 0
		END	

	ELSE
		BEGIN
			select @Output = 'No Records deleted, possible error'
			return 1
		END
GO

/*************************************************************/

if exists
(
	select[name]
	from sysobjects
	where [name] = 'InsertTitle'
)
drop procedure InsertTitle
GO

CREATE PROCEDURE InsertTitle
     @mov_id nvarchar(100),
	 @mov_title [nvarchar](100),
	 @mov_plot [nvarchar](1500),
	 @mov_genre [nvarchar] (200),
	 @mov_size [nvarchar](25),
	 @mov_fileType [nvarchar](10),
	 @mov_runTime [nvarchar](25),
	 @mov_dateAdded [datetime],
	 @mov_rating Float,
	 @mov_smPoster [nvarchar](255),
	 @mov_lgPoster [nvarchar](255),
	 @mov_directors [nvarchar](255),
     @mov_writers [nvarchar](255),
     @mov_cast [nvarchar](500),
     @mov_producers [nvarchar](250),
	 @mov_oscars [nvarchar] (255),
	 @mov_nominations [nvarchar] (255),
	 @mov_plotkeywords [nvarchar] (200),
	 @mov_trailer [nvarchar](1500),
	 @mov_imdbUrl [nvarchar](255),
	 @mov_rottenID nvarchar(100),
	 @mov_rottenRating float
AS
	INSERT INTO [MovieSummary] ([mov_id],
								[mov_title], 
								[mov_plot],
								[mov_genre], 
								[mov_size], 
								[mov_fileType], 
								[mov_dateAdded], 
								[mov_rating], 
								[mov_runTime], 
								[mov_lgPoster], 
								[mov_smPoster],
								[mov_directors],
								[mov_writers],
								[mov_cast],
								[mov_producers],
								[mov_oscars],
								[mov_nominations],
								[mov_plotkeywords],
								[mov_trailer],
								[mov_imdbUrl],
								[mov_rottenID],
								[mov_rottenRating]) 
		VALUES (@mov_id, @mov_title, @mov_plot, @mov_genre, @mov_size, @mov_fileType, @mov_dateAdded, @mov_rating, @mov_runTime,
		 @mov_lgPoster, @mov_smPoster, @mov_directors, @mov_writers, @mov_cast, @mov_producers, @mov_oscars, @mov_nominations,
		 @mov_plotkeywords, @mov_trailer, @mov_imdbUrl, @mov_rottenID, @mov_rottenRating)
GO

/*************************************************************/

if exists
(
	select[name]
	from sysobjects
	where [name] = 'SelectTitle'
)
drop procedure SelectTitle
GO

CREATE PROCEDURE SelectTitle
AS
	SELECT	[mov_id],
			[mov_title], 
			[mov_plot],
			[mov_genre], 
			[mov_size], 
			[mov_fileType], 
			[mov_dateAdded], 
			[mov_rating], 
			[mov_runTime], 
			[mov_lgPoster], 
			[mov_smPoster],
			[mov_directors],
			[mov_writers],
			[mov_cast],
			[mov_producers],
			[mov_oscars],
			[mov_nominations],
			[mov_plotkeywords],
			[mov_trailer],
			[mov_imdbUrl],
			[mov_rottenID],
			[mov_rottenRating]
		FROM [MovieSummary] 
		ORDER BY [mov_title]
GO

/*************************************************************/

if exists
(
	select[name]
	from sysobjects
	where [name] = 'SelectTitleInfo'
)
drop procedure SelectTitleInfo
GO

CREATE PROCEDURE SelectTitleInfo
@mov_id nvarchar(100)
AS
	SELECT	[mov_id],
			[mov_title], 
			[mov_plot],
			[mov_genre], 
			[mov_size], 
			[mov_fileType], 
			[mov_dateAdded], 
			[mov_rating], 
			[mov_runTime], 
			[mov_lgPoster], 
			[mov_smPoster],
			[mov_directors],
			[mov_writers],
			[mov_cast],
			[mov_producers],
			[mov_oscars],
			[mov_nominations],
			[mov_plotkeywords],
			[mov_trailer],
			[mov_imdbUrl],
			[mov_rottenID],
			[mov_rottenRating]
	FROM [MovieSummary] 
	WHERE @mov_id = [mov_id]	
GO

/*************************************************************/

if exists
(
	select[name]
	from sysobjects
	where [name] = 'UpdateTitle'
)
drop procedure UpdateTitle
GO

CREATE PROCEDURE UpdateTitle
     @mov_id nvarchar(100),
	 @mov_title [nvarchar](100),
	 @mov_plot [nvarchar](1500),
	 @mov_genre [nvarchar] (200),
	 @mov_size [nvarchar](25),
	 @mov_fileType [nvarchar](10),
	 @mov_runTime [nvarchar](25),
	 @mov_dateAdded [datetime],
	 @mov_rating Float,
	 @mov_smPoster [nvarchar](255),
	 @mov_lgPoster [nvarchar](255),
	 @mov_directors [nvarchar](255),
     @mov_writers [nvarchar](255),
     @mov_cast [nvarchar](500),
     @mov_producers [nvarchar](250),
	 @mov_oscars [nvarchar] (255),
	 @mov_nominations [nvarchar] (255),
	 @mov_plotkeywords [nvarchar] (200),
	 @mov_trailer [nvarchar](1500),
	 @mov_imdbUrl [nvarchar](255),
	 @mov_rottenID nvarchar(100),
	 @mov_rottenRating float
AS
	UPDATE [MovieSummary] SET [mov_title] = @mov_title, 
							  [mov_plot] = @mov_plot, 
							  [mov_size] = @mov_size, 
							  [mov_fileType] = @mov_fileType, 
							  [mov_genre] = @mov_genre,
							  [mov_dateAdded] = @mov_dateAdded, 
							  [mov_rating] = @mov_rating, 
							  [mov_runTime] = @mov_runTime, 
							  [mov_lgPoster] = @mov_lgPoster, 
							  [mov_smPoster] = @mov_smPoster,
							  [mov_directors] = @mov_directors,
							  [mov_writers] = @mov_writers,
							  [mov_cast] = @mov_cast,
							  [mov_producers] = @mov_producers,
							  [mov_oscars] = @mov_oscars,
							  [mov_nominations] = @mov_nominations,
							  [mov_plotkeywords] = @mov_plotkeywords,
							  [mov_trailer] = @mov_trailer,
							  [mov_imdbUrl] = @mov_imdbUrl,
							  [mov_rottenID] =  @mov_rottenID,
							  [mov_rottenRating] = @mov_rottenRating
		WHERE [mov_id] = @mov_id
GO

/*************************************************************/
if exists
(
	select[name]
	from sysobjects
	where [name] = 'GetUserAverages'
)
drop procedure GetUserAverages
go

GO
CREATE PROCEDURE GetUserAverages

AS 
    SELECT users_id, AVG(rating)
    FROM dbo.UserReviews
	GROUP BY users_id
GO
/*************************************************************/
if exists
(
	select[name]
	from sysobjects
	where [name] = 'GetMovieAverages'
)
drop procedure GetMovieAverages
go

GO
CREATE PROCEDURE GetMovieAverages

AS 
    SELECT movie_id, AVG(rating)
    FROM dbo.UserReviews
	GROUP BY mov_id
GO
/*************************************************************/
if exists(
	select[name]
	from sysobjects

	where [name] = 'GetMovieRatings'
	)
drop procedure GetMovieRatings
go

GO
CREATE PROCEDURE GetMovieRatings

AS 
    SELECT mov_id,users_id,rating
    FROM dbo.UserReviews
	ORDER BY mov_id
GO

/*************************************************************/
if exists
(
	select[name]
	from sysobjects
	where [name] = 'GetSimilarMovie'
)
drop procedure GetSimilarMovie
go

GO
CREATE PROCEDURE GetSimilarMovie
@mov_id nvarchar(100)

AS 
    SELECT mov_id,match,similarity,rating
    FROM dbo.MovieRatings
	WHERE [mov_id] = @mov_id OR [match] = @mov_id;
GO

/*************************************************************/
if exists
(
	select[name]
	from sysobjects
	where [name] = 'GetUnwatchedMovie'
)
drop procedure GetUnwatchedMovie
go

GO
CREATE PROCEDURE GetUnwatchedMovie
@user_id nvarchar(100)

AS 
    SELECT mov_id
    FROM dbo.UserReviews AS t1
	WHERE t1.mov_id NOT IN (SELECT mov_id FROM dbo.MovieRatings AS t2 WHERE [users_id] = @user_id)
GO

/*************************************************************/
if exists
(
	select[name]
	from sysobjects
	where [name] = 'AddSimilar'
)
drop procedure AddSimilar
GO

GO
CREATE PROCEDURE AddSimilar
@mov_id nvarchar(100),
@match nvarchar(100),
@similar nvarchar(100),
@rating nvarchar(100)
AS
BEGIN
 INSERT INTO dbo.similar (mov_id, match_id, similarity, mov_rating) 
 VALUES (@mov_id, @match, @similar, @rating)
END
GO

if exists
(
	select[name]
	from sysobjects
	where [name] = 'AddRating'
)
drop procedure AddRating
GO

GO
CREATE PROCEDURE AddRating
@mov_id nvarchar(100),
@user_id nvarchar(100),
@rating nvarchar(100)
AS
BEGIN
 INSERT INTO dbo.UserReviews(users_id,mov_id,rating) 
 VALUES (@user_id, @mov_id, @rating)
 END
 GO

 /*-------------------------------------------------------------------*/
if exists
(
	select[name]
	from sysobjects
	where [name] ='DetermineChanges'
)
drop procedure DetermineChanges
GO

CREATE PROCEDURE DetermineChanges
@mov_id nvarchar(100)
AS
	SELECT	[mov_lgPoster], 
			[mov_smPoster]
	FROM [MovieSummary] 
	WHERE @mov_id = [mov_id]	
GO

 /*-------------------------------------------------------------------*/
if exists
(
	select[name]
	from sysobjects
	where [name] ='GetRottenID'
)
drop procedure GetRottenID
GO

CREATE PROCEDURE GetRottenID
@mov_id nvarchar(100)
AS
	SELECT	[mov_rottenID]
	FROM [MovieSummary] 
	WHERE @mov_id = [mov_id]	
GO






