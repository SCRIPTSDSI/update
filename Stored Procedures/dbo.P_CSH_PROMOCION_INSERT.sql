SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[P_CSH_PROMOCION_INSERT]( @MASTER_ID INT,@DATA_REFERENCE VARCHAR(30), @WHERE VARCHAR(1000))
AS
DECLARE 
   @QUERY NVARCHAR(4000)
   
   
--@DATA_REFERENCE --Nuk eshte perdorur sepse duhet lidhur me funksionin e cmimit
--si date reference mund te perdoret edhe Data e fillimit te Promocionit
--e cila mund te merret nepermjet @MASTER_ID-se
SET @QUERY=

' INSERT INTO CSH_PROMOCION_SCR
           (MASTER_ID
           ,KOD
           ,PERSHKRIM
           ,NJESI
           ,CMSH
           ,CMIMI)
SELECT '+ 
     CAST(@MASTER_ID AS VARCHAR(20))+'
     ,KOD
     ,PERSHKRIM
     ,NJESI
     ,DBO.SALES_PRICE(KOD,'''','''',DBO.DATEVALUE('''+@DATA_REFERENCE+'''))
     ,DBO.SALES_PRICE(KOD,'''','''',DBO.DATEVALUE('''+@DATA_REFERENCE+'''))
FROM ARTIKUJ WHERE 1=1 AND  KOD NOT IN (SELECT KOD FROM CSH_PROMOCION_SCR ) '+@WHERE;
PRINT @QUERY
EXEC SP_EXECUTESQL @QUERY
GO
