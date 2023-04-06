CREATE TABLE [dbo].[JOBSSTART]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODUL] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GRUP] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIMSQL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATEJOBS] [datetime] NULL,
[DATEAFTER] [datetime] NULL,
[ROWSCOUNT] [int] NULL,
[STATUS] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAG] [bit] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
