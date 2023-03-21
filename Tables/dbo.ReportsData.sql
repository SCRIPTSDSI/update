CREATE TABLE [dbo].[ReportsData]
(
[Id] [int] NOT NULL,
[ReportId] [int] NULL,
[Code] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Query] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCmdSp] [bit] NULL,
[Connection] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NotActive] [bit] NULL,
[User] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastEditDate] [datetime] NULL,
[CreationDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportsData] ADD CONSTRAINT [PK_ReportsData] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
