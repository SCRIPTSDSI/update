CREATE TABLE [dbo].[X_NEWSTR]
(
[NRRENDOR] [int] NOT NULL,
[DATABASE] [int] NULL,
[FILE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRORDER] [int] NULL,
[FIELD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIP] [int] NULL,
[SIZE] [int] NULL,
[OPERACION] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQL] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAGNR] [int] NULL,
[TROW] [bit] NULL
) ON [PRIMARY]
GO
