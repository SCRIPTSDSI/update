CREATE TABLE [dbo].[SKEMELM]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKEMELM_KOD] DEFAULT (''),
[PERSHKRIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKEMELM_PERSHKRIM] DEFAULT (''),
[LLOGINV] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKEMELM_LLOGINV] DEFAULT (''),
[NDRGJEND] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKEMELM_NDRGJEND] DEFAULT (''),
[LLOGB] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKEMELM_LLOGB] DEFAULT (''),
[LLOGSH] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKEMELM_LLOGSH] DEFAULT (''),
[KLASIFIKIM] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKEMELM_KLASIFIKIM] DEFAULT (''),
[TAG] [bit] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL CONSTRAINT [DF_SKEMELM_TAGNR] DEFAULT ((0)),
[LLOGSHPZ01] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SKEMELM_LLOGSHPZ01] DEFAULT (''),
[NOTACTIV] [bit] NULL CONSTRAINT [DF_SKEMELM_NOTACTIV] DEFAULT ((0)),
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_SLM_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_SLM_DATEEDIT] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [@KOD_SKLM] ON [dbo].[SKEMELM] ([KOD]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [NRRENDOR_SKLM] ON [dbo].[SKEMELM] ([NRRENDOR]) ON [PRIMARY]
GO
