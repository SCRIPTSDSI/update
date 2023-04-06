CREATE TABLE [dbo].[ArtikujPlanProdhim]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRDOK] [int] NULL,
[DATEDOK] [datetime] NULL,
[DATEREFER] [datetime] NULL,
[SHENIM1] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM2] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL,
[DATEEDIT] [datetime] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ArtikujPlanProdhim] ADD CONSTRAINT [PK_ArtikujPlanProdhim] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ArtikujPlanProdhim] ON [dbo].[ArtikujPlanProdhim] ([NRRENDOR]) ON [PRIMARY]
GO
