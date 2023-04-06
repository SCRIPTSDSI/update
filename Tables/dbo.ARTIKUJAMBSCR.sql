CREATE TABLE [dbo].[ARTIKUJAMBSCR]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[KOD] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOEFICIENT] [float] NULL,
[PROMOC] [bit] NULL,
[PROMOCTIP] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QKOSTO] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDERSCR] [int] NULL,
[STATROW] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAG] [bit] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
