CREATE TABLE [dbo].[AQ]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRMAG] [int] NULL,
[TIP] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KMAG] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRDOK] [float] NULL,
[NRFRAKS] [int] NULL,
[DATEDOK] [datetime] NULL,
[SHENIM1] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM2] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM3] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM4] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRDFK] [bigint] NULL,
[DOK_JB] [bit] NULL,
[NRRENDORFAT] [bigint] NULL,
[TIPFAT] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KTH] [bit] NULL,
[DST] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POSTIM] [bit] NULL,
[LETER] [bit] NULL,
[FIRSTDOK] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODLM] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KALIMLMZGJ] [bit] NULL,
[KLASIFIKIM] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAG] [bit] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[NRSERIAL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KMON] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KURS1] [float] NULL,
[KURS2] [float] NULL,
[NRDOKUP] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATEDOKUP] [datetime] NULL,
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_AQ_DATEEDIT] DEFAULT (getdate()),
[DATECREATE] [datetime] NULL CONSTRAINT [DF_AQ_DATECREATE] DEFAULT (getdate()),
[GRUP] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAGLM] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AQ] ADD CONSTRAINT [NRRENDOR] UNIQUE NONCLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
