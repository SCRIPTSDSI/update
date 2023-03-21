CREATE TABLE [dbo].[RelacionReferenca]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODDST] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARI] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPKLL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIMDST] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_RelacionReferenca_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_RelacionReferenca_DATEEDIT] DEFAULT (getdate()),
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RelacionReferenca] ADD CONSTRAINT [kod_unikrfr] UNIQUE NONCLUSTERED  ([KOD]) ON [PRIMARY]
GO
