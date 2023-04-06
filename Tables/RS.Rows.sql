CREATE TABLE [RS].[Rows]
(
[ID] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[RapID] [int] NULL,
[Pershkrim] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RefID] [int] NULL,
[RowIndex] [int] NULL,
[IsValueLeft] [bit] NULL,
[IsValueRight] [bit] NULL,
[ValueLeft] [float] NULL,
[ValueRight] [float] NULL,
[IsTotal] [bit] NULL,
[IsBold] [bit] NULL,
[IsNote] [bit] NULL,
[IsShowValue] [bit] NULL,
[HasLlog] [bit] NULL,
[IsAnalize] [bit] NULL,
[IsFirstChild] [bit] NULL,
[IsLastChild] [bit] NULL,
[IsSummRow] [bit] NULL,
[GRUP] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsFormule] [bit] NULL,
[Formula] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsBeforeDate] [bit] NULL,
[IsEndDate] [bit] NULL,
[IsCustomDate] [bit] NULL,
[Sign] [smallint] NOT NULL CONSTRAINT [DF_Rows_Sign] DEFAULT ((1)),
[D] [smallint] NULL,
[M] [smallint] NULL,
[Y] [smallint] NULL,
[NrPrevYear] [smallint] NULL,
[DBNAME] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [RS].[Rows] ADD CONSTRAINT [PK_RS_RapRows] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
ALTER TABLE [RS].[Rows] ADD CONSTRAINT [FK_RS_RapRows_RS_RAP] FOREIGN KEY ([RapID]) REFERENCES [RS].[Rap] ([ID]) ON DELETE CASCADE
GO
