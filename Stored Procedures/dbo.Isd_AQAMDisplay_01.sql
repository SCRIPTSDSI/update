SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE        procedure [dbo].[Isd_AQAMDisplay_01]    -- Kufizimi ishte 5% per mbylljen e amortizimit
(                                                     -- Kufizim me vlerem minimale shiko Isd_AQAMDisplay
  @pDateEnd   Varchar(20),
  @pDateDok   Varchar(20),
  @pShenim1   Varchar(150),
  @pShenim2   Varchar(150),
  @pWhere     Varchar(Max),
  @pOper      Varchar(10),
  @pDepKart   Int,
  @pListKart  Int,
  @pUser      Varchar(30),
  @pTableTmp  Varchar(30)
)

AS   -- EXEC dbo.Isd_AQAMDisplay '31/12/2022','31/12/2018','Amortizim vjetor','Amortizim makineri','R1.KOD=''AS000001''','D',0,0,'ADMIN','##AA';
     
         SET NOCOUNT ON

     DECLARE @sSql           Varchar(Max),
             @NrRendor       Int,
             @sWhere         Varchar(Max),
             @VleraAktiv     Float,
             @VleraAM        Float,
             @NrKartelaAM    Int,
             @Shenim1        Varchar(150),
             @Shenim2        Varchar(150),
             @sTableTmp      Varchar(30),
             @DateEnd        DateTime,
             @DateDok        DateTime;
             
         SET @DateEnd      = dbo.DATEVALUE(@pDateEnd);
         SET @DateDok      = dbo.DATEVALUE(@pDateDok);
         SET @Shenim1      = @pShenim1;
         SET @Shenim2      = @pShenim2;
         SET @sWhere       = @pWhere;
         SET @sTableTmp    = @pTableTmp;

          IF OBJECT_ID('TEMPDB..#TempScr')      IS NOT NULL
             DROP TABLE #TempScr;
          IF OBJECT_ID('TEMPDB..#TempDtAM')     IS NOT NULL
             DROP TABLE #TempDtAM;
          IF OBJECT_ID('TEMPDB..#TempShitje')   IS NOT NULL
             DROP TABLE #TempShitje;
          IF OBJECT_ID('TEMPDB..#TempSistemim') IS NOT NULL
             DROP TABLE #TempSistemim;
          IF OBJECT_ID('TEMPDB..#TempDates')    IS NOT NULL
             DROP TABLE #TempDates;
          IF OBJECT_ID('TEMPDB..#TempDates1')   IS NOT NULL
             DROP TABLE #TempDates1;
          IF OBJECT_ID('TEMPDB..#TempDates2')   IS NOT NULL
             DROP TABLE #TempDates2;
          IF OBJECT_ID('TEMPDB..#TempDates3X')  IS NOT NULL
             DROP TABLE #TempDates3X;
          IF OBJECT_ID('TEMPDB..#TempDates3Y')  IS NOT NULL
             DROP TABLE #TempDates3Y;
          IF OBJECT_ID('TEMPDB..#TempSeri')     IS NOT NULL
             DROP TABLE #TempSeri;
          IF OBJECT_ID('TempDB..#TempSeriX')    IS NOT NULL
             DROP TABLE #TempSeriX;
          IF OBJECT_ID('TEMPDB..#MonthNames')   IS NOT NULL
             DROP TABLE #MonthNames;

         
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


-- 1.        Filtrimi i te dhenave tek tabelat AQ, AQSCR, krijimi i temporareve

         SET @sSql = '
                                                                     
             INSERT INTO #TempDtAM                                   -- 1. Tabela me Kartelat dhe datat e fundit te amortizimit
                   (KOD, DateAMLast, AMVleraCum, AQVleraCum)
             SELECT B.KARTLLG,
                    DTAM       = ISNULL(MAX(CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END),0),
                    VLAMCUM    = ROUND(SUM(ISNULL(B.VLERAAM,0)),2),
                    AQVleraCum = 0.0 
               FROM AQ A INNER JOIN AQSCR      B  ON A.NRRENDOR=B.NRD
                         INNER JOIN AQKARTELA  R1 ON B.KARTLLG=R1.KOD
                         INNER JOIN AQKATEGORI R2 ON R2.KOD=R1.KATEGORI
              WHERE (A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''')) AND (UPPER(ISNULL(B.KODOPER,'''')) IN (''CE'',''AM'')) AND 
                    (1=1)
           GROUP BY B.KARTLLG; 
           
             UPDATE T                                                -- 2. Llogaritja e vleftes se asetit deri diten e amortizimit te fundit
                SET T.AQVleraCum = ROUND(ISNULL(A.AQValue,0),2)
               FROM #TempDtAM T INNER JOIN (
                                             SELECT KOD=B.KARTLLG, AQValue=SUM(ISNULL(B.VLERABS,0))
                                               FROM AQ A INNER JOIN AQSCR      B  ON A.NRRENDOR=B.NRD
                                                         INNER JOIN #TempDtAM  T  ON B.KARTLLG =T.KOD
                                                         INNER JOIN AQKARTELA  R1 ON B.KARTLLG=R1.KOD
                                                         INNER JOIN AQKATEGORI R2 ON R2.KOD=R1.KATEGORI
                                              WHERE (A.DATEDOK<=T.DateAMLast) AND (A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''')) AND 
                                                    (UPPER(ISNULL(B.KODOPER,'''')) IN (''CE'',''BL'',''MM'')) AND 
                                                    (1=1)
                                           GROUP BY B.KARTLLG 
                                           
                                            )       A     ON T.KOD=A.KOD;
                      
                                                          
             INSERT INTO #TempScr                                    -- 3. Tabela me Kartelat dhe veprimet qe do te amortizohen
                   (NRRENDOR)
             SELECT B.NRRENDOR
               FROM AQ A INNER JOIN AQSCR      B  ON A.NRRENDOR=B.NRD
                         INNER JOIN AQKARTELA  R1 ON B.KARTLLG=R1.KOD
                         INNER JOIN AQKATEGORI R2 ON R2.KOD=R1.KATEGORI
              WHERE A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''') AND (UPPER(ISNULL(B.KODOPER,'''')) IN (''CE'',''BL'',''MM'')) AND 
                   (1=1);
                   
                   
             INSERT INTO #TempShitje                                 -- 4. Tabela me Kartelat dhe date shitje/jashte perdorimit per te kufizuar datat seri te amortizimit
                   (KOD,AQDateShitje,KODOPER)
             SELECT B.KARTLLG,B.DATEOPER,B.KODOPER
               FROM AQ A INNER JOIN AQSCR      B  ON A.NRRENDOR=B.NRD
                         INNER JOIN AQKARTELA  R1 ON B.KARTLLG=R1.KOD
                         INNER JOIN AQKATEGORI R2 ON R2.KOD=R1.KATEGORI
              WHERE A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''') AND (UPPER(ISNULL(B.KODOPER,'''')) IN (''SH'',''JP'',''CR'')) AND 
                   (1=1);
                   

             INSERT INTO #TempSistemim                               -- 5. Tabela me Kartelat dhe date sistemimi (Te perpunohet me vone    03.12.2018)
                   (KOD,AQDateSistemim,AQVleraSistemim)
             SELECT B.KARTLLG,A.DATEDOK,ROUND(ISNULL(B.VLERABS,0),2)
               FROM AQ A INNER JOIN AQSCR      B  ON A.NRRENDOR=B.NRD
                         INNER JOIN AQKARTELA  R1 ON B.KARTLLG=R1.KOD
                         INNER JOIN AQKATEGORI R2 ON R2.KOD=R1.KATEGORI
              WHERE A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''') AND (UPPER(ISNULL(B.KODOPER,'''')) IN (''SI'')) AND 
                   (1=1);';
                   
          IF  @sWhere<>''          
              SET @sSql = Replace(@sSql,'1=1',@sWhere);
        EXEC (@sSql);     -- PRINT  @sSql;  SELECT * FROM #TempScr; SELECT * FROM #TempDtAM; RETURN;


          IF OBJECT_ID('TEMPDB..#TempDatesX')  IS NOT NULL
             DROP TABLE #TempDatesX;
             

      SELECT A.*,
             DTAM = CASE WHEN ISNULL(B.DateAMLast,0)=0 OR A.DateDok>B.DateAMLast
                              THEN CASE WHEN A.KODOPER IN ('CE')      THEN A.DATEDOK
                                        WHEN A.KODOPER IN ('BL','MM') THEN A.DATEDOK   
                                        ELSE                               B.DateAMLast
                                   END
                         ELSE                                              B.DateAMLast
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
                    VLERABS       = ROUND(ISNULL(B.VLERABS,0),2),
                    K.KATEGORI, 
                    K.GRUP,
                    R.NRTIMEAM,
                    A.DOK_JB,
                    B.NRRENDOR 
               FROM AQ A INNER JOIN AQSCR      B  ON A.NRRENDOR=B.NRD
                         INNER JOIN #TempScr   T  ON B.NRRENDOR=T.NRRENDOR
                         INNER JOIN AQKARTELA  K  ON B.KARTLLG =K.KOD
                         INNER JOIN AQKATEGORI R  ON R.KOD=K.KATEGORI
                         LEFT  JOIN #TempDtAM  Dt ON B.KARTLLG=Dt.KOD
              WHERE A.DATEDOK<=@DateEnd AND B.KODOPER IN ('CE','BL','MM') 
             ) A  LEFT  JOIN #TempDtAM B ON A.KOD=B.KOD
       WHERE DateStart<=@DateEnd
    ORDER BY KOD,DateDok;



-- 1.1   Per ato blerje apo MM para amortizimit te fundit ruhet nje rekord i kumuluar .... (reshtat me kriterin OrderParaAM>1 fshihen)

      SELECT A.*,
             OrderParaAM      = CASE WHEN DATEDOK<DtAM 
                                     THEN CASE WHEN ROW_NUMBER() OVER (PARTITION BY KOD ORDER BY KOD,DATEDOK)=1 THEN 1 ELSE 2 END
                                     ELSE 0
                                END         
        INTO #TempDates
        FROM #TempDatesX A
    ORDER BY KOD,DateDok;
--    SELECT * FROM #TempScr; SELECT * FROM #TempDtAM; Select * From #TempDates; RETURN;                                                                                 

      DELETE FROM #TempDates WHERE OrderParaAM>1;   
   

          IF OBJECT_ID('TEMPDB..#TempScr')      IS NOT NULL
             DROP TABLE #TempScr;

          IF OBJECT_ID('TEMPDB..#TempDatesX')   IS NOT NULL
             DROP TABLE #TempDatesX;

-- 1.FUND    Gjenerimi i tabelave temporare





-- 2.        Zberthimi ne seri data per evidentimin e amortizimit [DateStart, DateEnd]
          -- Ndertimi i tabeles me date seri per amortizimin (tabela #TempSeri) e cial ndertohet me ndihmen e funksionit Isd_AQAMDateRange


             -- 2.1     Gjenerimi i serise se datave, mbushet tabela #TempSeri 

      SELECT NrRendor = CAST(0 AS BIGINT), StartDate = DTAM, EndDate = DATEDOK, KOD, NrOrd = 0, TRow=CAST(0 AS BIT),
             NrTimeAM,KODOPER 
        INTO #TempSeri 
        FROM #TempDates 
       WHERE 1=2;
       
        EXEC dbo.Isd_AQAMSeriDates '#TempDates','#TempSeri',@pDateEnd;
 --   SELECT * FROM #TempSeri; SELECT * FROM #TempDates; RETURN;



             -- 2.2     Kufizimi i serise se datave deri ne date shitje aseti (ne se ka te tille brenda periushes)
  
  
          IF OBJECT_ID('TempDB..#TempSeriX')    IS NOT NULL
             DROP TABLE #TempSeriX;
             
      SELECT TOP 1 A.Kod,A.NrOrd,T.AQDateShitje,T.KodOper      -- 2.2.1      Gjendet e para date serie  >= se date shitje dhe ruhet tek #TempSeriX
        INTO #TempSeriX
        FROM #TempSeri A INNER JOIN #TempShitje T ON A.KOD=T.KOD
       WHERE A.EndDate>T.AQDateShitje
    ORDER BY A.KOD,A.NrOrd;         

      UPDATE A                                                 -- 2.2.2      Per rekordin qe ka te paren date >= se date shitje ruhet si date ajo e shitjes
         SET A.EndDate = T.AQDateShitje, A.KodOper=T.KodOper
        FROM #TempSeri A INNER JOIN #TempSeriX T ON A.KOD=T.KOD AND A.NrOrd=T.NrOrd;
        
      DELETE A                                                 -- 2.2.3      Fshihen te gjithe rekordet e serise jashte dates se shitjes
        FROM #TempSeri A INNER JOIN #TempSeriX T ON A.KOD=T.KOD 
       WHERE A.NrOrd>T.NrOrd; 


          IF OBJECT_ID('TempDB..#TempSeriX')    IS NOT NULL
             DROP TABLE #TempSeriX;
             
          IF OBJECT_ID('TEMPDB..#TempShitje')   IS NOT NULL
             DROP TABLE #TempShitje;
    -- SELECT * FROM #TempSeri; RETURN                    
                      


-- 3.        Tabela #TempDates1 eshte kryesore ne algoritmin per amortizimin


      SELECT Dt.*, 
             DateStartAM      = A.StartDate,
             DateTransAM      = A.EndDate,
             DateAMLast       = Dt.DTAM,
             DATEEND          = @DateEnd,

             VLERAAM          = CAST(0.0 AS FLOAT),
             AMVleraCum       = CAST(0.0 AS FLOAT),     -- Shuma e amortizimeve para pariudhes vleresuese (referuar DateAMLast)
             AMVleraPrg       = CAST(0.0 AS FLOAT),     -- Amortizimi progresiv per periudhen e rivleresimit (amortizimit)
             AMVleraTot       = CAST(0.0 AS FLOAT),     -- Amortizim total (progresiv te periudhes + Amortizimi i cumuluar)

             AQVleraCum       = CAST(0.0 AS FLOAT),     -- Shuma e vlerave te aktivit para pariudhes vleresuese (referuar DateAMLast)
             AQVleraMbet      = CAST(0.0 AS FLOAT),
             AQVleraSistemim  = CAST(0.0 AS FLOAT),
             
             PERSHKRIMAM      = Space(150),
             NrMonthsAM       = 0,
             TipRow           = ' ',
             ZGJEDHUR         = CAST(1 AS BIT),
             KodMbyllje       = A.KodOper,
             SeqNum           = ROW_NUMBER() OVER (PARTITION BY A.NRRENDOR,Dt.KOD ORDER BY A.NRRENDOR,Dt.KOD,A.StartDate)--,
             
        INTO #TempDates1     

        FROM #TempDates Dt LEFT JOIN #TempSeri A ON Dt.NRRENDOR=A.NRRENDOR 
    -- WHERE Dt.DateDok>=Dt.DTAM
    ORDER BY A.NRRENDOR,Dt.KOD,A.StartDate; 
--    SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM; --SELECT * FROM #TempSeri; RETURN


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


      UPDATE A
         SET DateAMLast = B.DateAMLast,  AMVleraCum = B.AMVleraCum,  AQVleraCum = B.AQVleraCum
        FROM #TempDates1 A INNER JOIN #TempDtAM B ON A.KOD=B.KOD;

      UPDATE A
         SET DateAMLast = A.DATEDOK,     AMVleraCum = 0,             AQVleraCum = A.VLERABS
        FROM #TempDates1 A 
       WHERE NOT EXISTS (SELECT NRRENDOR FROM #TempDtAM B WHERE A.KOD=B.KOD);

      UPDATE A
         SET DateAMLast = A.DATEDOK
        FROM #TempDates1 A 
       WHERE DATEDOK>DateAMLast;

                                                               -- 4.2        Gjendet e para date serie  >= ku futet vlefta per sistemin e asetit
      UPDATE A                                                            -- (Te perpunohet me vone    03.12.2018)
         SET AQVleraSistemim  = T.AQVleraSistemim
        FROM #TempDates1 A INNER JOIN #TempSistemim T ON A.KOD=T.KOD
       WHERE A.DateStartAM<=T.AQDateSistemim AND T.AQDateSistemim<=A.DateTransAM;         
--  SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM; SELECt * FROM #TempSistemim; RETURN 


          IF OBJECT_ID('TEMPDB..#TempDtAM')     IS NOT NULL
             DROP TABLE #TempDtAM;

          IF OBJECT_ID('TEMPDB..#TempSistemim') IS NOT NULL
             DROP TABLE #TempSistemim;
   
    


-- 5.            Shtohet nje resht per date diference. Per kete perdoret #TempDates2 e cila ne fund i shtohet #TempDates1
             --  Ky resht dallohet nga te tjeret sepse ka TipRow='D'. U shtua per te ritur lexueshmerine e informacionit ne afishim
             --  Edhe ky resht edhe ai me SeqNum=0 jane per te ritur lexueshmerine e te dhenave ne afishim ne program  
             --  Kujdes: Llogaritet ne muaj dhe dite diferenca e periudhes nga DateEnd-DateTransAM

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


      UPDATE #TempDates1 
         SET NrMonthsAM    = DATEDIFF(m,DateStartAM,DateTransAM)+1;
         
         
         
      -- 6.1    FILLIM AVK:      Metoda Amortizimit Vefte Konstant (sipas normes se Amortizimit)



             -- 6.1.1   Llogaritja e vleftes se amortizimit
      
      UPDATE T
         SET PERSHKRIMAM   = CASE WHEN T.TipRow='D'
                                  THEN PERSHKRIMAM
                                  ELSE SUBSTRING(M1.Month_Name,1,3)+' - '+SUBSTRING(M2.Month_Name,1,3)+' '+SUBSTRING(CAST(YEAR(T.DateStartAM) AS VARCHAR),1,4)
                             END,
             NrMonthsAM    = A.NrMonthsAM,
             VLERAAM       = CASE WHEN T.TipRow='D'                 THEN VLERAAM                              
                                  WHEN ISNULL(A.NrMonthsAM,0)=0     THEN 0 
                                  ELSE                                   ROUND((A.NrMonthsAM*(T.AQVleraCum) * T.NORMEAM)/1200, 2) -- Konstante
                             END                                      -- ROUND((A.NrMonthsAM*( T.VLERABS + T.AQVleraCum) * T.NORMEAM)/1200, 2) -- Konstante
        FROM 
           (
             SELECT KOD,SeqNum, NrMonthsAM=DATEDIFF(m,DateStartAM,DateTransAM)+1
               FROM #TempDates1 
              WHERE ISNULL(IsAMVlereMbet,0)=0 
              ) A  
                   INNER JOIN #TempDates1 T  ON A.KOD=T.KOD AND A.SeqNum=T.SeqNum
                   INNER JOIN #MonthNames M1 ON MONTH(T.DateStartAM)=M1.Month_Number
                   INNER JOIN #MonthNames M2 ON MONTH(T.DateTransAM)=M2.Month_Number;


             -- 6.1.2   AVK: Llogaritja e vleftes se mbetur (fusha AQVleraMbet me vlefta progresive) me metoden rekursive, dhe te dhenat ruhen provizorisht tek tabela #TempDates3X.
                     -- Llogaritja e mesiperme (per VLERAAM tek 6.1.1) mund te behej dhe ketu.
                     -- Test 5% i mbylljes se Amortizimit mund te jete variable. 
      

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
               FROM #TempDates1 t JOIN SumAm A ON A.NRRENDOR=T.NRRENDOR AND A.SeqNum=t.SeqNum - 1                              -- ON A.KOD=t.KOD AND A.SeqNum = t.SeqNum - 1
              WHERE ISNULL(IsAMVlereMbet,0)=0 AND TipRow<>'D' AND                                                              -- AND A.SeqNum <> 1
                    A.AQVleraMbet>=0 AND               
                    CASE WHEN t.AQVleraCum>0 THEN ROUND(100-(100*(t.AQVleraCum-A.AQVleraMbet)/t.AQVleraCum),2) ELSE 5 END>=5   -- deri 5% te vleftes     
              
           )
           
             SELECT * INTO #TempDates3X FROM    SumAm    -- WHERE AQVleraMbet>=0  -- Kujdes ....!   Bllokoje ne rekursivitet sepse fryhet kot tabela temporare SumAm 
             
OPTION  ( MAXRECURSION 1000 );


      UPDATE A
         SET A.AQVleraMbet = B.AQVleraMbet       
        FROM #TempDates1 A INNER JOIN #TempDates3X B ON A.NRRENDOR=B.NRRENDOR AND A.SeqNum=B.SeqNum  -- ON A.KOD=B.KOD AND A.SeqNum=B.SeqNum
       WHERE ISNULL(A.IsAMVlereMbet,0)=0;
--    SELECT * FROM #TempDates3X ORDER BY KOD,SEQNUM; SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM;RETURN;


          IF OBJECT_ID('TEMPDB..#TempDates3X')  IS NOT NULL
             DROP TABLE #TempDates3X;



      -- 6.1.FUND   AVK:        metoda Amortizimit Vlefte Konstante (sipas normes se amortizimit)






   -- UPDATE #TempDates1
   --    SET AQVleraCum=0, AQVleraMbetStart=0, AQVleraCumStart=0, AMVleraCumStart=0
   --  WHERE KODOPER IN ('CE','BL','MM') AND SEQNUM=1;
   -- SELECT * FROM #TempDates1;RETURN;
 




      -- 6.2.       FILLIM AVM:     metoda Amortizimit Vlefte Mbetur (kujdes filtrohet sipas natyres se kategorise)  


             -- 6.2.1   Kalkulohet fusha e nr te muajve qe llogaritet amortizimi
      
      UPDATE #TempDates1 
         SET NrMonthsAM    = CASE WHEN TipRow='D' THEN NrMonthsAM ELSE DATEDIFF(m,DateStartAM,DateTransAM)+1 END
       WHERE ISNULL(IsAMVlereMbet,0)=1; 
--    SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM; RETURN;



             -- 6.2.2   AVM: Llogaritja e vleftes se mbetur (fusha AQVleraMbet me vlefta progresive) me metoden rekursive, dhe te dhenat ruhen provizorisht tek tabela #TempDates3Y.
                     -- Test 5% i mbylljes se Amortizimit mund te jete variable. 

       ALTER TABLE  #TempDates1 ADD  AQVleraStart  FLOAT NULL;   
      UPDATE #TempDates1 SET AQVleraStart = AQVleraCum - AMVleraCum;


;WITH  SumAm
        AS ( 
             SELECT t.Kod, 
                    t.VLERABS,
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
               FROM #TempDates1 t JOIN SumAm A ON A.NRRENDOR=T.NRRENDOR AND A.SeqNum=t.SeqNum - 1                              -- ON A.KOD=t.KOD AND A.SeqNum = t.SeqNum - 1
              WHERE ISNULL(IsAMVlereMbet,0)=1 AND TipRow<>'D' AND                                                              -- AND A.SeqNum <> 1
                    t.AQVleraCum>0 AND 
                    A.AQVleraMbet>=0 AND ROUND(100-(100*(t.AQVleraCum-(A.VLERAAM+A.AQVleraMbet))/t.AQVleraCum),2)>=5           -- deri 5% te vleftes

           )
           
             SELECT * INTO #TempDates3Y FROM    SumAm    -- WHERE AQVleraMbet>=0 -- Kujdes ....!   Bllokoje ne rekursivitet sepse fryhet kot tabela temporare SumAm
             
OPTION  ( MAXRECURSION 1000 );
--    SELECT * FROM #TempDates3Y ORDER BY KOD,SEQNUM; RETURN;

       ALTER TABLE #TempDates1 DROP COLUMN AQVleraStart;   


      UPDATE A
         SET A.VLERAAM     = B.VLERAAM, 
             A.AQVleraMbet = B.AQVleraMbet,       
             VLERABS       = A.AQVleraCum-A.AMVleraCum
        FROM #TempDates1 A INNER JOIN #TempDates3Y B ON A.NRRENDOR=B.NRRENDOR AND A.SeqNum=B.SeqNum -- ON A.KOD=B.KOD AND A.SeqNum=B.SeqNum
       WHERE ISNULL(A.IsAMVlereMbet,0)=1;
--    SELECT * FROM #TempDates3Y ORDER BY KOD,SEQNUM; SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM; RETURN;
 

          IF OBJECT_ID('TEMPDB..#TempDates3Y')  IS NOT NULL
             DROP TABLE #TempDates3Y;



      -- 6.2.FUND   AVM:        metoda Amortizimit Vlefte Mbetur (kujdes filtrohet sipas natyres se kategorise)
      
      
      

      UPDATE A
         SET VLERABS       = A.AQVleraCum - CASE WHEN ISNULL(A.IsAMVlereMbet,0)=1 THEN A.AMVleraCum ELSE 0 END
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



-- 7.        FILLIM kontrolli per mbylljen e Amortizimit (Amortizim deri ne 5% te vleftes se asetit)

   
          IF OBJECT_ID('TEMPDB..#TempDatesY')   IS NOT NULL
             DROP TABLE #TempDatesY;


             -- 7.1     Gjendet i pari resht ku vlera e mbetur e asetit eshte <= 5% (5% mund te jete edhe variable). Rezultati ruhet tek tabela #TempDatesY.
    
      
      SELECT TOP 1 *,PERQ=ROUND(100-(100*(AQVleraCum-AQVleraMbet)/AQVleraCum),2) 
        INTO #TempDatesY
        FROM #TempDates1
       WHERE (AQVleraCum-AQVleraMbet>0) AND ROUND(100-(100*(AQVleraCum-AQVleraMbet)/AQVleraCum),2)<=5  -- Test i mbylljes mund te jete variable 
    ORDER BY KOD,NRRENDOR,SEQNUM;
    --SELECT * FROM #TempDatesY;
    
    
             -- 7.2     Modifikohen te gjithe rekordet pas kesaj vlefte te pare (kriteri SeqNum)
                     -- Reshti pare me <= 5% mer gjithe vleften e asetit te mbetur per vlefte amortizimi, 
                     -- gjithe rekorder e tjera pas ketij kane vlefte amortizimi zero.
      
      UPDATE A
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
       WHERE A.SeqNum>0 AND A.TipRow<>'D';
--    SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM;RETURN;

          IF OBJECT_ID('TEMPDB..#TempDatesY')   IS NOT NULL
             DROP TABLE #TempDatesY;
    
   
             -- 7.3     Statistika ne Reshtin Diference   
   
      UPDATE A                                                           
         SET VLERAAM       =  ISNULL((SELECT SUM(VLERAAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0), -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
             AQVleraMbet   = (AQVleraCum - AMVleraCum)
                              -                                          
                              ISNULL((SELECT SUM(VLERAAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0)  -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
        FROM #TempDates1 A
       WHERE TipRow='D';

   

             -- 7.4     Fshihen reshtat per te cilat ka perfunduar Amortizimi 
        
      DELETE FROM #TempDates1 WHERE (SeqNum>0 AND TipRow<>'D') AND VLERAAM <= 0;


-- 7.FUND    Kontrolli per mbylljen e Amortizimit.


   
   
      SELECT @VleraAM      = SUM(CASE WHEN TipRow='D' THEN 0 ELSE VLERAAM END),
             @VleraAktiv   = SUM(CASE WHEN SEQNUM=0                                        THEN   VLERABS
                                      WHEN SEQNUM=1 AND (KODOPER IN ('BL','MM','CE','SI')) THEN   VLERABS
                                      WHEN SEQNUM=1 AND (KODOPER IN ('SH','JP','CR'))      THEN 0-VLERABS  -- nuk jane pjese e te dhenave ????
                                      WHEN SEQNUM=1 AND (KODOPER IN ('AM','NP'))           THEN 0
                                      ELSE                                                      0
                                 END),
             @NrKartelaAM  = SUM(CASE WHEN SEQNUM=1 THEN 1 ELSE 0 END) 
        FROM #TempDates1;
--    SELECT VLERABS,KODOPER,KOD,SEQNUM FROM #TempDates1 WHERE SEQNUM=1 AND (KODOPER IN ('BL','MM','CE','SI')) ORDER BY KOD,SEQNUM; RETURN;
--     PRINT @VleraAktiv;    



-- 8.              FILLIM Komente te nevojeshme per periudhat e Amortizimit
            
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
       

          IF @pOper<>'D'
             BEGIN
               GOTO CREATEAM; 
             END;
   



             
--                  AFISHIMI  VIEW-se  PER  AMORTIZIMIN  E  AKTIVEVE        

      SELECT ZGJEDHUR,   
             A.KOD,A.PERSHKRIM,A.NJESI,A.DATEDOK,A.KODOPER,
             A.SEQNUM,
             A.NORMEAM,
             A.VLERABS,
             VLERAAM          = CASE WHEN A.TipRow='D'                                      -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                                     THEN ISNULL((SELECT SUM(B.VLERAAM)     FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0)
                                     ELSE A.VLERAAM
                                END,     
             A.DATESTARTAM,
             DATETRANSAM      = CASE WHEN A.TipRow='D'                                      -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                                     THEN ISNULL((SELECT MAX(B.DATETRANSAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),A.DateStartAM)
                                     ELSE A.DATETRANSAM
                                END,
             A.PERSHKRIMAM,
             KOMENTAM, 
             
             AQVleraCum       = CASE WHEN A.TipRow='D' THEN A.AQVleraCum ELSE 0 END,
             AQVleraMbet      = ROUND(A.AQVleraMbet,0),
                
             AMVleraCum       = CASE WHEN A.TipRow='D' 
                                     THEN A.AMVleraCum+ISNULL((SELECT SUM(B.VLERAAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0) 
                                     ELSE 0 
                                END,
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
             KATEGORI         = CASE WHEN A.TipRow='D' THEN A.KATEGORI+' - '+R2.PERSHKRIM ELSE '' END,  -- PERSHKRIMKTG, -- A.KATEGORI,A.GRUP,R1.KODLM,
             GRUPIM           = CASE WHEN A.TipRow='D' THEN A.GRUP    +' - '+R3.PERSHKRIM ELSE '' END,  -- PERSHKRIMGRP
             A.DATEEND,
             NRMONTHSAM       = CASE WHEN A.TipRow='D'                                     -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                                     THEN ISNULL((SELECT SUM(B.NRMONTHSAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0)
                                     ELSE A.NRMONTHSAM
                                END, -- A.NRMONTHSAM
             KODAF            = A.KOD +
                                CASE WHEN (@pDepKart=1  AND ISNULL(R1.DEP,'')<>'') OR (@pListKart=1 AND ISNULL(R1.LIST,'')<>'') 
                                     THEN '.'+ISNULL(R1.DEP,'') 
                                     ELSE '' 
                                END   +
                                CASE WHEN @pListKart=1  AND ISNULL(R1.LIST,'')<>'' 
                                     THEN '.'+ISNULL(R1.LIST,'') 
                                     ELSE '' 
                                END,
             A.YMD, A.Yr, A.Mn, A.Dy, 
             NRKARTELAAM      = @NrKartelaAM, 
             TOTALAKTIV       = @VleraAktiv,
             TOTALAM          = @VleraAM,  
             TipRow,  
             A.NRRENDOR, 
             SEQYEAR          = CASE WHEN A.TipRow='D' OR R2.NRTIMEAM=12
                                     THEN 0         -- OVER (PARTITION BY A.KOD, YEAR(A.DATETRANSAM) ORDER BY A.KOD,A.DATETRANSAM)
                                     ELSE ROW_NUMBER() OVER (PARTITION BY A.NRRENDOR, YEAR(A.DATETRANSAM) ORDER BY A.NRRENDOR,A.DATETRANSAM)
                                END,
             TROW             = CAST(0 AS BIT),
             TAGNR            = CAST(0 AS BIT)
             
        INTO #TempAmortizim
        
        FROM #TempDates1  A  INNER JOIN AQKARTELA  R1 ON A.KOD=R1.KOD
                             LEFT  JOIN AQKATEGORI R2 ON A.KATEGORI=R2.KOD
                             LEFT  JOIN AQGRUP     R3 ON A.GRUP=R3.KOD
   UNION ALL
   
      SELECT ZGJEDHUR,
             A.KOD,A.PERSHKRIM,A.NJESI,A.DATEDOK,KODOPER = '  ',
             SEQNUM           = 0,
             A.NORMEAM,
             A.VLERABS,
             VLERAAM          = A.AMVleraCum,
             A.DATESTARTAM,
             DATETRANSAM      = CASE WHEN A.TipRow='D' OR A.SEQNUM=1                        -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                                     THEN ISNULL((SELECT MAX(B.DateTransAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),A.DateStartAM)
                                     ELSE A.DATETRANSAM
                                END,
             PERSHKRIMAM      = '',                                                         -- WHERE A.KOD=B.KOD AND B.TipRow='D'
             KOMENTAM         =           ISNULL((SELECT KOMENTAM           FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow='D'),A.KOMENTAM),
             A.AQVleraCum,
             AQVleraMbet      = CASE WHEN A.IsAMVlereMbet=1 THEN A.VLERABS ELSE A.AQVleraCum-A.AMVleraCum END,
             
             A.AMVleraCum,
             AMDateFundit     = CONVERT(VARCHAR(10),A.DateAMLast,104),                                  -- A.DateAMLast,
             A.IsAMVlereMbet,
             Menyra           = CASE WHEN ISNULL(A.IsAMVlereMbet,0)=0  THEN 'AVK' ELSE 'AVM' END,
             GjendjeAktivi    = CASE WHEN ISNULL(A.KodMbyllje,'')='SH' THEN 'Shitur' 
                                     WHEN ISNULL(A.KodMbyllje,'')='JP' THEN 'Jashte perdorimit'
                                     WHEN ISNULL(A.KodMbyllje,'')='CR' THEN 'CRegjistrim'
                                     ELSE ''
                                END,
             KATEGORI         = A.KATEGORI+' - '+R2.PERSHKRIM,  -- PERSHKRIMKTG, -- A.KATEGORI,A.GRUP,R1.KODLM,
             GRUPIM           = A.GRUP    +' - '+R3.PERSHKRIM,  -- PERSHKRIMGRP
             A.DATEEND,                                                          -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
             NRMONTHSAM       = ISNULL((SELECT SUM(B.NRMONTHSAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0),
                             -- ISNULL((SELECT B.NRMONTHSAM FROM #TempDates1 B WHERE A.KOD=B.KOD AND B.TipRow='D'),0),
             KODAF            = A.KOD +
                                CASE WHEN (@pDepKart=1  AND ISNULL(R1.DEP,'')<>'') OR (@pListKart=1 AND ISNULL(R1.LIST,'')<>'') 
                                     THEN '.'+ISNULL(R1.DEP,'') 
                                     ELSE '' 
                                END  + 
                                CASE WHEN @pListKart=1  AND ISNULL(R1.LIST,'')<>'' 
                                     THEN '.'+ISNULL(R1.LIST,'') 
                                     ELSE '' 
                                END,
             A.YMD, A.Yr, A.Mn, A.Dy,        
             NRKARTELAAM      = @NrKartelaAM, 
             TOTALAKTIV       = @VleraAktiv,
             TOTALAM          = @VleraAM,  
             TipRow,
             A.NRRENDOR,   
             SEQYEAR          = 0,
             TROW             = CAST(1 AS BIT),
             TAGNR            = CAST(0 AS BIT)
             
        FROM #TempDates1  A  INNER JOIN AQKARTELA  R1 ON A.KOD=R1.KOD
                             LEFT  JOIN AQKATEGORI R2 ON A.KATEGORI=R2.KOD
                             LEFT  JOIN AQGRUP     R3 ON A.GRUP=R3.KOD
       WHERE A.SEQNUM=1 
    ORDER BY KOD, SEQNUM;


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
                                               CASE WHEN Dy<>'0' THEN ','+Dy+' dite ' ELSE '' END,' ,',','),2,100),
             PERSHKRIMAM   = SUBSTRING(M1.Month_Name,1,10)+
                                       CASE WHEN YEAR(T.DateStartAM)<>YEAR(T.DateTransAM) THEN ' '+SUBSTRING(CAST(YEAR(T.DateStartAM) AS VARCHAR),3,2) ELSE '' END
                                       +
                                      ' - '+SUBSTRING(M2.Month_Name,1,10)+' '+SUBSTRING(CAST(YEAR(T.DateTransAM) AS VARCHAR),3,2)
        FROM #TempAmortizim T INNER JOIN #MonthNames M1 ON MONTH(T.DateStartAM)=M1.Month_Number
                              INNER JOIN #MonthNames M2 ON MONTH(T.DateTransAM)=M2.Month_Number;


         SET @sSql = '
          IF OBJECT_ID(''TEMPDB..'+@sTableTmp+''') IS NOT NULL
             DROP TABLE '+@sTableTmp+';
             
      SELECT * INTO '+@sTableTmp+' FROM #TempAmortizim ORDER BY KOD, NRRENDOR,SEQNUM; 
    
      SELECT * FROM '+@sTableTmp+' ORDER BY KOD, DATEDOK, SEQNUM;   --NRRENDOR, SEQNUM; ';    
    
       EXEC (@sSql);
    
  
        GOTO FUNDAM;    





CREATEAM:

--                  Krijimi i dokumentit AQ per amortizimin dhe kalimi i ketij ne databaze te Nd/jes

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
             A.DateTransAM,A.VLERABS+A.AQVleraCum,A.VLERAAM,A.NORMEAM,
             R1.BC,
             A.PERSHKRIMAM,
             SASI          = 1,
             CMIMBS        = A.VLERABS,
             KODOPER       = 'AM',
             KOEFSHB       = 1,
             KMON          = '',
             TIPKLL        = 'X',
             NRRENDKLLG    = R1.NRRENDOR
        FROM #TempDates1 A LEFT JOIN AQKARTELA R1 ON A.KOD=R1.KOD
       WHERE A.SEQNUM>0 AND A.TipRow<>'D'
    ORDER BY A.KOD, A.SEQNUM;



FUNDAM:
    
          IF OBJECT_ID('TEMPDB..#TempDtAM')     IS NOT NULL
             DROP TABLE #TempDtAM;
          IF OBJECT_ID('TEMPDB..#TempScr')      IS NOT NULL
             DROP TABLE #TempScr;
          IF OBJECT_ID('TEMPDB..#TempShitje')   IS NOT NULL
             DROP TABLE #TempShitje;
          IF OBJECT_ID('TEMPDB..#TempSistemim') IS NOT NULL
             DROP TABLE #TempSistemim;
          IF OBJECT_ID('TEMPDB..#TempDates')    IS NOT NULL
             DROP TABLE #TempDates;
          IF OBJECT_ID('TEMPDB..#TempDates1')   IS NOT NULL
             DROP TABLE #TempDates1;
          IF OBJECT_ID('TEMPDB..#TempDates2')   IS NOT NULL
             DROP TABLE #TempDates2;
          IF OBJECT_ID('TEMPDB..#TempDates3X')  IS NOT NULL
             DROP TABLE #TempDates3X;
          IF OBJECT_ID('TEMPDB..#TempDates3Y')  IS NOT NULL
             DROP TABLE #TempDates3Y;
          IF OBJECT_ID('TEMPDB..#TempSeri')     IS NOT NULL
             DROP TABLE #TempSeri;
          IF OBJECT_ID('TempDB..#TempSeriX')    IS NOT NULL
             DROP TABLE #TempSeriX;
          IF OBJECT_ID('TEMPDB..#MonthNames')   IS NOT NULL
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
