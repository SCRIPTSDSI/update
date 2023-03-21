CREATE TABLE [dbo].[MagazinaKthim]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KMAG] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KMAGDST] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIMDST] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_MagazinaKthim_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_MagazinaKthim_DATEEDIT] DEFAULT (getdate()),
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[MODUL] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARI] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
