CREATE TABLE [dbo].[X_FORMDISPL]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[PERSHKRIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FORME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IDFORME] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRORDER] [int] NULL,
[FIELD] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROMPT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WIDTH] [int] NULL,
[INGRID] [bit] NULL,
[DISPLAY] [bit] NULL,
[READONLY] [bit] NULL,
[BUTONSTYLE] [int] NULL,
[TAGNR] [int] NULL,
[TROW] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDFORME] ON [dbo].[X_FORMDISPL] ([IDFORME], [NRORDER]) ON [PRIMARY]
GO
