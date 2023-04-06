CREATE TABLE [dbo].[ReferenceLinked]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[REFERENCE1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REFERENCE2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD1] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD2] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACTIV] [bit] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [bit] NULL
) ON [PRIMARY]
GO
