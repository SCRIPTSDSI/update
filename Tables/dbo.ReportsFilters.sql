CREATE TABLE [dbo].[ReportsFilters]
(
[Id] [int] NOT NULL,
[ReportId] [int] NOT NULL,
[Label] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InputName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InputName2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InputType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultValue] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultValue2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComparisonField] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComparisonField2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Operation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Operation2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DatasetQuery] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NGroup] [int] NULL,
[NOrder] [int] NULL,
[DoubleType] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportsFilters] ADD CONSTRAINT [PK_ReportsFilters] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
