SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Procedure [dbo].[Isd_KalimLM_FJ]
 (
  @PTip          Varchar(10),
  @PNrRendor     Int,
  @PSQLFilter    Varchar(5000),
  @PTableNameTmp Varchar(40)
  )
AS


          IF @PTip<>'S'            -- FJ 
             RETURN;
             
             
         SET NOCOUNT ON

     DECLARE @TimeSt                  DateTime,
             @TimeDi                  Varchar(20),
             @TimeEn                  Varchar(10)

     DECLARE @DokName                 Varchar(30),
             @KalimFJLMValut          Bit, 
             @KontabDShoqFJ           Bit,
             @AplikoFiro              Bit,
             @LlogMRrjet              Varchar(5000),
		     @LlogDShoq               Varchar(5000),
             @LlogAmbRjet             Varchar(100),
             @Sql                     Varchar(MAX),
             @Where                   Varchar(MAX),
             @DepListRF               Varchar(10),
             @ImplicidDepListMG       Bit,
             @ImplicidDepListRF       Bit,
             @ImplicidDepListArt      Bit,
             @ImplicidDepListSherb    Bit,
             @ImplicidDepListAqKart   Bit;

         SET @TimeSt                = GETDATE()
         SET @TimeDi                = CONVERT(Varchar(10),@TimeSt,108)

      SELECT @KalimFJLMValut        = ISNULL(KALIMFJLMVAL,0),
             @KontabDShoqFJ         = ISNULL(KALIMLMDSHOQFJ,0),
		     @LlogMRrjet            = ISNULL(LLOGMRRJET,''),
		     @LlogDShoq             = ISNULL(LLOGDOKSH,''),
             @LlogAmbRjet           = ISNULL(LLOGAMBRJET,''),
             @ImplicidDepListMG     = ISNULL(KALIMFJLMDEPLIST,0), 
             @ImplicidDepListRF     = ISNULL(KLDEPLISTNGAREF,0),
             @ImplicidDepListArt    = ISNULL(DEPLISTNGAART,0),
             @ImplicidDepListSherb  = ISNULL(DEPLISTNGASHERB,0),
             @ImplicidDepListAqKart = ISNULL(DEPLISTNGAAQKART,0)  
        FROM CONFIGLM;

         SET @DokName               = 'FJ';
         SET @Where                 = @PSQLFilter;
         SET @DepListRF             = CAST(@ImplicidDepListRF AS VARCHAR(10));


   RAISERROR (N'
Faza 1   Gjenerimi dokumentave FK nga %s.                                 %s', 0, 1, @DokName, @TimeDi) WITH NOWAIT


          IF OBJECT_ID('TempDB..#FJ') IS NOT NULL
             BEGIN
               DROP TABLE #FJ
             END;  

      SELECT NRRENDOR  = CAST(0 AS BIGINT),
             KOMENTLM1 = SHENIM1,
             PERSHKRIM = SHENIM1,
             LLOGARI   = KODFKL,
             DEPRF     = KODFKL,
             LISTERF   = KODFKL,
             DEPART    = KODFKL,
             LISTEART  = KODFKL 
        INTO #FJ 
        FROM FJ 
       WHERE 1=2;


       PRINT '01.1     Krijim Koka FK';

         SET @Sql = ' 
      INSERT INTO #FJ 
            (NRRENDOR,KOMENTLM1,PERSHKRIM,LLOGARI,DEPRF,LISTERF) 
      SELECT A.NRRENDOR,
             LEFT('''+@DokName+' nr ''+CONVERT(VARCHAR,CONVERT(BIGINT,A.NRDOK))+'' dt ''+CONVERT(VARCHAR,A.DATEDOK,4)+'',''+ISNULL(A.KMAG,''''),150),
             ISNULL(A.SHENIM1,ISNULL(B.PERSHKRIM,'''')),
             ISNULL(B.LLOGARI,''''),
             CASE WHEN '+@DepListRF+'=1 THEN ISNULL(B.DEP,'''')   ELSE '''' END,
             CASE WHEN '+@DepListRF+'=1 THEN ISNULL(B.LISTE,'''') ELSE '''' END 
        FROM FJ A LEFT JOIN KLIENT   B ON A.KODFKL=B.KOD 
       ' + @Where;

	    EXEC (@Sql);


      INSERT INTO #FK                  -- Krijim FK
			(KODNENDITAR, NRDFK, NRDOK, DATEDOK, PERSHKRIM1, PERSHKRIM2,  
			 KMON, KURS1, KURS2, ORG, FIRSTDOK, TIPDOK, NUMDOK, REFERDOK,DST,  
			 KMAG, FORMAT, KLASIFIKIM, TAGNR)  
	  SELECT '',0,0,DATEDOK,SHENIM1,B.KOMENTLM1,
			 '', 1, 1, @PTip, FIRSTDOK,@DokName, NRDOK, KODFKL,'SH',
             KMAG,'','',A.NRRENDOR 
		FROM FJ A INNER JOIN #FJ B ON A.NRRENDOR=B.NRRENDOR 
    ORDER BY DATEDOK,NRDOK; 
    
       PRINT '01.2     Krijim Koka FK - Fund';



   RAISERROR (N'02.1     Detyrim Klienti', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, 
             KMON, KURS1, KURS2, TREGDK,DB, KR, DBKRMV, 
             ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF,LISTERF,DEPART,LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '....'+MAX(ISNULL(A.KMON,'')), 
             LLOGARIPK   = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN MAX(A1.LLOGARI) ELSE @LlogDShoq END,
--           CASE WHEN @KontabDShoqFJ=1 THEN MAX(A1.LLOGARI) ELSE CASE WHEN ISNULL(A.ISDOKSHOQ,0)=1 THEN @LlogDShoq ELSE MAX(A1.LLOGARI) END END,
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')), 
			 KMON        = MAX(ISNULL(A.KMON,'')),
             KURS1       = MAX(A.KURS1),
             KURS2       = MAX(A.KURS2), 
             TREGDK      = 'D',
			 DB          = SUM(B.VLERABS),
			 KR          = 0,
			 DBKRMV      = SUM((B.VLERABS * A.KURS2)/ A.KURS1),
             ORDPOST     = 0,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
             DSCERROR    = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN 'Llg.Klient,Detyrim' ELSE 'Llg.D.Shoq,Detyrim' END,
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')), 
             DETART      = '',
             LISTEART    = '',
             KODREF      = MAX(A.KODFKL),
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
		FROM FJ A INNER JOIN #FJ    A1 ON A.NRRENDOR=A1.NRRENDOR
                  INNER JOIN FJSCR  B  ON A.NRRENDOR=B.NRD 
    GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0);
 -- ORDER BY A.NRRENDOR 
       PRINT '02.2     Detyrim Klienti - Fund';



   RAISERROR (N'03.1     TVSH valute ose monedhe vendi', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, 
             KMON, KURS1, KURS2, TREGDK, DB, KR, DBKRMV, 
             ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF,LISTERF,DEPART,LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '....'+MAX(ISNULL(A.KMON,'')), 
             LLOGARIPK   = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN MAX(A.LLOGTVSH) ELSE @LlogMRrjet END, 
--			 CASE WHEN @KontabDShoqFJ=1 THEN MAX(A.LLOGTVSH) ELSE CASE WHEN ISNULL(A.ISDOKSHOQ,0)=1 THEN @LlogMRrjet ELSE MAX(A.LLOGTVSH) END END, 
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')), 
			 KMON        = CASE WHEN @KalimFJLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
             KURS1       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
             KURS2       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END, 
             TREGDK      = 'K',
             DB          = 0,

             KR          = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 
                                THEN CASE WHEN MAX(ISNULL(A.VLERZBR,0))=0 THEN SUM(B.VLTVSH) ELSE MAX(ISNULL(A.VLTVSH,0)) END
                                ELSE SUM(B.VLERABS) 
                           END 
                           * 
                           CASE WHEN @KalimFJLMValut=0 THEN MAX(A.KURS2/A.KURS1) ELSE 1 END,

			 DBKRMV      = 0 - CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1
                                    THEN CASE WHEN MAX(ISNULL(A.VLERZBR,0))=0 THEN SUM(B.VLTVSH) ELSE MAX(ISNULL(A.VLTVSH,0)) END 
                                    ELSE SUM(B.VLERABS) 
                               END 
                           * 
                           MAX(A.KURS2/A.KURS1),

--  E sakte por imponuar nga ITE behen veprimet me Koke dokumenti...  -- ITE

--			 CASE WHEN @KalimFJLMValut=0 
--                THEN SUM(CASE WHEN @KontabDShoqFJ=1 
--                              THEN ISNULL(B.VLTVSH,0) 
--                              ELSE CASE WHEN ISNULL(A.ISDOKSHOQ,0)=1 THEN B.VLERABS ELSE B.VLTVSH END 
--                         END * A.KURS2/A.KURS1) 
--                 ELSE SUM(CASE WHEN @KontabDShoqFJ=1 
--                               THEN ISNULL(B.VLTVSH,0) 
--                               ELSE CASE WHEN ISNULL(A.ISDOKSHOQ,0)=1 THEN B.VLERABS ELSE B.VLTVSH END 
--                          END) 
--           END,
--			 0-SUM(CASE WHEN @KontabDShoqFJ=1 
--                      THEN ISNULL(B.VLTVSH,0) 
--                      ELSE CASE WHEN ISNULL(A.ISDOKSHOQ,0)=1 THEN B.VLERABS ELSE B.VLTVSH END 
--           END * A.KURS2/A.KURS1),                                  -- ITE
             ORDPOST     = 3000,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN 'Llg.Tvsh' ELSE 'Llg.Mall rjet' END, 
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DETART      = '',
             LISTEART    = '', 
             KODREF      = MAX(A.KODFKL),
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
		FROM FJ A INNER JOIN #FJ    A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FJSCR  B  ON A.NRRENDOR=B.NRD
    GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0)
      HAVING ABS( CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 
                       THEN CASE WHEN MAX(ISNULL(A.VLERZBR,0))=0 THEN SUM(B.VLTVSH) ELSE MAX(ISNULL(A.VLTVSH,0)) END
                       ELSE SUM(B.VLERABS) 
                  END ) >= 0.01;
--    HAVING ABS(SUM(CASE WHEN @KontabDShoqFJ=1 THEN ISNULL(B.VLPATVSH,0) ELSE CASE WHEN ISNULL(A.ISDOKSHOQ,0)=1 THEN B.VLERABS ELSE B.VLTVSH END END))>=0.01;
--  ORDER BY A.NRRENDOR 
       PRINT '03.2     TVSH valute ose monedhe vendi - Fund';



-- Shtuar me 28.01.2016 per te saktesuar kontabilizimin ne rastet: Row=Klient, ka Tvsh, dokument fature
   RAISERROR (N'03.3     TVSH valute ose monedhe vendi: Rasti Row=Klient, ka Tvsh,dokument fature', 0, 1) WITH NOWAIT;

--------------                        INSERT INTO #FKSCR1
--------------                              (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, 
--------------                               KMON, KURS1, KURS2, TREGDK, DB, KR, DBKRMV, 
--------------                               ORDPOST,KMAG, MSGERROR, DSCERROR, 
--------------                               DEPRF,LISTERF,DEPART,LISTEART,KODREF,TIPKLLREF,TAGNR) 
--------------
--------------                        SELECT '....'+MAX(ISNULL(A.KMON,'')), 
--------------							   CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1
--------------                                    THEN MAX(A.LLOGTVSH)
--------------                                    ELSE @LlogMRrjet END, 
--------------							   MAX(A1.PERSHKRIM),  
--------------							   MAX(ISNULL(A.SHENIM3,''))+' Sistemim Tvsh', 
--------------							   CASE WHEN @KalimFJLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
--------------                               CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
--------------                               CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END, 
--------------                               'D' AS TREGDK,
--------------                                   CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 
--------------                                        THEN MAX(ISNULL(A.VLTVSH,0)) 
--------------                                        ELSE SUM(B.VLERABS) END 
--------------                                   * 
--------------                                   CASE WHEN @KalimFJLMValut=0 THEN MAX(A.KURS2/A.KURS1) ELSE 1 END,
--------------                               0,
--------------							       CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1
--------------                                        THEN MAX(ISNULL(A.VLTVSH,0)) 
--------------                                        ELSE SUM(B.VLERABS) END 
--------------                                   * 
--------------                                   MAX(A.KURS2/A.KURS1),
--------------                               11000,
--------------                               MAX(ISNULL(A.KMAG,'')),
--------------							   MAX(ISNULL(A1.KOMENTLM1,'')), 
--------------							   CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1
--------------                                    THEN 'Llg.Tvsh'
--------------                                    ELSE 'Llg.Mall rjet' END, 
--------------                               MAX(ISNULL(A1.DEPRF,'')),
--------------                               MAX(ISNULL(A1.LISTERF,'')),
--------------                               '',
--------------                               '', 
--------------                               MAX(A.KODFKL),@PTip,
--------------							   A.NRRENDOR 
--------------						  FROM FJ A INNER JOIN #FJ    A1 ON A.NRRENDOR=A1.NRRENDOR
--------------                                    LEFT  JOIN FJSCR  B  ON A.NRRENDOR=B.NRD
--------------                         WHERE B.TIPKLL='S' AND B.VLTVSH<>0 AND ISNULL(A.ISDOKSHOQ,0)=0
--------------                      GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0)
--------------                        HAVING ABS( CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 
--------------                                         THEN MAX(ISNULL(A.VLTVSH,0)) 
--------------                                         ELSE SUM(B.VLERABS) END ) >= 0.01;
       PRINT '03.6     TVSH valute ose monedhe vendi: Rasti Row=Klient, ka Tvsh,dokument fature - Fund';



   RAISERROR (N'04.1     Zbritje Klient', 0, 1) WITH NOWAIT;
   
--    INSERT INTO #FKSCR1
--          (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, 
--           KMON, KURS1, KURS2, TREGDK, DB, KR, DBKRMV, 
--           ORDPOST,KMAG, MSGERROR, DSCERROR, DEPRF, LISTERF, TAGNR) 
--
--    SELECT '....'+ISNULL(A.KMON,''), 
--			 CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN A1.LLOGARI ELSE @LlogDShoq END, 
--			 A1.PERSHKRIM, 
--			 ISNULL(A.SHENIM3,''), 
--			 ISNULL(A.KMON,''),
--           A.KURS1,
--           A.KURS2, 
--           'K' AS TREGDK,
--           0,
--			 ISNULL(A.VLERZBR,0),
--			 0-((ISNULL(A.VLERZBR,0) * A.KURS2)/A.KURS1),
--           4000,
--           ISNULL(A.KMAG,''),
--			 A1.KOMENTLM1, 
--			 'Llg.Klient, Zbr.',
--           A1.DEPRF,
--           A1.LISTERF,
--			 A.NRRENDOR 
--		FROM FJ A INNER JOIN #FJ    A1 ON A.NRRENDOR=A1.NRRENDOR
--	   WHERE ISNULL(VLERZBR,0)<>0 
--	ORDER BY A.NRRENDOR;
 

-- Efekti TVSH
      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, 
             KMON, KURS1, KURS2, TREGDK, DB, KR, DBKRMV, 
             ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF,LISTERF,DEPART,LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '....'+MAX(ISNULL(A.KMON,'')), 
			 LLOGARIPK   = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN MAX(A1.LLOGARI) ELSE @LlogDShoq END, 
			 PERSHKRIM   = MAX(A1.PERSHKRIM), 
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')), 
			 KMON        = MAX(ISNULL(A.KMON,'')),
             KURS1       = MAX(A.KURS1),
             KURS2       = MAX(A.KURS2), 
             TREGDK      = 'K',
             DB          = 0,
             KR          = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1
                                THEN MAX(ISNULL(A.VLERZBR,0)) + SUM(B.VLTVSH)  - MAX(ISNULL(A.VLTVSH,0))
                                ELSE SUM(B.VLERABS) - MAX(ISNULL(A.VLERTOT,0)) 
                           END, 
             DBKRMV      = 0 - ( CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 
                                      THEN MAX(ISNULL(A.VLERZBR,0)) + SUM(B.VLTVSH)  - MAX(ISNULL(A.VLTVSH,0))
                                      ELSE SUM(B.VLERABS) - MAX(ISNULL(A.VLERTOT,0)) 
                                 END) * MAX(A.KURS2/A.KURS1), 
--           (SUM(CASE WHEN @KontabDShoqFJ=1 THEN ISNULL(B.VLTVSH,0) 
--                     ELSE CASE WHEN ISNULL(A.ISDOKSHOQ,0)=1 THEN B.VLERABS ELSE B.VLTVSH END 
--                END) 
--           - 
--           MAX(    CASE WHEN @KontabDShoqFJ=1 THEN ISNULL(A.VLTVSH,0) 
--                        ELSE CASE WHEN ISNULL(A.ISDOKSHOQ,0)=1 THEN A.VLERTOT ELSE A.VLTVSH END 
--                   END)),
--			 0 - (SUM(CASE WHEN @KontabDShoqFJ=1 THEN ISNULL(B.VLTVSH,0) 
--                         ELSE CASE WHEN ISNULL(A.ISDOKSHOQ,0)=1 THEN B.VLERABS ELSE B.VLTVSH END 
--                    END) 
--             - 
--           MAX(CASE WHEN @KontabDShoqFJ=1 THEN ISNULL(A.VLTVSH,0) 
--                    ELSE CASE WHEN ISNULL(A.ISDOKSHOQ,0)=1 THEN A.VLERTOT ELSE A.VLTVSH END 
--               END)) * 
--           MAX(A.KURS2/A.KURS1),
             ORDPOST     = 4000,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Llg.Klient,Zbritje',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DETART      = '',
             LISTEART    = '', 
             KODREF      = MAX(A.KODFKL),
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
		FROM FJ A INNER JOIN #FJ    A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FJSCR  B  ON A.NRRENDOR=B.NRD 
	   WHERE ISNULL(VLERZBR,0)<>0 AND ISNULL(A.VLPATVSH,0)<>0 
    GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0)
	ORDER BY A.NRRENDOR; 
	
       PRINT '04.2     Zbritje Klient - Fund';



   RAISERROR (N'04.3     Zbritje Ardhur', 0, 1) WITH NOWAIT;
   
      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF,TAGNR) 
             
      SELECT SEGMENT     = '....'+MAX(ISNULL(A.KMON,'')), 
             LLOGARIPK   = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN MAX(A.LLOGZBR) ELSE @LlogMRrjet END, 
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')), 
			 KMON        = CASE WHEN @KalimFJLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
             KURS1       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
             KURS2       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END,   -- ISNULL(A.KMON,''), A.KURS1, A.KURS2,   -- 15.03.12   1.2
             TREGDK      = 'D',
             DB          = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN MAX(ISNULL(A.VLERZBR,0)) ELSE SUM(B.VLERABS) - MAX(ISNULL(A.VLERTOT,0)) END
                           * 
                           CASE WHEN @KalimFJLMValut=0 THEN MAX(A.KURS2/A.KURS1) ELSE 1 END,      -- ISNULL(A.VLERZBR,0),          -- 15.03.12   1.2
             KR          = 0,
             DBKRMV      = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN MAX(ISNULL(A.VLERZBR,0)) ELSE SUM(B.VLERABS) - MAX(ISNULL(A.VLERTOT,0)) END 
                           * 
                           MAX(A.KURS2/A.KURS1),
             ORDPOST     = 4500,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Llg.Zbritje',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = '',
             LISTEART    = '', 
             KODREF      = MAX(A.KODFKL),
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
	    FROM FJ A INNER JOIN #FJ    A1 ON A.NRRENDOR=A1.NRRENDOR
				  LEFT  JOIN FJSCR  B  ON A.NRRENDOR=B.NRD 
       WHERE ISNULL(VLERZBR,0)<>0 
    GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0)
    ORDER BY A.NRRENDOR;

       PRINT '04.4     Zbritje Ardhur - Fund';



   RAISERROR (N'05.1     Parapagese Klient', 0, 1) WITH NOWAIT;
      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF,LISTERF,DEPART,LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '....'+ISNULL(A.KMON,''), 
             LLOGARIPK   = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN A1.LLOGARI ELSE @LlogDShoq END, 
			 PERSHKRIM   = A1.PERSHKRIM,
			 KOMENT      = ISNULL(A.SHENIM3,''), 
			 KMON        = ISNULL(A.KMON,''),
             KURS1       = A.KURS1,
             KURS2       = A.KURS2, 
             TREGDK      = 'K',
             DB          = 0,
			 KR          = ISNULL(A.PARAPG,0),
			 DBKRMV      = 0-((ISNULL(A.PARAPG,0) * A.KURS2)/A.KURS1),
             ORDPOST     = 6500,
             KMAG        = ISNULL(A.KMAG,''),
			 MSGERROR    = A1.KOMENTLM1, 
			 DSCERROR    = 'Llg.Klient,Parapg',
             DEPRF       = ISNULL(A1.DEPRF,''),
             LISTERF     = ISNULL(A1.LISTERF,''),
             DEPART      = '',
             LISTEART    = '', 
             KODREF      = A.KODFKL,
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
		FROM FJ A INNER JOIN #FJ    A1 ON A.NRRENDOR=A1.NRRENDOR
	   WHERE ISNULL(A.PARAPG,0)<>0 AND ISNULL(A.NRRENDORAR,0)=0 
	ORDER BY A.NRRENDOR; 

       PRINT '05.2     Parapagese Klient - Fund';



   RAISERROR (N'05.3     Parapagese Likujdim', 0, 1) WITH NOWAIT;
      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF, TAGNR) 

      SELECT SEGMENT     = '....'+ISNULL(A.KMON,''), 
             LLOGARIPK   = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN A.LLOGARK ELSE @LlogMRrjet END, 
			 PERSHKRIM   = A1.PERSHKRIM,
			 KOMENT      = ISNULL(A.SHENIM3,''), 
			 KMON        = ISNULL(A.KMON,''),
             KURS1       = A.KURS1,
             KURS2       = A.KURS2, 
             TREGDK      = 'D',
             DB          = ISNULL(A.PARAPG,0),
             KR          = 0,
			 DBKRMV      =(ISNULL(A.PARAPG,0) * A.KURS2)/A.KURS1,
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
		FROM FJ A INNER JOIN #FJ    A1 ON A.NRRENDOR=A1.NRRENDOR
	   WHERE ISNULL(A.PARAPG,0)<>0 AND ISNULL(A.NRRENDORAR,0)=0 
	ORDER BY A.NRRENDOR; 
	
       PRINT '05.4     Parapagese Likujdim - Fund';



   RAISERROR (N'06.1     Artikuj : Llogari Shitje', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF, TAGNR) 

      SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')), 
			 LLOGARIPK   = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN MAX(E.LLOGSH) ELSE '$$$$$' END, 
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')), 
			 KMON        = CASE WHEN @KalimFJLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
             KURS1       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
             KURS2       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END, -- MAX(ISNULL(A.KMON,'')), MAX(A.KURS1), MAX(A.KURS2),   -- 15.03.12   1.2
             TREGDK      = 'K',
             DB          = 0,
			 KR          = SUM(CASE WHEN @KontabDShoqFJ=0   
                                    THEN CASE WHEN @KalimFJLMValut=0 THEN (ISNULL(B.VLPATVSH,0) * A.KURS2)/A.KURS1 ELSE ISNULL(B.VLPATVSH,0) END 
                                    ELSE 0 
                               END),       -- SUM(CASE WHEN @KontabDShoqFJ=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END),  -- 15.03.12   1.2 
			 DBKRMV      = 0-SUM(CASE WHEN @KontabDShoqFJ=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END * A.KURS2/A.KURS1),
             ORDPOST     = 3000,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Llg.Ardhur,Artikuj',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = CASE WHEN @ImplicidDepListArt=1 THEN MAX(ISNULL(D.DEP,''))  ELSE '' END,
             LISTEART    = CASE WHEN @ImplicidDepListArt=1 THEN MAX(ISNULL(D.LIST,'')) ELSE '' END,
             KODREF      = MAX(''),
             TIPKLLREF   = 'K', 
			 TAGNR       = A.NRRENDOR 
		FROM FJ A INNER JOIN #FJ     A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FJSCR   B  ON A.NRRENDOR=B.NRD 
                  LEFT  JOIN ARTIKUJ D  ON D.KOD=B.KARTLLG
                  LEFT  JOIN SKEMELM E  ON E.KOD=D.KODLM 
	   WHERE TIPKLL='K' AND ISNULL(B.ISAMB,0)=0      -- 04.05.2015
    GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0),B.NRRENDOR 
      HAVING ABS(SUM(CASE WHEN @KontabDShoqFJ=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END))>=0.01 
	ORDER BY A.NRRENDOR;
	
       PRINT '06.2     Artikuj : Llogari Shitje - Fund';


-- ne se nuk duhet ndarje amballazhi kthyeshem ne magazine hiq paragrafin 06.3 dhe komentin me siper me date 04.05.2015

   RAISERROR (N'06.3     Artikuj : Llogari Amballazh', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF, TAGNR) 

      SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')),  
			 LLOGARIPK   = CASE WHEN ISNULL(@LlogAmbRjet,'')<>'' THEN @LlogAmbRjet ELSE '$$$$$' END, 
		--   CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN MAX(E.LLOGSH) ELSE '$$$$$' END, -- 04.05.2015
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')), 
			 KMON        = CASE WHEN @KalimFJLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
             KURS1       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
             KURS2       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END, -- MAX(ISNULL(A.KMON,'')), MAX(A.KURS1), MAX(A.KURS2),  -- 15.03.12   1.2
             TREGDK      = 'K',
             DB          = 0,
			 KR          = SUM(CASE WHEN @KontabDShoqFJ=0   -- 15.03.12   1.1 
                                    THEN CASE WHEN @KalimFJLMValut=0 THEN (ISNULL(B.VLPATVSH,0) * A.KURS2)/A.KURS1 ELSE  ISNULL(B.VLPATVSH,0) END 
                                    ELSE 0 
                               END),     -- SUM(CASE WHEN @KontabDShoqFJ=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END),  -- 15.03.12   1.2 
			 DBKRMV      = 0 - SUM(CASE WHEN @KontabDShoqFJ=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END * A.KURS2/A.KURS1),
             ORDPOST     = 3000,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Amb.kthyeshem',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = CASE WHEN @ImplicidDepListArt=1 THEN MAX(ISNULL(D.DEP,''))  ELSE '' END,
             LISTEART    = CASE WHEN @ImplicidDepListArt=1 THEN MAX(ISNULL(D.LIST,'')) ELSE '' END,
             KODREF      = MAX(''),
             TIPKLLREF   = 'K', 
			 TAGNR       = A.NRRENDOR 
		FROM FJ A INNER JOIN #FJ     A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FJSCR   B  ON A.NRRENDOR=B.NRD 
                  LEFT  JOIN ARTIKUJ D  ON D.KOD=B.KARTLLG
                  LEFT  JOIN SKEMELM E  ON E.KOD=D.KODLM 
	   WHERE TIPKLL='K' AND ISNULL(B.ISAMB,0)=1      -- 04.05.2015
    GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0),B.NRRENDOR 
      HAVING ABS(SUM(CASE WHEN @KontabDShoqFJ=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END))>=0.01 
	ORDER BY A.NRRENDOR;
	
       PRINT '06.3     Artikuj : Llogari Amballazh - Fund';



   RAISERROR (N'06.4     Klient Amballazh rrjet', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')), 
             LLOGARIPK   = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN MAX(A1.LLOGARI) ELSE @LlogMRrjet END,
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')), 
			 KMON        = MAX(ISNULL(A.KMON,'')),
             KURS1       = MAX(A.KURS1),
             KURS2       = MAX(A.KURS2), 
             TREGDK      = 'D',
			 DB          = 0-SUM(ISNULL(B.VLERABS,0)),
             KR          = 0,
			 DBKRMV      = 0-SUM(ISNULL(B.VLERABS,0) * A.KURS2/A.KURS1),
             ORDPOST     = 9050,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Klient,Amb.kthyeshem',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = '',
             LISTEART    = '', 
             KODREF      = MAX(A.KODFKL),
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
		FROM FJ A INNER JOIN #FJ     A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FJSCR   B  ON A.NRRENDOR=B.NRD 
	   WHERE TIPKLL='K' AND ISNULL(B.ISAMB,0)=1
    GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0),B.NRRENDOR 
      HAVING ABS(SUM(ISNULL(B.VLERABS,0)))>=0.01 
	ORDER BY A.NRRENDOR;
	
       PRINT '06.4     Klient Amballazh rrjet - Fund';



   RAISERROR (N'06.5     Klient Amballazh rrjet', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')), 
             LLOGARIPK   = CASE WHEN ISNULL(@LlogAmbRjet,'')<>'' THEN @LlogAmbRjet ELSE '$$$$$' END,
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')), 
			 KMON        = MAX(ISNULL(A.KMON,'')),
             KURS1       = MAX(A.KURS1),
             KURS2       = MAX(A.KURS2), 
             TREGDK      = 'K',
			 DB          = 0,
             KR          = 0-SUM(ISNULL(B.VLERABS,0)),
			 DBKRMV      = SUM(ISNULL(B.VLERABS,0) * A.KURS2/A.KURS1),
             ORDPOST     = 9055,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Klient,Amb.kthyeshem',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = '',
             LISTEART    = '', 
             KODREF      = MAX(A.KODFKL),
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
		FROM FJ A INNER JOIN #FJ     A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FJSCR   B  ON A.NRRENDOR=B.NRD 
	   WHERE TIPKLL='K' AND ISNULL(B.ISAMB,0)=1
    GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0),B.NRRENDOR 
      HAVING ABS(SUM(ISNULL(B.VLERABS,0)))>=0.01 
	ORDER BY A.NRRENDOR;
	
       PRINT '06.5     Klient Amballazh rrjet - Fund';

-- ne se nuk duhet ndarje amballazhi kthyeshem ne magazine hiq paragrafin 06.3 dhe komentin me siper me date 04.05.2015


   RAISERROR (N'07.1     Sherbim : Llogari Shitje', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')), 
			 LLOGARIPK   = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN MAX(E.LLOGSH) ELSE '$$$$$' END, 
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')),
			 KMON        = CASE WHEN @KalimFJLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
             KURS1       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
             KURS2       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END, -- MAX(ISNULL(A.KMON,'')), MAX(A.KURS1), MAX(A.KURS2),   -- 15.03.12   1.2 
             TREGDK      = 'K',
             DB          = 0,
			 KR          = SUM(CASE WHEN @KontabDShoqFJ=0    -- 15.03.12   1.1 
                                    THEN CASE WHEN @KalimFJLMValut=0 THEN (ISNULL(B.VLPATVSH,0) * A.KURS2)/A.KURS1 ELSE ISNULL(B.VLPATVSH,0) END 
                                    ELSE 0 
                               END),       -- SUM(CASE WHEN @KontabDShoqFJ=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END),  -- 15.03.12   1.2 
			 DBKRMV      = 0-SUM(CASE WHEN @KontabDShoqFJ=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END * A.KURS2/A.KURS1),
             ORDPOST     = 3100,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Llg.Ardhur,Sherbim',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = CASE WHEN @ImplicidDepListSherb=1 THEN MAX(ISNULL(E.DEP,''))  ELSE '' END,
             LISTEART    = CASE WHEN @ImplicidDepListSherb=1 THEN MAX(ISNULL(E.LISTE,'')) ELSE '' END,
             KODREF      = MAX(B.KARTLLG),
             TIPKLLREF   = 'R',
			 TAGNR       = A.NRRENDOR 
		FROM FJ A INNER JOIN #FJ     A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FJSCR   B  ON A.NRRENDOR=B.NRD 
                  LEFT  JOIN SHERBIM E  ON E.KOD=B.KARTLLG
	   WHERE TIPKLL='R' 
    GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0),B.NRRENDOR 
      HAVING ABS(SUM(CASE WHEN @KontabDShoqFJ=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END))>=0.01 
	ORDER BY A.NRRENDOR;
	
       PRINT '07.2     Sherbim : Llogari Shitje - Fund';



   RAISERROR (N'08.1     Llogari Ardhur', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF, TAGNR) 

      SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')), 
             LLOGARIPK   = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN MAX(B.KARTLLG) ELSE '$$$$$' END,
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(CASE WHEN ISNULL(B.KOMENT,'')<>'' THEN ISNULL(B.KOMENT,'') ELSE ISNULL(A.SHENIM3,'') END),   -- MAX(ISNULL(A.SHENIM3,'')), ishte para 12.06.2020
 			 KMON        = CASE WHEN @KalimFJLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
             KURS1       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
             KURS2       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END, -- MAX(ISNULL(A.KMON,'')), MAX(A.KURS1), MAX(A.KURS2),    -- 15.03.12   1.2 
             TREGDK      = 'K',
             DB          = 0,
			 KR          = SUM(CASE WHEN @KontabDShoqFJ=0    
                                    THEN CASE WHEN @KalimFJLMValut=0 THEN (ISNULL(B.VLPATVSH,0) * A.KURS2)/A.KURS1 ELSE  ISNULL(B.VLPATVSH,0) END 
                                    ELSE 0 
                               END),        -- SUM(CASE WHEN @KontabDShoqFJ=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END),  -- 15.03.12   1.2
			 DBKRMV      = 0 - SUM(CASE WHEN @KontabDShoqFJ=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END * A.KURS2/A.KURS1),
             ORDPOST     = 3200,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Llg.Ardhur,LM',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTEREF    = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = '',
             LISTEART    = '',
             KODREF      = MAX(B.KARTLLG),
             TIPKLLREF   = 'L',
			 TAGNR       = A.NRRENDOR 
		FROM FJ A INNER JOIN #FJ     A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FJSCR   B  ON A.NRRENDOR=B.NRD 
	   WHERE TIPKLL='L' 
    GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0),B.NRRENDOR 
      HAVING ABS(SUM(CASE WHEN @KontabDShoqFJ=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END))>=0.01 
	ORDER BY A.NRRENDOR;
	
       PRINT '08.2     Llogari Ardhur - Fund';



   RAISERROR (N'08a.1    Llogari Aktivi-Ardhur', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF, TAGNR) 

      SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')), 
             LLOGARIPK   = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN MAX(Q.LLOGSH) ELSE '$$$$$' END,
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(CASE WHEN ISNULL(B.KOMENT,'')<>'' THEN ISNULL(B.KOMENT,'') ELSE ISNULL(A.SHENIM3,'') END),   -- MAX(ISNULL(A.SHENIM3,'')), ishte para 12.06.2020
 			 KMON        = CASE WHEN @KalimFJLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
             KURS1       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
             KURS2       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END, -- MAX(ISNULL(A.KMON,'')), MAX(A.KURS1), MAX(A.KURS2),     -- 15.03.12   1.2 
             TREGDK      = 'K',
             DB          = 0,
			 KR          = SUM(CASE WHEN @KontabDShoqFJ=0    
                                    THEN CASE WHEN @KalimFJLMValut=0 THEN (ISNULL(B.VLPATVSH,0) * A.KURS2)/A.KURS1 ELSE  ISNULL(B.VLPATVSH,0) END 
                                    ELSE 0 
                               END),          -- SUM(CASE WHEN @KontabDShoqFJ=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END),  -- 15.03.12   1.2
			 DBKRMV      = 0 - SUM(CASE WHEN @KontabDShoqFJ=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END * A.KURS2/A.KURS1),
             ORDPOST     = 3200,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Llg.Ardhur,LM',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = CASE WHEN @ImplicidDepListAqKart=1 THEN MAX(K.DEP)  ELSE '' END,
             LISTEART    = CASE WHEN @ImplicidDepListAqKart=1 THEN MAX(K.LIST) ELSE '' END,
             KODREF      = MAX(B.KARTLLG),
             TIPKLLREF   = MAX(B.TIPKLL),
			 TAGNR       = A.NRRENDOR 
		FROM FJ A INNER JOIN #FJ       A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FJSCR     B  ON A.NRRENDOR=B.NRD
                  LEFT  JOIN AQKARTELA K  ON B.KARTLLG=K.KOD
                  LEFT  JOIN AQSKEMELM Q  ON Q.KOD=K.KODLM
	   WHERE TIPKLL='X' 
    GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0),B.NRRENDOR 
      HAVING ABS(SUM(CASE WHEN @KontabDShoqFJ=0 THEN ISNULL(B.VLPATVSH,0) ELSE 0 END))>=0.01 
	ORDER BY A.NRRENDOR;
    
       PRINT '08a.2    Llogari Aktivi-Ardhur - Fund';



   RAISERROR (N'09.1     Shlyerje Klient', 0, 1) WITH NOWAIT;
-------------------------------------------------
--   Komentuar me 28.01.2016 Komplet pjesa e meposhteme

--    INSERT INTO #FKSCR1
--          (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
--           DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
--           DEPRF, LISTERF, DEPART, LISTEART, KODREF,TIPKLLREF,TAGNR) 
--
--    SELECT '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')), 
--           CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN MAX(A1.LLOGARI) ELSE @LlogMRrjet END,
--			 MAX(A1.PERSHKRIM),  
--			 MAX(ISNULL(A.SHENIM3,'')), 
--			 MAX(ISNULL(A.KMON,'')),
--           MAX(A.KURS1),
--           MAX(A.KURS2), 
--           'D' AS TREGDK,
--			 0-SUM(ISNULL(B.VLERABS,0)),
--           0,
--			 0-SUM(ISNULL(B.VLERABS,0) * A.KURS2/A.KURS1),
--           9050,
--           MAX(ISNULL(A.KMAG,'')),
--			 MAX(A1.KOMENTLM1), 
--			 'Llg.Klient,Ulje detyrim',
--           MAX(ISNULL(A1.DEPRF,'')),
--           MAX(ISNULL(A1.LISTERF,'')),
--           '',
--           '', 
--           MAX(A.KODFKL),@PTip,
--			 A.NRRENDOR 
--		FROM FJ A INNER JOIN #FJ     A1 ON A.NRRENDOR=A1.NRRENDOR
--                LEFT  JOIN FJSCR   B  ON A.NRRENDOR=B.NRD 
--	   WHERE TIPKLL='S' 
--  GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0),B.NRRENDOR 
--    HAVING ABS(SUM(ISNULL(B.VLERABS,0)))>=0.01 
--	ORDER BY A.NRRENDOR;
------------------
       PRINT '09.2     Shlyerje Klient - Fund';



   RAISERROR (N'09.3     Shlyerje Detyrim Klient', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART, KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')),                              --MAX(C.LLOGARI) 
             LLOGARIPK   = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN @LlogDShoq ELSE @LlogDShoq END, -- MAX(ISNULL(C.LLOGARI,'')),
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(CASE WHEN ISNULL(A.SHENIM3,'')= '' THEN 'Kalim detyrimi: '+B.KARTLLG ELSE A.SHENIM3 END), 
			 KMON        = MAX(ISNULL(A.KMON,'')),
             KURS1       = MAX(A.KURS1),
             KURS2       = MAX(A.KURS2), 
             TREGDK      = 'K',
			 DB          = 0,  
             KR          =  SUM(ISNULL(B.VLPATVSH,0)),
			 DBKRMV      = 0-SUM(ISNULL(B.VLPATVSH,0) * A.KURS2/A.KURS1),  -- 0-SUM(ISNULL(B.VLERABS,0) * A.KURS2/A.KURS1),
             ORDPOST     = 9500,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Llg.Klient:Kalim Detyrim',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = '',
             LISTEART    = '', 
             KODREF      = MAX(A.KODFKL),
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
		FROM FJ A INNER JOIN #FJ     A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FJSCR   B  ON A.NRRENDOR=B.NRD 
                  LEFT  JOIN KLIENT  C  ON B.KARTLLG=C.KOD
	   WHERE TIPKLL='S' AND ISNULL(A.ISDOKSHOQ,0)<>1
    GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0),B.NRRENDOR 
      HAVING ABS(SUM(ISNULL(B.VLERABS,0)))>=0.01 
	ORDER BY A.NRRENDOR;
	
       PRINT '09.4     Shlyere Detyrim Klient  Fund';



   RAISERROR (N'09.5     Shlyerje Detyrim Furnitori', 0, 1) WITH NOWAIT;
      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')),
             LLOGARIPK   = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN MAX(C.LLOGARI) ELSE @LlogDShoq END, 
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(CASE WHEN ISNULL(A.SHENIM3,'')= '' THEN 'Kalim detyrimi: '+B.KARTLLG ELSE A.SHENIM3 END), 
			 KMON        = MAX(ISNULL(A.KMON,'')),
             KURS1       = MAX(A.KURS1),
             KURS2       = MAX(A.KURS2), 
             TREGDK      = 'K',
             DB          = 0,
 			 KR          = SUM(ISNULL(B.VLERABS,0)),
			 DBKRMV      = 0 - SUM(ISNULL(B.VLERABS,0) * A.KURS2/A.KURS1),
             ORDPOST     = 7500,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Furnitor: Shlyerje Detyrim',
             DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = '',  
             LISTEART    = '',  
             KODREF      = MAX(A.KODFKL),
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
	    FROM FJ A   INNER JOIN #FJ      A1 ON A.NRRENDOR=A1.NRRENDOR
                    LEFT  JOIN FJSCR    B  ON A.NRRENDOR=B.NRD 
                    LEFT  JOIN FURNITOR C  ON C.KOD=B.KARTLLG
	   WHERE TIPKLL='F' 
    GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0),B.NRRENDOR 
      HAVING ABS(SUM(ISNULL(B.VLERABS,0)))>=0.01 
	ORDER BY A.NRRENDOR;
	
       PRINT '09.6     Shlyerje Detyrim Furnitori - Fund';



   RAISERROR (N'10.1     Promocion Artikuj', 0, 1) WITH NOWAIT;

     DECLARE @LlogPrmc   Varchar(100);
      SELECT @LlogPrmc = ISNULL(LLOGPRMCFJ,'') FROM CONFIGLM;

      INSERT INTO #FKSCR1
            (SEGMENT,LLOGARIPK,PERSHKRIM,KOMENT,KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV,ORDPOST,KMAG,MSGERROR,DSCERROR,
             DEPRF, LISTERF, DEPART, LISTEART, KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')), 
             LLOGARIPK   = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1   
                                THEN CASE WHEN MAX(ISNULL(C.KODLMFJ,''))<>'' THEN MAX(ISNULL(C.KODLMFJ,'')) ELSE @LlogPrmc END
                                ELSE @LlogMRrjet 
                           END, 
  			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')), 
			 KMON        = CASE WHEN @KalimFJLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
             KURS1       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
             KURS2       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END, 
             TREGDK      = 'D',
			 DB          = SUM(CASE WHEN @KalimFJLMValut=0 THEN (ISNULL(B.VLERABS,0)*A.KURS2)/A.KURS1 ELSE  ISNULL(B.VLERABS,0) END), 
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
             KODREF      = MAX(''),
             TIPKLLREF   = 'K',
			 TAGNR       = A.NRRENDOR 
		FROM FJ A INNER JOIN #FJ     A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FJSCR   B  ON A.NRRENDOR=B.NRD
                  LEFT  JOIN PROMOC  C  ON B.PROMOCKOD=C.KOD 
                  LEFT  JOIN ARTIKUJ D  ON D.KOD=B.KARTLLG
	   WHERE TIPKLL='K' AND ISNULL(B.PROMOC,0)=1
    GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0),B.NRRENDOR 
      HAVING ABS(SUM(ISNULL(B.VLERABS,0)))>=0.01 
	ORDER BY A.NRRENDOR;
	
       PRINT '10.2     Promocion Artikuj - Fund';



-- RAISERROR (N'10.1     Promocion - Artikuj', 0, 1) WITH NOWAIT   

-- Para referimt tek Tabela PROMOC por ishte tek CONFIG     dt 22.10.2013

--   DECLARE @LlogDhurA Varchar(100),
-- 			 @LlogDhurB Varchar(100),
-- 			 @LlogDhurC Varchar(100),
--			 @LlogDhurD Varchar(100);
--
--    SELECT @LlogDhurA=ISNULL(LLOGDHURA,''), @LlogDhurB=ISNULL(LLOGDHURB,''), @LlogDhurC=ISNULL(LLOGDHURC,''), @LlogDhurD=ISNULL(LLOGDHURD,'') FROM CONFIGLM;
--
--    INSERT INTO #FKSCR1
--          (SEGMENT,LLOGARIPK,PERSHKRIM,KOMENT,KMON, KURS1, KURS2, TREGDK, 
--           DB, KR, DBKRMV,ORDPOST,KMAG,MSGERROR,DSCERROR,TAGNR) 
--
--    SELECT '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')), 
--           CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 
--                THEN CASE WHEN MAX(B.PROMOCTIP)='B' THEN @LlogDhurA
--                          WHEN MAX(B.PROMOCTIP)='C' THEN @LlogDhurB
--                          WHEN MAX(B.PROMOCTIP)='D' THEN @LlogDhurC
--                          ELSE                           @LlogDhurA 
--                     END  
--                ELSE @LlogMRrjet 
--           END, 
--  		 MAX(A1.PERSHKRIM),  
--			 MAX(ISNULL(A.SHENIM3,'')), 
--			 CASE WHEN @KalimFJLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
--           CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
--           CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END, -- MAX(ISNULL(A.KMON,'')), MAX(A.KURS1), MAX(A.KURS2),   -- 15.03.12   1.2
--           'D' AS TREGDK,
--			 SUM(CASE WHEN @KalimFJLMValut=0 THEN (ISNULL(B.VLERABS,0) * A.KURS2)/A.KURS1 ELSE ISNULL(B.VLERABS,0) END),  -- SUM(ISNULL(B.VLERABS,0)),  -- 15.03.12   1.2
--           0,
--			 SUM(ISNULL(B.VLERABS,0) * A.KURS2/A.KURS1),
--           7000,
--           MAX(ISNULL(A.KMAG,'')),
--			 MAX(A1.KOMENTLM1), 
-- 			 'Llg.Artikuj,Promocion',
--			 A.NRRENDOR 
--		FROM FJ A INNER JOIN #FJ     A1 ON A.NRRENDOR=A1.NRRENDOR
--                LEFT  JOIN FJSCR   B  ON A.NRRENDOR=B.NRD 
--	   WHERE TIPKLL='K' AND ISNULL(B.PROMOC,0)=1
--  GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0),B.NRRENDOR 
--    HAVING ABS(SUM(ISNULL(B.VLERABS,0)))>=0.01 
--	ORDER BY A.NRRENDOR
--
--     PRINT '10.2     Mbaroi Promocion - Artikuj'



   RAISERROR (N'10.3     Promocion Klient', 0, 1) WITH NOWAIT;

      INSERT INTO #FKSCR1
            (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
             DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, 
             DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF,TAGNR) 

      SELECT SEGMENT     = '....'+MAX(ISNULL(A.KMON,'')),
             LLOGARIPK   = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN MAX(A1.LLOGARI) ELSE @LlogDShoq END, 
			 PERSHKRIM   = MAX(A1.PERSHKRIM),  
			 KOMENT      = MAX(ISNULL(A.SHENIM3,'')), 
			 KMON        = MAX(ISNULL(A.KMON,'')),
             KURS1       = MAX(A.KURS1),
             KURS2       = MAX(A.KURS2), 
             TREGDK      = 'K',
             DB          = 0,
 			 KR          = SUM(ISNULL(B.VLERABS,0)),
			 DBKRMV      = 0-SUM(ISNULL(B.VLERABS,0) * A.KURS2/A.KURS1),
             ORDPOST     = 7500,
             KMAG        = MAX(ISNULL(A.KMAG,'')),
			 MSGERROR    = MAX(A1.KOMENTLM1), 
			 DSCERROR    = 'Llg.Klient,Promocion',
             KODRF       = MAX(ISNULL(A1.DEPRF,'')),
             LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
             DEPART      = '',  -- MAX(ISNULL(D.DEP,'')),
             LISTEART    = '',  -- MAX(ISNULL(D.LIST,'')),
             KODREF      = MAX(A.KODFKL),
             TIPKLLREF   = @PTip,
			 TAGNR       = A.NRRENDOR 
		FROM FJ A INNER JOIN #FJ     A1 ON A.NRRENDOR=A1.NRRENDOR
                  LEFT  JOIN FJSCR   B  ON A.NRRENDOR=B.NRD 
                --LEFT  JOIN ARTIKUJ D  ON D.KOD=B.KARTLLG
	   WHERE TIPKLL='K' AND ISNULL(B.PROMOC,0)=1
    GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0),B.NRRENDOR 
      HAVING ABS(SUM(ISNULL(B.VLERABS,0)))>=0.01 
	ORDER BY A.NRRENDOR;
	
       PRINT '10.4     Promocion Klient - Fund';



   RAISERROR (N'11.1     Firo Artikuj, Klient', 0, 1) WITH NOWAIT;

         SET @AplikoFiro = 1;
               
		  IF NOT EXISTS (SELECT Name FROM Sys.COLUMNS WHERE OBJECT_ID=OBJECT_ID('FJSCR') AND Name='VLERAFR')
			 BEGIN
                SELECT @AplikoFiro=ISNULL(ISAPLEHW,0) FROM CONFND;
             END;  

          IF @AplikoFiro=1

             BEGIN


                 INSERT INTO #FKSCR1
                       (SEGMENT,LLOGARIPK,PERSHKRIM,KOMENT,KMON, KURS1, KURS2, TREGDK, 
                        DB, KR, DBKRMV,ORDPOST,KMAG,MSGERROR,DSCERROR,
                        DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF,TAGNR) 

                 SELECT SEGMENT     = '.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,2)+'.'+Dbo.Isd_SegmentFind(MAX(B.KODAF),0,3)+'.'+MAX(ISNULL(A.KMAG,''))+'.'+MAX(ISNULL(A.KMON,'')), 
						LLOGARIPK   = MAX(CASE WHEN B.TIPFR='B' THEN LLOGARIB   --MAX(E.LLOGARIA), 
                                               WHEN B.TIPFR='C' THEN LLOGARIC
                                               WHEN B.TIPFR='D' THEN LLOGARID
                                               WHEN B.TIPFR='E' THEN LLOGARIE
                                               WHEN B.TIPFR='F' THEN LLOGARIF
                                               WHEN B.TIPFR='G' THEN LLOGARIG
                                               WHEN B.TIPFR='H' THEN LLOGARIH
                                               WHEN B.TIPFR='I' THEN LLOGARII
                                               WHEN B.TIPFR='J' THEN LLOGARIJ
                                               ELSE                  LLOGARIA 
                                          END), 
  						PERSHKRIM   = MAX(A1.PERSHKRIM),  
 						KOMENT      = 'Artikuj: Firo',  --MAX(ISNULL(A.SHENIM3,'')), 
						KMON        = CASE WHEN @KalimFJLMValut=0 THEN '' ELSE MAX(ISNULL(A.KMON,'')) END,
                        KURS1       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS1)           END,
                        KURS2       = CASE WHEN @KalimFJLMValut=0 THEN 1  ELSE MAX(A.KURS2)           END, -- MAX(ISNULL(A.KMON,'')), MAX(A.KURS1), MAX(A.KURS2),   -- 15.03.12   1.2
                        TREGDK      = 'D',
						DB          = SUM(CASE WHEN @KalimFJLMValut=0 THEN (ISNULL(B.VLERAFR,0) * A.KURS2)/A.KURS1 ELSE  ISNULL(B.VLERAFR,0) END), --	SUM(ISNULL(B.VLERAFR,0)), -- 15.03.12   1.2
                        KR          = 0,
						DBKRMV      = SUM(ISNULL(B.VLERAFR,0) * A.KURS2/A.KURS1),
                        ORDPOST     = 8000,
                        KMAG        = MAX(ISNULL(A.KMAG,'')),
						MSGERROR    = MAX(A1.KOMENTLM1), 
 						DSCERROR    = 'Llg.Artikuj,Firo',
                        DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
                        LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
                        DEPART      = CASE WHEN @ImplicidDepListArt=1 THEN MAX(ISNULL(D.DEP,''))  ELSE '' END,
                        LISTEART    = CASE WHEN @ImplicidDepListArt=1 THEN MAX(ISNULL(D.LIST,'')) ELSE '' END, 
                        KODREF      = MAX(''),
                        TIPKLLREF   = 'K',
						TAGNR       = A.NRRENDOR 
				   FROM FJ A INNER JOIN #FJ        A1 ON A.NRRENDOR=A1.NRRENDOR
                             LEFT  JOIN FJSCR      B  ON A.NRRENDOR=B.NRD 
                             LEFT  JOIN ARTIKUJ    D  ON D.KOD=B.KARTLLG
							 LEFT  JOIN ARTIKUJFIR E  ON D.NRRENDOR=E.NRD
				  WHERE TIPKLL='K' 
               GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0),B.NRRENDOR 
                 HAVING ABS(SUM(ISNULL(B.VLERAFR,0)))>=0.01 
			   ORDER BY A.NRRENDOR;
			   
                  PRINT '11.2     Firo Artikuj - Fund';



              RAISERROR (N'11.3     Firo Klient', 0, 1) WITH NOWAIT;

                 INSERT INTO #FKSCR1
                       (SEGMENT, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
                        DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR,
                        DEPRF, LISTERF, DEPART, LISTEART,KODREF,TIPKLLREF,TAGNR) 

                 SELECT SEGMENT     = '....'+MAX(ISNULL(A.KMON,'')),
                        LLOGARIPK   = CASE WHEN ISNULL(A.ISDOKSHOQ,0)=0 OR @KontabDShoqFJ=1 THEN MAX(A1.LLOGARI) ELSE @LlogDShoq END, 
						PERSHKRIM   = MAX(A1.PERSHKRIM), -- MAX(ISNULL(A.SHENIM3,'')),
						KOMENT      = 'Klient: Firo',
 						KMON        = MAX(ISNULL(A.KMON,'')),
                        KURS1       = MAX(A.KURS1),
                        KURS2       = MAX(A.KURS2), 
                        TREGDK      = 'K',
                        DB          = 0,
 						KR          = SUM(ISNULL(B.VLERAFR,0)),
						DBKRMV      = 0-SUM(ISNULL(B.VLERAFR,0) * A.KURS2/A.KURS1),
                        ORDPOST     = 8500,
                        KMAG        = MAX(ISNULL(A.KMAG,'')),
						MSGERROR    = MAX(A1.KOMENTLM1), 
						DSCERROR    = 'Llg.Klient,Firo',
                        DEPRF       = MAX(ISNULL(A1.DEPRF,'')),
                        LISTERF     = MAX(ISNULL(A1.LISTERF,'')),
                        DEPART      = '',  -- MAX(ISNULL(D.DEP,'')),
                        LISTEART    = '',  -- MAX(ISNULL(D.LIST,'')),
                        KODREF      = MAX(A.KODFKL),
                        TIPKLLREF   = @PTip,
						TAGNR       = A.NRRENDOR 
				   FROM FJ A INNER JOIN #FJ     A1 ON A.NRRENDOR=A1.NRRENDOR
                             LEFT  JOIN FJSCR   B  ON A.NRRENDOR=B.NRD 
                           --LEFT  JOIN ARTIKUJ    D  ON D.KOD=B.KARTLLG
				  WHERE TIPKLL='K' 
               GROUP BY A.NRRENDOR, ISNULL(A.ISDOKSHOQ,0),B.NRRENDOR 
                 HAVING ABS(SUM(ISNULL(B.VLERAFR,0)))>=0.01 
			   ORDER BY A.NRRENDOR;

             END;
             
       PRINT '11.4     Firo Artikuj,Klient - Fund';
       


   RAISERROR (N'12.1     Modifikim fushe KOD tek Scr', 0, 1) WITH NOWAIT;



      DELETE FROM #FKSCR1 WHERE LLOGARIPK='$$$$$';
      UPDATE #FKSCR1 SET KOD = LLOGARIPK+SEGMENT;

       PRINT '12.2     Modifikim fushe KOD tek Scr - Fund';



   RAISERROR (N'13.1     Modifikim sipas skemes Dep/List tek Magazina', 0, 1) WITH NOWAIT;

-- Pse mungon Dbo.Isd_SegmentFind(A.KOD,0,4) tek LLOGARI ...? 15.04.2016

          IF @ImplicidDepListMG=1 
             BEGIN
                 UPDATE A 
                    SET KOD      = LLOGARIPK+'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(B.DEP,'')  END + 
                                             '.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(B.LIST,'') END + 
                                             '.'+dbo.Isd_SegmentFind(A.KOD,0,4)+
                                             '.'+dbo.Isd_SegmentFind(A.KOD,0,5),
                        LLOGARI  = dbo.Isd_SegmentsToKodAF(
                                   LLOGARIPK+'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(B.DEP,'')  END + 
                                             '.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(B.LIST,'') END)
                   FROM #FKSCR1 A INNER JOIN MAGAZINA B ON A.KMAG=B.KOD 
                  WHERE ISNULL(KMAG,'')<>'' AND (ISNULL(B.DEP,'''')<>'' OR ISNULL(B.LIST,'''')<>'') -- AND (Dbo.Isd_SegmentFind(SEGMENT,0,2)='') AND (Dbo.Isd_SegmentFind(SEGMENT,0,3)='')
                                                                                                    -- Rasti kur mjafton nje segment eshte hedhur me dore 
             END;
                           
       PRINT '13.2     Modifikim sipas skemes Dep/List tek Magazina - Fund';



   RAISERROR (N'14.1     Modifikim sipas skemes Dep/List tek Klient', 0, 1) WITH NOWAIT;

-- Pse mungon Dbo.Isd_SegmentFind(A.KOD,0,4) tek LLOGARI ...? 15.04.2016

          IF @ImplicidDepListRF=1 
             BEGIN
                 UPDATE A 
                    SET KOD      = LLOGARIPK+'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(A.DEPRF,'')   END + 
                                             '.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(A.LISTERF,'') END + 
                                             '.'+dbo.Isd_SegmentFind(A.KOD,0,4) + 
                                             '.'+dbo.Isd_SegmentFind(A.KOD,0,5),

                        LLOGARI  = dbo.Isd_SegmentsToKodAF(
                                   LLOGARIPK+'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(A.DEPRF,'')   END + 
                                             '.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(A.LISTERF,'') END)
                    FROM #FKSCR1 A 
                   WHERE ISNULL(A.DEPRF,'')<>'' OR ISNULL(A.LISTERF,'')<>'';   -- AND (Dbo.Isd_SegmentFind(SEGMENT,0,2)='') AND (Dbo.Isd_SegmentFind(SEGMENT,0,3)='')
                                                                               -- Rasti kur mjafton nje segment eshte hedhur me dore 
             END;
             
       PRINT '14.2     Modifikim sipas skemes Dep/List tek Klient - Fund';



   RAISERROR (N'15.1     Modifikim sipas skemes Dep/List tek Referenca detaje', 0, 1) WITH NOWAIT;

-- Pse mungon Dbo.Isd_SegmentFind(A.KOD,0,4) tek LLOGARI ...? 15.04.2016

          IF @ImplicidDepListART=1 OR @ImplicidDepListSherb=1 OR @ImplicidDepListAqKart=1
             BEGIN
                 UPDATE A 
                    SET KOD      = LLOGARIPK+'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(A.DEPART,'')   END + 
                                             '.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(A.LISTEART,'') END + 
                                             '.'+dbo.Isd_SegmentFind(A.KOD,0,4) + 
                                             '.'+dbo.Isd_SegmentFind(A.KOD,0,5),

                        LLOGARI  = dbo.Isd_SegmentsToKodAF(
                                   LLOGARIPK+'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(A.DEPART,'')   END + 
                                             '.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(A.LISTEART,'') END)
                   FROM #FKSCR1 A 
                  WHERE A.DEPART<>'' OR A.LISTEART<>'';                        -- AND (Dbo.Isd_SegmentFind(SEGMENT,0,2)='') AND (Dbo.Isd_SegmentFind(SEGMENT,0,3)='')
                                                                               -- Rasti kur mjafton nje segment eshte hedhur me dore 
             END;
             
       PRINT '15.2     Modifikim sipas skemes Dep/List tek Referenca detaje - Fund';



/* RAISERROR (N'16.1     Modifikim sipas skemes Dep/List tek Sherbim', 0, 1) WITH NOWAIT;

-- Pse mungon Dbo.Isd_SegmentFind(A.KOD,0,4) tek LLOGARI ...? 15.04.2016

          IF @ImplicidDepListSherb=1 
             BEGIN
                 UPDATE A 
                    SET KOD      = LLOGARIPK+'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(A.DEPART,'')   END + 
                                             '.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(A.LISTEART,'') END + 
                                             '.'+dbo.Isd_SegmentFind(A.KOD,0,4)+
                                             '.'+dbo.Isd_SegmentFind(A.KOD,0,5),
                        LLOGARI  = dbo.Isd_SegmentsToKodAF(
                                   LLOGARIPK+'.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,2)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,2) ELSE ISNULL(A.DEPART,'')   END + 
                                             '.'+CASE WHEN Dbo.Isd_SegmentFind(A.KOD,0,3)<>'' THEN Dbo.Isd_SegmentFind(A.KOD,0,3) ELSE ISNULL(A.LISTEART,'') END)
                   FROM #FKSCR1 A 
                  WHERE (A.DEPART<>'' OR A.LISTEART<>'') AND ISNULL(A.TIPKLLREF,'')='R';  -- AND (Dbo.Isd_SegmentFind(SEGMENT,0,2)='') AND (Dbo.Isd_SegmentFind(SEGMENT,0,3)='')
                                                                                          -- Rasti kur mjafton nje segment eshte hedhur me dore 
             END;
             
       PRINT '16.2     Modifikim sipas skemes Dep/List tek Sherbim - Fund';   */
       
       

         IF  OBJECT_ID('TempDB..#FJ') IS NOT NULL
             DROP TABLE #FJ;

         SET @TimeEn = CONVERT(Varchar(10),GETDATE(),108)
         SET @TimeDi = CONVERT(Varchar(10),DATEADD(SECOND,DATEDIFF(SECOND,@TimeSt,GETDATE()),'2001-01-01 00:00:00'),108)



   RAISERROR (N'Faza 1   Gjenerimi dokumentave FK nga %s.                                 %s   %s', 0, 1, @DokName, @TimeEn, @TimeDi) WITH NOWAIT



        EXEC [dbo].[Isd_KalimLMDbF] @PTip,@PNrRendor,@PTableNameTmp   -- @PNrRendor Nuk Perdoret





GO
