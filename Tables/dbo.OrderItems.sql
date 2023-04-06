CREATE TABLE [dbo].[OrderItems]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[DATEDOK] [datetime] NULL,
[NRDOK] [int] NULL,
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM1] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM2] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KMAG] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATEDOKCREATE] [datetime] NULL,
[COLUMNLIST] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LISTORDEREDMK] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LISTORDEREDDQ] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LISTORDEREDKL] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LISTORDERCOLMK] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LISTORDERCOLDQ] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LISTORDERCOLKL] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDERSTATUS] [int] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAGNR] [int] NULL,
[TROW] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OrderItems] ADD CONSTRAINT [PK_OrderItems] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO