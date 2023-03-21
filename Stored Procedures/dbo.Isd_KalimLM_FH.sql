SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- EXEC [Isd_KalimLM_FH] @pTip='A', @pNrRendor=0, @pSQLFilter='A.DATEDOK>=DBO.DATEVALUE(''01/01/2011'') AND A.DATEDOK<=DBO.DATEVALUE(''31/01/2011'')', @pTableNameTmp='##AAAA';

CREATE Procedure [dbo].[Isd_KalimLM_FH]
 (
  @pTip            Varchar(10),
  @pNrRendor       Int,              -- Nuk Perdoret
  @pSQLFilter      Varchar(5000),
  @pTableNameTmp   Varchar(40)
  )
AS

         SET NOCOUNT ON;



          IF @pTip<>'H'              -- FH 
             RETURN;
             
             

     DECLARE @TimeSt               DateTime,
             @TimeDi               Varchar(20),
             @TimeEn               Varchar(10),

             @DokName              Varchar(30),
             @Where                Varchar(5000),
             @LlogCelje            Varchar(30),
		     @LlogXhiruese         Varchar(30),
             @LlogAmbRjet          Varchar(30),
		     @FALlogGaranciKL      Varchar(30),
		     @FALlogGaranciART     Varchar(30),
             @KalimLMDepList       Bit,
             @KalimLMFA		       Bit,
             @ImplicidDepListRF    Bit,
             @ImplicidDepListART   Bit; 
         
         SET @TimeSt             = GETDATE();
         SET @TimeDi             = CONVERT(Varchar(10),@TimeSt,108);

         SET @DokName            = 'FH';
         SET @Where              = @pSQLFilter;
	     SET @KalimLMFA          = 0;

	  SELECT @LlogCelje          = ISNULL(LLOGCEL,''),
		     @LlogXhiruese       = ISNULL(LLOGXHMG,''),
             @LlogAmbRjet        = ISNULL(LLOGAMBRJET,''),
		     @FALlogGaranciKL    = ISNULL(FALLOGGARANCIKL,''),
		     @FALlogGaranciART   = ISNULL(FALLOGGARANCIART,''),
             @KalimLMDepList     = ISNULL(KALIMFHLMDEPLIST,''), 
             @ImplicidDepListRF  = ISNULL(FUDEPLISTNGAREF,0),
             @ImplicidDepListART = ISNULL(DEPLISTNGAART,0)  
	    FROM CONFIGLM; 

--    SELECT @KMagAmbRjet        = ISNULL(KMAGAMB,'') FROM CONFIGMG;

   RAISERROR (N'
Faza 1   Gjenerimi dokumentave FK nga %s.                                 %s', 0, 1, @DokName, @TimeDi) WITH NOWAIT;

               
          IF OBJECT_ID('TempDb..#FH') IS NOT NULL
             DROP TABLE #FH;

      SELECT NRRENDOR  = CAST(0 AS BIGINT),
             KOMENTLM1 = SHENIM1,
             PERSHKRIM = '',
             KMAG, 
             DOK_JB, 
             DST,
             KODLM, 
             LLOGARI   = KODLM,
             SEGMENT   = KODLM,
             SEGMENTMG = KODLM,
             DEPRF     = KODLM,
             LISTERF   = KODLM,
             DEPART    = KODLM,
             LISTEART  = KODLM 
        INTO #FH 
        FROM FH 
       WHERE 1=2;

		  IF EXISTS (SELECT Name FROM Sys.COLUMNS WHERE OBJECT_ID=OBJECT_ID('FHSCR') AND Name='FAKLS')
             SET @KalimLMFA = 1;



   RAISERROR (N'01.1     Krijim Koka FK', 0, 1) WITH NOWAIT;

         SET @Where = @Where+' AND (ISNULL(A.DST,'''')<>''TR'') ';
         
	 	EXEC ('
	  INSERT INTO #FH 
            (NRRENDOR,KOMENTLM1,PERSHKRIM,LLOGARI,KMAG,KODLM,DOK_JB,DST,SEGMENT,SEGMENTMG) 
      SELECT A.NRRENDOR,
             ISNULL(LEFT('''+@DokName+' nr ''+CONVERT(VARCHAR,CONVERT(BIGINT,A.NRDOK))+'' dt ''+CONVERT(VARCHAR,A.DATEDOK,4)+'',''+ISNULL(A.KMAG,''''),150),0),
             PERSHKRIM = '''',
             dbo.Isd_SegmentFind(ISNULL(A.KODLM,''''),0,1),
             A.KMAG, A.KODLM, A.DOK_JB, A.DST,
             CASE WHEN CHARINDEX(''.'',ISNULL(A.KODLM,''''))>0   
                  THEN Stuff(A.KODLM,1,CHARINDEX(''.'',ISNULL(A.KODLM,'''')),'''')
                  ELSE '''' 
             END,
             CASE WHEN '+@KalimLMDepList+'=0 
                  THEN ''''
                  ELSE CASE WHEN ISNULL(B.DEP,'''')<>'''' OR  ISNULL(B.LIST,'''')<>'''' THEN ISNULL(B.DEP,'''')+''.''+ISNULL(B.LIST,'''') ELSE '''' END 
             END
        FROM FH A LEFT JOIN MAGAZINA B ON A.KMAG=B.KOD 
       '+@Where);

          IF NOT EXISTS(SELECT 1 FROM #FH)
             BEGIN
               DROP TABLE #FH;
               RETURN;
             END;


          IF @ImplicidDepListRF=1
             BEGIN
               UPDATE A
                  SET A.DEPRF=R.DEP, A.LISTERF=R.LISTE
                 FROM #FH A INNER JOIN FF       B ON A.NRRENDOR=B.NRRENDDMG
                            INNER JOIN FURNITOR R ON B.KODFKL=R.KOD
                WHERE ISNULL(A.DOK_JB,0)=1
             END;

														-- Krijim FK
	  INSERT INTO #FK 
			(KODNENDITAR, NRDFK, NRDOK, DATEDOK, PERSHKRIM1, PERSHKRIM2,  
			 KMON, KURS1, KURS2, ORG, FIRSTDOK, TIPDOK, NUMDOK, REFERDOK, DST,  
			 KMAG, FORMAT, KLASIFIKIM, TAGNR)  
	  SELECT '',0,0,DATEDOK,	SHENIM1,B.KOMENTLM1,  
		     '', 1, 1, @pTip, FIRSTDOK, @DokName, NRDOK, A.KMAG,ISNULL(A.DST,''),
             A.KMAG,'','',A.NRRENDOR
		FROM FH A INNER JOIN #FH B ON A.NRRENDOR=B.NRRENDOR 
	ORDER BY DATEDOK,A.KMAG,NRDOK; 

       PRINT '01.2     Mbaroi Krijim Koka FK';



   RAISERROR (N'02.1     Llogari Inventar', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 
             
      SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0 THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                WHEN ISNULL(A1.SEGMENT,'')<>''           THEN ISNULL(A1.SEGMENT,'') 
                                ELSE                                          ISNULL(A1.SEGMENTMG,'') 
                           END,
			 LLOGARIPK   = CASE WHEN ISNULL(B.ISAMB,0)=1 THEN @LlogAmbRjet ELSE D.LLOGINV END,     -- D.LLOGINV,    -- Modifikimi per DILO-n 26.04.2017
			 PERSHKRIM   = '',  
			 KOMENT      = CASE WHEN CHARINDEX('.',ISNULL(A1.KODLM,''))>0  
				                THEN RIGHT(ISNULL(A1.KODLM,''),LEN(ISNULL(A1.KODLM,''))-CHARINDEX('',ISNULL(A1.KODLM,''))+1) 
				                ELSE '' 
                           END,
			 KMON        = '',
			 KURS1       = 1,
			 KURS2       = 1,
          -- TREGDK      = 'D', DB = VLERAM, KR = 0, DBKRMV = VLERAM, -- 21.05.2019 Per te pasur autoshkarkimet e prodhimit si flete dalje ...
             TREGDK      = CASE WHEN ISNULL(GJENROWAUT,0)=0 THEN 'D'    ELSE 'K'      END, 
			 DB          = CASE WHEN ISNULL(GJENROWAUT,0)=0 THEN VLERAM ELSE 0        END,
			 KR          = CASE WHEN ISNULL(GJENROWAUT,0)=0 THEN 0      ELSE 0-VLERAM END,
			 DBKRMV      = VLERAM,
             ORDPOST     = 0,
             KMAG,
			 MSGERROR    = A1.KOMENTLM1,                                                                                               -- Modifikimi per DILO-n 26.04.2017
             DSCERROR    = B.KODAF + CASE WHEN ISNULL(B.ISAMB,0)=1 THEN ': Amb.kthyeshem,Inventar' ELSE ': Llg.Artikuj,Inventar' END,  -- B.KODAF + ': Llog.Inventar',
             DEPRF       = A1.DEPRF,
             LISTERF     = A1.LISTERF,
             DEPART      = C.DEP,
             LISTEART    = C.LIST,
			 TAGNR       = A1.NRRENDOR 
        FROM #FH A1 LEFT JOIN FHSCR   B  ON A1.NRRENDOR=B.NRD 
					LEFT JOIN ARTIKUJ C  ON C.KOD=B.KARTLLG 
                    LEFT JOIN SKEMELM D  ON D.KOD=C.KODLM
	   WHERE A1.DOK_JB=1 OR (A1.DOK_JB=0 AND ISNULL(VLERAFR,0)=0 AND ISNULL(B.FAKLS,'')='')  
	ORDER BY A1.NRRENDOR;  

       PRINT '02.2     Mbaroi Llogari Inventar';



   RAISERROR (N'03.1     Llogari: Aplikacion FA', 0, 1) WITH NOWAIT; 

		  IF @KalimLMFA=1	
			 BEGIN
                 INSERT INTO #FKSCR1
                      (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
                       DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
                       DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 
                 SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0   THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                           WHEN ISNULL(A1.SEGMENT,'')<>''             THEN ISNULL(A1.SEGMENT,'') 
                                           ELSE                                            ISNULL(A1.SEGMENTMG,'') 
                                      END,
					    LLOGARIPK   = CASE WHEN B.FASTATUS='WIP'   THEN E.SKEMELMW
                                           WHEN B.FASTATUS='AKTIV' THEN E.SKEMELMA
                                           ELSE ISNULL(D.LLOGINV,'') 
                                      END, 
					    PERSHKRIM   = '',  
					    KOMENT      = CASE WHEN CHARINDEX('.',ISNULL(A1.KODLM,''))>0  
						                   THEN RIGHT(ISNULL(A1.KODLM,''),LEN(ISNULL(A1.KODLM,''))-CHARINDEX('',ISNULL(A1.KODLM,''))+1) 
						                   ELSE '' 
					                  END, 
					    KMON        = '',
					    KURS1       = 1,
					    KURS2       = 1, 
                        TREGDK      = 'D',
					    DB          = VLERAM ,
					    KR          = 0,
					    DBKRMV      = VLERAM,
                        ORDPOST     = 100,
                        KMAG,
					    MSGERROR    = A1.KOMENTLM1, 
					    DSCERROR    = B.KODAF + ': Llog.FA',
                        DEPRF       = A1.DEPRF,
                        LISTERF     = A1.LISTERF,
                        DEPART      = C.DEP,
                        LISTEART    = C.LIST,
					    TAGNR       = A1.NRRENDOR 
                   FROM #FH A1 LEFT JOIN FHSCR      B  ON A1.NRRENDOR=B.NRD 
						   	   LEFT JOIN ARTIKUJ    C  ON C.KOD=B.KARTLLG 
                               LEFT JOIN SKEMELM    D  ON D.KOD=C.KODLM
                               LEFT JOIN OBJEKTINST E  ON B.FAKLS=E.KOD
				  WHERE A1.DOK_JB=0 AND ISNULL(B.FAKLS,'')<>''  
			   ORDER BY A1.NRRENDOR;
             END;
             
       PRINT '03.2     Mbaroi Llogari: Aplikacion FA';



   RAISERROR (N'04.1     Llogari Kosto blerje', 0, 1) WITH NOWAIT

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 
      SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0 THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                WHEN ISNULL(A1.SEGMENT,'')<>''           THEN ISNULL(A1.SEGMENT,'') 
                                ELSE                                          ISNULL(A1.SEGMENTMG,'') 
                           END,
             LLOGARIPK   = CASE WHEN ISNULL(D.NDRGJEND,'')<>''           THEN D.NDRGJEND ELSE D.LLOGB END, 
			 PERSHKRIM   = '',  
			 KOMENT      = CASE WHEN CHARINDEX('.',ISNULL(A1.KODLM,''))>0  
				                THEN RIGHT(ISNULL(A1.KODLM,''),LEN(ISNULL(A1.KODLM,''))-CHARINDEX('',ISNULL(A1.KODLM,''))+1) 
				                ELSE '' 
			               END, 
			 KMON        = '',
			 KURS1       = 1,
			 KURS2       = 1, 
          -- TREGDK      = 'K', 0, VLERAM, 0-VLERAM,     -- 21.05.2019 Per te pasur autoshkarkimet e prodhimit si flete dalje ...
             TREGDK      = CASE WHEN ISNULL(GJENROWAUT,0)=0 THEN 'K'      ELSE 'D'      END,
			 DB          = CASE WHEN ISNULL(GJENROWAUT,0)=0 THEN 0        ELSE 0-VLERAM END,
			 KR          = CASE WHEN ISNULL(GJENROWAUT,0)=0 THEN   VLERAM ELSE 0        END,
			 DBKRMV      = 0-VLERAM,
             ORDPOST     = 1000,
             KMAG,
			 MSGERROR    = A1.KOMENTLM1,
             DSCERROR    = B.KODAF + ': Llog.Blerje',
             DEPRF       = A1.DEPRF,
             LISTERF     = A1.LISTERF,
             DEPART      = C.DEP,
             LISTEART    = C.LIST,
			 TAGNR       = A1.NRRENDOR 
        FROM #FH A1 LEFT JOIN FHSCR   B  ON A1.NRRENDOR=B.NRD 
			  	  	LEFT JOIN ARTIKUJ C  ON C.KOD=B.KARTLLG 
                    LEFT JOIN SKEMELM D  ON D.KOD=C.KODLM
	   WHERE A1.DOK_JB=1 AND ISNULL(B.ISAMB,0)=0   -- 04.05.2015  
	ORDER BY A1.NRRENDOR; 
 
       PRINT '04.2     Mbaroi Llogari Kosto blere';



   RAISERROR (N'04.3     Llogari Amballazh ne Rjet', 0, 1) WITH NOWAIT      -- 04.05.2015
          -- ne se nuk duhet ndarje amballazhi kthyeshem ne magazine hiq paragrafin 04.3 dhe komentin me siper me date 04.05.2015
      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 
      SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0 THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                WHEN ISNULL(A1.SEGMENT,'')<>''           THEN ISNULL(A1.SEGMENT,'') 
                                ELSE                                          ISNULL(A1.SEGMENTMG,'') 
                           END,  
             LLOGARIPK   = D.NDRGJEND,      -- CASE WHEN ISNULL(@LlogAmbRjet,'')<>'' THEN @LlogAmbRjet ELSE D.NDRGJEND END, 
			 PERSHKRIM   = '',  
			 KOMENT      = CASE WHEN CHARINDEX('.',ISNULL(A1.KODLM,''))>0  
				                THEN RIGHT(ISNULL(A1.KODLM,''),LEN(ISNULL(A1.KODLM,''))-CHARINDEX('',ISNULL(A1.KODLM,''))+1) 
				                ELSE '' 
			               END, 
			 KMON        = '',
			 KURS1       = 1,
			 KURS2       = 1, 
             TREGDK      = 'K',
			 DB          = 0,
			 KR          =   VLERAM ,
			 DBKRMV      = 0-VLERAM,
             ORDPOST     = 1000,
             KMAG,
			 MSGERROR    = A1.KOMENTLM1, 
			 DSCERROR    = B.KODAF + ': Amb.kthyeshem',
             DEPRF       = A1.DEPRF,
             LISTERF     = A1.LISTERF,
             DEPART      = C.DEP,
             LISTEART    = C.LIST,
			 TAGNR       = A1.NRRENDOR 
        FROM #FH A1 LEFT JOIN FHSCR   B  ON A1.NRRENDOR=B.NRD 
					LEFT JOIN ARTIKUJ C  ON C.KOD=B.KARTLLG 
                    LEFT JOIN SKEMELM D  ON D.KOD=C.KODLM
	   WHERE A1.DOK_JB=1 AND ISNULL(B.ISAMB,0)=1  
	ORDER BY A1.NRRENDOR; 
 
       PRINT '04.4     Mbaroi Llogari Amballazh';



   RAISERROR (N'05.1     Llogari Origjine', 0, 1) WITH NOWAIT;        -- brendeshem

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 
      SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0            THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                WHEN ISNULL(A1.SEGMENT,'')<>''                      THEN ISNULL(A1.SEGMENT,'') 
                                ELSE                                                     ISNULL(A1.SEGMENTMG,'') 
                           END,  
             LLOGARIPK   = CASE WHEN A1.DST='CE'                                    THEN @LlogCelje 
                                WHEN A1.DST='NV'                                    THEN @LlogXhiruese 
                                WHEN ISNULL(A1.DOK_JB,0)=0 AND ISNULL(B.ISAMB,0)=1  THEN D.LLOGINV
                                WHEN Dbo.Isd_SegmentFind(A1.KODLM,0,1)<>''          THEN Dbo.Isd_SegmentFind(A1.KODLM,0,1) 
                                ELSE                                                     ISNULL(D.NDRGJEND,'') 
                           END, 
          -- CASE WHEN A1.DST='CE'                                    THEN @LlogCelje              -- Modifikimi per DILO-n 26.04.2017
          --      WHEN A1.DST='NV'                                    THEN @LlogXhiruese 
          --      WHEN Dbo.Isd_SegmentFind(A1.KODLM,0,1)<>''          THEN Dbo.Isd_SegmentFind(A1.KODLM,0,1) 
          --      ELSE                                                     ISNULL(D.NDRGJEND,'') 
          -- END, 
			 PERSHKRIM   = '',  
			 KOMENT      = CASE WHEN CHARINDEX('.',ISNULL(A1.KODLM,''))>0  
				                THEN RIGHT(ISNULL(A1.KODLM,''),LEN(ISNULL(A1.KODLM,''))-CHARINDEX('',ISNULL(A1.KODLM,''))+1) 
				                ELSE '' 
			               END, 
			 KMON        = '',
			 KURS1       = 1,
			 KURS2       = 1, 
          -- TREGDK      = 'K', 0, VLERAM, 0-VLERAM,    -- 21.05.2019 Per te pasur autoshkarkimet e prodhimit si flete dalje ...
			 TREGDK      = CASE WHEN ISNULL(GJENROWAUT,0)=0 THEN 'K'      ELSE 'D'      END,
			 DB          = CASE WHEN ISNULL(GJENROWAUT,0)=0 THEN 0        ELSE 0-VLERAM END,
			 KR          = CASE WHEN ISNULL(GJENROWAUT,0)=0 THEN   VLERAM ELSE 0        END,
			 DBKRMV      = 0-VLERAM,
             ORDPOST     = 1200,
             KMAG,
			 MSGERROR    = A1.KOMENTLM1,                                                                                                                       -- Modifikimi per DILO-n 26.04.2017
             DSCERROR    = B.KODAF + CASE WHEN ISNULL(A1.DOK_JB,0)=0 AND ISNULL(B.ISAMB,0)=1 THEN ': Inventar,Amb.kthyeshem' ELSE ': Llg.Artikuj,LevBrend' END,-- B.KODAF + ': Llog.origjine', 
             DEPRF       = A1.DEPRF,
             LISTERF     = A1.LISTERF,
             DEPART      = C.DEP,
             LISTEART    = C.LIST,
			 TAGNR       = A1.NRRENDOR 
        FROM #FH A1 LEFT JOIN FHSCR   B  ON A1.NRRENDOR=B.NRD 
			   	  	LEFT JOIN ARTIKUJ C  ON C.KOD=B.KARTLLG 
                    LEFT JOIN SKEMELM D  ON D.KOD=C.KODLM
	   WHERE A1.DOK_JB=0 AND ISNULL(VLERAFR,0)=0 --ISNULL(TIPFR,'')=''  
	ORDER BY A1.NRRENDOR; 
 
       PRINT '05.2     Mbaroi Llogari Origjine';



   RAISERROR (N'06.1     Llogari Firo-Inventar', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 
      SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0  THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                WHEN ISNULL(A1.SEGMENT,'')<>''            THEN ISNULL(A1.SEGMENT,'') 
                                ELSE                                           ISNULL(A1.SEGMENTMG,'') 
                           END,  
			 LLOGARIPK   = D.LLOGINV, 
			 PERSHKRIM   = '',  
			 KOMENT      = CASE WHEN CHARINDEX('.',ISNULL(A1.KODLM,''))>0  
				                THEN RIGHT(ISNULL(A1.KODLM,''),LEN(ISNULL(A1.KODLM,''))-CHARINDEX('',ISNULL(A1.KODLM,''))+1) 
				                ELSE '' 
			               END, 
			 KMON        = '',
			 KURS1       = 1,
			 KURS2       = 1, 
             TREGDK      = 'K',
			 DB          = 0,
			 KR          = 0-VLERAFR ,
 			 DBKRMV      = VLERAFR,
             ORDPOST     = 4000,
             KMAG,
			 MSGERROR    = A1.KOMENTLM1, 
			 DSCERROR    = B.KODAF + ': Llog.Inventar-Firo',
             DEPRF       = A1.DEPRF,
             LISTERF     = A1.LISTERF,
             DEPART      = C.DEP,
             LISTEART    = C.LIST,
			 TAGNR       = A1.NRRENDOR 
        FROM #FH A1 LEFT JOIN FHSCR   B  ON A1.NRRENDOR=B.NRD 
					LEFT JOIN ARTIKUJ C  ON C.KOD=B.KARTLLG 
                    LEFT JOIN SKEMELM D  ON D.KOD=C.KODLM
	   WHERE A1.DOK_JB=0 AND ISNULL(VLERAFR,0)<>0 
	ORDER BY A1.NRRENDOR; 

       PRINT '06.2     Mbaroi Llogari Firo-Inventar';
 


   RAISERROR (N'06.3     Llogari Firo-Shpenzim', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 
      SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0  THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                WHEN ISNULL(A1.SEGMENT,'')<>''            THEN ISNULL(A1.SEGMENT,'') 
                                ELSE                                           ISNULL(A1.SEGMENTMG,'') 
                           END,  

          -- Aktiviteti tregetar ska firo te asnje klase, por kontabilizohet me ndryshim gjendje ....
          -- cdo artikull qe ska te percaktuar firo dhe eshte e tipit ''MB'',(MBeturina - tek FH,FD brendeshme) atehere kontabilizohet me ndryshim gjendje  							       
			 LLOGARIPK   = CASE WHEN ISNULL(DOK_JB,0)=0 AND A1.DST='MB' AND ISNULL(F.NRD,0)=0 THEN D.NDRGJEND
                                WHEN B.TIPFR='B' THEN LLOGARIB
                                WHEN B.TIPFR='C' THEN LLOGARIC
                                WHEN B.TIPFR='D' THEN LLOGARID
                                WHEN B.TIPFR='E' THEN LLOGARIE
                                WHEN B.TIPFR='F' THEN LLOGARIF
                                WHEN B.TIPFR='G' THEN LLOGARIG
                                WHEN B.TIPFR='H' THEN LLOGARIH
                                WHEN B.TIPFR='I' THEN LLOGARII
                                WHEN B.TIPFR='J' THEN LLOGARIJ
                                ELSE                  LLOGARIA 
                           END, 
			 PERSHKRIM   = '',  
			 KOMENT      = CASE WHEN CHARINDEX('.',ISNULL(A1.KODLM,''))>0  
				                THEN RIGHT(ISNULL(A1.KODLM,''),LEN(ISNULL(A1.KODLM,''))-CHARINDEX('',ISNULL(A1.KODLM,''))+1) 
				                ELSE '' 
			               END, 
			 KMON        = '',
			 KURS1       = 1,
			 KURS2       = 1, 
             TREGDK      = 'D',
			 DB          = 0-VLERAFR ,
			 KR	         = 0,
 			 DBKRMV      = 0-VLERAFR,
             ORDPOST     = 100,
             KMAG,
			 MSGERROR    = A1.KOMENTLM1, 
			 DSCERROR    = B.KODAF + ': Llog.Firo',
             DEPRF       = A1.DEPRF,
             LISTERF     = A1.LISTERF,
             DEPART      = C.DEP,
             LISTEART    = C.LIST,
			 TAGNR       = A1.NRRENDOR 
        FROM #FH A1 LEFT JOIN FHSCR      B ON A1.NRRENDOR=B.NRD 
					LEFT JOIN ARTIKUJ    C ON C.KOD=B.KARTLLG 
                    LEFT JOIN ARTIKUJFIR F ON C.NRRENDOR=F.NRD
                    LEFT JOIN SKEMELM    D ON D.KOD=C.KODLM
	   WHERE A1.DOK_JB=0 AND ISNULL(VLERAFR,0)<>0; 

       PRINT '06.4     Mbaroi Llogari Firo-Shpenzim';



   RAISERROR (N'07.1     Llogari Garanci FA-Klient', 0, 1) WITH NOWAIT;        ---- FA Model  Aplikacion FA 

		  IF (@KalimLMFA=1) AND (@FALlogGaranciKL<>'')				

             BEGIN
                 INSERT INTO #FKSCR1
                       (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
                        DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
                        DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 
                 SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0  THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                           WHEN ISNULL(A1.SEGMENT,'')<>''            THEN ISNULL(A1.SEGMENT,'') 
                                           ELSE                                           ISNULL(A1.SEGMENTMG,'') 
                                      END,  
						LLOGARIPK   = @FALlogGaranciKL, 
						PERSHKRIM   = '',  
						KOMENT      = CASE WHEN CHARINDEX('.',ISNULL(A1.KODLM,''))>0  
							               THEN RIGHT(ISNULL(A1.KODLM,''),LEN(ISNULL(A1.KODLM,''))-CHARINDEX('',ISNULL(A1.KODLM,''))+1) 
							               ELSE '' 
						              END, 
						KMON        = '',
						KURS1       = 1,
						KURS2       = 1, 
                        TREGDK      = 'K',
						DB          = 0,
						KR          = C.FAGARANCI,
 						DBKRMV      = 0-FAGARANCI,
                        ORDPOST     = 5000,
                        A1.KMAG,
						MSGERROR    = A1.KOMENTLM1, 
						DSCERROR    = B.KODAF + ': Llog.Garanci-Klient',
                        DEPRF       = A1.DEPRF,
                        LISTERF     = A1.LISTERF,
                        DEPART      = C.DEP,
                        LISTEART    = C.LIST,
						TAGNR       = A1.NRRENDOR 
                   FROM #FH A1 LEFT JOIN FHSCR   B ON A1.NRRENDOR=B.NRD 
						   	   LEFT JOIN ARTIKUJ C ON C.KOD=B.KARTLLG 
                               LEFT JOIN KLIENT  D ON D.KOD=B.FADESTIN
				  WHERE A1.DOK_JB=0 AND B.FADESTIN<>'' AND D.KOD<>'' 
			   ORDER BY A1.NRRENDOR;  

                  PRINT '07.2     Mbaroi Llogari Garanci FA-Klient';


              RAISERROR (N'07.3     Llogari Garanci FA-Artikuj', 0, 1) WITH NOWAIT;

                 INSERT INTO #FKSCR1
                       (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
                        DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
                        DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 
                 SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0  THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                           WHEN ISNULL(A1.SEGMENT,'')<>''            THEN ISNULL(A1.SEGMENT,'') 
                                           ELSE                                           ISNULL(A1.SEGMENTMG,'') 
                                      END,  
					    LLOGARIPK   = @FALlogGaranciART, 
					    PERSHKRIM   = '',  
					    KOMENT      = CASE WHEN CHARINDEX('.',ISNULL(A1.KODLM,''))>0  
						                   THEN RIGHT(ISNULL(A1.KODLM,''),LEN(ISNULL(A1.KODLM,''))-CHARINDEX('',ISNULL(A1.KODLM,''))+1) 
						                   ELSE '' 
					                  END, 
					    KMON        = '',
					    KURS1       = 1,
					    KURS2       = 1, 
                        TREGDK      = 'D',
					    DB          = C.FAGARANCI,
					    KR          = 0,
 					    DBKRMV      = FAGARANCI,
                        ORDPOST     = 6000,
                        A1.KMAG,
					    MSGERROR    = A1.KOMENTLM1, 
					    DSCERROR    = B.KODAF + ': Llog.Garanci-Artikuj',
                        DEPRF       = A1.DEPRF,
                        LISTERF     = A1.LISTERF,
                        DEPART      = C.DEP,
                        LISTEART    = C.LIST,
					    TAGNR       = A1.NRRENDOR 
                   FROM #FH A1 LEFT JOIN FHSCR   B ON A1.NRRENDOR=B.NRD 
						   	   LEFT JOIN ARTIKUJ C ON C.KOD=B.KARTLLG 
                               LEFT JOIN KLIENT  D ON D.KOD=B.FADESTIN
				  WHERE A1.DOK_JB=0 AND B.FADESTIN<>'' AND D.KOD<>''; 
		    -- ORDER BY A1.NRRENDOR  

                 UPDATE A  
                    SET A.PERSHKRIM=ISNULL(B.PERSHKRIM,'')+' - '+ISNULL(A.PERSHKRIM,'') 
                   FROM #FKSCR1 A INNER JOIN KLIENT B ON A.FADESTIN=B.KOD 
                  WHERE ISNULL(A.FADESTIN,'')<>'';

             END;

       PRINT '07.2     Mbaroi Llogari Garanci FA-Artikuj';



   RAISERROR (N'08.1     Modifikimi i fushes KOD tek Scr', 0, 1, @DokName) WITH NOWAIT;

      UPDATE #FKSCR1 
         SET KOD      = LLOGARIPK+'.'+dbo.Isd_SegmentFind(SEGMENT,0,1)+'.'+dbo.Isd_SegmentFind(SEGMENT,0,2)+'.'+KMAG+'.';

       PRINT '08.2     Mbaroi Modifikimi i fushes KOD tek Scr';


-- Kujdes Prioritetet 

   RAISERROR (N'09.1     Modifikim sipas skemes Dep/List tek Furnitor', 0, 1) WITH NOWAIT;

-- Pse mungon Dbo.Isd_SegmentFind(A.KOD,0,4) tek LLOGARI ...? 15.04.2016

          IF @ImplicidDepListRF=1 
             BEGIN
               UPDATE A 
                  SET KOD =     LLOGARIPK+'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(A.DEPRF,'')   END       
                                         +'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(A.LISTERF,'') END       
                                         +'.'+dbo.Isd_SegmentFind(A.KOD,0,4)
                                         +'.'+dbo.Isd_SegmentFind(A.KOD,0,5),
                      LLOGARI = dbo.Isd_SegmentsToKodAF(
                                LLOGARIPK+'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(A.DEPRF,'')   END       
                                         +'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(A.LISTERF,'') END)
                 FROM #FKSCR1 A 
                WHERE A.DEPRF<>'' OR A.LISTERF<>''               -- AND (Dbo.Isd_SegmentFind(SEGMENT,0,2)='') AND (Dbo.Isd_SegmentFind(SEGMENT,0,3)='')
                                                                 -- Rasti kur mjafton nje segment eshte hedhur me dore 
             END;
             
       PRINT '09.2     Mbaroi Modifikim sipas skemes Dep/List tek Furnitor';



   RAISERROR (N'10.1     Modifikim sipas skemes Dep/List tek Artikuj', 0, 1) WITH NOWAIT;

          IF @ImplicidDepListART=1                               -- Pse mungon Dbo.Isd_SegmentFind(A.KOD,0,4) tek LLOGARI ...? 15.04.2016
             BEGIN
               UPDATE A 
                  SET KOD     = LLOGARIPK+'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(A.DEPART,'')   END
                                         +'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(A.LISTEART,'') END       
                                         +'.'+dbo.Isd_SegmentFind(A.KOD,0,4)
                                         +'.'+dbo.Isd_SegmentFind(A.KOD,0,5),
                      LLOGARI = dbo.Isd_SegmentsToKodAF(
                                LLOGARIPK+'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(A.DEPART,'')   END       
                                         +'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(A.LISTEART,'') END)
                 FROM #FKSCR1 A 
                WHERE A.DEPART<>'' OR A.LISTEART<>''             -- AND (Dbo.Isd_SegmentFind(SEGMENT,0,2)='') AND (Dbo.Isd_SegmentFind(SEGMENT,0,3)='')
                                                                 -- Rasti kur mjafton nje segment eshte hedhur me dore 
             END;                                            

       PRINT '10.2     Mbaroi Modifikim sipas skemes Dep/List tek Artikuj';



          IF EXISTS (SELECT Name FROM TempDb.Sys.Tables WHERE OBJECT_ID=OBJECT_ID('TempDb..#FH'))
             DROP TABLE #FH;

         SET @TimeEn = CONVERT(Varchar(10),GETDATE(),108);
         SET @TimeDi = CONVERT(Varchar(10),DateAdd(Second,DATEDIFF(Second,@TimeSt,GETDATE()),'2001-01-01 00:00:00'),108);

   RAISERROR (N'Faza 1   Fund Gjenerimi dokumentave FK nga %s.                            %s   ', 0, 1, @DokName, @TimeEn, @TimeDi) WITH NOWAIT;



        EXEC [dbo].[Isd_KalimLMDbF] @pTip,@pNrRendor,@pTableNameTmp;   -- @pNrRendor Nuk Perdoret






GO
