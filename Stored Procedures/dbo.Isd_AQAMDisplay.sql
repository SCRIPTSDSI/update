SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- Kujdes: Ne proces dhe po kolaudohet tek JO20 tek 10.101.1.9    26.02.2021

-- Ndrysho deklarimin per vlerat numerike ne Decimal (jo Float)
-- U zevendesua Float me Decimal(30,2) 18.03.2021


CREATE        procedure [dbo].[Isd_AQAMDisplay]  -- Kolaudim me kufij per mbylljen e amortizimit: vlere minimale (jo fix 5%)
(                                               -- Per kufizimi 5% per mbylljen e amortizimit shiko Isd_AQAMDisplay_01
  @pDateEnd    Varchar(20),                      
  @pDateDok    Varchar(20),
  @pShenim1    Varchar(150),
  @pShenim2    Varchar(150),
  @pWhere      Varchar(Max),
  @pOper       Varchar(10),
  @pDepKart    Int,                             -- Kujdes ! shiko poshte tek shenimi:    -- New 19.04.2019
  @pListKart   Int,
  @pModelAM    Int,                             -- @pModelAM=0 - > Amortizimi modeli 1,    @pModelAM=1 - > Amortizimi modeli 2 (SKK=0,SNK=1)
  @pUser       Varchar(30),
  @pTableTmp   Varchar(30)
)

AS   -- EXEC dbo.Isd_AQAMDisplay '31/12/2022','31/12/2018','Amortizim vjetor','Amortizim makineri','R1.KOD=''AS000001''','D',0,0,0,'ADMIN','##AA';
   
/*   DECLARE @VleraBs   Float,                  -- Kalkulator per kolaudim
             @NrMuaj    Int,
             @NrDays    Int,
             @Norme     Int;
      SELECT @VleraBs = 600000.0, @NrMuaj = 6, @NrDays = 37, @Norme = 25;
         
      SELECT AMTotal=(@NrMuaj*AMMuaj*1.0)+(@NrDays*AMDit), AMVit, AMMuaj, AMDit, Vlera=@VleraBs, NrMuaj=@NrMuaj, NrDit=@NrDays,Norme=@Norme
        FROM
           ( SELECT AMVit=(@VleraBs*@Norme)/100, AMMuaj=((@VleraBs*@Norme)/1200), AMDit=(@VleraBs*@Norme)/36500 ) A; */   
   
         SET NOCOUNT ON

     DECLARE @sSql           nVarchar(Max),
             @sSql1          nVarchar(Max),
             @NrRendor       Int,
             @sWhere         Varchar(Max),
             @VleraAktiv     Decimal(30,2),
             @VleraAM        Decimal(30,2),
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


--           Tabela temporare

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
      
      SELECT KOD=KARTLLG, AQDateShitje=DATEOPER,KODOPER                                INTO #TempShitje    FROM AQSCR WHERE 1=2;

      SELECT KOD=KARTLLG, AQDateSistemim=DATEOPER, AQVleraSistemim=VLERAAM             INTO #TempSistemim  FROM AQSCR WHERE 1=2;

      SELECT KOD=KARTLLG,DateAMLast=DATEOPER,AMVleraCum=VLERAAM,AQVleraCum=VLERABS,AQVleraHist=CAST(VLERABS AS Decimal(30,2))
        INTO #TempDtAM      
        FROM AQSCR 
       WHERE 1=2;  
       
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
             
--           Fund krijim struktura temporare            


   RAISERROR (N'A. ****     FILLIM Amortizimi     **** ', 0, 1) WITH NOWAIT; PRINT '';


                                                                     
   RAISERROR (N'1.          Filtrimi i te dhenave tek tabelat AQ, AQSCR, krijimi i temporareve ', 0, 1) WITH NOWAIT; PRINT '';

                                                                                         -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
         SET @sSql = '
                                                                     
          RAISERROR (N''     1.1    Tabela me Kartelat dhe datat e fundit te amortizimit '', 0, 1) WITH NOWAIT

             INSERT INTO #TempDtAM                                                       -- 1.1. Tabela me Kartelat dhe datat e fundit te amortizimit
                   (KOD, DateAMLast, AMVleraCum, AQVleraCum)
             SELECT B.KARTLLG,
                    DTAM       = ISNULL(MAX(CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END),0),
                    AMVleraCum = 0.0,                                                    -- 27.05.2020, ishte- AMVleraCum=ROUND(SUM(ISNULL(B.VLERAAM,0)),2)
                                                                                         -- 26.02.2021, ishte- AMVleraCum=ROUND(SUM(CASE WHEN B.KODOPER=''CE'' THEN 0 ELSE ISNULL(B.VLERAAM,0) END),2)
                    AQVleraCum = 0.0 
               FROM AQ A INNER JOIN AQSCR          B  ON A.NRRENDOR=B.NRD
                         INNER JOIN AQKARTELA      R1 ON B.KARTLLG=R1.KOD
                         INNER JOIN #AQKategoriTmp R2 ON R2.KOD=R1.KATEGORI
              WHERE (A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''')) AND (UPPER(ISNULL(B.KODOPER,'''')) IN (''CE'',''AM'')) AND 
                    (1=1)
           GROUP BY B.KARTLLG; 
           

             UPDATE T
                SET AMVleraCum = ROUND(ISNULL(A.VLERAAM,0),2),                           -- 26.02.2021, procedure e re
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
                SET T.AQVleraCum  = ROUND(ISNULL(A.AQValue,0) - CASE WHEN ISNULL(A.AMVlereMbet,0)=0 THEN 0 ELSE ISNULL(T.AMVleraCum,0) END,2),    -- New 26.02.2021, pjesa me minus
                    T.AQVleraHist = CAST(ROUND(ISNULL(A.AQValue,0),2) AS Decimal(30,2))
               FROM #TempDtAM T INNER JOIN (
                                             SELECT KOD     = B.KARTLLG, AMVlereMbet=MAX(CASE WHEN ISNULL(R2.AMVLEREMBET,0)=0 THEN 0 ELSE 1 END),
                                                    AQValue = ISNULL( SUM(CASE WHEN B.KODOPER IN (''BL'',''RK'',''RV'')                  THEN ISNULL(B.VLERABS,0)
                                                                               WHEN B.KODOPER IN (''CE'') AND ISNULL(R2.AMVLEREMBET,0)=0 THEN CASE WHEN ISNULL(D.VLERAFATMV,0)<>0 
                                                                                                                                                   THEN ISNULL(D.VLERAFATMV,0) 
                                                                                                                                                   ELSE ISNULL(B.VLERABS,0)
                                                                                                                                              END
                                                                            -- WHEN B.KODOPER IN (''CE'') AND ISNULL(R2.AMVLEREMBET,0)=0 THEN ISNULL(B.VLERABS,0) -- ishte perpara 08.03.2021
                                                                                                                                              
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

             INSERT INTO #TempScr                                                        -- 1.3. Tabela me Kartelat dhe veprimet qe do te amortizohen
                   (NRRENDOR)
             SELECT B.NRRENDOR
               FROM AQ A INNER JOIN AQSCR          B  ON A.NRRENDOR=B.NRD
                         INNER JOIN AQKARTELA      R1 ON B.KARTLLG=R1.KOD
                         INNER JOIN #AQKategoriTmp R2 ON R2.KOD=R1.KATEGORI
              WHERE A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''') AND (UPPER(ISNULL(B.KODOPER,'''')) IN (''CE'',''BL'',''RK'',''RV'')) AND 
                   (1=1); ';
                   
          IF  @sWhere<>''          
              SET @sSql = Replace(@sSql,'1=1',@sWhere);
        EXEC (@sSql);                                    -- PRINT  @sSql;  SELECT Deri='1',* FROM #TempScr; SELECT Deri='1A',* FROM #TempDtAM; RETURN;
                   
                   
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
             SELECT B.KARTLLG, A.DATEDOK, ROUND(ISNULL(B.VLERABS,0),2)                   
               FROM AQ A INNER JOIN AQSCR          B  ON A.NRRENDOR=B.NRD
                         INNER JOIN AQKARTELA      R1 ON B.KARTLLG=R1.KOD
                         INNER JOIN #AQKategoriTmp R2 ON R2.KOD=R1.KATEGORI
              WHERE A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''') AND (UPPER(ISNULL(B.KODOPER,'''')) IN (''SI'')) AND 
                   (1=1);';
                   
          IF  @sWhere<>''          
              SET @sSql = Replace(@sSql,'1=1',@sWhere);
        EXEC (@sSql);      


          IF OBJECT_ID('TEMPDB..#TempDatesX') IS NOT NULL
             DROP TABLE #TempDatesX;



   RAISERROR (N'     1.7    Plotesim i tabeles me te dhenat per vlerat dhe datat e amortizimive ', 0, 1) WITH NOWAIT; 
                                                                            
      SELECT A.*,
             DTAM = CASE WHEN ISNULL(B.DateAMLast,0)=0 OR A.DateDok>B.DateAMLast
                              THEN CASE WHEN A.KODOPER IN ('CE')           THEN A.DATEDOK
                                        WHEN A.KODOPER IN ('BL','RK','RV') THEN A.DATEDOK         -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
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
                                                -- rasti kur nuk ka amortizime dhe starton me date me force krahesimi behet me AMDateStart
                    DateStart     = CASE WHEN ISNULL(Dt.DateAMLast,0)=0 AND ISNULL(K.AMDateStartAplikim,0)=1 AND ISNULL(K.AMDateStart,0)<>0 
                                         THEN DATEADD(m,1,CONVERT(DATETIME,'01/'+CAST(MONTH(CASE WHEN ISNULL(Dt.DateAMLast,0)=0 OR K.AMDateStart>DateAMLast THEN K.AMDateStart ELSE Dt.DateAMLast END) AS VARCHAR(2))+'/'+
                                                                                 CAST(YEAR (CASE WHEN ISNULL(Dt.DateAMLast,0)=0 OR K.AMDateStart>DateAMLast THEN K.AMDateStart ELSE Dt.DateAMLast END) AS VARCHAR(4)),103))

                                         ELSE DATEADD(m,1,CONVERT(DATETIME,'01/'+CAST(MONTH(CASE WHEN ISNULL(Dt.DateAMLast,0)=0 OR A.DATEDOK    >DateAMLast THEN A.DATEDOK     ELSE Dt.DateAMLast END) AS VARCHAR(2))+'/'+
                                                                                 CAST(YEAR (CASE WHEN ISNULL(Dt.DateAMLast,0)=0 OR A.DATEDOK    >DateAMLast THEN A.DATEDOK     ELSE Dt.DateAMLast END) AS VARCHAR(4)),103))
                                    END,
                 -- DateEnd       = @DateEnd,
                    NORMEAM       = ISNULL(R.NORMEAM,0),
                    IsAMVlereMbet = ISNULL(R.AMVLEREMBET,0),
                    VLERABS       = ROUND(ISNULL(B.VLERABS,0),2),  
                    AQVleraHist   = CAST(Dt.AQVleraHist AS Decimal(30,2)),
                    AMDtStartForc = CASE WHEN ISNULL(Dt.AMVleraCum,0)=0 AND ISNULL(K.AMDateStartAplikim,0)=1 AND ISNULL(K.AMDateStart,0)<>0 
                                      -- WHEN ISNULL(Dt.DateAMLast,0)=0 AND ISNULL(K.AMDateStartAplikim,0)=1 AND ISNULL(K.AMDateStart,0)<>0 
                                         THEN K.AMDateStart   
                                         ELSE NULL 
                                    END,
                    AMDtStartApl  = CASE WHEN ISNULL(Dt.AMVleraCum,0)=0 AND ISNULL(K.AMDateStartAplikim,0)=1 AND ISNULL(K.AMDateStart,0)<>0
                                      -- WHEN ISNULL(Dt.DateAMLast,0)=0 AND ISNULL(K.AMDateStartAplikim,0)=1 AND ISNULL(K.AMDateStart,0)<>0
                                         THEN ISNULL(K.AMDateStartAplikim,0) 
                                         ELSE CAST(0 AS BIT) 
                                    END,
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
    ORDER BY KOD,DateDok;                                                                -- SELECT Deri='1.7',* from #TempDtAM; RETURN;

    
-- Ne se koencidon qe Amortizimi me force eshte njesoj me ate te llogaritur me siper (pra fillim muaj) atehere ska nevoje per AMDtStartForc

      UPDATE A
         SET AMDtStartForc = CASE WHEN AMDtStartForc=DateStart THEN NULL ELSE AMDtStartForc END,
             AMDtStartApl  = CASE WHEN AMDtStartForc=DateStart THEN 0    ELSE AMDtStartApl  END
        FROM #TempDatesX A
       WHERE AMDtStartApl=1                                                              -- SELECT Deri='Kujdes 1.7',* FROM #TempDatesX; Select * From #TempDtAM; RETURN;


   RAISERROR (N'     1.8    Amortizim Linear (konstant): Plotesim i tabeles me te dhena per kosto historike ', 0, 1) WITH NOWAIT; 
--                          Kriter eshte deri ne daten e amortizimit te fundit              -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
      UPDATE T
         SET VLERABS = ISNULL(( SELECT SUM(CASE WHEN B.KODOPER IN ('BL','RK') THEN ISNULL(B.VLERABS,0)
                                                WHEN B.KODOPER IN ('CE')      THEN ISNULL(B.VLERABS,0)
                                                                                   -- CASE WHEN ISNULL(D.VLERAFATMV,0)<>0 
                                                                                   --      THEN ISNULL(D.VLERAFATMV,0)-ISNULL(B.VLERAAM,0) 
                                                                                   --      ELSE ISNULL(B.VLERABS,0)
                                                                                   -- END     
                                                ELSE                               0
                                           END) 
                                  FROM AQSCR B INNER JOIN AQ        A ON A.NRRENDOR=B.NRD AND B.KARTLLG=T.KOD 
                                               INNER JOIN AQKARTELA C ON B.KARTLLG=C.KOD
                                               LEFT  JOIN AQCELJE   D ON D.NRD=C.NRRENDOR
                                               
                                 WHERE ((A.DATEDOK<=T.DTAM) AND (B.KODOPER IN ('BL','CE'))) OR  ((A.DATEDOK<T.DTAM) AND (B.KODOPER IN ('RK'))) )
                               ,0) 
        FROM #TempDatesX T 
       WHERE ISNULL(T.IsAmVlereMbet,0)=1 AND T.KODOPER IN ('BL','CE');                   -- SELECT Deri='Kujdes 1.8',* FROM #TempDatesX; Select * From #TempDtAM; RETURN;


   RAISERROR (N'     1.9    Per ato blerje apo RK,RV para amortizimit te fundit ruhet nje rekord i kumuluar .... (reshtat me kriterin OrderParaAM>1 fshihen) ', 0, 1) WITH NOWAIT; PRINT '';

      SELECT A.*,
             OrderParaAM      = CASE WHEN DATEDOK<DtAM 
                                     THEN CASE WHEN ROW_NUMBER() OVER (PARTITION BY KOD ORDER BY KOD,DATEDOK)=1 THEN 1 ELSE 2 END
                                     ELSE 0
                                END         
        INTO #TempDates
        FROM #TempDatesX A
    ORDER BY KOD,DateDok;                                                                -- SELECT '2',* FROM #TempScr; SELECT '2A',* FROM #TempDtAM; Select '2B',* From #TempDates; RETURN;                                                                                 

      DELETE FROM #TempDates WHERE OrderParaAM>1;                                        -- Select Deri='1.9',* FROM #TempDates; Return;


          IF OBJECT_ID('TEMPDB..#TempScr')      IS NOT NULL
             DROP TABLE #TempScr;

          IF OBJECT_ID('TEMPDB..#TempDatesX')   IS NOT NULL
             DROP TABLE #TempDatesX;

-- 1. FUND   Gjenerimi i tabelave temporare




   RAISERROR (N'2.          Zberthimi ne seri data per evidentimin e amortizimit [DateStart, DateEnd]
            Ndertimi i tabeles me date seri per amortizimin (tabela #TempSeri) e cial ndertohet me ndihmen e funksionit Isd_AQAMDateRange', 0, 1) WITH NOWAIT; PRINT '';


-- 2.        Zberthimi ne seri data per evidentimin e amortizimit [DateStart, DateEnd]
--           Ndertimi i tabeles me date seri per amortizimin (tabela #TempSeri) e cial ndertohet me ndihmen e funksionit Isd_AQAMDateRange


   RAISERROR (N'     2.1    Gjenerimi i serise se datave, mbushet tabela #TempSeri ', 0, 1) WITH NOWAIT; 
   
      SELECT NrRendor = CAST(0 AS BIGINT), StartDate=DTAM, EndDate=DATEDOK, KOD, NrOrd = 0, TRow=CAST(0 AS BIT),
             NrTimeAM,KODOPER,DateBlock=CAST(NULL AS DATETIME),AQVleraHist
        INTO #TempSeri 
        FROM #TempDates 
       WHERE 1=2;
 



   -- SELECT Deri='2.1.A',* FROM #TempSeri; SELECT Deri='2.1.A',* FROM #TempDates;
-- KUJDES.   Mos lejo sepse jep gabime per keto raste:   a. NormeAM=0,   b. NrTimeAM=0,   c. DateOper=null (ose 0),   d. AQSCR.NRD=null

        EXEC dbo.Isd_AQAMSeriDates '#TempDates','#TempSeri',@pDateEnd;
   -- SELECT Deri='2.1.B',* FROM #TempSeri; SELECT Deri='2.1.B',* FROM #TempDates; RETURN;


             -- 2.2     Kufizimi i serise se datave deri ne date shitje aseti (ne se ka te tille brenda periushes)
             --         Kujdes me fushen NrOrd
             
   RAISERROR (N'     2.2    Kufizimi i serise se datave deri ne date shitje aseti (ne se ka te tille brenda periushes) ', 0, 1) WITH NOWAIT; PRINT '';
  
          IF OBJECT_ID('TempDB..#TempSeriX')    IS NOT NULL
             DROP TABLE #TempSeriX;
             
                                                                          -- SELECT TOP 1 A.Kod,A.NrOrd,T.AQDateShitje,.. etj         -- ishte perpara 08.04.2020
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
   -- SELECT Deri='4',* FROM #TempSeri;  RETURN                    
                      



   RAISERROR (N'3.          Tabela #TempDates1 eshte kryesore ne algoritmin per amortizimin ', 0, 1) WITH NOWAIT; PRINT '';

      SELECT Dt.*, 
             DateStartAM      = A.StartDate,
             DateTransAM      = CASE WHEN A.DateBlock IS NULL 
                                     THEN A.EndDate 
                                     ELSE CASE WHEN A.DateBlock<=A.EndDate THEN A.DateBlock ELSE A.EndDate END
                                END,
             DateAMLast       = Dt.DTAM,
             DateEND          = @DateEnd,
             DateBlock        = A.DateBlock,
             
             VleraAM          = CAST(0.0 AS Decimal(30,2)),
             AMVleraCum       = CAST(0.0 AS Decimal(30,2)),     -- Shuma e amortizimeve para pariudhes vleresuese (referuar DateAMLast)
             AMVleraPrg       = CAST(0.0 AS Decimal(30,2)),     -- Amortizimi progresiv per periudhen e rivleresimit (amortizimit)
             AMVleraTot       = CAST(0.0 AS Decimal(30,2)),     -- Amortizim total (progresiv te periudhes + Amortizimi i cumuluar)
             AMVleraMin       = CAST(0.0 AS Decimal(30,2)),     -- Vlere minimale amortizimi, llogaritet me poshte

             AQVleraCum       = CAST(0.0 AS Decimal(30,2)),     -- Shuma e vlerave te aktivit para pariudhes vleresuese (referuar DateAMLast)
             AQVleraMbet      = CAST(0.0 AS Decimal(30,2)),
             AQVleraSistemim  = CAST(0.0 AS Decimal(30,2)),
          -- Dt.AQVleraHist,                                    -- Shuma e vlerave te aktivit para pariudhes vleresuese (referuar DateAMLast)
             PershkrimAM      = Space(150),
             KomentAM         = Space(100),
             KomentMbyllje    = Space(150),                     -- Pershkrim ne rast mbyllje aseti    
             NrMonthsAM       = 0,
             NrDaysAM         = 0,                              -- u shtua me 30.09.2020
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
   -- SELECT Deri='3',* FROM #TempDates1 ORDER BY KOD,SEQNUM; RETURN; SELECT '3A',* FROM #TempSeri; RETURN


          IF OBJECT_ID('TEMPDB..#TempSeri')     IS NOT NULL
             DROP TABLE #TempSeri;
    
    

/*        -- Nje tjeter algoritem per gjenerimin e tabeles me datat seri per amortizimin, nuk kenaq kushtin per ta hedhur kete procedure me parameter kodin a aktivit
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
      UPDATE A                                                                           -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
         SET DateAMLast      = CASE WHEN B.DateAMLast< A.DATEDOK                                  THEN A.DATEDOK    ELSE B.DateAMLast END,  
             AMVleraCum      = CASE WHEN A.KODOPER IN ('CE','BL','RK') AND B.DateAMLast>A.DATEDOK THEN B.AMVleraCum ELSE 0            END, -- Shtuar me 13.08.2020, ishte vetem 'CE'
             AQVleraCum      = CASE WHEN A.KODOPER IN ('CE','BL','RK') AND B.DateAMLast>A.DATEDOK THEN B.AQVleraCum ELSE A.VLERABS    END  -- Shtuar me 13.08.2020, ishte vetem 'CE' 
        FROM #TempDates1 A INNER JOIN #TempDtAM B ON A.KOD=B.KOD;
   -- SELECT Deri='4.A',* FROM #TempDates1; RETURN;

      UPDATE A
         SET DateAMLast      = A.DATEDOK, AMVleraCum = 0, AQVleraCum = A.VLERABS
        FROM #TempDates1 A 
       WHERE NOT EXISTS (SELECT NRRENDOR FROM #TempDtAM B WHERE A.KOD=B.KOD);

      UPDATE A
         SET DateAMLast      = A.DATEDOK
        FROM #TempDates1 A 
       WHERE DATEDOK>DateAMLast;

      UPDATE #TempDates1                                                                 -- 4.1 Korigjo DatestartAM per ato me date amrtizim me force
         SET DateStartAM = AMDtStartForc, DateStart=AMDtStartForc, DTAM=AMDtStartForc    -- DateAMLast  = AMDtStartForc,
       WHERE AMDtStartApl=1;
 --   SELECT Deri='4.B',* FROM #TempDates1 ORDER BY KOD,SEQNUM; RETURN;
   
      UPDATE A                                                                           -- 4.2 Gjendet e para date serie  >= ku futet vlefta per sistemin e asetit
         SET AQVleraSistemim = T.AQVleraSistemim
        FROM #TempDates1 A INNER JOIN #TempSistemim T ON A.KOD=T.KOD
       WHERE A.DateStartAM<=T.AQDateSistemim AND T.AQDateSistemim<=A.DateTransAM;         
   -- SELECT Deri='4.C',* FROM #TempDates1 ORDER BY KOD,SEQNUM; SELECT Deri='4C',* FROM #TempSistemim; RETURN;


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
         --  DateTransAM   = DateEnd,
             SeqNum        = SeqNum + 1, 
             TipRow        = 'D';                                                        -- Resht Diference
             

      INSERT   INTO  #TempDates1     
      SELECT * FROM  #TempDates2 A;

        DROP TABLE #TempDates2;
   -- SELECT Deri='5A',* From  #TempDates1; RETURN;
            

   RAISERROR (N'6.          Llogaritja e fushave dhe elementeve per Amortizimin sipas te dyja metodave 
            AVK - Amortizim Vlefte Konstante,       AVM - Amortizim Vlefte Mbetur ', 0, 1) WITH NOWAIT; PRINT '';


   RAISERROR (N'     6.0    Llogaritje numur muaj amortizim si dhe vlere minimale ku nderpritet amortizimi ', 0, 1) WITH NOWAIT; PRINT '';
   
      UPDATE #TempDates1                                                                 -- procedure e re me 18.03.2021
         SET NrMonthsAM    = CASE WHEN DateStartAM=DateTransAM
                                       THEN 0
                                                             
                                  WHEN DAY(DateStartAM)=1      AND    DATEADD(d,-1,DATEADD(m, DATEDIFF(m,0,DateTransAM)+1, 0))=DateTransAM  -- DateTransAM dite e fundit e muajit
                                       THEN DATEDIFF(m, DateStartAM, DateTransAM)+1
                                       
                                  WHEN DAY(DateStartAM)<>1     AND    DATEADD(d,-1,DATEADD(m, DATEDIFF(m,0,DateTransAM)+1, 0))=DateTransAM  -- DateTransAM dite e fundit e muajit
                                       THEN DATEDIFF(m, DATEADD(m,1,  DATEADD(m,DATEDIFF(m,0,DateStartAM),0)),    DateTransAM)+1
                                       --   diference DATEDIFF('dt e pare muaj pasardhes,   datetransAM)'
                                       
                                  WHEN DAY(DateStartAM)=1  AND DATEADD(d,-1,DATEADD(m, DATEDIFF(m,0,DateTransAM)+1, 0))<>DateTransAM        -- DateTransAM jo dite e fundit e muajit
                                       THEN DATEDIFF(m, DateStartAM,  DATEADD(d,-(DAY(DateTransAM)),DateTransAM))+1
                                       --   diference DATEDIFF(dt startAM, dt e fundit 1 muaj para DateTransAM)
                                         
                                  ELSE      DATEDIFF(m, DATEADD(m,1,DATEADD(m,DATEDIFF(m,0,DateStartAM),0)),    DATEADD(d,-(DAY(DateTransAM)),DateTransAM))+1
                                       --   diference DATEDIFF(dt e pare muaj pasardhes, dt e fundit 1 muaj paraardhes)
                              END,
                              
             NrDaysAM      = CASE WHEN DateStartAM=DateTransAM
                                       THEN 1
                                  WHEN DAY(DateStartAM)=1      AND    DATEADD(d,-1,DATEADD(m, DATEDIFF(m,0,DateTransAM)+1, 0))= DateTransAM
                                       THEN 0
                                  
                                  WHEN DAY(DateStartAM)<>1     AND    DATEADD(d,-1,DATEADD(m, DATEDIFF(m,0,DateTransAM)+1, 0))= DateTransAM
                                       THEN DATEDIFF(d, DateStartAM,  DATEADD(d,-1,DATEADD(m, DATEDIFF(m,0,DateStartAM)+1, 0)))+1
                                       --   diference Nr dite ('dt e fundit e muajit' - 'diten konkrete)+1
                                       
                                  WHEN DAY(DateStartAM)=1  AND DATEADD(d,-1,DATEADD(m, DATEDIFF(m,0,DateTransAM)+1, 0))<>DateTransAM
                                       THEN DATEDIFF(d, DateTransAM-DAY(DateTransAM)+1,DateTransAM)+1
                                       --   diference Nr dite ('dt korente' - ' dt e pare muajit DateTransAM')+1
                                         
                                  ELSE      DATEDIFF(d, DateStartAM,  DATEADD(d,-1,DATEADD(m, DATEDIFF(m,0,DateStartAM)+1, 0)))+1
                                            +
                                            DATEDIFF(d, DateTransAM-DAY(DateTransAM)+1,DateTransAM)+1                                  
                                       --   shumat e mesiperme (rasti 3,4)
                              END

        FROM #TempDates1                  -- DateTransAM-DAY(DateTransAM)+1
	   WHERE NOT ((DateStartAM IS NULL) OR (DateTransAM IS NULL));    
                           
-- First day of month date 1.  DATEADD(mm, DATEDIFF(mm,0,DateTransAM), 0)
--                         2.  DateTransAM-DAY(DateTransAM)+1
-- FirstDayOfNextMonth         DATEADD(m,1,DATEADD(m,DATEDIFF(m,0,DateStartAM),0))
-- Last day of previous month  DATEADD(d,-(DAY(DateTransAM)),DateTransAM)
-- Last day of current month   dateadd(d,-(day(dateadd(m,1,getdate()))),dateadd(m,1,getdate()))
                               
--      SELECT Deri='6.0',* FROM #TempDates1; RETURN;


/* -- u komentua 16.03.2021 dhe u zevendesua me ate me siper
      UPDATE #TempDates1                                                                     
         SET NrMonthsAM    = DATEDIFF(m, DateStartAM, DateTransAM) + 1;
         
      UPDATE T                                                                               
         SET T.NrDaysAM    = CASE WHEN T.DateTransAM=TM.LastDate THEN            0 ELSE DATEDIFF(d,TM.FirstDate, T.DateTransAM)+1 END,
             T.NrMonthsAM  = CASE WHEN T.DateTransAM=TM.LastDate THEN NrMonthsAM ELSE NrMonthsAM - 1                              END
        FROM #TempDates1 T INNER JOIN #MonthsTable TM ON YEAR(T.DateTransAM)=[YEAR] AND MONTH(T.DateTransAM)=[MONTH];
--    SELECT Deri='6.0',DateStartAM,DateTransAM,D=DATEDIFF(m, DateStartAM, DateTransAM),* From  #TempDates1; Select * From #MonthsTable; RETURN; */
   
 
       UPDATE T 
         SET AMVleraMin    = CASE WHEN ISNULL(R.APLVLEREMINAM,0) = 0                     -- sipas perqindjes 
                                       THEN ROUND((ISNULL(R.PERQINDMINAM,0) * ISNULL(T.AQVleraCum,0))/100,2)   -- VleraBS ose AQVleraCum
                                       
                                  WHEN ISNULL(R.APLVLEREMINAM,0) = 1                     -- sipas vlere minimale
                                       THEN ISNULL(R.VLEREMINAM,0.0)
                                                                                         -- sipas maximumit (perqindje, vlere minimale)
                                  ELSE CASE WHEN ROUND((ISNULL(R.PERQINDMINAM,0)*ISNULL(T.AQVleraCum,0))/100,2)>=ISNULL(R.VLEREMINAM,0.0) 
                                            THEN ROUND((ISNULL(R.PERQINDMINAM,0)*ISNULL(T.AQVleraCum,0))/100,2)
                                            ELSE ISNULL(R.VLEREMINAM,0.0)
                                       END     
                             END
        FROM #TempDates1   T INNER JOIN AQKARTELA      K  ON T.KOD = K.KOD
                             INNER JOIN #AQKategoriTmp R  ON K.KATEGORI=R.KOD;



   RAISERROR (N'     6.1    FILLIM AVK:      Metoda Amortizimit Vefte Konstant (sipas normes se Amortizimit) ', 0, 1) WITH NOWAIT; PRINT '';


   RAISERROR (N'     6.1.1                   Llogaritja e vleftes se amortizimit ', 0, 1) WITH NOWAIT;
      
      UPDATE T
         SET PERSHKRIMAM   = CASE WHEN T.TipRow='D'
                                  THEN PERSHKRIMAM
                                  ELSE SUBSTRING(M1.Month_Name,1,3)+' - '+SUBSTRING(M2.Month_Name,1,3)+' '+SUBSTRING(CAST(YEAR(T.DateStartAM) AS VARCHAR),1,4)
                             END,
             VLERAAM       = CASE WHEN T.TipRow='D'                 THEN VLERAAM                              
                                  WHEN ISNULL(A.NrMonthsAM,0)=0 AND ISNULL(A.NrDaysAM,0)=0    
                                                                    THEN 0 
                                  ELSE                                   ROUND(((A.NrMonthsAM*(T.AQVleraCum) * T.NORMEAM)/1200.0) +     -- u modifikua pas 30.09.2020
                                                                               ((A.NrDaysAM*  (T.AQVleraCum) * T.NORMEAM)/36500.0), 2)  -- Konstante
                             END
        FROM 
           (
             SELECT KOD,KODOPER,SeqNum,NrMonthsAM,NrDaysAM,NrRendor
               FROM #TempDates1 
              WHERE ISNULL(IsAMVlereMbet,0)=0 
              ) A  
                   INNER JOIN #TempDates1 T  ON A.KOD=T.KOD AND A.KODOPER=T.KODOPER AND A.SeqNum=T.SeqNum AND A.NrRendor=T.NrRendor
                   INNER JOIN #MonthNames M1 ON MONTH(T.DateStartAM)=M1.Month_Number
                   INNER JOIN #MonthNames M2 ON MONTH(T.DateTransAM)=M2.Month_Number;
-- SELECT Deri='6.1.1',VLERAAM,* FROM #TempDates1; RETURN;


   RAISERROR (N'     6.1.2                   AVK: Llogaritja e vleftes se mbetur (fusha AQVleraMbet me vlefta progresive) me metoden rekursive, dhe te dhenat ruhen provizorisht tek tabela #TempDates3X 
                             Llogaritja e mesiperme (per VLERAAM tek 6.1.1) mund te behej dhe ketu.
                             Test AMVleraMin i mbylljes se Amortizimit eshte variable. ', 0, 1) WITH NOWAIT; PRINT '';

;WITH  SumAm
       AS ( 
             SELECT t.Kod, 
                    t.VLERABS,
                 -- VLERAAM     =  ROUND(                         ((t.NrMonthsAM*ISNULL(t.VLERABS,0)*t.NORMEAM)/1200.0), 2)+
                 --                                               ((t.NrDaysAM  *ISNULL(t.VLERABS,0)*t.NORMEAM)/36500.0), 2),
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
                    CASE WHEN t.AQVleraCum>0 THEN ROUND(A.AQVleraMbet,2) ELSE AMVleraMin END >= AMVleraMin                                -- deri AMVleraMin te vleftes     
                 -- CASE WHEN t.AQVleraCum>0 THEN ROUND(100-(100*(t.AQVleraCum-A.AQVleraMbet)/t.AQVleraCum),2) ELSE 5 END >= 5%           -- deri 5% te vleftes     
           )
           
             SELECT * INTO #TempDates3X FROM SumAm    -- WHERE AQVleraMbet>=0               -- Kujdes ....!   te bllokohet rekursiviteti sepse fryhet kot tabela temporare SumAm 
             
OPTION  ( MAXRECURSION 1000 );

    
      UPDATE A
         SET A.AQVleraMbet = B.AQVleraMbet       
        FROM #TempDates1 A INNER JOIN #TempDates3X B ON A.NRRENDOR=B.NRRENDOR AND A.SeqNum=B.SeqNum  -- ON A.KOD=B.KOD AND A.SeqNum=B.SeqNum
       WHERE ISNULL(A.IsAMVlereMbet,0)=0;
   -- SELECT Deri='6,1.2 A',* FROM #TempDates3X ORDER BY KOD,SEQNUM; SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM; RETURN;
    

          IF OBJECT_ID('TEMPDB..#TempDates3X')  IS NOT NULL
             DROP TABLE #TempDates3X;

   RAISERROR (N'     6.1    FUND AVK:        Metoda Amortizimit Vefte Konstant (sipas normes se Amortizimit) ', 0, 1) WITH NOWAIT; PRINT '';




      -- 6.2.       FILLIM AVM:     metoda Amortizimit Vlefte Mbetur (kujdes filtrohet sipas natyres se kategorise)  
   RAISERROR (N'     6.2    FILLIM AVM:      metoda Amortizimit Vlefte Mbetur (kujdes filtrohet sipas natyres se kategorise) ', 0, 1) WITH NOWAIT; PRINT '';


/* RAISERROR (N'     6.2.1                   Kalkulohet fusha e nr te muajve qe llogaritet amortizimi ', 0, 1) WITH NOWAIT;
      
      UPDATE #TempDates1 
         SET NrMonthsAM    = CASE WHEN TipRow='D' THEN NrMonthsAM ELSE DATEDIFF(m,DateStartAM,DateTransAM)+CASE WHEN DAY(DateStartAM)=1 THEN 1 ELSE 0 END END
       WHERE ISNULL(IsAMVlereMbet,0)=1; 
   -- SELECT Deri='6.2.1',* FROM #TempDates1 ORDER BY KOD,SEQNUM; RETURN; */



   RAISERROR (N'     6.2.1                   AVM: Llogaritja e vleftes se mbetur (fusha AQVleraMbet me vlefta progresive) me metoden rekursive, dhe te dhenat ruhen provizorisht tek tabela #TempDates3Y 
                             Test AMVleraMin i mbylljes se Amortizimit eshte variable sipas kategorise dhe asetit. ', 0, 1) WITH NOWAIT;


       ALTER TABLE  #TempDates1 ADD AQVleraStart Decimal(30,2) NULL;   
      UPDATE #TempDates1 SET AQVleraStart=AQVleraCum,VLERABS=AQVleraCum;      -- - AMVleraCum;
   -- SELECT Deri='6.2.1.A',* FROM #TempDates1 ORDER BY KOD,SEQNUM; RETURN;


;WITH  SumAm
        AS ( 
             SELECT t.Kod, 
                    t.VLERABS,            -- Per amortizim te plote te vleres se mbetur u punua me 13.08.2020 por vlera e mbetur kalon ne shpenzim: 
                                          -- Komentet nuk duhen sepse e gjitha kalon ne shpenzim dhe kjo nuk amortizohet. Mbeti funksioni sic ka qene (koment per 6.2.2 )
--                  VLERAAM     = CASE WHEN t.AQVleraStart>t.AMVleraMin              
--                                     THEN ROUND(                   (t.NrMonthsAM*ISNULL(t.AQVleraStart,0)*t.NORMEAM)/1200.0, 2)
--                                     ELSE t.AQVleraStart
--                                END,
--                  AQVleraMbet = CASE WHEN t.AQVleraStart>t.AMVleraMin 
--                                     THEN ROUND(t.AQVleraStart   - (t.NrMonthsAM*ISNULL(t.AQVleraStart,0)*t.NORMEAM)/1200.0, 2)
--                                     ELSE 0
--                                END,
                    VLERAAM     = ROUND(                          ((t.NrMonthsAM*ISNULL(t.AQVleraStart,0)*t.NORMEAM)/ 1200.0)
                                                                + ((t.NrDaysAM  *ISNULL(t.AQVleraStart,0)*t.NORMEAM)/36500.0), 2),  -- u shtua 16.03.2020
                    AQVleraMbet = ROUND(       t.AQVleraStart   -  (t.NrMonthsAM*ISNULL(t.AQVleraStart,0)*t.NORMEAM)/ 1200.0, 2),
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

   -- SELECT Deri='6.2.1.B',* FROM #TempDates1 Order By Kod,SeqNum;  SELECT * FROM #TempDates3Y ORDER BY KOD,SEQNUM; RETURN;

       ALTER TABLE #TempDates1 DROP COLUMN AQVleraStart;   

      UPDATE A
         SET A.VLERABS     = A.AQVleraCum,           -- = A.AQVleraCum - A.AMVleraCum,             -- Pas 13.08.2020
             KomentMbyllje = CASE WHEN B.VLERAAM>0   
                                  THEN CASE WHEN (A.AQVleraCum - B.VLERAAM) >= A.AMVleraMin        -- (A.AQVleraCum-A.AMVleraCum) - B.VLERAAM >= A.AMVleraMin 
                                            THEN ''
                                            ELSE 'AM deri '+CONVERT(VARCHAR(25),CAST(A.AMVleraMin AS DECIMAL(20,0)))   -- Pra nga Vlera e mbetur minus Amortizim minimal, pjesa tjeter ne shpenzim
                                       END               
                                  ELSE ''         
                             END,
             A.VLERAAM     = CASE WHEN B.VLERAAM>0   -- Pas 13.08.2020
                                  THEN CASE WHEN (A.AQVleraCum - B.VLERAAM) >= A.AMVleraMin        -- WHEN (A.AQVleraCum-A.AMVleraCum) - B.VLERAAM >= A.AMVleraMin 
                                            THEN B.VLERAAM 
                                            ELSE A.AQVleraCum-A.AMVleraCum-A.AMVleraMin            -- Pra nga Vlera e mbetur minus Amortizim minimal, pjesa tjeter ne shpenzim
                                       END 
                                  ELSE B.VLERAAM                                      
                             END, 
          -- A.VLERAAM     = B.VLERAAM,                                                            -- Ishte deri 13.08.2020
             A.AQVleraMbet = B.AQVleraMbet       
             
        FROM #TempDates1 A INNER JOIN #TempDates3Y B ON A.NRRENDOR=B.NRRENDOR AND A.SeqNum=B.SeqNum -- ON A.KOD=B.KOD AND A.SeqNum=B.SeqNum
       WHERE ISNULL(A.IsAMVlereMbet,0)=1;
   -- DELETE   FROM #TempDates1 WHERE VLERAAM<=0;
   -- SELECT * FROM #TempDates3Y ORDER BY KOD,SEQNUM; SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM; RETURN;
   -- SELECT Deri='6.2.1.C',* FROM #TempDates1 ORDER BY KOD,SEQNUM;
    
    
    
--           6.2.2 Rasti kur amortizon per disa Vite dh kartela me amortizim me vlere te mbetur
    
      UPDATE A
         SET A.VLERABS     = ISNULL((SELECT TOP 1 AQVleraMbet FROM #TempDates1 B WHERE A.Kod=B.KOD AND B.SeqNum=A.SeqNum-1),A.VLERABS)
        FROM #TempDates1 A 
       WHERE ISNULL(A.IsAMVlereMbet,0)=1 AND SeqNum>1 AND TipRow<>'D';
   -- SELECT Deri='6.2.2',* FROM #TempDates1 ORDER BY KOD,SEQNUM;RETURN
    
    
          IF OBJECT_ID('TEMPDB..#TempDates3Y')  IS NOT NULL
             DROP TABLE #TempDates3Y;


   RAISERROR (N'     6.2    FUND AVM:        metoda Amortizimit Vlefte Mbetur (kujdes filtrohet sipas natyres se kategorise) ', 0, 1) WITH NOWAIT; PRINT '';

      

   RAISERROR (N'     6.3    kufizimet per amortizim sipas vlerave minimale, llogaritje te vleres se mbetur, progresive etj. ', 0, 1) WITH NOWAIT; PRINT '';
                                                                             -- Algoritmi nderpritet kur shuma a amortizimeve te cumuluara arrin pragun minimal
      UPDATE A                                                               -- par Am cumuluar + AmVlere minimale = vleren e asetit  -- shtuar me 14.04.2020
         SET A.VLERAAM     = CASE WHEN A.AMVleraCum+AMVleraMin> A.AQVleraHist THEN 0 ELSE A.VLERAAM     END,
             A.AQVleraMbet = CASE WHEN A.AMVleraCum+AMVleraMin> A.AQVleraHist THEN 0 ELSE A.AQVleraMbet END
--       SET A.VLERAAM     = CASE WHEN A.AMVleraCum+AMVleraMin>=A.AQVleraCum  THEN 0 ELSE A.VLERAAM     END, -- ishte perpara 08.03.2021
--           A.AQVleraMbet = CASE WHEN A.AMVleraCum+AMVleraMin>=A.AQVleraCum  THEN 0 ELSE A.AQVleraMbet END
        FROM #TempDates1 A 
   -- SELECT Deri='6.3.A',* FROM #TempDates1 ORDER BY KOD,SEQNUM;RETURN;

    --UPDATE A
    --   SET VLERABS       = A.AQVleraCum - CASE WHEN ISNULL(A.IsAMVlereMbet,0)=1 THEN A.AMVleraCum ELSE 0 END
    --  FROM #TempDates1 A 
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
   -- SELECT Deri='6.3.B',* FROM #TempDates1 ORDER BY KOD,SEQNUM;RETURN;



   RAISERROR (N'7.          FILLIM kontrolli per mbylljen e Amortizimit (Amortizim deri ne AMVleraMin te vleftes se asetit) ', 0, 1) WITH NOWAIT; PRINT '';

   
          IF OBJECT_ID('TEMPDB..#TempDatesY')   IS NOT NULL
             DROP TABLE #TempDatesY;


   RAISERROR (N'     7.1    Gjendet i pari resht ku vlera e mbetur e asetit eshte <= AMVleraMin (AMVleraMin llogaritet me siper). Rezultati ruhet tek tabela #TempDatesY.) ', 0, 1) WITH NOWAIT;
                                                                     
      SELECT KOD,NRRENDOR, AQVleraCum, AMVleraMin, AMVleraTot,                            -- Test i mbylljes eshte variable sipas kategorive, u korigjua me daten 11.04.2020 dhe                                   
             SeqNum   = ( SELECT SeqNum=MIN(SEQNUM)                                       -- zevendesoi ate me poshte te dates 08.04.2020 dhe ate procedure me TOP 108.04.2020 (gabim TOP 1)
                            FROM #TempDates1 B 
                           WHERE A.KOD=B.KOD AND (AQVleraCum-AMVleraMin-AMVleraTot<=0) )  -- WHERE A.KOD=B.KOD AND (AQVleraCum-AMVleraMin-AMVleraTot>0) )
        INTO #TempDatesY
        FROM #TempDates1 A
       WHERE A.SEQNUM = ( SELECT SeqNum=MAX(SEQNUM)
                            FROM #TempDates1 B 
                           WHERE A.KOD=B.KOD AND (AQVleraCum-AMVleraMin-AMVleraTot<=0) )  -- WHERE A.KOD=B.KOD AND (AQVleraCum-AMVleraMin-AMVleraTot>0) )        
    ORDER BY KOD,NRRENDOR,SEQNUM;
--    SELECT * FROM #TempDatesY; SELECT Deri='7.1',VleraAM,* FROM #TempDates1 ORDER BY KOD,SEQNUM;RETURN;


--    SELECT KOD,NRRENDOR,                                                               -- Test i mbylljes eshte variable sipas kategorive date 08.04.2020
--           SeqNum   = ( SELECT SeqNum=MIN(SEQNUM) FROM #TempDates1 B WHERE A.KOD=B.KOD AND (AQVleraCum-AQVleraMbet>0) AND AQVleraMbet<=AMVleraMin)
--      INTO #TempDatesY
--      FROM #TempDates1 A
--     WHERE A.SEQNUM = ( SELECT SeqNum=MIN(SEQNUM) FROM #TempDates1 B WHERE A.KOD=B.KOD AND (AQVleraCum-AQVleraMbet>0) AND AQVleraMbet<=AMVleraMin)        
--  ORDER BY KOD,NRRENDOR,SEQNUM;

--    SELECT TOP 1 *                                                                     -- ishte deri daten 08.04.2020 (gabim TOP 1)
--      INTO #TempDatesY
--      FROM #TempDates1
--     WHERE (AQVleraCum-AQVleraMbet>0) AND AQVleraMbet<=AMVleraMin                      -- Test i mbylljes eshte variable sipas kategorive
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
 
 
      UPDATE A                                                                           -- U korigjua me 10.04.2020. Procedura ishte si me poshte e komentuar
         SET A.VLERAAM     = CASE WHEN A.SEQNUM<B.SEQNUM 
                                       THEN A.VLERAAM 

                                  WHEN A.SEQNUM=B.SEQNUM                                 -- Ndryshuar me 13.08.2020 zevendesoi komentin
                                       THEN CASE WHEN A.VLERAAM<=A.AMVleraMin 
                                                 THEN A.VLERAAM
                                                 ELSE A.VLERAAM -A.AMVleraMin            -- A.VLERAAM+(A.AQVleraHist-A.AMVleraMin-A.AMVleraTot) --A.AQVleraMbet
                                            END 
                               -- WHEN A.SEQNUM=B.SEQNUM THEN A.VLERAAM+(A.AQVleraCum-A.AMVleraMin-A.AMVleraTot) --A.AQVleraMbet

                                  ELSE 0
                             END,
             A.AQVleraMbet = CASE WHEN A.SEQNUM<B.SEQNUM THEN A.AQVleraMbet
                                  WHEN A.SEQNUM=B.SEQNUM THEN 0
                             END 
        FROM #TempDates1 A INNER JOIN #TempDatesY B ON A.KOD=B.KOD AND A.NRRENDOR=B.NRRENDOR    -- AND A.SEQNUM=B.SEQNUM 
       WHERE A.SeqNum>0 AND A.TipRow<>'D';
  -- SELECT Deri='7.2 A',A=AQVleraHist-AMVleraMin-AMVleraTot,AQVleraHist,AMVleraMin,AMVleraTot,VLERAAM,* FROM #TempDates1 ORDER BY KOD,SEQNUM;RETURN;
    
      UPDATE A
         SET A.AMVleraPrg  =                (SELECT SUM(T.VLERAAM) FROM #TempDates1 T WHERE T.KOD=A.KOD AND T.SeqNum<=A.SeqNum),
             A.AMVleraTot  = A.AMVleraCum + (SELECT SUM(T.VLERAAM) FROM #TempDates1 T WHERE T.KOD=A.KOD)
        FROM #TempDates1 A 
       WHERE A.SeqNum>0; -- AND A.TipRow<>'D';
  -- SELECT Deri='7.2 B',* FROM #TempDates1 ORDER BY KOD,SEQNUM;--RETURN;


          IF OBJECT_ID('TEMPDB..#TempDatesY')   IS NOT NULL
             DROP TABLE #TempDatesY;
    
   
             
   RAISERROR (N'     7.3    Statistika ne Reshtin Diference    ', 0, 1) WITH NOWAIT;
   
      UPDATE A                                                           
         SET VLERAAM       = ROUND(ISNULL((SELECT SUM(VLERAAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0),2),   -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
             AQVleraMbet   = ROUND(AQVleraHist - AMVleraCum -                               -- = (AQVleraCum )                            -- - AMVleraCum
                                   ISNULL((SELECT SUM(VLERAAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0),2)    -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
        FROM #TempDates1 A
       WHERE TipRow='D';
--    SELECT Deri='7.3',* FROM #TempDates1;  RETURN;   


   RAISERROR (N'     7.4    Fshihen reshtat per te cilat ka perfunduar Amortizimi    ', 0, 1) WITH NOWAIT; PRINT '';
        
      DELETE FROM #TempDates1 WHERE (SeqNum>0 AND TipRow<>'D') AND VLERAAM <= 0;


   RAISERROR (N'7.          FUND kontrolli per mbylljen e Amortizimit (Amortizim deri ne AMVleraMin te vleftes se asetit) ', 0, 1) WITH NOWAIT; PRINT '';



   RAISERROR (N'8           Variabla globale qe duhen ne afishim ', 0, 1) WITH NOWAIT; PRINT '';
   
                                                                        
      SELECT @VleraAM      = SUM(CASE WHEN TipRow='D' THEN 0 ELSE VLERAAM END),                                 -- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020
             @VleraAktiv   = SUM(CASE WHEN SEQNUM=0                                             THEN   VLERABS
                                      WHEN SEQNUM=1 AND (KODOPER IN ('BL','RK','CE','RV','SI')) THEN   VLERABS
                                      WHEN SEQNUM=1 AND (KODOPER IN ('CR'))                     THEN 0-VLERABS  -- 'SH','JP',  nuk jane pjese e te dhenave ????
                                      ELSE                                                           0          -- WHEN SEQNUM=1 AND (KODOPER IN ('AM','NP')) THEN 0
                                 END),
             @NrKartelaAM  = SUM(CASE WHEN SEQNUM=1 THEN 1 ELSE 0 END) 
        FROM #TempDates1;
--    SELECT VLERABS,KODOPER,KOD,SEQNUM FROM #TempDates1 WHERE SEQNUM=1 AND (KODOPER IN ('BL','RK','RV','CE','SI')) ORDER BY KOD,SEQNUM; RETURN;
--    SELECT Deri='7.',* FROM #TempDates1; PRINT @VleraAktiv; RETURN;


/*   -- NUK E DI PSE DUHET SEPSE KOMENTET MBUSHEN ME POSHTE EDHE PER AFISHIM EDHE PER KALIM NE DATABASE ...!      -- 30.03.2021

   RAISERROR (N'9           Komente te nevojeshme per periudhat e Amortizimit ', 0, 1) WITH NOWAIT; PRINT '';
            
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
                                                      M1.Month_Name + ' - '+
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
   -- SELECT * FROM #TempDates1 ORDER BY KOD,DATEDOK,SEQNUM; RETURN;  */

      
   RAISERROR (N'A. ****     FUND Amortizimi     **** ', 0, 1) WITH NOWAIT; PRINT CHAR(13)+CHAR(13);



          -- Kur @pOper='D' behet Display i tabeles se krijuar; ne rastin @pOper='NOTDISPL' vetem sa krijohete tabele por nuk afishohet. 
          -- Rasti me @pOper='NOTDISPL' duhet tek krahesimi i metodave ne vlefte per amortizimin (shiko dbo.Isd_AQAMDisplay2Metodes)

          IF NOT (@pOper='D' OR @pOper='NOTDISPL')
             BEGIN
               GOTO CREATEAM; 
             END;
   



             
   RAISERROR (N'B. ****     AFISHIMI  VIEW-se  PER  AMORTIZIMIN  E  AKTIVEVE     **** ', 0, 1) WITH NOWAIT; PRINT '';

/*                                                       -- Fusha per te ruajtur ose kolauduar algoritmim (per elemente sqarues ne algoritmin e Amortizimit)
   DECLARE @sFieldsNoDispl    Varchar(500);
         SET @sFieldsNoDispl  = 'Njesi,SeqNum,AQVleraCum,AQVleraMbet,AMVleraCum,AMDateFundit,IsAmVlereMbet,GjendjeAktiv,Kategori,Grupim,KODLM,DateEnd,NrMonthsAM,'+
                                'KodAF,NrKartelaAM,TotalAktiv,TotalAM,AMVleraMin,TipRow,NrRendor,SeqYear,TRow,TagNr,GjendjeAktivi,FieldsNoDisplay,'; */

      SELECT Zgjedhur,   
             A.Kod,A.Pershkrim,A.Njesi,A.DateDok,A.KodOper,
             A.SeqNum,
             A.NormeAM,
             VleraBS          = ROUND(A.VleraBS,0),
             VleraAM          = ROUND(CASE WHEN A.TipRow='D'                                            -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                                           THEN ISNULL((SELECT SUM(B.VLERAAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0)
                                           ELSE A.VLERAAM
                                      END,0),
             A.DateStartAM,
             DateTransAM      = CASE WHEN A.TipRow='D'                                                  -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                                     THEN ISNULL((SELECT MAX(B.DATETRANSAM)   FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),A.DateStartAM)
                                     ELSE A.DATETRANSAM
                                END,
             PershkrimAM      = A.PershkrimAM, 
             A.KomentAM,
             A.KomentMbyllje,
             AQVleraHist      = ROUND(CASE WHEN A.TipRow='D' OR A.SeqNum=0 THEN A.AQVleraHist ELSE 0 END,0),
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
             KodAF            = A.KOD +
                                CASE WHEN (@pDepKart=1  AND ISNULL(R1.DEP,'')<>'') OR (@pListKart=1 AND ISNULL(R1.LIST,'')<>'') THEN '.'+ISNULL(R1.DEP,'')  ELSE '' END +
                                CASE WHEN @pListKart=1  AND ISNULL(R1.LIST,'')<>''                                              THEN '.'+ISNULL(R1.LIST,'') ELSE '' END,
             NrYearsAM        = 0,
             NrMonthsAM       = CASE WHEN A.TipRow='D'                                     
                                     THEN ISNULL((SELECT SUM(B.NRMONTHSAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0)
                                     ELSE A.NrMonthsAM                                     -- WHERE A.KOD=B.KOD AND B.TipRow<>'D' 
                                END,
             A.NrDaysAM,
             NrKartelaAM      = @NrKartelaAM, 
             TotalAktiv       = @VleraAktiv,
             TotalAM          = @VleraAM, 
             AMVleraMin,  
             TipRow,  
             A.NrRendor, 
             SeqYear          = CASE WHEN A.TipRow='D' OR R2.NRTIMEAM=12
                                     THEN 0         
                                     ELSE ROW_NUMBER() OVER (PARTITION BY A.NRRENDOR, YEAR(A.DATETRANSAM) ORDER BY A.NRRENDOR,A.DATETRANSAM)
                                END,                -- OVER (PARTITION BY A.KOD, YEAR(A.DATETRANSAM) ORDER BY A.KOD,A.DATETRANSAM)
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
             DateTransAM      = CASE WHEN A.TipRow='D' OR A.SEQNUM=1                        
                                     THEN ISNULL((SELECT MAX(B.DateTransAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),A.DateStartAM)
                                     ELSE A.DATETRANSAM
                                END,
             PershkrimAM      = '',                                                         
             A.KomentAM,                  -- KomentAM = ISNULL((SELECT KOMENTAM FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow='D'),A.KOMENTAM),
             KomentMbyllje    = '',
             AQVleraHist      = ROUND(CASE WHEN A.TipRow='D' OR A.SEQNUM=1 THEN A.AQVleraHist ELSE 0 END,0),
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
             Kategori         = A.KATEGORI+' - '+R2.PERSHKRIM,  -- PERSHKRIMKTG,A.KATEGORI,A.GRUP,
             Grupim           = A.GRUP    +' - '+R3.PERSHKRIM,  -- PERSHKRIMGRP
             R1.KodLM,
             DateEnd          = A.DateEnd,                                       
             KodAF            = A.KOD + CASE WHEN (@pDepKart=1  AND ISNULL(R1.DEP,'')<>'') OR (@pListKart=1 AND ISNULL(R1.LIST,'')<>'') THEN '.'+ISNULL(R1.DEP,'')  ELSE '' END + 
                                        CASE WHEN @pListKart=1  AND ISNULL(R1.LIST,'')<>''                                              THEN '.'+ISNULL(R1.LIST,'') ELSE '' END,
             NrYearsAM        = 0,
             NrMonthsAM       = ISNULL((SELECT SUM(B.NRMONTHSAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0),
             A.NrDaysAM,
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


      UPDATE T
         SET NrYearsAM        = CEILING(T.NrMonthsAM/12),
             NrMonthsAM       = T.NrMonthsAM-(12*CEILING(T.NrMonthsAM/12))
        FROM #TempAmortizim T;


      UPDATE T
         SET KomentAM    = CASE WHEN YEAR(T.DateStartAM)<>YEAR(T.DateTransAM) THEN CONVERT(VARCHAR,T.DateStartAM,04) ELSE LEFT(CONVERT(VARCHAR,T.DateStartAM,04),5) END
                           + ' - '+CONVERT(VARCHAR,T.DateTransAM,04)+', '
                           + SUBSTRING(REPLACE(CASE WHEN NrYearsAM<>0  THEN ','+CAST(T.NrYearsAM  AS VARCHAR) +CASE WHEN T.NrYearsAM=1 THEN ' vit ' ELSE ' vite ' END ELSE '' END +
                                               CASE WHEN NrMonthsAM<>0 THEN ','+CAST(T.NrMonthsAM AS VARCHAR)+' muaj ' ELSE '' END +
                                               CASE WHEN NrDaysAM<>0   THEN ','+CAST(T.NrDaysAM   AS VARCHAR)+' dite ' ELSE '' END,' ,',','),2,100)
                           + CASE WHEN ISNULL(T.KomentMbyllje,'')<>''  THEN ' - '+T.KomentMbyllje ELSE '' END,

             PershkrimAM = CASE WHEN YEAR(T.DateStartAM)=YEAR(T.DateTransAM) AND MONTH(T.DateStartAM)=MONTH(T.DateTransAM)
			                         THEN SUBSTRING(M1.Month_Name,1,10)+' '+CAST(YEAR(T.DateStartAM) AS VARCHAR)
								WHEN YEAR(T.DateStartAM)=YEAR(T.DateTransAM)
								     THEN SUBSTRING(M1.Month_Name,1,10)+' - '+SUBSTRING(M2.Month_Name,1,10)+' '+CAST(YEAR(T.DateStartAM) AS VARCHAR)
								ELSE 
								          SUBSTRING(M1.Month_Name,1,10)+' '  +SUBSTRING(CAST(YEAR(T.DateStartAM) AS VARCHAR),3,2)+
									  '-'+SUBSTRING(M2.Month_Name,1,10)+' '  +SUBSTRING(CAST(YEAR(T.DateTransAM) AS VARCHAR),3,2)
							 END
        FROM #TempAmortizim  T INNER JOIN #MonthNames M1 ON MONTH(T.DateStartAM)=M1.Month_Number
                               INNER JOIN #MonthNames M2 ON MONTH(T.DateTransAM)=M2.Month_Number;


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


       ALTER TABLE  #TempDates1 ADD  NrYearsAM Varchar(100) NULL;  

      UPDATE T
         SET NrYearsAM     = CEILING(T.NrMonthsAM/12),
             NrMonthsAM    = T.NrMonthsAM-(12*CEILING(T.NrMonthsAM/12))
        FROM #TempDates1 T;

      UPDATE T
         SET KOMENTAM      = CASE WHEN YEAR(T.DateStartAM)<>YEAR(T.DateTransAM) THEN CONVERT(VARCHAR,T.DateStartAM,04) ELSE LEFT(CONVERT(VARCHAR,T.DateStartAM,04),5) END
                             +' - '+CONVERT(VARCHAR,T.DateTransAM,04)+', '
                             +
                             SUBSTRING(REPLACE(CASE WHEN NrYearsAM<>0  THEN ','+CAST(T.NrYearsAM  AS VARCHAR) +CASE WHEN T.NrYearsAM=1 THEN ' vit ' ELSE ' vite ' END ELSE '' END +
                                               CASE WHEN NrMonthsAM<>0 THEN ','+CAST(T.NrMonthsAM AS VARCHAR)+' muaj ' ELSE '' END +
                                               CASE WHEN NrDaysAM<>0   THEN ','+CAST(T.NrDaysAM   AS VARCHAR)+' dite ' ELSE '' END,' ,',','),2,100)+
                             + 
                             CASE WHEN ISNULL(T.KomentMbyllje,'')<>''  THEN ' - '+T.KomentMbyllje ELSE '' END,
             PERSHKRIMAM   = CASE WHEN YEAR(T.DateStartAM)=YEAR(T.DateTransAM) AND MONTH(T.DateStartAM)=MONTH(T.DateTransAM)
			                           THEN SUBSTRING(M1.Month_Name,1,10)+' '+CAST(YEAR(T.DateStartAM) AS VARCHAR)
								  WHEN YEAR(T.DateStartAM)=YEAR(T.DateTransAM)
								       THEN SUBSTRING(M1.Month_Name,1,10)+' - '+SUBSTRING(M2.Month_Name,1,10)+' '+CAST(YEAR(T.DateStartAM) AS VARCHAR)
								  ELSE 
								            SUBSTRING(M1.Month_Name,1,10)+' '+SUBSTRING(CAST(YEAR(T.DateStartAM) AS VARCHAR),3,2)+
										'-'+SUBSTRING(M2.Month_Name,1,10)+' '+SUBSTRING(CAST(YEAR(T.DateTransAM) AS VARCHAR),3,2)
							 END
        FROM #TempDates1 T INNER JOIN #MonthNames M1 ON MONTH(T.DateStartAM)=M1.Month_Number
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
             KOD           = A.KOD + '.' + CASE WHEN @pDepKart=1  THEN ISNULL(R1.DEP,'')  ELSE '' END + '.'+
                                           CASE WHEN @pListKart=1 THEN ISNULL(R1.LIST,'') ELSE '' END + '..',
             KODAF         = A.KOD + CASE WHEN (@pDepKart=1  AND ISNULL(R1.DEP,'')<>'') OR (@pListKart=1 AND ISNULL(R1.LIST,'')<>'') THEN '.'+ISNULL(R1.DEP,'')  ELSE '' END +
                                     CASE WHEN @pListKart=1  AND ISNULL(R1.LIST,'')<>''                                              THEN '.'+ISNULL(R1.LIST,'') ELSE '' END,
             A.KOD,A.PERSHKRIM,A.NJESI,NJESINV=A.NJESI,
             A.DateTransAM,
             VLERABS       = ROUND(CAST(VLERABS AS DECIMAL(34,4)),2),--CONVERT(DECIMAL(18,2),A.VLERABS),                                    
             VLERAAM       = ROUND(CONVERT(DECIMAL(34,4),A.VLERAAM),2),
             A.NORMEAM,
             R1.BC,
             KOMENT        = RTRIM(LTRIM(A.PERSHKRIMAM)) + CASE WHEN A.PERSHKRIMAM<>'' AND ISNULL(A.KomentAM,'')<>'' THEN '/'  ELSE '' END + ISNULL(A.KomentAM,''),
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
