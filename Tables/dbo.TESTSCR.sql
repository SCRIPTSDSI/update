CREATE TABLE [dbo].[TESTSCR]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[NRD] [int] NULL,
[KOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TESTSCR] ADD CONSTRAINT [PK_TESTSCR] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
