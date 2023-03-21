SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Procedure [dbo].[Isd_KalimLM_FF]
 (
  @PTip          Varchar(10),
  @PNrRendor     Int,
  @PSQLFilter    Varchar(5000),
  @PTableNameTmp Varchar(40)
  )
AS

-- FF Fillim

         SET NOCOUNT ON

     DECLARE @TimeSt                  DateTime,
             @TimeDi                  Varchar(20),
             @TimeEn                  Varchar(10)

     DECLARE @DokName                 Varchar(30),
             @KalimFFLMValut          Bit,
             @KontabKFngaRef          Bit,
             @ImplicidDepListMG       Bit,
             @ImplicidDepListRF       Bit,
             @ImplicidDepListArt      Bit,
             @ImplicidDepListSherb    Bit,
             @ImplicidDepListAqKart   Bit,
             @DepListRF               Varchar(10),
             @Where                   Varchar(MAX);
           
         SET @TimeSt                = GETDATE();
         SET @TimeDi                = CONVERT(Varchar(10),@TimeSt,108);

      SELECT @KalimFFLMValut        = ISNULL(KalimFFLMVAL,0),
             @KontabKFngaRef        = ISNULL(FUDEPLISTNGAREF,0),
             @ImplicidDepListMG     = ISNULL(KALIMFFLMDEPLIST,0),
             @ImplicidDepListRF     = ISNULL(FUDEPLISTNGAREF,0),
             @ImplicidDepListArt    = ISNULL(DEPLISTNGAART,0),
             @ImplicidDepListSherb  = ISNULL(DEPLISTNGASHERB,0),
             @ImplicidDepListAqKart = ISNULL(DEPLISTNGAAQKART,0)
        FROM CONFIGLM;


         SET @DokName               = 'FF';
         SET @Where                 = @PSQLFilter;
         SET @DepListRF             = CAST(@ImplicidDepListRF AS VARCHAR(10));

   RAISERROR (N'
Faza 1   Gjenerimi dokumentave FK nga %s.                                 %s', 0, 1, @DokName, @TimeDi) WITH NOWAIT;


          IF OBJECT_ID('TempDb..#FF') IS NOT NULL
             BEGIN
               DROP TABLE #FF
             END;  

      SELECT NRRENDOR  = CAST(0 AS BIGINT),
             KOMENTLM1 = SHENIM1,
             PERSHKRIM = SHENIM1,
             LLOGARI   = KODFKL, 
             DEP       = KODFKL,
             LIST      = KODFKL,
             DEPRF     = KODFKL, 
             LISTERF   = KODFKL,
             DEPART    = KODFKL,
             LISTEART  = KODFKL
        INTO #FF 
        FROM FF 
       WHERE 1=2;


       PRINT '01.1     Krijim Koka FK';

	 	EXEC (' 
	  INSERT INTO #FF 
            (NRRENDOR,KOMENTLM1,PERSHKRIM,LLOGARI,DEPRF,LISTERF) 
      SELECT A.NRRENDOR,
             LEFT('''+@DokName+' nr ''+CONVERT(VARCHAR,CONVERT(BIGINT,A.NRDOK))+'' dt ''+CONVERT(VARCHAR,A.DATEDOK,4)+'',''+ISNULL(A.KMAG,''''),150),
             ISNULL(A.SHENIM1,ISNULL(B.PERSHKRIM,'''')),
             ISNULL(B.LLOGARI,''''),
             CASE WHEN '+@DepListRF+'=1 THEN ISNULL(B.DEP,'''')   ELSE '''' END,
             CASE WHEN '+@DepListRF+'=1 THEN ISNULL(B.LISTE,'''') ELSE '''' END 
        FROM FF A LEFT JOIN FURNITOR B ON A.KODFKL=B.KOD '+@Where);

														-- Krijim FK
	  INSERT INTO #FK 
			(KODNENDITAR, NRDFK, NRDOK, DATEDOK, PERSHKRIM1, PERSHKRIM2,  
			 KMON, KURS1, KURS2, ORG, FIRSTDOK, TIPDOK, NUMDOK, REFERDOK,DST,  
			 KMAG, FORMAT, KLASIFIKIM, TAGNR)  
	  SELECT '',0,0,DATEDOK,SHENIM1,B.KOMENTLM1,
			 '', 1, 1, @PTip, FIRSTDOK,@DokName, NRDOK, KODFKL,'BL',
             KMAG,'','',A.NRRENDOR 
		FROM FF A INNER JOIN #FF B ON A.NRRENDOR=B.NRRENDOR;
 
       PRINT '01.2     Krijim Koka FK - Fund';




   RAISERROR (N'02.1     Detyrim Furnitori', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, 
             KMON, KURS1, KURS2, TREGDK,DB, KR, DBKRMV, 
             ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF,LISTERF,DEPART,LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = CASE WHEN @KontabKFngaRef=0
                                THEN '....'+MAX(ISNULL(A.KMON,''))
                                ELSE '.'+MAX(ISNULL(A1.DEP,''))+'.'+MAX(ISNULL(A1.LIST,''))+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')) 
                           END, 
             LLOGARIPK   = MAX(A1.LLOGARI),
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')), 
			 KMON        = MAX(ISNULL(A.KMON,'')),
             KURS1       = MAX(A.KURS1),
             KURS2       = MAX(A.KURS2), 
             TREGDK      = 'K',
			 DB          = 0,
			 KR          = SUM(B.VLERABS),
			 DBKRMV      = 0 - SUM((B.VLERABS * A.KURS2)/ A.KURS1),
             ORDPOST     = 0,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Llg.Furnitor,Datyrim',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = '',
             LISTEART    = '', 
             KODREF      = MAX(A.KODFKL),
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
		FROM FF A INNER JOIN #FF    A1 ON A.NRRENDOR=A1.NRRENDOR
                  INNER JOIN FFSCR  B  ON A.NRRENDOR=B.NRD 
     GROUP BY A.NRRENDOR;
  
       PRINT '02.1     Detyrim Furnitori - Fund';




   RAISERROR (N'03.1     TVSH Valute ose Monedhe Vendi', 0, 1) WITH NOWAIT;

-- Preket llogari TVSH (Kujdes efektin e zbritjes)

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, 
             KMON, KURS1, KURS2, TREGDK, DB, KR, DBKRMV, 
             ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF,LISTERF,DEPART,LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '....'+MAX(ISNULL(A.KMON,'')), 
			 LLOGARIPK   = MAX(A.LLOGTVSH), 
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')), 
			 KMON        = CASE WHEN @KalimFFLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
             KURS1       = CASE WHEN @KalimFFLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
             KURS2       = CASE WHEN @KalimFFLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END, 
             TREGDK      = 'D',
/*  -- Modifikuar 08.03.2017 per te bere efektin e zbritjes si tek shitja
			 CASE WHEN @KalimFFLMValut=0 THEN SUM((ISNULL(B.VLTVSH,0) * A.KURS2)/A.KURS1) ELSE SUM(ISNULL(B.VLTVSH,0)) END,
             0,
			 SUM((ISNULL(B.VLTVSH,0) * A.KURS2)/A.KURS1), */
             DB          = CASE WHEN MAX(ISNULL(A.VLERZBR,0))=0 THEN SUM(B.VLTVSH) ELSE MAX(ISNULL(A.VLTVSH,0)) END * 
                           CASE WHEN @KalimFFLMValut=0 THEN MAX(A.KURS2/A.KURS1) ELSE 1 END,
                              
             KR          = 0,
			 DBKRMV      = CASE WHEN MAX(ISNULL(A.VLERZBR,0))=0 THEN SUM(B.VLTVSH) ELSE MAX(ISNULL(A.VLTVSH,0)) END 
                           * 
                           MAX(A.KURS2/A.KURS1),
-- Fund Modifikimi 08.03.2017


             ORDPOST     = 3000,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Llg.Tvsh',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = '',
             LISTTART    = '', 
             KODREF      = MAX(A.KODFKL),
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
		FROM FF A INNER JOIN #FF    A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FFSCR  B  ON A.NRRENDOR=B.NRD
    GROUP BY A.NRRENDOR
      HAVING ABS(SUM(ISNULL(B.VLTVSH,0)))>=0.01; 
 
       PRINT '03.2     TVSH Valute ose Monedhe Vendi - Fund';




   RAISERROR (N'04.1     Zbritje Furnitori', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, 
             KMON, KURS1, KURS2, TREGDK, DB, KR, DBKRMV, 
             ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF,LISTERF,DEPART,LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = MAX(CASE WHEN @KontabKFngaRef=0
                                    THEN '....'+ISNULL(A.KMON,'')
                                    ELSE '.'+ISNULL(A1.DEP,'')+'.'+ISNULL(A1.LIST,'')+'.'+ISNULL(A.KMAG,'')+'.'+ISNULL(A.KMON,'') 
                               END), 
			 LLOGARIPK   = MAX(A1.LLOGARI), 
			 PERSHKRIM   = MAX(A1.PERSHKRIM), 
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')), 
			 KMON        = MAX(ISNULL(A.KMON,'')),
             KURS1       = MAX(A.KURS1),
             KURS2       = MAX(A.KURS2), 
             TREGDK      = 'D',
           /*ISNULL(A.VLERZBR,0),         -- Modifikuar 08.03.2017 per te bere efektin e zbritjes si tek shitja
             0,
			 (ISNULL(A.VLERZBR,0) * A.KURS2)/A.KURS1,*/
             DB          = MAX(ISNULL(A.VLERZBR,0)) + SUM(B.VLTVSH)  - MAX(ISNULL(A.VLTVSH,0)),  -- SUM(B.VLERABS) - MAX(ISNULL(A.VLERTOT,0)),
             KR          = 0,
             DBKRMV      =(MAX(ISNULL(A.VLERZBR,0)) + SUM(B.VLTVSH)  - MAX(ISNULL(A.VLTVSH,0))) * MAX(A.KURS2/A.KURS1), 							   
             PRDPOST     = 4000,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Llg.Furnitor,Zbritje',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = '',
             LISTEART    = '',
             KODREF      = MAX(A.KODFKL),
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
		FROM FF A INNER JOIN #FF    A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FFSCR  B  ON A.NRRENDOR=B.NRD
	   WHERE ISNULL(A.VLERZBR,0)<>0
    GROUP BY A.NRRENDOR;

       PRINT '04.2     Zbritje Furnitori - Fund';




   RAISERROR (N'04.3     Zbritje Llogari LM ', 0, 1) WITH NOWAIT
   
      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF,TAGNR) 
      SELECT SEGMENT     = '....'+ISNULL(A.KMON,''), 
             LLOGARIPK   = A.LLOGZBR, 
			 PERSHKRIM   = A1.PERSHKRIM,  
			 KOMENT      = ISNULL(A.SHENIM3,''), 
			 KMON        = CASE WHEN @KalimFFLMValut=0 THEN '' ELSE ISNULL(A.KMON,'') END,
             KURS1       = CASE WHEN @KalimFFLMValut=0 THEN 1  ELSE A.KURS1           END,
             KURS2       = CASE WHEN @KalimFFLMValut=0 THEN 1  ELSE A.KURS2           END, --	ISNULL(A.KMON,''),A.KURS1,A.KURS2,    -- 15.03.12   1.2
             TREGDK      = 'K',
             DB          = 0,
			 KR          = CASE WHEN @KalimFFLMValut=0 THEN (ISNULL(A.VLERZBR,0)*A.KURS2)/A.KURS1 ELSE  ISNULL(A.VLERZBR,0) END,  -- ISNULL(A.VLERZBR,0),  -- 15.03.12   1.2
			 DBKRMV      = 0-((ISNULL(A.VLERZBR,0) * A.KURS2)/A.KURS1),
             ORDPOST     = 4500,
             KMAG        = ISNULL(A.KMAG,''),
			 MSGERROR    = A1.KOMENTLM1, 
			 DSCERROR    = 'Llg.Zbritje',
             DEPRF       = ISNULL(A1.DEPRF,''),
             LISTERF     = ISNULL(A1.LISTERF,''),
             DEPART      = '',
             LISTEART    = '',
             KODREF      = A.KODFKL,
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
		FROM FF A INNER JOIN #FF    A1 ON A.NRRENDOR=A1.NRRENDOR
	   WHERE ISNULL(VLERZBR,0)<>0; 
 
       PRINT '04.4     Zbritje Llogari LM - Fund';




   RAISERROR (N'05.1     Parapagese Furnitori', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF,LISTERF,DEPART,LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = CASE WHEN @KontabKFngaRef=0
                                THEN '....'+ISNULL(A.KMON,'')
                                ELSE '.'+ISNULL(A1.DEP,'')+'.'+ISNULL(A1.LIST,'')+'.'+ISNULL(A.KMAG,'')+'.'+ISNULL(A.KMON,'') 
                           END, 
             LLOGARIPK   = A1.LLOGARI, 
			 PERSHKRIM   = A1.PERSHKRIM,
			 SHENIM3     = ISNULL(A.SHENIM3,''), 
			 KMON        = ISNULL(A.KMON,''),
             KURS1       = A.KURS1,
             KURS2       = A.KURS2, 
             TREGDK      = 'D',
			 DB          = ISNULL(A.PARAPG,0),
             KR          = 0,
			 DBKRMV      =(ISNULL(A.PARAPG,0) * A.KURS2)/A.KURS1,
             ORDPOST     = 6500,
             KMAG        = ISNULL(A.KMAG,''),
			 MSGERROR    = A1.KOMENTLM1, 
			 DSCERROR    = 'Llg.Furnitor,Parapg',
             DEPRF       = ISNULL(A1.DEPRF,''),
             LISTERF     = ISNULL(A1.LISTERF,''),
             DEPART      = '',
             LISTEART    = '',
             KODREF      = A.KODFKL,
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
		FROM FF A INNER JOIN #FF    A1 ON A.NRRENDOR=A1.NRRENDOR
	   WHERE ISNULL(A.PARAPG,0)<>0 AND ISNULL(A.NRRENDORAR,0)=0; 
 -- ORDER BY A.NRRENDOR 
       PRINT '05.2     Parapagese Furnitori - Fund';




   RAISERROR (N'05.3     Parapagese Llogari LM', 0, 1) WITH NOWAIT;
      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '....'+ISNULL(A.KMON,''), 
             LLOGARIPK   = A.LLOGARK, 
			 PERSHKRIM   = A1.PERSHKRIM,
			 KOMENT      = ISNULL(A.SHENIM3,''), 
			 KMON        = ISNULL(A.KMON,''),
             KURS1       = A.KURS1,
             KURS2       = A.KURS2, 
             TREGDK      = 'K',
             DB          = 0,
             KR          = ISNULL(A.PARAPG,0),
			 DBKRMV      = 0-((ISNULL(A.PARAPG,0) * A.KURS2)/A.KURS1),
             ORDPOST     = 6000,
             KMAG        = ISNULL(A.KMAG,''),
			 MSGERROR    = A1.KOMENTLM1, 
			 DSCERROR    = 'Llg.Finance,Parapg',
             DEPRF       = ISNULL(A1.DEPRF,''),
             LISTERF     = ISNULL(A1.LISTERF,''),
             DEPART      = '',
             LISTEART    = '',
             KODREF      = A.KODFKL,
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
		FROM FF A INNER JOIN #FF    A1 ON A.NRRENDOR=A1.NRRENDOR
	   WHERE ISNULL(A.PARAPG,0)<>0 AND ISNULL(A.NRRENDORAR,0)=0;
 -- ORDER BY A.NRRENDOR 
       PRINT '05.4     Parapagese Llogari LM - Fund';




   RAISERROR (N'06.1     Artikuj : Llg.Blerje', 0, 1) WITH NOWAIT

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF, TAGNR) 

      SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')), 
			 LLOGARIPK   = MAX(E.LLOGB), 
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')), 
			 KMON        = CASE WHEN @KalimFFLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
             KURS1       = CASE WHEN @KalimFFLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
             KURS2       = CASE WHEN @KalimFFLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END, -- MAX(ISNULL(A.KMON,'')), MAX(A.KURS1), MAX(A.KURS2), -- 15.03.12   1.2
             TREGDK      = 'D',
			 DB          = CASE WHEN @KalimFFLMValut=0 THEN SUM((ISNULL(B.VLPATVSH,0) * A.KURS2)/A.KURS1) ELSE SUM(ISNULL(B.VLPATVSH,0)) END, -- SUM(ISNULL(B.VLPATVSH,0)), -- 15.03.12   1.2
             KR          = 0,
             DBKRMV      = SUM((ISNULL(B.VLPATVSH,0) * A.KURS2)/A.KURS1),
             ORDPOST     = 3000,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Llg.Artikuj,Blerje',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = CASE WHEN @ImplicidDepListArt=1 THEN MAX(ISNULL(D.DEP,''))  ELSE '' END,
             LISTEART    = CASE WHEN @ImplicidDepListArt=1 THEN MAX(ISNULL(D.LIST,'')) ELSE '' END,
             KODREF      = MAX(''),
             TIPKLLREF   = 'K',
			 TAGNR       = A.NRRENDOR 
		FROM FF A INNER JOIN #FF     A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FFSCR   B  ON A.NRRENDOR=B.NRD 
                  LEFT  JOIN ARTIKUJ D  ON D.KOD=B.KARTLLG
                  LEFT  JOIN SKEMELM E  ON E.KOD=D.KODLM 
	   WHERE TIPKLL='K' 
    GROUP BY A.NRRENDOR,B.NRRENDOR 
      HAVING ABS(SUM(ISNULL(B.VLPATVSH,0)))>=0.01;
 -- ORDER BY A.NRRENDOR
       PRINT '06.2     Artikuj : Llg.Blerje - Fund';


   RAISERROR (N'07.1     Sherbim : Llg.Blerje', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGEMENT    = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')), 
             LLOGARIPK   = MAX(E.LLOGB), 
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')),      
			 KMON        = CASE WHEN @KalimFFLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
             KURS1       = CASE WHEN @KalimFFLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
             KURS2       = CASE WHEN @KalimFFLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END, 
             TREGDK      = 'D',
			 DB          = SUM(CASE WHEN @KalimFFLMValut=0 THEN (ISNULL(B.VLPATVSH,0) * A.KURS2)/A.KURS1 ELSE  ISNULL(B.VLPATVSH,0) END),
             KR          = 0,
			 DBKRMV      = SUM(ISNULL(B.VLPATVSH,0)*A.KURS2/A.KURS1),  -- SUM(CASE WHEN @KontabDShoqFJ=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END),  -- 15.03.12   1.2 
             ORDPOST     = 3300,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Llg.Sherbim',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DETART      = CASE WHEN @ImplicidDepListSherb=1 THEN MAX(ISNULL(E.DEP,''))   ELSE '' END,
             LISTEART    = CASE WHEN @ImplicidDepListSHerb=1 THEN MAX(ISNULL(E.LISTE,'')) ELSE '' END,
             KODREF      = MAX(B.KARTLLG),
             TIPKLLREF   = 'R',
			 TAGNR       = A.NRRENDOR 
		FROM FF A INNER JOIN #FF     A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FFSCR   B  ON A.NRRENDOR=B.NRD 
                  LEFT  JOIN SHERBIM E  ON E.KOD=B.KARTLLG
	   WHERE TIPKLL='R' 
    GROUP BY A.NRRENDOR,B.NRRENDOR 
      HAVING ABS(SUM(ISNULL(B.VLPATVSH,0)))>=0.01 
	ORDER BY A.NRRENDOR

       PRINT '07.2     Sherbim : Llg.Blerje - Fund';




   RAISERROR (N'08.1     Llogari Shpenzim', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')), 
             LLOGARIPK   = MAX(B.KARTLLG),
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(CASE WHEN ISNULL(B.KOMENT,'')<>'' THEN ISNULL(B.KOMENT,'') ELSE ISNULL(A.SHENIM3,'') END),   -- MAX(ISNULL(A.SHENIM3,'')), ishte para 12.06.2020
			 KMON        = CASE WHEN @KalimFFLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
             KURS1       = CASE WHEN @KalimFFLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
             KURS2       = CASE WHEN @KalimFFLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END, -- MAX(ISNULL(A.KMON,'')), MAX(A.KURS1), MAX(A.KURS2), -- 15.03.12   1.2
             TREGDK      = 'D',
			 DB          = CASE WHEN @KalimFFLMValut=0 THEN SUM((ISNULL(B.VLPATVSH,0) * A.KURS2)/A.KURS1) ELSE SUM(ISNULL(B.VLPATVSH,0)) END, -- SUM(ISNULL(B.VLPATVSH,0)), -- 15.03.12   1.2
             KR          = 0,
			 DBKRMV      = SUM((ISNULL(B.VLPATVSH,0) * A.KURS2)/A.KURS1),
             ORDPOST     = 3200,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Llg.Sherbim,Shpenzim',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = '',
             LISTEART    = '',
             KODREF      = MAX(B.KARTLLG),
             TIPKLLREF   = 'L',
			 TAGNR       = A.NRRENDOR 
		FROM FF A INNER JOIN #FF     A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FFSCR   B  ON A.NRRENDOR=B.NRD
	   WHERE TIPKLL='L' 
    GROUP BY A.NRRENDOR, B.NRRENDOR 
      HAVING ABS(SUM(ISNULL(B.VLPATVSH,0)))>=0.01; 
 -- ORDER BY A.NRRENDOR
       PRINT '08.2     Llogari Shpenzim - Fund';




   RAISERROR (N'08a.1    Llogari Aktivi-Blerje', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')), 
             LLOGARIPK   = MAX(Q.LLOGSHPBL),
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(CASE WHEN ISNULL(B.KOMENT,'')<>'' THEN ISNULL(B.KOMENT,'') ELSE ISNULL(A.SHENIM3,'') END),   -- MAX(ISNULL(A.SHENIM3,'')), ishte para 12.06.2020 
			 KMON        = CASE WHEN @KalimFFLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
             KURS1       = CASE WHEN @KalimFFLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
             KURS2       = CASE WHEN @KalimFFLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END,   -- MAX(ISNULL(A.KMON,'')), MAX(A.KURS1), MAX(A.KURS2),
             TREGDK      = 'D',
			 DB          = CASE WHEN @KalimFFLMValut=0 THEN SUM((ISNULL(B.VLPATVSH,0) * A.KURS2)/A.KURS1) ELSE SUM(ISNULL(B.VLPATVSH,0)) END,  -- SUM(ISNULL(B.VLPATVSH,0)),    
             KR          = 0,
			 DBKRMV      = SUM((ISNULL(B.VLPATVSH,0) * A.KURS2)/A.KURS1),
             ORDPOST     = 3200,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Llg.Aktivi,Blerje',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = CASE WHEN @ImplicidDepListAqKart=1 THEN MAX(K.DEP)  ELSE '' END,
             LISTEART    = CASE WHEN @ImplicidDepListAqKart=1 THEN MAX(K.LIST) ELSE '' END,
             KODREF      = MAX(B.KARTLLG),
             TIPKLLREF   = MAX(B.TIPKLL),
             TAGNR       = A.NRRENDOR 
        FROM FF A INNER JOIN #FF       A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FFSCR     B  ON A.NRRENDOR=B.NRD
                  LEFT  JOIN AQKARTELA K  ON B.KARTLLG=K.KOD
                  LEFT  JOIN AQSKEMELM Q  ON K.KODLM=Q.KOD
       WHERE TIPKLL='X' 
    GROUP BY A.NRRENDOR, B.NRRENDOR 
      HAVING ABS(SUM(ISNULL(B.VLPATVSH,0)))>=0.01; 
  --ORDER BY A.NRRENDOR
       PRINT '08b.2    Llogari Aktivi-Blerje - Fund';




   RAISERROR (N'09.1     Kalim Furnitor Rasti ne Scr', 0, 1) WITH NOWAIT;
      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')),
             LLOGARIPK   = MAX(C.LLOGARI), 
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(CASE WHEN ISNULL(A.SHENIM3,'')= '' THEN 'Kalim detyrimi: '+B.KARTLLG ELSE A.SHENIM3 END), 
			 KMON        = MAX(ISNULL(A.KMON,'')),
             KURS1       = MAX(A.KURS1),
             KURS2       = MAX(A.KURS2), 
             TREGDK      = 'D',
 			 DB          = SUM(ISNULL(B.VLERABS,0)),
             KR          = 0,
			 DBKRMV      = SUM(ISNULL(B.VLERABS,0) * A.KURS2/A.KURS1),
             ORDPOST     = 5000,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Furnitor: Kalim Detyrimi',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = '',  
             LISTEART    = '',  
             KODREF      = MAX(A.KODFKL),
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
		FROM FF A   INNER JOIN #FF      A1 ON A.NRRENDOR=A1.NRRENDOR
                    LEFT  JOIN FFSCR    B  ON A.NRRENDOR=B.NRD 
                    LEFT  JOIN FURNITOR C  ON C.KOD=B.KARTLLG
	   WHERE TIPKLL='F' 
    GROUP BY A.NRRENDOR, B.NRRENDOR 
      HAVING ABS(SUM(ISNULL(B.VLERABS,0)))>=0.01 
	ORDER BY A.NRRENDOR;
       PRINT '09.2     Kalim Furnitor Rasti ne Scr - Fund';




   RAISERROR (N'09.3     Shlyerje Detyrimi Klient Rasti ne Scr', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')),
             LLOGARIPK   = MAX(C.LLOGARI), 
			 PERSHKRIM   = MAX(A1.PERSHKRIM), 
             KOMENT      = MAX(CASE WHEN ISNULL(A.SHENIM3,'')= '' THEN 'Kalim detyrimi: '+B.KARTLLG ELSE A.SHENIM3 END), -- MAX(ISNULL(A.SHENIM3,'Kalim detyrimi tek Klient')), 
			 KMON        = MAX(ISNULL(A.KMON,'')),
             KURS1       = MAX(A.KURS1),
             KURS2       = MAX(A.KURS2), 
             TREGDK      = 'D',
 			 DB          = SUM(ISNULL(B.VLERABS,0)),
             KR          = 0,
			 DBKRMV      = SUM(ISNULL(B.VLERABS,0) * A.KURS2/A.KURS1),
             ORDPOST     = 5100,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Klient: Shlyerje Detyrim',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = '',  
             LISTEART    = '',  
             KODREF      = MAX(A.KODFKL),
             TIPKLLREF   = MAX(TIPKLL),
			 TAGNR       = A.NRRENDOR 
		FROM FF A INNER JOIN #FF      A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FFSCR    B  ON A.NRRENDOR=B.NRD 
                  LEFT  JOIN KLIENT   C  ON C.KOD=B.KARTLLG
	   WHERE TIPKLL='S' 
    GROUP BY A.NRRENDOR, B.NRRENDOR 
      HAVING ABS(SUM(ISNULL(B.VLERABS,0)))>=0.01 
	ORDER BY A.NRRENDOR;
	
       PRINT '09.4     Shlyerje Detyrimi Klient Rasti ne Scr - Fund';




   RAISERROR (N'10.1     Promocion Artikuj', 0, 1) WITH NOWAIT;                          -- u fut dt 22.10.2013

     DECLARE @LlogPrmc   Varchar(100);
      SELECT @LlogPrmc = ISNULL(LLOGPRMCFF,'') FROM CONFIGLM;

      INSERT INTO #FKSCR1
            (SEGMENT,LLOGARIPK,PERSHKRIM,KOMENT,KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV,ORDPOST,KMAG,MSGERROR,DSCERROR,
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF, TAGNR) 

      SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')), 
             LLOGARIPK   = CASE WHEN MAX(ISNULL(C.KODLMFF,''))<>'' THEN MAX(ISNULL(C.KODLMFF,'')) ELSE @LlogPrmc END,
  			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')), 
			 KMON        = CASE WHEN @KalimFFLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
             KURS1       = CASE WHEN @KalimFFLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
             KURS2       = CASE WHEN @KalimFFLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END, 
             TREGDK      = 'K',
			 DB          = SUM(CASE WHEN @KalimFFLMValut=0 THEN (ISNULL(B.VLERABS,0) * A.KURS2)/A.KURS1 ELSE  ISNULL(B.VLERABS,0) END), -- SUM(ISNULL(B.VLERABS,0)), -- 15.03.12   1.2
             KR          = 0,
			 DBKRMV      = SUM(ISNULL(B.VLERABS,0) * A.KURS2/A.KURS1),
             ORDPOST     = 7000,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
 			 DSCERROR    = 'Llg.Artikuj,Promocion',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = CASE WHEN @ImplicidDepListArt=1 THEN MAX(ISNULL(D.DEP,''))  ELSE '' END,
             LISTEART    = CASE WHEN @ImplicidDepListArt=1 THEN MAX(ISNULL(D.LIST,'')) ELSE '' END,
             KODREF      = '',
             TIPKLLREF   = 'K',
			 TAGNR       = A.NRRENDOR 
		FROM FF A INNER JOIN #FF     A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FFSCR   B  ON A.NRRENDOR=B.NRD
                  LEFT  JOIN PROMOC  C  ON B.PROMOCKOD=C.KOD 
                  LEFT  JOIN ARTIKUJ D  ON D.KOD=B.KARTLLG
	   WHERE TIPKLL='K' AND ISNULL(B.PROMOC,0)=1
    GROUP BY A.NRRENDOR,B.NRRENDOR 
      HAVING ABS(SUM(ISNULL(B.VLERABS,0)))>=0.01 
	ORDER BY A.NRRENDOR;
	
       PRINT '10.2     Promocion Artikuj - Fund';




   RAISERROR (N'10.3     Promocion Furnitori', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '....'+MAX(ISNULL(A.KMON,'')),
             LLOGARIPK   = MAX(A1.LLOGARI), 
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')), 
			 KMON        = MAX(ISNULL(A.KMON,'')),
             KURS1       = MAX(A.KURS1),
             KURS2       = MAX(A.KURS2), 
             TREGDK      = 'D',
             DB          = 0,
 			 KR          =   SUM(ISNULL(B.VLERABS,0)),
			 DBKRMV      = 0-SUM(ISNULL(B.VLERABS,0) * A.KURS2/A.KURS1),
             ORDPOST     = 7500,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Llg.Furnitor,Promocion',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = CASE WHEN @ImplicidDepListArt=1 THEN MAX(ISNULL(D.DEP,''))  ELSE '' END,
             LISTEART    = CASE WHEN @ImplicidDepListArt=1 THEN MAX(ISNULL(D.LIST,'')) ELSE '' END,
             KODREF      = MAX(A.KODFKL),
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
		FROM FF A INNER JOIN #FF     A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FFSCR   B  ON A.NRRENDOR=B.NRD 
                  LEFT  JOIN ARTIKUJ D  ON D.KOD=B.KARTLLG
	   WHERE TIPKLL='K' AND ISNULL(B.PROMOC,0)=1
    GROUP BY A.NRRENDOR,B.NRRENDOR 
      HAVING ABS(SUM(ISNULL(B.VLERABS,0)))>=0.01 
	ORDER BY A.NRRENDOR;
	
       PRINT '10.4     Promocion Furnitor - Fund';




   RAISERROR (N'11.1     Firo', 0, 1) WITH NOWAIT;
       PRINT '11.2     Firo - Fund';




   RAISERROR (N'12.1     Modifikim fushe KOD tek Scr', 0, 1) WITH NOWAIT;

      UPDATE #FKSCR1 SET KOD=LLOGARIPK + SEGMENT, LLOGARI=LLOGARIPK;

       PRINT '12.1     Modifikim fushe KOD tek Scr - Fund';




   RAISERROR (N'13.1     Modifikim sipas skemes Dep/List tek Magazina', 0, 1) WITH NOWAIT;

-- Pse mungon Dbo.Isd_SegmentFind(A.KOD,0,4) tek LLOGARI ...? 15.04.2016

          IF @ImplicidDepListMG=1 
             BEGIN
                UPDATE A 
                   SET KOD      = LLOGARIPK+'.' + CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(B.DEP,'')  END + 
                                            '.' + CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(B.LIST,'') END + 
                                            '.' + Dbo.Isd_SegmentFind(A.KOD,0,4) + 
                                            '.' + Dbo.Isd_SegmentFind(A.KOD,0,5),
                       LLOGARI  = dbo.Isd_SegmentsToKodAF(
                                  LLOGARIPK+'.' + CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(B.DEP,'')  END + 
                                            '.' + CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(B.LIST,'') END)
                  FROM #FKSCR1 A INNER JOIN MAGAZINA B ON A.KMAG=B.KOD 
                 WHERE ISNULL(KMAG,'')<>'' AND (ISNULL(B.DEP,'''')<>'' OR ISNULL(B.LIST,'''')<>''); -- AND (Dbo.Isd_SegmentFind(SEGMENT,0,2)='') AND (Dbo.Isd_SegmentFind(SEGMENT,0,3)='') 
                                                                                                    -- Rasti kur mjafton nje segment eshte hedhur me dore 
             END;
                           
       PRINT '13.2     Modifikim sipas skemes Dep/List tek Magazina - Fund';




   RAISERROR (N'14.1     Modifikim sipas skemes Dep/List tek Furnitor', 0, 1) WITH NOWAIT;

-- Pse mungon Dbo.Isd_SegmentFind(A.KOD,0,4) tek LLOGARI ...? 15.04.2016

          IF @ImplicidDepListRF=1 
             BEGIN
                UPDATE A 
                   SET KOD      = LLOGARIPK+'.' + CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(A.DEPRF,'')   END + 
                                            '.' + CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(A.LISTERF,'') END + 
                                            '.' + Dbo.Isd_SegmentFind(A.KOD,0,4) + 
                                            '.' + Dbo.Isd_SegmentFind(A.KOD,0,5),

                       LLOGARI  = dbo.Isd_SegmentsToKodAF(
                                  LLOGARIPK+'.' + CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(A.DEPRF,'')   END + 
                                            '.' + CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(A.LISTERF,'') END)
                  FROM #FKSCR1 A 
                 WHERE ISNULL(A.DEPRF,'')<>'' OR ISNULL(A.LISTERF,'')<>'';     -- AND (Dbo.Isd_SegmentFind(SEGMENT,0,2)='') AND (Dbo.Isd_SegmentFind(SEGMENT,0,3)='')
                                                                               -- Rasti kur mjafton nje segment eshte hedhur me dore 
             END;
             
       PRINT '14.2     Modifikim sipas skemes Dep/List tek Furnitor - Fund';




   RAISERROR (N'15.1     Modifikim sipas skemes Dep/List tek Artikuj', 0, 1) WITH NOWAIT;

-- Pse mungon Dbo.Isd_SegmentFind(A.KOD,0,4) tek LLOGARI ...? 15.04.2016

          IF @ImplicidDepListART=1 OR @ImplicidDepListSherb=1 OR @ImplicidDepListAqKart=1
             BEGIN
                UPDATE A 
                   SET KOD      = LLOGARIPK+'.' + CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(A.DEPART,'')   END + 
                                            '.' + CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(A.LISTEART,'') END + 
                                            '.' + dbo.Isd_SegmentFind(A.KOD,0,4) + 
                                            '.' + dbo.Isd_SegmentFind(A.KOD,0,5),

                       LLOGARI  = dbo.Isd_SegmentsToKodAF(
                                  LLOGARIPK+'.' + CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(A.DEPART,'')   END + 
                                            '.' + CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(A.LISTEART,'') END)
                  FROM #FKSCR1 A 
                 WHERE A.DEPART<>'' OR A.LISTEART<>'';                         -- AND (Dbo.Isd_SegmentFind(SEGMENT,0,2)='') AND (Dbo.Isd_SegmentFind(SEGMENT,0,3)='')
                                                                               -- Rasti kur mjafton nje segment eshte hedhur me dore 
             END;
             
       PRINT '15.2     Modifikim sipas skemes Dep/List tek Artikuj - Fund';




          IF OBJECT_ID('TempDb..#FF') IS NOT NULL
             DROP TABLE #FF;


         SET @TimeEn = CONVERT(Varchar(10),GETDATE(),108)
         SET @TimeDi = CONVERT(Varchar(10),DATEADD(SECOND,DATEDIFF(SECOND,@TimeSt,GETDATE()),'2001-01-01 00:00:00'),108)




   RAISERROR (N'Faza 1   Gjenerimi dokumentave FK nga %s.                                 %s   %s', 0, 1, @DokName, @TimeEn, @TimeDi) WITH NOWAIT




        EXEC [dbo].[Isd_KalimLMDbF] @PTip,@PNrRendor,@PTableNameTmp   -- @PNrRendor Nuk Perdoret
GO
