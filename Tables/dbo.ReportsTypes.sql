CREATE TABLE [dbo].[ReportsTypes]
(
[Id] [int] NOT NULL,
[Code] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsFilter] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportsTypes] ADD CONSTRAINT [PK_ReportsTypes] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
