CREATE TABLE [dbo].[tempartikujnjesi]
(
[kod] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[njesi] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tempartikujnjesi] ADD CONSTRAINT [PK__temparti__2E8B20C7F7736336] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
