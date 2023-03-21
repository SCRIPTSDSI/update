CREATE TABLE [dbo].[ArtikujPlanProces]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SASI] [float] NULL,
[NOTACTIV] [bit] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_StockProces_DATEEDIT] DEFAULT (getdate()),
[DATECREATE] [datetime] NULL CONSTRAINT [DF_StockProces_DATECREATE] DEFAULT (getdate()),
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[SHENIM1] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM2] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODLP] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NR] [int] NULL
) ON [PRIMARY]
GO
