CREATE TABLE [dbo].[ARTIKUJFIR]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOEFICENTA] [float] NULL,
[KOEFICENTB] [float] NULL,
[KOEFICENTC] [float] NULL,
[KOEFICENTD] [float] NULL,
[LLOGARIA] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARIB] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARIC] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAG] [bit] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[KOEFICENTE] [float] NULL,
[KOEFICENTF] [float] NULL,
[KOEFICENTG] [float] NULL,
[KOEFICENTH] [float] NULL,
[KOEFICENTI] [float] NULL,
[KOEFICENTJ] [float] NULL,
[LLOGARIE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARIF] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARIG] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARIH] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARII] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARIJ] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATROW] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [LLOGARID] ON [dbo].[ARTIKUJFIR] ([LLOGARID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [@NRD_FIR] ON [dbo].[ARTIKUJFIR] ([NRD]) ON [PRIMARY]
GO