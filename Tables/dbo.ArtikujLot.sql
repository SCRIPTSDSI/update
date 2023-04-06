CREATE TABLE [dbo].[ArtikujLot]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTSKADENCE] [datetime] NULL,
[GRUP] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODLP] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NR] [int] NULL,
[NOTACTIV] [bit] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_ItemsLot_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_ItemsLot_DATEEDIT] DEFAULT (getdate()),
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
