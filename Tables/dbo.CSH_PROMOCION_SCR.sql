CREATE TABLE [dbo].[CSH_PROMOCION_SCR]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[MASTER_ID] [int] NOT NULL,
[KOD] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMSH] [float] NULL,
[CMIMI] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CSH_PROMOCION_SCR] ADD CONSTRAINT [PK_CSH_PROMOCION_SCR] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CSH_PROMOCION_SCR] ADD CONSTRAINT [FK_CSH_PROMOCION_SCR_CSH_PROMOCION] FOREIGN KEY ([MASTER_ID]) REFERENCES [dbo].[CSH_PROMOCION] ([ID]) ON DELETE CASCADE
GO