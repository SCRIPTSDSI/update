CREATE TABLE [dbo].[ArtikujKtgKL]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[DATEDOK] [datetime] NULL,
[NRDOK] [int] NULL,
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM1] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM2] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATEDOKCREATE] [datetime] NULL,
[DATESTART] [datetime] NULL,
[DATEEND] [datetime] NULL,
[COLUMNLIST] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LISTORDEREDMK] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS] [int] NULL,
[ACTIV] [bit] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAGNR] [int] NULL,
[TROW] [bit] NULL
) ON [PRIMARY]
GO
