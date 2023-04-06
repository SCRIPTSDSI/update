CREATE TABLE [dbo].[AQKls4]
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
[DATECREATE] [datetime] NULL CONSTRAINT [DF_AQKLS4_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_AQKLS4_DATEEDIT] DEFAULT (getdate()),
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAG] [bit] NULL,
[TAGNR] [int] NULL,
[terst] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
