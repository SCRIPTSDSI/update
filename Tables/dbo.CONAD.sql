CREATE TABLE [dbo].[CONAD]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[RNGA] [float] NULL,
[RDERI] [float] NULL,
[PIKE] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CONAD] ADD CONSTRAINT [PK_CONAD] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
