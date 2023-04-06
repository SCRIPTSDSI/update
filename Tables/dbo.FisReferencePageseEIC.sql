CREATE TABLE [dbo].[FisReferencePageseEIC]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODEIC] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM1] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM2] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM3] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM4] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VISIBLE] [bit] NULL,
[NOTACTIV] [bit] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_FisReferencePageseEIC_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_FisReferencePageseEIC_DATEEDIT] DEFAULT (getdate()),
[TROW] [bit] NULL,
[TAGNR] [bit] NULL
) ON [PRIMARY]
GO
