CREATE TABLE [dbo].[TEST]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[KOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TEST] ADD CONSTRAINT [PK_TEST] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO