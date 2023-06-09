CREATE TABLE [dbo].[AQKartelaCE]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIMSH] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KATEGORI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GRUP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NOTACTIV] [bit] NULL,
[DTBL] [datetime] NULL,
[CMIMBL] [float] NULL,
[VLERABL] [float] NULL,
[DTPERD] [datetime] NULL,
[DTCE] [datetime] NULL,
[NORMEAMCE] [float] NULL,
[SASICE] [float] NULL,
[CMIMCE] [float] NULL,
[VLERACE] [float] NULL,
[VLERAAMCE] [float] NULL,
[DTSH] [datetime] NULL,
[VLERASH] [float] NULL,
[VLERAAMSH] [float] NULL,
[DTAM] [datetime] NULL,
[VLERAAM] [float] NULL,
[VLERAAMCUM] [float] NULL,
[KODLM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERDORUES] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VENDNDODH] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DHURATE] [bit] NULL,
[FURNITOR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODEL] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODELNR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERIALNR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIF1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIF2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIF3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BC] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODFIN] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEP] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LIST] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VLERABLMON] [float] NULL,
[MON] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KOMENT] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAGNR] [int] NULL,
[TROW] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
