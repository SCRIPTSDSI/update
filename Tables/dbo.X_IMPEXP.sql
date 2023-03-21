CREATE TABLE [dbo].[X_IMPEXP]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[FORDER] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODUL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPEXP] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPROW] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPDOK] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FNAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IMPORT] [bit] NULL,
[EXPORT] [bit] NULL,
[KUFIP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KUFIS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NDARES] [bit] NULL,
[TAG] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
