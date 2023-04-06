CREATE TABLE [dbo].[CSH_LISTA]
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
[BC] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRIORITET] [smallint] NULL,
[IMPORTUAR] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CSH_LISTA] ADD CONSTRAINT [PK_CSH_LISTA] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Permban listen me Cmimet e shitjes sipas nje konfigurimi te caktuar', 'SCHEMA', N'dbo', 'TABLE', N'CSH_LISTA', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cmimi shitjes', 'SCHEMA', N'dbo', 'TABLE', N'CSH_LISTA', 'COLUMN', N'CMIMI'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Kur do filloje te perdoret Cmimi i Shitjes', 'SCHEMA', N'dbo', 'TABLE', N'CSH_LISTA', 'COLUMN', N'DATE_FILLIMI'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Kur do mbaroje perdorimi i Cmimit te Shitjes', 'SCHEMA', N'dbo', 'TABLE', N'CSH_LISTA', 'COLUMN', N'DATE_MBARIMI'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Permban kodin e monedhes', 'SCHEMA', N'dbo', 'TABLE', N'CSH_LISTA', 'COLUMN', N'KMON'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Permban vetem kodin e Artikullit', 'SCHEMA', N'dbo', 'TABLE', N'CSH_LISTA', 'COLUMN', N'KOD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Ne varesi te [TIP_SHITJE] ka vlera te ndryshme ose nuk ka fare vlere.
p.sh. Nese [TIP_SHITJE = ''AK = Te gjithe klientet''] atehere nuk ka kuptim te kemi [kod klienti]', 'SCHEMA', N'dbo', 'TABLE', N'CSH_LISTA', 'COLUMN', N'KOD_SHITJE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A lejohet te bejme skonto per Artikull gjate shitjes, per kete Klient ?', 'SCHEMA', N'dbo', 'TABLE', N'CSH_LISTA', 'COLUMN', N'LEJO_SKONTO_RRESHT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A lejohet te bejme skonto ne Totalin e Fatures per kete Klient ?', 'SCHEMA', N'dbo', 'TABLE', N'CSH_LISTA', 'COLUMN', N'LEJO_SKONTO_TOTAL'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Diferenca ndermjet Cmimit_Kosto dhe Cmimit te Shitjes ne % ose ne Vlere ????', 'SCHEMA', N'dbo', 'TABLE', N'CSH_LISTA', 'COLUMN', N'MARZHI'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Permban Kodin e Njesise se artikullit', 'SCHEMA', N'dbo', 'TABLE', N'CSH_LISTA', 'COLUMN', N'NJESI'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cmimi i Shitjes - a e perfshin TVSH-ne fature', 'SCHEMA', N'dbo', 'TABLE', N'CSH_LISTA', 'COLUMN', N'PERFSHIN_TVSH'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Sa eshte minimumi i blererjes qe ne te aplikojme kete cmim ?', 'SCHEMA', N'dbo', 'TABLE', N'CSH_LISTA', 'COLUMN', N'SASIA_MINIMALE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Nuk e kuptoj (ne navision thote se mund te perdoret vetem per filtrim)', 'SCHEMA', N'dbo', 'TABLE', N'CSH_LISTA', 'COLUMN', N'TIP_CMIMI'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Permban tipin e shitjes p.sh.
----------------------------------
AK,	Te gjithe Klientet
GK,	Grup Klientesh
KL,	Klient
PR,	Promocion', 'SCHEMA', N'dbo', 'TABLE', N'CSH_LISTA', 'COLUMN', N'TIP_SHITJE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Use codes that are easy to remember and that describe the business group', 'SCHEMA', N'dbo', 'TABLE', N'CSH_LISTA', 'COLUMN', N'VAT_Business_Posting_Group'
GO
