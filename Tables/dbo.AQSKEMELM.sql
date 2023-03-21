CREATE TABLE [dbo].[AQSKEMELM]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[KOD] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSHKRIM] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGSHPBL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGSHPAM] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KLASIFIKIM] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAG] [bit] NULL,
[TROW] [bit] NULL,
[TAGNR] [int] NULL,
[LLOGBL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGAM] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGCEVL] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGCEAM] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGSH] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGSHMI] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NOTACTIV] [bit] NULL,
[LLOGSHPVLERMBET] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGPRONESI] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGPLUSVLERA] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LLOGMINUSVLERA] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DITARKONTABBLERJE] [bit] NULL,
[DITARKONTABSHITJE] [bit] NULL
) ON [PRIMARY]
GO
