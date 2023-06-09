CREATE TABLE [dbo].[SMTEMPSCR]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[NRD] [int] NULL,
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODAF] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KARTLLG] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRRENDKLLG] [int] NULL,
[LLOGARIPK] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[NJESINV] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPKLL] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BC] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIF] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIF2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOMENT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NOTMAG] [bit] NULL,
[RIMBURSIM] [bit] NULL,
[DTSKADENCE] [datetime] NULL,
[SERI] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODKR] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[VLTAX] [float] NULL,
[LASTMODIF] [datetime] NOT NULL CONSTRAINT [DF_SMTEMPSCR_LASTMODIF] DEFAULT (getdate()),
[SERIALI] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SMTEMPSCR_SERIALI] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SMTEMPSCR] ADD CONSTRAINT [PK_SMTEMPSCR] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SMTEMPSCR] WITH NOCHECK ADD CONSTRAINT [FK_SMTEMPSCR_SMTEMP] FOREIGN KEY ([NRD]) REFERENCES [dbo].[SMTEMP] ([NRRENDOR]) ON DELETE CASCADE ON UPDATE CASCADE
GO
