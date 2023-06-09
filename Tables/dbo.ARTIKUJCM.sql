CREATE TABLE [dbo].[ARTIKUJCM]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIF] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOSTMES] [float] NULL,
[KOSTPLAN] [float] NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NEGST] [bit] NULL,
[POZIC] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIP] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESB] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOEFB] [float] NULL,
[CMB] [float] NULL,
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
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAG] [bit] NULL,
[TROW] [bit] NULL,
[BC] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIF2] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIF3] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAGNR] [int] NULL,
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
[CMSHPLM1] [float] NULL,
[CMSHPLM2] [float] NULL,
[PERSHKRIMSH] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MINI] [float] NULL,
[MAKS] [float] NULL,
[NJESSH] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOEFSH] [float] NULL,
[DSCNTKLA] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSCNTKLB] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSCNTKLC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSCNTKLD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSCNTKLE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSCNTKLF] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSCNTKLG] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSCNTKLH] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSCNTKLI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSCNTKLJ] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TATIM] [bit] NULL,
[PESHA] [float] NULL,
[VOLUM] [float] NULL,
[KONV1] [float] NULL,
[KONV2] [float] NULL,
[KONVNJESI] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KONVKOLITR] [float] NULL,
[VLTAX] [float] NULL,
[KODORG] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOEFICPERB] [float] NULL,
[AUTOSHKLPFJ] [bit] NULL,
[AUTOSHKLPFDBR] [bit] NULL,
[RIMBURSIM] [bit] NULL,
[KODLM] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEP] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LISTE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORG] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FURNKOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FURNARTKOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FURNARTPERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOEFICIENT] [float] NULL,
[NOTACTIV] [bit] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [@KOD_ARTCM] ON [dbo].[ARTIKUJCM] ([KOD]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [@NRRENDOR_ARTCM] ON [dbo].[ARTIKUJCM] ([NRRENDOR]) ON [PRIMARY]
GO
