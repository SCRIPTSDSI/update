SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- Exec dbo.Isd_GjenerimArkeFromFF '30/12/2020','A01','A','A.DATEDOK>=''2019/01/01'' AND A.DATEDOK<=''2019/01/04'' ','5817',1,'#12345678','ADMIN','1234567890'

CREATE Procedure [dbo].[Isd_GjenerimArkeFromFF]
(
  @pDateDok         Varchar(20),
  @pKodAB           Varchar(60),
  @pTipDok          Varchar(10),
  @pWhere           Varchar(Max),
  @pLlogariXhir     Varchar(30),
  @pAplikoLimitLik  Int,
  @pTableTmpLm      Varchar(40),
  @pPerdorues       Varchar(30),
  @pLgJob           Varchar(30)
 )

As

/*   DECLARE @pDateDok       Varchar(20),
             @pKodAB         Varchar(60),
             @pTipDok        Varchar(10),
             @pWhere         Varchar(Max),               
             @pTableTmpLm    Varchar(40),
             @pPerdorues     Varchar(30),
             @pLgJob         Varchar(30);
             
         SET @pKodAB       = 'A01';
         SET @pDateDok     = '12.01.2019';
         SET @pTipDok      = 'A'; 
         SET @pPerdorues   = 'ADMIN';
         SET @pWhere       = 'A.DATEDOK>=''2019/01/01'' AND A.DATEDOK<=''2019/01/04'' ';
*/             
             
     DECLARE @DateDok        DateTime,
             @KodAB          Varchar(60),
             @sTipDok        Varchar(10),     
             @sWhere         Varchar(MAX),
             @LlogariXhir    Varchar(30),
             @TableTmpLm     Varchar(30),
             @Perdorues      Varchar(30),
             @LgJob          Varchar(60),

             @sSql           Varchar(Max),
             @ListCommun     Varchar(MAX),
          -- @TagRnd         Varchar(30),
             @NrMaxMP        Int,

             @i              Int,
             @j              Int,
             @NrRendor       Int,
             @sNrRendor      Varchar(30),
             @AplikoLimitLik Int,
             @MaxVlefteLik   Float;     -- Vlefte maximale likujdimi me arke (deri 300000 lek te reja)
             
             
         SET @DateDok        = dbo.DateValue(@pDateDok);
         SET @KodAB          = @pKodAB;
         SET @sTipDok        = @pTipDok;
         SET @sWhere         = ISNULL(@pWhere,'');
         SET @LlogariXhir    = @pLlogariXhir;
         SET @TableTmpLm     = @pTableTmpLm;
         SET @Perdorues      = @pPerdorues;
         SET @LgJob          = @pLgJob;
         SET @AplikoLimitLik = ISNULL(@pAplikoLimitLik,0);
         SET @MaxVlefteLik   = 30000.00;
             
      SELECT @NrMaxMP      = MAX(NUMDOK) 
        FROM ARKA 
       WHERE KodAB=@KodAB AND YEAR(DateDok)=YEAR(@DateDok) AND TIPDOK='MP';
       
         SET @NrMaxMP      = ISNULL(@NrMaxMP,0);
--    SELECT @TagRnd       = dbo.Isd_RandomNumberChars(dbo.Isd_RandomNumber());
             

          IF OBJECT_ID('Tempdb..#TmpAB')         IS NOT NULL
             DROP TABLE #TmpAB;
          IF OBJECT_ID('Tempdb..#TmpABScr')      IS NOT NULL
             DROP TABLE #TmpABScr;
          IF OBJECT_ID('Tempdb..#TmpABId')       IS NOT NULL
             DROP TABLE #TmpABId;
          IF OBJECT_ID('Tempdb..#TmpNrDok')      IS NOT NULL
             DROP TABLE #TmpNrDok;
             
      SELECT NRRENDOR=0 INTO #TmpABId   FROM ARKA    WHERE 1=2;
      SELECT *          INTO #TmpAB     FROM ARKA    WHERE 1=2;
      SELECT *          INTO #TmpABScr  FROM ARKASCR WHERE 1=2; 
      
      

--          **** NDERTIMI I DOKUMENTAVE NE STRUKTURE TEMPORARE ****
      
--           A. Gjenerimi i dokumentave per pagese     
      
         SET @sSql = '
      INSERT INTO #TmpABId
            (NRRENDOR)    
      SELECT A.NrRendor
        FROM FF A 
       WHERE 1=1 AND ISNULL(A.JOBCREATE,'''')=''GRM'' AND
--           ISNULL(A.KMON,'''')='''' AND 
            (NOT EXISTS(SELECT * FROM DFU B WHERE B.KOD=A.KOD AND B.NRFAT=A.NRDSHOQ AND B.DTFAT=A.DTDSHOQ AND B.TREGDK=''D''))
    ORDER BY A.KodFKL, A.DateDok; ';

          IF @sWhere<>''
             SET @sSql = REPLACE(@sSql,'1=1',@sWhere);  
        
        EXEC (@sSql);
        
        


--           A1. Gjenerimi i tabeles me detyrimet per furnitoret qe do shlyen 

      INSERT INTO #TmpABScr
            (LlogariPK, Pershkrim, TipRef, DateDokREF, NrDokREF, DB, KR, DBKRMV, TregDK, KMon, Kurs1, Kurs2, TipKLL, OrderScr)
           
      SELECT LlogariPK   = A.KodFKL, 
             B.Pershkrim, 
             TipRef      = 'FF',
             A.DtDShoq,
             A.NrDShoq, 
             Db          = ROUND(ISNULL(A.VlerTot,0),2), 
             Kr          = 0,
             DbKrMv      = ROUND(ISNULL(A.VlerTot,0),2),
             TregDk      = 'D',
             KMon        = ISNULL(A.KMon,''),
             Kurs1       = A.Kurs1,
             Kurs2       = A.Kurs2,
             TipKll      = 'F',
             OrderScr    = ROW_NUMBER() OVER(PARTITION BY A.KodFKL ORDER BY A.DateDok)
        FROM FF A INNER JOIN #TmpABId T ON A.NrRendor=T.NrRendor
                  INNER JOIN Furnitor B ON A.KodFKL=B.Kod             -- And IsNull(B.Sasi01_Pr,0)<>0 And A.DATEDOK=@DateDok  -- NrD=@NrD
    ORDER BY LlogariPK, A.DateDok;
    



--           KUJDES....!  Ne rast gabimi duhen pare relacionet ....
     
--           A2. Fshihen reshtat qe skane lidhje me realcionet AgjentBlerje - Furnitor ne kete tabele me detyrimet per furnitoret qe do shlyen 

      UPDATE #TmpABScr 
         SET TROW   = 1;
         
      UPDATE A
         SET A.Trow = 0
        FROM #TmpABScr A INNER JOIN AgjentBlerjeFurnitorScr B2 On A.LlogariPk=B2.KodAF  -- furnitor
                         INNER JOIN AgjentBlerjeFurnitor    B1 On B1.NrRendor=B2.NrD    -- agjent blerje
                         INNER JOIN AgjentBlerje            B3 On B3.Kod=B1.Kod         -- kod arke
                         INNER JOIN ARKAT                   R1 On R1.Kod=B3.KodArke   
                         
      DELETE FROM #TmpABScr WHERE TROW=1;
                            
 
 
 
--           A3. Krijimi i rreshtave te pare ne detaje (RRAB='K') per llogari arke/banke

      INSERT INTO #TmpABScr
            (LlogariPK, Llogari, Pershkrim, DB, KR, DBKRMV, TregDK, KMon, Kurs1, Kurs2, TipKLL, OrderScr)

      SELECT LlogariPK,    
             Llogari     = MAX(R1.Llogari),
             Pershkrim   = MAX(R1.Pershkrim),
             Db          = 0, 
             Kr          =   ROUND(SUM(ISNULL(A.Db,0)),2),
             DbKrMv      = 0-ROUND(SUM(ISNULL(A.Db,0)),2),
             TregDk      = 'K',
             KMon        = MAX(A.KMON),
             Kurs1       = MAX(A.KURS1),
             Kurs2       = MAX(A.KURS2),
             TipKll      = 'T',
             OrderScr    = 0
        FROM #TmpABScr A, ARKAT R1 WHERE R1.KOD=@KodAB
    GROUP BY LlogariPK    
    ORDER BY LlogariPK;

      UPDATE A
         SET KODAF       = CASE WHEN TIPKLL='F' THEN LlogariPK ELSE Llogari END,
             KOD         = CASE WHEN TIPKLL='F' THEN LlogariPK ELSE Llogari END+CASE WHEN TIPKLL='F' THEN '.' ELSE '....' END + KMon,
             Llogari     = CASE WHEN TIPKLL='F' THEN LlogariPK ELSE Llogari END,
             Koment      = 'Shlyerje fatura',
             RRAB        = CASE WHEN TIPKLL='F' THEN '' ELSE 'K' END,
             NRDITAR     = 0
        FROM #TmpABScr A; 

 

--           A4. Krijimi i dokumentave pagese arke (deri kete moment kane NJE KOD ARKE NGA GJENEROHEN...)

       ALTER TABLE #TmpAB ADD KODFU VARCHAR(30) NULL

      INSERT INTO #TmpAB
            (KodAB, Llogari, KodFu,TipDok, DateDok, NumDok, FraksDok, Vlera, VleraMV, KMon, Kurs1, Kurs2, Shenim1, USI, USM,DateCreate,DateEdit)
                 
      SELECT KodAB       = @KodAB,  
             LlogariPK, 
             KodFu       = A.LlogariPK,
             TipDok      = 'MP', 
             DateDok     = @DateDok,              
             NumDok      = @NrMaxMP + Row_Number() OVER(ORDER BY LlogariPK),  -- MAX(ISNULL(B.NrMaxMp,0)) + Row_Number() OVER(ORDER BY LlogariPK),
             FraksDok    = 0,                                                 -- @NrMaxMP + Row_Number() OVER(ORDER BY LlogariPK),
             Vlera       = ROUND(SUM(A.DB),2), 
             VleraMV     = ROUND(SUM(A.DBKRMV),2),
             KMon        = '',     
             Kurs1       = 1, 
             Kurs2       = 1, 
             Shenim1     = 'Likujdim fatura '+MAX(ISNULL(A.PERSHKRIM,'')), 
             USI         = @Perdorues, 
             USM         = @Perdorues,
             DateCreate  = GetDate(),
             DateEdit    = GetDate()
        FROM #TmpABScr A 
       WHERE A.TREGDK='D' 
    GROUP BY LlogariPK
    ORDER BY LlogariPK;             
    
    
      UPDATE A        
         SET NRD         = B.NRRENDOR,
             LlogariPK   = A.Llogari,
             TAGNR       = B.NRRENDOR
        FROM #TmpABScr A INNER JOIN #TmpAB B ON A.LlogariPK=B.Llogari; 
   
      UPDATE A
         SET NRDITAR     = 0,
             NRDFK       = 0,
             LLOGARI     = B.Llogari,
             NrRendorAB  = B.NrRendor,
             TAGNR       = A.NRRENDOR
          -- TAGRND      = @TagRND
        FROM #TmpAB A, ARKAT B WHERE KOD=@KodAB;     
        



--           A5. Fshirja e dokumentave pagese per vleften > @MaxVlefteLik (30000 Lek) vetem per rastin Autofature

--           (Kjo procedure mbase duhet vetem per faturat me Nipt). Te pyetet ........)




          IF ISNULL(@AplikoLimitLik,0)=0            -- Per autofaturat (me Nipt) ka limit pagesa
             BEGIN
               DELETE B
                 FROM #TmpABScr B INNER JOIN #TmpAB A ON B.NRD=A.NRRENDOR
                WHERE A.VLERA>=@MaxVlefteLik;

               DELETE A
                 FROM #TmpAB    A 
                WHERE A.VLERA>=@MaxVlefteLik;
             END;
             
          IF OBJECT_ID('Tempdb..#TmpDelete') IS NOT NULL
             DROP TABLE #TmpDelete;
             
           
     
-- Deri ketu dokumentat krijohen ne rregull, POR VETEM SE DALIN NGA NJE ARKE.

-- Procedura u ndryshua me vone dhe pagesat do behen nga Arkat Agjente....

 




--           B.   Ndryshimi i dokumentave pagese sipas arkave te agjenteve

--           B.1. Ndryshim kod arke te dokumentave

      UPDATE A
         SET A.KodAB     = B3.KodArke,
             A.Llogari   = R1.Llogari,
             NrRendorAB  = R1.NrRendor
        FROM #TmpAB A LEFT JOIN AgjentBlerjeFurnitorScr B2 On A.KodFu=B2.KodAF      -- furnitor
                      LEFT JOIN AgjentBlerjeFurnitor    B1 On B1.NrRendor=B2.NrD    -- agjent blerje
                      LEFT JOIN AgjentBlerje            B3 On B1.Kod=B3.Kod         -- kod arke
                      LEFT JOIN ARKAT                   R1 On B3.KodArke=R1.Kod     -- arka
                      
                      
--           B.2. Gjenerimi i tabeles #TMPNrDok me numurat te radhes per arketime/pagesa sipas arkave

/*    SELECT KodArke     = A.KODAB, 
             LlogariAB   = MAX(ISNULL(B.LLOGARI,'')),   
             Viti        = YEAR(A.DATEDOK), 
             NrMaxMa     = MAX(CASE WHEN A.TIPDOK='MA' THEN A.NUMDOK ELSE 0 END), 
             NrMaxMp     = MAX(CASE WHEN A.TIPDOK='MP' THEN A.NUMDOK ELSE 0 END) 
        INTO #TmpNrDok     
        FROM ARKA A LEFT JOIN ARKAT B ON A.KodAB=B.Kod
    GROUP BY A.KODAB,YEAR(A.DATEDOK) 
    ORDER BY A.KODAB,YEAR(A.DATEDOK);

      INSERT INTO #TmpNrDok
            (KodArke,LlogariAB,Viti,NrMaxMa,NrMaxMp)
      SELECT KodArke=A.KOD, A.Llogari, Viti=0, NrMaxMa=0, NrMaxMp=0 
        FROM ARKAT A
       WHERE NOT EXISTS (SELECT KodArke From #TmpNrDok B WHERE B.KodArke=A.Kod) 
    ORDER BY A.Kod;

    

--           B.3. Ndryshim Nr te dokumentave arkes sipas arkave te agjenteve 

      UPDATE A
         SET NUMDOK = ISNULL(NrMaxMP,0) + ISNULL(B.Nr,0) 
        FROM #TmpAB A INNER JOIN #TmpNrDok T ON A.KodAB=T.KodArke
                      LEFT  JOIN 
                                ( 
                                   SELECT NrRendor, Nr = Row_Number() OVER(PARTITION BY KodAB ORDER BY KodAB,KodFu) FROM #TmpAB 
                                  ) B  ON A.NrRendor=B.NrRendor




--           C. Dokumentat MP nga arka qender per tek arkat agjent dhe me poshte (pika D.) dokumentat MA tek arkat agjent nga arka qender

--           C.1 Gjenerim MP nga Arka qendrore per arkat Agjente

      INSERT INTO #TmpAB
            (KodAB, NrRendorAB,Llogari, KodFu,TipDok, DateDok, NumDok, FraksDok, Vlera, VleraMV, KMon, Kurs1, Kurs2, Shenim1, USI, USM,DateCreate,DateEdit,TagRnd)
                 
      SELECT KodAB       = @KodAB,  
             NrRendorAB  = MAX(R1.NRRENDOR),
             Llogari     = MAX(R1.Llogari), 
             KodFu       = A.KodAB,  -- Kujdes. Duhet me poshte
             TipDok      = 'MP', 
             DateDok     = @DateDok,              
             NumDok      = @NrMaxMP + Row_Number() OVER(ORDER BY KodAB),  
             FraksDok    = 0,                                             
             Vlera       = ROUND(SUM(A.VLERA),2), 
             VleraMV     = ROUND(SUM(A.VLERAMV),2),
             KMon        = '',     
             Kurs1       = 1, 
             Kurs2       = 1, 
             Shenim1     = 'MP likujdim fatura '+MAX(ISNULL(R1.PERSHKRIM,'')),
             USI         = @Perdorues, 
             USM         = @Perdorues,
             DateCreate  = GetDate(),
             DateEdit    = GetDate(),
             TagRnd      = 1000
        FROM #TmpAB A INNER JOIN ARKAT R1 ON A.KODAB=R1.KOD
    GROUP BY KodAB 
    ORDER BY KodAB;  
    
    
--           C.2 Gjenerim i rreshtave te pare ne Scr per keto dokumenta MP 

      INSERT INTO #TmpABScr
            (NRD, LlogariPK, Llogari, Pershkrim, DB, KR, DBKRMV, TregDK, KMon, Kurs1, Kurs2, TipKLL, RRAB,OrderScr)

      SELECT NRD         = A.NrRendor,
             LlogariPK   = R1.Llogari, 
             Llogari     = R1.Llogari,
             Pershkrim   = R2.Pershkrim,
             Db          = 0, 
             Kr          =   ROUND(ISNULL(A.VLERA,0),2),
             DbKrMv      = 0-ROUND(ISNULL(A.VLERAMV,0),2),
             TregDk      = 'K',
             KMon        = A.KMon,
             Kurs1       = A.Kurs1,
             Kurs2       = A.Kurs2,
             TipKll      = 'T',
             RRAB        = 'K',
             OrderScr    = 0
        FROM #TmpAB A INNER JOIN ARKAT   R1 ON R1.Kod=A.KodAB
                      INNER JOIN LLOGARI R2 ON R2.Kod=R1.Llogari
       WHERE A.TagRnd=1000
    ORDER BY A.KodAB;


--           C.3 Gjenerim i rreshtave te Scr me llogarine kunderparti (llogarine xhiruese) per keto dokumenta MP

      INSERT INTO #TmpABScr
            (NRD, LlogariPK, Llogari, Pershkrim, DB, KR, DBKRMV, TregDK, KMon, Kurs1, Kurs2, TipKLL, RRAB,OrderScr)

      SELECT NRD         = A.NrRendor,
             LlogariPK   = @LlogariXhir, 
             Llogari     = @LlogariXhir,  
             Pershkrim   = (SELECT R2.PERSHKRIM FROM LLOGARI R2 WHERE R2.KOD=@pLlogariXhir),
             Db          = ROUND(ISNULL(A.VLERA,0),2), 
             Kr          = 0,
             DbKrMv      = ROUND(ISNULL(A.VLERAMV,0),2),
             TregDk      = 'D',
             KMon        = A.KMon,
             Kurs1       = A.Kurs1,
             Kurs2       = A.Kurs2,
             TipKll      = 'T',
             RRAB        = '',
             OrderScr    = 1
        FROM #TmpAB A 
       WHERE ISNULL(A.TagRnd,0)=1000
    ORDER BY KodAB;

         
         
--           D. Gjenerimi i dokumentave MA tek arkat agjent qe vijne nga nga arka qender 

--           D.1 Gjenerimi i dokumentave MA tek arkat Agjente
    
      INSERT INTO #TmpAB
            (KodAB, NrRendorAB,Llogari, KodFu,TipDok, DateDok, NumDok, FraksDok, Vlera, VleraMV, KMon, Kurs1, Kurs2, Shenim1, JobCreate,USI, USM,DateCreate,DateEdit,TagRnd)
                 
      SELECT KodAB       = A.KodFu,  
             NrRendorAB  = R1.NRRENDOR,
             Llogari     = R1.Llogari, 
             KodFu,
             TipDok      = 'MA', 
             DateDok     = A.DATEDOK,              
             NumDok      = IsNull(T.NrMaxMa,0) + Row_Number() OVER(ORDER BY KodFu), 
             FraksDok    = 0,                                                       
             Vlera       = ROUND(A.VLERA,2), 
             VleraMV     = ROUND(A.VLERAMV,2),
             KMon        = '',     
             Kurs1       = 1, 
             Kurs2       = 1, 
             Shenim1     = 'Arka '+ISNULL(A.KodAB,'')+' - MP nr '+CAST(CAST(A.NUMDOK AS BIGINT) AS VARCHAR(20))+', dt '+CONVERT(VARCHAR(20),A.DATEDOK,104),
             JobCreate   = 'GRMLIK',
             USI         = @Perdorues, 
             USM         = @Perdorues,
             DateCreate  = GetDate(),
             DateEdit    = GetDate(),
             TagRnd      = 2000
        FROM #TmpAB A INNER JOIN ARKAT     R1 ON A.KodFu=R1.KOD
                      INNER JOIN #TmpNrDok T  ON A.KodFu=T.KodArke
       WHERE ISNULL(A.TagRnd,0)=1000;  
    
    
--           D.2 Gjenerim i reshtave me llogarine e arkes konkrete tek Scr tek keto dokumenta MA tek arkat Agjente
               
      INSERT INTO #TmpABScr
            (NRD, LlogariPK, Llogari, Pershkrim, DB, KR, DBKRMV, TregDK, KMon, Kurs1, Kurs2, TipKLL, RRAB,OrderScr)

      SELECT NRD         = A.NrRendor,
             LlogariPK   = A.Llogari, 
             Llogari     = A.Llogari,
             Pershkrim   = R2.Pershkrim,
             Db          = ROUND(A.VLERA,2), 
             Kr          = 0,
             DbKrMv      = ROUND(A.VLERAMV,2),
             TregDk      = 'D',
             KMon        = A.KMon,
             Kurs1       = A.Kurs1,
             Kurs2       = A.Kurs2,
             TipKll      = 'T',
             RRAB        = 'K',
             OrderScr    = 0
        FROM #TmpAB A INNER JOIN LLOGARI R2 ON A.Llogari=R2.Kod
       WHERE A.TagRnd=2000;



--           D.3 Gjenerim i reshtave Scr me llogarine xhiruese kunderparti tek keto dokumenta MA tek arkat Agjente

      INSERT INTO #TmpABScr
            (NRD,LlogariPK, Llogari, Pershkrim, DB, KR, DBKRMV, TregDK, KMon, Kurs1, Kurs2, TipKLL, RRAB,OrderScr)

      SELECT NRD         = A.NrRendor,
             LlogariPK   = @LlogariXhir, 
             Llogari     = @LlogariXhir,  
             Pershkrim   = (SELECT R2.PERSHKRIM FROM LLOGARI R2 WHERE R2.Kod=@LlogariXhir),
             Db          = 0, 
             Kr          =   ROUND(A.VLERA,2),
             DbKrMv      = 0-ROUND(A.VLERAMV,2),
             TregDk      = 'K',
             KMon        = A.KMon,
             Kurs1       = A.Kurs1,
             Kurs2       = A.Kurs2,
             TipKll      = 'T',
             RRAB        = '',
             OrderScr    = 1
        FROM #TmpAB A
       WHERE A.TagRnd=2000;               
   
   
--           D.4 Vendosja e lidhjeve te dokumantave Mp - Ma per transferime dokumenta midis arkave 
--              (MP nga arka qendrore lidhet me MA ne arkat e agjenteve si dokumenta te lidhur me njeri tjetrin)
   
      UPDATE A
         SET LNKDOK='A', LNKNRRENDOR=B.NRRENDOR
        FROM #TmpAB A INNER JOIN #TmpAB B ON A.KodFu=B.KodAB
       WHERE A.TAGRND=1000 AND B.TAGRND=2000
      

--           E.  Modifikime te ndryshme

      UPDATE A
         SET A.LLOGARI    = R1.LLOGARI,
             A.NRRENDORAB = R1.NRRENDOR
        FROM #TmpAB A INNER JOIN ARKAT R1 ON A.KODAB=R1.KOD;

      UPDATE #TmpAB
         SET TAGNR=NRRENDOR, NRDFK=0, NRDITAR=0, TAGRND=0;
               
      UPDATE #TmpABScr
         SET LLOGARIPK    = LLOGARI,
             KODAF        = LLOGARI,
             KOD          = LLOGARI+CASE WHEN TIPKLL='T' THEN '....' ELSE '.' END+ISNULL(KMON,''),
             TAGNR        = NRD, 
             NRDITAR      = 0; 
*/        


--          **** FUND NDERTIMI I DOKUMENTAVENE STRUKTURE TEMPORARE ****


  


--           **** KALIMI I TE DHENAVE NGA STRUKTURE TEMPORARE NE TE DHENAT E ND/JES ****


--           E.1  Kalimi i #TmpAB ne ARKA

         SET @ListCommun   = dbo.Isd_ListFields2Tables('ARKA','#TmpAB','NRRENDOR,FIRSTDOK');

         SET @sSql= ' 
      INSERT INTO ARKA
            ('+@ListCommun+') 
      SELECT '+@ListCommun+'
        FROM #TmpAB 
    ORDER BY KODAB,YEAR(DATEDOK),NUMDOK;';

       EXEC (@sSql);


--           E.2  UPDATE NRD ne #TmpABScr me vlerat e ARKA te sapo krijuara

      UPDATE #TmpABScr SET NRD=0;

      UPDATE B 
         SET B.NRD = A.NRRENDOR 
        FROM ARKA A INNER JOIN #TmpAB    T ON A.TAGNR=T.TAGNR 
                    INNER JOIN #TmpABScr B ON A.TAGNR=B.TAGNR 
--     WHERE A.TagRND=@TagRnd  AND A.TAGNR<>0;  -- Kujdes @TagRnd


--           E.3  Kalimi i #TmpABScr te krijuara ne ARKAScr

         SET @ListCommun = dbo.Isd_ListFields2Tables('ARKASCR','#TMPABSCR','NRRENDOR,TAGNR,TAGRND');

         SET @sSql= ' 
      INSERT INTO ARKASCR 
            ('+@ListCommun+',TAGNR,TAGRND) 
      SELECT '+@ListCommun+',0,''''
        FROM #TmpABScr 
       WHERE NRD<>0; ';

       EXEC (@sSql);
       
     SELECT * FROM #TmpABScr Order By NRRENDOR DESC;
     

--           E.4  Zerime vlera ne ARKA per ARKA-t e shtuara

         SET @sSql = '';
      
      SELECT @sSql = @sSql + ','+CAST(CAST(A.NRRENDOR AS BIGINT) AS VARCHAR) 
        FROM ARKA A INNER JOIN #TmpAB T ON A.TAGNR=T.TAGNR 
--     WHERE TAGRND=@TagRnd 
    ORDER BY A.NRRENDOR;

      UPDATE A    
         SET A.TAGNR       = 0,
             A.FIRSTDOK    = 'A'+CAST(A.NRRENDOR AS VARCHAR)  
        FROM ARKA A INNER JOIN #TmpAB    T ON A.TAGNR=T.TAGNR     
--     WHERE TAGRND=@TagRnd AND ISNULL(TAGNR,0)<>0;



--           E.5  Ndertimi dhe plotesim i te dhenave (dokumentave dhe ditareve) te dokumentave arke te krijuara

         SET @i = 1;     
         SET @j = Len(@sSql) - Len(Replace(@sSql,',',''))+1;
         
       WHILE @i<=@j
         BEGIN
             SET @sNrRendor  = CAST([dbo].[Isd_StringInListStr](@sSql,@i,',') AS BIGINT);
             IF  @sNrRendor<>''
                 BEGIN
                   SET  @NrRendor = CAST(@sNrRendor AS BIGINT);
                   EXEC dbo.Isd_DocSaveLM 'ARKA',@NrRendor,@Perdorues,@LgJob,'M',@TableTmpLm;   
                 END;             
                 Print @NrRendor
             SET @i = @i + 1;
         END;
       


--           ***** FSHIRJE TE STRUKTURAVE TEMPORARE *****


          IF OBJECT_ID('Tempdb..#TmpAB')         IS NOT NULL
             DROP TABLE #TmpAB;
          IF OBJECT_ID('Tempdb..#TmpABScr')      IS NOT NULL
             DROP TABLE #TmpABScr;
          IF OBJECT_ID('Tempdb..#TmpABId')       IS NOT NULL
             DROP TABLE #TmpABId;
          IF OBJECT_ID('Tempdb..#TmpNrDok')      IS NOT NULL
             DROP TABLE #TmpNrDok;
GO
