CREATE TABLE [dbo].[FRMINF]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[APPNAME] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODNAME] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FRMNAME] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRDNAME] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FRMTOP] [int] NULL,
[FRMLEFT] [int] NULL,
[FRMHEIGHT] [int] NULL,
[FRMWIDTH] [int] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
