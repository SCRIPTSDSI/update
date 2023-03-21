SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--        EXEC dbo.Isd_DocSaveTestFields 'AQHISTORISCR',41,'M'

CREATE Procedure [dbo].[Isd_DocSaveTestFields]
(
  @PTableName     Varchar(50),
  @PNrRendor      Int,
  @PIDMStatus     Varchar(10)
 )

As

-- EXEC dbo.Isd_DocSaveTestFields 'FJ',  567796, 'M'
-- EXEC dbo.Isd_DocSaveTestFields 'FD',  618126, 'M'
-- EXEC dbo.Isd_DocSaveTestFields 'ARKA', 84702, 'M'
-- EXEC dbo.Isd_DocSaveTestFields 'FK',  419468, 'M'


-- Kujdes Kolaudimi per kontroll Scr i pjeses A. u be pasi me pare ishte pjesa B. 


         SET NoCount On

     DECLARE @NrRendor       Int,
             @IDMStatus      Varchar(10),
             @TableName      Varchar(30),
             @Sql            nVarchar(Max),
             @sMsg1          Varchar(100),
             @sMsg2          Varchar(100),
             @sMsg3          Varchar(100),
             @sMsg4          Varchar(100);

         SET @NrRendor     = @PNrRendor;
         SET @IDMStatus    = @PIDMStatus;
         SET @TableName    = @PTableName;


          IF CHARINDEX(','+@TableName+',',',DG,FJ,FF,FJT,ORF,ORK,OFK,SM,FH,FD,ARKA,BANKA,FK,FKST,VS,VSST,AQ,AQHISTORISCR,')<=0 Or @NrRendor<=0 Or @IDMStatus='' 
             RETURN;

         SET @sMsg1 = '  --  Fillim dokumenti :  '+@TableName;
         SET @sMsg2 = '  --         dokumenti :  '+@TableName;
         SET @sMsg3 = '  --         reshta    :  '+@TableName;
         SET @sMsg4 = '  --  Fund   dokumenti :  '+@TableName;


--       IF  @IDMStatus='M'     -- Gjithmone ....
--           BEGIN
               SET @Sql = ' 
                   UPDATE '+@TableName+' 
                      SET DATEEDIT=GETDATE() 
                    WHERE NRRENDOR='+CAST(CAST(@NrRendor As BigInt) As Varchar(30))+';';
               EXEC (@Sql);
--           END;

--           Test monedha e mbushur sakte ose jo, KodFKL, si dhe Test per NRMAG

          IF CHARINDEX(','+@TableName+',',',FJ,FF,FJT,ORF,ORK,OFK,SM,')>0 
             BEGIN

               SET @Sql = '

                  DECLARE @KodKF          Varchar(30),
                          @Kod            Varchar(60),
                          @KMon           Varchar(10),
                          @Kurs1          Float,
                          @Kurs2          Float,
                          @KMag           Varchar(30),
                          @NrMag          Int,
                          @NrRndMg        Int;

                   SELECT @KodKF        = KODFKL,
                          @Kod          = KOD,
                          @KMon         = KMON,
                          @Kurs1        = KURS1,
                          @Kurs2        = KURS2,  
                          @KMag         = KMAG,
                          @NrMag        = ISNULL(NRMAG,0)
                     FROM '+@TableName+'
                    WHERE NRRENDOR = '+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+'; 


                       IF @@RowCount = 0
                          RETURN;    


--   Krahesimi jep gabim kur  ka space ne fund te fushes ....!!!!, 
--   duhej me DATALENGTH function .... ??????????????????????????????



                   IF (dbo.Isd_SegmentsWithSpaces(@KMon)=1) Or 
                      (LTrim(RTrim(ISNULL(@KMon,'''')))='''' AND (@Kurs1<>1 Or @Kurs2<>1)) Or
                      (ISNULL(@Kurs1,0)<=0 Or ISNULL(@Kurs2,0)<=0)
                      BEGIN

                        PRINT  ''UPDATE dokumenti '+@TableName+' :   KMon, Kurse'';

                        UPDATE '+@TableName+'
                           SET KMON  = LTrim(RTrim(ISNULL(KMON,''''))),
                               KURS1 = CASE WHEN LTrim(RTrim(ISNULL(KMON,'''')))='''' AND (ISNULL(KURS1,0)<>1) Then 1
                                            WHEN ISNULL(KURS1,0)<=0                                            Then 1
                                            ELSE ISNULL(KURS1,1) 
                                       END,
                               KURS2 = CASE WHEN LTrim(RTrim(ISNULL(KMON,'''')))='''' AND (ISNULL(KURS2,0)<>1) Then 1
                                            WHEN ISNULL(KURS2,0)<=0                                            Then 1
                                            ELSE ISNULL(KURS2,1) 
                                       END
                         WHERE NRRENDOR='+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+';

                      END;

                   IF (dbo.Isd_SegmentsWithSpaces(@KodKF) = 1) Or 
                      (dbo.Isd_SegmentsWithSpaces(@Kod)   = 1) Or
                      (dbo.Isd_SegmentsTrim1(@Kod)<>dbo.Isd_SegmentsTrim1(@KodKF)+''.''+@KMon)
                      BEGIN
                        PRINT  ''UPDATE dokumenti '+@TableName+' :   Kod, KodFKL'';

                        UPDATE '+@TableName+'
                           SET KODFKL = LTrim(RTrim(ISNULL(KODFKL,''''))),
                               KOD    = LTrim(RTrim(ISNULL(KODFKL,'''')))+''.''+LTrim(RTrim(ISNULL(KMON,'''')))
                         WHERE NRRENDOR='+CAST(CAST(@NrRendor As BigInt) As Varchar(30))+';

                      END;


                   SELECT @NrRndMg = NRRENDOR 
                     FROM MAGAZINA 
                    WHERE KOD = LTrim(RTrim(ISNULL(@KMag,'''')));

                      IF (ISNULL(@NrMag,0)<>ISNULL(@NrRndMg,0)) Or (dbo.Isd_SegmentsWithSpaces(@KMag)=1)
                         BEGIN
                           PRINT ''UPDATE dokumenti '+@TableName+' :   KMag, NrMag'';

                          UPDATE '+@TableName+'
                             SET NRMAG = ISNULL(@NrRndMg,0),
                                 KMAG  = LTrim(RTrim(ISNULL(KMAG,'''')))
                           WHERE NRRENDOR='+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+';

                        END; ';

--             PRINT @Sql;
               PRINT @sMsg1;
               PRINT @sMsg2;
               EXEC (@Sql);
             END;

          IF CHARINDEX(','+@TableName+',',',FH,FD,')>0 
             BEGIN

               SET @Sql = '

                  DECLARE @KMagRF         Varchar(10),
                          @KMagLNK        Varchar(10),
                          @KMag           Varchar(30),
                          @NrMag          Int,
                          @NrRndMg        Int;

                   SELECT @KMagRF       = KMAGRF,
                          @KMagLNK      = KMAGLNK,
                          @KMag         = KMAG,
                          @NrMag        = ISNULL(NRMAG,0)
                     FROM '+@TableName+'
                    WHERE NRRENDOR = '+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+'; 


                       IF @@RowCount = 0
                          RETURN;
    

                   SELECT @NrRndMg = NRRENDOR 
                     FROM MAGAZINA 
                    WHERE KOD = LTrim(RTrim(ISNULL(@KMag,'''')));


                      IF (ISNULL(@NrMag,0) <>ISNULL(@NrRndMg,0))  Or
                         (dbo.Isd_SegmentsWithSpaces(@KMag)=1)    Or (dbo.Isd_SegmentsWithSpaces(@KMagRF)=1) Or
                         (dbo.Isd_SegmentsWithSpaces(@KMagLNK)=1)
                         BEGIN
                           PRINT ''UPDATE dokumenti '+@TableName+' :   KMag, NrMag, KMagRF, KMagLNK'';

                          UPDATE '+@TableName+'
                             SET NRMAG   = ISNULL(@NrRndMg,0),
                                 KMAG    = LTrim(RTrim(ISNULL(KMAG   ,''''))),
                                 KMAGRF  = LTrim(RTrim(ISNULL(KMAGRF ,''''))),
                                 KMAGLNK = LTrim(RTrim(ISNULL(KMAGLNK,'''')))
                           WHERE NRRENDOR='+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+';

                        END; ';

--             PRINT @Sql;
               PRINT @sMsg1;
               PRINT @sMsg2;
               EXEC (@Sql);
             END;
          

          IF CHARINDEX(','+@TableName+',',',ARKA,BANKA,')>0 
             BEGIN

               SET @Sql = '

                  DECLARE @KodAB          Varchar(30),
                          @Llogari        Varchar(60),
                          @KMon           Varchar(10),
                          @Kurs1          Float,
                          @Kurs2          Float,
                          @NrAB           Int,
                          @NrRndAB        Int;

                   SELECT @KodAB        = KODAB,
                          @LloGari      = LLOGARI,
                          @KMon         = KMON,
                          @Kurs1        = KURS1,
                          @Kurs2        = KURS2,  
                          @NrAB         = ISNULL(NRRENDORAB,0)
                     FROM '+@TableName+'
                    WHERE NRRENDOR = '+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+'; 


                       IF @@RowCount = 0
                          RETURN;


                   SELECT @NrRndAB = NRRENDOR 
                     FROM ARKAT
                    WHERE KOD = LTrim(RTrim(ISNULL(@KodAB,'''')));
  
                   IF (dbo.Isd_SegmentsWithSpaces(@KMon)=1) Or 
                      (LTrim(RTrim(ISNULL(@KMon,'''')))='''' AND (@Kurs1<>1 Or @Kurs2<>1)) Or
                      (ISNULL(@Kurs1,0)<=0 Or ISNULL(@Kurs2,0)<=0)

                      BEGIN
                        PRINT ''UPDATE dokumenti '+@TableName+' :   KMon, Kurse'';

                        UPDATE '+@TableName+'
                            SET KMON  = LTrim(RTrim(ISNULL(KMON,''''))),
                                KURS1 = CASE WHEN LTrim(RTrim(ISNULL(KMON,'''')))='''' AND (ISNULL(KURS1,0)<>1) Then 1
                                             WHEN ISNULL(KURS1,0)<=0                                            Then 1
                                             ELSE ISNULL(KURS1,1) 
                                        END,
                                KURS2 = CASE WHEN LTrim(RTrim(ISNULL(KMON,'''')))='''' AND (ISNULL(KURS2,0)<>1) Then 1
                                        WHEN ISNULL(KURS2,0)<=0                                                 Then 1
                                        ELSE ISNULL(KURS2,1) 
                                        END
                          WHERE NRRENDOR='+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+';

                      END;


                   IF (dbo.Isd_SegmentsWithSpaces(@KodAB)=1) Or (dbo.Isd_SegmentsWithSpaces(@Llogari)=1) Or
                      (ISNULL(@NrAB,0)<>ISNULL(@NrRndAB,0)) 

                      BEGIN
                        PRINT ''UPDATE dokumenti '+@TableName+' :   KodAB, Llogari'';

                        UPDATE '+@TableName+'
                           SET KODAB   = LTrim(RTrim(ISNULL(KODAB,''''))),
                               LLOGARI = LTrim(RTrim(ISNULL(LLOGARI,'''')))
                         WHERE NRRENDOR='+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+';

                      END;  ';

--             PRINT @Sql;
               PRINT @sMsg1;
               PRINT @sMsg2;
               EXEC (@Sql);

             END;

          IF CHARINDEX(','+@TableName+',',',FK,FKST,VS,VSST,AQ,')>0 
             BEGIN
               PRINT @sMsg1;
               PRINT @sMsg2;
               EXEC (@Sql);
             END;

--  RETURN;

--           A.

--           Test ne reshta dokumenti
--           Test monedha e mbushur sakte ose jo, Kod, KodAF, KartLlg, Llogari ne reshta

--           Me pare ishte pjesa B. e kesaj procedure 

          IF CHARINDEX(','+@TableName+',',',FJ,FF,FJT,ORF,ORK,OFK,SM,')>0 
             BEGIN

               SET @Sql = '

                       IF Object_Id(''TempDb..#TempScr'') is not null
                          Drop Table #TempScr;

                   SELECT B.NRRENDOR,
                          KODNEW       = dbo.Isd_SegmentsTrim2(B.KODAF,A.KMON,A.KMAG,B.TIPKLL,''KOD'',  '''+@TableName+'''),
                          KODAFNEW     = dbo.Isd_SegmentsTrim2(B.KODAF,A.KMON,A.KMAG,B.TIPKLL,''KODAF'','''+@TableName+'''),
                          KARTLLGNEW   = LTrim(RTrim(KARTLLG))
--                        B.KOD, B.KODAF, B.KARTLLG, B.TIPKLL, A.KMAG, A.KMON, B.NRD

                     Into #TempScr

                     FROM '+@TableName+' A Inner Join '+@TableName+'SCR B On A.NRRENDOR=B.NRD
                    WHERE (A.NRRENDOR='+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+') AND
                          (dbo.Isd_SegmentsWithSpaces(B.KOD)     = 1 Or
                           dbo.Isd_SegmentsWithSpaces(B.KODAF)   = 1 Or
                           dbo.Isd_SegmentsWithSpaces(B.KARTLLG) = 1 Or
                           dbo.Isd_SegmentsTrim1(B.KOD)  <>dbo.Isd_SegmentsTrim2(B.KODAF,A.KMON,A.KMAG,B.TIPKLL,''KOD'',  '''+@TableName+''') Or
                           dbo.Isd_SegmentsTrim1(B.KODAF)<>dbo.Isd_SegmentsTrim2(B.KODAF,A.KMON,A.KMAG,B.TIPKLL,''KODAF'','''+@TableName+'''))
                 Order By 1 


                   UPDATE A
                      SET A.KOD        = B.KODNEW,
                          A.KODAF      = B.KODAFNEW,
                          A.KARTLLG    = B.KARTLLGNEW
                     FROM '+@TableName+'Scr A Inner Join #TempScr B On A.NRRENDOR=B.NRRENDOR 


                       IF Object_Id(''TempDb..#TempScr'') is not null
                          Drop Table #TempScr; ';
                          
                          
                IF CHARINDEX(','+@TableName+',',',FF,')>0 

                   SET @Sql = @Sql + '

                   UPDATE B
                      SET CMIMREFERENCE = CASE WHEN ISNULL(B.CMIMREFERENCE,0)=0 THEN R.CMSH ELSE B.CMIMREFERENCE END,
                          CMSHREF       = CASE WHEN ISNULL(B.CMSHREF,0)=0       THEN R.CMSH ELSE B.CMSHREF       END
                     FROM '+@TableName+' A INNER JOIN '+@TableName+'SCR B On A.NRRENDOR=B.NRD
                                           INNER JOIN ARTIKUJ R ON B.KARTLLG=R.KOD
                    WHERE (A.NRRENDOR='+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+') AND (B.TIPKLL=''K'') AND
                          (ISNULL(B.CMIMREFERENCE,0)=0 OR ISNULL(B.CMSHREF,0)=0)   ';

            -- PRINT @Sql;
               EXEC (@Sql);

             END;



          IF CHARINDEX(','+@TableName+',',',FH,FD,')>0 
             BEGIN

               SET @Sql = '

                       IF Object_Id(''TempDb..#TempScr'') is not null
                          Drop Table #TempScr;


                   SELECT B.NRRENDOR,  
                          KODNEW       = dbo.Isd_SegmentsTrim2(B.KODAF,'''',A.KMAG,''K'',''KOD'',  '''+@TableName+'''),
                          KODAFNEW     = dbo.Isd_SegmentsTrim2(B.KODAF,'''',A.KMAG,''K'',''KODAF'','''+@TableName+'''),
                          KARTLLGNEW   = LTrim(RTrim(KARTLLG))
--                        B.KOD, B.KODAF, B.KARTLLG, TIPKLL=''K'', A.KMAG, KMON='''', B.NRD

                     Into #TempScr

                     FROM '+@TableName+' A Inner Join '+@TableName+'SCR B On A.NRRENDOR=B.NRD
                    WHERE (A.NRRENDOR='+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+') AND
                          (dbo.Isd_SegmentsWithSpaces(B.KOD)     = 1 Or
                           dbo.Isd_SegmentsWithSpaces(B.KODAF)   = 1 Or
                           dbo.Isd_SegmentsWithSpaces(B.KARTLLG) = 1 Or
                           dbo.Isd_SegmentsTrim1(B.KOD)  <>dbo.Isd_SegmentsTrim2(B.KODAF,'''',A.KMAG,''K'',''KOD'',  '''+@TableName+''') Or
                           dbo.Isd_SegmentsTrim1(B.KODAF)<>dbo.Isd_SegmentsTrim2(B.KODAF,'''',A.KMAG,''K'',''KODAF'','''+@TableName+'''))
                 Order By 1 


                   UPDATE A
                      SET A.KOD        = B.KODNEW,
                          A.KODAF      = B.KODAFNEW,
                          A.KARTLLG    = B.KARTLLGNEW
                     FROM '+@TableName+'Scr A Inner Join #TempScr B On A.NRRENDOR=B.NRRENDOR 


                       IF Object_Id(''TempDb..#TempScr'') is not null
                          Drop Table #TempScr; ';

--             PRINT @Sql;
               EXEC (@Sql);

             END;


          IF CHARINDEX(','+@TableName+',',',ARKA,BANKA,VS,VSST,')>0 
             BEGIN

               SET @Sql = '

                       IF Object_Id(''TempDb..#TempScr'') is not null
                          Drop Table #TempScr;


                   UPDATE '+@TableName+'SCR
                      SET TREGDK = CASE WHEN ISNULL(KR,0)<>0 Then ''K'' ELSE ''D'' END
                    WHERE (NRD='+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+') AND
                          ((ISNULL(TREGDK,'''')='''') Or (TREGDK=''D'' AND ABS(KR)>=0.01) Or (TREGDK=''K'' AND ABS(DB)>=0.01));
                          

                   SELECT B.NRRENDOR,  
                          KODNEW       = dbo.Isd_SegmentsTrim2(B.KODAF,B.KMON,'''',B.TIPKLL,''KOD'',  '''+@TableName+'''),
                          KODAFNEW     = dbo.Isd_SegmentsTrim2(B.KODAF,B.KMON,'''',B.TIPKLL,''KODAF'','''+@TableName+'''),
                          LLOGARIPKNEW = LTrim(RTrim(B.LLOGARIPK)),
                          LLOGARINEW   = LTrim(RTrim(B.LLOGARI))
--                        B.KOD, B.KODAF, B.LLOGARIPK, B.LLOGARI, B.TIPKLL, KMAG='''', B.KMON, B.NRD

                     Into #TempScr

                     FROM '+@TableName+' A Inner Join '+@TableName+'SCR B On A.NRRENDOR=B.NRD
                    WHERE (A.NRRENDOR='+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+') AND
                          (dbo.Isd_SegmentsWithSpaces(B.KOD)       = 1 Or 
                           dbo.Isd_SegmentsWithSpaces(B.KODAF)     = 1 Or 
                           dbo.Isd_SegmentsWithSpaces(B.LLOGARIPK) = 1 Or
                           dbo.Isd_SegmentsWithSpaces(B.LLOGARI)   = 1 Or
                           dbo.Isd_SegmentsTrim1(B.KOD)  <>dbo.Isd_SegmentsTrim2(B.KODAF,B.KMON,'''',B.TIPKLL,''KOD'',  '''+@TableName+''') Or
                           dbo.Isd_SegmentsTrim1(B.KODAF)<>dbo.Isd_SegmentsTrim2(B.KODAF,B.KMON,'''',B.TIPKLL,''KODAF'','''+@TableName+'''))


                   UPDATE A
                      SET A.KOD        = B.KODNEW,
                          A.KODAF      = B.KODAFNEW,
                          A.LLOGARIPK  = B.LLOGARIPKNEW,
                          A.LLOGARI    = B.LLOGARINEW
                     FROM '+@TableName+'Scr A Inner Join #TempScr B On A.NRRENDOR=B.NRRENDOR 


                       IF Object_Id(''TempDb..#TempScr'') is not null
                          Drop Table #TempScr; ';

--             PRINT @Sql;
               EXEC (@Sql);

             END;


          IF CHARINDEX(','+@TableName+',',',FK,FKST,')>0 
             BEGIN

               SET @Sql = '

                       IF Object_Id(''TempDb..#TempScr'') is not null
                          Drop Table #TempScr;


                   UPDATE '+@TableName+'SCR
                      SET TREGDK = CASE WHEN ISNULL(KR,0)<>0 Then ''K'' ELSE ''D'' END
                    WHERE (NRD='+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+') AND
                          ((ISNULL(TREGDK,'''')='''') Or (TREGDK=''D'' AND ABS(KR)>=0.01) Or (TREGDK=''K'' AND ABS(DB)>=0.01));


                   SELECT B.NRRENDOR,  
                          KODNEW       = CASE WHEN A.ORG=''T''
                                              Then dbo.Isd_SegmentsTrim2(B.LLOGARI, B.KMON,'''',''L'',''KOD'',  '''+@TableName+''')
                                              ELSE dbo.Isd_SegmentsTrim2(B.KOD,     B.KMON,'''',''L'',''KOD'',  '''+@TableName+''')
                                         END,
                          LLOGARINEW   = CASE WHEN A.ORG=''T''
                                              Then dbo.Isd_SegmentsTrim2(B.LLOGARI, B.KMON,'''',''L'',''KODAF'','''+@TableName+''')
                                              ELSE dbo.Isd_SegmentsTrim2(B.KOD,     B.KMON,'''',''L'',''KODAF'','''+@TableName+''')
                                         END,
                          LLOGARIPKNEW = LTrim(RTrim(B.LLOGARIPK))
--                        B.KOD, B.LLOGARI, B.LLOGARIPK, TIPKLL=''T'', KMAG='''', B.KMON, B.NRD, A.ORG

                     Into #TempScr

                     FROM '+@TableName+' A Inner Join '+@TableName+'SCR B On A.NRRENDOR=B.NRD
                    WHERE (A.NRRENDOR='+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+') AND
                          (dbo.Isd_SegmentsWithSpaces(B.KOD)       = 1 Or 
                           dbo.Isd_SegmentsWithSpaces(B.LLOGARI)   = 1 Or 
                           dbo.Isd_SegmentsWithSpaces(B.LLOGARIPK) = 1 Or
                           dbo.Isd_SegmentsTrim1(B.KOD)     <> CASE WHEN A.ORG=''T''
                                                                    Then dbo.Isd_SegmentsTrim2(B.LLOGARI, B.KMON,'''',''L'',''KOD'',  '''+@TableName+''')
                                                                    ELSE dbo.Isd_SegmentsTrim2(B.KOD,     B.KMON,'''',''L'',''KOD'',  '''+@TableName+''')
                                                               END     Or
                           dbo.Isd_SegmentsTrim1(B.LLOGARI) <> CASE WHEN A.ORG=''T''
                                                                    Then dbo.Isd_SegmentsTrim2(B.LLOGARI, B.KMON,'''',''L'',''KODAF'','''+@TableName+''')
                                                                    ELSE dbo.Isd_SegmentsTrim2(B.KOD,     B.KMON,'''',''L'',''KODAF'','''+@TableName+''')
                                                               END)
                 Order By 1 


                   UPDATE A
                      SET A.KOD        = B.KODNEW,
                          A.LLOGARIPK  = B.LLOGARIPKNEW,
                          A.LLOGARI    = B.LLOGARINEW
                     FROM '+@TableName+'Scr A Inner Join #TempScr B On A.NRRENDOR=B.NRRENDOR 


                       IF Object_Id(''TempDb..#TempScr'') is not null
                          Drop Table #TempScr; ';

--             PRINT @Sql;
               EXEC (@Sql);

             END;


          IF CHARINDEX(','+@TableName+',',',AQ,')>0 
             BEGIN

               SET @Sql = '

                       IF Object_Id(''TempDb..#TempScr'') is not null
                          Drop Table #TempScr;


                   SELECT B.NRRENDOR,  
                          KODNEW       = dbo.Isd_SegmentsTrim2(B.KODAF,'''',A.KMAG,''K'',''KOD'',  '''+@TableName+'''),
                          KODAFNEW     = dbo.Isd_SegmentsTrim2(B.KODAF,'''',A.KMAG,''K'',''KODAF'','''+@TableName+'''),
                          KARTLLGNEW   = LTrim(RTrim(KARTLLG))
--                        B.KOD, B.KODAF, B.KARTLLG, TIPKLL=''X'', A.KMAG, KMON='''', B.NRD

                     Into #TempScr

                     FROM '+@TableName+' A Inner Join '+@TableName+'SCR B On A.NRRENDOR=B.NRD
                    WHERE (A.NRRENDOR='+CAST(CAST(@NrRendor AS BIGINT) AS VARCHAR(30))+') AND
                          (dbo.Isd_SegmentsWithSpaces(B.KOD)     = 1 Or
                           dbo.Isd_SegmentsWithSpaces(B.KODAF)   = 1 Or
                           dbo.Isd_SegmentsWithSpaces(B.KARTLLG) = 1 Or
                           dbo.Isd_SegmentsTrim1(B.KOD)  <>dbo.Isd_SegmentsTrim2(B.KODAF,'''',A.KMAG,''K'',''KOD'',  '''+@TableName+''') Or
                           dbo.Isd_SegmentsTrim1(B.KODAF)<>dbo.Isd_SegmentsTrim2(B.KODAF,'''',A.KMAG,''K'',''KODAF'','''+@TableName+'''))
                 Order By 1; 


                   UPDATE A
                      SET A.KOD        = B.KODNEW,
                          A.KODAF      = B.KODAFNEW,
                          A.KARTLLG    = B.KARTLLGNEW
                     FROM '+@TableName+'Scr A Inner Join #TempScr B On A.NRRENDOR=B.NRRENDOR; 


                       IF Object_Id(''TempDb..#TempScr'') is not null
                          Drop Table #TempScr; ';

--             PRINT @Sql;
               EXEC (@Sql);

             END;
             

          IF CHARINDEX(','+@TableName+',',',AQHISTORISCR,')>0 
             BEGIN

               UPDATE A
                  SET A.KOD        = LTrim(RTrim(A.KARTLLG))+'...',
                      A.KODAF      = LTrim(RTrim(A.KARTLLG)),
                      A.KARTLLG    = LTrim(RTrim(A.KARTLLG)),                      
                      A.ORDERSCR   = B.ORDERSCR
                 FROM AQHistoriScr A INNER JOIN 
        
                    ( SELECT NRRENDOR,ORDERSCR=ROW_NUMBER() OVER(PARTITION BY KARTLLG ORDER BY DATEOPER,KODOPER) 
                        FROM AQHISTORISCR 
                       WHERE NRD=@NrRendor  
                       
                       ) B  ON A.NRRENDOR=B.NRRENDOR
                               
                WHERE A.NRD=@NrRendor; 
                       

             END;

--           fund per A.




-- U zevendesua me pjesen A.

--           B.

--           Ne se kolaudohet procedurat me siper par A. per Scr te perdoren ato A., per shpejtesi kemi keto me poshte B. 
--           Punon me Isd_SegmentsTrim1()

 


--         IF CHARINDEX(','+@TableName+',',',FJ,FF,FJT,ORF,ORK,OFK,SM,FH,FD,')>0 
--             BEGIN
--
--               SET @Sql = '
--
--                       IF not Exists( SELECT NRRENDOR 
--                                        FROM '+@TableName+' 
--                                       WHERE NRRENDOR = '+CAST(CAST(@NrRendor As BigInt) As Varchar(30))+')
--                          BEGIN
--                            RETURN;
--                          END;
--
--                       IF Object_Id(''TempDb..#TempScr'') is not null
--                          Drop Table #TempScr;
--
--                   SELECT B.NRRENDOR,
--                          KODNEW       = dbo.Isd_SegmentsTrim1(B.KOD),
--                          KODAFNEW     = dbo.Isd_SegmentsTrim1(B.KODAF),
--                          KARTLLGNEW   = LTrim(RTrim(KARTLLG))
--
--                     Into #TempScr
--
--                     FROM '+@TableName+' A Inner Join '+@TableName+'SCR B On A.NRRENDOR=B.NRD
--                    WHERE A.NRRENDOR='+CAST(CAST(@NrRendor As BigInt) As Varchar(30))+' AND
--                        ((dbo.Isd_SegmentsWithSpaces(B.KOD)     = 1) Or 
--                         (dbo.Isd_SegmentsWithSpaces(B.KODAF)   = 1) Or
--                         (dbo.Isd_SegmentsWithSpaces(B.KARTLLG) = 1))
--                 Order By 1
-- 
--                       IF @@RowCount>0
--                          PRINT ''UPDATE reshta :   KOD, KODAF, KARTLLG'';
--
--                   UPDATE A
--                      SET A.KOD        = B.KODNEW,
--                          A.KODAF      = B.KODAFNEW,
--                          A.KARTLLG    = B.KARTLLGNEW
--                     FROM '+@TableName+'Scr A Inner Join #TempScr B On A.NRRENDOR=B.NRRENDOR 
--
--                       IF Object_Id(''TempDb..#TempScr'') is not null
--                          Drop Table #TempScr; ';
--
--            -- PRINT @Sql;
--               EXEC (@Sql);
--               PRINT @sMsg3;
--               PRINT @sMsg4;
--             END;


--          IF CHARINDEX(','+@TableName+',',',ARKA,BANKA,VS,VSST,')>0 
--             BEGIN
--
--               SET @Sql = '
--
--                       IF not Exists( SELECT NRRENDOR 
--                                        FROM '+@TableName+' 
--                                       WHERE NRRENDOR = '+CAST(CAST(@NrRendor As BigInt) As Varchar(30))+')
--                          BEGIN
--                            RETURN;
--                          END;
--
--                       IF Object_Id(''TempDb..#TempScr'') is not null
--                          Drop Table #TempScr;
--
--                   SELECT B.NRRENDOR,  
--                          KODNEW       = dbo.Isd_SegmentsTrim1(B.KOD),
--                          KODAFNEW     = dbo.Isd_SegmentsTrim1(B.KODAF),
--                          LLOGARIPKNEW = LTrim(RTrim(B.LLOGARIPK)),
--                          LLOGARINEW   = LTrim(RTrim(B.LLOGARI))
--
--                     Into #TempScr
--
--                     FROM '+@TableName+' A Inner Join '+@TableName+'SCR B On A.NRRENDOR=B.NRD
--                    WHERE A.NRRENDOR='+CAST(CAST(@NrRendor As BigInt) As Varchar(30))+' AND
--                        ((dbo.Isd_SegmentsWithSpaces(B.KOD)       = 1) Or 
--                         (dbo.Isd_SegmentsWithSpaces(B.KODAF)     = 1) Or
--                         (dbo.Isd_SegmentsWithSpaces(B.LLOGARIPK) = 1))
--                 Order By 1; 
--
--                       IF @@RowCount>0
--                          PRINT ''UPDATE reshta :   KOD, KODAF, LLOGARI, LLOGARIPK'';
--
--                   UPDATE A
--                      SET A.KOD        = B.KODNEW,
--                          A.KODAF      = B.KODAFNEW,
--                          A.LLOGARIPK  = B.LLOGARIPKNEW,
--                          A.LLOGARI    = B.LLOGARINEW
--                     FROM '+@TableName+'Scr A Inner Join #TempScr B On A.NRRENDOR=B.NRRENDOR; 
--
--                       IF Object_Id(''TempDb..#TempScr'') is not null
--                          Drop Table #TempScr; ';
--
--            -- PRINT @Sql;
--               EXEC (@Sql);
--               PRINT @sMsg3;
--               PRINT @sMsg4;
--             END;


--          IF CHARINDEX(','+@TableName+',',',FK,FKST,')>0 
--             BEGIN
--
--               SET @Sql = '
--
--                       IF not Exists( SELECT NRRENDOR 
--                                        FROM '+@TableName+' 
--                                       WHERE NRRENDOR = '+CAST(CAST(@NrRendor As BigInt) As Varchar(30))+')
--                          BEGIN
--                            RETURN;
--                          END;
--
--                       IF Object_Id(''TempDb..#TempScr'') is not null
--                          Drop Table #TempScr;
--
--                   SELECT B.NRRENDOR,  
--                          KODNEW       = dbo.Isd_SegmentsTrim1(B.KOD),
--                          LLOGARINEW   = dbo.Isd_SegmentsTrim1(B.LLOGARI),
--                          LLOGARIPKNEW = LTrim(RTrim(B.LLOGARIPK))
--
--                     Into #TempScr
--
--                     FROM '+@TableName+' A Inner Join '+@TableName+'SCR B On A.NRRENDOR=B.NRD
--                    WHERE A.NRRENDOR='+CAST(CAST(@NrRendor As BigInt) As Varchar(30))+' AND
--                        ((dbo.Isd_SegmentsWithSpaces(B.KOD)       = 1) Or 
--                         (dbo.Isd_SegmentsWithSpaces(B.LLOGARI)   = 1) Or
--                         (dbo.Isd_SegmentsWithSpaces(B.LLOGARIPK) = 1))
--                 Order By 1; 
--
--                       IF @@RowCount>0
--                          PRINT ''UPDATE reshta :   KOD, LLOGARI, LLOGARIPK'';
--
--                   UPDATE A
--                      SET A.KOD        = B.KODNEW,
--                          A.LLOGARIPK  = B.LLOGARIPKNEW,
--                          A.LLOGARI    = B.LLOGARINEW
--                     FROM '+@TableName+'Scr A Inner Join #TempScr B On A.NRRENDOR=B.NRRENDOR 
--
--                       IF Object_Id(''TempDb..#TempScr'') is not null
--                          Drop Table #TempScr; ';
--
--            -- PRINT @Sql;
--               EXEC (@Sql);
--               PRINT @sMsg3;
--               PRINT @sMsg4;
--             END;

---- fund pjesa B.




GO
