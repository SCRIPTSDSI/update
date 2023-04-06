CREATE TABLE [dbo].[AQPersonel]
(
[EmployeeID] [int] NOT NULL IDENTITY(1, 1),
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Extension] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WorkPhone] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OfficeLocation] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAGNR] [int] NULL,
[NRRENDOR] [int] NULL,
[TROW] [bit] NULL
) ON [PRIMARY]
GO
