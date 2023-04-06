CREATE TABLE [dbo].[FISBLERJE]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[DocNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount] [float] NULL,
[DocType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DueDateTime] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EIC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartyType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecDateTime] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PDF] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FISBLERJE_1] ON [dbo].[FISBLERJE] ([EIC]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FISBLERJE] ON [dbo].[FISBLERJE] ([NRRENDOR]) ON [PRIMARY]
GO
