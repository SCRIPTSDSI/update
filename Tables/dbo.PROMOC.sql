CREATE TABLE [dbo].[PROMOC]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM1] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM2] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM3] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPI] [int] NULL,
[DATESTA] [datetime] NULL,
[DATEEND] [datetime] NULL,
[DATELIMITED] [bit] NULL,
[KLASIFIKIM1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODLMFF] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODLMFJ] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NOTACTIV] [bit] NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_PRC_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_PRC_DATEEDIT] DEFAULT (getdate()),
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
