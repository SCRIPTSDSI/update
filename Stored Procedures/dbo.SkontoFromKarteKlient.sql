SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE      PROCEDURE [dbo].[SkontoFromKarteKlient]
@PARA1  AS VARCHAR(10),
@PARA2 AS VARCHAR(25),
@PARA3   AS FLOAT,
@PARA4   AS VARCHAR(25)
AS

SELECT SKONTO=0
GO
