CREATE TABLE [dbo].[NJESISASI]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[KODNJESI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SASIMAX] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NJESISASI] ADD CONSTRAINT [PK_NJESISASI] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
