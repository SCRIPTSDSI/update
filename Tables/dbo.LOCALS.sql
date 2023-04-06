CREATE TABLE [dbo].[LOCALS]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[FLCL01] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FLCL02] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTMF01] [datetime] NULL,
[PRDF01] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCNF01] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_LOCALS_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_LOCALS_DATEEDIT] DEFAULT (getdate()),
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO