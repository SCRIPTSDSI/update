CREATE TABLE [dbo].[Reports]
(
[Id] [int] NOT NULL,
[Code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[No] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Modul] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportGroup] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportQuery] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NotActive] [bit] NULL,
[Report] [varbinary] (max) NULL,
[IsCmdSp] [bit] NULL,
[NOrder] [int] NULL,
[SelectLines] [bit] NULL,
[DateStamp] [datetime] NULL,
[FormNodeId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Reports] ADD CONSTRAINT [PK_Reports] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
