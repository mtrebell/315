/**************** Drop Statements ************************/
IF EXISTS
(
	select [name]
	from sys.tables
	where [name] = 'Recomended'
)
DROP TABLE Recomended
GO

IF EXISTS
(
	select [name]
	from sys.tables
	where [name] = 'Similar'
)
DROP TABLE Similar
GO

IF EXISTS
(
	select [name]
	from sys.tables
	where [name] = 'UserReviews'
)
DROP TABLE UserReviews
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

IF EXISTS
(
	select [name]
	from sys.tables
	where [name] = 'Genre'
)
DROP TABLE Genre
GO

/************** Create Static Tables ******/

CREATE TABLE [Genre]
(
	[genre_id] [int] IDENTITY(1,1) NOT NULL,
	[genre] [nvarchar] (100) NOT NULL
PRIMARY KEY CLUSTERED 
(
	[genre_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

Insert Into [Genre](genre) values ('Action'), ('Adventure'), ('Animation'), 
	('Biography'), ('Comedy'), ('Crime'), ('Documentary'), ('Drama'), ('Family'),
	('Fantasy'), ('Film-Noir'), ('Game-Show'), ('History'), ('Horror'), ('Music'),
	('Musical'), ('Mystery'), ('News'), ('Reality-TV'), ('Romance'), ('Sci-Fi'), 
	('Sport'), ('Talk-Show'), ('Thriller'), ('War'), ('Western'), ('Unassigned')
GO 

/************** Create Dynamic Tables ******/

CREATE TABLE [MovieSummary](
	[mov_id] [nvarchar](100) NOT NULL,
	[mov_title] [nvarchar](100) NOT NULL,
	[mov_plot] [nvarchar](1500) NULL,
	[mov_genre] [nvarchar] (200) NOT NULL,
	[mov_size] [nvarchar](25) NULL,
	[mov_fileType] [nvarchar](10) NULL,
	[mov_runTime] [nvarchar](25) NULL,
	[mov_dateAdded] [datetime] NULL,
	[mov_rating] [float] NULL,
	[mov_smPoster] [nvarchar](255) NULL,
	[mov_lgPoster] [nvarchar](255) NULL,
	[mov_directors] [nvarchar](255) null,
    [mov_writers] [nvarchar](255) null,
    [mov_cast] [nvarchar](500) null,
    [mov_producers] [nvarchar](250) null,
	[mov_oscars] [nvarchar] (5) null,
	[mov_nominations] [nvarchar] (5) null,
	[mov_plotkeywords] [nvarchar] (200) null,
	[mov_trailer] [nvarchar](1500) NULL,
	[mov_imdbUrl] [nvarchar](255) NULL,
	[mov_rottenID][nvarchar] (100) NULL,
	[mov_rottenRating] [float] NULL

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

CREATE TABLE UserReviews
(
	review_id int  identity(1,1)
		PRIMARY KEY,
	mov_id		[nvarchar](100)
		FOREIGN KEY REFERENCES MovieSummary(mov_id),
	users_id		uniqueidentifier,
	dateModified	datetime
		DEFAULT GetDate(),
	rating float null,
	review nvarchar(2000) null
)
GO

/************** Create Dynamic Tables *******************/

CREATE TABLE Recomended
(
	[users_id] uniqueidentifier
		FOREIGN KEY REFERENCES aspnet_Users(UserId),	
	[mov_id] [nvarchar](100)
		FOREIGN KEY REFERENCES MovieSummary(mov_id),
	[mov_rating] [float],
	PRIMARY KEY ([mov_id],[users_id])
)
GO

CREATE TABLE Similar
(
	[mov_id] [nvarchar](100)
		FOREIGN KEY REFERENCES MovieSummary(mov_id),
	[match_id] [nvarchar](100)
		FOREIGN KEY REFERENCES MovieSummary(mov_id),
	[similarity] [float],
	[mov_rating] [float],
	Primary Key ([mov_id],[match_id])
)
GO
