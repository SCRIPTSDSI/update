CREATE TABLE [dbo].[DRHUSERFRM]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[KODUS] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FORMNAME] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FIELDS] [varchar] (3000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPDOK] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FORMREF] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACTIV] [bit] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
