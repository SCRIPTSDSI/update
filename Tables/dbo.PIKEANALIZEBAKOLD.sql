CREATE TABLE [dbo].[PIKEANALIZEBAKOLD]
(
[nrrendor] [int] NOT NULL,
[barcode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[kartllg] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bc] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sasi] [float] NULL,
[vlpatvsh] [float] NULL,
[pershkrim] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pike] [float] NULL,
[DYQANI] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NGASHITJET] [bit] NOT NULL,
[NRDDYQANI] [int] NOT NULL,
[DATEDOK] [datetime] NOT NULL,
[ID] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PIKEANALIZEBAKOLD] ADD CONSTRAINT [PK__PIKEANAL__3214EC2744323F01] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
