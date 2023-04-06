CREATE TABLE [dbo].[FieldsPrompt]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[TABLENAME] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FIELDNAME] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FIELDPROMPT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FieldsPrompt] ON [dbo].[FieldsPrompt] ([TABLENAME], [FIELDNAME]) ON [PRIMARY]
GO
