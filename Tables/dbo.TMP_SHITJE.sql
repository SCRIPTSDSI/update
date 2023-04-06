CREATE TABLE [dbo].[TMP_SHITJE]
(
[DATEDOK] [datetime] NULL,
[NRDOK] [int] NULL,
[KMAG] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KODFKL] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KASE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHENIM1] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERQZBR] [float] NULL,
[KLASIFIKIM] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BC] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KARTLLG] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NJESI] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SASI] [float] NULL,
[CMSHZB0] [float] NULL,
[PERQDSCN] [float] NULL,
[CMIMBS] [float] NULL,
[VLERABS] [float] NULL,
[EXPORT] [bit] NULL CONSTRAINT [DF_TMP_SHITJE_EXPORT] DEFAULT ((0)),
[KLIENTID] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
