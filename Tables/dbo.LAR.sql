CREATE TABLE [dbo].[LAR]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KMON] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBARTUR] [float] NULL,
[MBARTURMV] [float] NULL,
[GJ] [float] NULL,
[GJMV] [float] NULL,
[SG1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SG2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SG3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SG4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SG5] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SG6] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SG7] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SG8] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SG9] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SG10] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [@KOD_LAR] ON [dbo].[LAR] ([KOD]) ON [PRIMARY]
GO
