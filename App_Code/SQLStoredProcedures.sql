
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
AS 
    SELECT *
	/*mov_smPoster, mov_title, mov_rating, mov_runTime, mov_id */
    FROM dbo.MovieSummary
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
	where [name] = 'MovieFavoritesFilter'
)
drop procedure MovieFavoritesFilter
go

GO
CREATE PROCEDURE MovieFavoritesFilter
    @UserID uniqueidentifier
AS 
    SELECT mov_smPoster, mov_title, mov_rating, mov_runTime, MS.mov_id 
    FROM dbo.MovieSummary as MS
    inner join dbo.FavoriteDetails as FD
    on FD.mov_id = MS.mov_id
	WHERE favorite_id =  
		( 
			SELECT favorite_id
			FROM dbo.Favorites
			Where users_id = @UserID			
		)
	ORDER BY mov_title
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
	where [name] = 'DeleteFavorites'
)
drop procedure DeleteFavorites
go

GO
CREATE PROCEDURE DeleteFavorites
    @UserID uniqueidentifier,
	@MovID int,
    @Output varchar(100) output
AS 
	IF Exists
	( 
		SELECT favorite_id
		FROM dbo.Favorites
		Where users_id = @UserID
	)

	BEGIN
		DELETE
		FROM dbo.FavoriteDetails
		WHERE @MovID = mov_id AND favorite_id =  
					( 
						SELECT favorite_id
						FROM dbo.Favorites
						Where users_id = 
					  					( 
											SELECT UserID
											FROM dbo.aspnet_Users
											Where UserID = @UserID
										)
					)
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
	where [name] = 'InsertFavorites'
)
drop procedure InsertFavorites
go

GO
CREATE PROCEDURE InsertFavorites
    @UserID uniqueidentifier,
	@MovID int,
    @Output varchar(100) output
AS 
	IF NOT Exists
	( 
		SELECT favorite_id
		FROM dbo.Favorites
		Where users_id = @UserID
	)	
		BEGIN
			INSERT INTO dbo.Favorites (users_id)
			VALUES (@UserID)
		END
 
	IF NOT Exists
	( 
		SELECT mov_id
		FROM dbo.FavoriteDetails
		Where mov_id = @MovID AND favorite_id =
									(
									SELECT favorite_id
									FROM dbo.Favorites
									WHERE users_id = @UserID
									)
	)
	BEGIN
		INSERT INTO dbo.FavoriteDetails
		VALUES ((SELECT favorite_id
				 FROM dbo.Favorites
				 WHERE users_id = @UserID),
				 @MovID) 
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
		FROM dbo.FavoriteDetails
		WHERE favorite_id =  
					( 
						SELECT favorite_id
						FROM dbo.Favorites
						Where users_id = 
					  					( 
											SELECT UserID
											FROM dbo.aspnet_Users
											Where UserID = @UserID
										)
					)
			
		DELETE
		FROM dbo.Favorites
		Where users_id = 
						( 
							SELECT UserID
							FROM dbo.aspnet_Users
							Where UserID = @UserID
						)
	End

	IF Exists
	( 
	SELECT users_id
	FROM dbo.Requests
	WHERE users_id = @UserID
	)
	BEGIN
		DELETE
		FROM dbo.Requests
		Where users_id = 
					( 
						SELECT UserID
						FROM dbo.aspnet_Users
						Where UserID = @UserID
					)
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
	@UserID uniqueidentifier 
AS 

IF (@Title != '')
    Insert Into dbo.Requests (requestTitle, users_id)
    Values (@Title, @UserID)
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
	 @mov_genre [nvarchar] (25),
	 @mov_size [nvarchar](25),
	 @mov_fileType [nvarchar](10),
	 @mov_runTime [nvarchar](25),
	 @mov_dateAdded [datetime],
	 @mov_rating [nvarchar](10),
	 @mov_smPoster [nvarchar](255),
	 @mov_lgPoster [nvarchar](255),
	 @mov_trailer [nvarchar](1500),
	 @mov_imdbUrl [nvarchar](255)
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
								[mov_trailer],
								[mov_imdbUrl]) 
		VALUES (@mov_id, @mov_title, @mov_plot, @mov_genre, @mov_size, @mov_fileType, @mov_dateAdded, 
			@mov_rating, @mov_runTime, @mov_lgPoster, @mov_smPoster, @mov_trailer, @mov_imdbUrl)
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
			[mov_trailer],
			[mov_imdbUrl]
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
			[mov_trailer],
			[mov_imdbUrl]
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
	 @mov_genre [nvarchar] (25),
	 @mov_size [nvarchar](25),
	 @mov_fileType [nvarchar](10),
	 @mov_runTime [nvarchar](25),
	 @mov_dateAdded [datetime],
	 @mov_rating [nvarchar](10),
	 @mov_smPoster [nvarchar](255),
	 @mov_lgPoster [nvarchar](255),
	 @mov_trailer [nvarchar](1500),
	 @mov_imdbUrl [nvarchar](255)
AS
	UPDATE [MovieSummary] SET [mov_id] = @mov_id,
							  [mov_title] = @mov_title, 
							  [mov_plot] = @mov_plot, 
							  [mov_size] = @mov_size, 
							  [mov_fileType] = @mov_fileType, 
							  [mov_dateAdded] = @mov_dateAdded, 
							  [mov_rating] = @mov_rating, 
							  [mov_runTime] = @mov_runTime, 
							  [mov_lgPoster] = @mov_lgPoster, 
							  [mov_smPoster] = @mov_smPoster 
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
    SELECT user_id, AVG(rating)
    FROM dbo.MovieRatings
	GROUP BY user_id
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
    FROM dbo.ratings
	GROUP BY movie_id
GO
/*************************************************************/
if exists
(
	select[name]
	from sysobjects
	where [name] = 'GetMoiveRatings'
)
drop procedure GetMovieRatings
go

GO
CREATE PROCEDURE GetMovieRatings

AS 
    SELECT movie_id,user_id,rating
    FROM dbo.MovieRatings
	ORDER BY movie_id
GO

/*************************************************************/
if exists
(
	select[name]
	from sysobjects
	where [name] = 'GetSimilarMoive'
)
drop procedure GetSimilarMovie
go

GO
CREATE PROCEDURE GetSimilarMovie
@mov_id nvarchar(100)

AS 
    SELECT mov_id,match_id,similarity,rating
    FROM dbo.MovieRatings
	WHERE [mov_id] = @mov_id OR [match_id] = @mov_id
	ORDER BY match_id
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
    FROM dbo.MovieRatings AS t1
	WHERE t1.mov_id NOT IN (SELECT mov_id FROM dbo.MovieRatings AS t2 WHERE [user_id] = @user_id)
GO

/*************************************************************/
if exists
(
	select[name]
	from sysobjects
	where [name] = 'AddSimilar'
)
drop procedure AddSimilar
go

GO

GO
CREATE PROCEDURE AddSimilar
@mov_id nvarchar(100),
@match nvarchar(100),
@similar nvarchar(100),
@rating nvarchar(100)
AS
BEGIN
 INSERT INTO dbo.similar (mov_id, match,similar,rating) 
 VALUES (@mov_id, @match,@similar,@rating)
END

if exists
(
	select[name]
	from sysobjects
	where [name] = 'AddRating'
)
drop procedure AddRating
go

GO

GO
CREATE PROCEDURE AddRating
@mov_id nvarchar(100),
@user_id nvarchar(100),
@rating nvarchar(100)
AS
BEGIN
 INSERT INTO dbo.ratings(user_id,moive_id,rating) 
 VALUES (@user_id, @movie_id, @rating)
 END
