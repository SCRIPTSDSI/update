CREATE TABLE [dbo].[KODCHANGE]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODNEW] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPKLL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIMNEW] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATE] [datetime] NULL,
[PERDORUES] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
