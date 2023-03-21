CREATE TABLE [dbo].[SG_LIBRAT]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[PERSHKRIM] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRSEGL] [int] NULL,
[NRSEGD] [int] NULL,
[LIBER] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DITAR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIP] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
