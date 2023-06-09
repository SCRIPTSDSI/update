CREATE TABLE [RS].[CellLlogs]
(
[ID] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[CellID] [int] NULL,
[Kod] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pershkrim] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [RS].[CellLlogs] ADD CONSTRAINT [PK__CellLlog__3214EC27118E833F] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
ALTER TABLE [RS].[CellLlogs] ADD CONSTRAINT [FK_CellLlogs_Cells] FOREIGN KEY ([CellID]) REFERENCES [RS].[Cells] ([ID]) ON DELETE CASCADE
GO
