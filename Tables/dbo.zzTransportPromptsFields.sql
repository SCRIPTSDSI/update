CREATE TABLE [dbo].[zzTransportPromptsFields]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FLDPROMPT] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FLDNAME] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPCONTROL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LISTPROMPT] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ENABLED] [bit] NULL,
[VISIBLE] [bit] NULL,
[READONLY] [bit] NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_xxRoutesPromptsFields_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_xxRoutesPromptsFields_DATEEDIT] DEFAULT (getdate()),
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
