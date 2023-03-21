CREATE TABLE [dbo].[Countries]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INTCOUNTRYKOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INTISOKOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INTCURRENCYKOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_Countries_DateCreate] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_Countries_DateEdit] DEFAULT (getdate()),
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[NOTACTIV] [bit] NULL
) ON [PRIMARY]
GO
