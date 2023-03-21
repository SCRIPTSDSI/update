CREATE TABLE [dbo].[SM]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[DATEDOK] [datetime] NULL,
[KTH] [bit] NULL,
[NRDOK] [float] NULL,
[NRFRAKS] [int] NULL,
[KOD] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODFKL] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KMON] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASAKF] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KASE] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VENHUAJ] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NIPT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRSERIAL] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODFISKAL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RRETHI] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM4] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRDSHOQ] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTDSHOQ] [datetime] NULL,
[NRRENDDMG] [int] NULL,
[TIPDMG] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRMAG] [int] NULL,
[KMAG] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRDMAG] [int] NULL,
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
[VLERZBR] [float] NULL,
[VLERTOT] [float] NULL,
[PARAPG] [float] NULL,
[PERQTVSH] [float] NULL,
[PERQZBR] [float] NULL,
[LLOGTVSH] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGZBR] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGARK] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRDFK] [int] NULL,
[NRDITAR] [int] NULL,
[POSTIM] [bit] NULL,
[LETER] [bit] NULL,
[FIRSTDOK] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISDG] [bit] NULL,
[NRDOKDG] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTDOKDG] [datetime] NULL,
[TAGNR] [int] NULL,
[NRDITARSHL] [int] NULL,
[NRRENDKF] [int] NULL,
[NRFRAKSKF] [int] NULL,
[NRDFTEXTRA] [int] NULL,
[ISDOKSHOQ] [bit] NULL,
[NRRENDOROF] [int] NULL,
[NRRENDOROR] [int] NULL,
[TIMED] [datetime] NULL,
[KLASIFIKIM] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAG] [bit] NULL,
[TROW] [bit] NULL,
[VLTAX] [float] NULL,
[PGKLIENT] [float] NULL,
[KLIENTID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATEARK] [datetime] NULL,
[NRRENDORFJT] [int] NULL,
[EXTEXP] [bit] NULL,
[KASEPRINT] [bit] NULL,
[KONFIRM] [bit] NULL,
[PAGESEARK] [float] NULL,
[KLASIFIKIM1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASETVSH] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODKART] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PGFORM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PGLIKUJ] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PGSHENIM1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PGSHENIM2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXTIMPID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXTIMPKOMENT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXTEXPKOMENT] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AGJENTSHITJELINK] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DATECREATE] [datetime] NULL CONSTRAINT [DF_SM_DATECREATE] DEFAULT (getdate()),
[DATEEDIT] [datetime] NULL CONSTRAINT [DF_SM_DATEEDIT] DEFAULT (getdate()),
[TAGRND] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISDATEPARE] [datetime] NULL,
[FISKALIZUAR] [bit] NULL,
[ISDOCFISCAL] [bit] NULL,
[FISLASTERROREIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISLASTERRORTEXTEIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISQRCODELINK] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISRELATEDFIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISIIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISLASTERRORTEXTFIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISLASTERRORFIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISUUID] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISFIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISIICSIG] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISTCR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISPROCES] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISSTATUS] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISPDF] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISBUSINESSUNIT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISDATEFUND] [datetime] NULL,
[Nrfiskalizim] [int] NULL,
[FISKODOPERATOR] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JOBCREATE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIME] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISTVSHEFEKT] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISEIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISRESPONSEXMLFIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISRESPONSEXMLEIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISXMLSTRING] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISXMLSIGNED] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISMENPAGESE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISTIPDOK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISKODREASON] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fic] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iicsig] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_SM_UUID] DEFAULT (newid()),
[eic] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RESPONSEXMLEIC] [xml] NULL,
[fisctcr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fiscbusinunit] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RELATEDFIC] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isfj] [bit] NULL,
[KARTE] [bit] NULL,
[tipnipt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iscash] [bit] NULL,
[errorlast] [xml] NULL,
[errortextlast] [xml] NULL,
[XMLSTRING] [xml] NULL,
[SIGNEDXML] [xml] NULL,
[QRCODELINK] [xml] NULL,
[RESPONSEXMLFIC] [xml] NULL,
[PROCES] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISCMENPAG] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FISCTIPDOK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPORT] [bit] NULL,
[PIKE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LASTMODIF] [datetime] NULL,
[NRDSKONTO] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMERKOMP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NEKASE] [bit] NULL,
[VOUCHER] [bit] NULL,
[PRINTKASE] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [@KODFKL_SM] ON [dbo].[SM] ([KODFKL]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [@NRRENDOR_SM] ON [dbo].[SM] ([NRRENDOR]) ON [PRIMARY]
GO