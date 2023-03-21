SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--        Exec dbo.Isd_TestDocSasiMg 'PG1','31/12/2015',355716,0,'FJ','#12345678','ADMIN','1234567890'

CREATE Procedure [dbo].[Isd_TestDocSasiMg_Old] 
(
  @pKMag          Varchar(30),
  @pDateDok       Varchar(20),
  @pNrRendor      Int,             
  @pNrRendDMg     Int,
  @pTableDoc      Varchar(40),
  @pTableTmp      Varchar(40),
  @pPerdorues     Varchar(30),
  @pLgJob         Varchar(30)
 )

AS


-- Kjo procedure ishte deri 18.02.2021 (Isd_TestDocSasiMg versioni fundit)



         SET NoCount On

     Declare @KMag               Varchar(30),
          -- @DateDok            DateTime,      -- Te shfrytezohet ne se duhet test me date dokumenti
             @sDateDok           Varchar(100),
             @NrRendor           BigInt,
             @sTableDoc          Varchar(30),
             @sTableTmp          Varchar(30),
             @sTableName         Varchar(30),
             @NrRendDMg          Int,
             @NrRendorMgH        Int,
             @NrRendorMgD        Int,
             @sNrRendor          Varchar(30),
             @TestSasiLimit      Int,
             @sSql               Varchar(Max);
  
         SET @KMag             = @pKMag;
      -- SET @DateDok          = dbo.DateValue(@pDateDok);
         SET @NrRendor         = @pNrRendor;  
         SET @sTableDoc        = @pTableDoc;
         SET @sTableTmp        = @pTableTmp;
         SET @sNrRendor        = CAST(CAST(@NrRendor AS BIGINT) AS Varchar(30));
         SET @sSql             = '';
         SET @sTableName       = @sTableTmp;
         SET @sDateDok         = '';

         
-- Ne se do qe data te mos jete pjese e algoritmit atehere mbaj @DateDok='31.12.2030' dhe gjithcka ok.

          IF ISNULL(@pDateDok,'')<>''
             SET @sDateDok     = @pDateDok
          ELSE
             SET @sDateDok     = '31.12.2030';
         


         SET @NrRendDMg        = @pNrRendDMg;
         
          IF @sTableDoc='FH' OR  @sTableDoc='FD'
             SET @NrRendDMg    = @pNrRendor;
             

         SET @NrRendorMgH      = CASE WHEN CHARINDEX(','+@sTableDoc+',',',FH,FF,')>0 THEN @NrRendDMg ELSE 0          END;
         SET @NrRendorMgD      = CASE WHEN CHARINDEX(','+@sTableDoc+',',',FH,FF,')>0 THEN 0          ELSE @NrRendDMg END;

          IF @sTableTmp=''
             BEGIN
               SET @sTableName = @sTableDoc+'Scr';
             END;

          IF ISNULL(@pNrRendor,0)>0 And CHARINDEX(','+@pTableDoc+',',',FJ,FJT,ORK,OFK,SM,FF,ORF,FD,FH,')=0 
             BEGIN
               RAISERROR (N'  Kujdes. Gabim parametra :   NrRendor = %s, TableDok = ''%s''', 0, 1,@sNrRendor,@sTableDoc) With NoWait
               SELECT KARTLLG='', GJENDJE=0, NRD=0
               RETURN;
             END

          IF ISNULL(@NrRendor,0)<=0 And ISNULL(@sTableTmp,'')='' 
             BEGIN
               RAISERROR (N'  Kujdes. Gabim parametra :   NrRendor = %s, TableTmp = ''%s''', 0, 1,@sNrRendor,@sTableTmp) With NoWait
               SELECT KARTLLG='', GJENDJE=0, NRD=0
               RETURN;
             END;

          IF ISNULL(@NrRendor,0)<=0 And ISNULL(@sTableTmp,'')<>'' And (dbo.Isd_TableExists(@sTableTmp)=0)
             BEGIN
               RAISERROR (N'  Kujdes. Gabim parametra :   TableTmp = ''%s'' e panjohur', 0, 1,@sTableTmp) With NoWait
               SELECT KARTLLG='', GJENDJE=0, NRD=0
               RETURN;
             END;


      SELECT @TestSasiLimit=ISNULL(TESTSASIGJLIM,0) From ConfigMg;


          IF OBJECT_ID('TempDb..#TmpSasiLimit') IS NOT NULL
             DROP TABLE #TmpSasiLimit;
             
          IF OBJECT_ID('TempDb..#TmpArtikuj')   IS NOT NULL
             DROP TABLE #TmpArtikuj;
             
          IF OBJECT_ID('TempDB..#TmpDokScr')    IS NOT NULL
             DROP TABLE #TmpDokScr; 

      SELECT KOD, SASILIM=CAST(0.00 AS Float)
        INTO #TmpSasiLimit
        FROM ARTIKUJ
       WHERE 1=2;

      SELECT KARTLLG = KOD
        INTO #TmpArtikuj
        FROM ARTIKUJ
       WHERE 1=2;
       
      SELECT KARTLLG,SASI 
        INTO #TmpDokScr
        FROM FJSCR 
       WHERE 1=2;
       
         SET @sSql = '
         
              INSERT INTO #TmpArtikuj
                    (KARTLLG)
              SELECT KARTLLG      FROM '+@sTableName+' GROUP BY KARTLLG ORDER BY KARTLLG; 
              
              INSERT INTO #TmpDokScr
                    (KARTLLG,SASI)
              SELECT KARTLLG,SASI FROM '+@sTableName+' WHERE 1=1;';
          IF NOT (@sTableDoc='FH' OR @sTableDoc='FD')
             SET @sSql = REPLACE(@sSql,'1=1','TIPKLL=''K''');

       EXEC  (@sSql);           --     PRINT  @sSql; SELECT * FROM #TmpArtikuj; SELECT * FROM #TmpDokScr
      
      
          IF @TestSasiLimit=1   -- Limitet e sasive sipas magazinave ose tek artikujt.  --     Krijimi i Temp me SasiLimite
             BEGIN

                  INSERT INTO #TmpSasiLimit
                        (KOD,SASILIM)

                  SELECT A.KARTLLG, SASILIM=ROUND(MAX(ISNULL(B.SASI,0)),3)

                    FROM #TmpDokScr A LEFT JOIN

                         (
                            SELECT KARTLLG=R1.KOD, SASI=CASE WHEN ISNULL(R2.SASI,0)=0 THEN R1.MINI ELSE ISNULL(R2.SASI,0) END
                              FROM ARTIKUJ R1 LEFT JOIN 
                                (
                                   SELECT KARTLLG=B.KOD, SASI=SUM(ISNULL(B.SASIMIN,0))
                                     FROM ARTIKUJKFSCR B INNER JOIN ARTIKUJKF A ON B.NRD=A.NRRENDOR
                                    WHERE A.KMAG=@KMag
                                 GROUP BY B.KOD
                                   HAVING SUM(ISNULL(SASIMIN,0))<>0

                                   )      R2   ON  R1.KOD = R2.KARTLLG


                            )  B    ON   A.KARTLLG=B.KARTLLG


                   WHERE 1=1 AND 2=2 AND ISNULL(A.SASI,0)<>0
                GROUP BY A.KARTLLG
                  HAVING ( (CHARINDEX(','+@sTableDoc+',',',FH,FF,OFF,')           >0 AND SUM(ISNULL(A.SASI,0))<0) OR 
                           (CHARINDEX(','+@sTableDoc+',',',FD,FJ,FJT,ORK,OFK,SM,')>0 AND SUM(ISNULL(A.SASI,0))>0) ) 

                      -- Perjashto testin ne se SUM(SASI) nuk eshte <>0 dhe sipas rastit te dokumentit (Shiko Having)

                ORDER BY A.KARTLLG 

             END;


     DECLARE @sList1   Varchar(1000),
             @sList2   Varchar(1000);

         SET @sList1 = '';
         SET @sList2 = '';

      SELECT @sList1 = @sList1 + ',' + A.KARTLLG, 
             @sList2 = @sList2 + ','+CAST(MAX(ISNULL(B.SASI,0)) - SUM(ISNULL(A.SASI,0)) - MAX(ISNULL(T.SASILIM,0)) AS Varchar)
          -- A.KARTLLG, GJENDJE=MAX(ISNULL(B.SASI,0)) - SUM(ISNULL(A.SASI,0)) - MAX(ISNULL(T.SASILIM,0)), NRD=MAX(A.NRD)

        FROM #TmpDokScr A LEFT JOIN

          (

             SELECT      KARTLLG, SASI=ROUND(SUM(ISNULL(SASI,0)),3)
               FROM

             (
                  SELECT B.KARTLLG, SASI=SUM(ISNULL(B.SASI,0)) 
                    FROM FHSCR B INNER JOIN FH          A ON B.NRD=A.NRRENDOR
                                 INNER JOIN #TmpArtikuj T ON B.KARTLLG=T.KARTLLG
                   WHERE KMAG=@KMag AND A.DATEDOK<=dbo.DATEVALUE(@sDateDok) AND B.NRD<>CAST(CAST(@NrRendorMgH AS BIGINT) AS VARCHAR) 
                GROUP BY B.KARTLLG                                       -- AND (EXISTS (SELECT NRRENDOR FROM #TmpDokScr T1 WHERE B.KARTLLG=T1.KARTLLG))
                  HAVING SUM(ISNULL(B.SASI,0))<>0

               UNION ALL

                  SELECT B.KARTLLG, SASI=SUM(0-ISNULL(B.SASI,0)) 
                    FROM FDSCR B INNER JOIN FD          A ON B.NRD=A.NRRENDOR
                                 INNER JOIN #TmpArtikuj T ON B.KARTLLG=T.KARTLLG
                   WHERE KMAG=@KMag AND A.DATEDOK<=dbo.DATEVALUE(@sDateDok) AND B.NRD<>CAST(CAST(@NrRendorMgD AS BIGINT) AS VARCHAR) 
                GROUP BY B.KARTLLG                                       -- AND (EXISTS (SELECT NRRENDOR FROM #TmpDokScr T1 WHERE B.KARTLLG=T1.KARTLLG))
                  HAVING SUM(0-ISNULL(B.SASI,0))<>0

               ) C

           GROUP BY KARTLLG
             HAVING ROUND(SUM(ISNULL(SASI,0)),3)<>0 


             )                             B ON   A.KARTLLG=B.KARTLLG
                   LEFT JOIN #TmpSasiLimit T ON A.KARTLLG=T.KOD
                   
       WHERE 1=1 AND 2=2 AND ISNULL(A.SASI,0)<>0                               
    GROUP BY A.KARTLLG             -- Perjashto testin ne se SUM(SASI) nuk eshte <>0 dhe sipas rastit te dokumentit (Shiko Having)

      HAVING ( 
              (CHARINDEX(','+@sTableDoc+',',',FH,FF,OFF,')           >0 AND SUM(ISNULL(A.SASI,0))<0) 
               OR 
              (CHARINDEX(','+@sTableDoc+',',',FD,FJ,FJT,ORK,OFK,SM,')>0 AND SUM(ISNULL(A.SASI,0))>0) 
              ) 
               AND
             ( (MAX(ISNULL(B.SASI,0))-SUM(ISNULL(A.SASI,0))- MAX(ISNULL(T.SASILIM,0))) < 0 )

    ORDER BY A.KARTLLG;
 

          IF SUBSTRING(@sList1,1,1)=','
             SET @sList1 = SUBSTRING(@sList1,2,LEN(@sList1));
          IF SUBSTRING(@sList2,1,1)=','
             SET @sList2 = SUBSTRING(@sList2,2,LEN(@sList2));

      SELECT KARTLLG=@sList1, GJENDJE=@sList2, NRROWS=CASE WHEN LEN(@sList1)>0 THEN LEN(@sList1)-LEN(REPLACE(@sList1,',',''))+1 ELSE 0 END; 



--        IF @NrRendor<>0
--           BEGIN
--             SET @sSql = Replace(@sSql,'1=1','A.NRD='+CAST(CAST(@NrRendor AS BIGINT) AS Varchar(30)));
--           END;

--        IF Not (@sTableDoc='FH' Or @sTableDoc='FD')
--           BEGIN
--             SET @sSql = Replace(@sSql,'2=2','A.TIPKLL=''K'''); 
--           END;

        EXEC (@sSql);

          IF OBJECT_ID('TempDb..#TmpSasiLimit') IS NOT NULL
             DROP TABLE #TmpSasiLimit;

          IF OBJECT_ID('TempDb..#TmpArtikuj')   IS NOT NULL
             DROP TABLE #TmpArtikuj;
             
          IF OBJECT_ID('TempDB..#TmpDokScr')    IS NOT NULL
             DROP TABLE #TmpDokScr; 
GO
