CREATE TABLE [dbo].[ISD3]
(
[BC] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SASIA] [float] NULL,
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ISD3] ADD CONSTRAINT [PK__ISD3__2E8B20C73ADDDEF1] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
