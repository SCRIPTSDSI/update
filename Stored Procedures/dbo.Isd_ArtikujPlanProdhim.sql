SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE        procedure [dbo].[Isd_ArtikujPlanProdhim]
(
  @pCurrDate       Varchar(20),
  @pKMagProdhim    Varchar(10),
  @pTableTmpName   Varchar(60),
  @pOper           Varchar(10),                     -- @pOper            'I' = Krijim tabela dhe display te fhena,    'D' = Display te dhena
  @pTipArtikuj     Varchar(10),                     -- @pTipArtikuj      '' = Lende e pare dhe Produkte,  'L' = Lende e pare,  'P' = Produkte
  @pSasiKonv       Varchar(10),                     -- @pSasiKonv        '' = Sasi ne njesi magazine,     'K' = Sasi ne njesi konvertuar
  @pProductActive  Int,                             -- @pProductActive   0 - Te gjithe,   1 - Jo blokuar,   2 - Blokuar,   3 - Ato nen gjendje minimale
  @pSasiMinimale   Int,                             -- @pSasiMinimale    0 - Te gjitha,   1 - Ato me Gjendje>=SasiMin,  2 - Ato me gjendje < SasiMin
  @pNrRendor       Int
)

AS   -- EXEC dbo.Isd_ArtikujPlanProdhim '16/01/2019','PG1','##TblArtikujProdhim','I','L','K',0,0,0;  -- Shtim/Krijim
     -- EXEC dbo.Isd_ArtikujPlanProdhim '16/01/2019','PG1','##TblArtikujProdhim','D','','',0,0,0;    -- Display
     -- EXEC dbo.Isd_ArtikujPlanProdhim '16/01/2019','PG1','##TblArtikujProdhim','P','','K',1,1,0;   -- Print

         SET NOCOUNT ON;
         
     DECLARE @CurrDate         DateTime,
             @DateShitje       DateTime,
             @DateFurnizim     DateTime,
             @DiteStokJavor    Varchar(20),
             @WeekDayFurn      Int,
             @KMagPrd          Varchar(10),
             @TableTmpName     Varchar(60),
             @Oper             Varchar(10),
             @TipArtikuj       Varchar(10),
             @SasiKonv         Varchar(10),
             @ProductActive    Int,
             @SasiMinimale     Int,
             @sString          Varchar(500),
             @sSql            nVarchar(MAX),
             @sFields          Varchar(MAX);

         SET @CurrDate       = dbo.DateValue(@pCurrDate);
         SET @DateShitje     = DATEADD(DAY,-6,@CurrDate);       -- Shitjet dhe furnizimi meren per diten pasardhese ....
         SET @DateFurnizim   = DATEADD(DAY,-6,@CurrDate);
         SET @WeekDayFurn    = DATEPART(dw,@DateFurnizim);
         SET @TableTmpName   = @pTableTmpName;
         SET @KMagPrd        = @pKMagProdhim;
         SET @Oper           = @pOper;
         SET @TipArtikuj     = REPLACE(ISNULL(@pTipArtikuj,''),' ','');
         SET @SasiKonv       = REPLACE(ISNULL(@pSasiKonv,'')  ,' ','');
         SET @ProductActive  = @pProductActive;
         SET @SasiMinimale   = @pSasiMinimale;
         SET @DiteStokJavor  = CASE WHEN @WeekDayFurn=2 THEN 'Hene'
                                    WHEN @WeekDayFurn=3 THEN 'Marte'
                                    WHEN @WeekDayFurn=4 THEN 'Merkure'
                                    WHEN @WeekDayFurn=5 THEN 'Enjte'
                                    WHEN @WeekDayFurn=6 THEN 'Prempte'
                                    WHEN @WeekDayFurn=7 THEN 'Shtune'
                                    WHEN @WeekDayFurn=1 THEN 'Djele'
                               END;


          IF CHARINDEX(@Oper,'D')>0 OR CHARINDEX(@Oper,'P')>0   -- Display te dhenave
             GOTO DISPLAYDATA;



          IF OBJECT_ID('TEMPDB..#ListArtikuj')         IS NOT NULL
             DROP TABLE #ListArtikuj;
          IF OBJECT_ID('TEMPDB..#TableGjendje')        IS NOT NULL
             DROP TABLE #TableGjendje;
          IF OBJECT_ID('TEMPDB..#TableShitje')         IS NOT NULL
             DROP TABLE #TableShitje;
          IF OBJECT_ID('TEMPDB..#ArtikujPlanProdhim1')  IS NOT NULL
             DROP TABLE #ArtikujPlanProdhim1;
          IF OBJECT_ID('TEMPDB..#ArtikujPlanProdhim2') IS NOT NULL
             DROP TABLE #ArtikujPlanProdhim2;
          IF OBJECT_ID('TEMPDB..#ArtikujProducts')     IS NOT NULL
             DROP TABLE #ArtikujProducts;


--           1. Tabela me Liste artikuj

      SELECT A.KOD,A.PERSHKRIM,A.NJESI,
             StokDitor   = CASE WHEN @WeekDayFurn=2 THEN ISNULL(A.GJENDJE01,0.0)
                                WHEN @WeekDayFurn=3 THEN ISNULL(A.GJENDJE02,0.0)
                                WHEN @WeekDayFurn=4 THEN ISNULL(A.GJENDJE03,0.0)
                                WHEN @WeekDayFurn=5 THEN ISNULL(A.GJENDJE04,0.0)
                                WHEN @WeekDayFurn=6 THEN ISNULL(A.GJENDJE05,0.0)
                                WHEN @WeekDayFurn=7 THEN ISNULL(A.GJENDJE06,0.0)
                                WHEN @WeekDayFurn=1 THEN ISNULL(A.GJENDJE07,0.0)
                           END,
             SasiProces  = ISNULL(B.SASI,0.0),
             SasiMin     = ISNULL(A.SASIMIN,0.0),
             NotActiv    = ISNULL(A.NOTACTIV,CAST(0 AS BIT))
        INTO #ListArtikuj      
        FROM ArtikujPlanStockJavor A FULL OUTER JOIN ArtikujPlanProces B ON A.KOD=B.KOD
    ORDER BY A.Kod;
    
    
--           2. Tabela me gjendje magazine

      SELECT KOD = A.KARTLLG, GJENDJE = SUM(A.GJENDJE)
        INTO #TableGjendje
        FROM
       (
                SELECT B.KARTLLG, KMAG, GJENDJE=SUM(B.SASI)
                  FROM FH A INNER JOIN FHSCR B ON A.NRRENDOR=B.NRD
                            INNER JOIN #ListArtikuj L ON B.KARTLLG=L.KOD
                 WHERE A.DATEDOK<=@CurrDate AND KMAG=@KMagPrd
              GROUP BY KARTLLG,KMAG
             UNION ALL  
                SELECT B.KARTLLG, KMAG, GJENDJE=SUM(0-B.SASI)
                  FROM FD A INNER JOIN FDSCR B ON A.NRRENDOR=B.NRD
                            INNER JOIN #ListArtikuj L ON B.KARTLLG=L.KOD
                 WHERE A.DATEDOK<=@CurrDate AND KMAG=@KMagPrd           
              GROUP BY KARTLLG,KMAG
           ) A    
    GROUP BY KMAG,KARTLLG
    ORDER BY KMAG,KARTLLG;
    
    
--           3. Tabela me sasite e shitura (dokumenta shitje si dhe dokumenta furnizim dyqane me Fd furnizim nga @pKMagProdhim (ose 'PG1') tek dyqanet)

      SELECT KOD = A.KARTLLG, SasiShitur=SUM(A.SASI),SasiFaturuar=SUM(A.SasiFaturuar),SasiFurnizim=SUM(A.SasiFurnizim)
        INTO #TableShitje
        FROM
       ( 
           SELECT B.KARTLLG, SASI=SUM(B.SASI),SasiFaturuar=SUM(B.SASI),SasiFurnizim=0                -- te gjitha shitjet, pervec shitjet e dyqaneve
             FROM FJ A INNER JOIN FJSCR        B ON A.NRRENDOR=B.NRD
                       INNER JOIN MAGAZINA     M ON A.KMAG=M.KOD
                       INNER JOIN #ListArtikuj L ON B.KARTLLG=L.KOD
            WHERE DATEDOK=@DateShitje AND M.TIPI<>2          
         GROUP BY B.KARTLLG    
        UNION ALL 
           SELECT B.KARTLLG, SASI=SUM(B.SASI), SasiFaturuar=0,         SasiFurnizim=SUM(B.SASI)      -- te gjitha furnizimet, per dyqanet
             FROM FD A INNER JOIN FDSCR        B ON A.NRRENDOR=B.NRD
                       INNER JOIN MAGAZINA     M ON A.KMAGRF=M.KOD
                       INNER JOIN #ListArtikuj L ON B.KARTLLG=L.KOD
            WHERE A.KMAG=@KMagPrd AND A.DST='FU' AND A.DATEDOK=@DateFurnizim AND M.TIPI=2   --OR DATEDOK=DATEADD(DAY,-1,@CurrDate))  -- > Kujdes kriteri i dates
         GROUP BY B.KARTLLG,KMAG
         ) A 
    GROUP BY KARTLLG
    ORDER BY KARTLLG;  

   
   
--           4. Tabela me lsten a produkteve si dhe lendeve te para te nxjere nga Artikuj dhe ArtikujScr. 
--              Shtohen ne kete tabele dhe ato produkte (Artikuj.TIP='P') por qe skane lende te pare (skane perberesa ne ArtikujScr).

      SELECT NR=1, KOD=MAX(A.KOD),PERSHKRIM=MAX(A.PERSHKRIM),KOEFICIENT=1,KODLP=MAX(A.KOD),PERSHKRIMLP=MAX(A.PERSHKRIM),NJESILP=MAX(A.NJESI),TIPROW=0,TROW=CAST(1 AS BIT)
        INTO #ArtikujProducts
        FROM ARTIKUJSCR A INNER JOIN ARTIKUJ B ON A.NRD=B.NRRENDOR 
--     WHERE A.KOD>=@pKodLpKp AND A.KOD<=@pKodLpKs AND B.KOD>=@pKodPrKp AND B.KOD<=@pKodPrKs
    GROUP BY A.KOD   
    
   UNION ALL
                                                                                 
      SELECT NR=ROW_NUMBER() OVER (PARTITION BY A.KOD ORDER BY A.KOD,B.KOD) + 1, 
             KOD=B.KOD,PERSHKRIM=B.PERSHKRIM,A.KOEFICIENT,KODLP=A.KOD,PERSHKRIMLP=A.PERSHKRIM,NJESILP=A.NJESI,TIPROW=0,TROW=CAST(0 AS BIT) 
        FROM ARTIKUJSCR A INNER JOIN ARTIKUJ B ON A.NRD=B.NRRENDOR 
--     WHERE B.KOD>=@pKodLpKp AND B.KOD<=@pKodLpKs AND B.KOD>=@pKodPrKp AND B.KOD<=@pKodPrKs
    ORDER BY KOD,NR;


--           4.2 Shtohen produkte (Artikuj.Tip='P') por qe skane te percaktuar lende te pare si detaje, (pra skane elemente ne ArtikujScr).

      INSERT INTO #ArtikujProducts
            (NR,KOD,PERSHKRIM,KOEFICIENT,KODLP,PERSHKRIMLP,NJESILP,TIPROW,TROW)
      SELECT NR=1,KOD=A.KOD,PERSHKRIM=A.PERSHKRIM,KOEFICIENT=1,KODLP=A.KOD,PERSHKRIMLP=A.PERSHKRIM,NJESILP=A.NJESI,TIPROW=0,TROW=CAST(0 AS BIT) 
        FROM ARTIKUJ A 
       WHERE A.TIP='P' AND (NOT EXISTS (SELECT KOD FROM #ArtikujProducts B WHERE A.KOD=B.KOD))      
    ORDER BY A.KOD;



--           5. Tabele temporare me te dhenat nga te gjitha tabelat me fusha te llogaritura 

      SELECT Nr               = ISNULL(R4.Nr,0), A.Kod, A.Pershkrim, A.Njesi,

             SasiCalcul       = ROUND(ISNULL(R2.SasiShitur,0.0) + ISNULL(A.StokDitor,0.0) 
                                - 
                               (ISNULL(R1.Gjendje,0.0) + ISNULL(A.SasiProces,0.0)), 0),

             GjendjeMagazine  = ROUND(ISNULL(R1.Gjendje,0.0),  0),
             SasiProces       = ROUND(ISNULL(A.SasiProces,0.0),0),
             SasiMin          = ROUND(ISNULL(A.SasiMin,0.0),0),
             SasiShitur       = ROUND(ISNULL(R2.SasiShitur,0.0), 0),
             SasiFaturuar     = ROUND(ISNULL(R2.SasiFaturuar,0.0),0),
             SasiFurnizim     = ROUND(ISNULL(R2.SasiFurnizim,0.0),0),
             StokPlanDitor    = ROUND(ISNULL(A.StokDitor,0.0), 0),
             KoeficentProduct = CASE WHEN ISNULL(R4.Koeficient,1)<0 THEN 1 ELSE ISNULL(R4.Koeficient,1) END,
             KodLP            = R4.KodLP,
             PershkrimLP      = R4.PershkrimLP,
             NjesiLP          = R4.NjesiLP,
             NotActiv         = A.NotActiv 
             
        INTO #ArtikujPlanProdhim1
        
        FROM #ListArtikuj A  LEFT  JOIN #TableGjendje      R1  ON  A.KOD=R1.KOD
                             LEFT  JOIN #TableShitje       R2  ON  A.KOD=R2.KOD
                             INNER JOIN #ArtikujProducts   R4  ON  A.KOD=R4.KOD
    ORDER BY A.KOD;
    

          IF OBJECT_ID('TEMPDB..#ListArtikuj')         IS NOT NULL
             DROP TABLE #ListArtikuj;
          IF OBJECT_ID('TEMPDB..#TableGjendje')        IS NOT NULL
             DROP TABLE #TableGjendje;
          IF OBJECT_ID('TEMPDB..#TableShitje')         IS NOT NULL
             DROP TABLE #TableShitje;
          IF OBJECT_ID('TEMPDB..#ArtikujProducts')     IS NOT NULL
             DROP TABLE #ArtikujProducts;


--           6. Tabela perfundimtare #ArtikujPlanProdhim2 

      SELECT Nr, Kod,Pershkrim, Njesi, 
             SasiCalcul, GjendjeMagazine, Sasiproces, SasiShitur, SasiFaturuar, SasiFurnizim, StokPlanDitor, SasiMin, KoeficentProduct,
             SasiCalcul_Konv       = ROUND(SasiCalcul      * KoeficentProduct,0),
             GjendjeMagazine_Konv  = ROUND(GjendjeMagazine * KoeficentProduct,0),
             SasiProces_Konv       = ROUND(SasiProces      * KoeficentProduct,0),
             SasiShitur_Konv       = ROUND(SasiShitur      * KoeficentProduct,0),
             SasiFaturuar_Konv     = ROUND(SasiFaturuar    * KoeficentProduct,0),
             SasiFurnizim_Konv     = ROUND(SasiFurnizim    * KoeficentProduct,0),
             StokPlanDitor_Konv    = ROUND(StokPlanDitor   * KoeficentProduct,0),
             SasiMin_Konv          = ROUND(SasiMin         * KoeficentProduct,0),
             KodLP, 
             PershkrimLP,
             Njesi_Konv            = NjesiLP,
             NotActiv,
             DateShitje            = @DateShitje,
             DateFurnizim          = @DateFurnizim,
             DiteStokJavor         = @DiteStokJavor,
             Fields1               = 'Sasi,SasiCalcul,GjendjeMagazine,SasiProces,SasiShitur,SasiFaturuar,SasiFurnizim,StokPlanDitor,StockPlan,SasiMin',
             Prompt1               = 'Prodhim,SasiProdhim,Gjendje,Furre,Shitur,Faturuar,Furnizim,StockDitor,Stok,SasiMin',
             Fields2               = 'StokPlan,ShitjeLWeekDt,CurrLWeekDt',
             Prompt2               = 'Stok,ShitjeJK,Shitje',
             TRow                  = CAST(0 AS BIT),
             TagNr                 = 0
        INTO #ArtikujPlanProdhim2
        FROM #ArtikujPlanProdhim1
    ORDER BY KOD;
         


--           6.2 Total per cdo lende te pare (tatalet dhe shumat per cdo produkt qe te llogaritet lenda e pare) ....
--           Shtohet ketu resht total (Nr=99) per te llogaritur shumat e cdo kolone

      INSERT INTO #ArtikujPlanProdhim2
            (Nr, Kod,Pershkrim, Njesi, 
             SasiCalcul, GjendjeMagazine, Sasiproces, SasiShitur, SasiFaturuar, SasiFurnizim, StokPlanDitor, SasiMin, KoeficentProduct,
             SasiCalcul_Konv, GjendjeMagazine_Konv, SasiProces_Konv, SasiShitur_Konv, SasiFaturuar_Konv, SasiFurnizim_Konv,StokPlanDitor_Konv, SasiMin_Konv,
             KodLP,PershkrimLP,Njesi_Konv,NotActiv,DateShitje,DateFurnizim,DiteStokJavor,Fields1,Prompt1,Fields2,Prompt2,TRow,TagNr)
      SELECT Nr                    = 99, 
             Kod                   = KodLP, 
             Pershkrim             = MAX(PershkrimLP), 
             Njesi                 = MAX(CASE WHEN KOD=KodLP THEN NJESI     ELSE '' END), 
             SasiCalcul            = SUM(SasiCalcul_Konv), 
             GjendjeMagazine       = SUM(GjendjeMagazine_Konv), 
             Sasiproces            = SUM(SasiProces_Konv), 

             SasiShitur            = SUM(SasiShitur_Konv), 
             SasiFaturuar          = SUM(SasiFaturuar_Konv),
             SasiFurnizim          = SUM(SasiFurnizim_Konv),
             
             StokPlanDitor         = SUM(StokPlanDitor_Konv),     
             SasiMin               = SUM(SasiMin_Konv),          
             KoeficentProduct      = 1,
             SasiCalcul_Konv       = SUM(SasiCalcul_Konv),
             GjendjeMagazine_Konv  = SUM(GjendjeMagazine_Konv),
             SasiProces_Konv       = SUM(SasiProces_Konv),
             
             SasiShitur_Konv       = SUM(SasiShitur_Konv),
             SasiFaturuar_Konv     = SUM(SasiFaturuar_Konv),
             SasiFurnizim_Konv     = SUM(SasiFurnizim_Konv),
             
             StokPlanDitor_Konv    = SUM(StokPlanDitor_Konv),    
             SasiMin_Konv          = SUM(SasiMin_Konv),          
             KodLp,
             PershkrimLP           = MAX(PershkrimLP),
             Njesi_Konv            = MAX(Njesi_Konv),
             NotActiv              = MAX(CASE WHEN Kod=KodLP THEN NotActiv  ELSE 0  END),
             DateShitje            = MAX(DateShitje),
             DateFurnizim          = MAX(DateFurnizim),
             DiteStokJavor         = MAX(DiteStokJavor),
             Fields1               = MAX(Fields1),
             Prompt1               = MAX(Prompt1),
             Fields2               = MAX(Fields2),
             Prompt2               = MAX(Prompt2),
             TRow                  = CAST(0 AS BIT),
             TagNr                 = 0
        FROM #ArtikujPlanProdhim2
    GROUP BY KodLP   
    ORDER BY KodLP;


          IF OBJECT_ID('TEMPDB..#ArtikujPlanProdhim1')  IS NOT NULL
             DROP TABLE #ArtikujPlanProdhim1;

          IF OBJECT_ID('TEMPDB..'+@TableTmpName)        IS NOT NULL
             EXEC ('DROP TABLE ' +@TableTmpName);

        EXEC ('SELECT * INTO '+@TableTmpName+' FROM #ArtikujPlanProdhim2 ORDER BY KODLP,KOD');   

          IF OBJECT_ID('TEMPDB..#ArtikujPlanProdhim2') IS NOT NULL
             DROP TABLE #ArtikujPlanProdhim2;
          



DISPLAYDATA:          
            
         SET  @sFields = 'Nr,Kod,Pershkrim,Njesi_Konv,SasiCalcul_Konv, GjendjeMagazine_Konv,'+
                         'Sasiproces_Konv,SasiShitur_Konv,SasiFaturuar_Konv,SasiFurnizim_Konv,StokPlanDitor_Konv,SasiMin_Konv,KoeficentProduct,'+
                         'NotActiv,DateShitje,DateFurnizim,DiteStokJavor,TRow,TagNr';

         IF   @Oper='P' -- Printim
              BEGIN
                SET  @sFields = 
                         'Nr,Kod,Pershkrim,Njesi=Njesi,NjesiKonv=Njesi_Konv,SasiCalcul=SasiCalcul_Konv, GjendjeMagazine=GjendjeMagazine_Konv,'+
                         'Sasiproces=Sasiproces_Konv,SasiShitur=SasiShitur_Konv,SasiFaturuar=SasiFaturuar_Konv,SasiFurnizim=SasiFurnizim_Konv,'+
                         'StokPlanDitor=StokPlanDitor_Konv,SasiMin=SasiMin_Konv,KoeficentProduct,'+
                         'NotActiv,DateShitje,DateFurnizim,DiteStokJavor,TRow,TagNr,NrOrder=Case When NR=99 Then '''' Else Cast(NR As Varchar) End,'+

                       -- Pjesa ku ruhet filtri  
                         'FilTipArtikuj='''+@TipArtikuj+''',FiltSasiKonv='''+@SasiKonv+''','+
                         'FiltProductActive='+CAST(@ProductActive AS VARCHAR)+',FiltSasiMinimale='+CAST(@SasiMinimale AS VARCHAR)+','+
                         'Kushte=''Shitje: ''+Convert(Varchar,DateShitje,104)+'', furnizim: ''+Convert(Varchar,DateFurnizim,104)+'', dite stoku: ''+DiteStokJavor+'+
                         'Case When '''+@SasiKonv+'''=''K'' Then '', ne sasi konvertuar'' Else '''' End+'+
                         'Case When '+CAST(@ProductActive AS VARCHAR)+'=1 Then '', produktet aktive'' Else '''' End ';   -- 'PershkrimRp=''Planifikim prodhim ditor''';

                 IF  @SasiKonv<>'K'                                            -- 0. Kriter afishimi, ne njesi magazine ose njesi te konvertuar
                     SET  @sFields = REPLACE(@sFields,'Njesi_Konv','''''');
              END
                       

         SET  @sString = ' 3=3 ';                                              -- 1. Kriteri SasiMin dhe gjendje magazine

         IF   @SasiMinimale>0  
              SET  @sString = ' GjendjeMagazine_Konv'+CASE WHEN @SasiMinimale=1 THEN '>=' ELSE '<' END+'SasiMin_Konv ';
         


          SET @sSql = '
       SELECT '+@sFields+' 
         FROM '+@TableTmpName + ' 
        WHERE 1=1 AND 2=2 AND 3=3 
     ORDER BY KODLP,NR';


          SET @sSql = REPLACE(@sSql,' 3=3 ',@sString);


     --   IF  @Oper<>'P'                                                       --    Ne krijim dhe afishim te dhena (jo per printimin) 
     --       BEGIN
                IF  @SasiKonv<>'K' AND @TipArtikuj<>'T'                        -- 2. Kriter afishimi, ne njesi magazine ose njesi te konvertuar
                    SET @sSql = REPLACE(@sSql,'_Konv','');
             
                    SET @sSql = REPLACE(@sSql,',Njesi_Konv',',Njesi,Njesi_Konv');
     --       END;
              
              
          IF  @ProductActive>0                                                 -- 3. Kriteri per artikuj produkt aktive ose jo aktivet
              BEGIN
                SET @sSql = REPLACE(@sSql,' 1=1 ',' ISNULL(NotActiv,0)='+CAST(@ProductActive-1 AS VARCHAR))+' ';
              END;
                                         

          IF  @TipArtikuj='L'                                                  -- 4. Kriteri per afishim produkte dhe perberesit
              SET @sSql = REPLACE(@sSql, ' 2=2 ',' NR=1 ')
          ELSE
          IF  @TipArtikuj='P'
              SET @sSql = REPLACE(@sSql, ' 2=2 ',' NR<99 ')
          ELSE    
          IF  @TipArtikuj='T'
              SET @sSql = REPLACE(@sSql, ' 2=2 ',' NR=99 ');
-- PRINT @Oper;         
-- PRINT @sSql
        EXEC (@sSql);
              
GO
