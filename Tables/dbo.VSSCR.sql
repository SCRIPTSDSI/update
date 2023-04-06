CREATE TABLE [dbo].[VSSCR]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[KODAF] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOMENT] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARI] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARIPK] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPREF] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATEDOKREF] [datetime] NULL,
[NRDOKREF] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KMON] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KURS1] [float] NULL,
[KURS2] [float] NULL,
[DB] [float] NULL,
[KR] [float] NULL,
[DBKRMV] [float] NULL,
[TREGDK] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAG] [bit] NULL,
[TIPKLL] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRDITAR] [int] NULL,
[OPERLLOJ] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OPERNR] [int] NULL,
[OPERDT] [datetime] NULL,
[OPERAPL] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OPERORD] [int] NULL,
[OPERNRFAT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[FADESTIN] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FAART] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODAGJ] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDERSCR] [int] NULL,
[STATROW] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAGRND] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODAGJENT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTAF] [int] NULL,
[KODDETAJ] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [{823A2CF0-989B-497F-B1FD-5D9710DF0A9A}] ON [dbo].[VSSCR] ([NRD]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [@NRD_VSSCR] ON [dbo].[VSSCR] ([NRRENDOR], [NRD]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VSSCR] WITH NOCHECK ADD CONSTRAINT [FK_VSSCR_VS] FOREIGN KEY ([NRD]) REFERENCES [dbo].[VS] ([NRRENDOR]) ON DELETE CASCADE ON UPDATE CASCADE
GO