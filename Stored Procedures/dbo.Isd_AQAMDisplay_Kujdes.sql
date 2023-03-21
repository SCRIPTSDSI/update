SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






-- Kujdes: Ne proces dhe po kolaudohet tek JO20 tek 10.101.1.9    26.02.2021

-- Ndrysho deklarimin per vlerat numerike ne Decimal (jo Float)











CREATE        procedure [dbo].[Isd_AQAMDisplay_Kujdes]  -- Kolaudim me kufij per mbylljen e amortizimit: vlere minimale (jo fix 5%)
(                                               -- Per kufizimi 5% per mbylljen e amortizimit shiko Isd_AQAMDisplay_01
  @pDateEnd    Varchar(20),                      
  @pDateDok    Varchar(20),
  @pShenim1    Varchar(150),
  @pShenim2    Varchar(150),
  @pWhere      Varchar(Max),
  @pOper       Varchar(10),
  @pDepKart    Int,                 -- Kujdes ! shiko poshte tek shenimi:    -- New 19.04.2019
  @pListKart   Int,
  @pModelAM    Int,                 -- @pModelAM=0 - > Amortizimi modeli 1,    @pModelAM=1 - > Amortizimi modeli 2 (SKK=0,SNK=1)
  @pUser       Varchar(30),
  @pTableTmp   Varchar(30)
)

AS   -- EXEC dbo.Isd_AQAMDisplay '31/12/2022','31/12/2018','Amortizim vjetor','Amortizim makineri','R1.KOD=''AS000001''','D',0,0,0,'ADMIN','##AA';
   
   

         SET NOCOUNT ON

     DECLARE @sSql           nVarchar(Max),
             @sSql1          nVarchar(Max),
             @NrRendor       Int,
             @sWhere         Varchar(Max),
             @VleraAktiv     Float,
             @VleraAM        Float,
             @NrKartelaAM    Int,
             @Shenim1        Varchar(150),
             @Shenim2        Varchar(150),
             @sTableTmp      Varchar(30),
             @ModelAM        Int,
             @DateEnd        DateTime,
             @DateDok        DateTime;
             
         SET @DateEnd      = dbo.DATEVALUE(@pDateEnd);
         SET @DateDok      = dbo.DATEVALUE(@pDateDok);
         SET @Shenim1      = @pShenim1;
         SET @Shenim2      = @pShenim2;
         SET @sWhere       = @pWhere;
         SET @ModelAM      = ISNULL(@pModelAM,0);
         SET @sTableTmp    = @pTableTmp;

          IF OBJECT_ID('TEMPDB..#TempScr')       IS NOT NULL
             DROP TABLE #TempScr;
          IF OBJECT_ID('TEMPDB..#TempDtAM')      IS NOT NULL
             DROP TABLE #TempDtAM;
          IF OBJECT_ID('TEMPDB..#TempShitje')    IS NOT NULL
             DROP TABLE #TempShitje;
          IF OBJECT_ID('TEMPDB..#TempSistemim')  IS NOT NULL
             DROP TABLE #TempSistemim;
          IF OBJECT_ID('TEMPDB..#TempDates')     IS NOT NULL
             DROP TABLE #TempDates;
          IF OBJECT_ID('TEMPDB..#TempDates1')    IS NOT NULL
             DROP TABLE #TempDates1;
          IF OBJECT_ID('TEMPDB..#TempDates2')    IS NOT NULL
             DROP TABLE #TempDates2;
          IF OBJECT_ID('TEMPDB..#TempDates3X')   IS NOT NULL
             DROP TABLE #TempDates3X;
          IF OBJECT_ID('TEMPDB..#TempDates3Y')   IS NOT NULL
             DROP TABLE #TempDates3Y;
          IF OBJECT_ID('TEMPDB..#TempSeri')      IS NOT NULL
             DROP TABLE #TempSeri;
          IF OBJECT_ID('TempDB..#TempSeriX')     IS NOT NULL
             DROP TABLE #TempSeriX;
          IF OBJECT_ID('TEMPDB..#MonthNames')    IS NOT NULL
             DROP TABLE #MonthNames;
          IF OBJECT_ID('TEMPDB..#AQKategoriTmp') IS NOT NULL 
             DROP TABLE #AQKategoriTmp;
          IF OBJECT_ID('Tempdb..#MonthsTable')   IS NOT NULL  -- tabele e re pas dates 30.09.2020
             DROP TABLE #MonthsTable;

         


-- Tabele seri me date fillim dhe fund muaji

             
     DECLARE @DateSeriEnd     DateTime,
             @LastDate        DateTime,
             @Date            Datetime;
        
         SET @DateSeriEnd   = DATEADD(yy, 10,@DateEnd); -- Ndoshta datat te meren nga algoritmi me poshte si date min dhe date max
         SET @Date          = DATEADD(yy,-20,@DateEnd);
         
      SELECT [Year]         = 0,          
             [Month]        = 0,
             [FirstDate]    = GetDate(),
             [LastDate]     = GetDate()
        INTO #MonthsTable     
       WHERE 1=2;


          IF DATEPART(dd,@Date) <> 1
             SELECT @Date = DATEADD(d, 0, DATEADD(m, DATEDIFF(m, 0, @Date), 0)) -- date e pare e nuajit
     
       WHILE @Date <= @DateSeriEnd
         BEGIN
         
           IF DATEPART(dd, @Date) = 1
              BEGIN
              
	            SET         @LastDate = DATEADD(dd, -1, DATEADD(mm,1,@date) );
                
                INSERT INTO #MonthsTable 
                SELECT      YEAR(@Date),MONTH(@Date),@Date,@LastDate;
                
                SET         @Date = DATEADD(dd,1,@LastDate);
	          END  
	         
           ELSE
           
             SET @Date = DATEADD(dd,1,@Date);
             
         END;

      CREATE INDEX iDate ON #MonthsTable ([YEAR],[MONTH])
--    SELECT * FROM #MonthsTable      
--



      SELECT *
        INTO #MonthNames
        FROM
          (         SELECT 'Janar' AS Month_Name, 1 AS Month_Number
              UNION SELECT 'Shkurt',              2
              UNION SELECT 'Mars',                3
              UNION SELECT 'Prill',               4
              UNION SELECT 'Maj',                 5
              UNION SELECT 'Qershor',             6
              UNION SELECT 'Korrik',              7
              UNION SELECT 'Gusht',               8
              UNION SELECT 'Shtator',             9
              UNION SELECT 'Tetor',              10
              UNION SELECT 'Nendor',             11
              UNION SELECT 'Dhjetor',            12
             ) AS Months 
    ORDER BY Month_Name;
    
      SELECT NRRENDOR = CAST(0 AS BIGINT)                                              INTO #TempScr       FROM AQSCR WHERE 1=2;  
      SELECT KOD=KARTLLG, DateAMLast=DATEOPER, AMVleraCum=VLERAAM, AQVleraCum=VLERABS  INTO #TempDtAM      FROM AQSCR WHERE 1=2;  
      SELECT KOD=KARTLLG, AQDateShitje=DATEOPER,KODOPER                                INTO #TempShitje    FROM AQSCR WHERE 1=2;
      SELECT KOD=KARTLLG, AQDateSistemim=DATEOPER, AQVleraSistemim=VLERAAM             INTO #TempSistemim  FROM AQSCR WHERE 1=2;


      SELECT *
        INTO #AQKategoriTmp
        FROM AQKATEGORI
    ORDER BY KOD;
    
      UPDATE #AQKategoriTmp
         SET NORMEAM     = ISNULL(NORMEAM,0),    NRTIMEAM      = ISNULL(NRTIMEAM,12),    AMVLEREMBET    = ISNULL(AMVLEREMBET,0),
             VLEREMINAM  = ISNULL(VLEREMINAM,0), PERQINDMINAM  = ISNULL(PERQINDMINAM,0), APLVLEREMINAM  = ISNULL(APLVLEREMINAM,0),
             NORMEAM2    = ISNULL(NORMEAM2,0),   NRTIMEAM2     = ISNULL(NRTIMEAM2,12),   AMVLEREMBET2   = ISNULL(AMVLEREMBET2,0),
             VLEREMINAM2 = ISNULL(VLEREMINAM2,0),PERQINDMINAM2 = ISNULL(PERQINDMINAM2,0),APLVLEREMINAM2 = ISNULL(APLVLEREMINAM2,0);

          IF @ModelAM=1                                                          -- Amortizim me modelin 2
             BEGIN
               DELETE FROM #AQKategoriTmp WHERE ISNULL(ACTIVAM2,0)<>1;
               
               UPDATE #AQKategoriTmp
                  SET NORMEAM    = ISNULL(NORMEAM2,0),   NRTIMEAM     = ISNULL(NRTIMEAM2,12),    AMVLEREMBET   = ISNULL(AMVLEREMBET2,0),
                      VLEREMINAM = ISNULL(VLEREMINAM2,0),PERQINDMINAM = ISNULL(PERQINDMINAM2,0), APLVLEREMINAM = ISNULL(APLVLEREMINAM2,0)
                WHERE ISNULL(ACTIVAM2,0)=1; 
             END;
             
             



   RAISERROR (N'A. ****     FILLIM Amortizimi     **** ', 0, 1) WITH NOWAIT; PRINT ''--+CHAR(13);

-- 1.        Filtrimi i te dhenave tek tabelat AQ, AQSCR, krijimi i temporareve

                                                                     
   RAISERROR (N'1.          Filtrimi i te dhenave tek tabelat AQ, AQSCR, krijimi i temporareve ', 0, 1) WITH NOWAIT; PRINT '';

                                                                            -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020

         SET @sSql = '
                                                                     

          RAISERROR (N''     1.1    Tabela me Kartelat dhe datat e fundit te amortizimit '', 0, 1) WITH NOWAIT

             INSERT INTO #TempDtAM                                   -- 1.1. Tabela me Kartelat dhe datat e fundit te amortizimit
                   (KOD, DateAMLast, AMVleraCum, AQVleraCum)
             SELECT B.KARTLLG,
                    DTAM       = ISNULL(MAX(CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END),0),
                    AMVleraCum = 0.0,                                                    -- Ilir 27.05.2020, ishte- AMVleraCum=ROUND(SUM(ISNULL(B.VLERAAM,0)),2)
                                                                                         -- Ilir 26.02.2021, ishte- AMVleraCum=ROUND(SUM(CASE WHEN B.KODOPER=''CE'' THEN 0 ELSE ISNULL(B.VLERAAM,0) END),2)
                    AQVleraCum = 0.0 
               FROM AQ A INNER JOIN AQSCR          B  ON A.NRRENDOR=B.NRD
                         INNER JOIN AQKARTELA      R1 ON B.KARTLLG=R1.KOD
                         INNER JOIN #AQKategoriTmp R2 ON R2.KOD=R1.KATEGORI
              WHERE (A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''')) AND (UPPER(ISNULL(B.KODOPER,'''')) IN (''CE'',''AM'')) AND 
                    (1=1)
           GROUP BY B.KARTLLG; 
           

             UPDATE T
                SET AMVleraCum = ROUND(ISNULL(A.VLERAAM,0),2),                           -- Ilir 26.02.2021, procedure e re
                    AQVleraCum = 0.0 
               FROM #TempDtAM T INNER JOIN 
               
                  (            
                    SELECT B.KARTLLG,VLERAAM=SUM(B.VLERAAM) 
                      FROM AQ A INNER JOIN AQSCR           B  ON A.NRRENDOR=B.NRD
                                INNER JOIN #TempDtAM       T  ON B.KARTLLG =T.KOD
                                INNER JOIN AQKARTELA       R1 ON B.KARTLLG=R1.KOD
                                INNER JOIN #AQKategoriTmp  R2 ON R2.KOD=R1.KATEGORI
                          WHERE (A.DATEDOK<=T.DateAMLast) AND (A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''')) AND (UPPER(ISNULL(B.KODOPER,'''')) IN (''CE'',''AM'')) AND 
                                (1=1)
                          GROUP BY B.KARTLLG
           
                     ) A  ON T.KOD=A.KARTLLG; 



          RAISERROR (N''     1.2    Llogaritja e vleftes se asetit deri diten e amortizimit te fundit '', 0, 1) WITH NOWAIT;
                                                                                    -- 1.2. Llogaritje vlefte aseti deri diten e amortizimit te fundit.
                                                                                    -- Kjo procedure 1.2 zevendesoi proceduren 1.2 dhe 1.3 (e komentuar me poshte). Date 13.08.2020
             UPDATE T                                                               
                SET T.AQVleraCum = ROUND(ISNULL(A.AQValue,0) - CASE WHEN ISNULL(A.AMVlereMbet,0)=0 THEN 0 ELSE ISNULL(T.AMVleraCum,0) END,2)      -- New 26.02.2021, pjesa me minus
               FROM #TempDtAM T INNER JOIN (
                                             SELECT KOD     = B.KARTLLG, AMVlereMbet=MAX(CASE WHEN ISNULL(R2.AMVLEREMBET,0)=0 THEN 0 ELSE 1 END),
                                                    AQValue = ISNULL( SUM(CASE WHEN B.KODOPER IN (''BL'',''RK'',''RV'')                  THEN ISNULL(B.VLERABS,0)
                                                                               WHEN B.KODOPER IN (''CE'') AND ISNULL(R2.AMVLEREMBET,0)=0 THEN ISNULL(B.VLERABS,0)
                                                                               WHEN B.KODOPER IN (''CE'')                                THEN CASE WHEN ISNULL(D.VLERAFATMV,0)<>0 
                                                                                                                                                   THEN ISNULL(D.VLERAFATMV,0) 
                                                                                                                                                   ELSE ISNULL(B.VLERABS,0)
                                                                                                                                              END     
                                                                               ELSE                                                      0
                                                                          END), 0) 
                                               FROM AQ A INNER JOIN AQSCR           B  ON A.NRRENDOR=B.NRD
                                                         INNER JOIN #TempDtAM       T  ON B.KARTLLG =T.KOD
                                                         INNER JOIN AQKARTELA       R1 ON B.KARTLLG=R1.KOD
                                                         INNER JOIN #AQKategoriTmp  R2 ON R2.KOD=R1.KATEGORI
                                                         LEFT  JOIN AQCELJE         D  ON R1.NRRENDOR=D.NRD
                                              WHERE (A.DATEDOK<=T.DateAMLast) AND (A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''')) AND 
                                                    (UPPER(ISNULL(B.KODOPER,'''')) IN (''CE'',''BL'',''RK'',''RV'')) AND 
                                                    (1=1)
                                           GROUP BY B.KARTLLG 
                                           
                                            )       A     ON T.KOD=A.KOD;


          RAISERROR (''     1.4    Tabela me Kartelat dhe veprimet qe do te amortizohen '', 0, 1) WITH NOWAIT

             INSERT INTO #TempScr                                    -- 1.3. Tabela me Kartelat dhe veprimet qe do te amortizohen
                   (NRRENDOR)
             SELECT B.NRRENDOR
               FROM AQ A INNER JOIN AQSCR          B  ON A.NRRENDOR=B.NRD
                         INNER JOIN AQKARTELA      R1 ON B.KARTLLG=R1.KOD
                         INNER JOIN #AQKategoriTmp R2 ON R2.KOD=R1.KATEGORI
              WHERE A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''') AND (UPPER(ISNULL(B.KODOPER,'''')) IN (''CE'',''BL'',''RK'',''RV'')) AND 
                   (1=1); ';
                   
          IF  @sWhere<>''          
              SET @sSql = Replace(@sSql,'1=1',@sWhere);
        EXEC (@sSql);      -- PRINT  @sSql;  SELECT '1',* FROM #TempScr; SELECT '1A',* FROM #TempDtAM; RETURN;
                   
                   
         SET  @sSql = '       

          RAISERROR (''     1.5    Tabela me Kartelat dhe date shitje/jashte perdorimit per te kufizuar datat seri te amortizimit '', 0, 1) WITH NOWAIT
          
             INSERT INTO #TempShitje                                 -- 1.4. Tabela me Kartelat dhe date shitje/jashte perdorimit per te kufizuar datat seri te amortizimit
                   (KOD,AQDateShitje,KODOPER)                        --      a. Ndryshimi me 03.04.2020 (para kesaj date ishte si me poshte)    
                                                                     --         Behet SELECT vetem rekordi me daten me te pare per date blokimi ne se ka operacione ''SH'',''JP'',''CR''
                                                                     
             SELECT A.*,
                    KODOPER = (SELECT TOP 1 R.KODOPER 
                                 FROM AQSCR R 
                                WHERE R.KARTLLG=A.KARTLLG AND (UPPER(ISNULL(R.KODOPER,'''')) IN (''SH'',''JP'',''CR'')) AND R.DATEOPER=A.DATEOPER)
               FROM 
                   (                                                       
                      SELECT B.KARTLLG,DATEOPER=MIN(B.DATEOPER)
                        FROM AQ A INNER JOIN AQSCR          B  ON A.NRRENDOR=B.NRD
                                  INNER JOIN AQKARTELA      R1 ON B.KARTLLG=R1.KOD
                                  INNER JOIN #AQKategoriTmp R2 ON R2.KOD=R1.KATEGORI
                       WHERE A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''') AND (UPPER(ISNULL(B.KODOPER,'''')) IN (''SH'',''JP'',''CR'')) AND 
                            (1=1)
                    GROUP BY B.KARTLLG
                   
                    ) A
                   
           ORDER BY A.KARTLLG;


          RAISERROR (''     1.6    Tabela me Kartelat dhe date sistemimi (Te perpunohet me vone    03.12.2018) '', 0, 1) WITH NOWAIT; 

             INSERT INTO #TempSistemim                                                   -- 1.6. Tabela me Kartelat dhe date sistemimi (Te perpunohet me vone    03.12.2018)
                   (KOD,AQDateSistemim,AQVleraSistemim)
             SELECT B.KARTLLG, A.DATEDOK, ROUND(ISNULL(B.VLERABS,0),2)                   -- Ilir
               FROM AQ A INNER JOIN AQSCR          B  ON A.NRRENDOR=B.NRD
                         INNER JOIN AQKARTELA      R1 ON B.KARTLLG=R1.KOD
                         INNER JOIN #AQKategoriTmp R2 ON R2.KOD=R1.KATEGORI
              WHERE A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''') AND (UPPER(ISNULL(B.KODOPER,'''')) IN (''SI'')) AND 
                   (1=1);';
                   
                   
                   
/*  -- Ishte deri 13.08.2020: Procedura 1.2 dhe 1.3 u zevendesuan me ate me lart me proceduren 1.2 me siper. Date 13.08.2020

             UPDATE T                                                -- 1.2. Llogaritje vlefte aseti deri diten e amortizimit te fundit.
                SET T.AQVleraCum = ROUND(ISNULL(A.AQValue,0),2)      -- Ilir
               FROM #TempDtAM T INNER JOIN (
                                             SELECT KOD     = B.KARTLLG, 
                                                    AQValue = SUM(ISNULL(B.VLERABS,0))  -- Ilir
                                               FROM AQ A INNER JOIN AQSCR          B  ON A.NRRENDOR=B.NRD
                                                         INNER JOIN #TempDtAM      T  ON B.KARTLLG =T.KOD
                                                         INNER JOIN AQKARTELA      R1 ON B.KARTLLG=R1.KOD
                                                         INNER JOIN #AQKategoriTmp R2 ON R2.KOD=R1.KATEGORI
                                              WHERE (A.DATEDOK<=T.DateAMLast) AND (A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''')) AND 
                                                    (UPPER(ISNULL(B.KODOPER,'''')) IN (''CE'',''BL'',''RK'',''RV'')) AND 
                                                    (1=1)
                                           GROUP BY B.KARTLLG 
                                           
                                            )       A     ON T.KOD=A.KOD;
                      
          RAISERROR (N''     1.3    Amortizim Linear (konstant): Llogaritje vlefte aseti (kosto historike) deri diten e amortizimit te fundit '', 0, 1) WITH NOWAIT

             UPDATE T                                                -- 1.3. Llogaritje vlefte historike aseti deri diten e amortizimit te fundit.
                SET T.AQVleraCum = ROUND(ISNULL(A.AQValue,0),2)      -- Ilir
               FROM #TempDtAM T INNER JOIN (
                                             SELECT KOD     = B.KARTLLG, 
                                                    AQValue = ISNULL( SUM(CASE WHEN B.KODOPER IN (''BL'',''RK'',''RV'') THEN ISNULL(B.VLERABS,0)
                                                                               WHEN B.KODOPER IN (''CE'')               THEN CASE WHEN ISNULL(D.VLERAFATMV,0)<>0 
                                                                                                                                  THEN ISNULL(D.VLERAFATMV,0) 
                                                                                                                                  ELSE ISNULL(B.VLERABS,0)
                                                                                                                             END     
                                                                               ELSE                                          0
                                                                          END), 0)
                                                                          
                                               FROM AQ A INNER JOIN AQSCR          B  ON A.NRRENDOR=B.NRD
                                                         INNER JOIN #TempDtAM      T  ON B.KARTLLG =T.KOD
                                                         INNER JOIN AQKARTELA      R1 ON B.KARTLLG=R1.KOD
                                                         INNER JOIN #AQKategoriTmp R2 ON R2.KOD=R1.KATEGORI
                                                         LEFT  JOIN AQCELJE        D  ON R1.NRRENDOR=D.NRD
                                                         
                                              WHERE (A.DATEDOK<=T.DateAMLast) AND (A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''')) AND (ISNULL(R2.AMVLEREMBET,0)=0) AND 
                                                    (UPPER(ISNULL(B.KODOPER,'''')) IN (''CE'',''BL'',''RK'',''RV'')) AND 
                                                    (1=1)
                                           GROUP BY B.KARTLLG 
                                           
                                            )       A     ON T.KOD=A.KOD;
*/  
         
--                                                                   -- Gjendje para dates 08.04.2020 (pas kesaj date eshte si me siper) 
--        RAISERROR (''     1.6    Tabela me Kartelat dhe date shitje/jashte perdorimit per te kufizuar datat seri te amortizimit '', 0, 1) WITH NOWAIT
--        
--           INSERT INTO #TempShitje                                 -- 1.4. Tabela me Kartelat dhe date shitje/jashte perdorimit per te kufizuar datat seri te amortizimit
--                 (KOD,AQDateShitje,KODOPER)                        --      a. Ndryshimi me 03.04.2020 (para kesaj date ishte si me poshte)    
--           SELECT TOP 1 B.KARTLLG,B.DATEOPER,B.KODOPER             --         Behet SELECT vetem rekordi me daten me te pare per date blokimi ne se ka operacione ''SH'',''JP'',''CR''
--             FROM AQ A INNER JOIN AQSCR          B  ON A.NRRENDOR=B.NRD
--                       INNER JOIN AQKARTELA      R1 ON B.KARTLLG=R1.KOD
--                       INNER JOIN #AQKategoriTmp R2 ON R2.KOD=R1.KATEGORI
--            WHERE A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''') AND (UPPER(ISNULL(B.KODOPER,'''')) IN (''SH'',''JP'',''CR'')) AND 
--                 (1=1)
--         ORDER BY B.KARTLLG,B.DATEOPER;
                   
--           INSERT INTO #TempShitje                                 -- Gjendje para dates 03.04.2020 (pas kesaj date eshte si me siper) 
--                 (KOD,AQDateShitje,KODOPER)                              
--           SELECT B.KARTLLG,B.DATEOPER,B.KODOPER
--             FROM AQ A INNER JOIN AQSCR          B  ON A.NRRENDOR=B.NRD
--                       INNER JOIN AQKARTELA      R1 ON B.KARTLLG=R1.KOD
--                       INNER JOIN #AQKategoriTmp R2 ON R2.KOD=R1.KATEGORI
--            WHERE A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''') AND (UPPER(ISNULL(B.KODOPER,'''')) IN (''SH'',''JP'',''CR'')) AND 
--                 (1=1);


        
          IF  @sWhere<>''          
              SET @sSql = Replace(@sSql,'1=1',@sWhere);
        EXEC (@sSql);      -- PRINT  @sSql;  SELECT '1',* FROM #TempScr; SELECT '1A',* FROM #TempDtAM; RETURN;



          IF OBJECT_ID('TEMPDB..#TempDatesX')    IS NOT NULL
             DROP TABLE #TempDatesX;



   RAISERROR (N'     1.7    Plotesim i tabeles me te dhenat per vlerat dhe datat e amortizimive ', 0, 1) WITH NOWAIT; 
                                                                            -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
      SELECT A.*,
             DTAM = CASE WHEN ISNULL(B.DateAMLast,0)=0 OR A.DateDok>B.DateAMLast
                              THEN CASE WHEN A.KODOPER IN ('CE')           THEN A.DATEDOK
                                        WHEN A.KODOPER IN ('BL','RK','RV') THEN A.DATEDOK   
                                        ELSE                                    B.DateAMLast
                                   END
                         ELSE                                                   B.DateAMLast
                    END         
        INTO #TempDatesX
        FROM 
          (  SELECT KOD           = B.KARTLLG,
                    B.PERSHKRIM, 
                    B.NJESI, 
                    B.KODOPER,
                    DateDok       = A.DATEDOK,
                    
                    
                    DateStart     =                                         DATEADD(m,1,CONVERT(DATETIME,'01/'+CAST(MONTH(CASE WHEN ISNULL(Dt.DateAMLast,0)=0 OR A.DATEDOK>DateAMLast 
                                                                                                                               THEN A.DATEDOK 
                                                                                                                               ELSE Dt.DateAMLast 
                                                                                                                          END) AS VARCHAR(2))+'/'+
                                                                                                               CAST(YEAR (CASE WHEN ISNULL(Dt.DateAMLast,0)=0 OR A.DATEDOK>DateAMLast
                                                                                                                               THEN A.DATEDOK 
                                                                                                                               ELSE Dt.DateAMLast 
                                                                                                                          END) AS VARCHAR(4)),103)),
                    DtTrans       = DATEADD(d,-1,  DATEADD(m,  R.NRTIMEAM,  DATEADD(m,1,CONVERT(DATETIME,'01/'+CAST(MONTH(CASE WHEN ISNULL(Dt.DateAMLast,0)=0 --OR A.DATEDOK>DateAMLast 
                                                                                                                               THEN A.DATEDOK 
                                                                                                                               ELSE Dt.DateAMLast 
                                                                                                                          END) AS VARCHAR(2))+'/'+
                                                                                                               CAST(YEAR (CASE WHEN ISNULL(Dt.DateAMLast,0)=0 --OR A.DATEDOK>DateAMLast
                                                                                                                               THEN A.DATEDOK 
                                                                                                                               ELSE Dt.DateAMLast 
                                                                                                                          END) AS VARCHAR(4)),103))  )  ), 
                 -- zevendesuar A.DATEDOK me CASE WHEN ISNULL(Dt.DateAMLast,0)=0 THEN A.DATEDOK ELSE Dt.DateAMLast END
                 -- DateEnd       = @DateEnd,
                    NORMEAM       = ISNULL(R.NORMEAM,0),
                    IsAMVlereMbet = ISNULL(R.AMVLEREMBET,0),
                    VLERABS       = ROUND(ISNULL(B.VLERABS,0),2),  -- Ilir
                    K.KATEGORI, 
                    K.GRUP,
                    R.NRTIMEAM,
                    A.DOK_JB,
                    B.NRRENDOR 
               FROM AQ A INNER JOIN AQSCR          B  ON A.NRRENDOR=B.NRD
                         INNER JOIN #TempScr       T  ON B.NRRENDOR=T.NRRENDOR
                         INNER JOIN AQKARTELA      K  ON B.KARTLLG =K.KOD
                         INNER JOIN #AQKategoriTmp R  ON R.KOD=K.KATEGORI
                         LEFT  JOIN #TempDtAM      Dt ON B.KARTLLG=Dt.KOD
              WHERE A.DATEDOK<=@DateEnd AND B.KODOPER IN ('CE','BL','RK','RV') 
             ) A  LEFT  JOIN #TempDtAM B ON A.KOD=B.KOD
       WHERE DateStart<=@DateEnd
    ORDER BY KOD,DateDok;

-- SELECT 'Kujdes' AS PR,* FROM #TempDatesX;


   RAISERROR (N'     1.8    Amortizim Linear (konstant): Plotesim i tabeles me te dhena per kosto historike ', 0, 1) WITH NOWAIT; 
--                          Kriter eshte deri ne daten e amortizimit te fundit              -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
      UPDATE T
         SET VLERABS = ISNULL(( SELECT SUM(CASE WHEN B.KODOPER IN ('BL','RK') THEN ISNULL(B.VLERABS,0)
                                                WHEN B.KODOPER IN ('CE')      THEN CASE WHEN ISNULL(D.VLERAFATMV,0)<>0 
                                                                                        THEN ISNULL(D.VLERAFATMV,0) 
                                                                                        ELSE ISNULL(B.VLERABS,0)
                                                                                   END     
                                                ELSE                               0
                                           END) 
                                  FROM AQSCR B INNER JOIN AQ        A ON A.NRRENDOR=B.NRD AND B.KARTLLG=T.KOD 
                                               INNER JOIN AQKARTELA C ON B.KARTLLG=C.KOD
                                               LEFT  JOIN AQCELJE   D ON D.NRD=C.NRRENDOR
                                               
                                 WHERE ((A.DATEDOK<=T.DTAM) AND (B.KODOPER IN ('BL','CE'))) OR  ((A.DATEDOK<T.DTAM) AND (B.KODOPER IN ('RK'))) )
                               ,0) 
        FROM #TempDatesX T 
       WHERE ISNULL(T.IsAmVlereMbet,0)=0 AND T.KODOPER IN ('BL','CE');



                                                                                            -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
   RAISERROR (N'     1.9    Per ato blerje apo RK,RV para amortizimit te fundit ruhet nje rekord i kumuluar .... (reshtat me kriterin OrderParaAM>1 fshihen) ', 0, 1) WITH NOWAIT; PRINT '';

      SELECT A.*,
             OrderParaAM      = CASE WHEN DATEDOK<DtAM 
                                     THEN CASE WHEN ROW_NUMBER() OVER (PARTITION BY KOD ORDER BY KOD,DATEDOK)=1 THEN 1 ELSE 2 END
                                     ELSE 0
                                END         
        INTO #TempDates
        FROM #TempDatesX A
    ORDER BY KOD,DateDok;         -- SELECT '2',* FROM #TempScr; SELECT '2A',* FROM #TempDtAM; Select '2B',* From #TempDates; RETURN;                                                                                 

      DELETE FROM #TempDates WHERE OrderParaAM>1;   
   


          IF OBJECT_ID('TEMPDB..#TempScr')      IS NOT NULL
             DROP TABLE #TempScr;

          IF OBJECT_ID('TEMPDB..#TempDatesX')   IS NOT NULL
             DROP TABLE #TempDatesX;

-- 1. FUND   Gjenerimi i tabelave temporare




   RAISERROR (N'2.          Zberthimi ne seri data per evidentimin e amortizimit [DateStart, DateEnd]
            Ndertimi i tabeles me date seri per amortizimin (tabela #TempSeri) e cial ndertohet me ndihmen e funksionit Isd_AQAMDateRange', 0, 1) WITH NOWAIT; PRINT '';


-- 2.        Zberthimi ne seri data per evidentimin e amortizimit [DateStart, DateEnd]
          -- Ndertimi i tabeles me date seri per amortizimin (tabela #TempSeri) e cial ndertohet me ndihmen e funksionit Isd_AQAMDateRange


             -- 2.1     Gjenerimi i serise se datave, mbushet tabela #TempSeri 
             
   RAISERROR (N'     2.1    Gjenerimi i serise se datave, mbushet tabela #TempSeri ', 0, 1) WITH NOWAIT; 
   
      SELECT NrRendor = CAST(0 AS BIGINT), StartDate = DTAM, EndDate = DATEDOK, KOD, NrOrd = 0, TRow=CAST(0 AS BIT),
             NrTimeAM,KODOPER,DateBlock=CAST(NULL AS DATETIME)
        INTO #TempSeri 
        FROM #TempDates 
       WHERE 1=2;
 
       
        EXEC dbo.Isd_AQAMSeriDates '#TempDates','#TempSeri',@pDateEnd;
   -- SELECT '3',* FROM #TempSeri; SELECT '3A',* FROM #TempDates; --RETURN;


             -- 2.2     Kufizimi i serise se datave deri ne date shitje aseti (ne se ka te tille brenda periushes)
             --         Kujdes me fushen NrOrd
             
   RAISERROR (N'     2.2    Kufizimi i serise se datave deri ne date shitje aseti (ne se ka te tille brenda periushes) ', 0, 1) WITH NOWAIT; PRINT '';
  
          IF OBJECT_ID('TempDB..#TempSeriX')    IS NOT NULL
             DROP TABLE #TempSeriX;
             
--    SELECT TOP 1 A.Kod,A.NrOrd,T.AQDateShitje,.. etj         -- ishte perpara 08.04.2020

      SELECT A.Kod,A.NrOrd,T.AQDateShitje,T.KodOper,           -- 2.2.1      Gjendet e para date serie  >= se date shitje dhe ruhet tek #TempSeriX
             DateBlock=T.AQDateShitje                          --            a. Kujdes: Ka rendesi NrOrd i cili ndihmon per fshirjen (nuk mjaftin A.EndDate>T.AQDateShitje)
        INTO #TempSeriX                                        --            b. U fut fusha DateBlock qe mban daten e veprimit me te pare ('SH','JP','CR') 03.04.2020
        FROM #TempSeri A INNER JOIN #TempShitje T ON A.KOD=T.KOD
       WHERE A.EndDate>T.AQDateShitje
    ORDER BY A.KOD,A.NrOrd;      -- SELECT * FROM #TempSeriX; RETURN;

      UPDATE A                                                 -- 2.2.2      Per rekordin qe ka te paren date >= se date shitje ruhet si date ajo e shitjes
         SET A.EndDate = T.AQDateShitje, A.KodOper=T.KodOper, DateBlock=T.DateBlock
        FROM #TempSeri A INNER JOIN #TempSeriX T ON A.KOD=T.KOD AND A.NrOrd=T.NrOrd;
        
      DELETE A                                                 -- 2.2.3      Fshihen te gjithe rekordet e serise jashte dates se shitjes
        FROM #TempSeri A INNER JOIN #TempSeriX T ON A.KOD=T.KOD 
       WHERE A.NrOrd>T.NrOrd;
       
        

          IF OBJECT_ID('TempDB..#TempSeriX')    IS NOT NULL
             DROP TABLE #TempSeriX;
             
          IF OBJECT_ID('TEMPDB..#TempShitje')   IS NOT NULL
             DROP TABLE #TempShitje;
   -- SELECT '4',* FROM #TempSeri; -- RETURN                    
                      




-- 3.        Tabela #TempDates1 eshte kryesore ne algoritmin per amortizimin

   RAISERROR (N'3.          Tabela #TempDates1 eshte kryesore ne algoritmin per amortizimin ', 0, 1) WITH NOWAIT; PRINT '';


      SELECT Dt.*, 
             DateStartAM      = A.StartDate,
             DateTransAM      = A.EndDate,
             DateAMLast       = Dt.DTAM,
             DateEND          = @DateEnd,
             DateBlock        = A.DateBlock,
             
             VleraAM          = CAST(0.0 AS FLOAT),
             AMVleraCum       = CAST(0.0 AS FLOAT),     -- Shuma e amortizimeve para pariudhes vleresuese (referuar DateAMLast)
             AMVleraPrg       = CAST(0.0 AS FLOAT),     -- Amortizimi progresiv per periudhen e rivleresimit (amortizimit)
             AMVleraTot       = CAST(0.0 AS FLOAT),     -- Amortizim total (progresiv te periudhes + Amortizimi i cumuluar)
             AMVleraMin       = CAST(0.0 AS FLOAT),     -- Vlere minimale amortizimi, llogaritet me poshte

             AQVleraCum       = CAST(0.0 AS FLOAT),     -- Shuma e vlerave te aktivit para pariudhes vleresuese (referuar DateAMLast)
             AQVleraMbet      = CAST(0.0 AS FLOAT),
             AQVleraSistemim  = CAST(0.0 AS FLOAT),
             
             PershkrimAM      = Space(150),
             KomentMbyllje    = Space(150),             -- Pershkrim ne rast mbyllje aseti    
             NrMonthsAM       = 0,
             NrDaysAM         = 0,                      -- u shtua me 30.09.2020
             TipRow           = ' ',
             Zgjedhur         = CAST(1 AS BIT),
             KodMbyllje       = A.KodOper,
             SeqNum           = ROW_NUMBER() OVER (PARTITION BY A.NRRENDOR,Dt.KOD ORDER BY A.NRRENDOR,Dt.KOD,A.StartDate)--,
             
        INTO #TempDates1     

        FROM #TempDates Dt LEFT JOIN #TempSeri A ON Dt.NRRENDOR=A.NRRENDOR 
    -- WHERE Dt.DateDok>=Dt.DTAM
    ORDER BY A.NRRENDOR,Dt.KOD,A.StartDate; 
    

      DELETE                                            -- Fshirja e kartelave qe jane me date start amortizimi > DateBlock 
                                                        -- (DateBlock eshte date minimum e operacionev 'SH','JP','CR')  -- 03.04.2020
        FROM #TempDates1
       WHERE (NOT (DateBlock IS NULL)) AND (DateStartAM>DateBlock);
       
   -- SELECT '5',* FROM #TempDates1 ORDER BY KOD,SEQNUM; SELECT '5A',* FROM #TempSeri; --RETURN


          IF OBJECT_ID('TEMPDB..#TempSeri')     IS NOT NULL
             DROP TABLE #TempSeri;
    
      
/*
--           Nje tjeter algoritem per gjenerimin e tabeles me datat seri per amortizimin, nuk kenaq kushtin per ta hedhur kete procedure me parameter kodin a aktivit
          -- Per ndonje rast te meret ideja e gjenerimit te serive ....
   
      SELECT Dt.*, 
             DateStartAM1 =                 DATEADD(m, (12/NRTIMEAM)*(Seq.SeQnum-1), Dt.DateStart),
             DateTransAM1 = DATEADD(d, - 1, DATEADD(m, (12/NRTIMEAM)* Seq.SeQnum,    Dt.DateStart)),
             
             DateStartAM  = CASE WHEN YEAR (DATEADD(m, (12/NRTIMEAM)*(Seq.SeQnum-1), Dt.DateStart)) > YEAR(Dt.DateStart)                   -- Kriter per kalimin e viteve
                                     AND 
                                     MONTH(DATEADD(m, (12/NRTIMEAM)*(Seq.SeQnum-1), Dt.DateStart)) > 1 
                                THEN CONVERT(DATETIME,'01/01/'+CAST(YEAR(DATEADD(m, (12/NRTIMEAM)*(Seq.SeQnum-1), Dt.DateStart)) AS VARCHAR))
                                ELSE                                     DATEADD(m, (12/NRTIMEAM)*(Seq.SeQnum-1), Dt.DateStart)
                            END,
             DateTransAM = CASE WHEN YEAR(DATEADD(d, - 1, DATEADD(m, (12/NRTIMEAM)* Seq.SeQnum,    Dt.DateStart))) > YEAR(Dt.DateStart)   -- Kriter per kalimin e viteve
                                THEN      DATEADD(d, - 1, DATEADD(m, (12/NRTIMEAM)* Seq.SeQnum,    CONVERT(DATETIME,'01/01/'+CAST(YEAR(Dt.DateStart) AS VARCHAR))))
                                ELSE      DATEADD(d, - 1, DATEADD(m, (12/NRTIMEAM)* Seq.SeQnum,    Dt.DateStart))
                           END,
             ..........,              
             Seq.SeqNum
        INTO #TempDates1     
        FROM #TempDates Dt LEFT OUTER JOIN
                                        ( SELECT Row_Number() OVER (ORDER BY (SELECT NULL)) AS SeqNum 
                                            FROM Sys.Objects
                                           ) Seq    
                                           ON SeqNum <= DATEDIFF(m, Dt.DateStart-1, @DateEnd)
   --  WHERE DATEADD(m, NRTIMEAM*(Seq.SeQnum), Dt.DateStart)<=@DateEnd;   */   
   
   
   
-- 4.        Plotesime te tabeles ne lidhje me historikun e aktivit, si psh amortizimi fundit, amortizim i kumuluar, vlefta sistemuese etj.
   RAISERROR (N'4.          Plotesime te tabeles ne lidhje me historikun e aktivit, si psh amortizimi fundit, amortizim i kumuluar, vlefta sistemuese etj. ', 0, 1) WITH NOWAIT; PRINT '';







-- New 19.04.2019 -- u fut sepse nje Riparim Kapital e sapo kryer na bashkohej me AMCum me nje blerje te vjeter

-- Shiko ne se nuk ecen pika 1. shiko me poshte piken 2.

--    UPDATE A                                                                                             -- Para 19.04.2019
--       SET DateAMLast = B.DateAMLast,  AMVleraCum = B.AMVleraCum,  AQVleraCum = B.AQVleraCum
--      FROM #TempDates1 A INNER JOIN #TempDtAM B ON A.KOD=B.KOD;

-- 1.
--    UPDATE A                                                                                             -- New  19.04.2019, modifikim i sql me siper
--       SET DateAMLast      = CASE WHEN B.DateAMLast< A.DATEDOK THEN A.DATEDOK    ELSE B.DateAMLast END,  
--           AMVleraCum      = CASE WHEN B.DateAMLast>=A.DATEDOK THEN B.AMVleraCum ELSE 0            END,  
--           AQVleraCum      = CASE WHEN B.DateAMLast>=A.DATEDOK THEN B.AQVleraCum ELSE A.VLERABS    END  
--      FROM #TempDates1 A INNER JOIN #TempDtAM B ON A.KOD=B.KOD;
        
                                                                                                           -- New  27.05.2020, modifikim i sql me siper
      UPDATE A                                                                                             -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
         SET DateAMLast      = CASE WHEN B.DateAMLast< A.DATEDOK THEN A.DATEDOK    ELSE B.DateAMLast END,  
             AMVleraCum      = CASE WHEN A.KODOPER='CE'           AND B.DateAMLast>A.DATEDOK THEN B.AMVleraCum 
                                    WHEN A.KODOPER IN ('BL','RK') AND B.DateAMLast>A.DATEDOK THEN B.AMVleraCum -- Shtuar me 13.08.2020
                                    ELSE 0            
                               END,  
             AQVleraCum      = CASE WHEN A.KODOPER='CE' AND B.DateAMLast>A.DATEDOK THEN B.AQVleraCum ELSE A.VLERABS    END  
        FROM #TempDates1 A INNER JOIN #TempDtAM B ON A.KOD=B.KOD;
--    SELECT * FROM #TempDates1; RETURN;


      UPDATE A
         SET DateAMLast      = A.DATEDOK, AMVleraCum = 0, AQVleraCum = A.VLERABS
        FROM #TempDates1 A 
       WHERE NOT EXISTS (SELECT NRRENDOR FROM #TempDtAM B WHERE A.KOD=B.KOD);

      UPDATE A
         SET DateAMLast      = A.DATEDOK
        FROM #TempDates1 A 
       WHERE DATEDOK>DateAMLast;

                                                               -- 4.2        Gjendet e para date serie  >= ku futet vlefta per sistemin e asetit
      UPDATE A                                                            -- (Te perpunohet me vone    03.12.2018)
         SET AQVleraSistemim = T.AQVleraSistemim
        FROM #TempDates1 A INNER JOIN #TempSistemim T ON A.KOD=T.KOD
       WHERE A.DateStartAM<=T.AQDateSistemim AND T.AQDateSistemim<=A.DateTransAM;         
    --SELECT '6',* FROM #TempDates1 ORDER BY KOD,SEQNUM; SELECT '6A',* FROM #TempSistemim; --RETURN 



/*
-- New 19.04.2019 -- u fut sepse nje Riparim kapital e sapo kryer na bashkohej me AMCum me nje blerje te vjeter

-- 2.  (Shiko me siper piken 1.)
-- Kjo procedure nuk ka nevoje ne se behet pika 1. me siper

      UPDATE A                                                                                             -- New  19.04.2019 
         SET AMVleraCum = 0,  AQVleraCum = A.VLERABS
        FROM #TempDates1 A 
       WHERE DATEDOK>@DateDok AND DATEDOK<=@DateEnd;  --DATEDOK>DateAMLast AND DATEDOK<=@DateEnd
   -- SELECT '7',* FROM #TempDates1 ORDER BY KOD,SEQNUM; SELECT '7A',* FROM #TempSistemim; RETURN 
*/





          IF OBJECT_ID('TEMPDB..#TempDtAM')     IS NOT NULL
             DROP TABLE #TempDtAM;

          IF OBJECT_ID('TEMPDB..#TempSistemim') IS NOT NULL
             DROP TABLE #TempSistemim;
   
    


-- 5.            Shtohet nje resht per date diference. Per kete perdoret #TempDates2 e cila ne fund i shtohet #TempDates1
             --  Ky resht dallohet nga te tjeret sepse ka TipRow='D'. U shtua per te ritur lexueshmerine e informacionit ne afishim
             --  Edhe ky resht edhe ai me SeqNum=0 jane per te ritur lexueshmerine e te dhenave ne afishim ne program  
             --  Kujdes: Llogaritet ne muaj dhe dite diferenca e periudhes nga DateEnd-DateTransAM
   RAISERROR (N'5.          Shtohet nje resht per date diference. Per kete perdoret #TempDates2 e cila ne fund i shtohet #TempDates1 
            Ky resht dallohet nga te tjeret sepse ka TipRow=''D''. U shtua per te ritur lexueshmerine e informacionit ne afishim
            Edhe ky resht edhe ai me SeqNum=0 jane per te ritur lexueshmerine e te dhenave ne afishim ne program  
            Kujdes: Llogaritet ne muaj dhe dite diferenca e periudhes nga DateEnd-DateTransAM ', 0, 1) WITH NOWAIT; PRINT '';
             

      SELECT A.*
        INTO #TempDates2     
        FROM #TempDates1 A 
       WHERE A.SEQNUM = (SELECT MAX(B.SEQNUM) FROM #TempDates1 B WHERE B.KOD=A.KOD) AND A.DATETRANSAM<=A.DATEEND
    ORDER BY KOD;
    
    
      UPDATE #TempDates2
         SET DateStartAM   = (SELECT MIN(DateStartAM) FROM #TempDates1 WHERE #TempDates1.KOD=#TempDates2.KOD AND #TempDates1.DATEDOK=#TempDates2.DATEDOK),
             DateTransAM   = DateEnd,
             SeqNum        = SeqNum + 1, 
             TipRow        = 'D'                    -- Resht Diference
             
             
      INSERT   INTO  #TempDates1     
      SELECT * FROM  #TempDates2 A;

      DROP     TABLE #TempDates2;
--    SELECT * From  #TempDates1; RETURN;
            


-- 6.            Llogaritja e fushave dhe elementeve per Amortizimin sipas te dyja metodave 
             --  AVK - Amortizim Vlefte Konstante,       AVM - Amortizim Vlefte Mbetur
   RAISERROR (N'6.          Llogaritja e fushave dhe elementeve per Amortizimin sipas te dyja metodave 
            AVK - Amortizim Vlefte Konstante,       AVM - Amortizim Vlefte Mbetur ', 0, 1) WITH NOWAIT; PRINT '';


   RAISERROR (N'     6.0    Llogaritje numur muaj amortizim si dhe vlere minimale ku nderpritet amortizimi ', 0, 1) WITH NOWAIT; PRINT '';
      --  6.0 Llogaritje numur muaj amortizim si dhe vlere minimale ku nderpritet amortizimi

   
   
      UPDATE #TempDates1                                                                     -- procedure e re me 30.09.2020
         SET NrMonthsAM    = DATEDIFF(m, DateStartAM, DateTransAM) + 1;
         
      UPDATE T                                                                               -- procedure e re me 30.09.2020
         SET T.NrDaysAM    = CASE WHEN T.DateTransAM=TM.LastDate 
                                  THEN 0
                                  ELSE DATEDIFF(d,TM.FirstDate, T.DateTransAM)+1
                             END,
             T.NrMonthsAM  = CASE WHEN T.DateTransAM=TM.LastDate
                                  THEN NrMonthsAM
                                  ELSE NrMonthsAM - 1
                             END                    
        FROM #TempDates1 T INNER JOIN #MonthsTable TM ON YEAR(T.DateTransAM)=[YEAR] AND MONTH(T.DateTransAM)=[MONTH];



      UPDATE T 
         SET 
          -- T.NrMonthsAM  = DATEDIFF(m, T.DateStartAM, T.DateTransAM) + 1,                  -- ishte deri 30.09.2020
          
             AMVleraMin    = CASE WHEN ISNULL(R.APLVLEREMINAM,0) = 0                         -- sipas perqindjes 
                                       THEN ROUND((ISNULL(R.PERQINDMINAM,0) * ISNULL(T.AQVleraCum,0))/100,2)   -- VleraBS ose AQVleraCum
                                       
                                  WHEN ISNULL(R.APLVLEREMINAM,0) = 1                         -- sipas vlere minimale
                                       THEN ISNULL(R.VLEREMINAM,0.0)
                                                                                             -- sipas maximumit (perqindje, vlere minimale)
                                  ELSE CASE WHEN ROUND((ISNULL(R.PERQINDMINAM,0) * ISNULL(T.AQVleraCum,0))/100,2)>=ISNULL(R.VLEREMINAM,0.0) 
                                            THEN ROUND((ISNULL(R.PERQINDMINAM,0) * ISNULL(T.AQVleraCum,0))/100,2)
                                            ELSE ISNULL(R.VLEREMINAM,0.0)
                                       END     
                             END
        FROM #TempDates1   T INNER JOIN AQKARTELA      K  ON T.KOD = K.KOD
                             INNER JOIN #AQKategoriTmp R  ON K.KATEGORI=R.KOD;


      -- 6.1    FILLIM AVK:      Metoda Amortizimit Vefte Konstant (sipas normes se Amortizimit)
   RAISERROR (N'     6.1    FILLIM AVK:      Metoda Amortizimit Vefte Konstant (sipas normes se Amortizimit) ', 0, 1) WITH NOWAIT; PRINT '';



             -- 6.1.1   Llogaritja e vleftes se amortizimit
   RAISERROR (N'     6.1.1                   Llogaritja e vleftes se amortizimit ', 0, 1) WITH NOWAIT;
      
      UPDATE T
         SET PERSHKRIMAM   = CASE WHEN T.TipRow='D'
                                  THEN PERSHKRIMAM
                                  ELSE SUBSTRING(M1.Month_Name,1,3)+' - '+SUBSTRING(M2.Month_Name,1,3)+' '+SUBSTRING(CAST(YEAR(T.DateStartAM) AS VARCHAR),1,4)
                             END,
          -- NrMonthsAM    = A.NrMonthsAM,                                               -- u hoq me 30.09.2020
             VLERAAM       = CASE WHEN T.TipRow='D'                 THEN VLERAAM                              
                                  WHEN ISNULL(A.NrMonthsAM,0)=0 AND ISNULL(A.NrDaysAM,0)=0    
                                                                    THEN 0 
                                  ELSE                                   ROUND(((A.NrMonthsAM*(T.AQVleraCum) * T.NORMEAM)/1200) +     -- u modifikua pas 30.09.2020
                                                                               ((A.NrDaysAM*  (T.AQVleraCum) * T.NORMEAM)/36500), 2)  -- Konstante
--                                ELSE                                   ROUND((A.NrMonthsAM*(T.AQVleraCum) * T.NORMEAM)/1200, 2)     -- ishte para 30.09.2020
                             END                                      -- ROUND((A.NrMonthsAM*( T.VLERABS + T.AQVleraCum) * T.NORMEAM)/1200, 2) -- Konstante
        FROM 
           (
             SELECT KOD,KODOPER,SeqNum, 
                    NrMonthsAM,NrDaysAM,NrRendor                                                  -- u shtua me 30.09.2020
--                  NrMonthsAM=DATEDIFF(m,DateStartAM,DateTransAM)+1                     -- u hoq   me 30.09.2020
               FROM #TempDates1 
              WHERE ISNULL(IsAMVlereMbet,0)=0 
              ) A  
                   INNER JOIN #TempDates1 T  ON A.KOD=T.KOD AND A.KODOPER=T.KODOPER AND A.SeqNum=T.SeqNum AND A.NrRendor=T.NrRendor
                   INNER JOIN #MonthNames M1 ON MONTH(T.DateStartAM)=M1.Month_Number
                   INNER JOIN #MonthNames M2 ON MONTH(T.DateTransAM)=M2.Month_Number;



   RAISERROR (N'     6.1.2                   AVK: Llogaritja e vleftes se mbetur (fusha AQVleraMbet me vlefta progresive) me metoden rekursive, dhe te dhenat ruhen provizorisht tek tabela #TempDates3X 
                             Llogaritja e mesiperme (per VLERAAM tek 6.1.1) mund te behej dhe ketu.
                             Test AMVleraMin i mbylljes se Amortizimit eshte variable. ', 0, 1) WITH NOWAIT; PRINT '';

             -- 6.1.2   AVK: Llogaritja e vleftes se mbetur (fusha AQVleraMbet me vlefta progresive) me metoden rekursive, dhe te dhenat ruhen provizorisht tek tabela #TempDates3X.
                     -- Llogaritja e mesiperme (per VLERAAM tek 6.1.1) mund te behej dhe ketu.
                     -- Test AMVleraMin i mbylljes se Amortizimit eshte variable. 
      

;WITH  SumAm
       AS ( 
             SELECT t.Kod, 
                    t.VLERABS,
                 -- VLERAAM     =  ROUND(                         ((t.NrMonthsAM*ISNULL(t.VLERABS,0)*t.NORMEAM)/1200.0), 2),
                    AQVleraMbet =  ROUND(ISNULL(t.VLERABS,0)    - ((t.NrMonthsAM*ISNULL(t.VLERABS,0)*t.NORMEAM)/1200.0), 2) - t.AMVleraCum,
                    t.SeqNum,
                    t.NrRendor
               FROM #TempDates1 t
              WHERE SeqNum = 1 AND ISNULL(IsAMVlereMbet,0)=0 
              
          UNION ALL

             SELECT t.KOD, 
                    t.VLERABS,
                 -- VLERAAM     = ROUND(                          ((t.NrMonthsAM*ISNULL(A.VLERABS,0)*t.NORMEAM)/1200.0), 2),  
                    AQVleraMbet = ROUND(ISNULL(A.AQVleraMbet,0) - ((t.NrMonthsAM*ISNULL(A.VLERABS,0)*t.NORMEAM)/1200.0) ,2),       
                    t.SeqNum,
                    t.NrRendor              
               FROM #TempDates1 t JOIN SumAm A ON A.NRRENDOR=T.NRRENDOR AND A.SeqNum=t.SeqNum - 1                                         -- ON A.KOD=t.KOD AND A.SeqNum = t.SeqNum - 1
              WHERE ISNULL(IsAMVlereMbet,0)=0 AND TipRow<>'D' AND                                                                         -- AND A.SeqNum <> 1
                    A.AQVleraMbet>=0 AND               
                    CASE WHEN t.AQVleraCum>0 THEN ROUND(A.AQVleraMbet,2) ELSE AMVleraMin END >= AMVleraMin                   -- deri AMVleraMin te vleftes     
                 -- CASE WHEN t.AQVleraCum>0 THEN ROUND(100-(100*(t.AQVleraCum-A.AQVleraMbet)/t.AQVleraCum),2) ELSE 5 END >= 5%           -- deri 5% te vleftes     
              
           )
           
             SELECT * INTO #TempDates3X FROM    SumAm    -- WHERE AQVleraMbet>=0  -- Kujdes ....!   Bllokoje ne rekursivitet sepse fryhet kot tabela temporare SumAm 
             
OPTION  ( MAXRECURSION 1000 );

    
      UPDATE A
         SET A.AQVleraMbet = B.AQVleraMbet       
        FROM #TempDates1 A INNER JOIN #TempDates3X B ON A.NRRENDOR=B.NRRENDOR AND A.SeqNum=B.SeqNum  -- ON A.KOD=B.KOD AND A.SeqNum=B.SeqNum
       WHERE ISNULL(A.IsAMVlereMbet,0)=0;
   -- SELECT * FROM #TempDates3X ORDER BY KOD,SEQNUM; SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM; RETURN;
    

          IF OBJECT_ID('TEMPDB..#TempDates3X')  IS NOT NULL
             DROP TABLE #TempDates3X;


   RAISERROR (N'     6.1    FUND AVK:        Metoda Amortizimit Vefte Konstant (sipas normes se Amortizimit) ', 0, 1) WITH NOWAIT; PRINT '';

      -- 6.1.FUND   AVK:        metoda Amortizimit Vlefte Konstante (sipas normes se amortizimit)




   -- UPDATE #TempDates1
   --    SET AQVleraCum=0, AQVleraMbetStart=0, AQVleraCumStart=0, AMVleraCumStart=0
   --  WHERE KODOPER IN ('CE','BL','RK','RV') AND SEQNUM=1;
   -- SELECT * FROM #TempDates1;RETURN;
 




      -- 6.2.       FILLIM AVM:     metoda Amortizimit Vlefte Mbetur (kujdes filtrohet sipas natyres se kategorise)  
   RAISERROR (N'     6.2    FILLIM AVM:      metoda Amortizimit Vlefte Mbetur (kujdes filtrohet sipas natyres se kategorise) ', 0, 1) WITH NOWAIT; PRINT '';


             -- 6.2.1   Kalkulohet fusha e nr te muajve qe llogaritet amortizimi
   RAISERROR (N'     6.2.1                   Kalkulohet fusha e nr te muajve qe llogaritet amortizimi ', 0, 1) WITH NOWAIT;
      
      UPDATE #TempDates1 
         SET NrMonthsAM    = CASE WHEN TipRow='D' THEN NrMonthsAM ELSE DATEDIFF(m,DateStartAM,DateTransAM)+1 END
       WHERE ISNULL(IsAMVlereMbet,0)=1; 
--    SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM; RETURN;



             -- 6.2.2   AVM: Llogaritja e vleftes se mbetur (fusha AQVleraMbet me vlefta progresive) me metoden rekursive, dhe te dhenat ruhen provizorisht tek tabela #TempDates3Y.
                     -- Test AMVleraMin i mbylljes se Amortizimit eshte variable sipas kategorise dhe asetit. 

   RAISERROR (N'     6.2.2                   AVM: Llogaritja e vleftes se mbetur (fusha AQVleraMbet me vlefta progresive) me metoden rekursive, dhe te dhenat ruhen provizorisht tek tabela #TempDates3Y 
                             Test AMVleraMin i mbylljes se Amortizimit eshte variable sipas kategorise dhe asetit. ', 0, 1) WITH NOWAIT;


       ALTER TABLE  #TempDates1 ADD  AQVleraStart  FLOAT NULL;   
      UPDATE #TempDates1 SET AQVleraStart = AQVleraCum,VLERABS = AQVleraCum;-- - AMVleraCum;
-- SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM; RETURN;

;WITH  SumAm
        AS ( 
             SELECT t.Kod, 
                    t.VLERABS,            -- Ne se do amortizim te plote te vleres se mbetur u punua me 13.08.2020 por 
                                          -- nuk duhet sepse e gjitha kalon ne shpenzim dhe kjo nuk amortizohet. Mbeti funksioni sic ka qene (koment per 6.2.2 )
--                  VLERAAM     = CASE WHEN t.AQVleraStart>t.AMVleraMin              
--                                     THEN ROUND(                   (t.NrMonthsAM*ISNULL(t.AQVleraStart,0)*t.NORMEAM)/1200.0, 2)
--                                     ELSE t.AQVleraStart
--                                END,
--                  AQVleraMbet = CASE WHEN t.AQVleraStart>t.AMVleraMin 
--                                     THEN ROUND(t.AQVleraStart   - (t.NrMonthsAM*ISNULL(t.AQVleraStart,0)*t.NORMEAM)/1200.0, 2)
--                                     ELSE 0
--                                END,
                    VLERAAM     = ROUND(                          (t.NrMonthsAM*ISNULL(t.AQVleraStart,0)*t.NORMEAM)/1200.0, 2),
                    AQVleraMbet = ROUND(       t.AQVleraStart   - (t.NrMonthsAM*ISNULL(t.AQVleraStart,0)*t.NORMEAM)/1200.0, 2),
                    t.SeqNum,
                    t.NrRendor
               FROM #TempDates1 t
              WHERE SeqNum = 1 AND ISNULL(IsAMVlereMbet,0)=1 
              
          UNION ALL

             SELECT t.KOD, 
                    t.VLERABS,
                    VLERAAM     = ROUND(                          (t.NrMonthsAM*ISNULL(A.AQVleraMbet,0) *t.NORMEAM/1200.0), 2),  
                    AQVleraMbet = ROUND(ISNULL(A.AQVleraMbet,0) - (t.NrMonthsAM*ISNULL(A.AQVleraMbet,0) *t.NORMEAM/1200.0), 2),       
                    t.SeqNum,
                    t.NrRendor              
               FROM #TempDates1 t JOIN SumAm A ON A.NRRENDOR=T.NRRENDOR AND A.SeqNum=t.SeqNum - 1                                         -- ON A.KOD=t.KOD AND A.SeqNum = t.SeqNum - 1
              WHERE ISNULL(IsAMVlereMbet,0)=1 AND TipRow<>'D' AND                                                                         -- AND A.SeqNum <> 1
                    t.AQVleraCum>0 AND 
                    A.AQVleraMbet>=0 AND ROUND(A.VLERAAM+A.AQVleraMbet,2) >= AMVleraMin                                                   -- deri AMVleraMin te vleftes
                 -- A.AQVleraMbet>=0 AND ROUND(t.AQVleraCum-(A.VLERAAM+A.AQVleraMbet),2) >= AMVleraMin                                    -- deri AMVleraMin te vleftes
                 -- A.AQVleraMbet>=0 AND ROUND(100-(100*(t.AQVleraCum-(A.VLERAAM+A.AQVleraMbet))/t.AQVleraCum),2) >= 5                    -- deri 5% te vleftes     

           )
           
             SELECT * INTO #TempDates3Y FROM    SumAm    -- WHERE AQVleraMbet>=0 -- Kujdes ....!   Bllokoje ne rekursivitet sepse fryhet kot tabela temporare SumAm
             
OPTION  ( MAXRECURSION 1000 );
    -- SELECT * FROM #TempDates3Y ORDER BY KOD,SEQNUM; RETURN;

       ALTER TABLE #TempDates1 DROP COLUMN AQVleraStart;   

      UPDATE A
         SET A.VLERABS     = A.AQVleraCum, -- -A.AMVleraCum,
             KomentMbyllje = CASE WHEN B.VLERAAM>0   -- Pas 13.08.2020
                                  THEN CASE WHEN (A.AQVleraCum - B.VLERAAM) >= A.AMVleraMin -- (A.AQVleraCum-A.AMVleraCum) - B.VLERAAM >= A.AMVleraMin 
                                            THEN ''
                                            ELSE 'AM deri '+CONVERT(VARCHAR(25),CAST(A.AMVleraMin AS DECIMAL(20,0)))   -- Pra nga Vlera e mbetur minus Amortizim minimal, pjesa tjeter ne shpenzim
                                       END               -- CONVERT(Varchar(50),A.AMVleraMin)
                                  ELSE ''         
                             END,
             A.VLERAAM     = CASE WHEN B.VLERAAM>0   -- Pas 13.08.2020
                                  THEN CASE WHEN (A.AQVleraCum - B.VLERAAM) >= A.AMVleraMin  -- (A.AQVleraCum-A.AMVleraCum) - B.VLERAAM >= A.AMVleraMin 
                                            THEN B.VLERAAM 
                                            ELSE A.AQVleraCum-A.AMVleraCum-A.AMVleraMin   -- Pra nga Vlera e mbetur minus Amortizim minimal, pjesa tjeter ne shpenzim
                                       END 
                                  ELSE B.VLERAAM                                      
                             END, 
                             
          -- A.VLERAAM     = B.VLERAAM,              -- Ishte deri 13.08.2020
                             
             A.AQVleraMbet = B.AQVleraMbet       
             
        FROM #TempDates1 A INNER JOIN #TempDates3Y B ON A.NRRENDOR=B.NRRENDOR AND A.SeqNum=B.SeqNum -- ON A.KOD=B.KOD AND A.SeqNum=B.SeqNum
       WHERE ISNULL(A.IsAMVlereMbet,0)=1;
   -- DELETE   FROM #TempDates1 WHERE VLERAAM<=0;
   -- SELECT * FROM #TempDates3Y ORDER BY KOD,SEQNUM; SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM; RETURN;
   -- SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM; RETURN

          IF OBJECT_ID('TEMPDB..#TempDates3Y')  IS NOT NULL
             DROP TABLE #TempDates3Y;


   RAISERROR (N'     6.2    FUND AVM:        metoda Amortizimit Vlefte Mbetur (kujdes filtrohet sipas natyres se kategorise) ', 0, 1) WITH NOWAIT; PRINT '';
      -- 6.2.FUND   AVM:        metoda Amortizimit Vlefte Mbetur (kujdes filtrohet sipas natyres se kategorise)
      
      
--    UPDATE A -- kjo duhet kur u perdor pjesa e komentuar tek (koment per 6.2.2 )
--       SET A.AMVleraMin=A.AQVleraCum
--      FROM #TempDates1 A 
--     WHERE AQVleraCum=A.VLERAAM;      
 
                                                                             -- Algoritmi nder[pritet kur shuma a amortizimeve te cumuluara arrin pragun minimal
      UPDATE A                                                               -- par Am cumuluar + AmVlere minimale = vleren e asetit  -- shtuar me 14.04.2020
         SET A.VLERAAM     = CASE WHEN A.AMVleraCum+AMVleraMin> A.AQVleraCum THEN 0 ELSE A.VLERAAM     END,
             A.AQVleraMbet = CASE WHEN A.AMVleraCum+AMVleraMin> A.AQVleraCum THEN 0 ELSE A.AQVleraMbet END
--       SET A.VLERAAM     = CASE WHEN A.AMVleraCum+AMVleraMin>=A.AQVleraCum THEN 0 ELSE A.VLERAAM     END, -- ishte perpara 13.08.2020
--           A.AQVleraMbet = CASE WHEN A.AMVleraCum+AMVleraMin>=A.AQVleraCum THEN 0 ELSE A.AQVleraMbet END
        FROM #TempDates1 A 
 --   SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM; RETURN;


      UPDATE A
         SET VLERABS       = A.AQVleraCum - 0 --CASE WHEN ISNULL(A.IsAMVlereMbet,0)=1 THEN A.AMVleraCum ELSE 0 END
        FROM #TempDates1 A 
--    SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM;RETURN;


      UPDATE A
         SET AMVleraPrg    = ISNULL(( SELECT ROUND(SUM(ISNULL(B.VLERAAM,0)),2) 
                                        FROM #TempDates1 B 
                                       WHERE A.NRRENDOR=B.NRRENDOR AND B.SEQNUM<=A.SEQNUM ),0),  -- WHERE A.KOD=B.KOD AND B.SEQNUM<=A.SEQNUM
             AMVleraTot    = AMVleraCum +
                             ISNULL(( SELECT ROUND(SUM(ISNULL(B.VLERAAM,0)),2) 
                                        FROM #TempDates1 B 
                                       WHERE A.NRRENDOR=B.NRRENDOR AND B.SEQNUM<=A.SEQNUM ),0)   -- WHERE A.KOD=B.KOD AND B.SEQNUM<=A.SEQNUM
        FROM #TempDates1 A;
--    SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM;RETURN;



-- 7.        FILLIM kontrolli per mbylljen e Amortizimit (Amortizim deri ne AMVleraMin te vleftes se asetit)
   RAISERROR (N'7.          FILLIM kontrolli per mbylljen e Amortizimit (Amortizim deri ne AMVleraMin te vleftes se asetit) ', 0, 1) WITH NOWAIT; PRINT '';

   
          IF OBJECT_ID('TEMPDB..#TempDatesY')   IS NOT NULL
             DROP TABLE #TempDatesY;



   RAISERROR (N'     7.1    Gjendet i pari resht ku vlera e mbetur e asetit eshte <= AMVleraMin (AMVleraMin llogaritet me siper). Rezultati ruhet tek tabela #TempDatesY.) ', 0, 1) WITH NOWAIT;
             -- 7.1     Gjendet i pari resht ku vlera e mbetur e asetit eshte <= AMVleraMin (AMVleraMin llogaritet me siper). Rezultati ruhet tek tabela #TempDatesY.
    
                                                                     -- Test i mbylljes eshte variable sipas kategorive
      SELECT KOD,NRRENDOR, AQVleraCum, AMVleraMin, AMVleraTot,       -- u korigjua me daten 11.04.2020 dhe                                   
             SeqNum   = ( SELECT SeqNum=MIN(SEQNUM)                  -- zevendesoi ate me poshte te dates 08.04.2020 dhe ate procedure me TOP 108.04.2020 (gabim TOP 1)
                            FROM #TempDates1 B 
                           WHERE A.KOD=B.KOD AND (AQVleraCum-AMVleraMin-AMVleraTot<=0))
                        -- WHERE A.KOD=B.KOD AND (AQVleraCum-AMVleraMin-AMVleraTot>0))
        INTO #TempDatesY
        FROM #TempDates1 A
       WHERE A.SEQNUM = ( SELECT SeqNum=MAX(SEQNUM)
                            FROM #TempDates1 B 
                           WHERE A.KOD=B.KOD AND (AQVleraCum-AMVleraMin-AMVleraTot<=0))        
                        -- WHERE A.KOD=B.KOD AND (AQVleraCum-AMVleraMin-AMVleraTot>0))        
    ORDER BY KOD,NRRENDOR,SEQNUM;
--    SELECT * FROM #TempDatesY;SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM;RETURN;


--    SELECT KOD,NRRENDOR,                                                       -- Test i mbylljes eshte variable sipas kategorive date 08.04.2020
--           SeqNum   = ( SELECT SeqNum=MIN(SEQNUM)
--                          FROM #TempDates1 B 
--                         WHERE A.KOD=B.KOD AND (AQVleraCum-AQVleraMbet>0) AND AQVleraMbet<=AMVleraMin)
--      INTO #TempDatesY
--      FROM #TempDates1 A
--     WHERE A.SEQNUM = ( SELECT SeqNum=MIN(SEQNUM)
--                          FROM #TempDates1 B 
--                         WHERE A.KOD=B.KOD AND (AQVleraCum-AQVleraMbet>0) AND AQVleraMbet<=AMVleraMin)        
--  ORDER BY KOD,NRRENDOR,SEQNUM;


--    SELECT TOP 1 *                                                             -- ishte deri daten 08.04.2020 (gabim TOP 1)
--      INTO #TempDatesY
--      FROM #TempDates1
--     WHERE (AQVleraCum-AQVleraMbet>0) AND AQVleraMbet<=AMVleraMin              -- Test i mbylljes eshte variable sipas kategorive
--  ORDER BY KOD,NRRENDOR,SEQNUM;
    
--    SELECT TOP 1 *,PERQ=ROUND(100-(100*(AQVleraCum-AQVleraMbet)/AQVleraCum),2) 
--      INTO #TempDatesY
--      FROM #TempDates1
--     WHERE (AQVleraCum-AQVleraMbet>0) AND ROUND(100-(100*(AQVleraCum-AQVleraMbet)/AQVleraCum),2)<=5  -- Test 5% i mbylljes
--  ORDER BY KOD,NRRENDOR,SEQNUM;
--    SELECT * FROM #TempDatesY;
    
    
   RAISERROR (N'     7.2    Modifikohen te gjithe rekordet pas kesaj vlefte te pare (kriteri SeqNum) 
                . Reshti pare me <= AMVleraMin mer gjithe vleften e asetit te mbetur per vlefte amortizimi,
                  gjithe rekorder e tjera pas ketij kane vlefte amortizimi zero. ', 0, 1) WITH NOWAIT;
 
 
      UPDATE A                                                                                  -- U korigjua me 10.04.2020. Procedura ishte si me poshte e komentuar
         SET A.VLERAAM     = CASE WHEN A.SEQNUM<B.SEQNUM THEN A.VLERAAM 

                                  WHEN A.SEQNUM=B.SEQNUM THEN                                   -- Ndryshuar me 13.08.2020 zevendesoi komentin
                                       CASE WHEN A.VLERAAM<=A.AMVleraMin 
                                            THEN A.VLERAAM
                                            ELSE A.VLERAAM+(A.AQVleraCum-A.AMVleraMin-A.AMVleraTot) --A.AQVleraMbet
                                       END 
                               -- WHEN A.SEQNUM=B.SEQNUM THEN A.VLERAAM+(A.AQVleraCum-A.AMVleraMin-A.AMVleraTot) --A.AQVleraMbet

                                  ELSE 0
                             END,
             A.AQVleraMbet = CASE WHEN A.SEQNUM<B.SEQNUM THEN A.AQVleraMbet
                                  WHEN A.SEQNUM=B.SEQNUM THEN 0
                             END 
        FROM #TempDates1 A INNER JOIN #TempDatesY B ON A.KOD=B.KOD AND A.NRRENDOR=B.NRRENDOR    -- AND A.SEQNUM=B.SEQNUM 
       WHERE A.SeqNum>0 AND A.TipRow<>'D';
    
      UPDATE A
         SET A.AMVleraPrg  =                (SELECT SUM(T.VLERAAM) FROM #TempDates1 T WHERE T.KOD=A.KOD AND T.SeqNum<=A.SeqNum),
             A.AMVleraTot  = A.AMVleraCum + (SELECT SUM(T.VLERAAM) FROM #TempDates1 T WHERE T.KOD=A.KOD)
        FROM #TempDates1 A 
       WHERE A.SeqNum>0; -- AND A.TipRow<>'D';
--    SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM;RETURN;


                                                                                              
/*    UPDATE A                                                                                  -- Ishte deri 10.04.2020. U zevendesua me proceduren me siper
         SET A.VLERAAM     = CASE WHEN A.SEQNUM<=B.SEQNUM   THEN A.VLERAAM 
                                  WHEN A.SEQNUM =B.SEQNUM+1 THEN A.VLERAAM+A.AQVleraMbet
                                  ELSE 0
                             END,
             A.AQVleraMbet = CASE WHEN A.SEQNUM<=B.SEQNUM   THEN A.AQVleraMbet
                                  WHEN A.SEQNUM>=B.SEQNUM+1 THEN 0
                             END,
             A.AMVleraPrg  = CASE WHEN A.SEQNUM<=B.SEQNUM   THEN A.AMVleraPrg
                                  WHEN A.SEQNUM =B.SEQNUM+1 THEN A.AMVleraPrg+A.VLERAAM+A.AQVleraMbet
                                  ELSE 0
                             END,
             A.AMVleraTot  = CASE WHEN A.SEQNUM<=B.SEQNUM   THEN A.AMVleraTot
                                  WHEN A.SEQNUM =B.SEQNUM+1 THEN A.AMVleraTot+A.VLERAAM+A.AQVleraMbet
                                  ELSE 0
                             END     
        FROM #TempDates1 A INNER JOIN #TempDatesY B ON A.KOD=B.KOD AND A.NRRENDOR=B.NRRENDOR    -- AND A.SEQNUM=B.SEQNUM 
       WHERE A.SeqNum>0 AND A.TipRow<>'D'; */

          IF OBJECT_ID('TEMPDB..#TempDatesY')   IS NOT NULL
             DROP TABLE #TempDatesY;
    
   
             -- 7.3     Statistika ne Reshtin Diference   
   RAISERROR (N'     7.3    Statistika ne Reshtin Diference    ', 0, 1) WITH NOWAIT;
   
      UPDATE A                                                           
         SET VLERAAM       =  ISNULL((SELECT SUM(VLERAAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0), -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
             AQVleraMbet   = (AQVleraCum ) -- - AMVleraCum
                              -                                          
                              ISNULL((SELECT SUM(VLERAAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0)  -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
        FROM #TempDates1 A
       WHERE TipRow='D';

   

             -- 7.4     Fshihen reshtat per te cilat ka perfunduar Amortizimi 
   RAISERROR (N'     7.4    Fshihen reshtat per te cilat ka perfunduar Amortizimi    ', 0, 1) WITH NOWAIT; PRINT '';
        
      DELETE FROM #TempDates1 WHERE (SeqNum>0 AND TipRow<>'D') AND VLERAAM <= 0;


-- 7.FUND    Kontrolli per mbylljen e Amortizimit  (Amortizim deri ne AMVleraMin te vleftes se asetit)
   RAISERROR (N'7.          FUND kontrolli per mbylljen e Amortizimit (Amortizim deri ne AMVleraMin te vleftes se asetit) ', 0, 1) WITH NOWAIT; PRINT '';


   
                                                                                                                -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
      SELECT @VleraAM      = SUM(CASE WHEN TipRow='D' THEN 0 ELSE VLERAAM END),
             @VleraAktiv   = SUM(CASE WHEN SEQNUM=0                                             THEN   VLERABS
                                      WHEN SEQNUM=1 AND (KODOPER IN ('BL','RK','CE','RV','SI')) THEN   VLERABS
                                      WHEN SEQNUM=1 AND (KODOPER IN ('CR'))                     THEN 0-VLERABS  -- 'SH','JP',  nuk jane pjese e te dhenave ????
                                   -- WHEN SEQNUM=1 AND (KODOPER IN ('AM','NP'))                THEN 0
                                      ELSE                                                           0
                                 END),
             @NrKartelaAM  = SUM(CASE WHEN SEQNUM=1 THEN 1 ELSE 0 END) 
        FROM #TempDates1;
--    SELECT VLERABS,KODOPER,KOD,SEQNUM FROM #TempDates1 WHERE SEQNUM=1 AND (KODOPER IN ('BL','RK','RV','CE','SI')) ORDER BY KOD,SEQNUM; RETURN;
--     PRINT @VleraAktiv;    



-- 8.              FILLIM Komente te nevojeshme per periudhat e Amortizimit
   RAISERROR (N'8           Komente te nevojeshme per periudhat e Amortizimit ', 0, 1) WITH NOWAIT; PRINT '';
            
--                 Shpjegim:  DATEPART (dd, DATEADD(dd, DATEPART(dd, DATEADD(mm, 1, T.DateStartAM)) * -1, DATEADD(mm, 1, @day)))   -- Nr i diteve te muajit
--                           (DATEDIFF(dd,T.DateStartAM,T.DateTransAM)+1)                                                          -- Diference dite


      UPDATE T
         SET PERSHKRIMAM   = CASE WHEN YEAR(T.DateStartAM)=YEAR(T.DateTransAM)
                                       THEN CASE WHEN M1.Month_Name=M2.Month_Name  
                                                 THEN M2.Month_Name + ' '+SUBSTRING(CAST(YEAR(T.DateStartAM) AS VARCHAR),1,4)
                                                      +
                                                      CASE WHEN DATEPART(dd, DATEADD(dd, DATEPART(dd, DATEADD(mm, 1, T.DateStartAM)) * -1, DATEADD(mm, 1, T.DateStartAM)))
                                                                =
                                                               (DATEDIFF(dd,T.DateStartAM,T.DateTransAM)+1)
                                                           THEN ''
                                                           ELSE ', '+CONVERT(VARCHAR,DATEDIFF(dd, T.DateStartAM,T.DateTransAM)+1)+' dite'
                                                      END 
                                                 
                                                 ELSE 
                                                      M1.Month_Name + 
                                                      ' - '+
                                                      M2.Month_Name + ' '+SUBSTRING(CAST(YEAR(T.DateTransAM) AS VARCHAR),1,4)
                                            END               
                                       
                                  ELSE                                                                             
                                       M1.Month_Name+' '+SUBSTRING(CAST(YEAR(T.DateStartAM) AS VARCHAR),1,4)+' - '+
                                       M2.Month_Name+' '+SUBSTRING(CAST(YEAR(T.DateTransAM) AS VARCHAR),1,4)+
                                       CASE WHEN M1.Month_Name=M2.Month_Name
                                            THEN CASE WHEN DATEPART(dd, DATEADD(dd, DATEPART(dd, DATEADD(mm, 1, T.DateStartAM)) * -1, DATEADD(mm, 1, T.DateStartAM)))
                                                           =
                                                          (DATEDIFF(dd,T.DateStartAM,T.DateTransAM)+1)
                                                      THEN ''
                                                      ELSE ', '+CONVERT(VARCHAR,DATEDIFF(dd, T.DateStartAM,T.DateTransAM)+1)+' dite'
                                                 END 
                                            ELSE ''
                                       END          

                             END
        FROM #TempDates1  T  INNER JOIN #MonthNames M1 ON MONTH(T.DateStartAM)=M1.Month_Number
                             INNER JOIN #MonthNames M2 ON MONTH(T.DateTransAM)=M2.Month_Number;
   -- SELECT * FROM #TempDates1 ORDER BY KOD,DATEDOK,SEQNUM; RETURN;


             -- 8.2     Fusha per te ruajtur ose kolauduar algoritmim (per elemente sqarues ne algoritmin e Amortizimit)
         
       ALTER TABLE  #TempDates1 ADD  YMD           Varchar(100) NULL;
       ALTER TABLE  #TempDates1 ADD  Yr            Varchar(20)  NULL;
       ALTER TABLE  #TempDates1 ADD  Mn            Varchar(20)  NULL;
       ALTER TABLE  #TempDates1 ADD  Dy            Varchar(20)  NULL;   
       ALTER TABLE  #TempDates1 ADD  KomentAM      Varchar(100) NULL;  
       
   RAISERROR (N'A. ****     FUND Amortizimi     **** ', 0, 1) WITH NOWAIT; PRINT CHAR(13)+CHAR(13);




          -- Kur @pOper='D' behet Display i tabeles se krijuar; ne rastin @pOper='NOTDISPL' vetem sa krijohete tabele por nuk afishohet. 
          -- Rasti me @pOper='NOTDISPL' duhet tek krahesimi i metodave ne vlefte per amortizimin (shiko dbo.Isd_AQAMDisplay2Metodes)


          IF NOT (@pOper='D' OR @pOper='NOTDISPL')
             BEGIN
               GOTO CREATEAM; 
             END;
   



             
--                  AFISHIMI  VIEW-se  PER  AMORTIZIMIN  E  AKTIVEVE        
   RAISERROR (N'B. ****     AFISHIMI  VIEW-se  PER  AMORTIZIMIN  E  AKTIVEVE     **** ', 0, 1) WITH NOWAIT; PRINT '';

/*   DECLARE @sFieldsNoDispl  Varchar(500);
         SET @sFieldsNoDispl  = 'Njesi,SeqNum,AQVleraCum,AQVleraMbet,AMVleraCum,AMDateFundit,IsAmVlereMbet,'+
                                'GjendjeAktiv,Kategori,Grupim,KODLM,DateEnd,NrMonthsAM,KodAF,YMD,Yr,Mn,Dy,'+
                                'NrKartelaAM,TotalAktiv,TotalAM,AMVleraMin,TipRow,NrRendor,SeqYear,TRow,TagNr,'+
                                'GjendjeAktivi,FieldsNoDisplay,'; */

      SELECT Zgjedhur,   
             A.Kod,A.Pershkrim,A.Njesi,A.DateDok,A.KodOper,
             A.SeqNum,
             A.NormeAM,
             VleraBS          = ROUND(A.VleraBS,0),
             VleraAM          = ROUND(CASE WHEN A.TipRow='D'                                      -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                                           THEN ISNULL((SELECT SUM(B.VLERAAM)     FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0)
                                           ELSE A.VLERAAM
                                      END,0),
             A.DateStartAM,
             DateTransAM      = CASE WHEN A.TipRow='D'                                      -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                                     THEN ISNULL((SELECT MAX(B.DATETRANSAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),A.DateStartAM)
                                     ELSE A.DATETRANSAM
                                END,
             PershkrimAM      = A.PershkrimAM, 
             KomentAM, 
             A.KomentMbyllje,
             AQVleraCum       = ROUND(CASE WHEN A.TipRow='D' THEN A.AQVleraCum ELSE 0 END,0),
             AQVleraMbet      = ROUND(A.AQVleraMbet,0),
                
             AMVleraCum       = ROUND(CASE WHEN A.TipRow='D' 
                                           THEN A.AMVleraCum+ISNULL((SELECT SUM(B.VLERAAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0) 
                                           ELSE 0 
                                      END,0),
             AMDateFundit     = CASE WHEN A.TipRow='D'                                                  -- A.DateAMLast,   
                                     THEN CONVERT(VARCHAR(10),ISNULL((SELECT MAX(B.DATETRANSAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),A.DateStartAM),104) 
                                     ELSE '' 
                                END,             
             A.IsAMVlereMbet,
             Menyra           = CASE WHEN A.TipRow='D' 
                                     THEN CASE WHEN ISNULL(A.IsAMVlereMbet,0)=0 THEN 'AVK' ELSE 'AVM' END
                                     ELSE ''
                                END,
             GjendjeAktivi    = CASE WHEN ISNULL(A.KodMbyllje,'')='SH' THEN 'Shitur' 
                                     WHEN ISNULL(A.KodMbyllje,'')='JP' THEN 'Jashte perdorimit'
                                     WHEN ISNULL(A.KodMbyllje,'')='CR' THEN 'CRegjistrim'
                                     ELSE ''
                                END,
             Kategori         = CASE WHEN A.TipRow='D' THEN A.KATEGORI+' - '+R2.PERSHKRIM ELSE '' END,  -- PERSHKRIMKTG, -- A.KATEGORI,A.GRUP,
             Grupim           = CASE WHEN A.TipRow='D' THEN A.GRUP    +' - '+R3.PERSHKRIM ELSE '' END,  -- PERSHKRIMGRP
             R1.KodLM,
             DateEnd          = A.DATEEND,
             NrMonthsAM       = CASE WHEN A.TipRow='D'                                     -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                                     THEN ISNULL((SELECT SUM(B.NRMONTHSAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0)
                                     ELSE A.NRMONTHSAM
                                END, -- A.NRMONTHSAM
             KodAF            = A.KOD +
                                CASE WHEN (@pDepKart=1  AND ISNULL(R1.DEP,'')<>'') OR (@pListKart=1 AND ISNULL(R1.LIST,'')<>'') 
                                     THEN '.'+ISNULL(R1.DEP,'') 
                                     ELSE '' 
                                END   +
                                CASE WHEN @pListKart=1  AND ISNULL(R1.LIST,'')<>'' 
                                     THEN '.'+ISNULL(R1.LIST,'') 
                                     ELSE '' 
                                END,
             A.YMD, A.Yr, A.Mn, A.Dy, 
             NrKartelaAM      = @NrKartelaAM, 
             TotalAktiv       = @VleraAktiv,
             TotalAM          = @VleraAM, 
             AMVleraMin,  
             TipRow,  
             A.NrRendor, 
             SeqYear          = CASE WHEN A.TipRow='D' OR R2.NRTIMEAM=12
                                     THEN 0         -- OVER (PARTITION BY A.KOD, YEAR(A.DATETRANSAM) ORDER BY A.KOD,A.DATETRANSAM)
                                     ELSE ROW_NUMBER() OVER (PARTITION BY A.NRRENDOR, YEAR(A.DATETRANSAM) ORDER BY A.NRRENDOR,A.DATETRANSAM)
                                END,
             TRow             = CAST(0 AS BIT),
             TagNr            = CAST(0 AS BIT)
--           FieldsNoDisplay  = @sFieldsNoDispl       -- te futet me vone
             
        INTO #TempAmortizim
        
        FROM #TempDates1  A  INNER JOIN AQKARTELA      R1 ON A.KOD=R1.KOD
                             LEFT  JOIN #AQKategoriTmp R2 ON A.KATEGORI=R2.KOD
                             LEFT  JOIN AQGRUP         R3 ON A.GRUP=R3.KOD
   UNION ALL
   
      SELECT Zgjedhur,
             A.Kod,A.Pershkrim,A.Njesi,A.DateDok,KodOper = '  ',
             SeqNum           = 0,
             NormeAM          = A.NORMEAM,
             VleraBS          = ROUND(A.VLERABS,0),
             VleraAM          = ROUND(A.AMVleraCum,0),
             A.DateStartAM,
             DateTransAM      = CASE WHEN A.TipRow='D' OR A.SEQNUM=1                        -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                                     THEN ISNULL((SELECT MAX(B.DateTransAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),A.DateStartAM)
                                     ELSE A.DATETRANSAM
                                END,
             PershkrimAM      = '',                                                         -- WHERE A.KOD=B.KOD AND B.TipRow='D'
             KomentAM         =           ISNULL((SELECT KOMENTAM           FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow='D'),A.KOMENTAM),
             KomentMbyllje    = '',
             AQVleraCum       = ROUND(A.AQVleraCum,0),
             AQVleraMbet      = ROUND(CASE WHEN A.IsAMVlereMbet=1 THEN A.VLERABS ELSE A.AQVleraCum-A.AMVleraCum END,0),
             
             AMVleraCum       = ROUND(A.AMVleraCum,0),
             AMDateFundit     = CONVERT(VARCHAR(10),A.DateAMLast,104),                                  -- A.DateAMLast,
             A.IsAMVlereMbet,
             Menyra           = CASE WHEN ISNULL(A.IsAMVlereMbet,0)=0  THEN 'AVK' ELSE 'AVM' END,
             GjendjeAktivi    = CASE WHEN ISNULL(A.KodMbyllje,'')='SH' THEN 'Shitur' 
                                     WHEN ISNULL(A.KodMbyllje,'')='JP' THEN 'Jashte perdorimit'
                                     WHEN ISNULL(A.KodMbyllje,'')='CR' THEN 'CRegjistrim'
                                     ELSE ''
                                END,
             Kategori         = A.KATEGORI+' - '+R2.PERSHKRIM,  -- PERSHKRIMKTG, -- A.KATEGORI,A.GRUP,
             Grupim           = A.GRUP    +' - '+R3.PERSHKRIM,  -- PERSHKRIMGRP
             R1.KodLM,
             DateEnd          = A.DateEnd,                                       -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
             NrMonthsAM       = ISNULL((SELECT SUM(B.NRMONTHSAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0),
                             -- ISNULL((SELECT B.NRMONTHSAM FROM #TempDates1 B WHERE A.KOD=B.KOD AND B.TipRow='D'),0),
             KodAF            = A.KOD +
                                CASE WHEN (@pDepKart=1  AND ISNULL(R1.DEP,'')<>'') OR (@pListKart=1 AND ISNULL(R1.LIST,'')<>'') 
                                     THEN '.'+ISNULL(R1.DEP,'') 
                                     ELSE '' 
                                END  + 
                                CASE WHEN @pListKart=1  AND ISNULL(R1.LIST,'')<>'' 
                                     THEN '.'+ISNULL(R1.LIST,'') 
                                     ELSE '' 
                                END,
             A.YMD, A.Yr, A.Mn, A.Dy,        
             NrKartelaAM      = @NrKartelaAM, 
             TotalAktiv       = @VleraAktiv,
             TotalAM          = @VleraAM,
             AMVleraMin,  
             TipRow,
             A.NrRendor,   
             SeqYear          = 0,
             TRow             = CAST(1 AS BIT),
             TagNr            = CAST(0 AS BIT)
--           FieldsNoDisplay  = @sFieldsNoDispl      -- te futet me vone
             
        FROM #TempDates1  A  INNER JOIN AQKARTELA      R1 ON A.KOD=R1.KOD
                             LEFT  JOIN #AQKategoriTmp R2 ON A.KATEGORI=R2.KOD
                             LEFT  JOIN AQGRUP         R3 ON A.GRUP=R3.KOD
       WHERE A.SeqNum=1 
    ORDER BY Kod, SeqNum;


      UPDATE #TempAmortizim 
         SET Yr  = '0', Mn = '0', Dy = '0',
             YMD = dbo.Isd_DaysMonthsYears(CONVERT(VARCHAR, DateStartAM,103), CONVERT(VARCHAR, DateTransAM +1 , 103),1);
       
      UPDATE #TempAmortizim 
         SET Yr  = CASE WHEN                    CHARINDEX('y',YMD)>0 AND CHARINDEX('m',YMD)>0
                             THEN SUBSTRING(YMD,CHARINDEX('y',YMD)+1,CHARINDEX('m',YMD)-CHARINDEX('y',YMD)-1) 
                        WHEN                    CHARINDEX('y',YMD)>0 AND CHARINDEX('d',YMD)>0     
                             THEN SUBSTRING(YMD,CHARINDEX('y',YMD)+1,CHARINDEX('d',YMD)-CHARINDEX('y',YMD)-1)
                        WHEN                    CHARINDEX('y',YMD)>0                             
                             THEN SUBSTRING(YMD,CHARINDEX('y',YMD)+1,LEN(YMD))
                        ELSE      '0' 
                   END, 
             Mn  = CASE WHEN                    CHARINDEX('m',YMD)>0 AND CHARINDEX('d',YMD)>0 
                             THEN SUBSTRING(YMD,CHARINDEX('m',YMD)+1,CHARINDEX('d',YMD)-CHARINDEX('m',YMD)-1) 
                        WHEN                    CHARINDEX('m',YMD)>0                               
                             THEN SUBSTRING(YMD,CHARINDEX('m',YMD)+1,LEN(YMD))
                        ELSE      '0' 
                   END, 
             Dy  = CASE WHEN                    CHARINDEX('d',YMD)>0 
                             THEN SUBSTRING(YMD,CHARINDEX('d',YMD)+1,LEN(YMD))
                         ELSE     '0'     
                    END
        FROM #TempAmortizim;
        
      UPDATE T
         SET KOMENTAM      = SUBSTRING(REPLACE(CASE WHEN Yr<>'0' THEN ','+Yr+CASE WHEN Yr=1 THEN ' vit ' ELSE ' vite ' END ELSE '' END +
                                               CASE WHEN Mn<>'0' THEN ','+Mn+' muaj ' ELSE '' END +
                                               CASE WHEN Dy<>'0' THEN ','+Dy+' dite ' ELSE '' END,' ,',','),2,100)+
                             + 
                             CASE WHEN ISNULL(T.KomentMbyllje,'')<>'' THEN ' - '+T.KomentMbyllje ELSE '' END,
             PERSHKRIMAM   = SUBSTRING(M1.Month_Name,1,10)+
                                       CASE WHEN YEAR(T.DateStartAM)<>YEAR(T.DateTransAM) THEN ' '+SUBSTRING(CAST(YEAR(T.DateStartAM) AS VARCHAR),3,2) ELSE '' END
                                       +
                                      ' - '+SUBSTRING(M2.Month_Name,1,10)+' '+SUBSTRING(CAST(YEAR(T.DateTransAM) AS VARCHAR),3,2)
        FROM #TempAmortizim T INNER JOIN #MonthNames M1 ON MONTH(T.DateStartAM)=M1.Month_Number
                              INNER JOIN #MonthNames M2 ON MONTH(T.DateTransAM)=M2.Month_Number;

       ALTER TABLE #TempAmortizim DROP COLUMN KomentMbyllje;


         SET @sSql = '

          IF OBJECT_ID(''TEMPDB..'+@sTableTmp+''') IS NOT NULL
             DROP TABLE '+@sTableTmp+';
             
      SELECT * INTO '+@sTableTmp+' FROM #TempAmortizim ORDER BY KOD, NRRENDOR,SEQNUM; 
   -- SELECT * FROM '+@sTableTmp+' ORDER BY KOD, DATEDOK, SEQNUM; ';
      

          -- Kur @pOper='D' behet Display i tabeles; ne rastin @pOper='NOTDISPL' vetem sa krijohete tabele. 
          -- Rasti me @pOper='NOTDISPL' duhet tek krahesimi i metodave ne vlefte per amortizimin (shiko dbo.Isd_AQAMDisplay2Metodes)
          
          IF @pOper='D' 
             SET @sSql = Replace(@sSql,'-- ','   ');    

       EXEC (@sSql);
    

   RAISERROR (N'B. ****     FUND AFISHIMI  VIEW-se  PER  AMORTIZIMIN  E  AKTIVEVE     **** ', 0, 1) WITH NOWAIT; PRINT CHAR(13)+CHAR(13);
  

        GOTO FUNDAM;    





CREATEAM:

--                  Krijimi i dokumentit AQ per amortizimin dhe kalimi i ketij ne databaze te Nd/jes
   RAISERROR (N'C. ****     Krijimi i dokumentit AQ per amortizimin dhe kalimi i ketij ne databaze te Nd/jes     **** ', 0, 1) WITH NOWAIT; PRINT '';

      UPDATE #TempDates1 
         SET Yr  = '0', Mn = '0', Dy = '0',
             YMD = dbo.Isd_DaysMonthsYears(CONVERT(VARCHAR, DateStartAM,103), CONVERT(VARCHAR, DateTransAM +1 , 103),1);
       
      UPDATE #TempDates1 
         SET Yr  = CASE WHEN CHARINDEX('y',YMD)>0 AND CHARINDEX('m',YMD)>0
                             THEN SUBSTRING(YMD,CHARINDEX('y',YMD)+1,CHARINDEX('m',YMD)-CHARINDEX('y',YMD)-1) 
                        WHEN CHARINDEX('y',YMD)>0 AND CHARINDEX('d',YMD)>0     
                             THEN SUBSTRING(YMD,CHARINDEX('y',YMD)+1,CHARINDEX('d',YMD)-CHARINDEX('y',YMD)-1)
                        WHEN CHARINDEX('y',YMD)>0                             
                             THEN SUBSTRING(YMD,CHARINDEX('y',YMD)+1,LEN(YMD))
                        ELSE '0' 
                   END, 
             Mn  = CASE WHEN CHARINDEX('m',YMD)>0 AND CHARINDEX('d',YMD)>0 
                             THEN SUBSTRING(YMD,CHARINDEX('m',YMD)+1,CHARINDEX('d',YMD)-CHARINDEX('m',YMD)-1) 
                        WHEN CHARINDEX('m',YMD)>0                               
                             THEN SUBSTRING(YMD,CHARINDEX('m',YMD)+1,LEN(YMD))
                        ELSE '0' 
                   END, 
             Dy  = CASE WHEN CHARINDEX('d',YMD)>0 
                             THEN SUBSTRING(YMD,CHARINDEX('d',YMD)+1,LEN(YMD))
                         ELSE '0'     
                    END
        FROM #TempDates1;
        
      UPDATE T
         SET KOMENTAM      = SUBSTRING(REPLACE(CASE WHEN Yr<>'0' THEN ','+Yr+CASE WHEN Yr=1 THEN ' vit ' ELSE ' vite ' END ELSE '' END +
                                               CASE WHEN Mn<>'0' THEN ','+Mn+' muaj ' ELSE '' END +
                                               CASE WHEN Dy<>'0' THEN ','+Dy+' dite ' ELSE '' END,' ,',','),2,100),
             PERSHKRIMAM   = SUBSTRING(M1.Month_Name,1,10)+
                                       CASE WHEN YEAR(T.DateStartAM)<>YEAR(T.DateTransAM) THEN ' '+SUBSTRING(CAST(YEAR(T.DateStartAM) AS VARCHAR),3,2) ELSE '' END
                                       +
                                      ' - '+SUBSTRING(M2.Month_Name,1,10)+' '+SUBSTRING(CAST(YEAR(T.DateTransAM) AS VARCHAR),3,2)
        FROM #TempDates1    T INNER JOIN #MonthNames M1 ON MONTH(T.DateStartAM)=M1.Month_Number
                              INNER JOIN #MonthNames M2 ON MONTH(T.DateTransAM)=M2.Month_Number;
                              
                              
                              
      INSERT  INTO AQ
             (DATEDOK)
      VALUES (@DateDok);

         SET @NrRendor     = @@IDENTITY;

      UPDATE AQ
         SET NRDOK         = (SELECT ISNULL(MAX(NRDOK),0)+1 FROM AQ WHERE YEAR(@DateDok)=YEAR(DATEDOK)),
             DATEDOK       = @DateDok,
             DST           = 'AM',
             NRFRAKS       = 0,
             NRMAG         = 0,
             KMAG          = '',
             TIP           = 'X',
             SHENIM1       = @Shenim1,
             SHENIM2       = @Shenim2,
             SHENIM3       = '',
             SHENIM4       = '',
             KMON          = '',
             KURS1         = 1,
             KURS2         = 1,
             DOK_JB        = 0,
             NRDFK         = 0,
             USI           = @pUser,
             USM           = @pUser
       WHERE NRRENDOR      = @NrRendor;


      INSERT INTO AQSCR
            (NRD,      KOD,KODAF,KARTLLG,PERSHKRIM,NJESI,NJESINV,DATEOPER,VLERABS,VLERAAM,NORMEAM,
             BC,KOMENT,SASI,CMIMBS,KODOPER,KOEFSHB,KMON,TIPKLL,NRRENDKLLG)
      SELECT @NrRendor,
             KOD           = A.KOD                                                      + '.'+
                             CASE WHEN @pDepKart=1  THEN ISNULL(R1.DEP,'')  ELSE '' END + '.'+
                             CASE WHEN @pListKart=1 THEN ISNULL(R1.LIST,'') ELSE '' END + '..',
             KODAF         = A.KOD +
                             CASE WHEN (@pDepKart=1  AND ISNULL(R1.DEP,'')<>'') OR (@pListKart=1 AND ISNULL(R1.LIST,'')<>'') 
                                  THEN '.'+ISNULL(R1.DEP,'') 
                                  ELSE '' 
                             END   +
                             CASE WHEN @pListKart=1  AND ISNULL(R1.LIST,'')<>'' 
                                  THEN '.'+ISNULL(R1.LIST,'') 
                                  ELSE '' 
                             END,
             A.KOD,A.PERSHKRIM,A.NJESI,NJESINV=A.NJESI,
             A.DateTransAM,
             VLERABS       = ROUND(CAST(VLERABS AS DECIMAL(34,4)),2),--CONVERT(DECIMAL(18,2),A.VLERABS),                                    -- +A.AQVleraCum,
             VLERAAM       = ROUND(CONVERT(DECIMAL(34,4),A.VLERAAM),2),
             A.NORMEAM,
             R1.BC,
             PERSHKRIMAM   = RTRIM(LTRIM(A.PERSHKRIMAM))+CASE WHEN ISNULL(A.KomentMbyllje,'')<>'' THEN ' - '+A.KomentMbyllje ELSE '' END,
             SASI          = 1,
             CMIMBS        = ROUND(CONVERT(DECIMAL(34,4),A.VLERABS),2),
             KODOPER       = 'AM',
             KOEFSHB       = 1,
             KMON          = '',
             TIPKLL        = 'X',
             NRRENDKLLG    = R1.NRRENDOR
        FROM #TempDates1 A LEFT JOIN AQKARTELA R1 ON A.KOD=R1.KOD
       WHERE A.SEQNUM>0 AND A.TipRow<>'D'
    ORDER BY A.KOD, A.SEQNUM;

   RAISERROR (N'C. ****     FUND Krijimi i dokumentit AQ per amortizimin dhe kalimi i ketij ne databaze te Nd/jes     **** ', 0, 1) WITH NOWAIT; PRINT CHAR(13)+CHAR(13);


FUNDAM:
    
   RAISERROR (N'D. ****     Fshirje te tabelave temporare dhe perfundim     **** ', 0, 1) WITH NOWAIT; PRINT '';
    

          IF OBJECT_ID('TEMPDB..#AQKategoriTmp') IS NOT NULL 
             DROP TABLE #AQKategoriTmp;
          IF OBJECT_ID('TEMPDB..#TempDtAM')      IS NOT NULL
             DROP TABLE #TempDtAM;
          IF OBJECT_ID('TEMPDB..#TempScr')       IS NOT NULL
             DROP TABLE #TempScr;
          IF OBJECT_ID('TEMPDB..#TempShitje')    IS NOT NULL
             DROP TABLE #TempShitje;
          IF OBJECT_ID('TEMPDB..#TempSistemim')  IS NOT NULL
             DROP TABLE #TempSistemim;
          IF OBJECT_ID('TEMPDB..#TempDates')     IS NOT NULL
             DROP TABLE #TempDates;
          IF OBJECT_ID('TEMPDB..#TempDates1')    IS NOT NULL
             DROP TABLE #TempDates1;
          IF OBJECT_ID('TEMPDB..#TempDates2')    IS NOT NULL
             DROP TABLE #TempDates2;
          IF OBJECT_ID('TEMPDB..#TempDates3X')   IS NOT NULL
             DROP TABLE #TempDates3X;
          IF OBJECT_ID('TEMPDB..#TempDates3Y')   IS NOT NULL
             DROP TABLE #TempDates3Y;
          IF OBJECT_ID('TEMPDB..#TempSeri')      IS NOT NULL
             DROP TABLE #TempSeri;
          IF OBJECT_ID('TempDB..#TempSeriX')     IS NOT NULL
             DROP TABLE #TempSeriX;
          IF OBJECT_ID('TEMPDB..#MonthNames')    IS NOT NULL
             DROP TABLE #MonthNames;
          IF OBJECT_ID('Tempdb..#MonthsTable')   IS NOT NULL  
             DROP TABLE #MonthsTable;
                        

--                  Shenime dhe procedura ndihmese per kolaudim .....

--    SELECT Dt.Kod, DATEADD(d, Seq.SeqNum, Dt.DateStart)           -- Dite
--      FROM #TempDates Dt LEFT OUTER JOIN
--                                        ( SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS SeqNum
--                                            FROM #TempDates
--                                           ) Seq
--                                          ON SeqNum <= DATEDIFF(d, Dt.DateStart, Dt.DateEnd);

--    SELECT Dt.Kod, DATEADD(m, Seq.SeQnum, Dt.DateStart)           -- 1 Muaj
--                                          ON SeqNum <= DATEDIFF(m, Dt.DateStart, Dt.DateEnd);

--    SELECT Dt.Kod, DATEADD(q, Seq.SeqNum, Dt.DateStart)           -- 3 Muaj
--                                          ON SeqNum <= DATEDIFF(q, Dt.DateStart, Dt.DateEnd);
              
--    SELECT DATEDOK,            -- Data e fundit e muajit pasardhes se veprimit
--           DATETRANS1=DATEADD(d,-1,  DATEADD(m,  1,  DATEADD(m,1,CONVERT(DATETIME,'01/'+CAST(MONTH(DATEDOK) AS VARCHAR(2))+'/'+CAST(YEAR(DATEDOK) AS VARCHAR(4)),103))  )  ) 
--           DATETRANS2=DATEADD(d,-1,  DATEADD(q,  1,  DATEADD(m,1,CONVERT(DATETIME,'01/'+CAST(MONTH(DATEDOK) AS VARCHAR(2))+'/'+CAST(YEAR(DATEDOK) AS VARCHAR(4)),103))  )  )  -- 3 mujore
--           DATETRANS3=DATEADD(d,-1,  DATEADD(m,  4,  DATEADD(m,1,CONVERT(DATETIME,'01/'+CAST(MONTH(DATEDOK) AS VARCHAR(2))+'/'+CAST(YEAR(DATEDOK) AS VARCHAR(4)),103))  )  )  -- 4 mujore
--           DATETRANS4=DATEADD(d,-1,  DATEADD(m,  6,  DATEADD(m,1,CONVERT(DATETIME,'01/'+CAST(MONTH(DATEDOK) AS VARCHAR(2))+'/'+CAST(YEAR(DATEDOK) AS VARCHAR(4)),103))  )  )  -- 6 mujore
--           DATETRANS5=DATEADD(d,-1 , DATEADD(yy, 1,  DATEADD(m,1,CONVERT(DATETIME,'01/'+CAST(MONTH(DATEDOK) AS VARCHAR(2))+'/'+CAST(YEAR(DATEDOK) AS VARCHAR(4)),103))  )  )  -- 1 vit
--      FROM AQ

GO
