CREATE TABLE [dbo].[DRHUSERKUFI]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[KODUS] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODUL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPDOK] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KUFIP] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KUFIS] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[REFERENCE] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
