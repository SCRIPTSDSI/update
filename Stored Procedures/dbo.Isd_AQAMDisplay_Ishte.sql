SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE        procedure [dbo].[Isd_AQAMDisplay_Ishte]
(
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

As

     -- EXEC dbo.Isd_AQAMDisplay '31/12/2018','31/12/2018','Amortizim vjetor','Amortizim makineri','3=3','D',0,0,'ADMIN','##AA';
     
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

          IF OBJECT_ID('TEMPDB..#TempScr')     IS NOT NULL
             DROP TABLE #TempScr;
          IF OBJECT_ID('TEMPDB..#TempDtAM')    IS NOT NULL
             DROP TABLE #TempDtAM;
          IF OBJECT_ID('TEMPDB..#TempDates')   IS NOT NULL
             DROP TABLE #TempDates;
          IF OBJECT_ID('TEMPDB..#TempDates1')  IS NOT NULL
             DROP TABLE #TempDates1;
          IF OBJECT_ID('TEMPDB..#TempDates2')  IS NOT NULL
             DROP TABLE #TempDates2;
          IF OBJECT_ID('TEMPDB..#TempDates3')  IS NOT NULL
             DROP TABLE #TempDates3;
          IF OBJECT_ID('TEMPDB..#TempSeri')    IS NOT NULL
             DROP TABLE #TempSeri;
          IF OBJECT_ID('TEMPDB..#MonthNames')  IS NOT NULL
             DROP TABLE #MonthNames;

         
      SELECT *
        INTO #MonthNames
        FROM
          (         SELECT 'Janar' AS Month_Name, 1 AS Month_Number
              UNION SELECT 'Shkurt',   2
              UNION SELECT 'Mars',     3
              UNION SELECT 'Prill',    4
              UNION SELECT 'Maj',      5
              UNION SELECT 'Qershor',  6
              UNION SELECT 'Korrik',   7
              UNION SELECT 'Gusht',    8
              UNION SELECT 'Shtator',  9
              UNION SELECT 'Tetor',   10
              UNION SELECT 'Nendor',  11
              UNION SELECT 'Dhjetor', 12
             ) AS Months 
    ORDER BY Month_Name;
    
    
      SELECT NRRENDOR = CAST(0 AS BIGINT) INTO #TempScr FROM AQSCR WHERE 1=2;  
      
      SELECT KOD=KARTLLG, DateAMLast=DATEOPER, AMVleraCum=VLERAAM, AQVleraCum=VLERABS
        INTO #TempDtAM 
        FROM AQSCR 
       WHERE 1=2;  
  



-- 1.        Filtrimi i te dhenave tek tabelat AQ, AQSCR

         SET @sSql = '
                                                                     
             INSERT INTO #TempDtAM                                   -- Tabela me Kartelat dhe datat e fundit te amortizimit
                   (KOD, DateAMLast, AMVleraCum, AQVleraCum)
             SELECT B.KARTLLG,
                    DTAM       = ISNULL(MAX(CASE WHEN ISNULL(B.DATEOPER,0)=0 THEN A.DATEDOK ELSE B.DATEOPER END),0),
                    VLAMCUM    = SUM(ISNULL(B.VLERAAM,0)),
                    AQVleraCum = 0 
               FROM AQ A INNER JOIN AQSCR      B  ON A.NRRENDOR=B.NRD
                         INNER JOIN AQKARTELA  R1 ON B.KARTLLG=R1.KOD
                         INNER JOIN AQKATEGORI R2 ON R2.KOD=R1.KATEGORI
              WHERE (A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''')) AND (UPPER(ISNULL(B.KODOPER,'''')) IN (''CE'',''AM'')) AND 
                    (1=1)
           GROUP BY B.KARTLLG; 
           
                                                          
             INSERT INTO #TempScr                                    -- Tabela me Kartelat dhe veprimet qe do te amortizohen
                   (NRRENDOR)
             SELECT B.NRRENDOR
               FROM AQ A INNER JOIN AQSCR      B  ON A.NRRENDOR=B.NRD
                         INNER JOIN AQKARTELA  R1 ON B.KARTLLG=R1.KOD
                         INNER JOIN AQKATEGORI R2 ON R2.KOD=R1.KATEGORI
              WHERE A.DATEDOK<=dbo.DATEVALUE('''+@pDateEnd+''') AND (UPPER(ISNULL(B.KODOPER,'''')) IN (''CE'',''BL'',''MM'')) AND 
                   (1=1);';
          IF  @sWhere<>''          
              SET @sSql = Replace(@sSql,'1=1',@sWhere);
        EXEC (@sSql);       -- PRINT  @sSql; 


      SELECT A.*,
             DTAM = CASE WHEN ISNULL(B.DateAMLast,0)=0 
                         THEN CASE WHEN A.KODOPER IN ('CE')      THEN A.DATEDOK
                                   WHEN A.KODOPER IN ('BL','MM') THEN A.DATEDOK   -- -1 Kujdes 29.08.2018
                                   ELSE                               B.DateAMLast
                              END
                         ELSE B.DateAMLast
                    END         
        INTO #TempDates
        FROM 
          (  SELECT KOD           = B.KARTLLG,
                    B.PERSHKRIM, 
                    B.NJESI, 
                    B.KODOPER,
                    DateDok       = A.DATEDOK,
                    
                    
                    DateStart     =                                         DATEADD(m,1,CONVERT(DATETIME,'01/'+CAST(MONTH(CASE WHEN ISNULL(Dt.DateAMLast,0)=0 THEN A.DATEDOK ELSE Dt.DateAMLast END) AS VARCHAR(2))+'/'+CAST(YEAR(CASE WHEN ISNULL(Dt.DateAMLast,0)=0 THEN A.DATEDOK ELSE Dt.DateAMLast END) AS VARCHAR(4)),103)),
                    DtTrans       = DATEADD(d,-1,  DATEADD(m,  R.NRTIMEAM,  DATEADD(m,1,CONVERT(DATETIME,'01/'+CAST(MONTH(CASE WHEN ISNULL(Dt.DateAMLast,0)=0 THEN A.DATEDOK ELSE Dt.DateAMLast END) AS VARCHAR(2))+'/'+CAST(YEAR(CASE WHEN ISNULL(Dt.DateAMLast,0)=0 THEN A.DATEDOK ELSE Dt.DateAMLast END) AS VARCHAR(4)),103))  )  ), 
                 -- zevendesuar A.DATEDOK me CASE WHEN ISNULL(Dt.DateAMLast,0)=0 THEN A.DATEDOK ELSE Dt.DateAMLast END
                    
                 -- DateEnd       = @DateEnd,
                    NORMEAM       = ISNULL(R.NORMEAM,0),
                    IsAMVlereMbet = ISNULL(R.AMVLEREMBET,0),
                    VLERABS       = ISNULL(B.VLERABS,0),
                    K.KATEGORI, 
                    K.GRUP,
                    R.NRTIMEAM,
                    A.DOK_JB,
                    B.NRRENDOR 
                 -- NrOrder   = ROW_NUMBER() OVER (PARTITION BY B.KARTLLG ORDER BY B.KARTLLG) 
               FROM AQ A INNER JOIN AQSCR      B  ON A.NRRENDOR=B.NRD
                         INNER JOIN #TempScr   T  ON B.NRRENDOR=T.NRRENDOR
                         INNER JOIN AQKARTELA  K  ON B.KARTLLG =K.KOD
                         INNER JOIN AQKATEGORI R  ON R.KOD=K.KATEGORI
                         LEFT  JOIN #TempDtAM  Dt ON B.KARTLLG=Dt.KOD
              WHERE A.DATEDOK<=@DateEnd AND B.KODOPER IN ('CE','BL','MM') -- AND 1=1
             ) A  LEFT  JOIN #TempDtAM B ON A.KOD=B.KOD
       WHERE DateStart<=@DateEnd
    ORDER BY KOD,DateDok;

--     PRINT @DateEnd; SELECT * FROM #TempScr; SELECT * FROM #TempDtAM; 
      
   
   
   
-- 2.        Zberthimi ne seri data per evidentimin e amortizimit [DateStart, DateEnd]
--           Ndertimi i tabeles me date seri per amortizimin (tabela #TempSeri) e cial ndertohet me ndihmen e funksionit Isd_AQAMDateRange

      SELECT NrRendor = CAST(0 AS BIGINT), StartDate = DTAM, EndDate = DATEDOK, TRow=CAST(0 AS BIT),
             NrTimeAM 
        INTO #TempSeri 
        FROM #TempDates 
       WHERE 1=2;
       

        EXEC dbo.Isd_AQAMSeriDates '#TempDates','#TempSeri',@pDateEnd;
      


-- 3.        Tabela #TempDates1 eshte kryesore ne algoritmin per amortizimin


      SELECT Dt.*, 
             DateStartAM      = A.StartDate,
             DateTransAM      = A.EndDate,
             DateAMLast       = Dt.DTAM,
             DATEEND          = @DateEnd,

             VLERAAM          = CAST(0.0 AS FLOAT),
             VleraAMPrg       = CAST(0.0 AS FLOAT),     -- Amortizimi progresiv per periudhen e rivleresimit (amortizimit)
             AMVleraCum       = CAST(0.0 AS FLOAT),     -- Shuma e amortizimeve para pariudhes vleresuese (referuar DateAMLast)
             AQVleraCum       = CAST(0.0 AS FLOAT),     -- Shuma e vlerave te aktivit para pariudhes vleresuese (referuar DateAMLast)
             AMVleraTot       = CAST(0.0 AS FLOAT),     -- Amortizim total (progresiv te periudhes + Amortizimi i cumuluar)
             AQVleraMbet      = CAST(0.0 AS FLOAT),
             AQVleraMbetStart = CAST(0.0 AS FLOAT),     -- Vlefte e mbetur e assetit ne fillim te periudhes se rivleresimit (aset-amortizim)
             AQVleraCumStart  = CAST(0.0 AS FLOAT),     -- Vlefte e assetit deri ne fillim te periudhes se rivleresimit (Aset)
             AMVleraCumStart  = CAST(0.0 AS FLOAT),     -- Shuma e amortizimi deri ne fillim te periudhes se rivleresimit (shum amortizimit)
             VleraNEW         = CASE WHEN ROW_NUMBER() OVER (PARTITION BY A.NRRENDOR ORDER BY A.NRRENDOR,A.StartDate)=1 
                                     THEN VLERABS 
                                     ELSE 0.0 
                                END,

             PERSHKRIMAM      = Space(150),
             NrMonthsAM       = 0,
             TipRow           = ' ',
             ZGJEDHUR         = CAST(1 AS BIT),
             SeqNum           = ROW_NUMBER() OVER (PARTITION BY A.NRRENDOR,KOD ORDER BY A.NRRENDOR,KOD,A.StartDate)
          
        INTO #TempDates1     

        FROM #TempDates Dt LEFT JOIN #TempSeri A ON Dt.NRRENDOR=A.NRRENDOR 
    -- WHERE Dt.DateDok>=Dt.DTAM
    ORDER BY A.NRRENDOR,KOD,A.StartDate; 


/*
--           Nje tjeter algoritem per gjenerimin e tabeles me datat seri per amortizimin, nuk kenaq kushtin per ta hedhur kete procedure me parameter kodin a aktivit
--           Per ndonje rast te meret ideja e gjenerimit te serive ....
   
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
   --  WHERE DATEADD(m, NRTIMEAM*(Seq.SeQnum), Dt.DateStart)<=@DateEnd;
*/   
   
   
   
-- 4.        Plotesime te tabeles ne lidhje me historikun e aktivit, si psh amortizimi fundit, amortizim i kumuluar etj.

      UPDATE A
         SET DateAMLast       = B.DateAMLast,
             AMVleraCum       = B.AMVleraCum,
             AMVleraCumStart  = B.AMVleraCum,
             AQVleraMbetStart = A.VLERABS - B.AMVleraCum
        FROM #TempDates1 A INNER JOIN #TempDtAM B ON A.KOD=B.KOD;
     
      UPDATE T
         SET AQVleraCum       = ISNULL( ( SELECT SUM(B.VLERABS)
                                            FROM AQSCR B INNER JOIN AQ A ON A.NRRENDOR=B.NRD
                                           WHERE A.DATEDOK<T.DateAMLast AND B.KARTLLG=T.KOD AND B.KODOPER IN ('CE','BL','MM')
                                        GROUP BY B.KARTLLG ),0),
             AQVleraCumStart  = ISNULL( ( SELECT SUM(B.VLERABS)
                                            FROM AQSCR B INNER JOIN AQ A ON A.NRRENDOR=B.NRD
                                           WHERE A.DATEDOK<T.DateAMLast AND B.KARTLLG=T.KOD AND B.KODOPER IN ('CE','BL','MM')
                                        GROUP BY B.KARTLLG ),0),                           
             AMVleraCumStart  = ISNULL( ( SELECT SUM(B.VLERAAM)
                                            FROM AQSCR B INNER JOIN AQ A ON A.NRRENDOR=B.NRD
                                           WHERE A.DATEDOK<T.DateAMLast AND B.KARTLLG=T.KOD 
                                        GROUP BY B.KARTLLG ),0),
             AQVleraMbetStart = ISNULL( ( SELECT SUM(B.VLERABS)
                                            FROM AQSCR B INNER JOIN AQ A ON A.NRRENDOR=B.NRD
                                           WHERE A.DATEDOK<T.DateAMLast AND B.KARTLLG=T.KOD AND B.KODOPER IN ('CE','BL','MM')
                                        GROUP BY B.KARTLLG ),0) 
                                -
                                ISNULL( ( SELECT SUM(B.VLERAAM)
                                            FROM AQSCR B INNER JOIN AQ A ON A.NRRENDOR=B.NRD
                                           WHERE A.DATEDOK<T.DateAMLast AND B.KARTLLG=T.KOD 
                                        GROUP BY B.KARTLLG ),0)         
                                                                    
        FROM #TempDates1 T;
       
    SELECT * FROM #TempDates1 ORDER BY SEQNUM;RETURN;




-- 5.        Shtohet nje resht per date diference. Per kete perdoret #TempDates2 e cila ne fund i shtohet #TempDates1
--           Ky resht dallohet nga te tjeret sepse ka TipRow='D'. U shtua per te ritur lexueshmerine e informacionit ne afishim
--           Edhe ky resht edhe ai me SeqNum=0 jane per te ritur lexueshmerine e te dhenave ne afishim ne program  
--           Kujdes: Llogaritet ne muaj dhe dite diferenca e periudhes nga DateEnd-DateTransAM



      SELECT A.*
        INTO #TempDates2     
        FROM #TempDates1 A 
       WHERE A.SEQNUM = (SELECT MAX(B.SEQNUM) FROM #TempDates1 B WHERE B.KOD=A.KOD) AND A.DATETRANSAM<=A.DATEEND
    ORDER BY KOD;
    
    
      UPDATE #TempDates2
         SET DateStartAM = (SELECT MIN(DateStartAM) FROM #TempDates1 WHERE #TempDates1.KOD=#TempDates2.KOD),
             DateTransAM = DateEnd,
             SeqNum      = SeqNum + 1, 
             TipRow      = 'D'                    -- Resht Diference
             
      INSERT   INTO  #TempDates1     
      SELECT * FROM  #TempDates2 A;

      DROP     TABLE #TempDates2;
            
--    SELECT * From  #TempDates1; RETURN;
            
/*    UPDATE #TempDates2
         SET YMD         = dbo.Isd_DaysMonthsYears(CONVERT(VARCHAR, DateStartAM,103), CONVERT(VARCHAR, DateTransAM +1 , 103),1)
          -- YMD = dbo.Isd_GetDatesDifference('','',A.DateTransAM,A.DateEnd)--,' ',''),',','')
             
      UPDATE #TempDates2
         SET Yr          = CAST(SUBSTRING(YMD,2,CHARINDEX('M',YMD)-2)    AS INT),
             Mn          = CAST(SUBSTRING(YMD,  CHARINDEX('M',YMD)+1,  CHARINDEX('D',YMD)-CHARINDEX('M',YMD)-1) AS INT),
             Dy          = CAST(SUBSTRING(YMD,  CHARINDEX('D',YMD)+1, 2) AS INT);
             
     
      UPDATE #TempDates2
         SET VLERAAM     = ROUND((Yr*(VLERABS+AQVleraCum)*NORMEAM)/   100, 2)+
                           ROUND((Mn*(VLERABS+AQVleraCum)*NORMEAM)/  1200, 2)+
                           ROUND((Dy*(VLERABS+AQVleraCum)*NORMEAM)/ 36500, 2),
             PERSHKRIMAM = CASE WHEN Yr=0 THEN '' ELSE CAST(Yr AS VARCHAR)+CASE WHEN Yr=1 Then ' Vit,' ELSE ' Vjet,' END END +
                           CASE WHEN Mn=0 THEN '' ELSE CAST(Mn AS VARCHAR)+' Muaj,' END +
                           CASE WHEN Dy=0 THEN '' ELSE CAST(Dy AS VARCHAR)+' Dite'  END;

       ALTER TABLE  #TempDates2 DROP COLUMN YMD;
       ALTER TABLE  #TempDates2 DROP COLUMN Yr;
       ALTER TABLE  #TempDates2 DROP COLUMN Mn;
       ALTER TABLE  #TempDates2 DROP COLUMN Dy;

      INSERT   INTO #TempDates1     
      SELECT * FROM #TempDates2 A;

      DROP     TABLE #TempDates2;
*/

-- Fund zberthimi

    


-- 6.        Llogaritja e fushave dhe elementeve per amortizimin

      UPDATE #TempDates1 
         SET NrMonthsAM = DATEDIFF(m,DateStartAM,DateTransAM)+1;
         
         
         
      -- 6.1 Metoda e amortizimit konstant (sipas normes se amortizimit):



      UPDATE T
         SET PERSHKRIMAM   = CASE WHEN T.TipRow='D'
                                  THEN PERSHKRIMAM
                                  ELSE SUBSTRING(M1.Month_Name,1,3)+' - '+SUBSTRING(M2.Month_Name,1,3)+' '+SUBSTRING(CAST(YEAR(T.DateStartAM) AS VARCHAR),1,4)
                             END,
             NrMonthsAM    = A.NrMonthsAM,
             VLERAAM       = CASE WHEN T.TipRow='D'                 THEN VLERAAM                              
                                  WHEN ISNULL(A.NrMonthsAM,0)=0     THEN 0 
                                  ELSE                                   ROUND((A.NrMonthsAM*( T.VLERABS + T.AQVleraCum) * T.NORMEAM)/1200, 2) -- Konstante
                             END
        FROM 
           (
             SELECT KOD,SeqNum, NrMonthsAM=DATEDIFF(m,DateStartAM,DateTransAM)+1
               FROM #TempDates1 
              WHERE ISNULL(IsAMVlereMbet,0)=0 
              ) A  
                   INNER JOIN #TempDates1 T  ON A.KOD=T.KOD AND A.SeqNum=T.SeqNum
                   INNER JOIN #MonthNames M1 ON MONTH(T.DateStartAM)=M1.Month_Number
                   INNER JOIN #MonthNames M2 ON MONTH(T.DateTransAM)=M2.Month_Number;



 
      -- 6.2 Metoda amortizim me vleften e mbetur, kujdes te filtrohet sipas natyres se kategorise. 

      UPDATE #TempDates1 
         SET NrMonthsAM = CASE WHEN TipRow='D' THEN NrMonthsAM ELSE DATEDIFF(m,DateStartAM,DateTransAM)+1 END
       WHERE ISNULL(IsAMVlereMbet,0)=1; 





-- 7.        KOMENTE TE NEVOJESHME PER PERIUDHAT E AMORTIZIMIT
            
--           Shpjegim:  DATEPART (dd, DATEADD(dd, DATEPART(dd, DATEADD(mm, 1, T.DateStartAM)) * -1, DATEADD(mm, 1, @day)))   -- Nr i diteve te muajit
--                     (DATEDIFF(dd,T.DateStartAM,T.DateTransAM)+1)                                                          -- Diference dite

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


--           STATISTIKA PER PERIUDHAT (PER ELEMENTE SQARUES NE ALGORITMIN E AMORTIZIMIT)
         
                     
       ALTER TABLE  #TempDates1 ADD  YMD       Varchar(100) NULL;
       ALTER TABLE  #TempDates1 ADD  Yr        Varchar(20)  NULL;
       ALTER TABLE  #TempDates1 ADD  Mn        Varchar(20)  NULL;
       ALTER TABLE  #TempDates1 ADD  Dy        Varchar(20)  NULL;   
       ALTER TABLE  #TempDates1 ADD  KomentAM  Varchar(100) NULL;   
       
      --UPDATE #TempDates1 
      --   SET Yr  = '0', Mn = '0', Dy = '0',
      --       YMD = dbo.Isd_DaysMonthsYears(CONVERT(VARCHAR, DateStartAM,103), CONVERT(VARCHAR, DateTransAM +1 , 103),1);
              
      --UPDATE #TempDates1 
      --   SET Yr  = CASE WHEN CHARINDEX('y',YMD)>0 AND CHARINDEX('m',YMD)>0
      --                       THEN SUBSTRING(YMD,CHARINDEX('y',YMD)+1,CHARINDEX('m',YMD)-CHARINDEX('y',YMD)-1) 
      --                  WHEN CHARINDEX('y',YMD)>0 AND CHARINDEX('d',YMD)>0     
      --                       THEN SUBSTRING(YMD,CHARINDEX('y',YMD)+1,CHARINDEX('d',YMD)-CHARINDEX('y',YMD)-1)
      --                  WHEN CHARINDEX('y',YMD)>0                             
      --                       THEN SUBSTRING(YMD,CHARINDEX('y',YMD)+1,LEN(YMD))
      --                  ELSE '0' 
      --             END, 
      --       Mn  = CASE WHEN CHARINDEX('m',YMD)>0 AND CHARINDEX('d',YMD)>0 
      --                       THEN SUBSTRING(YMD,CHARINDEX('m',YMD)+1,CHARINDEX('d',YMD)-CHARINDEX('m',YMD)-1) 
      --                  WHEN CHARINDEX('m',YMD)>0                               
      --                       THEN SUBSTRING(YMD,CHARINDEX('m',YMD)+1,LEN(YMD))
      --                  ELSE '0' 
      --             END, 
      --       Dy  = CASE WHEN CHARINDEX('d',YMD)>0 
      --                       THEN SUBSTRING(YMD,CHARINDEX('d',YMD)+1,LEN(YMD))
      --                   ELSE '0'     
      --              END
      --  FROM #TempDates1;
        
      --UPDATE #TempDates1
      --   SET KOMENTAM = SUBSTRING(REPLACE(CASE WHEN Yr<>'0' THEN ','+Yr+CASE WHEN Yr=1 THEN ' vit ' ELSE ' vjet ' END ELSE '' END +
      --                                    CASE WHEN Mn<>'0' THEN ','+Mn+' muaj ' ELSE '' END +
      --                                    CASE WHEN Dy<>'0' THEN ','+Dy+' dite ' ELSE '' END,' ,',','),2,100);






-- 8.        Mbushja e fushave progresive sipas amortizimit
--           Leximi i te dhenave nga #TempDates1 mbush tabelen #TempDates3
   
;WITH  SumAm
        AS ( 
             SELECT t.Kod, 
                    t.VLERABS, 
                    VLERAAM     =                            ROUND((t.NrMonthsAM * (t.VLERABS + t.AQVleraCum) * t.NORMEAM)/1200.0, 2),
                    AQVleraMbet = t.VLERABS - t.AQVleraCum - ROUND((t.NrMonthsAM * (t.VLERABS + t.AQVleraCum) * t.NORMEAM)/1200.0, 2),
                    t.SeqNum,
                    t.NrRendor
               FROM #TempDates1 t
              WHERE SeqNum = 1 AND ISNULL(IsAMVlereMbet,0)=1 
              
          UNION ALL

             SELECT t.KOD, 
                    VLERABS     = A.AQVleraMbet, 
                    VLERAAM     = ROUND(                          (t.NrMonthsAM*ISNULL(A.AQVleraMbet,0)*t.NORMEAM/1200.0), 2),  
                    AQVleraMbet = ROUND(ISNULL(A.AQVleraMbet,0) - (t.NrMonthsAM*ISNULL(A.AQVleraMbet,0)*t.NORMEAM/1200.0) ,2),       
                    t.SeqNum,
                    t.NrRendor              -- ON A.KOD=t.KOD AND A.SeqNum = t.SeqNum - 1
               FROM #TempDates1 t JOIN SumAm A ON A.NRRENDOR=T.NRRENDOR AND A.SeqNum=t.SeqNum - 1
              WHERE ISNULL(IsAMVlereMbet,0)=1 AND TipRow<>'D'
              
           )
           
             SELECT * INTO #TempDates3 FROM    SumAm
             
OPTION  ( MAXRECURSION 1000 );

--SELECT * FROM #TempDates1 ORDER BY KOD,SEQNUM; SELECT * FROM #TempDates3 ORDER BY KOD,SEQNUM; RETURN;


--           KUJDES:       RASTI I AMORTIZIMIT ME VLERE TE MBETUR

      UPDATE A
         SET A.VLERAAM     = B.VLERAAM, 
             A.AQVleraMbet = B.AQVleraMbet       -- ON A.KOD=B.KOD AND A.SeqNum=B.SeqNum
        FROM #TempDates1 A INNER JOIN #TempDates3 B ON A.NRRENDOR=B.NRRENDOR AND A.SeqNum=B.SeqNum
       WHERE ISNULL(A.IsAMVlereMbet,0)=1;
 



      UPDATE A
         SET VleraAMPrg    = ISNULL(( SELECT ROUND(SUM(ISNULL(B.VLERAAM,0)),2) 
                                        FROM #TempDates1 B 
                                       WHERE A.NRRENDOR=B.NRRENDOR AND B.SEQNUM<=A.SEQNUM ),0),  -- WHERE A.KOD=B.KOD AND B.SEQNUM<=A.SEQNUM
             AMVleraTot    = AMVleraCum +
                             ISNULL(( SELECT ROUND(SUM(ISNULL(B.VLERAAM,0)),2) 
                                        FROM #TempDates1 B 
                                       WHERE A.NRRENDOR=B.NRRENDOR AND B.SEQNUM<=A.SEQNUM ),0)   -- WHERE A.KOD=B.KOD AND B.SEQNUM<=A.SEQNUM
        FROM #TempDates1 A;
        
        

           

      UPDATE A
         SET VLERAAM       = CASE WHEN (VLERABS+AQVleraCum) < (AMVleraCum + VleraAMPrg)               
                                  THEN ROUND(VLERAAM-((AMVleraCum+VleraAMPrg)-(VLERABS+AQVleraCum)),2)
                                  ELSE VLERAAM
                             END,
             AQVleraMbet   = (VLERABS+AQVleraCum) - (AMVleraCum + VleraAMPrg)
        FROM #TempDates1 A;
   

   
   
--           STATISTIKA NE RESHTIN DIFERENCE   
   
      UPDATE A                                                           -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
         SET VLERAAM       = ISNULL((SELECT SUM(VLERAAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0),
             AQVleraMbet   = (VLERABS + AQVleraCum) 
                              - 
                              AMVleraCum 
                              -                                          -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                              ISNULL((SELECT SUM(VLERAAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0)
        FROM #TempDates1 A
       WHERE TipRow='D';
   
   

--           FSHIHEN RESHTAT PER TE CILAT KA PERFUNDUAR AMORTIZIMI 
        
      DELETE FROM #TempDates1 WHERE (SeqNum>0 AND TipRow<>'D') AND VLERAAM <= 0;


   
      SELECT @VleraAM      = SUM(CASE WHEN TipRow='D' THEN 0 ELSE VLERAAM END),
             @VleraAktiv   = SUM(CASE WHEN SEQNUM=0                                  THEN   VLERABS
                                      WHEN SEQNUM=1 AND (KODOPER IN ('BL,MM,CE,SI')) THEN   VLERABS
                                      WHEN SEQNUM=1 AND (KODOPER IN ('SH','JP'))     THEN 0-VLERABS
                                      WHEN SEQNUM=1 AND (KODOPER IN ('AM','NP'))     THEN 0
                                      ELSE                                                0
                                 END),
             @NrKartelaAM  = SUM(CASE WHEN SEQNUM=1 THEN 1 ELSE 0 END) 
        FROM #TempDates1;
      

          IF @pOper<>'D'
             BEGIN
               GOTO CREATEAM; 
             END;
   
             


--           AFISHIMI  VIEW-se  PER  AMORTIZIMIN  E  AKTIVEVE         - Kur   @pOper = 'D'



      SELECT ZGJEDHUR,   
             A.KOD,A.PERSHKRIM,A.NJESI,A.DATEDOK,A.KODOPER,
             A.SEQNUM,
             A.NORMEAM,
             A.VLERABS,
             VLERAAM       = CASE WHEN A.TipRow='D'                                      -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                                  THEN ISNULL((SELECT SUM(B.VLERAAM)     FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0)
                                  ELSE A.VLERAAM
                             END,     
             A.DATESTARTAM,
             DATETRANSAM   = CASE WHEN A.TipRow='D'                                      -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                                  THEN ISNULL((SELECT MAX(B.DATETRANSAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),A.DateStartAM)
                                  ELSE A.DATETRANSAM
                             END,
             A.PERSHKRIMAM,
             KOMENTAM, 
             A.AQVleraCum,
             AQVleraMbet   = -- ROUND(A.AQVleraMbet,0),
                             CASE WHEN ROUND(CASE WHEN A.TipRow='D'                                            -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                                                  THEN A.VLERABS-ISNULL((SELECT SUM(B.VLERAAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0)
                                                  ELSE A.AQVleraMbet
                                             END,2) > 0
                                  THEN ROUND(CASE WHEN A.TipRow='D'                                            -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                                                  THEN A.VLERABS-ISNULL((SELECT SUM(B.VLERAAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0)
                                                  ELSE A.AQVleraMbet
                                             END,2)          
                                  ELSE 0          
                             END,     
          -- A.AQVleraMbet,
             A.VleraNew,
             A.AMVleraCum,
             A.IsAMVlereMbet,
             Menyra        = CASE WHEN A.TipRow='D' 
                                  THEN CASE WHEN ISNULL(A.IsAMVlereMbet,0)=0 THEN 'AVK' ELSE 'AVM' END
                                  ELSE ''
                             END,
             PERSHKRIMKTG  = A.KATEGORI+' - '+R2.PERSHKRIM,
             PERSHKRIMGRP  = A.GRUP    +' - '+R3.PERSHKRIM,
             A.DATEEND,
             NRMONTHSAM    = CASE WHEN A.TipRow='D'                                     -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                                  THEN ISNULL((SELECT SUM(B.NRMONTHSAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0)
                                  ELSE A.NRMONTHSAM
                             END, -- A.NRMONTHSAM
             KODAF         = A.KOD +
                             CASE WHEN (@pDepKart=1  AND ISNULL(R1.DEP,'')<>'') OR (@pListKart=1 AND ISNULL(R1.LIST,'')<>'') 
                                  THEN '.'+ISNULL(R1.DEP,'') 
                                  ELSE '' 
                             END   +
                             CASE WHEN @pListKart=1  AND ISNULL(R1.LIST,'')<>'' 
                                  THEN '.'+ISNULL(R1.LIST,'') 
                                  ELSE '' 
                             END,
             A.YMD, A.Yr, A.Mn, A.Dy, 
             A.KATEGORI,  A.GRUP, R1.KODLM,
             NRKARTELAAM   = @NrKartelaAM, 
             TOTALAKTIV    = @VleraAktiv,
             TOTALAM       = @VleraAM,  
             TipRow,  
             A.NRRENDOR, 
             SEQYEAR       = CASE WHEN A.TipRow='D' OR R2.NRTIMEAM=12
                                  THEN 0         -- OVER (PARTITION BY A.KOD, YEAR(A.DATETRANSAM) ORDER BY A.KOD,A.DATETRANSAM)
                                  ELSE ROW_NUMBER() OVER (PARTITION BY A.NRRENDOR, YEAR(A.DATETRANSAM) ORDER BY A.NRRENDOR,A.DATETRANSAM)
                             END,
             TROW          = CAST(0 AS BIT),
             R1.TAGNR 
             
        INTO #TempAmortizim
        
        FROM #TempDates1  A  INNER JOIN AQKARTELA  R1 ON A.KOD=R1.KOD
                             LEFT  JOIN AQKATEGORI R2 ON A.KATEGORI=R2.KOD
                             LEFT  JOIN AQGRUP     R3 ON A.GRUP=R3.KOD
   UNION ALL
   
      SELECT ZGJEDHUR,
             A.KOD,A.PERSHKRIM,A.NJESI,A.DATEDOK,KODOPER = '  ',
             SEQNUM        = 0,
             A.NORMEAM,
             A.VLERABS,--  = A.AQVleraMbet,
             VLERAAM       = A.AQVleraCum,
             A.DATESTARTAM,
             DATETRANSAM   = CASE WHEN A.TipRow='D' OR A.SEQNUM=1                        -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
                                  THEN ISNULL((SELECT MAX(B.DateTransAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),A.DateStartAM)
                                  ELSE A.DATETRANSAM
                             END,
             PERSHKRIMAM   = '',                                               -- WHERE A.KOD=B.KOD AND B.TipRow='D'
             KOMENTAM      = ISNULL((SELECT KOMENTAM           FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow='D'),A.KOMENTAM),
             A.AQVleraCum,
             AQVleraMbet   = A.VLERABS,
             A.VleraNew,
             A.AMVleraCum,
             A.IsAMVlereMbet,
             Menyra        = CASE WHEN ISNULL(A.IsAMVlereMbet,0)=0 THEN 'AVK' ELSE 'AVM' END,

             PERSHKRIMKTG  = A.KATEGORI+' - '+R2.PERSHKRIM,
             PERSHKRIMGRP  = A.GRUP    +' - '+R3.PERSHKRIM,
             A.DATEEND,                                                       -- WHERE A.KOD=B.KOD AND B.TipRow<>'D'
             NRMONTHSAM    = ISNULL((SELECT SUM(B.NRMONTHSAM) FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow<>'D'),0),
                          -- ISNULL((SELECT B.NRMONTHSAM FROM #TempDates1 B WHERE A.KOD=B.KOD AND B.TipRow='D'),0),
             KODAF         = A.KOD +
                             CASE WHEN (@pDepKart=1  AND ISNULL(R1.DEP,'')<>'') OR (@pListKart=1 AND ISNULL(R1.LIST,'')<>'') 
                                  THEN '.'+ISNULL(R1.DEP,'') 
                                  ELSE '' 
                             END  + 
                             CASE WHEN @pListKart=1  AND ISNULL(R1.LIST,'')<>'' 
                                  THEN '.'+ISNULL(R1.LIST,'') 
                                  ELSE '' 
                             END,                               -- WHERE A.KOD=B.KOD AND B.TipRow='D'
          -- YMD           = ISNULL((SELECT YMD FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow='D'),A.YMD),
          -- Yr            = ISNULL((SELECT Yr  FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow='D'),A.Yr),
          -- Mn            = ISNULL((SELECT Mn  FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow='D'),A.Mn),
          -- Dy            = ISNULL((SELECT Dy  FROM #TempDates1 B WHERE A.NRRENDOR=B.NRRENDOR AND B.TipRow='D'),A.Dy),
             A.YMD,A.Yr,A.Mn,A.Dy,        
             A.KATEGORI, A.GRUP, R1.KODLM,
             NRKARTELAAM   = @NrKartelaAM, 
             TOTALAKTIV    = @VleraAktiv,
             TOTALAM       = @VleraAM,  
             TipRow,
             A.NRRENDOR,   
             SEQYEAR       = 0,
             TROW          = CAST(1 AS BIT),
             R1.TAGNR 
             
        FROM #TempDates1  A  INNER JOIN AQKARTELA  R1 ON A.KOD=R1.KOD
                             LEFT  JOIN AQKATEGORI R2 ON A.KATEGORI=R2.KOD
                             LEFT  JOIN AQGRUP     R3 ON A.GRUP=R3.KOD
       WHERE A.SEQNUM=1 
       
    ORDER BY KOD, SEQNUM;


      UPDATE #TempAmortizim 
         SET Yr  = '0', Mn = '0', Dy = '0',
             YMD = dbo.Isd_DaysMonthsYears(CONVERT(VARCHAR, DateStartAM,103), CONVERT(VARCHAR, DateTransAM +1 , 103),1);
       
      UPDATE #TempAmortizim 
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
        FROM #TempAmortizim;
        
      UPDATE T
         SET KOMENTAM      = SUBSTRING(REPLACE(CASE WHEN Yr<>'0' THEN ','+Yr+CASE WHEN Yr=1 THEN ' vit ' ELSE ' vjet ' END ELSE '' END +
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
             
      SELECT *
        INTO '+@sTableTmp+'
        FROM #TempAmortizim
    ORDER BY KOD, NRRENDOR,SEQNUM; 
    
      SELECT *
        FROM '+@sTableTmp+'
    ORDER BY KOD, NRRENDOR, SEQNUM; ';    
    
       EXEC (@sSql);
       
  

        GOTO FUNDAM;    





CREATEAM:


--           KRIJIMI I DOKUMENTIT AQ PER AMORTIZIMIN DHE KALIMI I KETIJ NE DATABAZE TE ND/JES



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
         SET KOMENTAM      = SUBSTRING(REPLACE(CASE WHEN Yr<>'0' THEN ','+Yr+CASE WHEN Yr=1 THEN ' vit ' ELSE ' vjet ' END ELSE '' END +
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
    
    
          IF OBJECT_ID('TEMPDB..#TempDtAM')    IS NOT NULL
             DROP TABLE #TempDtAM;
          IF OBJECT_ID('TEMPDB..#TempScr')     IS NOT NULL
             DROP TABLE #TempScr;
          IF OBJECT_ID('TEMPDB..#TempDates')   IS NOT NULL
             DROP TABLE #TempDates;
          IF OBJECT_ID('TEMPDB..#TempDates1')  IS NOT NULL
             DROP TABLE #TempDates1;
          IF OBJECT_ID('TEMPDB..#TempDates2')  IS NOT NULL
             DROP TABLE #TempDates2;
          IF OBJECT_ID('TEMPDB..#TempDates3')  IS NOT NULL
             DROP TABLE #TempDates3;
          IF OBJECT_ID('TEMPDB..#TempSeri')    IS NOT NULL
             DROP TABLE #TempSeri;
          IF OBJECT_ID('TEMPDB..#MonthNames')  IS NOT NULL
             DROP TABLE #MonthNames;
                        


    
--           Shenime dhe procedura ndihmese per kolaudim .....

--      SELECT Dt.Kod, DATEADD(d, Seq.SeqNum, Dt.DateStart)           -- Dite
--        FROM #TempDates Dt LEFT OUTER JOIN
--                                        ( SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS SeqNum
--                                            FROM #TempDates
--                                           ) Seq
--                                          ON SeqNum <= DATEDIFF(d, Dt.DateStart, Dt.DateEnd);

--      SELECT Dt.Kod, DATEADD(m, Seq.SeQnum, Dt.DateStart)           -- 1 Muaj
--                                          ON SeqNum <= DATEDIFF(m, Dt.DateStart, Dt.DateEnd);

--      SELECT Dt.Kod, DATEADD(q, Seq.SeqNum, Dt.DateStart)           -- 3 Muaj
--                                          ON SeqNum <= DATEDIFF(q, Dt.DateStart, Dt.DateEnd);
              

--     SELECT DATEDOK,            -- Data e fundit e muajit pasardhes se veprimit
--            DATETRANS1=DATEADD(d,-1,  DATEADD(m,  1,  DATEADD(m,1,CONVERT(DATETIME,'01/'+CAST(MONTH(DATEDOK) AS VARCHAR(2))+'/'+CAST(YEAR(DATEDOK) AS VARCHAR(4)),103))  )  ) 
--            DATETRANS2=DATEADD(d,-1,  DATEADD(q,  1,  DATEADD(m,1,CONVERT(DATETIME,'01/'+CAST(MONTH(DATEDOK) AS VARCHAR(2))+'/'+CAST(YEAR(DATEDOK) AS VARCHAR(4)),103))  )  )   -- 3 mujore
--            DATETRANS3=DATEADD(d,-1,  DATEADD(m,  4,  DATEADD(m,1,CONVERT(DATETIME,'01/'+CAST(MONTH(DATEDOK) AS VARCHAR(2))+'/'+CAST(YEAR(DATEDOK) AS VARCHAR(4)),103))  )  )   -- 4 mujore
--            DATETRANS4=DATEADD(d,-1,  DATEADD(m,  6,  DATEADD(m,1,CONVERT(DATETIME,'01/'+CAST(MONTH(DATEDOK) AS VARCHAR(2))+'/'+CAST(YEAR(DATEDOK) AS VARCHAR(4)),103))  )  )   -- 6 mujore
--            DATETRANS5=DATEADD(d,-1 , DATEADD(yy, 1,  DATEADD(m,1,CONVERT(DATETIME,'01/'+CAST(MONTH(DATEDOK) AS VARCHAR(2))+'/'+CAST(YEAR(DATEDOK) AS VARCHAR(4)),103))  )  )  -- 1 vit
--       FROM AQ

       
     
GO
