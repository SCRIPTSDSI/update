CREATE TABLE [dbo].[TBLSF]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[TABLENAME] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRD] [int] NULL,
[NRORDER] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FIELDNAME] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIP] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPNAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROMPT] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WIDTH] [int] NULL,
[INGRID] [bit] NULL,
[VISIBLE] [bit] NULL,
[KODLIST] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLISTE] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'AAAAAAAAAAAAAA', 'SCHEMA', N'dbo', 'TABLE', N'TBLSF', 'COLUMN', N'INGRID'
GO
