CREATE TABLE [dbo].[FurnitorCmim]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[KODFRF] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIMRF] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACTIV] [bit] NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMIMBS] [float] NULL,
[TATIM] [bit] NULL,
[NOTACTIV] [bit] NULL,
[NRDOK] [int] NULL,
[DATEDOK] [datetime] NULL,
[DATESTART] [datetime] NULL,
[DATEEND] [datetime] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STARTROW] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDERSCR] [int] NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_FurnitorCmim_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_FurnitorCmim_DATEEDIT] DEFAULT (getdate()),
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FurnitorCmim] ADD CONSTRAINT [PK_FurnitorCm] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FurnitorCmim] ADD CONSTRAINT [FCmArt] UNIQUE NONCLUSTERED  ([KODFRF], [KOD]) ON [PRIMARY]
GO
