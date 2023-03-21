SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--EXEC [Isd_KalimLM_ABEG] @PTip='A', @PNrRendor=0, @PSQLFilter='A.DATEDOK>=DBO.DATEVALUE(''01/01/2011'') AND A.DATEDOK<=DBO.DATEVALUE(''31/01/2011'')', @PTableNameTmp='# #AAAA';

CREATE Procedure [dbo].[Isd_KalimLM_ABEG]
 (
  @PTip          Varchar(10),
  @PNrRendor     Int,          -- Nuk Perdoret
  @PSQLFilter    Varchar(5000),
  @PTableNameTmp Varchar(40)
  )
AS


         IF  CHARINDEX(@PTip,'ABEG')=0          -- ARKE BANKE VS    DG
             RETURN;


         SET NOCOUNT ON;

     DECLARE @TimeSt        DateTime,
             @TimeDi        Varchar(20),
             @TimeEn        Varchar(10),
             @DokName       Varchar(30),
             @Where         Varchar(5000),
             @SQLFilterUn1  Varchar(MAX); 
        
         SET @TimeSt      = GETDATE();
         SET @TimeDi      = CONVERT(Varchar(10),@TimeSt,108);
         SET @DokName     = LTrim(RTrim(Substring('ARKA ,BANKA,VS   ,DG   ',6*CHARINDEX(@PTip,'ABEG')-5,5)));
         SET @Where       = @PSqlFilter;



   RAISERROR (N'
Faza 1   Gjenerimi dokumentave FK nga %s.                                %s', 0, 1, @DokName, @TimeDi) WITH NOWAIT;



         IF  CHARINDEX(@PTip,'ABE')<>0       -- ARKE BANKE VS

             BEGIN

                 DECLARE @ProcName      Varchar(30),
                         @VExtra1       Varchar(5000),
                         @VExtra2       Varchar(5000),
                         @VOrder        Varchar(5000);

                     SET @ProcName = Left(@DokName,2)+'_KALIMLM';


		              IF (@PTip='A') or (@PTip='B') 
			             BEGIN
				           SET @VExtra1 = '          SHENIM1, SHENIM2,TIPDOK, NUMDOK, KODAB, '''','
				           SET @VExtra2 = '          MSGERROR    = A.TIPDOK+'' ''+ISNULL(A.KODAB,'''')+'', nr. ''+CONVERT(VARCHAR,CONVERT(BIGINT,A.NUMDOK))+'' ''+CONVERT(VARCHAR,A.DATEDOK,4), '
				           SET @VOrder  = ' ORDER BY DATEDOK, TIPDOK, NUMDOK, A.NRRENDOR '
			             END
		              ELSE
			             BEGIN
				           SET @VExtra1 = '          PERSHKRIM1, PERSHKRIM2, TIPDOK=''VS'', NUMDOK=NRDOK, '''',ISNULL(DST,''''),'
				           SET @VExtra2 = '          MSGERROR    = ''SP''+'' ''+ISNULL(FIRSTDOK,'''')+'', nr. ''+CONVERT(VARCHAR,CONVERT(BIGINT,A.NRDOK))+'' ''+CONVERT(VARCHAR,A.DATEDOK,4), '
				           SET @VOrder  = ' ORDER BY DATEDOK, TIPDOK, NUMDOK, A.NRRENDOR '
			             END;



               RAISERROR (N'01.1     Krijim Koka FK', 0, 1) WITH NOWAIT;

		             SET @SQLFilterUn1 = 
' 
                  INSERT INTO #FK
						(KODNENDITAR, NRDFK, NRDOK, DATEDOK, 
				 		 KMON, KURS1, KURS2, ORG, FIRSTDOK, 
						 PERSHKRIM1, PERSHKRIM2, TIPDOK, NUMDOK, REFERDOK,DST, 
						 KMAG, FORMAT, KLASIFIKIM, TAGNR) 
				  SELECT KODNENDITAR = '''',
				         NRDFK       = 0,
				         NRDOK       = 0,
				         DATEDOK, KMON, KURS1, KURS2, 
                         ORG         = '''+@PTip+''', 
                         FIRSTDOK,'+ 
                         @VExtra1+'
                         KMAG        = '''',
                         FORMAT      = '''',
                         KLASIFIKIM  = '''',
                         TAGNR       = NRRENDOR 
                    FROM '+@DokName+' A '
                          +@Where
                          +@VOrder

		            EXEC (@SQLFilterUn1);

                   PRINT '01.2     Mbaroi Krijim Koka FK';



               RAISERROR (N'02.1     Krijim Rrjeshta Scr', 0, 1) WITH NOWAIT;

                     SET @SQLFilterUn1 ='
	             
                  INSERT INTO #FKSCR 
						(KOD, LLOGARI, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
                         KODREF,TIPKLLREF, DB, KR, DBKRMV, ORDPOST, MSGERROR, DSCERROR, FADESTIN, FAART, TAGNR) 
                  SELECT C.KOD, C.LLOGARI, C.LLOGARI, 
						 PERSHKRIM   = B.PERSHKRIM, 
						 KOMENT      = LEFT(B.KOMENT,100), 	B.KMON, B.KURS1, B.KURS2, B.TREGDK, 
                         KODREF      = CASE WHEN B.RRAB=''K'' THEN A.KODAB	      ELSE dbo.Isd_SegmentFind(B.KOD,0,1) END,
                         TIPKLLREF   = CASE WHEN B.RRAB=''K'' THEN '''+@PTip+'''  ELSE B.TIPKLL	                      END,
                         DB          = B.DB, 
                         KR          = B.KR, 
                         DBKRMV      = B.DBKRMV, 
						 ORDPOST     = CASE WHEN B.RRAB  =''K'' THEN 0 
						                    WHEN B.TREGDK=''D'' THEN 1 
						                    ELSE                     2 
						               END, '+
						 @VExtra2+'
						 DSCERROR    = B.KODAF+'' - ''+ISNULL(B.PERSHKRIM,''''), 
						 FADESTIN    = B.FADESTIN, 
						 FAART       = B.FAART, 
						 TAGNR       = A.NRRENDOR 
					FROM '+@DokName+' A INNER JOIN '+@DokName +'SCR  B ON A.NRRENDOR=B.NRD 
						                INNER JOIN '+@ProcName+'     C ON B.NRD=C.NRD AND B.NRRENDOR=C.NRRENDOR '+
						 @Where+' 
				ORDER BY A.NRRENDOR ';

		              IF NOT ((@PTip='A') or (@PTip='B')) 
                         BEGIN
			               SET @SQLFilterUn1 = Replace(@SQLFilterUn1,'B.RRAB', '''z_z_z''');
			               SET @SQLFilterUn1 = Replace(@SQLFilterUn1,'A.KODAB','''''');
                         END;

		            EXEC (@SQLFilterUn1);

                   PRINT '02.2     Mbaroi Krijim Rrjeshta Scr';

             END;


         
         IF  @PTip='G'                      -- DG

             BEGIN

               RAISERROR (N'01.1     Krijim Koka FK', 0, 1) WITH NOWAIT;

                 DECLARE @KalimDGLMValut Bit;
                  SELECT @KalimDGLMValut = KALIMFFLMVAL FROM CONFIGLM;

			         SET @SQLFilterUn1 = '
                  INSERT INTO #FK 
					    (KODNENDITAR, NRDFK, NRDOK, DATEDOK, PERSHKRIM1, PERSHKRIM2,  
						 KMON, KURS1, KURS2, ORG, FIRSTDOK, TIPDOK, NUMDOK, REFERDOK, DST,  
						 KMAG, FORMAT, KLASIFIKIM, TAGNR)  
				  SELECT KODNENDITAR = '''', 
				         NRDFK       = 0, 
				         NRDOK       = 0, DATEDOK, SHENIM1, SHENIM2, KMON, KURS1, KURS2, 
						 ORG         = '''+@PTip+''', FIRSTDOK,
						 TIPDOK      = '''+@DokName+''', 
						 NUMDOK      = NRDOK, 
						 REFERDOK    = A.KOD,
						 DST         = '''',
                         KMAG        = '''',
                         FORMAT      = '''',
                         KLASIFIKIM  = '''',
                         TAGNR       = NRRENDOR 
					FROM '+@DokName+' A '+@Where+'
				ORDER BY DATEDOK,NRDOK ';

                    EXEC (@SqlFilterUn1);

                   PRINT '01.2     Mbaroi Krijim Koka FK';



               RAISERROR (N'02.1     Krijim Rrjeshtave Scr /Db', 0, 1) WITH NOWAIT;

                     SET @SQLFilterUn1 = '
                  INSERT INTO #FKSCR
                        (KOD, LLOGARI, LLOGARIPK, PERSHKRIM,KOMENT, KMON, KURS1, KURS2, TREGDK, 
                         KODREF,TIPKLLREF, DB, KR, DBKRMV, ORDPOST,KMAG, MSGERROR, DSCERROR, TAGNR) 
                               
                  SELECT KOD         = C.LLOGARIDB                                                                                                            +''.''+ -- ndryshuar 23.08.2016
                                       CASE WHEN dbo.Isd_SegmentFind(KARTLLG,0,2)='''' THEN MAX(ISNULL(C.DEP,''''))  ELSE dbo.Isd_SegmentFind(KARTLLG,0,2) END+''.''+  
                                       CASE WHEN dbo.Isd_SegmentFind(KARTLLG,0,3)='''' THEN MAX(ISNULL(C.LIST,'''')) ELSE dbo.Isd_SegmentFind(KARTLLG,0,3) END+''.''+
                                       dbo.Isd_SegmentFind(KARTLLG,0,4)                                                                                       +''.''+
                                       MAX(ISNULL(A.KMON,'''')),
                      -- C.LLOGARIDB+''.''+dbo.Isd_SegmentFind(KARTLLG,0,2)+''.''+dbo.Isd_SegmentFind(KARTLLG,0,3)+''.''+dbo.Isd_SegmentFind(KARTLLG,0,4)+''.''+MAX(ISNULL(A.KMON,'''')), -- ndryshuar 23.08.2016   

                         LLOGARI     = C.LLOGARIDB, 
                         LLOGARIPK   = C.LLOGARIDB, 
						 PERSHKRIM   = MAX(ISNULL(SHENIM1,'''')), 
						 KOMENT      = KARTLLG, 
						 KMON        = MAX(ISNULL(A.KMON,'''')), 
						 KURS1       = MAX(A.KURS1), 
						 KURS2       = MAX(A.KURS2), 
						 TREGDK      = ''D'',

                         KODREF      = C.LLOGARIDB,
                         TIPKLLREF   = '''+@PTip+''',

						 DB          = MAX(A.KURS2/A.KURS1) * CASE WHEN 1=1 THEN SUM(VLERATAX) ELSE 0 END,
						 KR          = MAX(A.KURS2/A.KURS1) * CASE WHEN 1=2 THEN SUM(VLERATAX) ELSE 0 END,
						 DBKRMV      = CASE WHEN 1=1 THEN SUM(   VLERATAX*A.KURS2/A.KURS1) ELSE SUM(0-(VLERATAX*A.KURS2/A.KURS1)) END,
                         ORDPOST     = 0+0+0,
                         KMAG        = '''',
						 MSGERROR    = '''+@DokName+'''+'', nr. ''+CONVERT(VARCHAR,CONVERT(BIGINT,MAX(A.NRDOK)))+'',''+CONVERT(VARCHAR,MAX(DATEDOK),4), 
						 DSCERROR    = ''Llog.Tatim Db'', 
						 TAGNR       = A.NRRENDOR 
					FROM '+@DokName+' A INNER JOIN '+@DokName+'SCR B ON A.NRRENDOR=B.NRD 
                                        INNER JOIN TATIM           C ON C.KOD=B.TATIM '
                         +@Where+'
                GROUP BY A.NRRENDOR,C.LLOGARIDB,KARTLLG
				ORDER BY A.NRRENDOR,C.LLOGARIDB ';

                      IF @KalimDGLMValut=0
                         BEGIN
  			               SET  @SqlFilterUn1 = Replace(@SqlFilterUn1,'MAX(ISNULL(A.KMON,''''))','''''');
  			               SET  @SqlFilterUn1 = Replace(@SqlFilterUn1,'MAX(A.KURS1)','1');
  			               SET  @SqlFilterUn1 = Replace(@SqlFilterUn1,'MAX(A.KURS2)','1');
                         END 
                      ELSE
                         BEGIN
  			               SET  @SqlFilterUn1 = Replace(@SqlFilterUn1,'MAX(A.KURS2/A.KURS1)','1');
  			             END  ;

                    EXEC (@SqlFilterUn1);

                   PRINT '02.2     Mbaroi Krijim Rrjeshtave Scr /Db';



               RAISERROR (N'02.3     Krijim Rrjeshtave Scr /Kr', 0, 1) WITH NOWAIT;

			         SET  @SQLFilterUn1 = Replace(@SQLFilterUn1,'= C.LLOGARIDB',        '= C.LLOGARIKR')
			         SET  @SQLFilterUn1 = Replace(@SQLFilterUn1,',C.LLOGARIDB',         ',C.LLOGARIKR')
			         SET  @SqlFilterUn1 = Replace(@SqlFilterUn1,'= ''D'',',             '= ''K'',')
			         SET  @SqlFilterUn1 = Replace(@SqlFilterUn1,'= ''Llog.Tatim Db'',', '= ''Llog.Tatim Kr'',')
			         SET  @SqlFilterUn1 = Replace(@SqlFilterUn1,'= 0+0+0,',             '= 1,')
			         SET  @SqlFilterUn1 = Replace(@SqlFilterUn1,'WHEN 1=',              'WHEN 2=')
                    EXEC (@SqlFilterUn1);

                   PRINT       '02.4     Mbaroi Krijim Rrjeshtave Scr /Kr';

             END;
  


         SET @TimeEn = CONVERT(Varchar(10),GETDATE(),108);
         SET @TimeDi = CONVERT(Varchar(10),DateAdd(Second,DATEDIFF(Second,@TimeSt,GETDATE()),'2001-01-01 00:00:00'),108);



   RAISERROR (N'Faza 1   Fund Gjenerimi dokumentave FK nga %s.                            %s   %s', 0, 1, @DokName, @TimeEn, @TimeDi) WITH NOWAIT;

   EXEC ('SELECT * FROM '+@PTableNameTmp);

        EXEC [dbo].[Isd_KalimLMDbF] @PTip,@PNrRendor,@PTableNameTmp;   -- @PNrRendor Nuk Perdoret


GO
