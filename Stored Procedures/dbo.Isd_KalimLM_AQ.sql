SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- EXEC [Isd_KalimLM_AQ]  @pTip='X',@pNrRendor=0,@pSQLFilter='A.DATEDOK>=DBO.DATEVALUE(''01/01/2011'') AND A.DATEDOK<=DBO.DATEVALUE(''31/01/2011'')',@pTableNameTmp='##AAAA'


-- KODOPER='MM' u zevendesua me 'RK': Riparim Kapital 11.09.2020


/*   AQ Veprime me Aktivet  AQ    0
     BL Blerje              AQ01  1
     AM Amortizim           AQ02  2
     RK Riparim kapital     AQ03  3
     RV Rivleresim          AQ04  4  -- Rivleresim, Shtim ose pakesim aktivi
     SR Sherbime            AQ05  5  -- sherbime por qe vlera nuk hyn ne vleren e asetit
     SH Shitje              AQ06  6
     CE Celje               AQ07  7
     SI Sistemim            AQ08  8
     NP Nderrim Pronesie    AQ09  9
     JP Jashte perdorimi    AQ10 10  -- Jashte Perdorimit trajtohet njesoj si CRegjistrim
     CR CRegjistrim         AQ11 11   */
 

CREATE Procedure [dbo].[Isd_KalimLM_AQ]
 (
  @pTip          Varchar(10),
  @pNrRendor     Int,          -- Nuk Perdoret
  @pSQLFilter    Varchar(5000),
  @pTableNameTmp Varchar(40)
  )

AS


         SET NOCOUNT ON



          IF @pTip<>'X'             -- AQ
             RETURN;



     DECLARE @TimeSt                  DateTime,
             @TimeDi                  Varchar(20),
             @TimeEn                  Varchar(10),
             @sTip                    Varchar(10),
             
             @RIdKp                   BIGINT,
             @RIdKs                   BIGINT,
             @RIdMax                  BIGINT,
             @RIncNum                 BIGINT,
             @RCount                  BIGINT,

             @DokName                 Varchar(30),
             @sWhere                  Varchar(5000),
         --  @LlogCelje               Varchar(30),
             @KalimLMDepList          Bit,
         --  @ImplicidDepListRF       Bit,
             @ImplicidDepListAqKart   Bit;

         SET @TimeSt                = GETDATE();
         SET @TimeDi                = CONVERT(Varchar(10),@TimeSt,108);
         SET @sTip                  = @pTip;
          
         SET @DokName               = 'AQ';
         SET @sWhere                = @pSqlFilter;

	  SELECT @KalimLMDepList        = ISNULL(KALIMFDLMDEPLIST,''), 
	         @ImplicidDepListAqKart = ISNULL(DEPLISTNGAAQKART,0)
	      -- @LlogCelje             = ISNULL(LLOGCEL,''),
          -- @ImplicidDepListRF     = ISNULL(KLDEPLISTNGAREF,0),
	    FROM CONFIGLM;
	   

   RAISERROR (N'
Faza 1   Gjenerimi dokumentave FK nga %s.                                 %s', 0, 1, @DokName, @TimeDi) WITH NOWAIT



          IF OBJECT_ID('TempDb..#AQ') IS NOT NULL
             DROP TABLE #AQ;

      SELECT NRRENDOR  = CAST(0 AS BIGINT),
             KOMENTLM1 = SHENIM1,
             SHENIM1,
             PERSHKRIM = SHENIM1,
             KMAG      = ISNULL(KMAG,SPACE(10)), 
             DOK_JB, 
             DST,
             TIPFAT,
             KODLM, 
             LLOGARI   = KODLM,
             SEGMENT   = KODLM,
             SEGMENTMG = KODLM,
             DEPRF     = KODLM,
             LISTERF   = KODLM,
             DEPART    = KODLM,
             LISTEART  = KODLM,
             KURS1     = CAST(0 AS FLOAT),
             KURS2     = CAST(0 AS FLOAT),
             KMON      = SHENIM3,
             TAGNR
        INTO #AQ 
        FROM AQ 
       WHERE 1=2;


       PRINT '01.1     Krijim Koka FK';

--       SET @sWhere = @sWhere+' AND (ISNULL(A.DST,'''')<>''NP'') ';      -- A duhet postuar ato per levizje aktivu ...?
         
	    EXEC (' INSERT INTO #AQ 
                      (NRRENDOR,SHENIM1,KMAG,DOK_JB,DST,KODLM,SEGMENT,KMON,KURS1,KURS2, TAGNR) 
                SELECT A.NRRENDOR,
                       ISNULL(LEFT('''+@DokName+' nr ''+CONVERT(VARCHAR,CONVERT(BIGINT,A.NRDOK))+'' dt ''+CONVERT(VARCHAR,A.DATEDOK,4)+'',''+ISNULL(A.DST,''''),150),0),
                       ISNULL(A.KMAG,''''), A.DOK_JB, A.DST,A.KODLM,
                       CASE WHEN CHARINDEX(''.'',ISNULL(A.KODLM,''''))>0   
                            THEN Stuff(A.KODLM,1,CHARINDEX(''.'',ISNULL(A.KODLM,'''')),'''')
                            ELSE '''' 
                       END,
                       A.KMON,A.KURS1,A.KURS2, A.NRRENDOR
                  FROM AQ A 
                 '+@sWhere)
                 
          IF NOT EXISTS(SELECT * FROM #AQ)
             BEGIN
               DROP TABLE #AQ;
               
               RETURN
               
             END;



      CREATE INDEX AQ_Idx ON #AQ(NRRENDOR)

														-- Krijim FK

      INSERT INTO #FK 
			(KODNENDITAR, NRDFK, NRDOK, DATEDOK, PERSHKRIM1, PERSHKRIM2,  
             KMON, KURS1, KURS2, ORG, FIRSTDOK, TIPDOK, NUMDOK, REFERDOK, DST,  
             KMAG, FORMAT, KLASIFIKIM, TAGNR)  
      SELECT '',0,0,DATEDOK, A.SHENIM1,B.SHENIM1,  
             ISNULL(A.KMON,''), ISNULL(A.KURS1,1), ISNULL(A.KURS2,1), @sTip, FIRSTDOK, @DokName, NRDOK, 'AQ', ISNULL(A.DST,''),
             ISNULL(A.KMAG,''),'','',A.NRRENDOR
        FROM AQ A INNER JOIN #AQ B ON A.NRRENDOR=B.NRRENDOR 
    ORDER BY A.DATEDOK,A.DST,A.NRDOK,A.NRRENDOR; 
    
       PRINT       '01.2     Mbaroi Krijim Koka FK'



   RAISERROR (N'02.1.1   Llogari Blerje/Shitje faturim - 1', 0, 1) WITH NOWAIT

      INSERT INTO #FKSCR1                                                   
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 

      SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0 THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                ELSE                                          ISNULL(A1.SEGMENT,'') 
                           END, 
             LLOGARIPK   = CASE WHEN ISNULL(A1.TIPFAT,'') = 'F' OR CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',BL,RK,SR,')>0       THEN S.LLOGBL 
                                WHEN ISNULL(A1.TIPFAT,'') = 'S' OR ISNULL(B.KODOPER,'') = 'SH'                                  THEN S.LLOGSH 
                                ELSE ''
                           END, 
             PERSHKRIM   = '',  
			 KOMENT      = CASE WHEN CHARINDEX('.',ISNULL(A1.KODLM,''))>0  
				                THEN RIGHT(ISNULL(A1.KODLM,''),LEN(ISNULL(A1.KODLM,''))-CHARINDEX('',ISNULL(A1.KODLM,''))+1) 
				                ELSE '' 
			               END, 
			 KMON        = '',
			 KURS1       = 1,
			 KURS2       = 1, 
             TREGDK      = CASE WHEN  ISNULL(A1.TIPFAT,'') = 'F' OR CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',BL,RK,SR,')>0      THEN 'D' 
                                WHEN  ISNULL(A1.TIPFAT,'') = 'S' OR ISNULL(B.KODOPER,'') = 'SH'                                 THEN 'K'  
                                ELSE                                                                                                 'D'
                           END,
			 DB          = CASE WHEN (ISNULL(A1.TIPFAT,'') = 'F' OR CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',BL,RK,SR,')>0) AND 
			                          ISNULL(S.DITARKONTABBLERJE,0)=1                                                           THEN B.VLERABS 
                                WHEN  ISNULL(A1.TIPFAT,'') = 'S' OR ISNULL(B.KODOPER,'') = 'SH'                                 THEN 0 
                                ELSE                                                                                                 0
                           END,
			 KR          = CASE WHEN (ISNULL(A1.TIPFAT,'') = 'F' OR CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',BL,RK,SR,')>0)     THEN 0 
                                WHEN (ISNULL(A1.TIPFAT,'') = 'S' OR ISNULL(B.KODOPER,'') = 'SH') AND 
                                      ISNULL(S.DITARKONTABSHITJE,0)=1                                                           THEN B.VLERABS 
                                ELSE                                                                                                 0
                           END,
			 DBKRMV      = CASE WHEN (ISNULL(A1.TIPFAT,'') = 'F' OR CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',BL,RK,SR,')>0) AND 
			                          ISNULL(S.DITARKONTABBLERJE,0)=1                                                           THEN B.VLERABS 
                                WHEN (ISNULL(A1.TIPFAT,'') = 'S' OR ISNULL(B.KODOPER,'') = 'SH') AND
                                      ISNULL(S.DITARKONTABSHITJE,0)=1                                                           THEN 0-B.VLERABS 
                                ELSE                                                                                                 0
                           END,
             ORDPOST     = 10 + 
                           CASE WHEN  ISNULL(A1.TIPFAT,'') = 'F' OR CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',BL,RK,SR,')>0      THEN 0+ CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',RK,SR,')
                                WHEN  ISNULL(A1.TIPFAT,'') = 'S' OR ISNULL(B.KODOPER,'') = 'SH'                                 THEN 10 
                                ELSE                                                                                                 0
                           END, 
             A1.KMAG,
			 MSGERROR    = A1.KOMENTLM1, 
             DSCERROR    = B.KODAF + 
                           CASE WHEN  ISNULL(A1.TIPFAT,'') = 'F' OR CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',BL,RK,SR,')>0 THEN ': Llg.Aktiv,blerje'
                                WHEN  ISNULL(A1.TIPFAT,'') = 'S' OR ISNULL(B.KODOPER,'') = 'SH'                            THEN ': Llg.Aktiv,shitje'
                                ELSE                                                                                            '' 
                           END,
             DEPRF       = A1.DEPRF,
             LISTERF     = A1.LISTERF,
             DEPART      = K.DEP,
             LISTEART    = K.LIST,
			 TAGNR       = A1.NRRENDOR 
        FROM #AQ A1 LEFT JOIN AQSCR     B  ON A1.NRRENDOR=B.NRD 
			   	    LEFT JOIN AQKARTELA K  ON K.KOD=B.KARTLLG 
                    LEFT JOIN AQSKEMELM S  ON S.KOD=K.KODLM
       WHERE A1.DOK_JB=1 AND ISNULL(B.VLERABS,0)<>0;  

 
 
   RAISERROR (N'02.1.2   Llogari Blerje/Shitje faturim - 2', 0, 1) WITH NOWAIT

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 

      SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0  
                                THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                ELSE ISNULL(A1.SEGMENT,'') 
                           END, 
             LLOGARIPK   = CASE WHEN ISNULL(A1.TIPFAT,'') = 'F' OR CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',BL,RK,SR,')>0       THEN S.LLOGSHPBL 
                                WHEN ISNULL(A1.TIPFAT,'') = 'S' OR ISNULL(B.KODOPER,'') = 'SH'                                  THEN S.LLOGSH 
                                ELSE                                                                                                 ''
                           END, 
             PERSHKRIM   = '',  
			 KOMENT      = CASE WHEN CHARINDEX('.',ISNULL(A1.KODLM,''))>0  
				                THEN RIGHT(ISNULL(A1.KODLM,''),LEN(ISNULL(A1.KODLM,''))-CHARINDEX('',ISNULL(A1.KODLM,''))+1) 
				                ELSE '' 
			               END, 
			 KMON        = '',
			 KURS1       = 1,
			 KURS2       = 1, 
             TREGDK      = CASE WHEN  ISNULL(A1.TIPFAT,'') = 'F' OR CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',BL,RK,SR,')>0      THEN 'K' 
                                WHEN  ISNULL(A1.TIPFAT,'') = 'S' OR ISNULL(B.KODOPER,'') = 'SH'                                 THEN 'D' 
                                ELSE                                                                                                 'K'
                           END,
			 DB          = CASE WHEN  ISNULL(A1.TIPFAT,'') = 'F' OR CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',BL,RK,SR,')>0      THEN 0 
                                WHEN (ISNULL(A1.TIPFAT,'') = 'S' OR ISNULL(B.KODOPER,'') = 'SH') AND
                                      ISNULL(S.DITARKONTABSHITJE,0)=1                                                           THEN B.VLERABS 
                                ELSE                                                                                                 0
                           END, 
			 KR          = CASE WHEN (ISNULL(A1.TIPFAT,'') = 'F' OR CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',BL,RK,')>0)    AND   
			                          ISNULL(S.DITARKONTABBLERJE,0)=1                                                           THEN B.VLERABS 
                                WHEN  ISNULL(A1.TIPFAT,'') = 'S' OR ISNULL(B.KODOPER,'') = 'SH'                                 THEN 0
                                ELSE                                                                                                 0
                           END,
			 DBKRMV      = CASE WHEN (ISNULL(A1.TIPFAT,'') = 'F' OR CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',BL,RK,SR,')>0) AND 
			                          ISNULL(S.DITARKONTABBLERJE,0)=1                                                           THEN 0-B.VLERABS 
                                WHEN (ISNULL(A1.TIPFAT,'') = 'S' OR ISNULL(B.KODOPER,'') = 'SH') AND
                                      ISNULL(S.DITARKONTABSHITJE,0)=1                                                           THEN   B.VLERABS 
                                ELSE                                                                                            0
                           END, 
             ORDPOST     = 30 + 
                           CASE WHEN ISNULL(A1.TIPFAT,'') = 'F' OR CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',BL,RK,SR,')>0       THEN 0+CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',RK,SR,') 
                                WHEN ISNULL(A1.TIPFAT,'') = 'S' OR ISNULL(B.KODOPER,'') = 'SH'                                  THEN 10
                                ELSE                                                                                                 0
                           END,
             A1.KMAG,
			 MSGERROR    = A1.KOMENTLM1, 
             DSCERROR    = B.KODAF + 
                           CASE WHEN ISNULL(A1.TIPFAT,'') = 'F' OR CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',BL,RK,SR,')>0       THEN ': Llg.Aktiv,shp.zblerje'
                                WHEN ISNULL(A1.TIPFAT,'') = 'S' OR ISNULL(B.KODOPER,'') = 'SH'                                  THEN ': Llg.Aktiv,shitje'
                                ELSE '' 
                           END,
             DEPRF       = A1.DEPRF,
             LISTERF     = A1.LISTERF,
             DEPART      = K.DEP,
             LISTEART    = K.LIST,
			 TAGNR       = A1.NRRENDOR 
        FROM #AQ A1 LEFT JOIN AQSCR     B  ON A1.NRRENDOR=B.NRD 
			   	    LEFT JOIN AQKARTELA K  ON K.KOD=B.KARTLLG 
                    LEFT JOIN AQSKEMELM S  ON S.KOD=K.KODLM
       WHERE A1.DOK_JB=1 AND ISNULL(B.VLERABS,0)<>0;   -- AND (CHARINDEX(','+ISNULL(A1.TIPFAT,'')+',',',F,S,')>0 OR CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',BL,SH,')>0)
  --ORDER BY A1.NRRENDOR 

       PRINT       '02.1     Mbaroi Llogari Blerje/Shitje';

   

   RAISERROR (N'02.2.1   Llogari Levizje brendeshme Aktivi - debi', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 

      SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0  
                                THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                ELSE ISNULL(A1.SEGMENT,'') 
                           END, 
             LLOGARIPK   = CASE WHEN ISNULL(B.KODOPER,'') = 'CE' THEN S.LLOGBL                                     -- ISNULL(A1.DST,'')='CE' OR 
                                WHEN ISNULL(B.KODOPER,'') = 'BL' THEN S.LLOGBL
                                WHEN ISNULL(B.KODOPER,'') = 'RK' THEN S.LLOGBL                                     -- riparim kapital qe futet ne vleren e asetit
                                WHEN ISNULL(B.KODOPER,'') = 'RV' THEN S.LLOGBL                                     -- rivleresim  qe futet ne vleren e asetit
                                WHEN ISNULL(B.KODOPER,'') = 'SR' THEN S.LLOGBL                                     -- sherbim por qe nuk futet ne vleren e asetit
                                WHEN ISNULL(B.KODOPER,'') = 'SH' THEN S.LLOGSH  
                                WHEN ISNULL(B.KODOPER,'') = 'NP' THEN S.LLOGPRONESI                                -- ????                     
                                ELSE                                  ''
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
			 DB          = CASE WHEN ISNULL(B.KODOPER,'')='NP' THEN 0 ELSE 1 END 
			               * 
			               CASE WHEN ISNULL(B.KODOPER,'')='CE'                                     THEN ISNULL(B.VLERABS,0)+ISNULL(B.VLERAAM,0) 
			                 -- WHEN ISNULL(B.KODOPER,'')='CE' AND ISNULL(B.VLERAFAT,0)<>0         THEN ISNULL(B.VLERAFAT,0) 
			                    WHEN ISNULL(B.KODOPER,'')='BL' AND ISNULL(S.DITARKONTABBLERJE,0)=0 THEN 0
			                    WHEN ISNULL(B.KODOPER,'')='SH' AND ISNULL(S.DITARKONTABSHITJE,0)=0 THEN 0
			                    ELSE                                                                    VLERABS 
			               END,
			 KR          = 0,
			 DBKRMV      = CASE WHEN ISNULL(B.KODOPER,'')='NP' THEN 0 ELSE 1 END 
			               * 
			               CASE WHEN ISNULL(B.KODOPER,'')='CE'                                     THEN ISNULL(B.VLERABS,0)+ISNULL(B.VLERAAM,0)
			                 -- WHEN ISNULL(B.KODOPER,'')='CE' AND ISNULL(B.VLERAFAT,0)<>0         THEN ISNULL(B.VLERAFAT,0) 
			                    WHEN ISNULL(B.KODOPER,'')='BL' AND ISNULL(S.DITARKONTABBLERJE,0)=0 THEN 0
			                    WHEN ISNULL(B.KODOPER,'')='SH' AND ISNULL(S.DITARKONTABSHITJE,0)=0 THEN 0
			                    ELSE                                                                    VLERABS 
			               END,
             ORDPOST     = 100,
             A1.KMAG,
			 MSGERROR    = A1.KOMENTLM1, 
             DSCERROR    = B.KODAF + 
                           CASE WHEN ISNULL(B.KODOPER,'') = 'CE' THEN ': Llg.Aktiv,celje'                          -- ISNULL(A1.DST,'')='CE'
                                WHEN ISNULL(B.KODOPER,'') = 'BL' THEN ': Llg.Aktiv,blerje'
                                WHEN ISNULL(B.KODOPER,'') = 'RK' THEN ': Llg.Aktiv,riparim kapital'  
                                WHEN ISNULL(B.KODOPER,'') = 'RV' THEN ': Llg.Rivleresim'  
                                WHEN ISNULL(B.KODOPER,'') = 'SR' THEN ': Llg.Aktiv,sherbim'  
                                WHEN ISNULL(B.KODOPER,'') = 'SH' THEN ': Llg.Aktiv,shitje'  
                                WHEN ISNULL(B.KODOPER,'') = 'NP' THEN ': Ndrim pronesi'
                                ELSE                                  '' 
                           END,
             DEPRF       = A1.DEPRF,
             LISTERF     = A1.LISTERF,
             DEPART      = K.DEP,
             LISTEART    = K.LIST,
			 TAGNR       = A1.NRRENDOR 
        FROM #AQ A1 LEFT JOIN AQSCR     B  ON A1.NRRENDOR=B.NRD 
			   	    LEFT JOIN AQKARTELA K  ON K.KOD=B.KARTLLG 
                    LEFT JOIN AQSKEMELM S  ON S.KOD=K.KODLM
       WHERE A1.DOK_JB=0 AND ISNULL(A1.DST,'')<>'AM' AND 
           ((B.KODOPER<>'CE' AND ISNULL(B.VLERABS,0)<>0) OR (B.KODOPER='CE' AND (ISNULL(B.VLERABS,0)+ISNULL(B.VLERAAM,0)<>0))) AND 
             CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',CE,BL,RK,RV,SR,SH,NP,')>0
          -- ISNULL(B.KODOPER,'')<>'AM' AND ISNULL(B.KODOPER,'')<>'CR';  
  --ORDER BY A1.NRRENDOR 
  --SELECT * FROM #FKSCR1  
  
  
   RAISERROR (N'02.2.2   Llogari Levizje brendeshme Aktivi - kredi', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 

      SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0  
                                THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                ELSE ISNULL(A1.SEGMENT,'') 
                           END, 
             LLOGARIPK   = CASE WHEN Dbo.Isd_SegmentFind(A1.KODLM,0,1)<>'' THEN Dbo.Isd_SegmentFind(A1.KODLM,0,1)  -- llogari ne dokument
                                WHEN ISNULL(B.KODOPER,'') = 'CE'           THEN S.LLOGCEVL                         -- ose @LlogCelje  -- ISNULL(A1.DST,'')='CE'
                                WHEN ISNULL(B.KODOPER,'') = 'BL'           THEN S.LLOGBL
                                WHEN ISNULL(B.KODOPER,'') = 'RK'           THEN S.LLOGSHPBL                        -- ose riparim kapital
                                WHEN ISNULL(B.KODOPER,'') = 'RV'           THEN CASE WHEN VLERABS>=0               -- ose rivleresim por vlefta futet ne vleren e asetit
                                                                                     THEN S.LLOGPLUSVLERA 
                                                                                     ELSE S.LLOGMINUSVLERA 
                                                                                END
                                WHEN ISNULL(B.KODOPER,'') = 'SR'           THEN S.LLOGSHPBL                        -- ose sherbim por jo vlefte ne vleren e asetit
                                WHEN ISNULL(B.KODOPER,'') = 'SH'           THEN S.LLOGSH  
                                WHEN ISNULL(B.KODOPER,'') = 'NP'           THEN S.LLOGPRONESI                      -- Ndrim pronesi
                                ELSE                                            ''
                           END, 
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
			 KR          =   CASE WHEN ISNULL(B.KODOPER,'')='NP' THEN 0 ELSE 1 END 
			                 *    
			                 CASE WHEN ISNULL(B.KODOPER,'')='CE'                                     THEN ISNULL(B.VLERABS,0)
			                   -- WHEN ISNULL(B.KODOPER,'')='CE' AND ISNULL(B.VLERAFAT,0)<>0         THEN ISNULL(B.VLERAFAT,0)
			                      WHEN ISNULL(B.KODOPER,'')='BL' AND ISNULL(S.DITARKONTABBLERJE,0)=0 THEN 0
			                      WHEN ISNULL(B.KODOPER,'')='SH' AND ISNULL(S.DITARKONTABSHITJE,0)=0 THEN 0 
			                      ELSE                                                                    VLERABS 
			                 END,
			 DBKRMV      =   CASE WHEN ISNULL(B.KODOPER,'')='NP' THEN 0 ELSE 1 END 
			                 * 
			              (0-CASE WHEN ISNULL(B.KODOPER,'')='CE'                                     THEN ISNULL(B.VLERABS,0) 
			                   -- WHEN ISNULL(B.KODOPER,'')='CE' AND ISNULL(B.VLERAFAT,0)<>0         THEN ISNULL(B.VLERAFAT,0) 
			                      WHEN ISNULL(B.KODOPER,'')='BL' AND ISNULL(S.DITARKONTABBLERJE,0)=0 THEN 0
			                      WHEN ISNULL(B.KODOPER,'')='SH' AND ISNULL(S.DITARKONTABSHITJE,0)=0 THEN 0
			                      ELSE                                                                    VLERABS 
			                 END),
             ORDPOST     = 110,
             A1.KMAG,
			 MSGERROR    = A1.KOMENTLM1, 
             DSCERROR    = B.KODAF + 
                           CASE WHEN ISNULL(B.KODOPER,'') = 'CE' THEN ': Llg.Aktiv,celje'                          -- ISNULL(A1.DST,'')='CE'
                                WHEN ISNULL(B.KODOPER,'') = 'BL' THEN ': Llg.Aktiv,blerje'
                                WHEN ISNULL(B.KODOPER,'') = 'RK' THEN ': Llg.Aktiv,riparim kapital'  
                                WHEN ISNULL(B.KODOPER,'') = 'RV' THEN ': Llg.Rivleresim'  
                                WHEN ISNULL(B.KODOPER,'') = 'SR' THEN ': Llg.Aktiv,sherbim'  
                                WHEN ISNULL(B.KODOPER,'') = 'SH' THEN ': Llg.Aktiv,shitje'  
                                WHEN ISNULL(B.KODOPER,'') = 'NP' THEN ': Ndrim pronesi'
                                ELSE '' 
                           END,
             DEPRF       = A1.DEPRF,
             LISTERF     = A1.LISTERF,
             DEPART      = K.DEP,
             LISTEART    = K.LIST,
			 TAGNR       = A1.NRRENDOR 
        FROM #AQ A1 LEFT JOIN AQSCR     B  ON A1.NRRENDOR=B.NRD 
			   	    LEFT JOIN AQKARTELA K  ON K.KOD=B.KARTLLG 
                    LEFT JOIN AQSKEMELM S  ON S.KOD=K.KODLM
       WHERE A1.DOK_JB=0 AND ISNULL(B.VLERABS,0)<>0 AND ISNULL(A1.DST,'')<>'AM' AND CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',CE,BL,RK,RV,SR,SH,NP,')>0
          -- ISNULL(B.KODOPER,'')<>'AM' AND ISNULL(B.KODOPER,'')<>'CR';  
  --ORDER BY A1.NRRENDOR 
    
       PRINT   '02.2     Mbaroi Levizje brendeshme Aktivi ';

-- SELECT * FROM #FKSCR1;

   RAISERROR (N'02.3.1   Llogari Levizje brendeshme Amortizimi - debi', 0, 1) WITH NOWAIT
  
      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 

      SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0  
                                THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                               ELSE ISNULL(A1.SEGMENT,'') 
                           END,  
             LLOGARIPK   = CASE WHEN Dbo.Isd_SegmentFind(A1.KODLM,0,1)<>'' THEN Dbo.Isd_SegmentFind(A1.KODLM,0,1)  -- llogari ne dokument
                             -- WHEN ISNULL(B.KODOPER,'') = 'CE'           THEN S.LLOGCEAM                         -- ISNULL(A1.DST,'')='CE'  
                                WHEN ISNULL(B.KODOPER,'') = 'AM'           THEN S.LLOGSHPAM
                                WHEN ISNULL(B.KODOPER,'') = 'SI'           THEN S.LLOGSHPAM                        -- Stornim ose sistemim 
                             -- WHEN ISNULL(B.KODOPER,'') = 'JP'           THEN S.LLOGSHPAM                        -- Jashte Perdorimi
                             -- WHEN ISNULL(B.KODOPER,'') = 'CR'           THEN S.LLOGAM                           -- CRegjistrim
                                ELSE                                            ''
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
			 DB          = B.VLERAAM,
			 KR          = 0,
			 DBKRMV      = B.VLERAAM,
             ORDPOST     = 1020,
             A1.KMAG,
			 MSGERROR    = A1.KOMENTLM1, 
             DSCERROR    = B.KODAF + 
                           CASE 
                             -- WHEN ISNULL(B.KODOPER,'') = 'CE' THEN ': Celje amorizimi'                          -- ISNULL(A1.DST,'')='CE'
                                WHEN ISNULL(B.KODOPER,'') = 'AM' THEN ': Shpenzim amortizim'
                                WHEN ISNULL(B.KODOPER,'') = 'SI' THEN ': Sistemim shpenzim amortizimi'
                             -- WHEN ISNULL(B.KODOPER,'') = 'JP' THEN ': Jashte perdorimi' 
                             -- WHEN ISNULL(B.KODOPER,'') = 'CR' THEN ': CRegjistrim'                              -- [Vlere Blerje] - [Vlere Anortizim Cumuluar]
                                ELSE                                  '' 
                           END,
             DEPRF       = A1.DEPRF,
             LISTERF     = A1.LISTERF,
             DEPART      = K.DEP,
             LISTEART    = K.LIST,
			 TAGNR       = A1.NRRENDOR 
        FROM #AQ A1 LEFT JOIN AQSCR     B  ON A1.NRRENDOR=B.NRD 
			   	    LEFT JOIN AQKARTELA K  ON K.KOD=B.KARTLLG 
                    LEFT JOIN AQSKEMELM S  ON S.KOD=K.KODLM
       WHERE A1.DOK_JB=0 AND ISNULL(B.VLERAAM,0)<>0 AND CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',AM,SI,')>0;   -- ',CE,AM,SI,'
  --ORDER BY A1.NRRENDOR 



   RAISERROR (N'02.3.2   Llogari Levizje brendeshme Amortizimi - kredi', 0, 1) WITH NOWAIT
   
      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 

      SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0  
                                THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                ELSE ISNULL(A1.SEGMENT,'') 
                           END,  
             LLOGARIPK   = CASE WHEN ISNULL(B.KODOPER,'') = 'CE'           THEN S.LLOGAM -- @LlogCelje             -- ISNULL(A1.DST,'')='CE'
                                WHEN ISNULL(B.KODOPER,'') = 'AM'           THEN S.LLOGAM
                                WHEN ISNULL(B.KODOPER,'') = 'SI'           THEN S.LLOGAM  
                             -- WHEN ISNULL(B.KODOPER,'') = 'JP'           THEN S.LLOGAM  
                             -- WHEN ISNULL(B.KODOPER,'') = 'CR'           THEN S.LLOGBL
                                ELSE                                            ''
                           END, 
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
			 KR          =   B.VLERAAM,
			 DBKRMV      = 0-B.VLERAAM,
             ORDPOST     = 1010,
             A1.KMAG,
			 MSGERROR    = A1.KOMENTLM1, 
             DSCERROR    = B.KODAF + 
                           CASE WHEN ISNULL(B.KODOPER,'') = 'CE' THEN ': Celje amortizim'                          -- ISNULL(A1.DST,'')='CE'
                                WHEN ISNULL(B.KODOPER,'') = 'AM' THEN ': Amortizim'
                                WHEN ISNULL(B.KODOPER,'') = 'SI' THEN ': Sistemim amortizim'  
                             -- WHEN ISNULL(B.KODOPER,'') = 'JP' THEN ': Jashte perdorimi'  
                             -- WHEN ISNULL(B.KODOPER,'') = 'CR' THEN ': CRegjistrim - Blerje'                     -- per [Vlere Blerje]
                                ELSE                                  '' 
                           END,
             DEPRF       = A1.DEPRF,
             LISTERF     = A1.LISTERF,
             DEPART      = K.DEP,
             LISTEART    = K.LIST,
			 TAGNR       = A1.NRRENDOR 
        FROM #AQ A1 LEFT JOIN AQSCR     B  ON A1.NRRENDOR=B.NRD 
			   	    LEFT JOIN AQKARTELA K  ON K.KOD=B.KARTLLG 
                    LEFT JOIN AQSKEMELM S  ON S.KOD=K.KODLM
       WHERE A1.DOK_JB=0 AND ISNULL(B.VLERAAM,0)<>0 AND CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',CE,AM,SI,')>0;  
  --ORDER BY A1.NRRENDOR 
    
        PRINT       '02.3     Mbaroi levizje brendeshme Amortizimi '



   RAISERROR (N'02.4.1   Llogari Levizje brendeshme CRegjistrimi: [Vlere Amortizim Cumuluar] - debi', 0, 1) WITH NOWAIT
  
      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 

      SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0  
                                THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                ELSE ISNULL(A1.SEGMENT,'') 
                           END, 
             LLOGARIPK   = S.LLOGAM,                           -- CRegjistrimi
                          
             PERSHKRIM   = '',  
			 KOMENT      = CASE WHEN CHARINDEX('.',ISNULL(A1.KODLM,''))>0  
				                THEN RIGHT(ISNULL(A1.KODLM,''),LEN(ISNULL(A1.KODLM,''))-CHARINDEX('',ISNULL(A1.KODLM,''))+1) 
				                ELSE '' 
			               END, 
			 KMON        = '',
			 KURS1       = 1,
			 KURS2       = 1, 
             TREGDK      = 'D',
			 DB          = B.VLERAAM,
			 KR          = 0,
			 DBKRMV      = B.VLERAAM,
             ORDPOST     = 1020,
             A1.KMAG,
			 MSGERROR    = A1.KOMENTLM1, 
             DSCERROR    = B.KODAF + ': CRegjistrim',                                -- [Vlere Amortizim Cumuluar]
             DEPRF       = A1.DEPRF,
             LISTERF     = A1.LISTERF,
             DEPART      = K.DEP,
             LISTEART    = K.LIST,
			 TAGNR       = A1.NRRENDOR 
        FROM #AQ A1 LEFT JOIN AQSCR     B  ON A1.NRRENDOR=B.NRD 
			   	    LEFT JOIN AQKARTELA K  ON K.KOD=B.KARTLLG 
                    LEFT JOIN AQSKEMELM S  ON S.KOD=K.KODLM
       WHERE A1.DOK_JB=0 AND CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',JP,CR,')>0 AND ISNULL(B.VLERAAM,0)<>0;  
  --ORDER BY A1.NRRENDOR 



   RAISERROR (N'02.4.2   Llogari Levizje brendeshme Cregjistrimi: [Vlere blerje] - kredi', 0, 1) WITH NOWAIT
   
      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 

      SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0  
                                THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                ELSE ISNULL(A1.SEGMENT,'') 
                           END, 
             LLOGARIPK   = S.LLOGBL, 
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
			 KR          =   B.VLERABS,
			 DBKRMV      = 0-B.VLERABS,
             ORDPOST     = 1010,
             A1.KMAG,
			 MSGERROR    = A1.KOMENTLM1, 
             DSCERROR    = B.KODAF + ': CRegjistrim - Blerje',
             DEPRF       = A1.DEPRF,
             LISTERF     = A1.LISTERF,
             DEPART      = K.DEP,
             LISTEART    = K.LIST,
			 A1.NRRENDOR 
        FROM #AQ A1 LEFT JOIN AQSCR     B  ON A1.NRRENDOR=B.NRD 
			   	    LEFT JOIN AQKARTELA K  ON K.KOD=B.KARTLLG 
                    LEFT JOIN AQSKEMELM S  ON S.KOD=K.KODLM
       WHERE A1.DOK_JB=0 AND CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',JP,CR,')>0 AND ISNULL(B.VLERABS,0)<>0;  
  --ORDER BY A1.NRRENDOR 
   


   RAISERROR (N'02.4.3   Llogari Levizje brendeshme [Vlere Blerje] - [Vlere Anortizim Cumuluar]: - debi', 0, 1) WITH NOWAIT

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, TAGNR) 

      SELECT SEGMENT     = CASE WHEN CHARINDEX('.',ISNULL(B.KODAF,''))>0  
                                THEN STUFF(B.KODAF,1,CHARINDEX('.',ISNULL(B.KODAF,'')),'')
                                ELSE ISNULL(A1.SEGMENT,'') 
                           END, 
             LLOGARIPK   = CASE WHEN Dbo.Isd_SegmentFind(A1.KODLM,0,1)<>'' THEN Dbo.Isd_SegmentFind(A1.KODLM,0,1)  -- llogari ne dokument
                                ELSE                                            S.LLOGSHPVLERMBET                  -- CRegjistrim
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
			 DB          = B.VLERABS - B.VLERAAM,
			 KR          = 0,
			 DBKRMV      = B.VLERABS - B.VLERAAM,
             ORDPOST     = 1020,
             A1.KMAG,
			 MSGERROR    = A1.KOMENTLM1, 
             DSCERROR    = B.KODAF + ': CRegjistrim',      -- [Vlere Blerje] - [Vlere Anortizim Cumuluar]
             DEPRF       = A1.DEPRF,
             LISTERF     = A1.LISTERF,
             DEPART      = K.DEP,
             LISTEART    = K.LIST,
			 A1.NRRENDOR 
        FROM #AQ A1 LEFT JOIN AQSCR     B  ON A1.NRRENDOR=B.NRD 
			   	    LEFT JOIN AQKARTELA K  ON K.KOD=B.KARTLLG 
                    LEFT JOIN AQSKEMELM S  ON S.KOD=K.KODLM
       WHERE A1.DOK_JB=0 AND CHARINDEX(','+ISNULL(B.KODOPER,'')+',',',JP,CR,')>0 AND (ISNULL(B.VLERAAM,0)<>0 OR ISNULL(B.VLERABS,0)<>0);  
  --ORDER BY A1.NRRENDOR 

        PRINT       '02.4     Mbaroi levizje brendeshme CRegjistrimi: [Vlere Blerje] - [Vlere Anortizim Cumuluar] '



   RAISERROR (N'02.5     Modifikimi i fushes KOD tek Scr', 0, 1) WITH NOWAIT

          SET @RIdKp   = ISNULL((SELECT MIN(NRRENDOR) FROM #FKSCR1),0);
          SET @RIdMax  = ISNULL((SELECT MAX(NRRENDOR) FROM #FKSCR1),0);
          SET @RCount  = ISNULL((SELECT COUNT(*)      FROM #FKSCR1),0);
          SET @RIncNum = 9999;

          IF  @RCount <= @RIncNum
              SET @RIncNum = @RIdMax;

        WHILE @RIdKp <= @RIdMax

          BEGIN
                  SET @RIdKs = @RIdKp + @RIncNum;

               UPDATE #FKSCR1 
                  SET KOD = LLOGARIPK+'.'+Dbo.Isd_SegmentFind(SEGMENT,0,1)+'.'+Dbo.Isd_SegmentFind(SEGMENT,0,2)+'.'+ ISNULL(KMAG,'')+'.'
                WHERE NRRENDOR>=@RIdKp AND NRRENDOR<=@RIdKs;

            RAISERROR (N'', 0, 1) WITH NOWAIT;

                 SET @RIdKp = @RIdKs + 1;
                 IF  @RIdKp > @RIdMax 
                     BREAK
                 ELSE
                     CONTINUE
          END;

       PRINT '02.5     Modifikimi i fushes KOD tek Scr';



   RAISERROR (N'02.6     Modifikim sipas skemes Dep/List tek AqKartela', 0, 1) WITH NOWAIT

-- Pse mungon Dbo.Isd_SegmentFind(A.KOD,0,4) tek LLOGARI ...?  15.04.2016

          IF @ImplicidDepListAqKart=1 
             BEGIN
                 UPDATE A 
                    SET KOD      = LLOGARIPK+'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(A.DEPART,'')   END + 
                                             '.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(A.LISTEART,'') END + 
                                             '.'+dbo.Isd_SegmentFind(A.KOD,0,4)+ 
                                             '.'+dbo.Isd_SegmentFind(A.KOD,0,5),
                        LLOGARI  = dbo.Isd_SegmentsToKodAF( 
                                   LLOGARIPK+'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(A.DEPART,'')   END+
										     '.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(A.LISTEART,'') END)
                   FROM #FKSCR1 A 
                  WHERE A.DEPART<>'' OR A.LISTEART<>''
             END;
             
       PRINT '02.6    Mbaroi Modifikim sipas skemes Dep/List tek AQKartela';


         IF  OBJECT_ID('TempDb..#AQ') IS NOT NULL
             DROP TABLE #AQ;

        SET @TimeEn = CONVERT(Varchar(10),GETDATE(),108);
        SET @TimeDi = CONVERT(Varchar(10),DateAdd(Second,DATEDIFF(Second,@TimeSt,GETDATE()),'2001-01-01 00:00:00'),108);
        


  RAISERROR (N'Faza 1   Fund Gjenerimi dokumentave FK nga %s.                            %s   %s', 0, 1, @DokName, @TimeEn, @TimeDi) WITH NOWAIT;

       EXEC [dbo].[Isd_KalimLMDbF] @sTip,@pNrRendor,@pTableNameTmp;   -- @pNrRendor Nuk Perdoret

GO
