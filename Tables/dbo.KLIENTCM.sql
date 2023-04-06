CREATE TABLE [dbo].[KLIENTCM]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL CONSTRAINT [DF_KLIENTCM_NRD] DEFAULT ((0)),
[KODKL] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMSH] [float] NULL,
[ACTIV] [bit] NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIMKL] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NOTACTIV] [bit] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATROW] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDERSCR] [int] NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_KLIENTCM_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_KLIENTCM_DATEEDIT] DEFAULT (getdate()),
[TAG] [bit] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_KLIENTCM] ON [dbo].[KLIENTCM] ([NRD]) ON [PRIMARY]
GO
