CREATE TABLE [dbo].[CSH_PROMOCION]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USERS_KOD] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS_KOD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATE_FILLIMI] [datetime] NULL,
[DATE_MBARIMI] [datetime] NULL,
[PRIORITET] [int] NULL,
[OPERATOR] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPDATED] [datetime] NULL,
[AKTIV] [bit] NULL,
[TIP_CMIMI] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIP_SHITJE] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD_SHITJE] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CSH_PROMOCION] ADD CONSTRAINT [PK_CSH_PROMOCIONE] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
