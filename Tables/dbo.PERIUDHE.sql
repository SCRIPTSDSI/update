CREATE TABLE [dbo].[PERIUDHE]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[DATA] [datetime] NULL,
[PERIUDHE] [int] NULL,
[PERSHKRIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GJENDJE] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATA1] [datetime] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
