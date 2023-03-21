SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- EXEC Isd_ImportGjendjeArtikuj @pdbOrigjine='EHW19',@pTableTmp='FhScrTmp',@pKMag='PG1',@pTableDst='FH',@pDateImp='31.12.2019',
--                               @pWhere='',@pHaving='',@pGrupimArtDL=0,@pGrupimArtFar=0,@pGrupimArtBC=0,@pFieldCmim='',@pdbCmimeOrg=0,@pModAppend=0;
     
     
       
CREATE        Procedure [dbo].[Isd_ImportGjendjeArtikuj] 
( 


-- KUJDES  !!!!

-- Kjo procedure ka shume ngjashmeri me proceduren [Isd_ImportCeljeMg] prandaj 
-- cdo ndryshim ketu mund te pasqyrohet edhe tek procedura [Isd_ImportCeljeMg]


  @pDbOrigjine    Varchar(50),      
  @pTableTmp      Varchar(30),      
  @pKMag          Varchar(30),
  @pTableDst      Varchar(30),      -- dokumenti destinacion 
  @pDateImp       Varchar(20),
  @pWhere         Varchar(Max),
  @pHaving        Varchar(Max),
  @pGrupimArtDL   Int,              -- Grupim sipas dep/liste
  @pGrupimArtFar  Int,              -- Grupim sipas [Date skadence] / [Lot (Seri)] / [Rimbursim]
  @pGrupimArtBC   Int,              -- Grupim sipas barkod, -- Te pyeten Eriald,Genti,Altini per keto raste
  @pFieldCmim     Varchar(30),
  @pdbCmimeOrg    Int,
  @pModAppend     Int
                         
 )

AS

  
         SET NOCOUNT ON;
         
     DECLARE @dbOrigjine      Varchar(50),
             @KMag            Varchar(30),
             @sKMag           Varchar(30),
             @sTableDst       Varchar(30),
             @DateImp         Varchar(30),
             @TableTmp        Varchar(30),
             @FieldCmim       Varchar(30),
             @dbCmimeOrg      Int,
             @ListFields      Varchar(Max),
             @Sql1            Varchar(MAX),
             @Sql2            Varchar(MAX),
             @sWhere          Varchar(Max),
             @sHaving         Varchar(Max);
    
         SET @dbOrigjine    = CASE WHEN ISNULL(@pdbOrigjine,'')='' THEN '' ELSE @pdbOrigjine+'..' END;
         SET @TableTmp      = @pTableTmp;
         SET @KMag          = @pKMag;
         SET @sTableDst     = @pTableDst;
         SET @sKMag         = QuoteName(@KMag,'''');
         SET @DateImp       = @pDateImp;
         SET @FieldCmim     = @pFieldCmim;
         SET @sWhere        = ISNULL(@pWhere,'');
         SET @sHaving       = ISNULL(@pHaving,'');
         SET @dbCmimeOrg    = @pdbCmimeOrg;
    
    
   
          IF OBJECT_ID('TEMPDB..#ImportArtMg')    IS NOT NULL 
             DROP TABLE #ImportArtMg;
              
          IF OBJECT_ID('TEMPDB..#ImportArtMgTmp') IS NOT NULL 
             DROP TABLE #ImportArtMgTmp; 
             
      SELECT * 
        INTO #ImportArtMg 
        FROM FHSCR 
       WHERE 1>2; 

      SELECT * 
        INTO #ImportArtMgTmp
        FROM FHSCR 
       WHERE 1>2; 

       ALTER TABLE #ImportArtMg    ADD KMAG VARCHAR(20) NULL; 
       ALTER TABLE #ImportArtMgTmp ADD KMAG VARCHAR(20) NULL; 
       
       

   RAISERROR ('1.  Fillimm i importit te artikujve magazine  ', 0, 1) WITH NOWAIT;



      SELECT @Sql1  = '

   RAISERROR (''2.  Fillim i importit te artikujve jo amballazh '', 0, 1) WITH NOWAIT; 

      INSERT INTO  #ImportArtMg 
            (KMAG,KOD,KODAF,KARTLLG,BC,SASI,VLERAM) 
      SELECT KMAG   = '+@sKMag+',
             KOD    = '+@sKMag+'+''.''+KARTLLG+''...'',
             KODAF  = KARTLLG,
             KARTLLG,
             BC     = ISNULL(BARCOD,''''),
             SASIC  = SUM(SASIH -SASID), 
             VLERA  = SUM(VLERAH-VLERAD) 
        FROM '+@dbOrigjine+'LEVIZJEHD 
       WHERE 1=1 AND (KMAG<>(SELECT ISNULL(KMAGAMB,'''') FROM '+@dbOrigjine+'CONFIGMG))
    GROUP BY KARTLLG,ISNULL(BARCOD,'''') 
      HAVING 2=2 
    ORDER BY KARTLLG;';


                                                          -- Celje per magazinen Amballazh
      SELECT @Sql2  = '


   RAISERROR (''3.  Fillim i importit te artikujve amballazh '', 0, 1) WITH NOWAIT; 

      INSERT INTO  #ImportArtMg 
            (KMAG,KOD,KODAF,KARTLLG,BC,SASI,VLERAM,KODKLF,ISAMB) 
      SELECT KMAG   = '+@sKMag+',
             KOD    = '+@sKMag+'+''.''+KARTLLG+''...'',
             KODAF  = KARTLLG,
             KARTLLG,
             BC     = ISNULL(BARCOD,''''), 
             SASIC  = SUM(SASIH -SASID), 
             VLERA  = SUM(VLERAH-VLERAD),
             KODKLF = ISNULL(KODKLF,''''),
             ISAMB  = ISNULL(ISAMB,0) 
        FROM '+@dbOrigjine+'LEVIZJEHD 
       WHERE 1=1 AND (KMAG=(SELECT ISNULL(KMAGAMB,'''') FROM '+@dbOrigjine+'CONFIGMG))
    GROUP BY KARTLLG,ISNULL(KODKLF,''''),ISNULL(BARCOD,''''),ISNULL(ISAMB,0)
      HAVING 2=2 
    ORDER BY KARTLLG,KODKLF;';




          IF @pGrupimArtDL=1                               -- Analitik: Departament - Liste 
             BEGIN                                         -- ne kete rast mbushet me perpara tabela ImportArtMgTmp( u fut per aresye vonese)

                 SELECT @Sql1 = '

              RAISERROR (''2.1 Fillim i importit te artikujve jo amballazh sipas departament/liste  '', 0, 1) WITH NOWAIT; 

                 INSERT INTO  #ImportArtMgTmp 
                       (KMAG,KOD,KODAF,KARTLLG,BC,SASI,VLERAM) 
                 SELECT KMAG  = '+@sKMag+', 
                        KOD,
                        KODAF = '''',
                        
                     -- KOD   = '+@sKMag+'+''.''+KARTLLG+''.''+dbo.Isd_SegmentFind(KOD,0,4)+''.''+dbo.Isd_SegmentFind(KOD,0,3)+''.'',         -- vonon puna me segmentet
                     -- KODAF = KARTLLG + CASE WHEN dbo.Isd_SegmentFind(KOD,0,4)<>''''                                                        -- ne se heq komentet ndrysho dhe group by (hiq KOD)
                     --                        THEN ''.''+Dbo.Isd_SegmentFind(KOD,0,3)+''.''+dbo.Isd_SegmentFind(KOD,0,4)
                     --                        WHEN dbo.Isd_SegmentFind(KOD,0,3)<>''''
                     --                        THEN ''.''+Dbo.Isd_SegmentFind(KOD,0,3)
                     --                        ELSE ''''
                     --                   END,
                     
                        KARTLLG,
                        BC    = ISNULL(BARCOD,''''),
                        SASIC = SUM(SASIH -SASID), 
                        VLERA = SUM(VLERAH-VLERAD) 
                   FROM '+@dbOrigjine+'LEVIZJEHD 
                  WHERE 1=1 AND (KMAG<>(SELECT ISNULL(KMAGAMB,'''') FROM '+@dbOrigjine+'CONFIGMG))
               GROUP BY KOD,KARTLLG,ISNULL(BARCOD,'''')
                 HAVING 2=2 
               ORDER BY KOD;';



                     IF @pGrupimArtFar=1                   -- Me (Dateskadence dhe seri) edhe (Analitik: Departament - Liste)
                        BEGIN

                            SELECT @Sql1 = '

              RAISERROR (''2.1 Fillim i importit te artikujve jo amballazh sipas seri/skadence dhe departament/liste  '', 0, 1) WITH NOWAIT; 

                 INSERT INTO  #ImportArtMgTmp 
                       (KMAG,KOD,KODAF,KARTLLG,BC,SASI,VLERAM,DTSKADENCE,SERI) 
                 SELECT KMAG  = '+@sKMag+',
                        KOD,
                        KODAF = '''',
                         
                     -- KOD   = '+@sKMag+'+''.''+KARTLLG+''.''+dbo.Isd_SegmentFind(KOD,0,4)+''.''+dbo.Isd_SegmentFind(KOD,0,3)+''.'',         -- vonon puna me segmentet
                     -- KODAF = KARTLLG + CASE WHEN dbo.Isd_SegmentFind(KOD,0,4)<>''''                                                        -- ne se heq komentet ndrysho dhe group by (hiq KOD)
                     --                        THEN ''.''+Dbo.Isd_SegmentFind(KOD,0,3)+''.''+dbo.Isd_SegmentFind(KOD,0,4)
                     --                        WHEN dbo.Isd_SegmentFind(KOD,0,3)<>''''
                     --                        THEN ''.''+Dbo.Isd_SegmentFind(KOD,0,3)
                     --                        ELSE ''''
                     --                   END,
                     
                        KARTLLG,
                        BC    = ISNULL(BARCOD,''''), 
                        SASIC = SUM(SASIH -SASID), 
                        VLERA = SUM(VLERAH-VLERAD),
                        DTSKADENCE,
                        SERI  = ISNULL(SERI,'''') 
                   FROM '+@dbOrigjine+'LEVIZJEHD 
                  WHERE 1=1 AND (KMAG<>(SELECT ISNULL(KMAGAMB,'''') FROM '+@dbOrigjine+'CONFIGMG))
               GROUP BY KOD,KARTLLG,ISNULL(BARCOD,''''),DTSKADENCE,ISNULL(SERI,'''') 
                 HAVING 2=2 ;';

                        END;


              -- Shenim 1 - Kjo procedure u shtua sepse ndryshoi algoritmi per shkak vonese me Dep/liste

                 SELECT @Sql1 = @Sql1 + '
                 
              RAISERROR (''2.2 Ndertimi i kodit te artikujve jo amballazh sipas departament/liste  '', 0, 1) WITH NOWAIT; 

                 UPDATE #ImportArtMgTmp
                    SET KOD   = '+@sKMag+'+''.''+KARTLLG+''.''+dbo.Isd_SegmentFind(KOD,0,4)+''.''+dbo.Isd_SegmentFind(KOD,0,3)+''.'',
                        KODAF = KARTLLG + CASE WHEN dbo.Isd_SegmentFind(KOD,0,4)<>'''' 
                                               THEN ''.''+Dbo.Isd_SegmentFind(KOD,0,3)+''.''+dbo.Isd_SegmentFind(KOD,0,4)
                                               WHEN dbo.Isd_SegmentFind(KOD,0,3)<>''''
                                               THEN ''.''+Dbo.Isd_SegmentFind(KOD,0,3)
                                               ELSE ''''
                                          END;
                              
                                          
              RAISERROR (''2.3 Kalim ne strukture temporare te artikujve jo amballazh sipas departament/liste  '', 0, 1) WITH NOWAIT; 

                INSERT INTO  #ImportArtMg                          
                      (KMAG,KOD,KODAF,KARTLLG,BC,SASI,VLERAM,DTSKADENCE,SERI)
                      
                SELECT KMAG    = MAX(KMAG),
                       KOD     = MAX(KOD),
                       KODAF,
                       KARTLLG = MAX(KARTLLG),
                       BC,
                       SASI    = SUM(SASI),
                       VLERAM  = SUM(VLERAM),
                       DTSKADENCE,
                       SERI      
                  FROM #ImportArtMgTmp                                          
              GROUP BY KODAF,BC,DTSKADENCE,SERI
                 HAVING (ABS(SUM(SASI))>=0.01) OR (ABS(SUM(VLERAM))>=0.01)
              ORDER BY KOD,DTSKADENCE,SERI;';
              
             -- Fund Shenim 1 -  

             END;                                         -- Fund Analitik: Departament - Liste


            
                       
          IF @pGrupimArtFar=1 AND @pGrupimArtDL=0         -- Me (Dateskadence dhe seri) por jo (Analitik: Departament - Liste)
             BEGIN

                 SELECT @Sql1 = '

              RAISERROR (''2.  Fillim i importit te artikujve jo amballazh sipas seri/skadence  '', 0, 1) WITH NOWAIT; 

                 INSERT INTO  #ImportArtMg 
                       (KMAG,KOD,KODAF,KARTLLG,BC,SASI,VLERAM,DTSKADENCE,SERI) 
                 SELECT KMAG  = '+@sKMag+', 
                        KOD   = '+@sKMag+'+''.''+KARTLLG+''...'',
                        KODAF = KARTLLG,
                        KARTLLG,
                        BC    = ISNULL(BARCOD,''''),
                        SASIC = SUM(SASIH -SASID), 
                        VLERA = SUM(VLERAH-VLERAD),
                        DTSKADENCE,
                        SERI  = ISNULL(SERI,'''') 
                   FROM '+@dbOrigjine+'LEVIZJEHD 
                  WHERE 1=1 AND (KMAG<>(SELECT ISNULL(KMAGAMB,'''') FROM '+@dbOrigjine+'CONFIGMG))
               GROUP BY KARTLLG,ISNULL(BARCOD,''''),DTSKADENCE,ISNULL(SERI,'''') 
                 HAVING 2=2 
               ORDER BY KARTLLG,DTSKADENCE,SERI;';

             END;

 
        SET @Sql1 = @Sql1 + @Sql2;
        


          IF @sWhere=''     -- Genti: Rasti kur vjen bosh dhe nuk i vinte kufizime.
             SET @sWhere = 'DATEDOK<=DBO.DATEVALUE('+QuoteName(@DateImp,'''')+')'; 

         SET @Sql1 = REPLACE(@Sql1,'1=1',@sWhere);

          IF @sHaving=''
             SET @sHaving = '(ABS(SUM(SASIH -SASID))>=0.01) OR (ABS(SUM(VLERAH-VLERAD))>=0.01)';

         SET @Sql1 = REPLACE(@Sql1,'2=2',@sHaving);
         

          IF @pGrupimArtBC<>1
             BEGIN
               SET @Sql1 = REPLACE(@Sql1,',ISNULL(BARCOD,'''')','');
               SET @Sql1 = REPLACE(@Sql1,'= ISNULL(BARCOD,'''')','= ''''');
             END;
                      
    -- PRINT  @Sql1;
        EXEC (@Sql1);
       

                             
       
   RAISERROR ('4.  Plotesim detaje te importuara  ', 0, 1) WITH NOWAIT;
   
   
          IF @FieldCmim<>''
             BEGIN
                SET @Sql1 = '
                     UPDATE #ImportArtMg
                        SET CMIMM='+@FieldCmim+', VLERAM=SASI*'+@FieldCmim+'
                       FROM #ImportArtMg A INNER JOIN ARTIKUJ B ON A.KARTLLG=B.KOD;';
               if @dbCmimeOrg=1
                  SET @Sql1 = REPLACE(@Sql1,' ARTIKUJ ',' '+@dbOrigjine+'ARTIKUJ ');
                          
               EXEC (@Sql1);
             END;
             
             
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
             KOEFSHB      = B.KOEFSH,
             NJESINV      = B.NJESI, 
             BC           = ISNULL(B.BC,''), 
             CMIMSH       = B.CMSH,
             VLERASH      = ROUND(A.SASI*B.CMSH,3),
             TIPKTH       = '',
             FAKLS        = '',
             FADESTIN     = '',
             FASTATUS     = '',
             TIPFR        = '',
             SASIFR       = 0,
             VLERAFR      = 0,
             PROMOC       = 0,
             PROMOCTIP    = '',
             PROMOCKOD    = ISNULL(A.PROMOCKOD,''),
             RIMBURSIM    = ISNULL(A.RIMBURSIM,0),
             SERI         = ISNULL(A.SERI,''),
             DTSKADENCE   = CASE WHEN A.DTSKADENCE=0 OR (YEAR(A.DTSKADENCE)=1989 AND MONTH(A.DTSKADENCE)=12 AND DAY(A.DTSKADENCE)=1)
                                 THEN NULL
                                 ELSE A.DTSKADENCE
                            END,
                            
             KOEFICIENT   = 0,
             KONVERTART   = ROUND(CASE WHEN ISNULL(B.KONV2,1)*ISNULL(B.KONV1,1)<=0 THEN 1 ELSE ISNULL(B.KONV2,1)/ISNULL(B.KONV1,1) END,3),
          -- RIMBURSIM    = ISNULL(B.RIMBURSIM,0),    -- Jep gabim ????
             KLSART       = '',
             LLOGLM       = '',
             ORDERSCR     = 0,
             GJENROWAUT   = 0, 
             KOMENT       = 'Gjendje me '+@DateImp, 
             CMIMOR       = ROUND(CASE WHEN (SASI*VLERAM)>0 THEN VLERAM/SASI ELSE B.KOSTMES END,3), 
             VLERAOR      = ROUND(VLERAM,3),
             TIPKLL       = 'K', 
             NRD          = 0,
             TROW         = 0, 
             TAGNR        = 0  
        FROM #ImportArtMg A LEFT JOIN ARTIKUJ B ON A.KARTLLG=B.KOD; 
        
        

   RAISERROR ('5.  Kalimi ne baze i detajeve  ', 0, 1) WITH NOWAIT;

          SET @ListFields = '';
          
          IF @sTableDst='FH' OR @sTableDst='H'
             SELECT @ListFields = dbo.Isd_ListFields2Tables('FHSCR','FHSCR','NRRENDOR,TROW,TAGNR')
          ELSE   
          IF @sTableDst='FD' OR @sTableDst='D'
             SELECT @ListFields = dbo.Isd_ListFields2Tables('FHSCR','FDSCR','NRRENDOR,TROW,TAGNR')
          ELSE   
          IF @sTableDst='FJ' OR @sTableDst='S'
             SELECT @ListFields = dbo.Isd_ListFields2Tables('FHSCR','FJSCR','NRRENDOR,TROW,TAGNR')
          ELSE   
          IF @sTableDst='FF' OR @sTableDst='F'
             SELECT @ListFields = dbo.Isd_ListFields2Tables('FHSCR','FFSCR','NRRENDOR,TROW,TAGNR')
          ELSE   
          IF @sTableDst='FJT' 
             SELECT @ListFields = dbo.Isd_ListFields2Tables('FHSCR','FJTSCR','NRRENDOR,TROW,TAGNR')
          ELSE   
          IF @sTableDst='OFK' 
             SELECT @ListFields = dbo.Isd_ListFields2Tables('FHSCR','OFKSCR','NRRENDOR,TROW,TAGNR')
          ELSE   
          IF @sTableDst='ORK' 
             SELECT @ListFields = dbo.Isd_ListFields2Tables('FHSCR','ORKSCR','NRRENDOR,TROW,TAGNR')
          ELSE   
          IF @sTableDst='ORF' 
             SELECT @ListFields = dbo.Isd_ListFields2Tables('FHSCR','ORFSCR','NRRENDOR,TROW,TAGNR')
          ELSE   
          IF @sTableDst='SM' 
             SELECT @ListFields = dbo.Isd_ListFields2Tables('FHSCR','SMSCR','NRRENDOR,TROW,TAGNR');
      

      SELECT @Sql1 = '   
      INSERT INTO '+@TableTmp+' 
            ('+@ListFields+') 
      SELECT '+@ListFields+'
        FROM #ImportArtMg 
    ORDER BY KARTLLG,ISNULL(DTSKADENCE,0),ISNULL(SERI,''''); ';

    -- PRINT  @Sql1
        EXEC (@Sql1);
        
        

   RAISERROR ('6.  Perfundimi i importit te artikujve magazine ', 0, 1) WITH NOWAIT;


     -- EXEC ('SELECT * FROM '+@TableTmp+' ORDER BY KARTLLG');

          IF OBJECT_ID('TEMPDB..#ImportArtMg') IS NOT NULL 
             DROP TABLE #ImportArtMg; 

          IF OBJECT_ID('TEMPDB..#ImportArtMgTmp') IS NOT NULL 
             DROP TABLE #ImportArtMgTmp; 
  
         
GO
