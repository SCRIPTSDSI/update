CREATE TABLE [dbo].[SG_IMPLICIT]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[TIP] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SG1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SG2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SG3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SG4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SG5] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AKTIVIMPL] [bit] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[SG6] [bit] NULL,
[SG7] [bit] NULL,
[SG8] [bit] NULL,
[SG9] [bit] NULL,
[SG10] [bit] NULL
) ON [PRIMARY]
GO
