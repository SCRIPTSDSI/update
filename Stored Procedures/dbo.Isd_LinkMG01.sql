SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Exec dbo.Isd_LinkMG01 ' (  DATEDOK>=DBO.DATEVALUE(''01/01/2018'') AND   DATEDOK<=DBO.DATEVALUE(''31/12/2018'')) ',
--                       ' (A.DATEDOK>=DBO.DATEVALUE(''01/01/2018'') AND A.DATEDOK<=DBO.DATEVALUE(''31/12/2018'')) ',1,1

CREATE Procedure [dbo].[Isd_LinkMG01]
(
  @pWhere1       Varchar(MAX),
  @pWhere2       Varchar(MAX),
  @pDistinct     Bit,
  @pTestNr       Bit
 )
 
AS


         SET NOCOUNT OFF;

     DECLARE @sSql   nVarchar(MAX);


         SET @sSql = '

      SELECT DISTINCT DOKUMENT=''FD'',KMAG,NRDOK,NRFRAKS,DATEDOK,SHENIM1,SHENIM2, DST, 
             KMAGDEST=KMAGRF,KMAGLNK,NRDOKLNK,NRFRAKSLNK,DATEDOKLNK, 
             PROMPTERR=''Gabim ne Mag.Destin/Mag.Lidhur'',NRRENDOR
        FROM FD
       WHERE (
              ISNULL(KMAGRF,'''')='''' OR ISNULL(KMAGLNK,'''')='''' OR ISNULL(NRDOKLNK,0)=0 OR (DATEDOKLNK IS NULL) OR ISNULL(KMAGRF,'''')<>ISNULL(KMAGLNK,'''')
              ) 
              AND 
             (1=1)           -- (DOK_JB=0) AND (DST IN (''LB'',''KM'',''DM'',''FU''))     AND  @pWhere1        -- Vijne nga programi

   UNION ALL
   
      SELECT DISTINCT DOKUMENT=''FH'',KMAG,NRDOK,NRFRAKS,DATEDOK,SHENIM1,SHENIM2, DST, 
             KMAGDEST=KMAGRF,KMAGLNK,NRDOKLNK,NRFRAKSLNK,DATEDOKLNK, 
             PROMPTERR=''Gabim ne Mag.Destin/Mag.Lidhur'',NRRENDOR
        FROM FH
       WHERE (
              ISNULL(KMAGRF,'''')='''' OR ISNULL(KMAGLNK,'''')='''' OR ISNULL(NRDOKLNK,0)=0 OR (DATEDOKLNK IS NULL) OR ISNULL(KMAGRF,'''')<>ISNULL(KMAGLNK,'''')
              ) 
              AND 
             (1=1)           -- (DOK_JB=0) AND (DST IN (''LB'',''KM'',''DM'',''FU''))     AND  @pWhere1        -- Vijne nga programi
              
   UNION ALL
   
      SELECT DISTINCT DOKUMENT=''FD'', A.KMAG,A.NRDOK,A.NRFRAKS,A.DATEDOK,A.SHENIM1,A.SHENIM2,A.DST, 
             KMAGDEST=A.KMAGRF,A.KMAGLNK,A.NRDOKLNK,A.NRFRAKSLNK,A.DATEDOKLNK, 
             PROMPTERR=''Mosperputhje datave'',A.NRRENDOR   
        FROM FD A INNER JOIN FH B ON A.NRDOK=B.NRDOK AND ISNULL(A.NRFRAKS,0)=ISNULL(B.NRFRAKS,0)
       WHERE (0=1) AND (A.DATEDOK<>B.DATEDOK) AND 
             (2=2)           -- (A.DOK_JB=0) AND (A.DST IN (''LB'',''KM'',''DM'',''FU'')) AND @PWhere2         -- Vijne nga programi

    ORDER BY KMAG,DOKUMENT,NRDOK,DATEDOK; ';

          IF @pDistinct<>1
             SET @sSql = REPLACE(@sSql,' DISTINCT ',' ');
             
          IF @pWhere1<>''
             SET @sSql = REPLACE(@sSql,'1=1',@pWhere1);
          IF @pWhere2<>''   
             SET @sSql = REPLACE(@sSql,'2=2',@pWhere2);
             
          IF @pTestNr=1   
             SET @sSql = REPLACE(@sSql,'0=1','0=0');
             
     PRINT @sSql;

     EXEC (@sSql);



GO
