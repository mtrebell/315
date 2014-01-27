
IF EXISTS
(
	select [name]
	from sys.tables
	where [name] = 'FavoriteDetails'
)
DROP TABLE FavoriteDetails
GO

IF EXISTS
(
	select [name]
	from sys.tables
	where [name] = 'Favorites'
)
DROP TABLE Favorites
GO

IF EXISTS
(
	select [name]
	from sys.tables
	where [name] = 'MovieSummary'
)
DROP TABLE MovieSummary
GO

IF EXISTS
(
	select [name]
	from sys.tables
	where [name] = 'Requests'
)
DROP TABLE Requests
GO

CREATE TABLE [MovieSummary](
	[mov_id] [int] IDENTITY(1,1) NOT NULL,
	[mov_title] [nvarchar](100) NULL,
	[mov_plot] [nvarchar](1500) NULL,
	[mov_size] [nvarchar](25) NULL,
	[mov_fileType] [nvarchar](10) NULL,
	[mov_runTime] [nvarchar](25) NULL,
	[mov_dateAdded] [datetime] NULL,
	[mov_rating] [nvarchar](10) NULL,
	[mov_smPoster] [nvarchar](255) NULL,
	[mov_lgPoster] [nvarchar](255) NULL,
	[mov_imdbUrl] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[mov_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[MovieSummary] ADD  DEFAULT (getdate()) FOR [mov_dateAdded]
GO


CREATE TABLE Requests
(
	request_id		int	IDENTITY (1,1)
		PRIMARY KEY,
	users_id		uniqueidentifier
		FOREIGN KEY REFERENCES aspnet_Users(UserId),
	requestDate		datetime
		DEFAULT	GetDate(),
	requestTitle	nvarchar(100) not null		
)
GO

CREATE TABLE Favorites
(
	favorite_id		int  identity(1,1)
		PRIMARY KEY,
	users_id		uniqueidentifier
		FOREIGN KEY REFERENCES aspnet_Users(UserId),
	dateModified	datetime
		DEFAULT GetDate()		
)
GO

CREATE TABLE FavoriteDetails
(
	favorite_id		int  
		FOREIGN KEY REFERENCES Favorites(favorite_id),
	mov_id		int
		FOREIGN KEY REFERENCES MovieSummary(mov_id),
)
GO

