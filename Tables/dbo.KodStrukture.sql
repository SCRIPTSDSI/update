CREATE TABLE [dbo].[KodStrukture]
(
[NrRendor] [int] NOT NULL IDENTITY(1, 1),
[TableRef] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KodModel] [int] NULL,
[KodLength] [int] NULL,
[KodFormat] [int] NULL,
[KodPrefixModel] [int] NULL,
[KodPrefixKonstant] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KodPrefixDinModel] [int] NULL,
[KodPrefixDinLength] [int] NULL,
[Perdorues] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateCreate] [datetime] NULL CONSTRAINT [DF_KodStrukture_DateCreate] DEFAULT (getdate()),
[DateEdit] [datetime] NULL CONSTRAINT [DF_KodStrukture_DateEdit] DEFAULT (getdate()),
[Trow] [bit] NULL,
[TagNr] [int] NULL
) ON [PRIMARY]
GO
