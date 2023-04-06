CREATE TABLE [dbo].[KLIENTKART]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODFIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATEBEG] [datetime] NULL,
[DATEEND] [datetime] NULL,
[ADRESA1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADRESA2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADRESA3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERQINDJE] [float] NULL,
[TELEFON1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TELEFON2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FAX] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODPOSTAR] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARIBANKE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMAIL] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BLOKIM] [bit] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
