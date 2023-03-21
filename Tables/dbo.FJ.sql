CREATE TABLE [dbo].[FJ]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRDOK] [float] NULL,
[NRFRAKS] [int] NULL,
[DATEDOK] [datetime] NULL,
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODFKL] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM4] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KMON] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KTH] [bit] NULL,
[NIPT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASAKF] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RRETHI] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VENHUAJ] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRSERIAL] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODFISKAL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GRUP] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRDSHOQ] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTDSHOQ] [datetime] NULL,
[KODKART] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRRENDDMG] [int] NULL,
[TIPDMG] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRMAG] [int] NULL,
[KMAG] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRDMAG] [float] NULL,
[FRDMAG] [int] NULL,
[DTDMAG] [datetime] NULL,
[MODPG] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTAF] [int] NULL,
[DTDS] [int] NULL,
[PERQDS] [float] NULL,
[KURS1] [float] NULL,
[KURS2] [float] NULL,
[VLPATVSH] [float] NULL,
[VLTVSH] [float] NULL,
[VLTAX] [float] NULL,
[VLERZBR] [float] NULL,
[VLERTOT] [float] NULL,
[PARAPG] [float] NULL,
[PERQTVSH] [float] NULL,
[PERQZBR] [float] NULL,
[LLOGTVSH] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGZBR] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARK] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISDG] [bit] NULL,
[NRDOKDG] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTDOKDG] [datetime] NULL,
[GRUPIMFT] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPFT] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOJDOK] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASETVSH] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRFATST] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTFATST] [datetime] NULL,
[VLKASE] [float] NULL,
[AGJENTSHITJE] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISDOKSHOQ] [bit] NULL,
[ISPERMBLEDHES] [bit] NULL,
[PRINTKOMENT] [bit] NULL,
[ACTIVFJKOMENT] [bit] NULL,
[KODARK] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATEARK] [datetime] NULL,
[PAGESEARK] [float] NULL,
[NRLINKAPL1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IMPORTTAG] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXTIMPID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXTIMPKOMENT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXTEXP] [bit] NULL,
[EXTEXPKOMENT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AGJENTSHITJELINK] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODPACIENT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODDOCTEGZAM] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODDOCTREFER] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POSTIM] [bit] NULL,
[LETER] [bit] NULL,
[KONFIRM] [bit] NULL,
[FIRSTDOK] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KASEPRINT] [bit] NULL,
[NRDFK] [int] NULL,
[NRDITAR] [int] NULL,
[NRDITARSHL] [int] NULL,
[NRDITARPRMC] [int] NULL,
[NRRENDORAR] [int] NULL,
[NRRENDORAMB] [int] NULL,
[NRRENDOROF] [int] NULL,
[NRRENDOROR] [int] NULL,
[NRRENDORFJT] [int] NULL,
[NRRENDORORGFJ] [int] NULL,
[NRRENDORAQ] [int] NULL CONSTRAINT [DF_FJ_NRRENDORAQ] DEFAULT ((0)),
[NRRENDKF] [int] NULL,
[NRFRAKSKF] [int] NULL,
[NRDFTEXTRA] [int] NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_FJ_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_FJ_DATEEDIT] DEFAULT (getdate()),
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAGLM] [bit] NULL,
[TAG] [bit] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[TAGRND] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISUUID] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISFIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISLASTERRORFIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISLASTERRORTEXTFIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISLASTERROREIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISLASTERRORTEXTEIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISQRCODELINK] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISRELATEDFIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISIIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISIICSIG] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISPDF] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISEIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISRESPONSEXMLFIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISRESPONSEXMLEIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISXMLSTRING] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISXMLSIGNED] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISSTATUS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISBUSINESSUNIT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISTCR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISKODOPERATOR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISPROCES] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISMENPAGESE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISTIPDOK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISDOCFISCAL] [bit] NULL,
[FISKODREASON] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JOBCREATE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIME] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISDATEPARE] [datetime] NULL,
[FISDATEFUND] [datetime] NULL,
[FISTVSHEFEKT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISKALIZUAR] [bit] NULL CONSTRAINT [DF_FJ_FISKALIZUAR] DEFAULT ((0)),
[NRFISKALIZIM] [int] NULL CONSTRAINT [DF_FJ_NRFISKALIZIM] DEFAULT ((0)),
[FISCFIC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[FJ] ADD CONSTRAINT [PK_FJ] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Datedok_incl_nrrendor_nrdok_kodfkl_kmag] ON [dbo].[FJ] ([DATEDOK]) INCLUDE ([KMAG], [KODFKL], [NRDOK], [NRRENDOR]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [@KODFKL_FJ] ON [dbo].[FJ] ([KODFKL]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nrdok_datedok_include] ON [dbo].[FJ] ([NRDOK], [DATEDOK]) INCLUDE ([DTDSHOQ], [ISDOKSHOQ], [KLASETVSH], [KMAG], [KMON], [KODFKL], [LLOJDOK], [NIPT], [NRDMAG], [NRDSHOQ], [NRRENDOR], [NRSERIAL], [SHENIM1], [SHENIM2], [SHENIM3], [TROW], [VLERTOT]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Nrdok_dtdok_incl_many] ON [dbo].[FJ] ([NRDOK], [DATEDOK]) INCLUDE ([DTDSHOQ], [ISDOKSHOQ], [KLASETVSH], [KMAG], [KMON], [KODFKL], [KONFIRM], [LLOJDOK], [NIPT], [NRDMAG], [NRDSHOQ], [NRRENDOR], [NRSERIAL], [SHENIM1], [SHENIM2], [SHENIM3], [TROW], [VLERTOT]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [@NRRENDOR_FJ] ON [dbo].[FJ] ([NRRENDOR]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NRRENDORFJT] ON [dbo].[FJ] ([NRRENDORFJT]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TAGNR_FJ] ON [dbo].[FJ] ([TAGNR]) ON [PRIMARY]
GO