CREATE TABLE [dbo].[OrderItemsScr]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SASI] [float] NULL,
[SASIKONV] [float] NULL,
[KMAG] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODAF] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPKLL] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDERSCR] [int] NULL,
[STATROW] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAGNR] [int] NULL,
[TROW] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OrderItemsScr] ON [dbo].[OrderItemsScr] ([NRD]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OrderItemsScr] ADD CONSTRAINT [FK_OrderItemsScr_OrderItems] FOREIGN KEY ([NRD]) REFERENCES [dbo].[OrderItems] ([NRRENDOR]) ON DELETE CASCADE ON UPDATE CASCADE
GO
