CREATE TABLE [dbo].[KLIENT]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARI] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NIPT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODFISKAL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRLICENCE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERFAQESUES] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADRESA1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADRESA2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADRESA3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMERTIMLB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TELEFON1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TELEFON2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FAX] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODPOSTAR] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARIBANKE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMAIL] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INTERNET] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QELLIM] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AFAT] [int] NULL,
[TATIM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTRAPORT] [int] NULL,
[KREDI] [float] NULL,
[KREDISP] [float] NULL,
[BILANC] [float] NULL,
[TOTREF] [float] NULL,
[GRUP] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KATEGORI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VENDNDODHJE] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RAJON] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VENDHUAJ] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODLINKKF] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AGJENTSHITJE] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LINKKLIENT] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LINKKLIENTKONV] [float] NULL,
[LINKKLIENTSIGN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[APLFIRO] [bit] NULL,
[KMON] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OKFJSHOQ] [bit] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[KOEFICENT] [float] NULL CONSTRAINT [DF_KLIENT_KOEFICENT] DEFAULT ((0)),
[KLASIFIKIM3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERQDSCN] [float] NULL,
[BLOCKDT] [bit] NULL,
[KLASIFIKIM4] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM5] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM6] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODPG] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPI] [int] NULL,
[NIPTCERTIFIKATE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODBASHKI] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEP] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LISTE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODFIN] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODIMP] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTFILLIMINVFIZIK] [datetime] NULL,
[BLOCKDTKP] [datetime] NULL,
[BLOCKDTKS] [datetime] NULL,
[KOMENTACTIV] [bit] NULL,
[KOMENT] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACTIVCM] [bit] NULL,
[KMAG] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[APLKREDILIM] [bit] NULL,
[KREDIOVERBLOCK] [bit] NULL,
[KREDIMODBLOCK] [int] NULL,
[KREDIWARNING] [float] NULL,
[DTOPENCONTACT] [datetime] NULL,
[DTCLOSECONTACT] [datetime] NULL,
[KODORIGJINE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NIPTACTIV] [bit] NULL,
[GRUPIMTATIMOR] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FRANCHSTATUS] [bit] NULL,
[FRANCHKOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[APLARTIKUJKTG] [bit] NULL,
[KODHISTORIK] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NOTACTIV] [bit] NULL CONSTRAINT [DF_KLIENT_NOTACTIV] DEFAULT ((0)),
[DATECREATE] [datetime] NULL CONSTRAINT [DF_KLI_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_KLI_DATEEDIT] DEFAULT (getdate()),
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SWIFTKOD] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARIBANKE2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SWIFTKOD2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISDOCFISCAL] [bit] NULL,
[TIPNIPT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [@KOD_KLIENT] ON [dbo].[KLIENT] ([KOD]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [NRRENDOR_KLIENT] ON [dbo].[KLIENT] ([NRRENDOR]) ON [PRIMARY]
GO
