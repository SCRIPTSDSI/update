CREATE TABLE [dbo].[ReportsGroup]
(
[Id] [int] NOT NULL,
[Code] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[No] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Modul] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NotActive] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportsGroup] ADD CONSTRAINT [PK_ReportsGroup] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
