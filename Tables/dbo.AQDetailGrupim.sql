CREATE TABLE [dbo].[AQDetailGrupim]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GRUPI] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODFORME] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FORMNAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TABLENAME] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRORDER] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM1] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM2] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VISIBLE] [bit] NULL,
[NOTACTIV] [bit] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_AQTableListItems_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_AQTableListItems_DATEEDIT] DEFAULT (getdate()),
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
