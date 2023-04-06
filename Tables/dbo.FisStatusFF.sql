CREATE TABLE [dbo].[FisStatusFF]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NIPT] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NrDok] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vlera] [float] NULL,
[Tipi] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateDok] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FisEIC] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartyType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateReg] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeReg] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FisPDF] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_FisStatusFF_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_FisStatusFF_DATEEDIT] DEFAULT (getdate()),
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[NrRendorStatus] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[FisStatusFF] ADD CONSTRAINT [PK_FisStatusFF] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
