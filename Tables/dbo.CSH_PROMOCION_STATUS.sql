CREATE TABLE [dbo].[CSH_PROMOCION_STATUS]
(
[KOD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CSH_PROMOCION_STATUS] ADD CONSTRAINT [PK_CSH_PROMOCION_STATUS] PRIMARY KEY CLUSTERED  ([KOD]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Permban listen me statuse per promocionin .', 'SCHEMA', N'dbo', 'TABLE', N'CSH_PROMOCION_STATUS', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Kodi i statusit', 'SCHEMA', N'dbo', 'TABLE', N'CSH_PROMOCION_STATUS', 'COLUMN', N'KOD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pershkrimi p.sh.
HAPUR ose MBYLLUR', 'SCHEMA', N'dbo', 'TABLE', N'CSH_PROMOCION_STATUS', 'COLUMN', N'PERSHKRIM'
GO
