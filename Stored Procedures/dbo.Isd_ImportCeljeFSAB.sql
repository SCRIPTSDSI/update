SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Exec [Isd_ImportCeljeFSAB] @pdbOrigjine='EHW13', @pDateCls='26.07.2013', @pDateDoc='01/08/2013',@pWhere='', @pModul='F', @pAnalitik=1
       
CREATE       Procedure [dbo].[Isd_ImportCeljeFSAB]
( 

-- Kjo procedure ka shume ngjashmeri me proceduren [Isd_ImportGjendjeFSABT] prandaj 
-- cdo ndryshim ketu mund te pasqyrohet edhe tek procedura [Isd_ImportGjendjeFSABT]

-- Ketu behen Celjet per Arke,Banke,Klient dhe Furnitor.
-- Per Celjet e liber te madh shiko dbo.Isd_ImportCeljeFK;


  @pdbOrigjine  Varchar(50),
  @pDateCls     Varchar(20),
  @pDateDoc     Varchar(20),
  @pWhere       Varchar(MAX),
  @pModul       Varchar(10),
  @pAnalitik    Int
 )
 
AS

         SET NOCOUNT ON;

--   DECLARE @pdbOrigjine   Varchar(50),
--           @pDateCls      Varchar(20),
--           @pDateDoc      Varchar(20),
--           @pWhere        Varchar(Max),
--           @pModul        Varchar(10),
--           @pAnalitik     Int;
--       SET @pdbOrigjine = 'EHW13';
--       SET @pDateCls    = '26/07/2013';
--       SET @pDateDoc    = '01/08/2013';
--       SET @pWhere      = '';
--       SET @pModul      = 'F';
--       SET @pAnalitik   = 1;     


          IF DB_NAME() = @pdbOrigjine
             RETURN;                     -- Print 'Asgje'


     DECLARE @dbOrigjine   Varchar(50),
             @sDateCls     Varchar(20),
             @sDateDoc     Varchar(20),
             @sWhere       Varchar(MAX),
             @sModul       Varchar(10),
             @Analitik     Int,
             @ListFields   Varchar(MAX),
             @Sql          Varchar(MAX),
             @DitarName    Varchar(30),
             @TipDokument  Varchar(10),
             @Prompt       Varchar(150),
             @LlgCelje     Varchar(30),
             @VlereDIF     Float,
             @NrD          Int;
          
         SET @dbOrigjine = @pdbOrigjine;
         SET @sDateCls   = @pDateCls;
         SET @sWhere     = @pWhere;
         SET @sDateDoc   = @pDateDoc;
         SET @sModul     = @pModul;
         SET @Analitik   = @pAnalitik;
         
         IF  @sDateCls = ''
             SET @sDateCls = CONVERT(VARCHAR(10),GETDATE(),104);

          IF CHARINDEX(@sModul,'FSAB')=0
             RETURN;



          IF @sModul='F'
             BEGIN     
               SET @DitarName   = 'DFU';
               SET @TipDokument = 'FF';
               SET @Prompt      = 'Furnitor';
                IF @Analitik<0 OR @Analitik>1
                   SET @Analitik=0;  
             END;

          IF @sModul='S'
             BEGIN     
               SET @DitarName   = 'DKL';
               SET @TipDokument = 'FJ';
               SET @Prompt      = 'Klient';
                IF @Analitik<0 OR @Analitik>2
                   SET @Analitik=0;  
             END;

          IF @sModul='A'
             BEGIN     
               SET @DitarName   = 'DAR';
               SET @TipDokument = '';
               SET @Prompt      = 'Arka';
               SET @Analitik    = 0;
             END;

          IF @sModul='B'
             BEGIN     
               SET @DitarName   = 'DBA';
               SET @TipDokument = '';
               SET @Prompt      = 'Banka';
               SET @Analitik    = 0;
             END;



   RAISERROR ('1.  Fillimi i importit te gjendjeve / [%s]  ', 0, 1,@DitarName) WITH NOWAIT;


      -- SET @sDateCls = QuoteName(@sDateCls,'''');
         SET @Prompt   = 'Gjendje '+@Prompt+': '+@sDateCls;


          IF OBJECT_ID('TEMPDB..#CELJEMOD') IS NOT NULL
             DROP TABLE #CELJEMOD ;
          IF OBJECT_ID('TEMPDB..#TableFatAgj') IS NOT NULL
             DROP TABLE #TableFatAgj;


      SELECT * 
        INTO #CELJEMOD 
        FROM VSSCR 
       WHERE 1>2 ;

--     ALTER TABLE #CELJEMOD ADD KMAG VARCHAR(20) NULL;


          IF @Analitik=0
             BEGIN
               SET @Sql = ' 
                    INSERT INTO #CELJEMOD 
                          (KOD, KMON, DB, DBKRMV,TIPREF,DATEDOKREF, NRDOKREF) 
                    SELECT KOD, KMON,
                           DB         = SUM(CASE WHEN   TREGDK=''D'' THEN   VLEFTA   ELSE 0-VLEFTA   END), 
                           VLMV       = SUM(CASE WHEN   TREGDK=''D'' THEN   VLEFTAMV ELSE 0-VLEFTAMV END),
                           TIPREF     = '''+@TipDokument+''',                                                  -- Pse mos jene bosh ose null       12.01.2020
                           DATEDOKREF = DBO.DATEVALUE('+QuoteName(@sDateCls,'''')+'),                          -- Pse mos jene 0 ose null          12.01.2020
                           NRDOKREF   = 0 
                      FROM '+@dbOrigjine+'..'+@DitarName+' 
                     WHERE 1=1 
                  GROUP BY KOD, KMON 
                    HAVING ABS(SUM(CASE WHEN TREGDK=''D'' THEN VLEFTA   ELSE 0-VLEFTA   END))>=0.01 OR  
                           ABS(SUM(CASE WHEN TREGDK=''D'' THEN VLEFTAMV ELSE 0-VLEFTAMV END))>=0.01 
                  ORDER BY KMON, KOD '


             END
             
          ELSE
          
          IF @Analitik<=1
             BEGIN                                                -- Celje Furnitore dhe Kliente sipas faturave 
               SET @Sql = ' 
                    INSERT INTO #CELJEMOD 
                          (KOD, KMON, DB, DBKRMV,TIPREF,DATEDOKREF, NRDOKREF) 
                    SELECT KOD, KMON,
                           VL         = SUM(CASE WHEN   TREGDK=''D'' THEN   VLEFTA   ELSE 0-VLEFTA   END), 
                           VLMV       = SUM(CASE WHEN   TREGDK=''D'' THEN   VLEFTAMV ELSE 0-VLEFTAMV END),
                           TIPREF     = '''+@TipDokument+''',
                           DATEDOKREF = DTFAT,
                           NRDOKREF   = NRFAT 
                      FROM '+@dbOrigjine+'..'+@DitarName+' 
                     WHERE 1=1
                  GROUP BY KOD,KMON,NRFAT,DTFAT 
                    HAVING ABS(SUM(CASE WHEN TREGDK=''D'' THEN VLEFTA   ELSE 0-VLEFTA   END))>=0.01 OR  
                           ABS(SUM(CASE WHEN TREGDK=''D'' THEN VLEFTAMV ELSE 0-VLEFTAMV END))>=0.01 
                  ORDER BY KMON, KOD '
             END
             
          ELSE
          
             BEGIN                                                -- Celje Kliente sipas faturave dhe Agjente shitje
               SET @Sql = ' 
               
                    SELECT *
                      INTO #TableFatAgj
                      FROM
                  ( 
                    SELECT KODFKL_TMP     = A.KODFKL, 
                           KLIENTMON_TMP  = A.KODFKL+''.''+ISNULL(KMON,''''),         
                           KMON_TMP       = ISNULL(A.KMON,''''),   
                           KODAGJENT_TMP  = ISNULL(A.KLASIFIKIM,''''),
                           NRFAT_TMP      = ISNULL(A.NRDSHOQ,''''), 
                           DTFAT_TMP      = ISNULL(A.DTDSHOQ,0),   
                           TIPDOK_TMP     = 1 
                      FROM '+@dbOrigjine+'..FJ A
                     WHERE NOT (ISNULL(A.KLASIFIKIM,'''')='''' OR ISNULL(A.NRDSHOQ,'''')='''' OR ISNULL(A.DTDSHOQ,0)=0)
                  GROUP BY A.KODFKL,ISNULL(A.KMON,''''),ISNULL(A.KLASIFIKIM,''''),ISNULL(A.NRDSHOQ,''''),ISNULL(A.DTDSHOQ,0)
                 
                 UNION ALL
                  
                    SELECT KODFKL_TMP     = B.LLOGARIPK,
                           KLIENTMON_TMP  = B.LLOGARIPK+''.''+ISNULL(B.KMON,''''),
                           KMON_TMP       = ISNULL(B.KMON,''''),
                           KODAGJENT_TMP  = ISNULL(B.KODAGJENT,''''), 
                           NRFAT_TMP      = ISNULL(B.NRDOKREF,''''),
                           DTFAT_TMP      = ISNULL(B.DATEDOKREF,0),
                           TIPDOK_TMP     = 2
                      FROM '+@dbOrigjine+'..VS A INNER JOIN '+@dbOrigjine+'..VSSCR B ON A.NRRENDOR=B.NRD
                     WHERE B.TIPKLL=''S'' AND (NOT ( ISNULL(B.KODAGJENT,'''')='''' OR ISNULL(B.NRDOKREF,'''')='''' OR ISNULL(B.DATEDOKREF,0)=0 ))
                  GROUP BY B.LLOGARIPK,ISNULL(B.KMON,''''),ISNULL(B.KODAGJENT,''''),ISNULL(B.NRDOKREF,''''),ISNULL(B.DATEDOKREF,0)   
                  
                         ) A
                         
                  ORDER BY KLIENTMON_TMP,KODAGJENT_TMP,DTFAT_TMP,NRFAT_TMP; 
                  
                  

                    INSERT INTO #CELJEMOD 
                          (KOD, KMON, DB, DBKRMV, TIPREF, DATEDOKREF, NRDOKREF, KODAGJENT) 
                    SELECT KOD, 
                           KMON        = ISNULL(KMON,''''),
                           VL          = SUM(CASE WHEN   TREGDK=''D'' THEN   VLEFTA   ELSE 0-VLEFTA   END), 
                           VLMV        = SUM(CASE WHEN   TREGDK=''D'' THEN   VLEFTAMV ELSE 0-VLEFTAMV END),
                           TIPREF      = '''+@TipDokument+''',
                           DATEDOKREF  = ISNULL(DTFAT,0),
                           NRDOKREF    = ISNULL(NRFAT,''''),
                           KODAGJENT   = ISNULL(T.KODAGJENT_TMP,'''')
                      FROM '+@dbOrigjine+'..'+@DitarName+' LEFT JOIN #TableFatAgj T ON KOD=T.KLIENTMON_TMP AND NRFAT=T.NRFAT_TMP AND DTFAT=T.DTFAT_TMP
                     WHERE 1=1
                  GROUP BY KOD, ISNULL(KMON,''''), ISNULL(NRFAT,''''), ISNULL(DTFAT,0), ISNULL(T.KODAGJENT_TMP,'''') 
                    HAVING ABS(SUM(CASE WHEN TREGDK=''D'' THEN VLEFTA   ELSE 0-VLEFTA   END))>=0.01 OR  
                           ABS(SUM(CASE WHEN TREGDK=''D'' THEN VLEFTAMV ELSE 0-VLEFTAMV END))>=0.01 
                  ORDER BY KMON, KOD, KODAGJENT, DATEDOKREF, NRDOKREF; 
                  
                    UPDATE #CELJEMOD SET DATEDOKREF=NULL WHERE DATEDOKREF=0;';
             END;


          IF  @sWhere=''   --Genti Rasti kur vjen bosh dhe nuk i vinte kufizime.
              SET @sWhere = 'DATEDOK<=DBO.DATEVALUE('+QuoteName(@sDateCls,'''')+')' 

         SET  @Sql = REPLACE(@Sql,'1=1',@sWhere)



   RAISERROR ('2.  Gjenerimi i struktures temporare me te dhena  ', 0, 1,@DitarName) WITH NOWAIT;

    -- PRINT  @Sql;      
        EXEC (@Sql);

 
 
   RAISERROR ('3.  Plotesim i struktures temporare me te dhena te nevojeshme  ', 0, 1) WITH NOWAIT;

      UPDATE #CELJEMOD
         SET DB         = ROUND(CASE WHEN DB>=0 THEN   DB ELSE 0 END,3),
             KR         = ROUND(CASE WHEN DB<0  THEN 0-DB ELSE 0 END,3), 
             DBKRMV     = ROUND(DBKRMV,3),
             TREGDK     = CASE WHEN DB>=0 THEN 'D' ELSE 'K' END, 
             KODAF      = CASE WHEN CHARINDEX('.',KOD)>0 THEN SUBSTRING(KOD,1,CHARINDEX('.',KOD)-1) ELSE KOD END; 

      UPDATE #CELJEMOD
         SET LLOGARI    = KODAF, 
             LLOGARIPK  = KODAF, 
             KOMENT     = @Prompt, 
             KURS1      = 1,
             KURS2      = CASE WHEN KMON=''
                               THEN 1
                               ELSE ROUND(CASE WHEN TREGDK='D'
                                               THEN CASE WHEN DB = 0 THEN 1 ELSE     DBKRMV/DB END 
                                               ELSE CASE WHEN KR = 0 THEN 1 ELSE 0 - DBKRMV/KR END 
                                          END,3)
                          END,
             NRDITAR    = 0,
          -- TIPREF     = '',
          -- NRDOKREF   = '',
             OPERLLOJ   = '',
             OPERNR     = '',
             OPERAPL    = '',
             OPERORD    = 0,
             OPERNRFAT  = '',
             FADESTIN   = '',
             FAART      = '',
             ORDERSCR   = 0,
             TIPKLL     = @sModul, 
             TROW       = 0,
             TAGNR      = 0;


      UPDATE A
         SET A.PERSHKRIM = B.PERSHKRIM
        FROM #CELJEMOD A INNER JOIN Furnitor B ON B.KOD=A.KODAF 
       WHERE A.TIPKLL='F';

      UPDATE A
         SET A.PERSHKRIM = B.PERSHKRIM
        FROM #CELJEMOD A INNER JOIN Klient B   ON B.KOD=A.KODAF 
       WHERE A.TIPKLL='S';

      UPDATE A
         SET A.PERSHKRIM = B.PERSHKRIM
        FROM #CELJEMOD A INNER JOIN Arkat B    ON B.KOD=A.KODAF 
       WHERE A.TIPKLL='A';

      UPDATE A
         SET A.PERSHKRIM = B.PERSHKRIM 
        FROM #CELJEMOD A INNER JOIN Bankat B   ON B.KOD=A.KODAF 
       WHERE A.TIPKLL='B';


         SET @VlereDIF = ISNULL((SELECT ROUND(SUM(DBKRMV),3) FROM #CELJEMOD),0);


          IF ABS(@VlereDIF)>=0.01
             BEGIN

                 SET @LlgCelje = ISNULL((SELECT LLOGCEL FROM CONFIGLM),'');
                 SET @VlereDIF = 0 - @VlereDIF; 

              INSERT INTO #CELJEMOD (TAGNR) VALUES (0)
                 SET @NrD = @@IDENTITY

		      UPDATE #CELJEMOD
			     SET DB        = CASE WHEN @VlereDIF>=0 THEN   @VlereDIF ELSE 0   END, 
				     KR        = CASE WHEN @VlereDIF< 0 THEN 0-@VlereDIF ELSE 0   END, 
                     DBKRMV    = @VlereDIF,
				     TREGDK    = CASE WHEN @VlereDIF>=0 THEN   'D'       ELSE 'K' END,
				     KOD       = @LlgCelje+'....',
				     KODAF     = @LlgCelje,
				     LLOGARI   = @LlgCelje,
				     LLOGARIPK = @LlgCelje,
				     PERSHKRIM = (SELECT PERSHKRIM FROM LLOGARI WHERE KOD=@LlgCelje), 
				     KOMENT    = 'Llg. mbyllje - '+@Prompt, 
                     KMON      = '',
				     KURS1     = 1,
				     KURS2     = 1,
				     NRDITAR   = 0,
                     TIPREF    = '',
                     NRDOKREF  = '',
                     OPERLLOJ  = '',
                     OPERNR    = '',
                     OPERAPL   = '',
                     OPERORD   = 0,
                     OPERNRFAT = '',
                     FADESTIN  = '',
                     FAART     = '',
                     ORDERSCR  = 0,
				     TIPKLL    = 'T', 
				     TROW      = 0,
				     TAGNR     = 0
               WHERE NRRENDOR = @NrD

             END;



   RAISERROR ('4.1 Kalimi i dokumentit ne databaze  /dokumenti  ', 0, 1) WITH NOWAIT;

      UPDATE VS SET TAGNR=0 WHERE TAGNR<>0;


      INSERT INTO VS (TAGNR) VALUES (0)
         SET @NrD = @@IDENTITY

      UPDATE VS 
         SET NRDOK       = ISNULL((SELECT MAX(ISNULL(B.NRDOK,0)) 
                                     FROM VS B 
                                    WHERE YEAR(B.DATEDOK)=YEAR(DBO.DATEVALUE(@sDateDoc))),0) + 1,
             KODNENDITAR = '', 
             DATEDOK     = DBO.DATEVALUE(@sDateDoc),
             PERSHKRIM1  = @Prompt, 
             PERSHKRIM2  = '',
             KLASIFIKIM  = '',
             DST         = 'CE',
             KMON        = '',
             KURS1       = 1,
             KURS2       = 1,
             NRDFK       = 0,
             FIRSTDOK    = 'E'+CAST(CONVERT(BIGINT,NRRENDOR) AS VARCHAR),
             POSTIM      = 0,
             LETER       = 0,
             USI         = 'A', 
             USM         = 'A',
             TROW        = 0, 
             TAGNR       = 0 
       WHERE NRRENDOR = @NrD;

      UPDATE #CELJEMOD 
         SET NRD   = @NrD,
             KURS2 = CASE WHEN KURS2<=0 THEN 1 ELSE KURS2 END;



   RAISERROR ('4.2 Kalimi i dokumentit ne databaze  /detajet  ', 0, 1) WITH NOWAIT;

      SELECT @ListFields = dbo.Isd_ListFieldsTable('VSSCR','NRRENDOR');

      SELECT @Sql = '   

      INSERT INTO VSSCR 
            ('+@ListFields+') 
      SELECT '+@ListFields+'
        FROM #CELJEMOD 
    ORDER BY TIPKLL,KMON,KODAF,ISNULL(KODAGJENT,''''), ISNULL(DATEDOKREF,0), ISNULL(NRDOKREF,''''); ';

        EXEC (@Sql);



          IF OBJECT_ID('TEMPDB..#CELJEMOD') IS NOT NULL
             DROP TABLE #CELJEMOD; 
          IF OBJECT_ID('TEMPDB..#TableFatAgj') IS NOT NULL
             DROP TABLE #TableFatAgj;



   RAISERROR ('5.  Ndertimi i ditareve te dokumentit  ', 0, 1) WITH NOWAIT;

        EXEC dbo.Isd_GjenerimDitarOne 'VS',0,@NrD;



   RAISERROR ('6.  Perfundimi i importit te gjendjeve / [%s]  ', 0, 1,@DitarName) WITH NOWAIT;   

    
    
GO
