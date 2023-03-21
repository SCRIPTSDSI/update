CREATE TABLE [dbo].[DECIMALS]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[TABLENAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SASI] [int] NULL,
[CMIM] [int] NULL,
[VLEFTE] [int] NULL,
[CMIMVL] [int] NULL,
[VLEFTEVL] [int] NULL,
[MODUL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIP] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRORDER] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
