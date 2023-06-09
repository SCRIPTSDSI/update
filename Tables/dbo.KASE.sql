CREATE TABLE [dbo].[KASE]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODKL] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KMAG] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRRENDORKP] [int] NULL,
[NRRENDORKS] [int] NULL,
[TAG] [bit] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[NOTACTIV] [bit] NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_KAS_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_KAS_DATEEDIT] DEFAULT (getdate()),
[fisctcrnum] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISCBUSUNITCODE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [@KOD_KASE] ON [dbo].[KASE] ([KOD]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [@NRRENDOR_KASE] ON [dbo].[KASE] ([NRRENDOR]) ON [PRIMARY]
GO
