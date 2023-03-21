CREATE TABLE [dbo].[SG_SEGMENTSL]
(
[USC] [int] NULL,
[NRD] [int] NULL,
[CODE] [int] NULL,
[KOD] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[S_NAME] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DESC] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NR] [int] NULL,
[DISPLAYED] [bit] NULL,
[INDEXED] [bit] NULL,
[VAL_DEFAULT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REQUIRED] [bit] NULL,
[SIZE_DISPLAY] [int] NULL,
[SIZE_DESC] [int] NULL,
[SIZE_SHORTDESC] [int] NULL,
[T] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SECURITY] [bit] NULL,
[VAL_TYPE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VAL_NO] [bit] NULL,
[VAL_UCO] [bit] NULL,
[VAL_RIGHT] [bit] NULL,
[VAL_SIZE] [int] NULL,
[VAL_MIN] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VAL_MAX] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HEMODE] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HESTR] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MANUALE] [bit] NULL,
[SKEDARI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LEVIZ] [bit] NULL,
[MERPJESE] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [KOD_SGL] ON [dbo].[SG_SEGMENTSL] ([CODE], [KOD]) ON [PRIMARY]
GO
