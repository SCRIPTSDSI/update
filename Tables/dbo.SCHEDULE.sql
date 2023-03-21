CREATE TABLE [dbo].[SCHEDULE]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AKTIV] [bit] NULL,
[DATA] [datetime] NULL,
[TIPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPI_KOD] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPI_PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OPERATOR] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPDATED] [datetime] NULL
) ON [PRIMARY]
GO
