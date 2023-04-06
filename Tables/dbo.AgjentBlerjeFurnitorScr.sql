CREATE TABLE [dbo].[AgjentBlerjeFurnitorScr]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[KODAF] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NIPTACTIV] [bit] NULL,
[KODORDER] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRORDER] [int] NULL,
[STATROW] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDERSCR] [int] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[NotDokumentFat] [bit] NULL,
[NotDocumentFat] [bit] NULL,
[NrKontrate] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateKontrate] [datetime] NULL,
[DateStart] [datetime] NULL,
[DateEnd] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [@NRD_AgjentBlerjeFurnitorScr] ON [dbo].[AgjentBlerjeFurnitorScr] ([NRRENDOR]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AgjentBlerjeFurnitorScr] ADD CONSTRAINT [FK_AgjentBlerjeFurnitorScr_AgjentBlerjeFurnitor] FOREIGN KEY ([NRD]) REFERENCES [dbo].[AgjentBlerjeFurnitor] ([NRRENDOR]) ON DELETE CASCADE ON UPDATE CASCADE
GO
