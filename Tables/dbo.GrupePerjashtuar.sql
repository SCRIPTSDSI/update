CREATE TABLE [dbo].[GrupePerjashtuar]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[KOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GrupePerjashtuar] ADD CONSTRAINT [PK_GrupePerjashtuar] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
