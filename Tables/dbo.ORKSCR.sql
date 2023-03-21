CREATE TABLE [dbo].[ORKSCR]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODAF] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KARTLLG] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRRENDKLLG] [int] NULL,
[LLOGARIPK] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMSHZB0] [float] NULL,
[CMIMM] [float] NULL,
[SASI] [float] NULL,
[PERQDSCN] [float] NULL,
[CMIMBS] [float] NULL,
[VLERABS] [float] NULL,
[VLERAM] [float] NULL,
[VLPATVSH] [float] NULL,
[VLTVSH] [float] NULL,
[PERQTVSH] [float] NULL,
[KOEFSHB] [float] NULL,
[NJESINV] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPKLL] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BC] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOMENT] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NOTMAG] [bit] NULL,
[RIMBURSIM] [bit] NULL,
[DTSKADENCE] [datetime] NULL,
[SERI] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODKR] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[TIPFR] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SASIFR] [float] NULL,
[VLERAFR] [float] NULL,
[KODTVSH] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOEFICIENT] [float] NULL,
[VLTAX] [float] NULL,
[PERQKMS] [float] NULL,
[VLERAKMS] [float] NULL,
[LEVRUAR] [bit] NULL,
[PROMOC] [bit] NULL,
[PROMOCTIP] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROMOCKOD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PESHANET] [float] NULL,
[PESHABRT] [float] NULL,
[APLTVSH] [bit] NULL,
[APLINVESTIM] [bit] NULL,
[CMSHZB0MV] [float] NULL,
[CMSHREF] [float] NULL,
[NRSERIAL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMIMBSTVSH] [float] NULL,
[KONVERTART] [float] NULL,
[PROMPTPROD1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMRIMBURSIM] [float] NULL,
[VLRIMBURSIM] [float] NULL,
[GARANCI] [int] NULL,
[KOEFICENTARTAGJ] [float] NULL,
[KOEFICENTARTKL] [float] NULL,
[ISNOTFIRO] [bit] NULL,
[SASIKONV] [float] NULL,
[ISAMB] [bit] NULL,
[STATROW] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDERSCR] [int] NULL,
[TAGRND] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMIMKLASEREF] [float] NULL,
[VLKLASEREF] [float] NULL,
[CMIMREFERENCE] [float] NULL,
[CMSHREFAP] [float] NULL,
[CMSHREFAP2] [float] NULL,
[KODAGJENT] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODKLF] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMKOSTMES] [float] NULL,
[CMKOSTMESMV] [float] NULL,
[VLKOSTMES] [float] NULL,
[MARZH] [float] NULL,
[DTPRODHIM] [datetime] NULL,
[KODAQ] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODDETAJ] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [{6A6B1E0E-62FA-4B49-AAAB-7574B4703910}] ON [dbo].[ORKSCR] ([NRD]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [@NRD_ORKSCR] ON [dbo].[ORKSCR] ([NRD], [NRRENDOR]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ORKSCRNRRENDOR] ON [dbo].[ORKSCR] ([NRRENDOR]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ORKSCR] WITH NOCHECK ADD CONSTRAINT [FK_ORKSCR_ORK] FOREIGN KEY ([NRD]) REFERENCES [dbo].[ORK] ([NRRENDOR]) ON DELETE CASCADE ON UPDATE CASCADE
GO