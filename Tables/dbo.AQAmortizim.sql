CREATE TABLE [dbo].[AQAmortizim]
(
[DepreciationID] [int] NOT NULL IDENTITY(1, 1),
[AssetID] [int] NULL,
[DepreciationDate] [datetime] NULL,
[DepreciationAmount] [money] NULL,
[TAGNR] [int] NULL
) ON [PRIMARY]
GO
