CREATE TABLE [dbo].[CSH_TIP_SHITJE]
(
[KOD] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CSH_TIP_SHITJE] ADD CONSTRAINT [PK_CH_TIPI_SHITJES] PRIMARY KEY CLUSTERED  ([KOD]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Permban listen me Tipet e shitjes. 
KUJDES : Nuk duhet te ndryshojne KOD-et', 'SCHEMA', N'dbo', 'TABLE', N'CSH_TIP_SHITJE', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'Jane STATIK (nuk duhet te ndryshojne sepse si te tille perdoren brenda kodit) :
--------------------------------------------------------------------------------------------
AK,	Te gjithe Klientet
GK,	Grup Klientesh
KL,	Klient
PR,	Promocion
', 'SCHEMA', N'dbo', 'TABLE', N'CSH_TIP_SHITJE', 'COLUMN', N'KOD'
GO
