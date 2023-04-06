CREATE TABLE [dbo].[Grumbullim]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRDOK] [int] NULL,
[NRGRUP] [int] NULL,
[DATEDOK] [datetime] NULL,
[KMAG] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM1] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM2] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM3] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM4] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_Grumbullim_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_Grumbullim_DATEEDIT] DEFAULT (getdate()),
[FIRSTDOK] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[STATUS] [int] NULL,
[StNipt] [bit] NULL,
[StNiptJo] [bit] NULL
) ON [PRIMARY]
GO
