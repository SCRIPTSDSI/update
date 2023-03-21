CREATE TABLE [dbo].[ARTIKUJKLS4]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOEFICENT] [float] NULL,
[TAG] [bit] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[NRSERIAL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PESHESPECIF] [float] NULL,
[NOTACTIV] [bit] NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_AKLS4_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_AKLS4_DATEEDIT] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [KOD_ARTKLS4] ON [dbo].[ARTIKUJKLS4] ([KOD]) ON [PRIMARY]
GO