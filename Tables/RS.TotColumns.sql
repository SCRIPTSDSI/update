CREATE TABLE [RS].[TotColumns]
(
[ColID] [int] NOT NULL,
[TotColID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [RS].[TotColumns] ADD CONSTRAINT [FK_RS_TotColumns_RS_RapColumns] FOREIGN KEY ([ColID]) REFERENCES [RS].[Columns] ([ID])
GO
