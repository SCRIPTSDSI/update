CREATE TABLE [dbo].[ARTIKUJKLSF]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MARKA] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRODHUES] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FURNITOR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUP] [int] NULL,
[NIV] [int] NULL,
[POZIC] [bit] NULL,
[PARENT] [bit] NULL,
[ORIGJINA] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
