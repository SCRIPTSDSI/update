CREATE TABLE [dbo].[AQVendorsFurnitor]
(
[VendorID] [int] NOT NULL IDENTITY(1, 1),
[VendorName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactFirstName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactLastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateOrProvince] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country/Region] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FaxNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAGNR] [int] NULL,
[NRRENDOR] [int] NULL,
[TROW] [bit] NULL
) ON [PRIMARY]
GO
