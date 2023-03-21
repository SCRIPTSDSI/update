CREATE TABLE [dbo].[OrderItemsSortScr]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[NRORDER] [int] NULL,
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BC] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOEFICENTCOPE] [float] NULL,
[KOEFICENTCOPEDOC] [bit] NULL,
[KOEFKONV1] [float] NULL,
[KOEFKONV2] [float] NULL,
[KOEFKONV3] [float] NULL,
[KOEFKONV4] [float] NULL,
[GRUPIM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDERSCR] [int] NULL,
[STATROW] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OrderItemsSortScr_Nrd] ON [dbo].[OrderItemsSortScr] ([NRD]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OrderItemsSortScr] ON [dbo].[OrderItemsSortScr] ([NRRENDOR]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OrderItemsSortScr] ADD CONSTRAINT [FK_OrderItemsSortScr_OrderItemsSort] FOREIGN KEY ([NRD]) REFERENCES [dbo].[OrderItemsSort] ([NRRENDOR]) ON DELETE CASCADE ON UPDATE CASCADE
GO
