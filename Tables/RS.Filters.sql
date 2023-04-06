CREATE TABLE [RS].[Filters]
(
[ID] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[Pershkrim] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RapID] [int] NULL,
[ObjectType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilterQuery] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ListFields] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyField] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VisibleNga] [bit] NULL,
[VisibleDeri] [bit] NULL,
[ObliguarNga] [bit] NULL,
[ObliguarDeri] [bit] NULL,
[OperatorNga] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OperatorDeri] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Operator] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EqualChar] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VariableNga] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VariableDeri] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FieldNga] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FieldDeri] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Having] [bit] NULL,
[Variabel] [bit] NULL,
[ValueNga] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ValueDeri] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RS].[Filters] ADD CONSTRAINT [PK_RS_Filters] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
ALTER TABLE [RS].[Filters] ADD CONSTRAINT [FK_RS_Filters_RS_RAP] FOREIGN KEY ([RapID]) REFERENCES [RS].[Rap] ([ID]) ON DELETE CASCADE
GO
