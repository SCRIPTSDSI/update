CREATE TABLE [dbo].[AQMirembajtje]
(
[MaintenanceID] [int] NOT NULL IDENTITY(1, 1),
[AssetID] [int] NULL,
[MaintenanceDate] [datetime] NULL,
[MaintenanceDescription] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaintenancePerformedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaintenanceCost] [money] NULL,
[TAGNR] [int] NULL,
[NRRENDOR] [int] NULL
) ON [PRIMARY]
GO
