CREATE TABLE [dbo].[ARTIKUJ_BC_PRINT]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BC] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SASIAPRINT] [int] NULL,
[GARANCI] [int] NULL,
[VMD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATE] [datetime] NULL,
[SHENIME] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NGJYRE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MASE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAG] [bit] NULL
) ON [PRIMARY]
GO
