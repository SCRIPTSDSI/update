CREATE TABLE [dbo].[PROFITCENTER]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUP] [int] NULL,
[NIV] [int] NULL,
[POZIC] [bit] NULL,
[PARENT] [bit] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PROFITCENTER] ADD CONSTRAINT [PK_PROFITCENTER] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [KOD] ON [dbo].[PROFITCENTER] ([KOD]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [NRRENDOR] ON [dbo].[PROFITCENTER] ([NRRENDOR]) ON [PRIMARY]
GO
