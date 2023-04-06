CREATE TABLE [dbo].[OFERTEBAKSCR]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NOT NULL,
[MENUELEMENTID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CMIM] [float] NOT NULL,
[CMB] [float] NOT NULL,
[PIKE] [float] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OFERTEBAKSCR] ADD CONSTRAINT [PK_OFERTEBAKSCR] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO