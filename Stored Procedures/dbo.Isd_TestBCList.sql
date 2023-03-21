SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE     procedure [dbo].[Isd_TestBCList]
(
  @pBcKp       Varchar(60),
  @pBcKs       Varchar(60),
  @pWhereArt   Varchar(Max),
  @pTipTest    Int
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



     DECLARE @sBCKp       Varchar(60),
             @sBCKs       Varchar(60),
             @iTipTest    Int,
             @sWhere1     Varchar(Max),
             @sWhere2     Varchar(Max),
             @sWhereArt   Varchar(Max),
             @sSql        Varchar(Max),
             @sListArt    Varchar(2000);

         SET @sBCKp     = @pBCKp;
         SET @sBCKs     = @pBCKs;
         SET @iTipTest  = @PTipTest;
         SET @sWhereArt = @PWhereArt;




         SET @sSql      = '';
         SET @sListArt  = 'A.KOD,A.PERSHKRIM,A.NJESI,BCREF=ISNULL(A.BC,''''),A.NRRENDOR,A.TROW,A.TAGNR';
--       SET @sListArt  = 'A.KOD,A.PERSHKRIM,A.NJESI,BCREF=ISNULL(A.BC,''''),KLASIF1=A.KLASIF,KLASIF2,KLASIF3,KLASIF4,KLASIF5,POZIC,D.LLOGINV,A.NRRENDOR,A.TROW,A.TAGNR';

         SET @sWhere1   = 'A.BC>='+QuoteName(@sBCKp,'''') +' AND A.BC<=' +QuoteName(@sBCKs,'''');
         SET @sWhere2   = 'A1.BC>='+QuoteName(@sBCKp,'''')+' AND A1.BC<='+QuoteName(@sBCKs,'''');
          IF @sWhereArt<>''
             BEGIN
               SET @sWhere1 = @sWhere1+' AND '+@sWhereArt;
               SET @sWhere2 = @sWhere2+' AND '+@sWhereArt;
             END;

         SET @sSql = '
              SELECT '+@sListArt+',
                     BCMULTI='''',PERSHKRIMBC='''',MASE='''',NGJYRE='''',PERIMETER='''',
                     REF=''R''
                FROM ARTIKUJ A LEFT  JOIN SKEMELM D ON A.KODLM=D.KOD
               WHERE '+@sWhere1+' AND 1=2
 
           UNION ALL

              SELECT '+@sListArt+',
                     BCMULTI=A1.BC,PERSHKRIMBC=A1.PERSHKRIM,A1.MASE,A1.NGJYRE,A1.PERIMETER,
                     REF=''M'' 
                FROM ARTIKUJ A INNER JOIN ARTIKUJBCSCR A1 ON A.NRRENDOR=A1.NRD
                               LEFT  JOIN SKEMELM D ON A.KODLM=D.KOD
               WHERE '+@sWhere2+' AND 2=3

            ORDER BY A.KOD ';


          IF @iTipTest<>2  -- ne listen Artikuj 
             SET @sSql = Replace(@sSql,'1=2','1=1');

          IF @iTipTest<>1  -- ne listen ArtikujBcScr
             SET @sSql = Replace(@sSql,'2=3','2=2');


        EXEC (@sSql);

     PRINT  @sSql



GO
