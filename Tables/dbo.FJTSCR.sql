CREATE TABLE [dbo].[FJTSCR]
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
[PROMOC] [bit] NULL,
[PROMOCTIP] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[VLTAX] [float] NULL,
[PERQKMS] [float] NULL,
[VLERAKMS] [float] NULL,
[KODTVSH] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[APLTVSH] [bit] NULL,
[APLINVESTIM] [bit] NULL,
[PROMOCKOD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PESHANET] [float] NULL,
[PESHABRT] [float] NULL,
[CMSHZB0MV] [float] NULL,
[CMSHREF] [float] NULL,
[NRSERIAL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FBARS] [float] NULL,
[FCOLOR] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FLENGTH] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FPROFIL] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLSART] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOEFICIENT] [float] NULL,
[KONVERTART] [float] NULL,
[DATEDOKREF] [datetime] NULL,
[NRDOKREF] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPREF] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPKTH] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GJENDJE] [float] NULL,
[NRDITAR] [int] NULL,
[CMIMBSTVSH] [float] NULL,
[PROMPTPROD1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMRIMBURSIM] [float] NULL,
[VLRIMBURSIM] [float] NULL,
[GARANCI] [int] NULL,
[KOEFICENTARTAGJ] [float] NULL,
[KOEFICENTARTKL] [float] NULL,
[ISNOTFIRO] [bit] NULL,
[SASIKONV] [float] NULL,
[ISAMB] [bit] NULL,
[IFIZIK] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE NONCLUSTERED INDEX [{39345D6A-B45E-98B2-9891CDE8300E}] ON [dbo].[FJTSCR] ([NRD]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FJTSCRNRRENDOR] ON [dbo].[FJTSCR] ([NRRENDOR]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [@NRD_FJTSCR] ON [dbo].[FJTSCR] ([NRRENDOR], [NRD]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FJTSCR] WITH NOCHECK ADD CONSTRAINT [FK_FJTSCR_FJT] FOREIGN KEY ([NRD]) REFERENCES [dbo].[FJT] ([NRRENDOR]) ON DELETE CASCADE ON UPDATE CASCADE
GO
