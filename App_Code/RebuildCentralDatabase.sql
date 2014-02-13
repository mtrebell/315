
IF EXISTS
(
	select [name]
	from sys.tables
	where [name] = 'Reviews'
)
DROP TABLE Reviews
GO

IF EXISTS
(
	select [name]
	from sys.tables
	where [name] = 'MovieData'
)
DROP TABLE MovieData
GO

CREATE TABLE [MovieData](
	[mov_id] [nvarchar](1500) NOT NULL,
	[rating] [double] not null default 0,
	[votes] [int] not null default 0
PRIMARY KEY CLUSTERED 
(
	[mov_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


CREATE TABLE Reviews
(
	review_id	int	IDENTITY (1,1)
		PRIMARY KEY,
	mov_id		[nvarchar](1500) 
		FOREIGN KEY REFERENCES MovieData(mov_id) not null,
	review_content		[nvarchar](max) not null	
)
GO


