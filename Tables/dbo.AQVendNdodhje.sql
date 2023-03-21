CREATE TABLE [dbo].[AQVendNdodhje]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADRESA1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADRESA2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADRESA3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NIPT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RRETHI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TELEFON1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TELEFON2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBJEKT] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GRUP] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KATEGORI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RAJON] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NOTACTIV] [bit] NULL CONSTRAINT [DF_AQVendNdodhje_NOTACTIV] DEFAULT ((0)),
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_AQVendNdodhje_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_AQVendNdodhje_DATEEDIT] DEFAULT (getdate()),
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
