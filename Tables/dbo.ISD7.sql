CREATE TABLE [dbo].[ISD7]
(
[BC] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SASIA] [float] NULL,
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ISD7] ADD CONSTRAINT [PK__ISD7__2E8B20C7AB4D9CDF] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
