CREATE TABLE [dbo].[CSH_TIP_CMIMI]
(
[KOD] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CSH_TIP_CMIMI] ADD CONSTRAINT [PK_TIP_CMIMI] PRIMARY KEY CLUSTERED  ([KOD]) ON [PRIMARY]
GO
