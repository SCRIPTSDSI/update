SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- EXEC [Isd_RvlFrMG] @pTipHD = 'HD', @pWhere = 'KMAG=''PG1'' AND TIPFR=''B'' ',

CREATE Procedure [dbo].[Isd_RvlFrMG]
(
  @pTipHD    VARCHAR(10),
  @pWhere    VARCHAR(MAX)
 )

AS


          IF CHARINDEX('D',@pTipHD)=0 AND CHARINDEX('H',@pTipHD)=0
             RETURN;


         SET NOCOUNT ON;

     DECLARE @sWhere       VARCHAR(MAX),
             @sTipHD       VARCHAR(20),
             @sSql         VARCHAR(MAX),
             @sSql1        VARCHAR(MAX);
      --     @FiroHD       VARCHAR(100);


      -- SET @FiroHD     = 'BCD';
         SET @sTipHD     = @pTipHD;
         SET @sWhere     = @pWhere;

          IF @sWhere<>''
             SET @sWhere = ' AND '+@sWhere;


          IF OBJECT_ID('TempDB..#FdFiro') IS NOT NULL
             DROP TABLE #FdFiro;

          IF OBJECT_ID('TempDB..#FhFiro') IS NOT NULL
             DROP TABLE #FhFiro;


      SELECT NRRENDOR = CAST(0 AS BIGINT), NRDFK = CAST(0 AS BIGINT)
        INTO #FHFIRO
        FROM FH
       WHERE 1=2;
      CREATE UNIQUE INDEX FHFiro ON #FHFIRO (NRRENDOR);

      SELECT NRRENDOR = CAST(0 AS BIGINT), NRDFK = CAST(0 AS BIGINT)
        INTO #FDFIRO
        FROM FD
       WHERE 1=2;
      CREATE UNIQUE INDEX FDFiro ON #FDFIRO (NRRENDOR);
 

         SET @sSql1 = '

      INSERT INTO #FDFIRO 
		    (NRRENDOR, NRDFK)
      SELECT A.NRRENDOR, NRDFK=ISNULL(A.NRDFK,0)
	    FROM FD A INNER JOIN FDSCR B ON A.NRRENDOR=B.NRD
       WHERE ISNULL(B.VLERAFR,0)<>0 '+@sWhere+'
    GROUP BY A.NRRENDOR,ISNULL(A.NRDFK,0)
      HAVING COUNT(*)>0; ';
      
--     WHERE CHARINDEX(B.TIPFR,'''+@FiroHD+''')>0 AND (B.VLERAFR<>0) '+@sWhere+'


          IF CHARINDEX('D',@pTipHD)>0
             BEGIN

                 SET  @sSql     = @sSql1;
                EXEC (@sSql);

		      UPDATE  A
		         SET  A.VLERAFR = CASE WHEN ABS(A.SASI-A.SASIFR)<=0.001 THEN A.VLERAM ELSE ROUND(A.SASIFR*A.CMIMM,3) END
                FROM  FDSCR A INNER JOIN #FDFIRO B ON A.NRD=B.NRRENDOR;

              DELETE  A
                FROM  FK A INNER JOIN #FDFIRO B ON A.NRRENDOR=B.NRDFK
               WHERE  A.ORG='D' AND B.NRDFK<>0;                       
        
              UPDATE  A
                 SET  A.NRDFK=0
                FROM  FD A INNER JOIN #FDFIRO B ON A.NRRENDOR=B.NRRENDOR
               WHERE  B.NRDFK<>0;                       
           
             END;


          IF CHARINDEX('H',@pTipHD)>0
             BEGIN

                 SET  @sSql     = REPLACE(REPLACE(REPLACE(@sSql1,'#FDFIRO','#FHFIRO'),' FD ',' FH '),' FDSCR ',' FHSCR ');
                EXEC (@sSql);

		      UPDATE  A
		         SET  A.VLERAFR = CASE WHEN ABS(A.SASI-A.SASIFR)<=0.001 THEN A.VLERAM ELSE ROUND(A.SASIFR * A.CMIMM,3) END
                FROM  FHSCR A INNER JOIN #FHFIRO B ON A.NRD=B.NRRENDOR;

              DELETE  A
                FROM  FK A INNER JOIN #FHFIRO B ON A.NRRENDOR=B.NRDFK
               WHERE  A.ORG='H' AND B.NRDFK<>0;
        
              UPDATE  A
                 SET  A.NRDFK=0
                FROM  FH A INNER JOIN #FHFIRO B ON A.NRRENDOR=B.NRRENDOR
               WHERE  B.NRDFK<>0;
             END;

--  SELECT * FROM #FDFIRO
--  SELECT * FROM #FHFIRO

          IF OBJECT_ID('TEMPDB..#FdFiro') IS NOT NULL
             DROP TABLE #FdFiro;

          IF OBJECT_ID('TEMPDB..#FhFiro') IS NOT NULL
             DROP TABLE #FhFiro;
GO
