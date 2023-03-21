CREATE TABLE [dbo].[OrdRowsDoc]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[DOC] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EDITMODE] [bit] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
