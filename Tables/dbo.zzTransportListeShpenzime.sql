CREATE TABLE [dbo].[zzTransportListeShpenzime]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[GRUPI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODFORME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LISTELLOGARI] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FIELDTOTAL] [bit] NULL,
[GJENDJE] [decimal] (18, 2) NULL,
[FIELDNAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODTMP] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
