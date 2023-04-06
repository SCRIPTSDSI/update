CREATE TABLE [dbo].[TIPDOKFJ]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[TIPDOK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODEIC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIMANG] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRORD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODNUM] [int] NULL,
[KODTD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[SHENIM1] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM1] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VISIBLE] [bit] NULL
) ON [PRIMARY]
GO
