CREATE TABLE [dbo].[LOGPOSTIME]
(
[NRRENDOR] [int] NOT NULL,
[STATUS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USERID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBJECTNAME] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STARTDATETIME] [datetime] NULL,
[ENDDATETIME] [datetime] NULL,
[ERRORMESSAGE] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRDOKPAPOST] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GJENDJE] [float] NULL,
[BARCODE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KMAG] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATEDOK] [datetime] NULL,
[NRDOK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ID] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LOGPOSTIME] ADD CONSTRAINT [PK__LOGPOSTI__3214EC27166B7451] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
