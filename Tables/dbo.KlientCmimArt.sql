CREATE TABLE [dbo].[KlientCmimArt]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMSH] [float] NULL,
[CMSH1] [float] NULL,
[CMSH2] [float] NULL,
[CMSH3] [float] NULL,
[CMSH4] [float] NULL,
[CMSH5] [float] NULL,
[CMSH6] [float] NULL,
[CMSH7] [float] NULL,
[CMSH8] [float] NULL,
[CMSH9] [float] NULL,
[CMSH10] [float] NULL,
[CMSH11] [float] NULL,
[CMSH12] [float] NULL,
[CMSH13] [float] NULL,
[CMSH14] [float] NULL,
[CMSH15] [float] NULL,
[CMSH16] [float] NULL,
[CMSH17] [float] NULL,
[CMSH18] [float] NULL,
[CMSH19] [float] NULL,
[KLASIF] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIF2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIF3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIF4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATROW] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KlientCmimArt] ADD CONSTRAINT [PK_KlientCmimArt] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [I_Kod] ON [dbo].[KlientCmimArt] ([KOD]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_KlientCmimArt_NRD] ON [dbo].[KlientCmimArt] ([NRD]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KlientCmimArt] ADD CONSTRAINT [FJ_KlientCmimArt_KlientCmim] FOREIGN KEY ([NRD]) REFERENCES [dbo].[KlientCmim] ([NRRENDOR]) ON DELETE CASCADE ON UPDATE CASCADE
GO
