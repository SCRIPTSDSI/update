CREATE TABLE [dbo].[RP_LISTE]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[KOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PART] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQL] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TEXT1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TEXT2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TEXT3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KUFIP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KUFIS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLS1] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLS2] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLS3] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLS4] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLS5] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLS6] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLS7] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLS8] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MOD] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAGNR] [int] NULL,
[TROW] [bit] NULL
) ON [PRIMARY]
GO
