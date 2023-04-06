CREATE TABLE [dbo].[ArtikujPlanStockJavor]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GJENDJE01] [float] NULL,
[GJENDJE02] [float] NULL,
[GJENDJE03] [float] NULL,
[GJENDJE04] [float] NULL,
[GJENDJE05] [float] NULL,
[GJENDJE06] [float] NULL,
[GJENDJE07] [float] NULL,
[NOTACTIV] [bit] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_StockPlan_DATEEDIT] DEFAULT (getdate()),
[DATECREATE] [datetime] NULL CONSTRAINT [DF_StockPlan_DATECREATE] DEFAULT (getdate()),
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[SASIMIN] [float] NULL,
[KODLP] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NR] [int] NULL
) ON [PRIMARY]
GO
