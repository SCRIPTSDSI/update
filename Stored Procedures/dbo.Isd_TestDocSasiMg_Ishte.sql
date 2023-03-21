SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--        Exec dbo.Isd_TestDocSasiMg 'PG1','31/12/2015',355716,0,'FJ','#12345678','ADMIN','1234567890'

CREATE Procedure [dbo].[Isd_TestDocSasiMg_Ishte]
(
  @PKMag          Varchar(30),
  @PDateDok       Varchar(20),
  @PNrRendor      Int,
  @PNrRendDMg     Int,
  @PTableDoc      Varchar(40),
  @PTableTmp      Varchar(40),
  @PPerdorues     Varchar(30),
  @PLgJob         Varchar(30)
 )

As




         Set NoCount On


     Declare @KMag               Varchar(30),
          -- @DateDok            DateTime,      -- Te shfrytezohet ne se duhet test me date dokumenti
             @sDateDok           Varchar(100),
             @NrRendor           BigInt,
             @sTableDoc          Varchar(30),
             @sTableTmp          Varchar(30),
             @sTableName         Varchar(30),
             @sNrRendDMg         Varchar(30),
             @NrRendorMgH        Int,
             @NrRendorMgD        Int,
             @sNrRendor          Varchar(30),
             @sWhereFh           Varchar(100),
             @sWhereFd           Varchar(100),
             @TestSasiLimit      Int,
             @sSql               Varchar(Max);
  
         Set @KMag             = @PKMag;
      -- Set @DateDok          = dbo.DateValue(@PDateDok);
         Set @NrRendor         = @PNrRendor;  
         Set @sTableDoc        = @PTableDoc;
         Set @sTableTmp        = @PTableTmp;
         Set @sNrRendor        = Cast(Cast(@NrRendor As BigInt) As Varchar(30));
         Set @sNrRendDMg       = Cast(Cast(IsNull(@PNrRendDMg,0) As BigInt) As Varchar(30));
         Set @sWhereFh         = '';
         Set @sWhereFd         = '';
         Set @sSql             = '';
         Set @sTableName       = @sTableTmp;
         Set @sDateDok         = '';
          if IsNull(@pDateDok,'')<>''
             Set @sDateDok     = @pDateDok
          else
             Set @sDateDok     = '31.12.2030';
         

           
          if @sTableDoc='FH' Or @sTableDoc='FD'
             Set @sNrRendDMg   = @sNrRendor;

         SET @NrRendorMgH      = CASE WHEN CHARINDEX(','+@sTableDoc+',',',FH,FF,')>0 THEN @sNrRendDMg ELSE 0           END;
         SET @NrRendorMgD      = CASE WHEN CHARINDEX(','+@sTableDoc+',',',FH,FF,')>0 THEN 0           ELSE @sNrRendDMg END;


          if @sTableTmp=''
             begin
               Set @sTableName = @sTableDoc+'Scr';
             end;

          if IsNull(@PNrRendor,0)>0 And CharIndex(','+@PTableDoc+',',',FJ,FJT,ORK,OFK,SM,FF,ORF,FD,FH,')=0 
             begin
               RaisError (N'  Kujdes. Gabim parametra :   NrRendor = %s, TableDok = ''%s''', 0, 1,@sNrRendor,@sTableDoc) With NoWait
               SELECT KARTLLG='', GJENDJE=0, NRD=0
               Return;
             end

          if IsNull(@NrRendor,0)<=0 And IsNull(@sTableTmp,'')='' 
             begin
               RaisError (N'  Kujdes. Gabim parametra :   NrRendor = %s, TableTmp = ''%s''', 0, 1,@sNrRendor,@sTableTmp) With NoWait
               SELECT KARTLLG='', GJENDJE=0, NRD=0
               Return;
             end;

          if IsNull(@NrRendor,0)<=0 And IsNull(@sTableTmp,'')<>'' And (dbo.Isd_TableExists(@sTableTmp)=0)
             begin
               RaisError (N'  Kujdes. Gabim parametra :   TableTmp = ''%s'' e panjohur', 0, 1,@sTableTmp) With NoWait
               SELECT KARTLLG='', GJENDJE=0, NRD=0
               Return;
             end;


          if @sTableDoc='FH' Or @sTableDoc='FF'
             Set @sWhereFh = ' AND B.NRD<>'+@sNrRendDMg;

          if @sTableDoc='FD' Or @sTableDoc='FJ'
             Set @sWhereFd = ' AND B.NRD<>'+@sNrRendDMg;


      Select @TestSasiLimit=IsNull(TESTSASIGJLIM,0) From ConfigMg;


          if Object_Id('TempDb..#TmpSasiLim') is not null
             Drop Table #TmpSasiLim;
             
          if Object_Id('TempDb..#TmpArtikuj') is not null
             Drop Table #TmpArtikuj;

      Select KOD, SASILIM=Cast(0.00 As Float)
        Into #TmpSasiLim
        From ARTIKUJ
       Where 1=2;


      Select KARTLLG = KOD
        Into #TmpArtikuj
        From ARTIKUJ
       Where 1=2;
       
       EXEC ('INSERT INTO #TmpArtikuj
                    (KARTLLG)
              SELECT KARTLLG FROM '+@sTableName+' GROUP BY KARTLLG ORDER BY KARTLLG; ');

      --SELECT * FROM #TmpArtikuj;
      
      

          if @TestSasiLimit=1   -- Limitet e sasive sipas magazinave ose tek artikujt.
             begin


               Set @sSql = '


--     Krijimi i Temp me SasiLimite

      INSERT INTO #TMPSASILIM
            (KOD,SASILIM)

      SELECT A.KARTLLG, SASILIM=ROUND(MAX(ISNULL(B.SASI,0)),3)

        FROM '+@sTableName+' A LEFT JOIN

             (
                SELECT KARTLLG=R1.KOD, SASI=CASE WHEN ISNULL(R2.SASI,0)=0 THEN R1.MINI ELSE ISNULL(R2.SASI,0) END
                  FROM ARTIKUJ R1 LEFT JOIN 
                    (
                       SELECT KARTLLG=B.KOD, SASI=SUM(ISNULL(B.SASIMIN,0))
                         FROM ARTIKUJKFSCR B INNER JOIN ARTIKUJKF A ON B.NRD=A.NRRENDOR
                        WHERE A.KMAG='''+@KMag+'''
                     GROUP BY B.KOD
                       HAVING SUM(ISNULL(SASIMIN,0))<>0

                       )      R2   ON  R1.KOD = R2.KARTLLG


                )  B    ON   A.KARTLLG=B.KARTLLG


       WHERE 1=1 AND 2=2 AND ISNULL(A.SASI,0)<>0
    GROUP BY A.KARTLLG
      HAVING ( (CHARINDEX('','+@sTableDoc+','','',FH,FF,OFF,'')           >0 AND SUM(ISNULL(A.SASI,0))<0) OR 
               (CHARINDEX('','+@sTableDoc+','','',FD,FJ,FJT,ORK,OFK,SM,'')>0 AND SUM(ISNULL(A.SASI,0))>0) ) 

-- Perjashto testin ne se SUM(SASI) nuk eshte <>0 dhe sipas rastit te dokumentit (Shiko Having)


    ORDER BY A.KARTLLG ';

             end;



         Set @sSql = @sSql + '



     DECLARE @sList1   Varchar(1000),
             @sList2   Varchar(1000);

         SET @sList1 = '''';
         SET @sList2 = '''';

      SELECT @sList1 = @sList1 + '','' + A.KARTLLG, 
             @sList2 = @sList2 + '',''+CAST(MAX(ISNULL(B.SASI,0)) - SUM(ISNULL(A.SASI,0)) - MAX(ISNULL(T.SASILIM,0)) As Varchar)
          -- A.KARTLLG, GJENDJE=MAX(ISNULL(B.SASI,0)) - SUM(ISNULL(A.SASI,0)) - MAX(ISNULL(T.SASILIM,0)), NRD=MAX(A.NRD)

        FROM '+@sTableName+' A LEFT JOIN

          (

             SELECT      KARTLLG, SASI=ROUND(SUM(ISNULL(SASI,0)),3)
               FROM

             (
                  SELECT B.KARTLLG, SASI=SUM(ISNULL(B.SASI,0)) 
                    FROM FHSCR B INNER JOIN FH          A ON B.NRD=A.NRRENDOR
                                 INNER JOIN #TmpArtikuj T ON B.KARTLLG=T.KARTLLG
                   WHERE KMAG='''+@KMag+''' AND A.DATEDOK<=dbo.DATEVALUE('''+@sDateDok+''') AND B.NRD<>'+CAST(CAST(@NrRendorMgH AS BIGINT) AS VARCHAR)+' -- AND (EXISTS (SELECT NRRENDOR FROM '+@sTableName+' T1 WHERE B.KARTLLG=T1.KARTLLG))
                GROUP BY B.KARTLLG
                  HAVING SUM(ISNULL(B.SASI,0))<>0

               UNION ALL

                  SELECT B.KARTLLG, SASI=SUM(0-ISNULL(B.SASI,0)) 
                    FROM FDSCR B INNER JOIN FD          A ON B.NRD=A.NRRENDOR
                                 INNER JOIN #TmpArtikuj T ON B.KARTLLG=T.KARTLLG
                   WHERE KMAG='''+@KMag+''' AND A.DATEDOK<=dbo.DATEVALUE('''+@sDateDok+''') AND B.NRD<>'+CAST(CAST(@NrRendorMgD AS BIGINT) AS VARCHAR)+' -- AND (EXISTS (SELECT NRRENDOR FROM '+@sTableName+' T1 WHERE B.KARTLLG=T1.KARTLLG))
                GROUP BY B.KARTLLG
                  HAVING SUM(0-ISNULL(B.SASI,0))<>0

               ) C

           GROUP BY KARTLLG
             HAVING ROUND(SUM(ISNULL(SASI,0)),3)<>0 


             )                           B ON   A.KARTLLG=B.KARTLLG
                   LEFT JOIN #TmpSasiLim T ON A.KARTLLG=T.KOD
                   
       WHERE 1=1 AND 2=2 AND ISNULL(A.SASI,0)<>0                               
    GROUP BY A.KARTLLG    -- Perjashto testin ne se SUM(SASI) nuk eshte <>0 dhe sipas rastit te dokumentit (Shiko Having)

      HAVING ( 
              (CHARINDEX('','+@sTableDoc+','','',FH,FF,OFF,'')           >0 AND SUM(ISNULL(A.SASI,0))<0) 
               OR 
              (CHARINDEX('','+@sTableDoc+','','',FD,FJ,FJT,ORK,OFK,SM,'')>0 AND SUM(ISNULL(A.SASI,0))>0) 
              ) 
               
               AND
             ( (MAX(ISNULL(B.SASI,0))-SUM(ISNULL(A.SASI,0))- MAX(ISNULL(T.SASILIM,0))) < 0 )

    ORDER BY A.KARTLLG;
 

          IF SUBSTRING(@sList1,1,1)='',''
             SET @sList1 = SUBSTRING(@sList1,2,LEN(@sList1));
          IF SUBSTRING(@sList2,1,1)='',''
             SET @sList2 = SUBSTRING(@sList2,2,LEN(@sList2));

      SELECT KARTLLG=@sList1, GJENDJE=@sList2, NRROWS=CASE WHEN LEN(@sList1)>0 THEN LEN(@sList1)-LEN(REPLACE(@sList1,'','',''''))+1 ELSE 0 END; ';



--        if @NrRendor<>0
--           begin
--             Set @sSql = Replace(@sSql,'1=1','A.NRD='+Cast(Cast(@NrRendor As BigInt) As Varchar(30)));
--           end;

          if Not (@sTableDoc='FH' Or @sTableDoc='FD')
             begin
               Set @sSql = Replace(@sSql,'2=2','A.TIPKLL=''K'''); 
             end;


       Print  @sSql;
        Exec (@sSql);

          if Object_Id('TempDb..#TmpSasiLim') is not null
             Drop Table #TmpSasiLim;
GO
