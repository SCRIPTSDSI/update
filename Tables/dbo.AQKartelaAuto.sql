CREATE TABLE [dbo].[AQKartelaAuto]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [bigint] NULL,
[KODCFG] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOLLOJ] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOMARKE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOTIP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOBISNESNAME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOKAROCEKOD] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOCOLOR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTONRDOORS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTONRHOMOLOGIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTODESTINACION] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOKARBURANT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOVELLIMI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOVELLIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOFUQI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTONRCILINDER] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOIDMOTOR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOYEAR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOSEATS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOSEATSALL] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOHEIGHT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOWIDTH] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOLENGTH] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTONRAKS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOWEIGHTMAX] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOWEIGHTEMPTY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOWEIGHTDRIVE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOENGINE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOSEGMENTAKS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOTIREDIMENSION] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOSPEEDMAX] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RIMORKOLLOJ] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RIMORKOMARKE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RIMORKOTIP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RIMORKONRHOMOLOGIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RIMORKOID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RIMORKOWEIGHTEMPTY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RIMORKOWEIGHTMAX] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AUTOPESHAGANXHE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [NRRENDOR_AQK] ON [dbo].[AQKartelaAuto] ([NRRENDOR]) ON [PRIMARY]
GO
