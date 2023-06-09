CREATE TABLE [dbo].[DEPARTAMENT]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUP] [int] NULL,
[NIV] [int] NULL,
[POZIC] [bit] NULL,
[PARENT] [bit] NULL,
[TROW] [bit] NULL,
[ORIGJINA] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAGNR] [int] NULL,
[KLASIFIKIM1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_DEP_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_DEP_DATEEDIT] DEFAULT (getdate()),
[NOTACTIV] [bit] NULL CONSTRAINT [DF_DEPARTAMENT_NOTACTIV] DEFAULT ((0)),
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DEPARTAMENT] ADD CONSTRAINT [PK_DEPARTAMENT] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [KOD] ON [dbo].[DEPARTAMENT] ([KOD]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [NRRENDOR] ON [dbo].[DEPARTAMENT] ([NRRENDOR]) ON [PRIMARY]
GO
