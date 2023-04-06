CREATE TABLE [dbo].[CSH_LISTA_LOGS]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[TIP_SHITJE] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD_SHITJE] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KMON] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SASIA_MINIMALE] [float] NULL,
[TIP_CMIMI] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMIMI] [float] NULL,
[MARZHI] [float] NULL,
[DATE_FILLIMI] [datetime] NULL,
[DATE_MBARIMI] [datetime] NULL,
[PERFSHIN_TVSH] [bit] NULL,
[LEJO_SKONTO_RRESHT] [bit] NULL,
[LEJO_SKONTO_TOTAL] [bit] NULL,
[VAT_Business_Posting_Group] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HOST] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HOST_IP] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OPERATOR] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATA] [datetime] NULL,
[TIP_VEPRIMI] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
