CREATE TABLE [dbo].[OFERTEBAKSCHD]
(
[NRRENDOR] [int] NOT NULL IDENTITY(1, 1),
[NRD] [int] NOT NULL,
[ORANGA] [datetime] NOT NULL,
[ORADERI] [datetime] NOT NULL,
[DITA] [int] NOT NULL,
[DITAPERSHKRIM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OFERTEBAKSCHD] ADD CONSTRAINT [PK_OFERTEBAKSCHD] PRIMARY KEY CLUSTERED  ([NRRENDOR]) ON [PRIMARY]
GO