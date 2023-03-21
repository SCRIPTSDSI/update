SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[P_ARTIKUJ_KERKO] (
 @TIPKERKIM VARCHAR(30),--MULTI_BC ose JO_MULTI_BC
 @KERKO VARCHAR(50),    --VLERA QE KERKOHET
 @KOLONA VARCHAR(10)    -- KOLONA NE T CILEN KERKOHET
 ) AS
DECLARE @QUERY NVARCHAR(4000);
/*  KERKIMI ME MULTI_BARKOD */
/****************************/
IF @TIPKERKIM='1'-- AND @kolona='BC'
BEGIN
SET @QUERY='

  SELECT A.NRRENDOR ,
        KOD ,
        ISNULL(BCS.BC,A.BC) AS BC,
        ISNULL(BCS.PERSHKRIM,A.PERSHKRIM) AS PERSHKRIM,
        KLASIF ,
        KLASIF2 ,
        NJESI ,
        POZIC ,
        CMSH ,
        CMSH1 ,
        CMSH2 ,
        CMSH3 ,
        CMSH4 ,
        CMSH5 ,
        CMSH6 ,
        CMSH7 ,
        CMSH8 ,
        CMSH9 ,
        TATIM ,
        PESHA ,
        RIMBURSIM ,
        NOTACTIV
        FROM ARTIKUJ A '
       -- INNER JOIN ARTIKUJBCSCR BCS ON A.NRRENDOR=BCS.NRD  WHERE BCS.BC=QUOTENAME(@KERKO)
    IF @KOLONA='BC'
     SET @QUERY=@QUERY+ '  INNER JOIN ARTIKUJBCSCR BCS ON A.NRRENDOR=BCS.NRD  WHERE BCS.BC IN ('+@KERKO+')'
    IF @KOLONA='KOD'
      SET @QUERY=@QUERY+ ' LEFT JOIN ARTIKUJBCSCR BCS ON A.NRRENDOR=BCS.NRD WHERE A.KOD ='+@KERKO
  EXEC SP_EXECUTESQL @QUERY;
END ELSE
--IF @TIPKERKIM<>'1'
BEGIN
  /*  KERKIMI PA MULTI_BARKOD */
  /****************************/
SET @QUERY='
 SELECT A.NRRENDOR ,
        KOD ,
        BC,
        PERSHKRIM,
        KLASIF ,
        KLASIF2 ,
        NJESI ,
        POZIC ,
        CMSH ,
        CMSH1 ,
        CMSH2 ,
        CMSH3 ,
        CMSH4 ,
        CMSH5 ,
        CMSH6 ,
        CMSH7 ,
        CMSH8 ,
        CMSH9 ,
        TATIM ,
        PESHA ,
        RIMBURSIM ,
        NOTACTIV
         FROM ARTIKUJ A
    WHERE A.'+@KOLONA+'='+@KERKO
    EXEC SP_EXECUTESQL @QUERY;
END;

GO
