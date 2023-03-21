CREATE TABLE [dbo].[AQCFGAuto]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[KODCFG] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRORDER] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FIELDKOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FIELDPROMPT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FIELDNAME] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOMENT] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FIELDKOMENT] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAGNR] [int] NULL,
[TROW] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
