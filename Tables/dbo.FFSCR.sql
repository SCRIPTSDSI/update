CREATE TABLE [dbo].[FFSCR]
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
[KODKR] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[TIPFR] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SASIFR] [float] NULL,
[VLERAFR] [float] NULL,
[VLTAX] [float] NULL,
[KOEFICIENT] [float] NULL,
[KODTVSH] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[APLINVESTIM] [bit] NULL,
[PERQKMS] [float] NULL,
[VLERAKMS] [float] NULL,
[KONVERTART] [float] NULL,
[GJENDJE] [float] NULL,
[APLTVSH] [bit] NULL,
[PROMOC] [bit] NULL,
[PROMOCTIP] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROMOCKOD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PESHANET] [float] NULL,
[PESHABRT] [float] NULL,
[CMSHZB0MV] [float] NULL,
[CMSHREF] [float] NULL,
[NRSERIAL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMIMBSTVSH] [float] NULL,
[NRDITAR] [int] NULL,
[NRDOKREF] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATEDOKREF] [datetime] NULL,
[TIPREF] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[KODPRONESI] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIMPRONESI] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODLOCATION] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIMLOCATION] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTPRODHIM] [datetime] NULL,
[KODAQ] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODDETAJ] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Trigger [dbo].[UPDATEARTCM]
ON [dbo].[FFSCR]
After Insert
AS
      Update Artikuj
      Set KostPlan   = CmimBs,
          Cmb        = CASE WHEN SASI <> 0 THEN ROUND(VLERABS/SASI,0) ELSE CMB END,
          DateModCmb = Datedok
      From Artikuj Inner Join Inserted On Artikuj.Kod=Inserted.Kartllg
      Inner Join Ff On Inserted.Nrd = Ff.NrRendor







	 
GO
CREATE NONCLUSTERED INDEX [{879027CF-F6D7-40B1-B0B5-0C058E1E4390}] ON [dbo].[FFSCR] ([NRD]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [@NRD_FFSCR] ON [dbo].[FFSCR] ([NRRENDOR], [NRD]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FFSCR] WITH NOCHECK ADD CONSTRAINT [FK_FFSCR_FF] FOREIGN KEY ([NRD]) REFERENCES [dbo].[FF] ([NRRENDOR]) ON DELETE CASCADE ON UPDATE CASCADE
GO
