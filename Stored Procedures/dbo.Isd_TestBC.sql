SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE     procedure [dbo].[Isd_TestBC]
(
  @PWhereArt   Varchar(Max),
  @pKoment     Varchar(100),
  @PTipTest    Int
 )

As

--
--      SELECT A.KOD,A.PERSHKRIM,A.NJESI,KLASIF1=A.KLASIF,
--             B.BC,B.NRBC 
--        FROM ARTIKUJ A INNER JOIN  
--
--                     ( 
--                       SELECT BC,NRBC=COUNT(*) 
--
--                         FROM 
--                             (
--                                   SELECT BC 
--                                     FROM ARTIKUJ A1 
--                                    WHERE NOT EXISTS ( SELECT BC FROM ARTIKUJBCSCR A2 WHERE A1.NRRENDOR=A2.NRD AND A1.BC=A2.BC)
--
--                                UNION ALL
--
--                                   SELECT BC FROM ARTIKUJBCSCR
--
--                               ) C
--
--                     GROUP BY BC 
--
--                    -- HAVING COUNT(*)=1 
--
--                      )   B    ON A.BC=B.BC
--
--       WHERE ISNULL(A.BC,'')=''    -- Me BC ne ARTIKULL
----     WHERE ISNULL(A.BC,'')='' AND ISNULL(B.BC,'')=''   -- Artikuj pa BC
--
--    ORDER BY A.KOD
--
----SELECT * FROM ARTIKUJBCSCR



-- Artikuj me BC me shume se nje here

     DECLARE @iTipTest    Int,
             @sKoment     Varchar(100),
             @sWhereArt   Varchar(Max),
             @sSql        Varchar(Max),
             @sWhere      Varchar(Max),
             @sListArt    Varchar(2000);

         SET @iTipTest  = @PTipTest;
         SET @sKoment   = @pKoment;
         SET @sWhereArt = @PWhereArt;



         SET @sSql      = '';
         SET @sListArt  = 'A.KOD,A.PERSHKRIM,A.NJESI,BCREF=ISNULL(A.BC,''''),KLASIF1=A.KLASIF,KLASIF2,KLASIF3,KLASIF4,KLASIF5,POZIC,D.LLOGINV,A.NRRENDOR,A.TROW,A.TAGNR,KOMENT='+QuoteName(@sKoment,'''');
          IF @sWhereArt<>''
             SET @sWhereArt = @sWhereArt + ' AND ';

          IF @iTipTest<=0
             BEGIN
               SET @sSql = '
                SELECT KOD='''' WHERE 1=2';            
             END;

          IF @iTipTest=1   -- Artikuj pa ARTIKUJ.BC
             BEGIN        
               SET @sSql = '
                SELECT '+@sListArt+'
                  FROM ARTIKUJ A LEFT JOIN SKEMELM D ON A.KODLM=D.KOD
                 WHERE '+@sWhereArt+' ISNULL(A.BC,'''')='''' 
              ORDER BY A.KOD ';
             END

          IF @iTipTest=2   -- Artikuj me ARTIKUJ.BC
             BEGIN
               SET @sSql = '
                SELECT '+@sListArt+'
                  FROM ARTIKUJ A LEFT JOIN SKEMELM D ON A.KODLM=D.KOD
                 WHERE '+@sWhereArt+' ISNULL(A.BC,'''')<>'''' 
              ORDER BY A.KOD ';
             END

          IF @iTipTest=3   -- Artikuj pa ARTIKUJBCSCR.BC
             BEGIN
               SET @sSql = '
                SELECT '+@sListArt+'
                  FROM ARTIKUJ A LEFT JOIN SKEMELM D ON A.KODLM=D.KOD
                 WHERE '+@sWhereArt+' (NOT EXISTS (SELECT BC FROM ARTIKUJBCSCR WHERE A1.NRD=A.NRRENDOR AND ISNULL(A1.BC,'''')<>'''')) 
              ORDER BY A.KOD ';
             END;

          IF @iTipTest=4   -- Artikuj me ARTIKUJBCSCR.BC
             BEGIN
               SET @sSql = '
                SELECT '+@sListArt+'
                  FROM ARTIKUJ A LEFT JOIN SKEMELM D ON A.KODLM=D.KOD
                 WHERE '+@sWhereArt+' (EXISTS (SELECT BC FROM ARTIKUJBCSCR WHERE A1.NRD=A.NRRENDOR AND ISNULL(A1.BC,'''')<>'''')) 
              ORDER BY A.KOD ';
             END

          IF @iTipTest=5   -- Artikuj me ARTIKUJ.BC dhe me ARTIKUJBCSCR.BC
             BEGIN
               SET @sSql = '
                SELECT '+@sListArt+'
                  FROM ARTIKUJ A LEFT JOIN SKEMELM D ON A.KODLM=D.KOD
                 WHERE '+@sWhereArt+' ISNULL(A.BC,'''')<>'''' AND    (EXISTS (SELECT BC FROM ARTIKUJBCSCR WHERE A1.NRD=A.NRRENDOR AND ISNULL(A1.BC,'''')<>'''')) 
              ORDER BY A.KOD ';
             END;

          IF @iTipTest=6   -- Artikuj me ARTIKUJ.BC dhe pa ARTIKUJBCSCR.BC
             BEGIN
               SET @sSql = '
                SELECT '+@sListArt+'
                  FROM ARTIKUJ A LEFT JOIN SKEMELM D ON A.KODLM=D.KOD
                 WHERE '+@sWhereArt+' ISNULL(A.BC,'''')<>'''' AND (NOT EXISTS (SELECT BC FROM ARTIKUJBCSCR A1 WHERE A1.NRD=A.NRRENDOR AND ISNULL(A1.BC,'''')<>'''')) 
              ORDER BY A.KOD ';
             END;

          IF @iTipTest=7   -- Artikuj pa ARTIKUJ.BC dhe pa ARTIKUJBCSCR.BC
             BEGIN
               SET @sSql = '
                SELECT '+@sListArt+'
                  FROM ARTIKUJ A LEFT JOIN SKEMELM D ON A.KODLM=D.KOD
                 WHERE '+@sWhereArt+' ISNULL(A.BC,'''')=''''  AND (NOT EXISTS (SELECT BC FROM ARTIKUJBCSCR A1 WHERE A1.NRD=A.NRRENDOR AND ISNULL(A1.BC,'''')<>'''')) 
              ORDER BY A.KOD ';
             END;

          IF @iTipTest=8   -- Artikuj pa ARTIKUJ.BC dhe me ARTIKUJBCSCR.BC
             BEGIN
               SET @sSql = '
                SELECT '+@sListArt+'
                  FROM ARTIKUJ A LEFT JOIN SKEMELM D ON A.KODLM=D.KOD
                 WHERE '+@sWhereArt+' ISNULL(A.BC,'''')=''''  AND     (EXISTS (SELECT BC FROM ARTIKUJBCSCR A1 WHERE A1.NRD=A.NRRENDOR AND ISNULL(A1.BC,'''')<>'''')) 
              ORDER BY A.KOD ';
             END;

          IF @iTipTest=9   -- Artikuj List + ArtikujBcScr
             BEGIN
               SET @sSql = '
                SELECT '+@sListArt+',BCMULTI=B.BC,PERSHKRIMBC=B.PERSHKRIM,B.MASE,B.NGJYRE
                  FROM ARTIKUJ A LEFT  JOIN SKEMELM D ON A.KODLM=D.KOD
                                 INNER JOIN ARTIKUJBCSCR B ON A.NRRENDOR=B.NRD
                 WHERE '+@sWhereArt+' ISNULL(A.BC,'''')=''''  AND     (EXISTS (SELECT BC FROM ARTIKUJBCSCR A1 WHERE A1.NRD=A.NRRENDOR AND ISNULL(A1.BC,'''')<>'''')) 
              ORDER BY A.KOD ';
             END;

          IF @sSql<>''
             BEGIN

               EXEC (@sSql);
               RETURN;

             END;


         SET @sWhere = '';

          IF @iTipTest=10  -- Artikuj me Bc doublikuar
             SET @sWhere = 'ISNULL(B.NRBC,0)>1';

          IF @iTipTest=11  -- Artikuj me Bc te rregull
             SET @sWhere = 'ISNULL(B.NRBC,0)=1';

          IF NOT (@iTipTest=10 OR @iTipTest=11)
             BEGIN

               SET @sSql = '
              SELECT KOD='''' WHERE 1=2'

             END

          ELSE
             BEGIN

               SET @sSql = '
              SELECT '+@sListArt+',
                     BCMULTI=B.BC,B.NRBC,PERSHKRIMBC='''',MASE='''',NGJYRE='''',PERIMETER='''',
                     REF=''R''
                FROM ARTIKUJ A INNER JOIN #TEMPBC B ON A.BC=B.BC 
                               LEFT  JOIN SKEMELM D ON A.KODLM=D.KOD
               WHERE '+@sWhereArt+' 1=1
 
           UNION ALL

              SELECT '+@sListArt+',
                     BCMULTI=B.BC,B.NRBC,PERSHKRIMBC=A1.PERSHKRIM,A1.MASE,A1.NGJYRE,A1.PERIMETER,
                     REF=''M'' 
                FROM ARTIKUJ A INNER JOIN ARTIKUJBCSCR A1 ON A.NRRENDOR=A1.NRD
                               INNER JOIN #TEMPBC B ON A1.BC=B.BC 
                               LEFT  JOIN SKEMELM D ON A.KODLM=D.KOD
               WHERE '+@sWhereArt+' 1=1

            ORDER BY A.KOD ';

                IF @sWhere<>''
                   SET @sSql = Replace(@sSql,'1=1',@sWhere)

             END;



          IF @iTipTest=10 OR @iTipTest=11
             BEGIN

                     IF OBJECT_ID('TEMPDB..#TEMPBC') IS NOT NULL
                        DROP TABLE #TEMPBC;

                 SELECT BC,NRBC=COUNT(*) 

                   INTO #TEMPBC

                   FROM 
                  (
                        SELECT BC 
                          FROM ARTIKUJ A1 
                         WHERE NOT EXISTS ( SELECT BC FROM ARTIKUJBCSCR A2 WHERE A1.NRRENDOR=A2.NRD AND A1.BC=A2.BC)

                     UNION ALL

                        SELECT BC FROM ARTIKUJBCSCR

                   ) C

               GROUP BY BC 

             END;


        EXEC (@sSql);

     PRINT  @sSql



GO
