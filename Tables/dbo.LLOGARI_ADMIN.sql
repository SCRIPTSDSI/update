CREATE TABLE [dbo].[LLOGARI_ADMIN]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUP] [int] NULL,
[NIV] [int] NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASA] [int] NULL,
[POZIC] [bit] NULL,
[TIPI] [int] NULL,
[AKTPASIV] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAG] [bit] NULL,
[ORIGJINA] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VEPRIMLM] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[KLASIFIKIM] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NOTRV] [bit] NULL,
[KODSUP] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
