CREATE TABLE [dbo].[TEMP]
(
[KOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TEMP] ADD CONSTRAINT [PK__TEMP__2E8B20C78C2E3B08] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO