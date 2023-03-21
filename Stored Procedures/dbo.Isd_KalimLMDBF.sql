SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE Procedure [dbo].[Isd_KalimLMDBF]
 (
  @PTip          Varchar(10),
  @PNrRendor     Int,                     -- Nuk Perdoret
  @PTableNameTmp Varchar(40)
  )

AS

         SET NOCOUNT ON

     DECLARE @TimeSt        DateTime,
             @TimeDi        Varchar(20),
             @TimeEn        Varchar(10),

             @DokName       Varchar(30),
             @Tip           Varchar(10),
             @TableTmp      Varchar(40),
             @TranNumber    Varchar(50),
             @IsMag         Bit,
             @i             Int,
           
             @RIdKp         BIGINT,
             @RIdKs         BIGINT,
             @RIdMax        BIGINT,
             @RIncNum       BIGINT,
             @RCount        BIGINT;

         SET @TimeSt      = GETDATE();
         SET @TimeDi      = CONVERT(Varchar(10),@TimeSt,108);
         SET @TranNumber  = dbo.Isd_RandomNumberChars(1);

         SET @Tip         = @PTip;
         SET @TableTmp    = @PTableNameTmp;
         SET @DokName     = '';
         SET @IsMag       = 0;
         SET @i           = CHARINDEX(@Tip,'ABEHDGFSX');


   RAISERROR (N'
x Faza 2 Procedura e kalimit te dokumentave ne te dhenat e nd/jes.        %s', 0, 1,@TimeDi) WITH NOWAIT;

       SET @DokName =dbo.Isd_StringInListStr('ARKA,BANKA,VS,FH,FD,DG,FF,FJ,AQ',@i,',');
       
       IF  @DokName=''
           RETURN;
           
           


       IF  CHARINDEX(@Tip,'HDFSX')>0 -- KUJDES u hoq F   -- CHARINDEX(@Tip,'HDFSX')>0

           BEGIN
           -- Mbush #FKSCR nga #FKSCR1 dhe punohet njesoj per te gjithe dokumentat e tjere me tabelen #FKSCR 
           -- #FKSCR1 vjen i mbushur nga FJ,FF,FH,FD,AQ
           -- SELECT * FROM #FKSCR1

           RAISERROR (N'x.1   1. Rregullim i Scr (vetem dokumenta me Magazine)', 0, 1) WITH NOWAIT  
               
			  UPDATE #FKSCR1      
			     SET SG1      = Dbo.Isd_SegmentFind(KOD,0,1),         
					 SG2      = Dbo.Isd_SegmentFind(KOD,0,2), 
					 SG3      = Dbo.Isd_SegmentFind(KOD,0,3), 
					 SG4      = KMAG,
					 SG5      = KMON,
                     FAKLS    = ISNULL(FAKLS,''), 
                     FADESTIN = ISNULL(FADESTIN,'') ,
                     FAART    = ISNULL(FAART,''),
					 LLOGARI  = LLOGARIPK;

           RAISERROR (N'x.1   2. Kalimi ne Scr standarte (vetem dokumenta me Magazine)', 0, 1) WITH NOWAIT


-- Kjo pjese u nda ne dy INSERT me 12.06.2020. (Ishte vetem INSERT i pare por pa WHERE)

 			  INSERT INTO #FKSCR                                            -- Jo reshtat me Ardhura/Shpenzime (ndoshta dhe Asete ose Sherbime) te cilat nuk kumulohen
			 	    (KOD,LLOGARI,LLOGARIPK,PERSHKRIM,                       -- Kjo mund te behet me konfigurim tek tabela e konfigurimeve 
                     KMON,KURS1,KURS2,TREGDK,DB,KR,DBKRMV,                  
                     KOMENT,ORDPOST,KMAG,MSGERROR,DSCERROR,TAGNR,
                     SG1,SG2,SG3,SG4,SG5,FADESTIN, FAART,KODREF,TIPKLLREF) 
  			  SELECT F01 = KOD, 
                     F02 = MAX(LLOGARI), 
                     F03 = MAX(LLOGARIPK), 
                     F04 = MAX(PERSHKRIM),
                     F05 = MAX(KMON),
                     F06 = MAX(KURS1),
                     F07 = MAX(KURS2),
                     F08 = TREGDK,
                     F09 = SUM(DB),
                     F10 = SUM(KR),
                     F11 = SUM(DBKRMV),
					 F12 = MAX(KOMENT),
                     F13 = ORDPOST, 
                     F14 = MAX(KMAG),
                     F15 = MAX(MSGERROR),  
                     F16 = MAX(DSCERROR),
                     F17 = TAGNR,
                     F18 = SG1,
                     F19 = SG2,
                     F20 = SG3,
                     F21 = SG4,
                     F22 = SG5,
                     F23 = FADESTIN, 
                     F24 = FAART,
                     F25 = MAX(ISNULL(KODREF,'')),
                     F26 = MAX(ISNULL(TIPKLLREF,''))
 			    FROM #FKSCR1 
 			   WHERE NOT ((@Tip='F' OR @Tip='S') AND TIPKLLREF='L')             -- 12.06.2020 u shtua WHERE, para kesaj date nuk kishte WHERE
		    GROUP BY TAGNR, KOD, TREGDK, ORDPOST, FADESTIN, FAART,SG1,SG2,SG3,SG4,SG5;
		  --GROUP BY TAGNR, KOD, TREGDK, ORDPOST, ISNULL(FADESTIN,''), ISNULL(FAART,''),SG1,SG2,SG3,SG4,SG5
		  --ORDER BY TAGNR,ORDPOST,TREGDK,MAX(LLOGARI),FADESTIN,FAART 

 			  INSERT INTO #FKSCR                                                -- Ky INSERT u shtua me 12.06.2020
			 	    (KOD,LLOGARI,LLOGARIPK,PERSHKRIM,
                     KMON,KURS1,KURS2,TREGDK,DB,KR,DBKRMV,
                     KOMENT,ORDPOST,KMAG,MSGERROR,DSCERROR,TAGNR,
                     SG1,SG2,SG3,SG4,SG5,FADESTIN, FAART,KODREF,TIPKLLREF) 
  			  SELECT F01 = KOD, 
                     F02 = LLOGARI, 
                     F03 = LLOGARIPK, 
                     F04 = PERSHKRIM,
                     F05 = KMON,
                     F06 = KURS1,
                     F07 = KURS2,
                     F08 = TREGDK,
                     F09 = DB,
                     F10 = KR,
                     F11 = DBKRMV,
					 F12 = KOMENT,
                     F13 = ORDPOST, 
                     F14 = KMAG,
                     F15 = MSGERROR,  
                     F16 = DSCERROR,
                     F17 = TAGNR,
                     F18 = SG1,
                     F19 = SG2,
                     F20 = SG3,
                     F21 = SG4,
                     F22 = SG5,
                     F23 = FADESTIN, 
                     F24 = FAART,
                     F25 = ISNULL(KODREF,''),
                     F26 = ISNULL(TIPKLLREF,'')
 			    FROM #FKSCR1 
 			   WHERE ((@Tip='F' OR @Tip='S') AND TIPKLLREF='L')  -- Reshtat me Ardhura/Shpenzime (ndoshta dhe Asete ose Sherbime)
		  --GROUP BY TAGNR, KOD, TREGDK, ORDPOST, ISNULL(FADESTIN,''), ISNULL(FAART,''),SG1,SG2,SG3,SG4,SG5
		  --GROUP BY TAGNR, KOD, TREGDK, ORDPOST, FADESTIN, FAART,SG1,SG2,SG3,SG4,SG5;

           END


       ELSE

           BEGIN
          -- #FKSCR e Mbushur nga Pjesa e Pare per keto Dokumenta

           RAISERROR (N'x.1      Rregullim i segmenteve ne Scr', 0, 1) WITH NOWAIT

		      UPDATE #FKSCR       
		 		 SET SG1 = Dbo.Isd_SegmentFind(KOD,0,1),         
				 	 SG2 = Dbo.Isd_SegmentFind(KOD,0,2), 
					 SG3 = Dbo.Isd_SegmentFind(KOD,0,3), 
					 SG4 = Dbo.Isd_SegmentFind(KOD,0,4),
					 SG5 = Dbo.Isd_SegmentFind(KOD,0,5) 
           END;
           
-- Punohet vetem me tabelen #FKSCR
-- Ndoshta mund te fshihet  #FKSCR1

 --SELECT * FROM #FKSCR1
 --SELECT * FROM #FKSCR



      CREATE NONCLUSTERED INDEX FK_TAGNR_Idx ON #FK(TAGNR);


   RAISERROR (N'x.2   1. Gjenerimi Errore dhe Llogarive te reja #LM', 0, 1) WITH NOWAIT;

      SELECT KOD       = ISNULL(KOD,''),
             PERSHKRIM = ISNULL(PERSHKRIM,''),
             KMON      = ISNULL(KMON,''),
             SG1       = ISNULL(SG1,''), SG2=ISNULL(SG2,''),SG3=ISNULL(SG3,''),SG4=ISNULL(SG4,''),SG5=ISNULL(SG5,'')
        INTO #LM 
        FROM LM 
       WHERE ISNULL(PERSHKRIM,'')<>'';

          IF CHARINDEX(@Tip,'HDFS')>0
             SET @IsMag = 1;



   RAISERROR (N'x.2   2. Gjenerimi Errore dhe Llogarive te reja #FKSCR rasti magazine', 0, 1) WITH NOWAIT;
 
      UPDATE #FKSCR 
         SET SG1       = ISNULL(SG1, ''), SG2  = ISNULL(SG2, ''),SG3=ISNULL(SG3, ''),SG4=ISNULL(KMAG,''),SG5=ISNULL(KMON,''), 
             KMAG      = ISNULL(KMAG,''), KMON = ISNULL(KMON,''),
             KOD       = CASE WHEN @IsMag=1 
                              THEN ISNULL(SG1, '')+'.'+ISNULL(SG2, '')+'.'+ISNULL(SG3, '')+'.'+ISNULL(SG4, '')+'.'+ISNULL(SG5, '')
                              ELSE KOD 
                         END, 
             LLOGARIPK = CASE WHEN @IsMag=1  THEN ISNULL(SG1, '')  ELSE LLOGARIPK END, 
             LLOGARI   = CASE WHEN @IsMag=1  THEN ISNULL(SG1, '')  ELSE LLOGARI   END;


-- RAISERROR (N'x.2   3. Gjenerimi Errore dhe Llogarive te reja #TESTLLG', 0, 1) WITH NOWAIT;

-- SELECT KOD       = REPLICATE('',60), 
--        MSGERROR  = REPLICATE('',250),DSCERROR=REPLICATE('',250),PERSHKRIM=REPLICATE('',250),
--	      RSG0      = REPLICATE('',60), 
--		  SG1       = REPLICATE('',60), SG2=REPLICATE('',60), SG3=REPLICATE('',60), SG4=REPLICATE('',60), SG5=REPLICATE('',60),
--		  E1        = REPLICATE('',250),E2 =REPLICATE('',250),E3 =REPLICATE('',250),E4 =REPLICATE('',250),E5 =REPLICATE('',250),
--        ORG       = REPLICATE('',10),
--		  TAGNR     = CAST(0 AS INT) 
--   INTO #TESTLLG
--  WHERE 1=2;

----          TRUNCATE TABLE #TESTLLG

-- RAISERROR (N'x.2   4. Gjenerimi Errore ne #TESTLLG', 0, 1) WITH NOWAIT;

--    INSERT INTO #TESTLLG 
--          (KOD,MSGERROR,DSCERROR,PERSHKRIM,RSG0,SG1,SG2,SG3,SG4,SG5,E1,E2,E3,E4,E5,ORG,TAGNR)
--    SELECT KOD       = SUBSTRING(KOD           +SPACE(60), 1,60), 
--           MSGERROR  = SUBSTRING(MAX(MSGERROR) +SPACE(250),1,250),
--           DSCERROR  = SUBSTRING(MAX(DSCERROR) +SPACE(250),1,250),
--           PERSHKRIM = SUBSTRING(MAX(PERSHKRIM)+SPACE(250),1,250),
--           RSG0      = KOD, 
--           SG1       = SUBSTRING(MAX(SG1)+SPACE(60),1,60),
--           SG2       = SUBSTRING(MAX(SG2)+SPACE(60),1,60),
--           SG3       = SUBSTRING(MAX(SG3)+SPACE(60),1,60),
--           SG4       = SUBSTRING(MAX(SG4)+SPACE(60),1,60),
--           SG5       = SUBSTRING(MAX(SG5)+SPACE(60),1,60),
--           E1        = SPACE(250),   E2 = SPACE(250), E3 = SPACE(250), E4 = SPACE(250), E5 = SPACE(250),
--           ORG       = SUBSTRING(@Tip+SPACE(10),1,10),
--           TAGNR     = CAST(0 AS INT) 
--      FROM #FKSCR 
--   GROUP BY KOD; 
                             
   RAISERROR (N'x.2   3. Gjenerimi Errore ne #TESTLLG', 0, 1) WITH NOWAIT;

      SELECT KOD       = SUBSTRING(KOD           +SPACE(60), 1,60), 
             MSGERROR  = SUBSTRING(MAX(MSGERROR) +SPACE(250),1,250),
             DSCERROR  = SUBSTRING(MAX(DSCERROR) +SPACE(250),1,250),
             PERSHKRIM = SUBSTRING(MAX(PERSHKRIM)+SPACE(250),1,250),
             RSG0      = KOD, 
             SG1       = SUBSTRING(MAX(SG1)+SPACE(60),1,60),
             SG2       = SUBSTRING(MAX(SG2)+SPACE(60),1,60),
             SG3       = SUBSTRING(MAX(SG3)+SPACE(60),1,60),
             SG4       = SUBSTRING(MAX(SG4)+SPACE(60),1,60),
             SG5       = SUBSTRING(MAX(SG5)+SPACE(60),1,60),
             E1        = SPACE(250), E2=SPACE(250), E3 = SPACE(250), E4 = SPACE(250), E5 = SPACE(250),
             ORG       = SUBSTRING(@Tip+SPACE(10),1,10),
             TAGNR     = CAST(0 AS INT) 
        INTO #TESTLLG       
        FROM #FKSCR 
     GROUP BY KOD; 
     

   RAISERROR (N'x.2   4. Gjenerimi Errore ne #TESTLLG', 0, 1) WITH NOWAIT;

      UPDATE A         --	Ndertimi i tabelse se Erroreve
         SET E1 = CASE WHEN ISNULL(B.KOD,'')=''           THEN 'E1' ELSE '' END,  
             E2 = CASE WHEN A.SG2=''
                       THEN ''
                       ELSE CASE WHEN ISNULL(C.KOD,'')='' THEN 'E2' ELSE '' END 
                  END,
             E3 = CASE WHEN A.SG3=''
                       THEN ''
                       ELSE CASE WHEN ISNULL(D.KOD,'')='' THEN 'E3' ELSE '' END 
                  END,
             E4 = CASE WHEN A.SG4=''
                       THEN '' 
                       ELSE CASE WHEN ISNULL(E.KOD,'')='' THEN 'E4' ELSE '' END 
                  END,
             E5 = CASE WHEN A.SG5=''
                       THEN ''
                       ELSE CASE WHEN ISNULL(F.KOD,'')='' THEN 'E5' ELSE '' END 
                  END 
        FROM #TESTLLG  A  LEFT JOIN LLOGARI     B ON A.SG1 = B.KOD 
                          LEFT JOIN DEPARTAMENT C ON A.SG2 = C.KOD 
                          LEFT JOIN LISTE       D ON A.SG3 = D.KOD 
                          LEFT JOIN MAGAZINA    E ON A.SG4 = E.KOD 
                          LEFT JOIN MONEDHA     F ON A.SG5 = F.KOD; 




   RAISERROR (N'x.2   5. Fshihen FK dhe FKSCR me Errore', 0, 1) WITH NOWAIT;


--                                                              5.1 Te gjitha FK me KOD jo te rregullt

          IF OBJECT_ID('TEMPDB..#FKSCRError') IS NOT NULL
             DROP TABLE #FKSCRError;

      SELECT TAGNR INTO #FKSCRError
        FROM #FKSCR
       WHERE ISNULL(KOD,'')=''
    GROUP BY TAGNR
      HAVING COUNT(*)>0;

      DELETE A
        FROM #FKSCR A INNER JOIN #FKSCRError B ON A.TAGNR=B.TAGNR

          IF OBJECT_ID('TEMPDB..#FKSCRError') IS NOT NULL                       
             DROP TABLE #FKSCRError;                            -- Fund ndryshimi me 22.07.2017


--	                                                            5.2 Fshihen FK dhe FKSCR me Errore per segmentet
      DELETE A                   
        FROM #FKSCR A INNER JOIN #TESTLLG B ON A.KOD = B.KOD 
       WHERE B.E1<>'' OR B.E2<>'' OR B.E3<>'' OR B.E4<>'' OR B.E5<>'';

--                                                              5.3 Te gjithe kokat e dokumentave qe skane reshta                
      DELETE A
        FROM #FK A LEFT JOIN #FKSCR B ON A.TAGNR = B.TAGNR 
       WHERE ISNULL(B.TAGNR,0)=0;

              
--            Ndertimi i tabeles se erroreve, qe sherben per te afishuar gabimet nga brenda programit :
   RAISERROR (N'x.2   6. Afishimi i Erroreve', 0, 1) WITH NOWAIT;
   
        EXEC ('
                USE TempDB   

                 IF NOT EXISTS (SELECT Name FROM Sys.Tables WHERE OBJECT_ID=OBJECT_ID('''+@TableTmp+'''))
                    SELECT * INTO '+@TableTmp+' FROM #TESTLLG  WHERE 1=2

             INSERT INTO '+@TableTmp+'
                   (KOD,MSGERROR,DSCERROR,PERSHKRIM,RSG0,SG1,SG2,SG3,SG4,SG5,E1,E2,E3,E4,E5,ORG,TAGNR) 
                   
             SELECT KOD,MSGERROR,DSCERROR,PERSHKRIM,RSG0,SG1,SG2,SG3,SG4,SG5,E1,E2,E3,E4,E5,ORG,TAGNR
               FROM #TESTLLG 
              WHERE (E1<>'''') OR (E2<>'''') OR (E3<>'''') OR (E4<>'''') OR (E5<>'''') ' );

      DELETE FROM #TESTLLG  WHERE E1<>'' OR E2<>'' OR E3<>'' OR E4<>'' OR E5<>'';


        --   Pjesa Trete e Testi-t per Kode

        --   Fshihen ne TESTLLG ato kode qe jane ne LM
        --   Mbeten vetem te Panjohurit qe do shtohen ne LM
        --   Pastaj Fshhihet LM ne TEMP dhe mbushet me Kodet e reja

      DELETE A FROM #TESTLLG A INNER JOIN #LM B ON A.KOD = B.KOD  WHERE A.KOD=B.KOD; 
                
    TRUNCATE TABLE #LM; 


   RAISERROR (N'x.2   7. Llogarite e reja ne LM', 0, 1) WITH NOWAIT;

      INSERT INTO #LM 
            (KOD,SG1,SG2,SG3,SG4,SG5,PERSHKRIM,KMON)  
      SELECT A.KOD, 
             SG1       = B.KOD,
             SG2       = ISNULL(C.KOD,''),
             SG3       = ISNULL(D.KOD,''),
             SG4       = ISNULL(E.KOD,''),
             SG5       = ISNULL(F.KOD,''),  
             PERSHKRIM = ISNULL(B.PERSHKRIM,'')                                                                    +  
                         CASE WHEN ISNULL(A.SG2,'')='' THEN '' ELSE '/' + LTRIM(RTRIM(ISNULL(C.PERSHKRIM,''))) END +
                         CASE WHEN ISNULL(A.SG3,'')='' THEN '' ELSE '/' + LTRIM(RTRIM(ISNULL(D.PERSHKRIM,''))) END +
                         CASE WHEN ISNULL(A.SG4,'')='' THEN '' ELSE '/' + LTRIM(RTRIM(ISNULL(E.PERSHKRIM,''))) END, 
             KMON      = A.SG5  
        FROM #TESTLLG A  LEFT JOIN LLOGARI     B ON A.SG1 = B.KOD  
                         LEFT JOIN DEPARTAMENT C ON A.SG2 = C.KOD  
                         LEFT JOIN LISTE       D ON A.SG3 = D.KOD  
                         LEFT JOIN MAGAZINA    E ON A.SG4 = E.KOD  
                         LEFT JOIN MONEDHA     F ON A.SG5 = F.KOD;  
 -- ORDER BY A.KOD;  


          -- Modifikim Emri sipas LM per te rejat

--    UPDATE A  
--       SET A.PERSHKRIM = LEFT(ISNULL(B.PERSHKRIM,''),100)  
--      FROM #FKSCR A INNER JOIN #LM B ON A.KOD=B.KOD;


   RAISERROR (N'x.2   8. Futja e Llogarive te reja ne LM', 0, 1) WITH NOWAIT;

      DELETE A  
        FROM LM A INNER JOIN #LM B ON A.KOD = B.KOD 
       WHERE ISNULL(A.PERSHKRIM,'')='' AND ISNULL(B.PERSHKRIM,'')<>''; 

      INSERT INTO LM 
            (KOD,SG1,SG2,SG3,SG4,SG5,PERSHKRIM,KMON) 
      SELECT KOD,SG1,SG2,SG3,SG4,SG5,PERSHKRIM,KMON 
        FROM #LM; 
 -- ORDER BY KOD;  


             --                Modifikim Emri sipas LM per te rejat
   RAISERROR (N'x.3      Modifikim pershkrimit ne Scr sipas LM per te rejat', 0, 1) WITH NOWAIT;

          IF CHARINDEX(@Tip,'ABE')>0
             BEGIN
               UPDATE A  
                  SET A.PERSHKRIM = LEFT(ISNULL(B.PERSHKRIM,''),100)  
                 FROM #FKSCR A INNER JOIN LM B ON A.KOD=B.KOD 
                WHERE ISNULL(A.PERSHKRIM,'')=''
             END  
          ELSE
             BEGIN
               UPDATE A  
                  SET A.PERSHKRIM = LEFT(ISNULL(B.PERSHKRIM,''),100)  
                 FROM #FKSCR A INNER JOIN LM B ON A.KOD=B.KOD 
             END;   


             --                Modifikimi i NRDOK nga FK origjinale


   RAISERROR (N'x.4      Gjenerimi NRDOK (me ndihmen e ID) ne #Fk', 0, 1) WITH NOWAIT;

       ALTER TABLE #FK DROP COLUMN NRRENDOR;
       ALTER TABLE #FK ADD         NRRENDOR INT IDENTITY(1,1) NOT NULL;

/*   DECLARE @FKNumbers TABLE
          (  VITI   INT,
             NRMAX  BIGINT );
  
      INSERT @FKNumbers (VITI, NRMAX)       
      SELECT YEAR(DATEDOK),MAX(NRDOK) 
        FROM FK 
    GROUP BY YEAR(DATEDOK);  
                
      UPDATE A  
         SET A.NRDOK = A.NRRENDOR + B.NRMAX  
        FROM #FK A INNER JOIN @FKNumbers B ON YEAR(A.DATEDOK)=B.VITI; */
                

      UPDATE A  
         SET A.NRDOK = A.NRRENDOR + B.NRMAX  
        FROM #FK A INNER JOIN (
         
                          SELECT VITI=YEAR(DATEDOK), NRMAX=MAX(NRDOK) 
                            FROM FK 
                        GROUP BY YEAR(DATEDOK) ) B 
                        
                                 ON YEAR(A.DATEDOK)=B.VITI;         

      UPDATE FK  SET TAGNR=0  WHERE ORG=@Tip AND (ISNULL(TAGNR,0)<>0);






   RAISERROR (N'x.5      Insertimi ne FK te te dhenave', 0, 1) WITH NOWAIT;


         SET  @RIdKp   = ISNULL((SELECT MIN(NRRENDOR) FROM #FK),0);
         SET  @RIdMax  = ISNULL((SELECT MAX(NRRENDOR) FROM #FK),0);
         SET  @RCount  = ISNULL((SELECT COUNT(*)      FROM #FK),0);
         SET  @RIncNum = 9999;

          IF  @RCount<=@RIncNum
              SET @RIncNum = @RIdMax;
              

    WHILE @RIdKp <= @RIdMax     -- (@@ROWCOUNT > 0) AND 

      BEGIN

            SET @RIdKs = @RIdKp + @RIncNum;

              INSERT INTO FK 
                    (KODNENDITAR, NRDOK, DATEDOK, PERSHKRIM1, PERSHKRIM2, 
                     KMON, KURS1, KURS2, TIPDOK, NUMDOK, REFERDOK, KMAG, FORMAT, 
                     KLASIFIKIM, ORG, DST,FIRSTDOK, NRDFK, POSTIM, LETER, USI, USM, TROW, TAGNR,TRANNUMBER ) 
              SELECT KODNENDITAR, NRDOK, DATEDOK, PERSHKRIM1, PERSHKRIM2, 
                     KMON, KURS1, KURS2, TIPDOK, NUMDOK, REFERDOK, KMAG, FORMAT, 
                     KLASIFIKIM, ORG, DST,FIRSTDOK, NRRENDOR, POSTIM, LETER, USI, USM, TROW, TAGNR,@TranNumber
                FROM #FK 
               WHERE NRRENDOR>=@RIdKp AND NRRENDOR<=@RIdKs;

            RAISERROR (N'', 0, 1) WITH NOWAIT;

            SET @RIdKp = @RIdKs + 1;

             IF @RIdKp > @RIdMax     -- (@@ROWCOUNT = 0) OR 
                BEGIN
                  BREAK
                END

             ELSE

                BEGIN
                  CONTINUE;
                END

                     
      END;
      
      
      
      
            --  Modifikimi i NRDFK ne Dokumentin Origjinal (ne ARKA,BANKA,VS,FH,FD,FJ,FF,DG etj.)

   RAISERROR (N'x.6      Lidhja e dokumentave %s me FK e krijuar', 0, 1, @DokName) WITH NOWAIT;

        EXEC ('
              UPDATE A 
                 SET A.NRDFK=B.NRRENDOR 
                FROM '+@DokName+' A INNER JOIN FK B ON A.NRRENDOR=B.TAGNR AND B.TRANNUMBER='''+@TranNumber+''' 
               WHERE B.ORG='''+@Tip+''' AND  ISNULL(B.TAGNR,0)<>0 ' );




   RAISERROR (N'x.7      Insertimi ne FKSCR te te dhenave', 0, 1) WITH NOWAIT;


         SET @RIdKp   = ISNULL((SELECT MIN(NRRENDOR) FROM #FKSCR),0);
         SET @RIdMax  = ISNULL((SELECT MAX(NRRENDOR) FROM #FKSCR),0);
         SET @RCount  = ISNULL((SELECT COUNT(*)      FROM #FKSCR),0);
         SET @RIncNum = 9999;

          IF @RCount<=@RIncNum
             SET @RIncNum = @RIdMax;

    WHILE @RIdKp <= @RIdMax     

      BEGIN

            SET @RIdKs = @RIdKp + @RIncNum;

              INSERT INTO FKSCR 
                    (NRD, KOD, LLOGARI, LLOGARIPK, PERSHKRIM, KOMENT,KODREF,TIPKLLREF, 
                     KMON, KURS1, KURS2, DB, KR, DBKRMV, TREGDK, 
                     FAKLS, FADESTIN, FAART, 
                     ORDPOST, ORDERSCR, TAG, TAGNR, TROW)
              SELECT B.NRRENDOR, A.KOD, A.LLOGARI, A.LLOGARIPK, A.PERSHKRIM, A.KOMENT,A.KODREF,A.TIPKLLREF, 
                     A.KMON, A.KURS1, A.KURS2, A.DB, A.KR, A.DBKRMV, A.TREGDK, 
                     A.FAKLS, A.FADESTIN, A.FAART, 
                     ISNULL(A.ORDPOST,0), ISNULL(A.ORDERSCR,0), A.TAG, 0, 0    -- A duhet Tip sepse ke @TranNumber
                FROM #FKSCR A INNER JOIN FK B ON A.TAGNR=B.TAGNR AND B.ORG=@Tip AND B.TRANNUMBER=@TranNumber 
               WHERE A.NRRENDOR>=@RIdKp AND A.NRRENDOR<=@RIdKs
            ORDER BY B.NRRENDOR,A.ORDPOST; 

            RAISERROR (N'', 0, 1) WITH NOWAIT;

            SET @RIdKp = @RIdKs + 1;

             IF @RIdKp > @RIdMax     -- (@@ROWCOUNT = 0) OR 
                BEGIN
                  Break
                END

             ELSE

                BEGIN
                  CONTINUE
                END

      END;



       PRINT 'x.8      Zerim TagNr ne FK';

      UPDATE FK  SET TAGNR=0  WHERE ORG=@Tip AND (ISNULL(TAGNR,0)<>0); 

        DROP INDEX FK_TAGNR_Idx ON #FK;



         SET @TimeDi = CONVERT(Varchar(10),DateAdd(Second,DATEDIFF(Second,@TimeSt,GETDATE()),'2001-01-01 00:00:00'),108);
         SET @TimeEn = CONVERT(Varchar(10),GETDATE(),108);

   RAISERROR (N'x Faza 2 Fund Procedura e kalimit te dokumentave ne te dhenat e nd/jes.   %s.   %s 
', 0, 1,@TimeEn,@TimeDi) WITH NOWAIT;
GO
