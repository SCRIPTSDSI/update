SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE     procedure [dbo].[QObjectsLink]
(
  @PKod        Varchar(50),
  @PNrRendor   Int
 )

As

SELECT *
  FROM OBJECTSLINK 
 WHERE TABELA=@PKod AND NRD=@PNrRendor






GO
