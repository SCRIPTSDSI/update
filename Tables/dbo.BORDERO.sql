CREATE TABLE [dbo].[BORDERO]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[DATEDOK] [datetime] NULL,
[LLOGARI] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODL] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARIPK] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARIBO] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOMENT] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DB] [float] NULL,
[KR] [float] NULL,
[DBKRMV] [float] NULL,
[KMON] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KURS1] [float] NULL,
[KURS2] [float] NULL,
[TREGDK] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRDOK] [int] NULL,
[NRDFK] [int] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
