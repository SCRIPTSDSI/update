CREATE TABLE [dbo].[LOGFSHIRJE]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[DATESTAMP] [datetime] NOT NULL CONSTRAINT [DF_LOGFSHIRJE_DATESTAMP] DEFAULT (getdate()),
[PERDORUES] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SASI] [float] NULL,
[CMIM] [float] NULL,
[VLERE] [float] NULL,
[VLEREFATURE] [float] NULL,
[KOMPJUTERI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LOGFSHIRJE] ADD CONSTRAINT [PK_LOGFSHIRJE] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
