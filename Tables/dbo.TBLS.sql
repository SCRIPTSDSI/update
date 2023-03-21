CREATE TABLE [dbo].[TBLS]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRORDER] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIP] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TABLENAME] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROMPT] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODUL] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBJEKT] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STRUCTURE] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
