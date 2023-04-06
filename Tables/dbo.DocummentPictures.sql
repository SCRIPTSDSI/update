CREATE TABLE [dbo].[DocummentPictures]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[REFKODND] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REFTABLENAME] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REFKOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REFNRRENDOR] [int] NULL,
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM1] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM2] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PICTURE] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADRESE1] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PICTUREEXT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_zGraphics_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_zGraphics_DATEEDIT] DEFAULT (getdate()),
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
