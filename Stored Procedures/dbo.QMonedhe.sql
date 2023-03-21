SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE     procedure [dbo].[QMonedhe]
(
  @PKod Varchar(50)
 )

As

SELECT *
  FROM MONEDHA 
 WHERE KOD=@PKod






GO
