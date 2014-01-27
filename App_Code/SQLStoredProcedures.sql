
if exists
(
	select[name]
	from sysobjects
	where [name] = 'MovieAlphabetFilter'
)
drop procedure MovieAlphabetFilter
go

GO
CREATE PROCEDURE MovieAlphabetFilter
    @Filter nvarchar(5) = ''
AS 

IF (@Filter = '*')

    SELECT mov_smPoster, mov_title, mov_rating, mov_runTime, mov_id 
    FROM dbo.MovieSummary
	ORDER BY mov_title

ELSE
    SELECT mov_smPoster, mov_title, mov_rating, mov_runTime, mov_id  
    FROM dbo.MovieSummary
	WHERE mov_title like (@Filter + '%')
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