SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[GetGaranci](@SERIAL AS NVARCHAR(50),@KOD AS NVARCHAR(50),
@PERSHKRIM AS NVARCHAR(250),@KMAG AS NVARCHAR(30),@DNGA AS DATETIME,@DDERI AS DATETIME)
AS

SELECT * FROM DRH..GARANCIA 
WHERE SERIALI LIKE @SERIAL
AND KOD LIKE @KOD
AND PERSHKRIM LIKE @PERSHKRIM
AND SHITESKOD LIKE @KMAG
--AND (DATEADD(MM,GARSASI,DATEDOK)>=@DNGA 
--AND DATEDOK<=@DNGA) 
--AND (DATEADD(MM,GARSASI,DATEDOK)<=@DDERI 
--AND DATEDOK<=@DDERI) 



--SELECT GETDATE(),DATEADD(MM,2,GETDATE())
GO
