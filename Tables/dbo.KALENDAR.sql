CREATE TABLE [dbo].[KALENDAR]
(
[c_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prefix] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[year] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[qtr] [int] NULL,
[num] [int] NULL,
[from] [datetime] NULL,
[to] [datetime] NULL,
[name] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adjust] [bit] NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [@c_name] ON [dbo].[KALENDAR] ([c_name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [num] ON [dbo].[KALENDAR] ([num]) ON [PRIMARY]
GO
