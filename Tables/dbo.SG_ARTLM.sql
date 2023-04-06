CREATE TABLE [dbo].[SG_ARTLM]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[TIP] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SG1] [bit] NULL,
[SG2] [bit] NULL,
[SG3] [bit] NULL,
[SG4] [bit] NULL,
[SG5] [bit] NULL,
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
