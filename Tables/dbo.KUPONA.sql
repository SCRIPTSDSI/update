CREATE TABLE [dbo].[KUPONA]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[NRKUPON] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DNGA] [datetime] NULL,
[DDERI] [datetime] NULL,
[AKTIV] [bit] NOT NULL CONSTRAINT [DF_KUPONA_AKTIV] DEFAULT ((1)),
[VALUE] [float] NOT NULL CONSTRAINT [DF_KUPONA_VALUE] DEFAULT ((0)),
[ISPERCENTAGE] [bit] NOT NULL CONSTRAINT [DF_KUPONA_ISPERCENTAGE] DEFAULT ((0)),
[PASSKEY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOMENT] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KUPONA] ADD CONSTRAINT [PK__KUPONA__2E8B20C75D32F6F5] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
