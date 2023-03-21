SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Declare @d1 DateTime,
--        @d2 DateTime;
--    Set @d1 = dbo.DateValue('01/01/2014');
--    Set @d2 = dbo.DateValue('31/12/2014');
--   Exec dbo.KostoMG2 '','zzz',@d1,@d2,'','zzz',1,'',1,'','R',1,0,''

CREATE        PROCEDURE [dbo].[KostoMG2]
(
  @PKMagKp      Varchar(30),
  @PKMagKs      Varchar(30),
  @PDateKp      DateTime,
  @PDateKs      DateTime,
  @PKodKp       Varchar(30),
  @PKodKs       Varchar(30),
  @PMgAll       Bit,
  @PMgList      Varchar(MAX),
  @PArtAll      Bit,
  @PArtList     Varchar(MAX),
  @POper        Varchar(5),
  @PSipasMg     Bit,
  @PDetajuar    Int,

  @pWhereExtra  Varchar(MAX)
)

AS

         SET NOCOUNT ON

     DECLARE @KMagKp       Varchar(30),
             @KMagKs       Varchar(30),
             @DateKp       DateTime,
             @DateKs       DateTime,
             @KodKp        Varchar(30),
             @KodKs        Varchar(30),
             @MgAll        Bit,
             @Detajuar     Int,
             @MgList       Varchar(MAX),
             @ArtAll       Bit,
             @ArtList      Varchar(MAX),
             @WhereExtra   Varchar(MAX),
             @sSql         Varchar(MAX);


         SET @KMagKp     = @PKMagKp;
         SET @KMagKs     = @PKMagKs;
         SET @DateKp     = @PDateKp;
         SET @DateKs     = @PDateKs;
         SET @KodKp      = @PKodKp;
         SET @KodKs      = @PKodKs;
         SET @MgAll      = @PMgAll;
         SET @MgList     = @PMgList;
         SET @Detajuar   = @PDetajuar;
         SET @ArtAll     = @PArtAll;
         SET @ArtList    = @PArtList;

         SET @WhereExtra = @pWhereExtra;

      
          IF OBJECT_ID('TempDB..#Magazina')  IS NOT NULL
             DROP TABLE #Magazina;
          IF OBJECT_ID('TempDB..#Artikuj')   IS NOT NULL
             DROP TABLE #Artikuj;
          IF OBJECT_ID('TempDB..#LevizjeHD') IS NOT NULL
             DROP TABLE #LevizjeHD;
          IF OBJECT_ID('TempDB..#KostoMg')   IS NOT NULL
             DROP TABLE #KostoMg;


      SELECT KOD
        INTO #Magazina
        FROM MAGAZINA
       WHERE (@MgAll =1 Or (','+@MgList +',' LIKE '%,'+KOD  +',%'))
    ORDER BY KOD;

      SELECT KOD,TIP,BC,NRRENDOR
        INTO #Artikuj
        FROM ARTIKUJ
       WHERE (@ArtAll=1 Or (','+@ArtList+',' LIKE '%,'+KOD+',%'))
    ORDER BY KOD;


   RAISERROR ('', 0, 1) WITH NOWAIT;


      SELECT *
        INTO #LevizjeHD
        FROM
    (
      SELECT A.NRRENDOR,KMAG,NRDOK, NRFRAKS, DATEDOK, DOK_JB,DST,
             ISPRODUKT     = CASE WHEN ISNULL(DOK_JB,0)=0 AND DST='PR' AND ISNULL(GJENROWAUT,0)<>1 THEN 'Produkt'  ELSE '' END,
             ISSHKARKIM    = CASE WHEN ISNULL(DOK_JB,0)=0 AND DST='PR' AND ISNULL(GJENROWAUT,0)= 1 THEN 'Shkarkim' ELSE '' END,
             NRRENDORFAT, 
             KODAF, KARTLLG, PERSHKRIM,TIP='H',
             CMIMM,
             SASIH         = SASI,
             VLERAH        = VLERAM,
             SASID         = 0,
             VLERAD        = 0,
             NRRENDORSCR   = B.NRRENDOR,
             NRD,
             ISAMB         = ISNULL(B.ISAMB,0)
        FROM FH A LEFT JOIN FHSCR B ON A.NRRENDOR = B.NRD
       WHERE (A.KMAG    >= @KMagKp  And A.KMAG    <= @KMagKs) And 
             (A.DATEDOK <= @DateKs) And 
             (B.KARTLLG >= @KodKp   And B.KARTLLG <= @KodKs)  

   UNION ALL

      SELECT A.NRRENDOR,KMAG,NRDOK, NRFRAKS, DATEDOK, DOK_JB,DST,
             ISPRODUKT     = '',
             ISSHKARKIM    = CASE WHEN ISNULL(GJENROWAUT,0)= 1 THEN 'Shkarkim' ELSE '' END,
             NRRENDORFAT,
             KODAF, KARTLLG, PERSHKRIM,TIP='D',
             B.CMIMM,
             SASIH         = 0,
             VLERAH        = 0,
             SASID         = SASI,
             VLERAD        = VLERAM,
             NRRENDORSCR   = B.NRRENDOR,
             NRD,
             ISAMB         = ISNULL(B.ISAMB,0)
        FROM FD A LEFT JOIN FDSCR B ON A.NRRENDOR = B.NRD
       WHERE (A.KMAG    >= @KMagKp  And A.KMAG    <= @KMagKs) And 
             (A.DATEDOK <= @DateKs) And 
             (B.KARTLLG >= @KodKp   And B.KARTLLG <= @KodKs)

    ) A;


          IF @WhereExtra<>''
             BEGIN
               SET   @sSql = '  
                     DELETE A
                       FROM #LevizjeHD A INNER JOIN ARTIKUJ R1 ON A.KARTLLG=R1.KOD
                                         INNER JOIN SKEMELM R2 ON R1.KODLM=R2.KOD
                      WHERE NOT (1=1); ';
               SET   @sSql = REPLACE(@sSql,'1=1',@WhereExtra);
               PRINT @sSql;
               EXEC (@sSql);
             END;

   RAISERROR ('', 0, 1) WITH NOWAIT;


   -- Create Index Idx_Mg    On #Magazina(KOD);
      Create Index Idx_Art   On #Artikuj(KOD);

   RAISERROR ('', 0, 1) WITH NOWAIT;


      CREATE INDEX Idx_HDMg  On #LevizjeHD(KMAG);
      CREATE INDEX Idx_HDArt On #LevizjeHD(KARTLLG);

   RAISERROR ('', 0, 1) WITH NOWAIT;


          IF @POper='R'
             GOTO DataRivleresim;

--Print @POper;


  DataDisplay:


      SELECT A.*,
             HYRJESASI     = CASE WHEN A.TIP='H' THEN A.SASI   ELSE 0 END, 
             HYRJEVLERE    = CASE WHEN A.TIP='H' 
                                  THEN CASE WHEN ABS(A.VLERAM)<=0.009 THEN 0 ELSE A.VLERAM END 
                                  ELSE 0 
                             END,
             HYRJECMIM     = CASE WHEN A.TIP='H' THEN A.CMIMM  ELSE 0 END, 
             DALJESASI     = CASE WHEN A.TIP='D' THEN A.SASI   ELSE 0 END, 
             DALJEVLERE    = CASE WHEN A.TIP='D' 
                                  THEN CASE WHEN ABS(A.VLERAM)<=0.009 THEN 0 ELSE A.VLERAM END 
                                  ELSE 0 
                             END,
             DALJECMIM     = CASE WHEN A.TIP='E' THEN A.CMIMM  ELSE 0 END,
             NrOrder       = ROW_NUMBER() Over (Partition By KMAGGR, KARTLLG 
                                                    Order By KMAGGR, KARTLLG, A.DTDOK, A.TIP Desc, A.DST Desc, A.NRDOK, A.NRRENDORSCR)
        INTO #KostoMg
        FROM
     (   
      SELECT NRRENDOR      = 0,
             TIP           = 'H',
             KODAF         = A.KARTLLG,
             A.KARTLLG,  
             KMAG          = MAX(CASE WHEN @PSipasMg=1 THEN A.KMAG ELSE '1' END),
             KMAGGR        = MAX(CASE WHEN @PSipasMg=1 THEN A.KMAG ELSE '1' END), 
             NRDOK         = 0, 
             DTDOK         = MAX(A.DATEDOK),
             NRFRAKS       = 0, 
             SASI          = ROUND(SUM(CASE WHEN A.TIP='H' THEN A.SASIH  ELSE 0-A.SASID  END),3),
             VLERAM        = ROUND(SUM(CASE WHEN A.TIP='H' THEN A.VLERAH ELSE 0-A.VLERAD END),3),


     
-- KORIGJUESI I CMIMIT TE MAGAZINES      -- 05.05.2017

-- Ishte perpara 05.05.2017
--           CMIMM         = ROUND(CASE WHEN SUM(CASE WHEN   A.TIP='H' THEN A.SASIH  ELSE 0-A.SASID  END) *
--                                           SUM(CASE WHEN   A.TIP='H' THEN A.VLERAH ELSE 0-A.VLERAD END)<=0 
--                                      THEN 0
--                                      ELSE SUM(CASE WHEN   A.TIP='H' THEN A.VLERAH ELSE 0-A.VLERAD END) / 
--                                           SUM(CASE WHEN   A.TIP='H' THEN A.SASIH  ELSE 0-A.SASID  END) 
--                                 END,5), 


-- Fillim 05.05.2017

-- Kujdes: 1. Rasti kur ska dokumenta magazine te para periudhes qe po rivleresohet
--         2. Dhe pervec pikes 1. te filloje me dokument qe nuk eshte asnje nga  'CE,BL,SI'
--           (pra dokumenti i pare i periudhes eshte levizje e brendeshme ose shitje ose kthim nga shitja)

-- Ne kete rast ndertohet nga vete perdoruesi nje dokument magazine i cili percaktohet si DST='SI' - Sistemim
-- dhe cmimi i ketij dokumenti sherben si kosto fillestare rivleresimi.


                                               -- AND MAX(SASIH-SASID)=0 AND MAX(VLERAH-VLERAD)=0 AND CHARINDEX(','+MAX(DST)+',',',CE,BL,SI,')>0

             CMIMM         = CASE WHEN COUNT(*)=1 AND CHARINDEX(','+MAX(A.DST)+',',',CE,BL,SI,')>0 
                                  THEN MAX(A.CMIMM)   -- Korigjuesi i cmimit te magazines ne se duhet
                                  ELSE 
                                       ROUND(CASE WHEN SUM(CASE WHEN   A.TIP='H' THEN A.SASIH  ELSE 0-A.SASID  END) *
                                                       SUM(CASE WHEN   A.TIP='H' THEN A.VLERAH ELSE 0-A.VLERAD END)<=0 
                                                  THEN 0
                                                  ELSE SUM(CASE WHEN   A.TIP='H' THEN A.VLERAH ELSE 0-A.VLERAD END) / 
                                                       SUM(CASE WHEN   A.TIP='H' THEN A.SASIH  ELSE 0-A.SASID  END) 
                                             END,5)
                             END, 
-- Fund 05.05.2017
                           

             NRD           = 0,
             FAT           = 'F',
             DST           = '  ',
             ISPRODUKT     = '',
             ISSHKARKIM    = '',
             ISAMB         = CAST(0 AS BIT),
             BC            = MAX(R2.BC),
             NRRENDORSCR   = 0,
             NRRENDORFAT   = MAX(A.NRRENDORFAT), 
             TIPART        = MAX(R2.TIP),
             DSTORDER      = '',
             TROW          = -1
        FROM #Magazina R1 Inner Join #LevizjeHD A  On A.KMAG=R1.KOD
                          Inner Join #Artikuj   R2 On A.KARTLLG=R2.KOD
       WHERE A.DATEDOK < @DateKp
    GROUP BY A.KARTLLG, CASE WHEN @PSipasMg=1 THEN A.KMAG ELSE '1' END

   UNION ALL 

      SELECT A.NRRENDOR,
             A.TIP,
             A.KODAF, 
             A.KARTLLG, 
             KMAG          = CASE WHEN @PSipasMg=1     THEN A.KMAG ELSE '1'    END,
             KMAGGR        = CASE WHEN @PSipasMg=1     THEN A.KMAG ELSE '1'    END, 
             A.NRDOK, 
             A.DATEDOK, 
             A.NRFRAKS, 
             SASI          = ROUND(CASE WHEN A.TIP='H' THEN SASIH  ELSE SASID  END,3) , 
             VLERAM        = ROUND(CASE WHEN A.TIP='H' THEN VLERAH ELSE VLERAD END,3),
             CMIMM         = ROUND(A.CMIMM,5), 
             NRD, 
             FAT           = CASE WHEN A.DOK_JB=1      THEN 'F'    ELSE ' '    END,
             A.DST,
             A.ISPRODUKT,
             A.ISSHKARKIM,
             ISAMB         = ISNULL(A.ISAMB,0),
             R2.BC,
             NRRENDORSCR   = A.NRRENDORSCR,
             A.NRRENDORFAT, 
             TIPARTIKULL   = R2.TIP,
             DSTORDER      = CASE WHEN            CHARINDEX(','+DST+',',',SI,BL,CE,')>0 
                                  THEN 'zzz'+Cast(CHARINDEX(','+DST+',',',SI,BL,CE,') AS VARCHAR) 
                                  ELSE '999'+DST 
                             END, 
             TROW          = 0
        FROM #Magazina R1 Inner Join #LevizjeHD A  On A.KMAG=R1.KOD
                          Inner Join #Artikuj   R2 On A.KARTLLG=R2.KOD
       WHERE (A.DATEDOK >= @DateKp)
       
     ) A
       
    ORDER BY KMAGGR, KARTLLG, DTDOK, TIP Desc, DSTORDER DESC, NRDOK,  NRRENDORSCR;
          
   RaisError ('', 0, 1) With NoWait;
          
      Create Index Idx_MgKod On #KostoMg(KMAGGR);
      Create Index Idx_MgArt On #KostoMg(KARTLLG);          
      Create Index Idx_MgOrd On #KostoMg(NrOrder);          
          
   RaisError ('', 0, 1) With NoWait;


      SELECT *,
             GjendjeSasi   = Gjendje_Sasi,
             GjendjeVlere  = CASE WHEN Gjendje_Sasi=0 And ABS(Gjendje_Vlere)<=0.009
                                  THEN 0
                                  ELSE Gjendje_Vlere
                             END
             
        FROM
     (   
      SELECT *,
             Gjendje_Sasi  = CASE WHEN @Detajuar=1
                                  THEN ROUND(( Select SUM(HYRJESASI  - DALJESASI) 
                                                 From #KostoMg B 
                                                Where A.KMAGGR=B.KMAGGR And A.KARTLLG=B.KARTLLG And B.NrOrder<=A.NrOrder),3)
                                  ELSE 0 
                             END,
             Gjendje_Vlere = CASE WHEN @Detajuar=1
                                  THEN ROUND(( Select SUM(HYRJEVLERE - DALJEVLERE) 
                                                 From #KostoMg B 
                                                Where A.KMAGGR=B.KMAGGR And A.KARTLLG=B.KARTLLG And B.NrOrder<=A.NrOrder),3)
                                  ELSE 0 
                              END
      
        FROM #KostoMg A
       ) A 
    ORDER BY KMAGGR, KARTLLG, DTDOK, TIP Desc, DSTORDER DESC, NRDOK,  NRRENDORSCR;

   RaisError ('', 0, 1) With NoWait;

        
        GoTo MbylljeProcedure; 



  DataRivleresim:


      SELECT *,
             NrRow       = Row_Number() Over (Order By KMAGGR, KARTLLG, DATEDOK, A.TIP DESC, DSTORDER DESC, NRDOK, A.NRRENDORSCR) 
        FROM
     (
      SELECT KMAGGR      = CASE WHEN @PSipasMg=1 THEN A.KMAG ELSE '1' END,
             NRRENDORSCR = NRRENDORSCR, 
             NRRENDOR    = NRRENDORSCR, 
             A.TIP, 
             KODAF, 
             KARTLLG, 
             KMAG,   
             NRDOK,
             DOK_JB,
             DATEDOK,
             NRFRAKS,
             DST,
             CMIMM,
             SASI        = SASIH  + SASID,
             VLERAM      = VLERAH + VLERAD,
             TIPART      = B.TIP, 
             TIPPRD      = CASE WHEN B.TIP='P' THEN 'P' ELSE '' END, 
             DSTORDER    = CASE WHEN            CharIndex(','+DST+',',',SI,BL,CE,')>0 
                                THEN 'zzz'+Cast(CharIndex(','+DST+',',',SI,BL,CE,') As Varchar) 
                                ELSE '999'+DST END, 
             NRD,
             ISAMB       = ISNULL(ISAMB,0)
        FROM #LevizjeHD A INNER JOIN #Artikuj B ON A.KARTLLG=B.KOD 
       WHERE A.DATEDOK>=@DateKp
    )  A
    ORDER BY NrRow; --KMAGGR, KARTLLG, DATEDOK, A.TIP DESC, DSTORDER DESC, NRDOK, A.NRRENDORSCR;


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
