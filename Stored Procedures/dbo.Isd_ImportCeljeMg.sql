SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- EXEC Isd_ImportCeljeMg @pDbOrigjine='EHW19',@pDateCls='31.12.2019',@pDateDoc='01.08.2013',@pWhere='',@pGrupimArtDL=0,@pGrupimArtFar=0,@pGrupimArtBC=0
       
CREATE        Procedure [dbo].[Isd_ImportCeljeMg]
( 


-- KUJDES  !!!!

-- Kjo procedure ka shume ngjashmeri me proceduren [Isd_ImportCeljeArtikuj] prandaj
-- cdo ndryshim ketu mund te pasqyrohet edhe tek procedura [Isd_ImportCeljeArtikuj]


  @pDbOrigjine   Varchar(50),       
  @pDateCls      Varchar(20),       
  @pDateDoc      Varchar(20),
  @pWhere        Varchar(Max),
  @pGrupimArtDL  Int,               -- Grupim sipas dep/liste
  @pGrupimArtFar Int,               -- Grupim sipas [Date skadence] / [Lot (Seri)]/ [Rimbursim]
  @pGrupimArtBC  Int                -- Grupim sipas barkod,-- Te pyeten Eriald,Genti,Altini per keto raste
                         
 )

AS

-- U zgjidhen Celje sipas kritereve: 1. Celje thjeshte,                       
--                                   2. Sipas depart/liste pa seri skadence, 
--                                   3. Sipas depart/liste dhe seri skadence 
--                                   4. Me seri skadence pa depart/liste
-- Edhe per rastin magazine amballazh por thjesht pa detaje te depart/liste apo seri/skadence
-- Ne se do te duhet celje amballazhi me depart/liste apo/edhe seri/skadence te behet.



-- Mbeti rasti celje per barkod  !!?????????



         SET NOCOUNT ON;

--  DECLARE @pDbOrigjine   Varchar(50),
--          @pDateCls      Varchar(20),
--          @pDateDoc      Varchar(20)
--      SET @pDbOrigjine = 'EHW13'
--      SET @pDateCls    = '25/07/2013'
--      SET @pDateDoc    = '01/08/2013'
--      SET @pWhere      = ''


          IF DB_NAME() = @pDbOrigjine
             RETURN;   -- Print 'Asgje'



     DECLARE @ListFields  Varchar(Max),
             @Sql1        Varchar(Max),
             @Sql2        Varchar(Max);
             

          IF OBJECT_ID('TEMPDB..#CELJEMG') IS NOT NULL 
             DROP TABLE #CELJEMG; 
             

      SELECT * 
        INTO #CELJEMG 
        FROM FHSCR 
       WHERE 1>2; 

       ALTER TABLE #CELJEMG ADD KMAG VARCHAR(20) NULL; 
       
       

   RAISERROR ('1.  Fillimm i celjes se magazinave  ', 0, 1) WITH NOWAIT;



      SELECT @Sql1  = '

   RAISERROR (''2.  Fillim Celje magzina jo amballazh '', 0, 1) WITH NOWAIT; 

      INSERT INTO  #CELJEMG 
            (KMAG,KOD,KODAF,KARTLLG,BC,SASI,VLERAM) 
      SELECT KMAG,
             KOD    = KMAG+''.''+KARTLLG+''...'',
             KODAF  = KARTLLG,
             KARTLLG, 
             BC     = ISNULL(BARCOD,''''),
             SASIC  = SUM(SASIH -SASID), 
             VLERA  = SUM(VLERAH-VLERAD) 
        FROM '+@pDbOrigjine+'..LEVIZJEHD 
       WHERE 1=1 AND (KMAG<>(SELECT ISNULL(KMAGAMB,'''') FROM '+@pDbOrigjine+'..CONFIGMG))
    GROUP BY KMAG,KARTLLG,ISNULL(BARCOD,'''') 
      HAVING (ABS(SUM(SASIH -SASID))>=0.01) OR (ABS(SUM(VLERAH-VLERAD))>=0.01) 
    ORDER BY KMAG,KARTLLG;';


                                                           -- Celje per magazinen Amballazh
      SELECT @Sql2  = '

   RAISERROR (''3.  Fillim Celje magazina amballazh '', 0, 1) WITH NOWAIT; 

      INSERT INTO  #CELJEMG 
            (KMAG,KOD,KODAF,KARTLLG,BC,SASI,VLERAM,KODKLF,ISAMB) 
      SELECT KMAG,
             KOD    = KMAG+''.''+KARTLLG+''...'',
             KODAF  = KARTLLG,
             KARTLLG,
             BC     = ISNULL(BARCOD,''''),
             SASIC  = SUM(SASIH -SASID), 
             VLERA  = SUM(VLERAH-VLERAD),
             KODKLF,
             ISAMB  = ISNULL(ISAMB,0) 
        FROM '+@pDbOrigjine+'..LEVIZJEHD 
       WHERE 1=1 AND (KMAG=(SELECT ISNULL(KMAGAMB,'''') FROM '+@pDbOrigjine+'..CONFIGMG))
    GROUP BY KMAG,KARTLLG,ISNULL(BARCOD,''''),KODKLF,ISNULL(ISAMB,0)
      HAVING (ABS(SUM(SASIH -SASID))>=0.01) OR (ABS(SUM(VLERAH-VLERAD))>=0.01) 
    ORDER BY KMAG,KARTLLG,KODKLF;';




          IF @pGrupimArtDL=1                               -- Analitik: Departament - Liste
             BEGIN

                 SELECT @Sql1 = '

              RAISERROR (''2.  Fillim Celje magzina jo amballazh sipas departament/liste  '', 0, 1) WITH NOWAIT; 

                 INSERT INTO  #CELJEMG 
                       (KMAG,KOD,KODAF,KARTLLG,BC,SASI,VLERAM) 
                 SELECT KMAG, 
                        KOD,
                        KODAF = KARTLLG + CASE WHEN dbo.Isd_SegmentFind(KOD,0,4)<>'''' 
                                               THEN ''.''+Dbo.Isd_SegmentFind(KOD,0,3)+''.''+dbo.Isd_SegmentFind(KOD,0,4)
                                               WHEN dbo.Isd_SegmentFind(KOD,0,3)<>''''
                                               THEN ''.''+Dbo.Isd_SegmentFind(KOD,0,3)
                                               ELSE ''''
                                          END,
                        KARTLLG, 
                        BC    = ISNULL(BARCOD,''''),
                        SASIC = SUM(SASIH -SASID), 
                        VLERA = SUM(VLERAH-VLERAD) 
                   FROM '+@pDbOrigjine+'..LEVIZJEHD 
                  WHERE 1=1 AND (KMAG<>(SELECT ISNULL(KMAGAMB,'''') FROM '+@pDbOrigjine+'..CONFIGMG))
               GROUP BY KMAG,KOD,KARTLLG,ISNULL(BARCOD,'''') 
                 HAVING (ABS(SUM(SASIH -SASID))>=0.01) OR (ABS(SUM(VLERAH-VLERAD))>=0.01) 
               ORDER BY KMAG,KOD,KARTLLG;';

             END;


          IF @pGrupimArtFar=1 AND @pGrupimArtDL=1         -- Me (Dateskadence dhe seri) edhe (Analitik: Departament - Liste)
             BEGIN

                 SELECT @Sql1 = '

              RAISERROR (''2.  Fillim Celje magzina jo amballazh sipas seri/skadence dhe departament/liste  '', 0, 1) WITH NOWAIT; 

                 INSERT INTO  #CELJEMG 
                       (KMAG,KOD,KODAF,KARTLLG,BC,SASI,VLERAM,DTSKADENCE,SERI) 
                 SELECT KMAG, 
                        KOD   = KMAG+''.''+KARTLLG+''...'',
                        KODAF = KARTLLG + CASE WHEN dbo.Isd_SegmentFind(KOD,0,4)<>'''' 
                                               THEN ''.''+Dbo.Isd_SegmentFind(KOD,0,3)+''.''+dbo.Isd_SegmentFind(KOD,0,4)
                                               WHEN dbo.Isd_SegmentFind(KOD,0,3)<>''''
                                               THEN ''.''+Dbo.Isd_SegmentFind(KOD,0,3)
                                               ELSE ''''
                                          END,
                        KARTLLG,
                        BC    = ISNULL(BARCOD,''''),
                        SASIC = SUM(SASIH -SASID), 
                        VLERA = SUM(VLERAH-VLERAD),
                        DTSKADENCE,
                        SERI  = ISNULL(SERI,'''') 
                   FROM '+@pDbOrigjine+'..LEVIZJEHD 
                  WHERE 1=1 AND (KMAG<>(SELECT ISNULL(KMAGAMB,'''') FROM '+@pDbOrigjine+'..CONFIGMG))
               GROUP BY KMAG,KOD,KARTLLG,ISNULL(BARCOD,''''),DTSKADENCE,ISNULL(SERI,'''') 
                 HAVING (ABS(SUM(SASIH -SASID))>=0.01) OR (ABS(SUM(VLERAH-VLERAD))>=0.01) 
               ORDER BY KMAG,KOD,KARTLLG,DTSKADENCE,ISNULL(SERI,'''');';

             END;


          IF @pGrupimArtFar=1 AND @pGrupimArtDL=0         -- Me (Dateskadence dhe seri) por jo (Analitik: Departament - Liste)
             BEGIN

                 SELECT @Sql1 = '

              RAISERROR (''2.  Fillim Celje magzina jo amballazh sipas seri/skadence  '', 0, 1) WITH NOWAIT; 

                 INSERT INTO  #CELJEMG 
                       (KMAG,KOD,KODAF,KARTLLG,BC,SASI,VLERAM,DTSKADENCE,SERI) 
                 SELECT KMAG, 
                        KOD   = KMAG+''.''+KARTLLG+''...'',
                        KODAF = KARTLLG,
                        KARTLLG,
                        BC    = ISNULL(BARCOD,''''),
                        SASIC = SUM(SASIH -SASID), 
                        VLERA = SUM(VLERAH-VLERAD),
                        DTSKADENCE,
                        SERI  = ISNULL(SERI,'''') 
                   FROM '+@pDbOrigjine+'..LEVIZJEHD 
                  WHERE 1=1 AND (KMAG<>(SELECT ISNULL(KMAGAMB,'''') FROM '+@pDbOrigjine+'..CONFIGMG))
               GROUP BY KMAG,KARTLLG,ISNULL(BARCOD,''''),DTSKADENCE,ISNULL(SERI,'''') 
                 HAVING (ABS(SUM(SASIH -SASID))>=0.01) OR (ABS(SUM(VLERAH-VLERAD))>=0.01) 
               ORDER BY KMAG,KARTLLG,DTSKADENCE,ISNULL(SERI,'''');';

             END;

 
        SET @Sql1 = @Sql1 + @Sql2;
        

          IF @pWhere=''     -- Genti: Rasti kur vjen bosh dhe nuk i vinte kufizime.
             SET @pWhere = 'DATEDOK<=DBO.DATEVALUE('+QuoteName(@pDateCls,'''')+')'; 

         SET @Sql1 = REPLACE(@Sql1,'1=1',@pWhere);


          IF @pGrupimArtBC<>1
             BEGIN
               SET @Sql1 = REPLACE(@Sql1,',ISNULL(BARCOD,'''')','');
               SET @Sql1 = REPLACE(@Sql1,'= ISNULL(BARCOD,'''')','= ''''');
             END;

       PRINT  @Sql1;
        EXEC (@Sql1);



   RAISERROR ('4.  Plotesim dokumenta celje /1  ', 0, 1) WITH NOWAIT;

      UPDATE A 
         SET NRRENDKLLG   = B.NRRENDOR, 
          -- KOD          = KMAG+'.'+KARTLLG+'...', 
          -- KODAF        = KARTLLG, 
             PERSHKRIM    = B.PERSHKRIM, 
             NJESI        = B.NJESI, 
             SASI         = ROUND(SASI,3), 
             VLERAM       = ROUND(VLERAM,3), 
             CMIMM        = ROUND(CASE WHEN (SASI*VLERAM)>0 THEN VLERAM/SASI ELSE B.KOSTMES END,3), 
             KMON         = '', 
             VLERAFT      = ROUND(VLERAM,3), 
             CMIMBS       = ROUND(CASE WHEN (SASI*VLERAM)>0 THEN VLERAM/SASI ELSE B.KOSTMES END,3), 
             VLERABS      = ROUND(VLERAM,3), 
             KOEFSHB      = 1,
             NJESINV      = B.NJESI, 
             BC           = ISNULL(B.BC,''), 
             CMIMSH       = B.CMSH,
             VLERASH      = ROUND(A.SASI*B.CMSH,3),
             A.TIPKTH     = '',
             A.FAKLS      = '',
             A.FADESTIN   = '',
             A.FASTATUS   = '',
             A.TIPFR      = '',
             A.SASIFR     = 0,
             A.VLERAFR    = 0,
             A.PROMOC     = 0,
             A.PROMOCTIP  = '',
             
          -- A.SERI       = '',
             A.DTSKADENCE = CASE WHEN A.DTSKADENCE=0 OR (YEAR(A.DTSKADENCE)=1989 AND MONTH(A.DTSKADENCE)=12 AND DAY(A.DTSKADENCE)=1)
                                 THEN NULL
                                 ELSE A.DTSKADENCE
                            END,
                            
             A.KOEFICIENT = 0,
             A.KONVERTART = 0,
             A.RIMBURSIM  = B.RIMBURSIM,
             A.KLSART     = '',
             A.LLOGLM     = '',
             A.ORDERSCR   = 0,
             GJENROWAUT   = 0, 
             KOMENT       = 'Gjendje me '+@pDateCls, 
             CMIMOR       = ROUND(CASE WHEN (SASI*VLERAM)>0 THEN VLERAM/SASI ELSE B.KOSTMES END,3), 
             VLERAOR      = ROUND(VLERAM,3),
             TIPKLL       = 'K', 
             TROW         = 0, 
             TAGNR        = 0
        FROM #CELJEMG A LEFT JOIN ARTIKUJ B ON A.KARTLLG=B.KOD; 



   RAISERROR ('5.  Plotesim dokumenta celje /2  ', 0, 1) WITH NOWAIT;

      UPDATE FH SET TAGNR=0 WHERE TAGNR<>0;



   RAISERROR ('6.  Plotesim dokumenta celje /3  ', 0, 1) WITH NOWAIT;

      INSERT 
        INTO FH (KMAG,NRDOK,TAGNR) 
      SELECT DISTINCT KMAG, 
             NR = ISNULL(( SELECT MAX(ISNULL(B.NRDOK,0)) 
                             FROM FH B 
                            WHERE B.KMAG=A.KMAG AND YEAR(B.DATEDOK)=YEAR(DBO.DATEVALUE(@pDateDoc))
                         GROUP BY B.KMAG),0) + 1,
             100 
        FROM #CELJEMG A
    ORDER BY KMAG;



   RAISERROR ('7.  Plotesim dokumenta celje /4  ', 0, 1) WITH NOWAIT;

      UPDATE A 
         SET NRMAG        = B.NRRENDOR, 
             TIP          = 'H', 
             NRFRAKS      = 0, 
             DATEDOK      = DBO.DATEVALUE(@pDateDoc), 
             A.SHENIM1    = 'Gjendje me '+@pDateCls, 
             A.SHENIM2    = '', 
             A.SHENIM3    = '', 
             A.SHENIM4    = '', 
             NRDFK        = 0, 
             DOK_JB       = 0, 
             NRRENDORFAT  = 0, 
             TIPFAT       = '', 
             KTH          = 0, 
             DST          = 'CE', 
             A.KODLM      = '',
             A.KLASIFIKIM = '',
             A.NRSERIAL   = '',
             A.KMAGRF     = '',
             A.KMAGLNK    = '',
             A.NRDOKLNK   = 0,
             A.NRFRAKSLNK = 0,
             A.POSTIM     = 0,
             A.LETER      = 0,
             A.GRUP       = B.GRUP,
             A.KALIMLMZGJ = 0,
             A.FAKLS      = '',
             A.FADESTIN   = '',
             A.FABUXHET   = '',
             A.NRDOKUP    = 0,
             A.FIRSTDOK   = 'H'+CAST(A.NRRENDOR AS VARCHAR), 
             A.USI        = 'A', 
             A.USM        = 'A', 
             A.TAG        = 0, 
             A.TROW       = 0 
        FROM FH A LEFT JOIN MAGAZINA B ON A.KMAG=B.KOD 
       WHERE A.TAGNR=100; 



   RAISERROR ('8.  Plotesim dokumenta celje /5  ', 0, 1) WITH NOWAIT;

      UPDATE A 
         SET NRD=B.NRRENDOR 
        FROM #CELJEMG A LEFT JOIN FH B ON A.KMAG=B.KMAG 
       WHERE B.TAGNR=100; 



   RAISERROR ('9.  Plotesim dokumenta celje /6  ', 0, 1) WITH NOWAIT;

      UPDATE FH SET TAGNR=0 WHERE TAGNR=100; 

      SELECT @ListFields = dbo.Isd_ListFieldsTable('FHSCR','NRRENDOR');

      SELECT @Sql1 = '   
      INSERT INTO FHSCR 
            ('+@ListFields+') 
      SELECT '+@ListFields+'
        FROM #CELJEMG 
    ORDER BY NRD,KARTLLG,ISNULL(BC,''''),ISNULL(DTSKADENCE,0),ISNULL(SERI,''''); '



   RAISERROR ('10. Kalimi ne baze i detajeve  ', 0, 1) WITH NOWAIT;

       EXEC (@Sql1);



   RAISERROR ('11. Perfundim i celjes se magazinave  ', 0, 1) WITH NOWAIT;

          IF OBJECT_ID('TEMPDB..#CELJEMG') IS NOT NULL 
             DROP TABLE #CELJEMG; 



GO
