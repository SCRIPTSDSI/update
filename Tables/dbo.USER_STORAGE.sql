CREATE TABLE [dbo].[USER_STORAGE]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[USERNAME] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DATA] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[USER_STORAGE] ADD CONSTRAINT [PK__USER_STO__23173F677D446614] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
