CREATE TABLE [dbo].[TMP_FDSCR]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[NRD] [int] NULL,
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODAF] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KARTLLG] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRRENDKLLG] [int] NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SASI] [float] NULL,
[CMIMM] [float] NULL,
[VLERAM] [float] NULL,
[KMON] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VLERAFT] [float] NULL,
[CMIMBS] [float] NULL,
[VLERABS] [float] NULL,
[KOEFSHB] [float] NULL,
[NJESINV] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPKLL] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BC] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOMENT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROMOC] [bit] NULL,
[PROMOCTIP] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RIMBURSIM] [bit] NULL,
[DTSKADENCE] [datetime] NULL,
[SERI] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GJENROWAUT] [bit] NULL,
[CMIMOR] [float] NULL,
[VLERAOR] [float] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[TIPKTH] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPFR] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SASIFR] [float] NULL,
[VLERAFR] [float] NULL,
[FBARS] [float] NULL,
[FCOLOR] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FLENGTH] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FPROFIL] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMP_FDSCR] ADD CONSTRAINT [PK__TMP_FDSC__2E8B20C70BB8DBB4] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
