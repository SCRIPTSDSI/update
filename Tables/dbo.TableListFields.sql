CREATE TABLE [dbo].[TableListFields]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[TABLENAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODUL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LISTFIELDSDOCEXC] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LISTFIELDSROWEXC] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_ListFieldsTable_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_ListFieldsTable_DATEEDIT] DEFAULT (getdate()),
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
