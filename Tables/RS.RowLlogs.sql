CREATE TABLE [RS].[RowLlogs]
(
[ID] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[RowID] [int] NULL,
[Kod] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pershkrim] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POS] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [RS].[RowLlogs] ADD CONSTRAINT [PK_RS_LlogRows] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
ALTER TABLE [RS].[RowLlogs] ADD CONSTRAINT [FK_RS_LlogRows_RS_RapRows] FOREIGN KEY ([RowID]) REFERENCES [RS].[Rows] ([ID]) ON DELETE CASCADE
GO