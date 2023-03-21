CREATE TABLE [dbo].[OrderItemsSort]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM1] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM2] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATEDOK] [datetime] NULL,
[KLASIFIKIM1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROMPTKOEF1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROMPTKOEF2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROMPTKOEF3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROMPTKOEF4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDERFIELDS] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACTIV] [bit] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_OrderItemsSort] ON [dbo].[OrderItemsSort] ([NRRENDOR]) ON [PRIMARY]
GO
