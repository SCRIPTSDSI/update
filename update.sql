
ALTER   Procedure [dbo].[Isd_AppendRowsFtStornim]
(
 @pDbName      Varchar(30), 
 @pTableName   Varchar(30),
 @pTable       Varchar(20),
 @pKMag        Varchar(20),
 @pWhere       Varchar(MAX),
 @pNrRendor    Int,
 @pGrupuar     Int,
 @pZerim       Int                 --   0: Analitik,   1: Grupuar
)

As

         SET NOCOUNT ON;

-- EXEC dbo.Isd_AppendRowsFtStornim 'EHW21S','FJ','#ProveKot', 'PG1', 'NRD IN (1406088,1406092,1406093)',1406088,1,1;    SELECT * FROM #ProveKot;

     DECLARE @sTable       Varchar(20),
			 @sKMag        Varchar(20),
		     @sWhere       Varchar(MAX),
             @NrRendor     Int,
			 @iGrupuar     Int,
			 @iZerim       Int,
	         @sSql         Varchar(MAX),
			 @Fields       Varchar(MAX),
			 @Fields2      Varchar(Max),
			 @sList        Varchar(Max),
			 @sFld         Varchar(30),
			 @sFldName     Varchar(30),
			 @sdBase       Varchar(50),
			 @sdbName      Varchar(50),
			 @sTableName   Varchar(30),
			 @sTableTmp    Varchar(30),
			 @i            Int,
			 @j            Int;

          IF OBJECT_ID('Tempdb..#tb1FtScr') IS NOT NULL
	         DROP TABLE #tb1FtScr;
          IF OBJECT_ID('Tempdb..#tb2FtScr') IS NOT NULL
	         DROP TABLE #tb2FtScr;
          IF OBJECT_ID('Tempdb..#tb3FtScr') IS NOT NULL
	         DROP TABLE #tb3FtScr;
          IF OBJECT_ID('Tempdb..#tb4FtScr') IS NOT NULL
	         DROP TABLE #tb4FtScr;
          IF OBJECT_ID('Tempdb..#tb5FtScr') IS NOT NULL
	         DROP TABLE #tb5FtScr;
         SET @sTable     = @pTable;
         SET @NrRendor   = @pNrRendor;
		 SET @sKMag      = @pKMag;
		 SET @sWhere     = @pWhere;
		 SET @iGrupuar   = @pGrupuar;
		 SET @iZerim     = @pZerim;
		 SET @sdBase     = db_Name();
		 SET @sdbName    = @pDbName;
		 SET @sTableName = @pTableName+'SCR';


--    SELECT * INTO #tb1FtScr	FROM FJSCR WHERE 1=2;
--    ALTER TABLE #tb1FtScr DROP COLUMN NRRENDOR
--    ALTER TABLE #tb1FtScr ADD NRRENDOR Int null
     SELECT NRRENDOR=0 INTO #tb1FtScr FROM FJSCR WHERE 1=2;


      SELECT * INTO #tb2FtScr  FROM FJSCR    WHERE 1=2;
      SELECT * INTO #tb3FtScr  FROM FFSCR    WHERE 1=2;
      SELECT * INTO #tb4FtScr  FROM SMSCR    WHERE 1=2;
      SELECT * INTO #tb5FtScr  FROM SMBAKSCR WHERE 1=2;


         SET @Fields = '';
        EXEC dbo.Isd_spFields2Tables @sdbName, @sdBase, @sTableName, @sTableName, 'NRRENDOR,NRD,TAGNR,TAGRND,', @Fields Output;


--       @Fields2 = Lista e fushave dhe vlerat qe behen insert (te gjitha fushat, plus sasi dhe vlera te inversuar)

		 SET @Fields2 = ','+@Fields+',';
         SET @sList   = 'SASI,VLPATVSH,VLTVSH,VLERAM,VLERABS,SASIFR,VLERAFR,SASIKONV,SASIPAKO,VLERASM'; -- Fushat qe inversohen
		 SET @i = 1;
		 SET @j = LEN(@sList) - LEN(REPLACE(@sList,',','')) + 1;
		 WHILE @i<=@j
		   BEGIN
		     SET @sFld = LTrim(RTrim(dbo.Isd_StringInListStr(@sList,@i,',')));
			  IF @sFld<>''
			     SET @Fields2 = REPLACE(@Fields2,','+@sFld+',',',0-'+@sFld+',');
				 
             SET @i = @i + 1;
		   END;

         SET @Fields2 = SUBSTRING(SUBSTRING(@Fields2,1,LEN(@Fields2)-1),2,LEN(@Fields2)); -- Heqim presjen ne fillim dhe fund.


	      IF @sdbName<>'' 
	         SET @sdbName = @sdbName+'..';



         SET @sSql = '
      
	  INSERT INTO #tb1FtScr
	        (NRRENDOR)
      SELECT NRRENDOR
	    FROM '+@sdbName+@sTableName+' 
       WHERE 1=1; ';                    -- AND NRD IN (1406088,1406092,1406093)

	      IF @sWhere<>''
		     SET @sSql = REPLACE(@sSql,'1=1',@sWhere);

	    EXEC (@sSql);


          IF @sTableName='FJSCR'
			 SET @sTableTmp='#tb2FtScr'
		  ELSE
          IF @sTableName='FFSCR'
			 SET @sTableTmp='#tb3FtScr'
          ELSE
          IF @sTableName='SMSCR'
			 SET @sTableTmp='#tb4FtScr'
          ELSE
          IF @sTableName='SMBAKSCR'
			 SET @sTableTmp='#tb5FtScr';


	      IF @pGrupuar=1
		     GOTO Grupuar;





ANALITIK:


--     PRINT 'Analitik';           -- perdor ListComun, fut ne KOMENT edhe stornim se bashku me Nr,Date fature (INNER JOIN Me FJ)

		 SET @sSql = ' 
		  
	  INSERT INTO '+@sTableTmp+'
			('+@Fields +')
	  SELECT '+@Fields2+'
        FROM '+@sdbName+@sTableName+' A INNER JOIN #tb1FtScr B ON A.NRRENDOR=B.NRRENDOR
	ORDER BY A.NRD,A.NRRENDOR; ';


		EXEC (@sSql);

		GOTO FUND;





GRUPUAR:


--     PRINT 'Grupuar';

		  IF OBJECT_ID('TEMPDB..#TMPFJSCR') IS NOT NULL
			 DROP TABLE #TMPFJSCR;
		  IF OBJECT_ID('TEMPDB..#TMPFFSCR') IS NOT NULL
			 DROP TABLE #TMPFFSCR;
		  IF OBJECT_ID('TEMPDB..#TMPSMSCR') IS NOT NULL
			 DROP TABLE #TMPSMSCR;
		  IF OBJECT_ID('TEMPDB..TMPSMBAKSCR') IS NOT NULL
			 DROP TABLE #TMPSMBAKSCR;


          IF @sTableName='FJSCR'
			 SELECT * INTO #TMPFJSCR    FROM FJSCR WHERE 1=2;
          ELSE
          IF @sTableName='FFSCR'
			 SELECT * INTO #TMPFFSCR    FROM FJSCR WHERE 1=2;
          ELSE
          IF @sTableName='SMSCR'
			 SELECT * INTO #TMPSMSCR    FROM FJSCR WHERE 1=2;
          ELSE
          IF @sTableName='SMBAKSCR'
			 SELECT * INTO #TMPSMBAKSCR FROM FJSCR WHERE 1=2;


		 SET @sSql = ' 
		  
	         INSERT INTO '+'#TMP'+@sTableName+'
			       ('+@Fields +',TAGNR)
	         SELECT '+@Fields2+',T.NRRENDOR
               FROM '+@sdbName+@sTableName+' A INNER JOIN #tb1FtScr T ON A.NRRENDOR=T.NRRENDOR
	       ORDER BY A.NRD,A.NRRENDOR;';

        EXEC (@sSql);       --   PRINT @sSql;  Select * From #tb1FtScr Order By NrRendor; SELECT * FROM #TMPFJSCR Order By NrRendor;  RETURN;


        
		  IF @sTableName='FJSCR'
		     BEGIN

                 INSERT INTO #tb2FtScr
	                    (KOD,KARTLLG,KODAF,LLOGARIPK,PERSHKRIM,CMSHZB0,CMIMM,VLERAM,NJESI,SASI,CMIMBS,VLPATVSH,VLTVSH,VLERABS,PERQTVSH,NJESINV,APLTVSH,PESHANET,PESHABRT,BC,TIPKLL)

                 SELECT KOD         = CASE WHEN ISNULL(A.TIPKLL,'')='K' THEN @sKMag+'.'+ISNULL(A.KARTLLG,'')+'...' ELSE ISNULL(A.KARTLLG,'')+'....' END,
	                    KARTLLG     = ISNULL(A.KARTLLG,''),
	                    KODAF       = ISNULL(A.KARTLLG,''),
			            LLOGARIPK   = ISNULL(A.KARTLLG,''),
                        PERSHKRIM   = MAX(CASE WHEN ISNULL(A.TIPKLL,'')='K' THEN ISNULL(R1.PERSHKRIM,'')
								               WHEN ISNULL(A.TIPKLL,'')='R' THEN ISNULL(R2.PERSHKRIM,'')
			                                   WHEN ISNULL(A.TIPKLL,'')='L' THEN ISNULL(R3.PERSHKRIM,'')
								               WHEN ISNULL(A.TIPKLL,'')='X' THEN ISNULL(R4.PERSHKRIM,'')
							              END),
                        CMSHZB0     = CASE WHEN ISNULL(A.TIPKLL,'')='K' THEN MAX(R1.CMSH)  -- Kujdes, mos jape zbritje tek SelfCare
							               WHEN ISNULL(A.TIPKLL,'')='R' THEN MAX(R2.CMSH)
			                               ELSE CASE WHEN SUM(ISNULL(A.VLPATVSH,0))*SUM(ISNULL(A.SASI,0))>0 THEN SUM(ISNULL(A.VLPATVSH,0))/SUM(ISNULL(A.SASI,0)) ELSE 0 END
						              END,
                        CMIMM       = CASE WHEN ISNULL(A.TIPKLL,'')='K' THEN MAX(ISNULL(R1.KOSTMES,0))                   ELSE 0 END,
                        VLERAM      = CASE WHEN ISNULL(A.TIPKLL,'')='K' THEN SUM(ISNULL(A.SASI,0)*ISNULL(R1.KOSTMES,0))  ELSE 0 END,
                        NJESI       = MAX(ISNULL(A.NJESI,'')),
                        SASI        = SUM(ISNULL(A.SASI,0)),
	                    CMIMBS      = CASE WHEN SUM(A.VLPATVSH)*SUM(A.SASI)>0 THEN ROUND(SUM(A.VLPATVSH)/SUM(A.SASI),2) ELSE 0 END,
                        VLPATVSH    = SUM(ISNULL(A.VLPATVSH,0)),
	                    VLTVSH      = SUM(ISNULL(A.VLTVSH,0)),
	                    VLERABS     = SUM(ISNULL(A.VLERABS,0)),
			            PERQTVSH    = CASE WHEN SUM(ISNULL(A.VLPATVSH,0))*SUM(ISNULL(A.VLTVSH,0))>0 THEN (100*SUM(ISNULL(A.VLTVSH,0)))/SUM(ISNULL(A.VLTVSH,0)) ELSE 0 END,
			            NJESINV     = MAX(ISNULL(A.NJESINV,'')),
			            APLTVSH     = CAST(MAX(CASE WHEN ISNULL(A.APLTVSH,0)=1 THEN 1 ELSE 0 END) AS BIT),   -- ??
			            PESHANET    = SUM(ISNULL(A.PESHANET,0)),
			            PESHABRT    = SUM(ISNULL(A.PESHABRT,0)),
			            BC          = MAX(ISNULL(R1.BC,'')),
	                    TIPKLL      = ISNULL(A.TIPKLL,'')

                   FROM #TMPFJSCR A   LEFT  JOIN ARTIKUJ   R1 ON A.KARTLLG=R1.KOD AND A.TIPKLL='K'
					                  LEFT  JOIN SHERBIM   R2 ON A.KARTLLG=R2.KOD AND A.TIPKLL='R'
		                              LEFT  JOIN LLOGARI   R3 ON A.KARTLLG=R3.KOD AND A.TIPKLL='L'
					                  LEFT  JOIN AQKARTELA R4 ON A.KARTLLG=R4.KOD AND A.TIPKLL='X'             
               GROUP BY ISNULL(A.KARTLLG,''),ISNULL(A.TIPKLL,'')
               ORDER BY ISNULL(KARTLLG,'');

	         END;


          IF @sTableName='FFSCR'
		     BEGIN

                 INSERT INTO #tb3FtScr
	                    (KOD,KARTLLG,KODAF,LLOGARIPK,PERSHKRIM,CMSHZB0,CMIMM,VLERAM,NJESI,SASI,CMIMBS,VLPATVSH,VLTVSH,VLERABS,PERQTVSH,NJESINV,APLTVSH,PESHANET,PESHABRT,BC,TIPKLL)

                 SELECT KOD         = CASE WHEN A.TIPKLL='K' THEN @sKMag+'.'+A.KARTLLG+'...' ELSE A.KARTLLG+'....' END,
	                    A.KARTLLG,
	                    KODAF       = A.KARTLLG,
			            LLOGARIPK   = A.KARTLLG,
                        PERSHKRIM   = MAX(CASE WHEN A.TIPKLL='K' THEN R1.PERSHKRIM
								               WHEN A.TIPKLL='R' THEN R2.PERSHKRIM
			                                   WHEN A.TIPKLL='L' THEN R3.PERSHKRIM
								               WHEN A.TIPKLL='X' THEN R4.PERSHKRIM
							              END),
                        CMSHZB0     = CASE WHEN A.TIPKLL='K' THEN MAX(R1.CMSH)  -- Kujdes, mos jape zbritje tek SelfCare
							               WHEN A.TIPKLL='R' THEN MAX(R2.CMSH)
			                               ELSE CASE WHEN SUM(A.VLPATVSH)*SUM(A.SASI)>0 THEN SUM(A.VLPATVSH)/SUM(A.SASI) ELSE 0 END
						              END,
                        CMIMM       = CASE WHEN A.TIPKLL='K' THEN MAX(R1.KOSTMES)        ELSE 0 END,
                        VLERAM      = CASE WHEN A.TIPKLL='K' THEN SUM(A.SASI*R1.KOSTMES) ELSE 0 END,
                        NJESI       = MAX(A.NJESI),
                        SASI        = SUM(A.SASI),
	                    CMIMBS      = CASE WHEN SUM(A.VLPATVSH)*SUM(A.SASI)>0 THEN ROUND(SUM(A.VLPATVSH)/SUM(A.SASI),2) ELSE 0 END,
                        VLPATVSH    = SUM(A.VLPATVSH),
	                    VLTVSH      = SUM(A.VLTVSH),
	                    VLERABS     = SUM(A.VLERABS),
			            PERQTVSH    = CASE WHEN SUM(A.VLPATVSH)*SUM(A.VLTVSH)>0 THEN (100*SUM(A.VLTVSH))/SUM(A.VLTVSH) ELSE 0 END,
			            NJESINV     = MAX(A.NJESINV),
			            APLTVSH     = CAST(MAX(CASE WHEN A.APLTVSH=1 THEN 1 ELSE 0 END) AS BIT),   -- ??
			            PESHANET    = SUM(ISNULL(A.PESHANET,0)),
			            PESHABRT    = SUM(ISNULL(A.PESHABRT,0)),
			            BC          = MAX(R1.BC),
	                    A.TIPKLL 

                   FROM #TMPFFSCR A   LEFT  JOIN ARTIKUJ   R1 ON A.KARTLLG=R1.KOD AND A.TIPKLL='K'
					                  LEFT  JOIN SHERBIM   R2 ON A.KARTLLG=R2.KOD AND A.TIPKLL='R'
		                              LEFT  JOIN LLOGARI   R3 ON A.KARTLLG=R3.KOD AND A.TIPKLL='L'
					                  LEFT  JOIN AQKARTELA R4 ON A.KARTLLG=R4.KOD AND A.TIPKLL='X'             
               GROUP BY A.KARTLLG,A.TIPKLL 
               ORDER BY KARTLLG;

	         END;


          IF @sTableName='SMSCR'
		     BEGIN

                 INSERT INTO #tb4FtScr
	                    (KOD,KARTLLG,KODAF,LLOGARIPK,PERSHKRIM,CMSHZB0,CMIMM,VLERAM,NJESI,SASI,CMIMBS,VLPATVSH,VLTVSH,VLERABS,PERQTVSH,NJESINV,APLTVSH,PESHANET,PESHABRT,BC,TIPKLL,VLERASM)

                 SELECT KOD         = CASE WHEN A.TIPKLL='K' THEN @sKMag+'.'+A.KARTLLG+'...' ELSE A.KARTLLG+'....' END,
	                    A.KARTLLG,
	                    KODAF       = A.KARTLLG,
			            LLOGARIPK   = A.KARTLLG,
                        PERSHKRIM   = MAX(CASE WHEN A.TIPKLL='K' THEN R1.PERSHKRIM
								               WHEN A.TIPKLL='R' THEN R2.PERSHKRIM
			                                   WHEN A.TIPKLL='L' THEN R3.PERSHKRIM
								               WHEN A.TIPKLL='X' THEN R4.PERSHKRIM
							              END),
                        CMSHZB0     = CASE WHEN A.TIPKLL='K' THEN MAX(R1.CMSH)  -- Kujdes, mos jape zbritje tek SelfCare
							               WHEN A.TIPKLL='R' THEN MAX(R2.CMSH)
			                               ELSE CASE WHEN SUM(A.VLPATVSH)*SUM(A.SASI)>0 THEN SUM(A.VLPATVSH)/SUM(A.SASI) ELSE 0 END
						              END,
                        CMIMM       = CASE WHEN A.TIPKLL='K' THEN MAX(R1.KOSTMES)        ELSE 0 END,
                        VLERAM      = CASE WHEN A.TIPKLL='K' THEN SUM(A.SASI*R1.KOSTMES) ELSE 0 END,
                        NJESI       = MAX(A.NJESI),
                        SASI        = SUM(A.SASI),
	                    CMIMBS      = CASE WHEN SUM(A.VLPATVSH)*SUM(A.SASI)>0 THEN ROUND(SUM(A.VLPATVSH)/SUM(A.SASI),2) ELSE 0 END,
                        VLPATVSH    = SUM(A.VLPATVSH),
	                    VLTVSH      = SUM(A.VLTVSH),
	                    VLERABS     = SUM(A.VLERABS),
			            PERQTVSH    = CASE WHEN SUM(A.VLPATVSH)*SUM(A.VLTVSH)>0 THEN (100*SUM(A.VLTVSH))/SUM(A.VLTVSH) ELSE 0 END,
			            NJESINV     = MAX(A.NJESINV),
			            APLTVSH     = CAST(MAX(CASE WHEN A.APLTVSH=1 THEN 1 ELSE 0 END) AS BIT),   -- ??
			            PESHANET    = SUM(ISNULL(A.PESHANET,0)),
			            PESHABRT    = SUM(ISNULL(A.PESHABRT,0)),
			            BC          = MAX(R1.BC),
	                    A.TIPKLL,
						VLERASM     = SUM(A.VLERASM)

                   FROM #TMPSMSCR A   LEFT  JOIN ARTIKUJ   R1 ON A.KARTLLG=R1.KOD AND A.TIPKLL='K'
					                  LEFT  JOIN SHERBIM   R2 ON A.KARTLLG=R2.KOD AND A.TIPKLL='R'
		                              LEFT  JOIN LLOGARI   R3 ON A.KARTLLG=R3.KOD AND A.TIPKLL='L'
					                  LEFT  JOIN AQKARTELA R4 ON A.KARTLLG=R4.KOD AND A.TIPKLL='X'             
               GROUP BY A.KARTLLG,A.TIPKLL 
               ORDER BY KARTLLG;

	         END;


          IF @sTableName='SMBAKSCR'
		     BEGIN

                 INSERT INTO #tb5FtScr
	                    (KOD,KARTLLG,KODAF,LLOGARIPK,PERSHKRIM,CMSHZB0,CMIMM,VLERAM,NJESI,SASI,CMIMBS,VLPATVSH,VLTVSH,VLERABS,PERQTVSH,NJESINV,APLTVSH,PESHANET,PESHABRT,BC,TIPKLL,VLERASM)

                 SELECT KOD         = CASE WHEN A.TIPKLL='K' THEN @sKMag+'.'+A.KARTLLG+'...' ELSE A.KARTLLG+'....' END,
	                    A.KARTLLG,
	                    KODAF       = A.KARTLLG,
			            LLOGARIPK   = A.KARTLLG,
                        PERSHKRIM   = MAX(CASE WHEN A.TIPKLL='K' THEN R1.PERSHKRIM
								               WHEN A.TIPKLL='R' THEN R2.PERSHKRIM
			                                   WHEN A.TIPKLL='L' THEN R3.PERSHKRIM
								               WHEN A.TIPKLL='X' THEN R4.PERSHKRIM
							              END),
                        CMSHZB0     = CASE WHEN A.TIPKLL='K' THEN MAX(R1.CMSH)  -- Kujdes, mos jape zbritje tek SelfCare
							               WHEN A.TIPKLL='R' THEN MAX(R2.CMSH)
			                               ELSE CASE WHEN SUM(A.VLPATVSH)*SUM(A.SASI)>0 THEN SUM(A.VLPATVSH)/SUM(A.SASI) ELSE 0 END
						              END,
                        CMIMM       = CASE WHEN A.TIPKLL='K' THEN MAX(R1.KOSTMES)        ELSE 0 END,
                        VLERAM      = CASE WHEN A.TIPKLL='K' THEN SUM(A.SASI*R1.KOSTMES) ELSE 0 END,
                        NJESI       = MAX(A.NJESI),
                        SASI        = SUM(A.SASI),
	                    CMIMBS      = CASE WHEN SUM(A.VLPATVSH)*SUM(A.SASI)>0 THEN ROUND(SUM(A.VLPATVSH)/SUM(A.SASI),2) ELSE 0 END,
                        VLPATVSH    = SUM(A.VLPATVSH),
	                    VLTVSH      = SUM(A.VLTVSH),
	                    VLERABS     = SUM(A.VLERABS),
			            PERQTVSH    = CASE WHEN SUM(A.VLPATVSH)*SUM(A.VLTVSH)>0 THEN (100*SUM(A.VLTVSH))/SUM(A.VLTVSH) ELSE 0 END,
			            
			            NJESINV     = MAX(A.NJESINV),
			            APLTVSH     = CAST(MAX(CASE WHEN A.APLTVSH=1 THEN 1 ELSE 0 END) AS BIT),   -- ??
			            PESHANET    = SUM(ISNULL(A.PESHANET,0)),
			            PESHABRT    = SUM(ISNULL(A.PESHABRT,0)),
			            BC          = MAX(R1.BC),
	                    A.TIPKLL,
						VLERASM     = SUM(A.VLERASM)

                   FROM #TMPSMBAKSCR A LEFT  JOIN ARTIKUJ   R1 ON A.KARTLLG=R1.KOD AND A.TIPKLL='K'
					                   LEFT  JOIN SHERBIM   R2 ON A.KARTLLG=R2.KOD AND A.TIPKLL='R'
		                               LEFT  JOIN LLOGARI   R3 ON A.KARTLLG=R3.KOD AND A.TIPKLL='L'
					                   LEFT  JOIN AQKARTELA R4 ON A.KARTLLG=R4.KOD AND A.TIPKLL='X'             
               GROUP BY A.KARTLLG,A.TIPKLL 
               ORDER BY KARTLLG;

	         END;



         SET @sSql = '
	  UPDATE A
	     SET KOEFSHB = 1, VLTAX   = 0, PERQKMS = 0, VLERAKMS = 0, APLINVESTIM=0, PROMOC=0, PROMOCTIP='''', PROMOCKOD='''', RIMBURSIM=0, KONVERTART=0,
			 KOMENT  = ''Stornim'',	NRD = '+CAST(@NrRendor AS VARCHAR(20))+'     -- SASIFR  = 0,	VLERAFR = 0, TIPFR = 0, 
        FROM '+@sTableTmp+' A; ';

       EXEC (@sSql);




FUND:

          IF @iZerim=1
	         EXEC ('DELETE FROM '+@sTable);


		 SET @sSql = ' 

      INSERT INTO '+@sTable+'
	        ('+@Fields+')
	  SELECT '+@Fields+'
		FROM '+@sTableTmp+' A
	ORDER BY A.NRD,A.NRRENDOR; ';

        EXEC (@sSql);


         SET @sSql = 'UPDATE '+@sTable+' SET NRD='+CAST(CAST(@NrRendor AS BigInt) AS VARCHAR(20));

        EXEC (@sSql);

--      EXEC ('SELECT * FROM '+@sTable);

		  IF OBJECT_ID('TEMPDB..#TMPFJSCR')   IS NOT NULL
			 DROP TABLE #TMPFJSCR;
		  IF OBJECT_ID('TEMPDB..#TMPFFSCR')   IS NOT NULL
			 DROP TABLE #TMPFFSCR;
		  IF OBJECT_ID('TEMPDB..#TMPSMSCR')   IS NOT NULL
			 DROP TABLE #TMPSMSCR;
		  IF OBJECT_ID('TEMPDB..TMPSMBAKSCR') IS NOT NULL
			 DROP TABLE #TMPSMBAKSCR;

          IF OBJECT_ID('TEMPDB..#tb1FtScr')   IS NOT NULL
	         DROP TABLE #tb1FtScr;
          IF OBJECT_ID('TEMPDB..#tb2FtScr')   IS NOT NULL
	         DROP TABLE #tb2FtScr;
          IF OBJECT_ID('TEMPDB..#tb3FtScr')   IS NOT NULL
	         DROP TABLE #tb3FtScr;
          IF OBJECT_ID('TEMPDB..#tb4FtScr')   IS NOT NULL
	         DROP TABLE #tb4FtScr;
          IF OBJECT_ID('TEMPDB..#tb5FtScr')   IS NOT NULL
	         DROP TABLE #tb5FtScr;

