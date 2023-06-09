CREATE TABLE [dbo].[DRHUSER]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NULL,
[KODUS] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODUL] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TIPDOK] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODREF] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NRKUFIP] [int] NULL,
[NRKUFIS] [int] NULL,
[ACTIVMODUL] [bit] NULL,
[ACTIVKUFIJ] [bit] NULL,
[TROW] [bit] NULL CONSTRAINT [DF_DRHUSER_TROW] DEFAULT ((0)),
[TAGNR] [int] NULL CONSTRAINT [DF_DRHUSER_TAGNR] DEFAULT ((0)),
[DISCOUNTFT] [bit] NULL CONSTRAINT [DF_DRHUSER_DISCOUNTFT] DEFAULT ((1)),
[PRICEMODIF] [bit] NULL CONSTRAINT [DF_DRHUSER_PRICEMODIF] DEFAULT ((0)),
[PARAPGFT] [bit] NULL CONSTRAINT [DF_DRHUSER_PARAPGFT] DEFAULT ((1)),
[ARKEDOKFT] [bit] NULL CONSTRAINT [DF_DRHUSER_ARKEDOKFT] DEFAULT ((1)),
[DOKPAMG] [bit] NULL,
[LISTCM] [bit] NULL,
[KMSROW] [bit] NULL,
[DSCNTROW] [bit] NULL,
[ROWLISTCMART] [bit] NULL,
[ROWLISTCMDOC] [bit] NULL,
[ROWLISTCMFF] [bit] NULL,
[ROWLISTCMOF] [bit] NULL,
[ROWCMSHREF] [bit] NULL,
[PRICEMODIFSH] [bit] NULL,
[DSCNTROWSH] [bit] NULL,
[STATROW] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
