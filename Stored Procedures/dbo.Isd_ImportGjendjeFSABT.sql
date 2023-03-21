SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE         procedure [dbo].[Isd_ImportGjendjeFSABT]
(

-- Kjo procedure ka mjaft ngjashmeri me proceduren [Isd_ImportCeljeFSAB] prandaj 
-- cdo ndryshim ketu mund te pasqyrohet edhe tek procedura [Isd_ImportCeljeFSAB]

-- Ketu behen sistemime, import gjendje per Arke,Banke,Klient, Furnitor dhe Liber te madh.


  @pNdName        Varchar(30),
  @pTableName     Varchar(30),
  @pTipDokument   Varchar(30), 
  @pTableTmp      Varchar(30),
  @pKoment        Varchar(200),
  @pWhereKod      Varchar(MAX),
  @pWhereGj       Varchar(MAX),
  @pAppendRows    Bit,
  @pInversVlere   Bit,
  @pInversPozic   Bit,
  @pAnalitik      Int  
)

AS

-- EXEC dbo.Isd_ImportGjendjeFSABT 'EHW19','VS','S','#AAAAA','Sistemim','','',1,0,0,1

         SET NOCOUNT ON;

     DECLARE @NdName          Varchar(30),
             @TableName       Varchar(30),
             @TipDokument     Varchar(30),
             @TableTmp        Varchar(30),
             @Koment          Varchar(200),
             @AppendRows      Bit,
             @InversVlere     Bit,
             @InversPozic     Bit,
             @Analitik        Int,
             
             @DitarName       Varchar(30),
             @TipFature       Varchar(10),
             @sSql            Varchar(MAX),
             @WhereKod        Varchar(MAX),
             @sHaving         Varchar(MAX);

         SET @NdName        = @pNdName;
         SET @TableName     = @pTableName;
         SET @TipDokument   = @pTipDokument;
         SET @TableTmp      = @pTableTmp;
         SET @Koment        = @pKoment;
         SET @WhereKod      = @pWhereKod;
         SET @sHaving       = @pWhereGj;
         SET @AppendRows    = @pAppendRows;
         SET @InversVlere   = @pInversVlere;
         SET @InversPozic   = @pInversPozic;
         SET @Analitik      = @pAnalitik;
         
         SET @sSql          = '';
         IF  @NdName<>''
             SET @NdName    = @NdName+'..';

         IF  @TipDokument='L'
             SET @TipDokument = 'T';

         SET @TipFature     = CASE WHEN @TipDokument = 'S' THEN 'FJ'
                                   WHEN @TipDokument = 'F' THEN 'FF'
                                   ELSE ''
                              END;      
                                           
         SET @DitarName     = CASE WHEN @TipDokument = 'S' THEN 'Kliente'
                                   WHEN @TipDokument = 'F' THEN 'Furnitore'
                                   WHEN @TipDokument = 'A' THEN 'Arke'
                                   WHEN @TipDokument = 'B' THEN 'Banke'
                                   WHEN @TipDokument = 'T' THEN 'LM'
                                   ELSE                          ''
                              END;      

          IF OBJECT_ID('TEMPDB..#CELJEMOD') IS NOT NULL
             DROP TABLE #CELJEMOD ;
                           
      SELECT * INTO #CELJEMOD FROM VSSCR WHERE 1>2 ;



   RAISERROR ('1.  Fillimi i importit te gjendjeve / [%s]  ', 0, 1,@DitarName) WITH NOWAIT;
   

                                 
         SET @Analitik =     CASE WHEN @Analitik<0 OR @Analitik>2 THEN 0 ELSE @Analitik END;
     
          IF @TipDokument = 'A' OR @TipDokument='B'
             SET @Analitik = 0

          ELSE   

          IF @TipDokument = 'F' OR @TipDokument='T'
             SET @Analitik = CASE WHEN @Analitik<0 OR @Analitik>1 THEN 0 ELSE @Analitik END

          ELSE

          IF @TipDokument = 'S'
             SET @Analitik = CASE WHEN @Analitik<0 OR @Analitik>2 THEN 0 ELSE @Analitik END;
             
          IF @sHaving=''
             BEGIN
               IF @TipDokument='T'
                  SET @sHaving = 'ABS(ROUND(SUM(B.DB - B.KR),2))>=0.01 OR ABS(ROUND(SUM(B.DBKRMV),2))>=0.01'
               ELSE
                  SET @sHaving = 'ABS(ROUND(SUM(CASE WHEN A.TREGDK=''D'' THEN A.VLEFTA ELSE 0-A.VLEFTA END),2))>=0.01 OR ABS(ROUND(SUM(CASE WHEN A.TREGDK=''D'' THEN A.VLEFTAMV ELSE 0-A.VLEFTAMV END),2))>=0.01';
             END             


          IF @TipDokument='T'
             GOTO LiberiMadh;


-- Rasti Ditaret S,F,A,B


          IF @Analitik=0 AND CHARINDEX(@TipDokument,'SFAB')>0              -- Kliente, Furnitore, Arke, Banke
             BEGIN
               SET  @sSql  = '
                    INSERT INTO #CELJEMOD 
                          (KOD,KMON,DB,DBKRMV,TIPREF,DATEDOKREF,NRDOKREF,KODAF,LLOGARI,LLOGARIPK,PERSHKRIM) 
                    SELECT A.KOD,
                           KMON        = ISNULL(A.KMON,''''),
                           VL          = ROUND(SUM(CASE WHEN A.TREGDK=''D'' THEN A.VLEFTA   ELSE 0-A.VLEFTA   END),3),
                           VLMV        = ROUND(SUM(CASE WHEN A.TREGDK=''D'' THEN A.VLEFTAMV ELSE 0-A.VLEFTAMV END),3),       
                           TIPREF      = '''',                                                                             -- Pse mos jene bosh ose null       12.01.2020 
                           DATEDOKREF  = NULL,                                                                             -- Pse mos jene 0 ose null          12.01.2020
                           NRDOKREF    = '''', 
                           KODAF       = CASE WHEN CHARINDEX(''.'',A.KOD)>0 THEN SUBSTRING(A.KOD,1,CHARINDEX(''.'',A.KOD)-1) ELSE A.KOD END,
                           LLOGARI     = CASE WHEN CHARINDEX(''.'',A.KOD)>0 THEN SUBSTRING(A.KOD,1,CHARINDEX(''.'',A.KOD)-1) ELSE A.KOD END,
                           LLOGARIPK   = CASE WHEN CHARINDEX(''.'',A.KOD)>0 THEN SUBSTRING(A.KOD,1,CHARINDEX(''.'',A.KOD)-1) ELSE A.KOD END,
                           PERSHKRIM   = MAX(ISNULL(R1.PERSHKRIM,A.PERSHKRIM))
                      FROM DKL A LEFT JOIN KLIENT R1 ON R1.KOD=CASE WHEN CHARINDEX(''.'',A.KOD)>0 THEN SUBSTRING(A.KOD,1,CHARINDEX(''.'',A.KOD)-1) ELSE A.KOD END
                     WHERE (1=1)
                  GROUP BY ISNULL(A.KMON,''''),A.KOD
                    HAVING (ISNULL(A.KOD,'''')<>'''' )
                            AND
                           (2=2)
                  ORDER BY KMON, KOD; ';

             END   

          ELSE
          
          IF @Analitik=1 AND CHARINDEX(@TipDokument,'SF')>0                -- Kliente, Furnitore
             BEGIN
               SET  @sSql  = ' 
                    INSERT INTO #CELJEMOD 
                          (KOD,KMON,DB,DBKRMV,TIPREF,DATEDOKREF,NRDOKREF,KODAF,LLOGARI,LLOGARIPK,PERSHKRIM) 
                    SELECT A.KOD, 
                           KMON        = ISNULL(A.KMON,''''),
                           VL          = ROUND(SUM(CASE WHEN   A.TREGDK=''D'' THEN   A.VLEFTA   ELSE 0-A.VLEFTA   END),3), 
                           VLMV        = ROUND(SUM(CASE WHEN   A.TREGDK=''D'' THEN   A.VLEFTAMV ELSE 0-A.VLEFTAMV END),3),
                           TIPREF      = '''+@TipFature+''',
                           DATEDOKREF  = A.DTFAT,
                           NRDOKREF    = ISNULL(A.NRFAT,''''),
                           KODAF       = CASE WHEN CHARINDEX(''.'',A.KOD)>0 THEN SUBSTRING(A.KOD,1,CHARINDEX(''.'',A.KOD)-1) ELSE A.KOD END,
                           LLOGARI     = CASE WHEN CHARINDEX(''.'',A.KOD)>0 THEN SUBSTRING(A.KOD,1,CHARINDEX(''.'',A.KOD)-1) ELSE A.KOD END,
                           LLOGARIPK   = CASE WHEN CHARINDEX(''.'',A.KOD)>0 THEN SUBSTRING(A.KOD,1,CHARINDEX(''.'',A.KOD)-1) ELSE A.KOD END,
                           PERSHKRIM   = MAX(ISNULL(R1.PERSHKRIM,A.PERSHKRIM))
                      FROM DKL A LEFT JOIN KLIENT R1 ON R1.KOD=CASE WHEN CHARINDEX(''.'',A.KOD)>0 THEN SUBSTRING(A.KOD,1,CHARINDEX(''.'',A.KOD)-1) ELSE A.KOD END 
                     WHERE (1=1)
                  GROUP BY A.KOD,ISNULL(A.KMON,''''),ISNULL(A.NRFAT,''''),A.DTFAT 
                    HAVING (ISNULL(A.KOD,'''')<>'''')
                            AND
                           (2=2)
                  ORDER BY KMON, KOD, A.DTFAT; '

             END
             
          ELSE
          
          IF @Analitik=2  AND CHARINDEX(@TipDokument,'S')>0                -- Kliente (Celje me gjendje sipas Fature dhe AgjentShitje)
             BEGIN
               SET  @sSql  = ' 
               
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
                      FROM FJ A
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
                      FROM VS A INNER JOIN VSSCR B ON A.NRRENDOR=B.NRD
                     WHERE B.TIPKLL=''S'' AND (NOT ( ISNULL(B.KODAGJENT,'''')='''' OR ISNULL(B.NRDOKREF,'''')='''' OR ISNULL(B.DATEDOKREF,0)=0 ))
                  GROUP BY B.LLOGARIPK,ISNULL(B.KMON,''''),ISNULL(B.KODAGJENT,''''),ISNULL(B.NRDOKREF,''''),ISNULL(B.DATEDOKREF,0)   
                  
                         ) A
                         
                  ORDER BY KLIENTMON_TMP,KODAGJENT_TMP,DTFAT_TMP,NRFAT_TMP; 
                  
                  

                    INSERT INTO #CELJEMOD 
                          (KOD,KMON,DB,DBKRMV,TIPREF,DATEDOKREF,NRDOKREF,KODAGJENT,KODAF,LLOGARI,LLOGARIPK,PERSHKRIM) 
                    SELECT A.KOD, 
                           KMON        = ISNULL(A.KMON,''''),
                           VL          = SUM(CASE WHEN   A.TREGDK=''D'' THEN   A.VLEFTA   ELSE 0-A.VLEFTA   END), 
                           VLMV        = SUM(CASE WHEN   A.TREGDK=''D'' THEN   A.VLEFTAMV ELSE 0-A.VLEFTAMV END),
                           TIPREF      = '''+@TipFature+''',
                           DATEDOKREF  = ISNULL(A.DTFAT,0),
                           NRDOKREF    = ISNULL(A.NRFAT,''''),
                           KODAGJENT   = ISNULL(T.KODAGJENT_TMP,''''),
                           KODAF       = CASE WHEN CHARINDEX(''.'',A.KOD)>0 THEN SUBSTRING(A.KOD,1,CHARINDEX(''.'',A.KOD)-1) ELSE A.KOD END,
                           LLOGARI     = CASE WHEN CHARINDEX(''.'',A.KOD)>0 THEN SUBSTRING(A.KOD,1,CHARINDEX(''.'',A.KOD)-1) ELSE A.KOD END,
                           LLOGARIPK   = CASE WHEN CHARINDEX(''.'',A.KOD)>0 THEN SUBSTRING(A.KOD,1,CHARINDEX(''.'',A.KOD)-1) ELSE A.KOD END,
                           PERSHKRIM   = MAX(ISNULL(R1.PERSHKRIM,A.PERSHKRIM))
                      FROM DKL A LEFT JOIN #TableFatAgj T  ON KOD=T.KLIENTMON_TMP AND NRFAT=T.NRFAT_TMP AND DTFAT=T.DTFAT_TMP
                                 LEFT JOIN KLIENT       R1 ON R1.KOD=CASE WHEN CHARINDEX(''.'',A.KOD)>0 THEN SUBSTRING(A.KOD,1,CHARINDEX(''.'',A.KOD)-1) ELSE A.KOD END 
                     WHERE (1=1)
                  GROUP BY A.KOD, ISNULL(A.KMON,''''), ISNULL(A.NRFAT,''''), ISNULL(A.DTFAT,0), ISNULL(T.KODAGJENT_TMP,'''') 
                    HAVING (ISNULL(A.KOD,'''')<>'''') 
                            AND
                           (2=2) 
                  ORDER BY KMON, KOD, KODAGJENT, DATEDOKREF, NRDOKREF; 
                  

                    UPDATE #CELJEMOD SET DATEDOKREF=NULL WHERE DATEDOKREF=0; ';             
             END;   



LiberiMadh:                                                     --  Rasti Ditar LM 


          IF @TipDokument='T' AND @Analitik=0                   --  Jo Analitik, (@Analitik=0) atehere referoju Llogari (Plan kontabel)
             BEGIN

               SET  @sSql  = '

                    INSERT INTO #CELJEMOD 
                          (KOD,KMON,DB,DBKRMV,LLOGARI,LLOGARIPK,PERSHKRIM)         -- TIPREF,DATEDOKREF,NRDOKREF,KODAF,
                    SELECT KOD         = B.LLOGARIPK+''....''+ISNULL(B.KMON,''''),
                           KMON        = ISNULL(B.KMON,''''),
                           GJENDJE     = ROUND(SUM(B.DB - B.KR),3),
                           GJENDJEMV   = ROUND(SUM(B.DBKRMV),3),
                        -- TIPREF      = '''',
                        -- DATEDOKREF  = NULL,
                        -- NRDOKREF    = '''',
                        -- KODAF       = B.LLOGARIPK,
                           LLOGARI     = B.LLOGARIPK+''....''+ISNULL(B.KMON,''''),
                           LLOGARIPK   = B.LLOGARIPK,
                           PERSHKRIM   = MAX(ISNULL(R1.PERSHKRIM,B.PERSHKRIM))
                      FROM FK A INNER JOIN FKSCR   B  ON A.NRRENDOR=B.NRD  
                                LEFT  JOIN LLOGARI R1 ON B.LLOGARIPK=R1.KOD
                     WHERE (1=1)
                  GROUP BY ISNULL(B.KMON,''''),B.LLOGARIPK
                    HAVING (ISNULL(B.LLOGARIPK+''....''+ISNULL(B.KMON,''''),'''')<>'''') AND 
                           (2=2) 
                  ORDER BY KMON, KOD;';

             END

          ELSE 
        
          IF @TipDokument='T' AND @Analitik=1                   --  Analitik: (@Analitik=1) atehere referoju LM per pershkrimin
             BEGIN

               SET  @sSql  = '

                    INSERT INTO #CELJEMOD 
                          (KOD,KMON,DB,DBKRMV,LLOGARI,LLOGARIPK,PERSHKRIM)                          -- TIPREF,DATEDOKREF,NRDOKREF,KODAF,
                    SELECT B.KOD,
                           KMON        = ISNULL(B.KMON,''''),                                       -- Kujdes rastet kur B.LLOGARI e mbushur keq prandaj nisemi nga fusha KOD
                           GJENDJE     = ROUND(SUM(B.DB - B.KR),3),
                           GJENDJEMV   = ROUND(SUM(B.DBKRMV),3),
                        -- TIPREF      = '''',
                        -- DATEDOKREF  = NULL,
                        -- NRDOKREF    = '''',
                        -- KODAF       = dbo.Isd_SegmentsToKodAF(B.KOD),                            -- B.LLOGARI, 
                           LLOGARI     = B.KOD,
                           LLOGARIPK   = CASE WHEN CHARINDEX(''.'',B.KOD)>0 THEN SUBSTRING(B.KOD,1,CHARINDEX(''.'',B.KOD)-1) ELSE B.KOD END,
                           PERSHKRIM   = MAX(ISNULL(R1.PERSHKRIM,B.PERSHKRIM))
                      FROM FK A INNER JOIN FKSCR B  ON A.NRRENDOR=B.NRD  
                                LEFT  JOIN LM    R1 ON B.KOD=R1.KOD
                     WHERE (1=1)
                  GROUP BY B.KMON,B.KOD,B.LLOGARI
                    HAVING (ISNULL(B.KOD,'''')<>'''') 
                            AND 
                           (2=2)
                  ORDER BY KMON, KOD;';
           
             END;



-- 2. Fshitje te tepertat

         SET @sSql  = @sSql  + ' 


                    DELETE 
                      FROM #CELJEMOD 
                     WHERE (ISNULL(KOD,'''')='''') OR
                           (ABS(ROUND(DB,3))<=0.01 AND ABS(ROUND(DBKRMV,3))<=0.01);';  -- (ABS(DB)>0   AND ABS(DB)<=1) OR (ABS(DBKRMV)>0 AND ABS(DBKRMV)<=1) */
       

          IF @WhereKod<>''
             BEGIN
               SET @sSql = Replace(@sSql,'(1=1)',@WhereKod);
             END;
          IF @sHaving<>''
             BEGIN
               SET @sSql = Replace(@sSql,'(2=2)',@sHaving);
             END;
             


-- 3. Lidhje me Ditarin qe importohet


          IF @TipDokument = 'S'
             BEGIN
               SET @sSql = Replace(@sSql,'KLIENT ',@NdName+'KLIENT ');
               SET @sSql = Replace(@sSql,'DKL ',   @NdName+'DKL ');
             END;
          IF @TipDokument = 'F'
             BEGIN
               SET @sSql = Replace(@sSql,'KLIENT ',@NdName+'FURNITOR ');
               SET @sSql = Replace(@sSql,'DKL ',   @NdName+'DFU ');
             END;
          IF @TipDokument = 'A'
             BEGIN
               SET @sSql = Replace(@sSql,'KLIENT ',@NdName+'ARKAT ');
               SET @sSql = Replace(@sSql,'DKL ',   @NdName+'DAR ');
             END;
          IF @TipDokument = 'B'
             BEGIN
               SET @sSql = Replace(@sSql,'KLIENT ',@NdName+'BANKAT ');
               SET @sSql = Replace(@sSql,'DKL ',   @NdName+'DBA ');
             END;
          IF @TipDokument = 'T'
             BEGIN
               SET @sSql = Replace(@sSql,' JOIN LLOGARI ',' JOIN '+@NdName+'LLOGARI ');
               SET @sSql = Replace(@sSql,' FKSCR ',  ' '+@NdName+'FKSCR ');
               SET @sSql = Replace(@sSql,' FK ',     ' '+@NdName+'FK ');
               SET @sSql = Replace(@sSql,' LM ',     ' '+@NdName+'LM ');
             END;


   RAISERROR ('2.  Gjenerimi i struktures temporare me te dhena  ', 0, 1,@DitarName) WITH NOWAIT;

   -- PRINT  @sSql;
       EXEC (@sSql);



   RAISERROR ('3.  Plotesim i struktures temporare me te dhena te nevojeshme  ', 0, 1) WITH NOWAIT;

      UPDATE #CELJEMOD
         SET DB          = CASE WHEN DB>=0 THEN   DB ELSE 0   END,
             KR          = CASE WHEN DB< 0 THEN 0-DB ELSE 0   END,
             DBKRMV      = DBKRMV,
             TREGDK      = CASE WHEN DB>=0 THEN  'D' ELSE 'K' END,
             KURS1       = 1,
             KURS2       = CASE WHEN ISNULL(KMON,'''')='''' THEN CAST(1 AS FLOAT)
                                WHEN DB*DBKRMV>0            THEN ROUND(DBKRMV/DB,4) 
                                ELSE                             CAST(1 AS FLOAT)
                           END,
             KOMENT      = @Koment,
             TIPKLL      = @TipDokument,
             ORDERSCR    = 0,
             NRDITAR     = 0;
        

          IF @InversPozic=1
             BEGIN
               UPDATE #CELJEMOD
                  SET KR=DB, DB=KR, DBKRMV=0-DBKRMV, TREGDK=CASE WHEN TREGDK='D' THEN 'K' ELSE 'D' END;
             END;

          IF @InversVlere=1
             BEGIN
               UPDATE #CELJEMOD
                  SET DB = 0-DB, KR = 0-KR, DBKRMV = 0-DBKRMV;
             END;


          IF @AppendRows=0
             BEGIN
               IF @TipDokument='A' OR @TipDokument='B'
                  EXEC (' DELETE FROM '+@TableTmp+' WHERE RRAB<>''K''; ')
               ELSE   
                  EXEC (' DELETE FROM '+@TableTmp+'; ');
             END;


         SET @sSql = '
         
      INSERT INTO '+@TableTmp+'
            (KOD,KODAF,LLOGARI,LLOGARIPK,KMON,PERSHKRIM,KOMENT,TIPKLL,DB,KR,DBKRMV,TREGDK,KURS1,KURS2,TIPREF,DATEDOKREF,NRDOKREF,ORDERSCR,KODAGJENT)
      SELECT KOD,KODAF,LLOGARI,LLOGARIPK,KMON,PERSHKRIM,KOMENT,TIPKLL,DB,KR,DBKRMV,TREGDK,KURS1,KURS2,TIPREF,DATEDOKREF,NRDOKREF,ORDERSCR,KODAGJENT
        FROM #CELJEMOD
    ORDER BY KMON,KOD;';
    
    
          IF @TableName='FK'   OR @TableName='FKST'
             BEGIN
               SET @sSql = Replace(@sSql,'KOD,KODAF,LLOGARI,','KOD,LLOGARI,');
               SET @sSql = Replace(@sSql,'TIPKLL,','');
               SET @sSql = Replace(@sSql,',TIPREF,DATEDOKREF,NRDOKREF','');
               SET @sSql = Replace(@sSql,',KODAGJENT','');
             END;
             

   RAISERROR ('4.  Kalimi i dokumentit ne databaze  /detajet  ', 0, 1) WITH NOWAIT;

   --  PRINT  @sSql;
        EXEC (@sSql);
        


          IF OBJECT_ID('TEMPDB..#CELJEMOD') IS NOT NULL
             DROP TABLE #CELJEMOD ;

   RAISERROR ('5.  Perfundimi i importit te gjendjeve / [%s]  ', 0, 1,@DitarName) WITH NOWAIT;   
GO
