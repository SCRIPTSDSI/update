CREATE TABLE [dbo].[TablesName]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[TABLESTR] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRORDER] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TABLENAME] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODUL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIP] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBJEKT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STRUCTURE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LIST] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDERLM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KALIMLM] [bit] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
