SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  PROCEDURE [dbo].[P_ACMAD_LLOGARIT_VLERA] AS
DECLARE @TVSH AS FLOAT;
SET @TVSH=(SELECT ISNULL(MAX(PERQTATB),0) FROM CONFIGLM) ;

/*(1)*/
  UPDATE ARTIKUJCMAD SET
         CMSHPATVSH=CMSH,
         CMSHTVSH=CMSH,
         TVSH=0
  WHERE (TATIM<>1) OR (TATIM IS NULL);

/*(2)*/
  UPDATE ARTIKUJCMAD SET
         TVSH=@TVSH,
         CMSHPATVSH=CMSH,
--         CMSHPATVSH=CMSH/((100+@TVSH)/100),
         CMSHTVSH=CMSH*((100+@TVSH)/100)
  WHERE TATIM=1;
--****************************************--


GO
