CREATE TABLE [dbo].[KLASATVSH]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[KOD] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERQTVSH] [float] NULL CONSTRAINT [DF_KLASATVSH_PERQTVSH] DEFAULT ((0)),
[LLOGTVSHFF] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGTVSHFJ] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[KODKASE] [int] NOT NULL CONSTRAINT [DF_KLASATVSH_KODKASE] DEFAULT ((0)),
[KODEIC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIMEIC] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODTVSHFIC] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODTVSHEIC] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RESPONSEXMLEIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXTVSHFIC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXTVSHeic] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[KLASATVSH] ADD CONSTRAINT [PK_KLASATVSH] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [KOD] ON [dbo].[KLASATVSH] ([KOD]) ON [PRIMARY]
GO