SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[getProductType]( @productCode AS varchar)
as
SELECT TOP 1 KLASIF FROM ARTIKUJ WHERE KOD = @productCode
GO