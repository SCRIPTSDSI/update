CREATE TABLE [dbo].[GARANCI]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[NRD] [int] NULL,
[REFTIPDOK] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REFNRDOK] [bigint] NULL,
[REFDATEDOK] [datetime] NULL,
[REFKMAG] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRSERIAL] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GARANCI_NRSERIAL] DEFAULT ('SKA'),
[BARCOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIMSH] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATEDOK] [datetime] NULL,
[SHENIM1] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM2] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM3] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM4] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHITESKOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHITESPERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AGJENTKOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AGJENTPERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ARTKOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ARTBC] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ARTPERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ARTCMIMBS] [float] NULL,
[ARTSASI] [float] NULL CONSTRAINT [DF_GARANCI_SASI] DEFAULT ((1)),
[ARTNJESI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ARTSHENIM1] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ARTSHENIM2] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ARTKODPRODUCT] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ARTMODEL] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GARANCISASI] [float] NULL CONSTRAINT [DF_GARANCI_GARSASI] DEFAULT ((1)),
[GARANCINJESI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GARANCI_GARNJESI] DEFAULT ('MUAJ'),
[STATUS] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GARANCI_STATUS] DEFAULT ((1)),
[STATUSPERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_GARANCI_STATUSPERSHKRIM] DEFAULT ('Normal'),
[STATUSDATE] [datetime] NULL,
[BLERKOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BLERPERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BLERADRESA1] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BLERADRESA2] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BLERRRETHI] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BLEREMAIL] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BLERTELEFON1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BLERTELEFON2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BLERNIPT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BLERSTATUS] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BLERSHENIM1] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_GARANCI_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_GARANCI_DATEEDIT] DEFAULT (getdate()),
[NRDSM] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRDFATURA] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHOTO1] [image] NULL,
[PHOTO1PATH] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PHOTO2] [image] NULL,
[PHOTO2PATH] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPORT] [bit] NULL,
[NRRESHT] [int] NULL,
[NRFRAKS] [int] NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[GARANCI] ADD CONSTRAINT [PK_GARANCIA] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
