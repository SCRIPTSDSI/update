CREATE TABLE [dbo].[SMPGSCR]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODAF] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KARTLLG] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARIPK] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOMENT] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VLERA] [float] NULL,
[KMON] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VLERAMV] [float] NULL,
[KURS1] [float] NULL,
[KURS2] [float] NULL,
[STATROW] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDERSCR] [int] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SMPGSCR] WITH NOCHECK ADD CONSTRAINT [FK_SMPGSCR_SMPG] FOREIGN KEY ([NRD]) REFERENCES [dbo].[SM] ([NRRENDOR]) ON DELETE CASCADE ON UPDATE CASCADE
GO
