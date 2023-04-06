CREATE TABLE [dbo].[AQKls1]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRSERIAL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PESHESPECIF] [float] NULL,
[KOEFICENT] [float] NULL,
[NOTACTIV] [bit] NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_AQKLS1_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_AQKLS1_DATEEDIT] DEFAULT (getdate()),
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAG] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
