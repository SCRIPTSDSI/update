CREATE TABLE [dbo].[ArtikujPlanProdhimScr]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SASI] [float] NULL,
[TIPKLL] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDERSCR] [int] NULL,
[STATROW] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[SASICALCUL] [float] NULL,
[SASIMG] [float] NULL,
[SASIPROCES] [float] NULL,
[SASISHITUR] [float] NULL,
[SASISTOKDITOR] [float] NULL,
[KODLP] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NR] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ArtikujPlanProdhimScr] ON [dbo].[ArtikujPlanProdhimScr] ([NRD], [KOD]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ArtikujPlanProdhimScr] ADD CONSTRAINT [FK_ArtikujPlPrScr_ArtikujPlPr] FOREIGN KEY ([NRD]) REFERENCES [dbo].[ArtikujPlanProdhim] ([NRRENDOR])
GO
