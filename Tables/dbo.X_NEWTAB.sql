CREATE TABLE [dbo].[X_NEWTAB]
(
[NRRENDOR] [int] NOT NULL,
[DATABASE] [int] NULL,
[MODUL] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FILE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FILEOR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DBOR] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FIELDS] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRORDER] [int] NULL,
[OPERACION] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLCRE] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLUPD] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLINDEX] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAGNR] [int] NULL,
[ISCFG] [bit] NULL,
[TROW] [bit] NULL
) ON [PRIMARY]
GO
