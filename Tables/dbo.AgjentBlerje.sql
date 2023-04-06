CREATE TABLE [dbo].[AgjentBlerje]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GRUPI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZONA] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEP] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LISTE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NOTACTIV] [bit] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_AgjentBlerje_DATECREATE] DEFAULT (getdate()),
[DATEDIT] [datetime] NULL CONSTRAINT [DF_AgjentBlerje_DATEDIT] DEFAULT (getdate()),
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[KODARKE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KMAG] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRANSPORT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AgjentBlerje] ADD CONSTRAINT [kod_unik_agjentbl] UNIQUE NONCLUSTERED  ([KOD]) ON [PRIMARY]
GO
