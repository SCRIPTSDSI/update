CREATE TABLE [dbo].[AgjentBlerjeFurnitor]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM4] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GRUP] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPI] [int] NULL,
[ZONA] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NOTACTIV] [bit] NULL CONSTRAINT [DF_AgjentBlerjeFurnitor_NOTACTIV] DEFAULT ((0)),
[DATECREATE] [datetime] NULL CONSTRAINT [DF_AgjentBlerjeFurnitor_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_AgjentBlerjeFurnitor_DATEEDIT] DEFAULT (getdate()),
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAG] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [NrRendor_AgjentBlerjeFurnitor] ON [dbo].[AgjentBlerjeFurnitor] ([NRRENDOR]) ON [PRIMARY]
GO
