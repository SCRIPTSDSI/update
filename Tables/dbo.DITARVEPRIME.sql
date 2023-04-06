CREATE TABLE [dbo].[DITARVEPRIME]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRRENDORDOK] [int] NOT NULL,
[TIP] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MASTER] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRDOK] [int] NULL,
[NRFRAKS] [int] NULL,
[DATEDOK] [datetime] NULL,
[VLERE] [float] NULL,
[OPERACION] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODUSER] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATEMOD] [datetime] NULL,
[DATETIMEMOD] [datetime] NULL,
[ORA] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OPERACIONDOK] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCNAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCIP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LGJOB] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOMENT] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_DITVEP_DATECREATE] DEFAULT (getdate()),
[TAGNR] [int] NULL,
[TROW] [bit] NULL
) ON [PRIMARY]
GO
