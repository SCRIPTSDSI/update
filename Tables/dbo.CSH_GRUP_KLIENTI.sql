CREATE TABLE [dbo].[CSH_GRUP_KLIENTI]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERFSHIN_TVSH] [bit] NULL,
[LEJO_SKONTO_RRESHT] [bit] NULL,
[LEJO_SKONTO_TOTAL] [bit] NULL,
[VAT_Business_Posting_Group] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CSH_GRUP_KLIENTI] ADD CONSTRAINT [PK_CSH_GRUP_KLIENTI] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ruan grupin e klientit dhe kufizimet qe i behen atij gjate shitjes', 'SCHEMA', N'dbo', 'TABLE', N'CSH_GRUP_KLIENTI', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Kodi i grupit p.sh. "GR01" ose "KL01"', 'SCHEMA', N'dbo', 'TABLE', N'CSH_GRUP_KLIENTI', 'COLUMN', N'KOD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A lejohet te bejme skonto per Artikull gjate shitjes, per kete Klient ?', 'SCHEMA', N'dbo', 'TABLE', N'CSH_GRUP_KLIENTI', 'COLUMN', N'LEJO_SKONTO_RRESHT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A lejohet te bejme skonto ne Totalin e Fatures per kete Klient ?', 'SCHEMA', N'dbo', 'TABLE', N'CSH_GRUP_KLIENTI', 'COLUMN', N'LEJO_SKONTO_TOTAL'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cmimi i Shitjes - a e perfshin TVSH-ne fature', 'SCHEMA', N'dbo', 'TABLE', N'CSH_GRUP_KLIENTI', 'COLUMN', N'PERFSHIN_TVSH'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Pershkrimi i grupi p.sh. "Klient me perfshirje TVSH" ose "Klient me Skonto ne TOTAL"', 'SCHEMA', N'dbo', 'TABLE', N'CSH_GRUP_KLIENTI', 'COLUMN', N'PERSHKRIM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Use codes that are easy to remember and that describe the business group', 'SCHEMA', N'dbo', 'TABLE', N'CSH_GRUP_KLIENTI', 'COLUMN', N'VAT_Business_Posting_Group'
GO
