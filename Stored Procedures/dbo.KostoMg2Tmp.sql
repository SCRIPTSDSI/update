SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Declare @d1 DATETIME,
--        @d2 DATETIME;
--    SET @d1 = dbo.DateValue('01/01/2014');
--    SET @d2 = dbo.DateValue('31/12/2014');
--   EXEC dbo.KostoMg2Tmp '','zzz',@d1,@d2,'A','Azzz',1,'',1,'',0,0,1,0,'##AAAAAAA','##BBBBBBB','D',''

CREATE        PROCEDURE [dbo].[KostoMg2Tmp]
(
  @pKMagKp        Varchar(30),
  @pKMagKs        Varchar(30),
  @pDateKp        DateTime,
  @pDateKs        DateTime,
  @pKodKp         Varchar(30),
  @pKodKs         Varchar(30),
  @pMgAll         Bit,
  @pMgList        Varchar(MAX),
  @pArtAll        Bit,
  @pArtList       Varchar(MAX),
  @pSipasMg       Bit,
  @pDetajuar      Bit,
  @pDeleteOld     Bit,
  @pCreateDocDIF  Bit,
  @pTableART      Varchar(50),
  @pTableDIF      Varchar(50),
  @pOper          Varchar(5),
  @pWhereExtra    Varchar(MAX)
)

AS

-- 1. Afishon artikujt qe do te rivleresohen (DataDisplay)

-- 2. Nderton tabelen temporare qe sherben per proceduren rivleresim (DataRivleresim)
--    Mbi kete tabele punohet dhe vetem ne fund postohen ne baze


         SET NOCOUNT ON

     DECLARE @KMagKp          Varchar(30),
             @KMagKs          Varchar(30),
             @DateKp          DateTime,
             @DateKs          DateTime,
             @KodKp           Varchar(30),
             @KodKs           Varchar(30),
             @MgAll           Bit,
             @Detajuar        Int,
             @DeleteOld       Bit,  -- Delete data from Old rivleresime
             @CreateDocDIF    Bit,
             @MgList          Varchar(MAX),
             @ArtAll          Bit,
             @ArtList         Varchar(MAX),
             @SipasMg         Bit,
             @TableArtikuj    Varchar(50),
             @TableDiffer     Varchar(50),
             @sDateKp         Varchar(20),
             @sDateKs         Varchar(20),
             @sSql            Varchar(MAX),
             @sWhereExtra     Varchar(MAX);


         SET @KMagKp        = @pKMagKp;
         SET @KMagKs        = @pKMagKs;
         SET @DateKp        = @pDateKp;
         SET @DateKs        = @pDateKs;
         SET @KodKp         = @pKodKp;
         SET @KodKs         = @pKodKs;
         SET @MgAll         = @pMgAll;
         SET @MgList        = @pMgList;
         SET @Detajuar      = @pDetajuar;
         SET @ArtAll        = @pArtAll;
         SET @ArtList       = @pArtList;
         SET @SipasMg       = @pSipasMg;
         SET @DeleteOld     = @pDeleteOld;
         SET @CreateDocDIF  = @pCreateDocDIF;
         SET @TableArtikuj  = @pTableART;
         SET @TableDiffer   = @pTableDIF;
         SET @sWhereExtra   = @pWhereExtra;

         SET @sDateKp       = CONVERT(VARCHAR(12),@DateKp,104);
         SET @sDateKs       = CONVERT(VARCHAR(12),@DateKs,104);
      
          IF OBJECT_ID('TempDB..#Magazina')  IS NOT NULL
             DROP TABLE #Magazina;
          IF OBJECT_ID('TempDB..#Artikuj')   IS NOT NULL
             DROP TABLE #Artikuj;
          IF OBJECT_ID('TempDB..#LevizjeHD') IS NOT NULL
             DROP TABLE #LevizjeHD;
          IF OBJECT_ID('TempDB..#KostoMg')   IS NOT NULL
             DROP TABLE #KostoMg;

       -- IF @DeleteOld=1
       --    SET @sString   = ' AND ((TIP=''H'' AND ISNULL(GJENROWRVL,0)=0) OR (TIP=''D''))';

      SELECT KOD
        INTO #Magazina
        FROM MAGAZINA
       WHERE (@MgAll =1 OR (','+@MgList +',' LIKE '%,'+KOD  +',%'))
    ORDER BY KOD;

      SELECT KOD,TIP,BC,NRRENDOR
        INTO #Artikuj
        FROM ARTIKUJ
       WHERE (@ArtAll=1 OR (','+@ArtList+',' LIKE '%,'+KOD+',%'))
    ORDER BY KOD;


   RAISERROR ('', 0, 1) WITH NOWAIT;


      SELECT *
        INTO #LevizjeHD
        FROM
    (
      SELECT A.NRRENDOR,KMAG,NRDOK, NRFRAKS, DATEDOK, DOK_JB,
             DST         = CASE WHEN ISNULL(DOK_JB,0)=0 AND DST='BL' THEN '' ELSE DST END,
             ISPRODUKT   = CASE WHEN ISNULL(DOK_JB,0)=0 AND DST='PR' AND ISNULL(GJENROWAUT,0)<>1 THEN 'Produkt'  ELSE '' END,
             ISSHKARKIM  = CASE WHEN ISNULL(DOK_JB,0)=0 AND DST='PR' AND ISNULL(GJENROWAUT,0)= 1 THEN 'Shkarkim' ELSE '' END,
             KODAF, 
             KARTLLG, 
             PERSHKRIM,
             TIP         = 'H', 
             GJENROWRVL  = CAST(ISNULL(GJENROWRVL,0) AS BIT),
             CMIMM,
             SASIH       = SASI,
             VLERAH      = VLERAM,
             SASID       = 0,
             VLERAD      = 0,
             NRRENDORFAT, 
             NRRENDORSCR = B.NRRENDOR,
             NRD,
             ISAMB       = ISNULL(B.ISAMB,0)
        FROM FH A LEFT JOIN FHSCR B ON A.NRRENDOR = B.NRD
       WHERE (A.KMAG    >= @KMagKp  And A.KMAG    <= @KMagKs) And 
             (A.DATEDOK <= @DateKs) And 
             (B.KARTLLG >= @KodKp   And B.KARTLLG <= @KodKs)  

   UNION ALL

      SELECT A.NRRENDOR,KMAG,NRDOK, NRFRAKS, DATEDOK, DOK_JB,
             DST         = CASE WHEN ISNULL(DOK_JB,0)=0 AND DST='BL' THEN '' ELSE DST END,
             ISPRODUKT   = '',
             ISSHKARKIM  = CASE WHEN ISNULL(GJENROWAUT,0)=1 THEN 'Shkarkim' ELSE '' END,
             KODAF, 
             KARTLLG, 
             PERSHKRIM,
             TIP         = 'D',
             GJENROWRVL  = CAST(ISNULL(GJENROWRVL,0) AS BIT),
             B.CMIMM,
             SASIH       = 0,
             VLERAH      = 0,
             SASID       = SASI,
             VLERAD      = VLERAM,
             NRRENDORFAT,
             NRRENDORSCR = B.NRRENDOR,
             NRD,
             ISAMB       = ISNULL(B.ISAMB,0)
        FROM FD A LEFT JOIN FDSCR B ON A.NRRENDOR = B.NRD
       WHERE (A.KMAG    >= @KMagKp  And A.KMAG    <= @KMagKs) And 
             (A.DATEDOK <= @DateKs) And 
             (B.KARTLLG >= @KodKp   And B.KARTLLG <= @KodKs)

    ) A;


          IF @sWhereExtra<>''
             BEGIN
               SET   @sSql ='
                     DELETE A
                       FROM #LevizjeHD A INNER JOIN ARTIKUJ R1 ON A.KARTLLG=R1.KOD
                                         INNER JOIN SKEMELM R2 ON R1.KODLM=R2.KOD
                      WHERE NOT (1=1); ';
               SET   @sSql = REPLACE(@sSql,'1=1',@sWhereExtra);
               PRINT @sSql;
               EXEC (@sSql);
             END;




-- Kujdes: Ne rastin kur meret kosto nd/je, atehere duhet te perjashtohen veprimet me dokumentat per te gjitah magazinat doganore 
-- Pra rasti kur @SipasMg=0 athere fshihen nga dokumentat e zgjedhura keto te dokumentave doganore ....   12.10.2018
-- 

          IF @SipasMg=0
             BEGIN
               DELETE A 
                 FROM #LevizjeHD A INNER JOIN MAGAZINA B ON A.KMAG=B.KOD WHERE ISNULL(B.ISDOGANE,0)=1
             END;
             
--fund 12.10.2018





   RAISERROR ('', 0, 1) WITH NOWAIT;


   -- CREATE INDEX Idx_Mg    ON #Magazina(KOD);
      CREATE INDEX Idx_Art   ON #Artikuj(KOD);

   RAISERROR ('', 0, 1) WITH NOWAIT

      CREATE INDEX Idx_HDMg  ON #LevizjeHD(KMAG);
      CREATE INDEX Idx_HDArt ON #LevizjeHD(KARTLLG);


   RAISERROR ('', 0, 1) WITH NOWAIT;


          IF @pOper='R'
             GOTO DataRivleresim;




  DataDisplay:


      SELECT A.*,
             HYRJESASI   = CASE WHEN A.TIP='H' THEN A.SASI   ELSE 0 END, 
             HYRJEVLERE  = CASE WHEN A.TIP='H' 
                                THEN CASE WHEN ABS(A.VLERAM)<=0.009 THEN 0 ELSE A.VLERAM END 
                                ELSE 0 
                           END,
             HYRJECMIM   = CASE WHEN A.TIP='H' THEN A.CMIMM  ELSE 0 END, 
             DALJESASI   = CASE WHEN A.TIP='D' THEN A.SASI   ELSE 0 END, 
             DALJEVLERE  = CASE WHEN A.TIP='D' 
                                THEN CASE WHEN ABS(A.VLERAM)<=0.009 THEN 0 ELSE A.VLERAM END 
                                ELSE 0 
                           END,
             DALJECMIM   = CASE WHEN A.TIP='D' THEN A.CMIMM  ELSE 0 END,
             NrOrder     = ROW_NUMBER() OVER (PARTITION BY KMAGGR, KARTLLG 
                                                  ORDER BY KMAGGR, KARTLLG, A.DTDOK, A.TIP DESC, A.DST DESC, A.NRDOK, A.NRRENDORSCR)
        INTO #KostoMg
        FROM
     (   
      SELECT NRRENDOR    = 0,
             TIP         = 'H',
             KODAF       = A.KARTLLG,
             A.KARTLLG,  
             KMAG        = MAX(CASE WHEN @SipasMg=1 THEN A.KMAG ELSE '1' END),
             KMAGGR      = MAX(CASE WHEN @SipasMg=1 THEN A.KMAG ELSE '1' END), 
             NRDOK       = 0, 
             DTDOK       = MAX(A.DATEDOK),
             NRFRAKS     = 0, 
             SASI        = ROUND(SUM(CASE WHEN   A.TIP='H' THEN A.SASIH  ELSE 0-A.SASID  END),3),
             VLERAM      = ROUND(SUM(CASE WHEN   A.TIP='H' THEN A.VLERAH ELSE 0-A.VLERAD END),3),


-- ishte perpara 05.05.2017
--
--           CMIMM       = ROUND(CASE WHEN (SUM(CASE WHEN   A.TIP='H' THEN A.SASIH  ELSE 0-A.SASID END)) 
--                                          *
--                                         (SUM(CASE WHEN   A.TIP='H' THEN A.VLERAH ELSE 0-A.VLERAD END))<=0 
--                                    THEN 0
--                                    ELSE (SUM(CASE WHEN   A.TIP='H' THEN A.VLERAH ELSE 0-A.VLERAD END)) 
--                                          / 
--                                          SUM(CASE WHEN   A.TIP='H' THEN A.SASIH  ELSE 0-A.SASID  END) 
--                               END,5), 




-- u shtua 05.05.2017
-- KORIGJUESI I CMIMIT TE MAGAZINES

-- Kujdes: 1. Rasti kur ska dokumenta magazine te para periudhes qe po rivleresohet
--         2. Dhe pervec pikes 1. te filloje me dokument qe nuk eshte asnje nga  ''CE,BL,SI''
--           (pra dokumenti i pare i periudhes eshte levizje e brendeshme ose shitje ose kthim nga shitja)

-- Ne kete rast ndertohet nga vete perdoruesi nje dokument magazine i cili percaktohet si DST=''SI'' - Sistemim
-- dhe cmimi i ketij dokumenti sherben si kosto fillestare rivleresimi.


                                            -- AND MAX(SASIH-SASID)=0 AND MAX(VLERAH-VLERAD)=0 AND CHARINDEX('',''+MAX(DST)+'','','',CE,BL,SI,'')>0

             CMIMM       = CASE WHEN COUNT(*)=1 AND CHARINDEX(','+MAX(A.DST)+',',',CE,BL,SI,')>0 
                                THEN MAX(A.CMIMM)  -- Korigjuesi i cmimit te magazines ne se duhet
                                ELSE 
                                     ROUND(CASE WHEN (SUM(CASE WHEN A.TIP='H' THEN A.SASIH  ELSE 0-A.SASID END)) 
                                                      *
                                                     (SUM(CASE WHEN A.TIP='H' THEN A.VLERAH ELSE 0-A.VLERAD END))<=0 
                                                THEN 0
                                                ELSE (SUM(CASE WHEN A.TIP='H' THEN A.VLERAH ELSE 0-A.VLERAD END)) 
                                                      / 
                                                      SUM(CASE WHEN A.TIP='H' THEN A.SASIH  ELSE 0-A.SASID  END) 
                                           END,5) 
                           END,
-- Fund 05.05.2017       

             NRD         = 0,
             FAT         = 'F',
             DST         = '  ',
             ISPRODUKT   = '',
             ISSHKARKIM  = '',
             ISAMB       = CAST(0 AS BIT),
             BC          = MAX(R2.BC),
             NRRENDORSCR = 0,
             NRRENDORFAT = MAX(A.NRRENDORFAT), 
             TIPART      = MAX(R2.TIP),
             GJENROWRVL  = CAST(0 AS BIT),
             DSTORDER    = '',
             TROW        = -1
        FROM #Magazina R1 INNER JOIN #LevizjeHD A  ON A.KMAG=R1.KOD
                          INNER JOIN #Artikuj   R2 ON A.KARTLLG=R2.KOD
       WHERE A.DATEDOK < @DateKp
    GROUP BY A.KARTLLG, CASE WHEN @SipasMg=1 THEN A.KMAG ELSE '1' END

   UNION ALL 

      SELECT A.NRRENDOR,
             A.TIP,
             A.KODAF, 
             A.KARTLLG, 
             KMAG        = CASE WHEN @SipasMg=1 THEN A.KMAG ELSE '1' END,
             KMAGGR      = CASE WHEN @SipasMg=1 THEN A.KMAG ELSE '1' END, 
             A.NRDOK, 
             A.DATEDOK, 
             A.NRFRAKS, 
             SASI        = ROUND(CASE WHEN A.TIP='H' THEN SASIH  ELSE SASID  END,3) , 
             VLERAM      = ROUND(CASE WHEN A.TIP='H' THEN VLERAH ELSE VLERAD END,3),
             CMIMM       = ROUND(A.CMIMM,5), 
             NRD, 
             FAT         = CASE WHEN A.DOK_JB=1 THEN 'F' ELSE ' ' END,
             A.DST,
             A.ISPRODUKT,
             A.ISSHKARKIM,
             ISAMB       = ISNULL(A.ISAMB,0),
             R2.BC,
             NRRENDORSCR = A.NRRENDORSCR,
             A.NRRENDORFAT, 
             TIPARTIKULL = R2.TIP,
             A.GJENROWRVL,
             DSTORDER    = CASE WHEN            CHARINDEX(','+DST+',',',BL,CD,CE,SI,')>0 
                                THEN 'zzz'+CAST(CHARINDEX(','+DST+',',',BL,CD,CE,SI,') AS VARCHAR) 
                                ELSE '999'+DST 
                           END, 
             TROW        = 0
        FROM #Magazina R1 INNER JOIN #LevizjeHD A  ON A.KMAG=R1.KOD
                          INNER JOIN #Artikuj   R2 ON A.KARTLLG=R2.KOD
       WHERE (A.DATEDOK >= @DateKp)
       
     ) A
       
    ORDER BY KMAGGR, KARTLLG, DTDOK, TIP DESC, DSTORDER DESC, NRDOK,  NRRENDORSCR;
          
   RAISERROR ('', 0, 1) WITH NOWAIT;
          
      CREATE INDEX Idx_MgKod ON #KostoMg(KMAGGR);
      CREATE INDEX Idx_MgArt ON #KostoMg(KARTLLG);          
      CREATE INDEX Idx_MgOrd ON #KostoMg(NrOrder);          
          

   RAISERROR ('', 0, 1) WITH NOWAIT;



-- SELECT * FROM #KostoMg;

      SELECT *,
             GjendjeSasi   = Gjendje_Sasi,
             GjendjeVlere  = CASE WHEN Gjendje_Sasi=0 And ABS(Gjendje_Vlere)<=0.009 THEN 0 ELSE Gjendje_Vlere END
             
        FROM
     (   
      SELECT *,
             Gjendje_Sasi  = CASE WHEN @Detajuar=1
                                  THEN ROUND(( SELECT SUM(HYRJESASI  - DALJESASI) 
                                                 FROM #KostoMg B 
                                                WHERE A.KMAGGR=B.KMAGGR And A.KARTLLG=B.KARTLLG And B.NrOrder<=A.NrOrder),3)
                                  ELSE 0 
                             END,
             Gjendje_Vlere = CASE WHEN @Detajuar=1
                                  THEN ROUND(( SELECT SUM(HYRJEVLERE - DALJEVLERE) 
                                                 FROM #KostoMg B 
                                                WHERE A.KMAGGR=B.KMAGGR And A.KARTLLG=B.KARTLLG And B.NrOrder<=A.NrOrder),3)
                                  ELSE 0 
                             END
      
        FROM #KostoMg A
       ) A 
    ORDER BY KMAGGR, KARTLLG, DTDOK, TIP DESC, DSTORDER DESC, NRDOK,  NRRENDORSCR;

   RAISERROR ('', 0, 1) WITH NOWAIT;

        
        GOTO MbylljeProcedure; 



  DataRivleresim:


      IF OBJECT_ID('TEMPDB..'+@TableArtikuj) IS NOT NULL
         EXEC ('DROP TABLE ' +@TableArtikuj);
      IF OBJECT_ID('TEMPDB..'+@TableDiffer)  IS NOT NULL
         EXEC ('DROP TABLE ' +@TableDiffer);


      SET @sSql = '
      SELECT KMAGGR, TIP,  KARTLLG, KMAG, DOK_JB, DST, TIPART, TIPPRD,GJENROWRVL,DATEDOK,      -- KODAF, 
             CMIMM,  SASI, VLERAM,
             
             CMIMMNEW    = CAST(0 AS FLOAT), 
             VLERAMNEW   = CAST(0 AS FLOAT), 
             CMIMUPDATE  = CAST(0 AS BIT),
             
             SASIFI      = CAST(0 AS FLOAT), -- Gjendjet Fillim periudhe 
             VLERAFI     = CAST(0 AS FLOAT), 
             CMIMFI      = CAST(0 AS FLOAT),
             
             NrRow       = ROW_NUMBER() OVER (ORDER BY KMAGGR, KARTLLG, DATEDOK, A.TIP DESC, DSTORDER DESC, NRDOK, A.NRRENDORSCR),
             VLERAMDIF   = CAST(0 AS FLOAT), KODLMDIF = SPACE(100), KMAGDIF = SPACE(20),
             NRRENDOR, NRD
 
        INTO '+@TableArtikuj+'
        FROM
     (
      SELECT KMAGGR      = CASE WHEN '+CAST(@SipasMg AS VARCHAR)+'=1 THEN A.KMAG ELSE ''1'' END,
             NRRENDORSCR = NRRENDORSCR, 
             NRRENDOR    = NRRENDORSCR, 
             DATEDOK,
             A.TIP, 
             KODAF, 
             KARTLLG, 
             KMAG,   
             NRDOK,
             DOK_JB,
             NRFRAKS,
             DST,
             GJENROWRVL,
             CMIMM,
             SASI        = SASIH  + SASID,
             VLERAM      = VLERAH + VLERAD,
             TIPART      = B.TIP, 
             TIPPRD      = CASE WHEN B.TIP=''P'' THEN ''P'' ELSE '''' END, 
             DSTORDER    = CASE WHEN              CHARINDEX('',''+DST+'','','',BL,CD,CE,SI,'')>0 
                                THEN ''zzz''+CAST(CHARINDEX('',''+DST+'','','',BL,CD,CE,SI,'') AS VARCHAR) 
                                ELSE ''999''+DST 
                           END, 
             NRD,
             ISAMB       = ISNULL(A.ISAMB,0)
        FROM #LevizjeHD A INNER JOIN #Artikuj B ON A.KARTLLG=B.KOD 

       WHERE A.DATEDOK>=CONVERT(DATETIME,'''+@sDateKp+''',104)

    )  A

    ORDER BY NrRow;         --KMAGGR, KARTLLG, DATEDOK, A.TIP DESC, DSTORDER DESC, NRDOK, A.NRRENDORSCR;


   RAISERROR ('''', 0, 1) WITH NOWAIT;



          IF '+CAST(@DeleteOld AS VARCHAR)+'=1
             begin

                                                                                 -- Tabela @TableDiffer ruan ID e dokumentave FH rivleresuese te mepareshme,
             -- Ruan NRD e dokumentave te fshire (Rivleresimet e mepareshme)     -- dhe fshirja behete tek dbo.KostMg3UpdDb, per keto Id tek @TableDiffer fshihen FH dhe FK koresponduese
                                                                                 -- per keto reshta te dokumentave kemi GJENROWRVL=1 ne ndertim dokumenti
               SELECT NRD
                 INTO '+@TableDiffer +' 
                 FROM '+@TableArtikuj+' 
                WHERE ISNULL(GJENROWRVL,0)=1
             GROUP BY NRD;
             
               DELETE 
                 FROM '+@TableArtikuj+' 
                WHERE ISNULL(GJENROWRVL,0)=1;

             end;



          IF OBJECT_ID(''TempDB..#TMPRIVLMG'') IS NOT NULL
             DROP TABLE #TMPRIVLMG;


      SELECT KMAGGR     = MAX(CASE WHEN '+CAST(@SipasMg AS VARCHAR)+'=1 THEN A.KMAG ELSE ''1'' END),
             KARTLLG,
             SASIFI     = ROUND(SUM(SASIH -SASID), 4), 
             VLERAFI    = ROUND(SUM(VLERAH-VLERAD),4),
             CMIMFI     = CASE WHEN ROUND(SUM(VLERAH-VLERAD)*SUM(SASIH -SASID),4)<=0 
                               THEN 0 
                               ELSE ROUND(SUM(VLERAH-VLERAD)/SUM(SASIH -SASID),4) 
                          END 
                
        INTO #TMPRIVLMG

        FROM LEVIZJEHD A
       WHERE (A.KMAG    >= '''+@KMagKp+'''  And A.KMAG    <= '''+@KMagKs+''') And 
             (A.DATEDOK <  CONVERT(DATETIME,'''+@sDateKp+''',104)) And 
             (A.KARTLLG >= '''+@KodKp +'''  And A.KARTLLG <= '''+@KodKs +''')   -- @sString
    GROUP BY KARTLLG, CASE WHEN '+CAST(@SipasMg AS VARCHAR)+'=1 THEN A.KMAG ELSE ''1'' END; 


   RAISERROR ('''', 0, 1) WITH NOWAIT;





-- Update CMIMFI me dokument sistemim Cmim per artikujt qe skane dokumenta para periudhes 
-- dhe dokumenti i pare i periudhes se rivleresimit nuk eshte asnje nga CE,BL,SI

-- ushtua 05.05.2017

      IF OBJECT_ID(''TEMPDB..#LevizjeHDCm'')  IS NOT NULL
         DROP TABLE #LevizjeHDCm;

      SELECT KARTLLG, CMIMM = MAX(CMIMM) 
        INTO #LevizjeHDCm 
        FROM #LevizjeHD 
       WHERE DATEDOK<CONVERT(DATETIME,'''+@sDateKp+''',104) AND DST=''SI'' AND SASIH=0 AND SASID=0 AND VLERAH=0 AND VLERAD=0 
    GROUP BY KARTLLG HAVING COUNT(*)=1;

      UPDATE A 
         SET A.CMIMFI = ISNULL(B.CMIMM,0) 
        FROM #TMPRIVLMG A INNER JOIN #LevizjeHDCm B ON A.KARTLLG=B.KARTLLG

      IF OBJECT_ID(''TEMPDB..#LevizjeHDCm'')  IS NOT NULL
         DROP TABLE #LevizjeHDCm;
         
-- fund shtim 05.05.2017



      UPDATE A
         SET A.SASIFI = B.SASIFI, A.VLERAFI = B.VLERAFI, A.CMIMFI = B.CMIMFI 
        FROM '+@TableArtikuj+' A INNER JOIN #TMPRIVLMG B ON A.KMAGGR=B.KMAGGR AND A.KARTLLG=B.KARTLLG;


          IF OBJECT_ID(''TempDB..#TMPRIVLMG'') IS NOT NULL
             DROP TABLE #TMPRIVLMG; 

    CREATE INDEX IX_NRROWS_ITEMS ON '+@TableArtikuj+'(NRROW); ';

--   PRINT @sSql;
     EXEC ( @sSql );
--   EXEC ('SELECT * FROM '+@TableArtikuj);


  MbylljeProcedure:


          IF OBJECT_ID('TempDB..#LevizjeHD') IS NOT NULL
             DROP TABLE #LevizjeHD;
          IF OBJECT_ID('TempDB..#Magazina')  IS NOT NULL
             DROP TABLE #Magazina;
          IF OBJECT_ID('TempDB..#Artikuj')   IS NOT NULL
             DROP TABLE #Artikuj;
          IF OBJECT_ID('TempDB..#KostoMg')   IS NOT NULL
             DROP TABLE #KostoMg;








GO
