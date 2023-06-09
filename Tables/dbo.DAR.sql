CREATE TABLE [dbo].[DAR]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRDITAR] [bigint] NULL,
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOMENT] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KMON] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KURS1] [float] NULL,
[KURS2] [float] NULL,
[TIPDOK] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRDOK] [bigint] NULL,
[FRAKSDOK] [int] NULL,
[DATEDOK] [datetime] NULL,
[VLEFTA] [float] NULL,
[VLEFTAMV] [float] NULL,
[TREGDK] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRLIBER] [bigint] NULL,
[TIPFAT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRFAT] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTFAT] [datetime] NULL,
[ISDOKSHOQ] [bit] NULL,
[KODMASTER] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[TIPKLL] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRRENDORDOK] [int] NULL CONSTRAINT [DF_DAR_NRRENDORDOK] DEFAULT ((0)),
[LLOJDOK] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDERTD] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRANNUMBER] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODREF] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DET1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DET2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DET3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DET4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DET5] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DAR] ADD CONSTRAINT [PK_DAR] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NRD_DAR] ON [dbo].[DAR] ([NRRENDOR]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NRRENDORDOK] ON [dbo].[DAR] ([NRRENDORDOK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TRANNUMBER] ON [dbo].[DAR] ([TRANNUMBER]) ON [PRIMARY]
GO
