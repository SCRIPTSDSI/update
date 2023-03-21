CREATE TABLE [dbo].[OrdListArtScr]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[NRD] [int] NULL,
[NRORDER] [int] NULL,
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BC] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOEFKONV1] [float] NULL,
[KOEFKONV2] [float] NULL,
[KOEFKONV3] [float] NULL,
[KOEFKONV4] [float] NULL,
[GRUPIM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDERSCR] [int] NULL,
[STATROW] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OrdListArtScr] ADD CONSTRAINT [PK__OrdListA__2E8B20C737F4EEA0] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OrdListArt] ON [dbo].[OrdListArtScr] ([NRD], [NRRENDOR]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OrdListArtScr] ADD CONSTRAINT [FK_OrdListArtScr_OrdListArt] FOREIGN KEY ([NRD]) REFERENCES [dbo].[OrdListArt] ([NRRENDOR]) ON DELETE CASCADE ON UPDATE CASCADE
GO