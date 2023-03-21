CREATE TABLE [RS].[Rap]
(
[ID] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[Pershkrim] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RapFile] [varbinary] (max) NULL,
[SqlSource] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SqlSource1] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SqlSource2] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SqlDest] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SqlDest1] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SqlDest2] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilterStartWith] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCol] [bit] NULL,
[Description] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GrLlogFrom] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GrLlogTo] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShowCtrlLlog] [bit] NULL,
[ShowTotal] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RS].[Rap] ADD CONSTRAINT [PK_RS_RAP] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
