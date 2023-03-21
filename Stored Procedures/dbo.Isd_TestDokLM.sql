SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   procedure [dbo].[Isd_TestDokLM]
(
  @pDateKp    Varchar(20),
  @pDateKs    Varchar(20),
  @pTNames    Varchar(1000),
  @pTestVlere Float,
  @pTestTable Varchar(30)
)
AS

--        IF OBJECT_ID('TempDB..#TestDok') IS NOT NULL
--           DROP TABLE #TestDok;
--    SELECT Dok      = REPLICATE('',20),  Test      = REPLICATE('',30),  ErrorDok   = REPLICATE('',100), ErrorMsg   = REPLICATE('',100),
--           ErrorRef = REPLICATE('',100), TableName = REPLICATE('',100), ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(0 AS BIGINT), NrRendor = 0
--      INTO #TestDok     
--     WHERE 1=2;
--      EXEC dbo.Isd_TestDokLM '01/01/2010','31/12/2012','LM',0.01,'#TestDok';

-- Test 1.     Test ARKA
-- Test 2.     Test BANKA
-- Test 3.     Test VS
-- Test 4.     Test FK
-- Test 5.     Test VSST
-- Test 6.     Test FKST

     DECLARE @DateKp      DateTime,
             @DateKs      DateTime,
             @TestVlere   Float,
             @TestTable   Varchar(30),
             @ErrorOrd    Varchar(100),
             @TableName   Varchar(30),
             @Dok         Varchar(20),
             @sSql        Varchar(MAX);

         SET @DateKp    = dbo.DateValue(@PDateKp);
         SET @DateKs    = dbo.DateValue(@PDateKs);
         SET @TestVlere = @pTestVlere;
         SET @TestTable = @pTestTable; 

         IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,LM,ARKA,BANKA,VS,FK,VSST,FKST','')=''
             RETURN;

-- Inicializimi
          IF OBJECT_ID('TempDB..#TestLMDok') IS NOT NULL
             DROP TABLE #TestLMDok; 
          IF OBJECT_ID('TempDB..#LMTestAR') IS NOT NULL
             DROP TABLE #LMTestAR; 
          IF OBJECT_ID('TempDB..#LMTestBA') IS NOT NULL
             DROP TABLE #LMTestBA; 
          IF OBJECT_ID('TempDB..#LMTestVS') IS NOT NULL
             DROP TABLE #LMTestVS; 
          IF OBJECT_ID('TempDB..#LMTestFK') IS NOT NULL
             DROP TABLE #LMTestFK; 
          IF OBJECT_ID('TempDB..#LMTestVT') IS NOT NULL
             DROP TABLE #LMTestVT; 
          IF OBJECT_ID('TempDB..#LMTestFT') IS NOT NULL
             DROP TABLE #LMTestFT;

          IF @TestVlere<=0
             SET @TestVlere = 0.01;

      SELECT Dok      = REPLICATE('',20),  Test      = REPLICATE('',30),  ErrorDok   = REPLICATE('',100), ErrorMsg   = REPLICATE('',100),
             ErrorRef = REPLICATE('',100), TableName = REPLICATE('',100), ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(0 AS BIGINT), NrRendor = 0
        INTO #TestLMDok    
       WHERE 1=2;


-- T1 ----------------------      A R K A     -------------------------

      SELECT NRRENDOR
        INTO #LMTestAR
        FROM ARKA
       WHERE DateDok>=@DateKp AND DateDok<=@DateKs;

         SET @TableName = 'ARKA';
         SET @ErrorOrd  = 'Dok '+@TableName+' ';
         SET @Dok       = 'DOK';


    IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,LM,'+@TableName,'')<>''
        BEGIN
			 INSERT INTO #TestLMDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @TableName,'','','','',@TableName,0,@ErrorOrd,-1
          UNION ALL
			 SELECT @TableName,'','','=====    '+@TableName+'    =====','',@TableName,0,@ErrorOrd,-1
          UNION ALL
	         SELECT @TableName,'','','','',@TableName,0,@ErrorOrd,-1

-- A1.					 -- Shumat e Vlerave te Dokumentit me ato te rrjeshtave
		  UNION ALL      
			 SELECT @TableName,'','','Kuadrim rrjeshta','',@TableName,0,@ErrorOrd+'/01',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (	  SELECT Test       = @TableName+'->Detaj',
						 ErrorDok   = MAX(A.KODAB+' '+TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT)))+', '+CONVERT(Varchar,MAX(A.DateDok),4),
						 ErrorMsg   = 'Diference vlefta',
						 ErrorRef   = 'Shuma Db-Kr: '+CAST(Sum(B.DBKRMV) AS Varchar),
						 ErrorOrder = @ErrorOrd+'/01',
						 TableName  = @TableName,
						 A.NRRENDOR  
				   FROM ARKA A Inner Join #LMTestAR A1 On A.NRRENDOR = A1.NRRENDOR
							   Inner Join ARKASCR   B  On A.NRRENDOR = B.NRD 
			   GROUP BY A.NRRENDOR 
				 Having (ABS(SUM(B.DBKRMV))>=@TestVlere)
			  ) A

-- A2.					 -- Referenca te panjohura Klient,Furnitor,Monedhe,Artikuj,Ardhura,Shpenzime,Sherbime etj.
		  UNION ALL      
			 SELECT @TableName,'','','Referenca panjohura','',@TableName,0,@ErrorOrd+'/02',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

			   FROM
			  (	  SELECT Test       = @TableName+'->Ref',
						 ErrorDok   = A.KODAB+' '+TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Reference panjohur /1',
						 ErrorRef   = CASE WHEN (NOT EXISTS (SELECT KOD FROM ARKAT   B WHERE B.KOD=A.KODAB)) THEN 'Arka : '  +ISNULL(A.KODAB,'')
										   WHEN (NOT EXISTS (SELECT KOD FROM MONEDHA B WHERE B.KOD=A.KMON))  THEN 'Monedhe: '+ISNULL(A.KMON,'')
                                           WHEN (NOT EXISTS (SELECT KOD FROM ARKAT B   WHERE B.KOD=A.KODAB AND B.NRRENDOR=A.NRRENDORAB)) THEN 'Id.Arka: '+ISNULL(A.KODAB,'')
										   ELSE 'Ref panjohur.'
									  END, 
						 ErrorOrder = @ErrorOrd+'/02 1',
                         ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
						 TableName  = @TableName,
						 A.NRRENDOR  
					FROM ARKA A Inner Join #LMTestAR A1 On A.NRRENDOR = A1.NRRENDOR
				   WHERE (NOT EXISTS (SELECT KOD FROM ARKAT B   WHERE B.KOD=A.KODAB)) Or
						 (NOT EXISTS (SELECT KOD FROM MONEDHA B WHERE B.KOD=A.KMON)) Or
                         (NOT EXISTS (SELECT KOD FROM ARKAT B   WHERE B.KOD=A.KODAB AND B.NRRENDOR=A.NRRENDORAB))

			   UNION ALL 

				  SELECT Test       = @TableName+'->Ref',
						 ErrorDok   = A.KODAB+' '+TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Reference panjohur /2',
						 ErrorRef   = +B.LLOGARIPK+' / '+
									  CASE WHEN B.TIPKLL='T' THEN 'Llg '
										   WHEN B.TIPKLL='S' THEN 'Kli   '
										   WHEN B.TIPKLL='F' THEN 'Fur '
										   WHEN B.TIPKLL='A' THEN 'Ark '
										   WHEN B.TIPKLL='B' THEN 'Ban '
										   ELSE 'Rrjeshti: '
									  END,
						 ErrorOrder = @ErrorOrd+'/02 2',
                         ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
						 TableName  = @TableName,
						 A.NRRENDOR  
					FROM ARKA A Inner Join #LMTestAR A1 On A.NRRENDOR = A1.NRRENDOR
								Inner Join ARKASCR B    On A.NrRendor=B.NrD
				   WHERE ((B.TipKll='T' AND (NOT EXISTS (SELECT KOD FROM LLOGARI  C WHERE C.KOD=B.LLOGARIPK))) Or
						  (B.TipKll='S' AND (NOT EXISTS (SELECT KOD FROM KLIENT   C WHERE C.KOD=B.LLOGARIPK))) Or
						  (B.TipKll='F' AND (NOT EXISTS (SELECT KOD FROM FURNITOR C WHERE C.KOD=B.LLOGARIPK))) Or
						  (B.TipKll='A' AND (NOT EXISTS (SELECT KOD FROM ARKAT C    WHERE C.KOD=B.LLOGARIPK))) Or
						  (B.TipKll='B' AND (NOT EXISTS (SELECT KOD FROM BANKAT C   WHERE C.KOD=B.LLOGARIPK))))
			  ) A

-- A3.					 -- Dokumenta me Nr te perseritur
		  UNION ALL     
			 SELECT @TableName,'','','Nr. perseritur','',@TableName,0,@ErrorOrd+'/03',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Nr',
						 ErrorDok   = MAX(A.KODAB+' '+TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Dok. perseritur',
						 ErrorRef   = A.KODAB+' '+TIPDOK+' nr '+
                                      CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+'/'+
									  CONVERT(nVarchar(10),YEAR(DATEDOK))+' - '+
									  CAST(COUNT(*) AS Varchar)+' here',
						 ErrorOrder = @ErrorOrd+'/03',
						 TableName  = @TableName,
						 NRRENDOR   = MIN(A.NRRENDOR ) 

					FROM ARKA A Inner Join #LMTestAR A1 On A.NRRENDOR = A1.NRRENDOR
				GROUP BY KODAB,YEAR(DATEDOK),NUMDOK,TIPDOK 
				  Having COUNT(*)>=2 
			  ) A

-- A4.					 -- Dokumenta pa rrjeshta
		  UNION ALL      
			 SELECT @TableName,'','','Dok. pa rreshta','',@TableName,0,@ErrorOrd+'/04',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Row',
						 ErrorDok   = MAX(A.KODAB+' '+TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Dok. pa rrjeshta',
						 ErrorRef   = '',
						 ErrorOrder = @ErrorOrd+'/04',
						 TableName  = @TableName,
						 A.NRRENDOR 
					FROM ARKA A Inner Join #LMTestAR A1 On A.NRRENDOR = A1.NRRENDOR
                                Left  Join ARKASCR B    On A.NRRENDOR = B.NRD
				GROUP BY A.NRRENDOR
				  Having ISNULL(COUNT(*),0)<=0 
			  ) A

-- A5.					 -- Kod Pa Monedhe
		  UNION ALL     
			 SELECT @TableName,'','','Mon ne Scr','',@TableName,0,@ErrorOrd+'/05',0

          UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

               FROM
              (    SELECT Test       = @TableName+'->Row',
		  				 ErrorDok   = A.KODAB+' '+A.TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
		 	             ErrorMsg   = 'Kod pa Mon: '+ISNULL(B.KMON,''),
			             ErrorRef   = 'Kod: '+B.KOD+' / '+B.TIPKLL,
                         ErrorOrder = @ErrorOrd+'/05',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM ARKA A Inner Join #LMTestAR A1 On A.NRRENDOR = A1.NRRENDOR
							    Left  Join ARKASCR B    On A.NRRENDOR = B.NRD
				   WHERE CASE WHEN TipKLL='T' THEN dbo.Isd_SegmentFind(B.KOD,0,5)
						      ELSE                 dbo.Isd_SegmentFind(B.KOD,0,2)
							  END <> ISNULL(B.KMon,'')
              ) A

-- A6.					 -- Vlefta ne rastin Monedhe baze
		  UNION ALL     
			 SELECT @TableName,'','','Vlefta mon baze Scr, TregDK','',@TableName,0,@ErrorOrd+'/06',0

          UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

               FROM
              (    SELECT Test       = @TableName+'->Row',
		  				 ErrorDok   = A.KODAB+' '+A.TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
		 	             ErrorMsg   = CASE WHEN ((ISNULL(TREGDK,'')='') AND (ISNULL(B.DB,0)<>0 OR ISNULL(B.KR,0)<>0 OR ISNULL(DBKRMV,0)<>0))
                                           THEN 'TregDK gabim '
                                           ELSE 'Mon baze/vleftat gabim'
                                      END,
			             ErrorRef   = 'Kod: '+B.KOD+' / '+B.TIPKLL,
                         ErrorOrder = @ErrorOrd+'/06',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM ARKA A Inner Join #LMTestAR A1 On A.NRRENDOR = A1.NRRENDOR
							    Left  Join ARKASCR B    On A.NRRENDOR = B.NRD
				   WHERE ((ISNULL(TREGDK,'')='') AND (ISNULL(B.DB,0)<>0 OR ISNULL(B.KR,0)<>0 OR ISNULL(DBKRMV,0)<>0)) 
                         OR
                        ( (B.KURS1=1 AND B.KURS2=1) AND 
                         ((B.TREGDK='D' AND B.DB<>DBKRMV) OR (B.TREGDK='K' AND KR<>0-DBKRMV)))
              ) A

-- A7.					 Rasti SCR me disa rrjeshta tipi Koke RRAB='K'
--        Test mosperputhje Vlere ne Dokument me Rrjeshtin pare te SCR qe mban kontabilizimin e Dokumentit ne Vlefte

		  UNION ALL      
			 SELECT @TableName,'','','Vlera llg.Arke # Vlera Dokumument','',@TableName,0,@ErrorOrd+'/07',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Row',
						 ErrorDok   = MAX(A.KODAB+' '+TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Vl. llg.arke # Vl. Dok',
						 ErrorRef   = 'Kod: '+MAX(B.KOD),
						 ErrorOrder = @ErrorOrd+'/07',
						 TableName  = @TableName,
						 A.NRRENDOR 
					FROM ARKA A Inner Join #LMTestAR A1 On A.NRRENDOR = A1.NRRENDOR
                                Left  Join ARKASCR B    On A.NRRENDOR = B.NRD
                   WHERE B.RRAB='K'
				GROUP BY A.NRRENDOR
                  Having Abs(MAX(A.VLERA)   - Sum(CASE WHEN TREGDK='D' THEN B.DB     ELSE   B.KR END))    >=@TestVlere Or 
                         Abs(MAX(A.VLERAMV) - Sum(CASE WHEN TREGDK='D' THEN B.DBKRMV ELSE 0-B.DBKRMV END))>=@TestVlere
			  ) A

        END


-- T2 ----------------------    B A N K A     -------------------------

			 SELECT NRRENDOR
			   INTO #LMTestBA
			   FROM BANKA
			  WHERE DateDok>=@DateKp AND DateDok<=@DateKs

                SET @TableName = 'BANKA'
				SET @ErrorOrd  = 'Dok '+@TableName+' '

    IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,LM,'+@TableName,'')<>''
        BEGIN

			 INSERT INTO #TestLMDok
				   (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @TableName,'','','','',@TableName,0,@ErrorOrd,-1
          UNION ALL		           
			 SELECT @TableName,'','','=====    '+@TableName+'    =====','',@TableName,0,@ErrorOrd,-1
          UNION ALL
	         SELECT @TableName,'','','','',@TableName,0,@ErrorOrd,-1

-- B1.					 -- Shumat e Vlerave te Dokumentit me ato te rrjeshtave
		  UNION ALL      
			 SELECT @TableName,'','','Kuadrim rrjeshta','',@TableName,0,@ErrorOrd+'/01',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (	  SELECT Test       = @TableName+'->Detaj',
						 ErrorDok   = MAX(A.KODAB+' '+TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT)))+', '+CONVERT(Varchar,MAX(A.DateDok),4),
						 ErrorMsg   = 'Diference vlefta',
						 ErrorRef   = 'Shuma Db-Kr: '+CAST(Sum(B.DBKRMV) AS Varchar),
						 ErrorOrder = @ErrorOrd+'/01',
						 TableName  = @TableName,
						 A.NRRENDOR  
				    FROM BANKA A Inner Join #LMTestBA A1 On A.NRRENDOR = A1.NRRENDOR
							     Inner Join BANKASCR B   On A.NRRENDOR = B.NRD 
			   GROUP BY A.NRRENDOR 
				 Having (ABS(SUM(B.DBKRMV))>=@TestVlere)
			  ) A

-- B2.					 -- Referenca te panjohura Klient,Furnitor,Monedhe,Artikuj,Ardhura,Shpenzime,Sherbime etj.
		  UNION ALL      
			 SELECT @TableName,'','','Referenca panjohura','',@TableName,0,@ErrorOrd+'/02',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (	  SELECT Test       = @TableName+'->Ref',
						 ErrorDok   = A.KODAB+' '+TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Reference panjohur /1',
						 ErrorRef   = CASE WHEN (NOT EXISTS (SELECT KOD FROM BANKAT  B WHERE B.KOD=A.KODAB)) THEN 'Banka : ' +ISNULL(A.KODAB,'')
										   WHEN (NOT EXISTS (SELECT KOD FROM MONEDHA B WHERE B.KOD=A.KMON))  THEN 'Monedhe: '+ISNULL(A.KMON,'')
                                           WHEN (NOT EXISTS (SELECT KOD FROM BANKAT B  WHERE B.KOD=A.KODAB AND B.NRRENDOR=A.NRRENDORAB)) THEN 'Id.Banka: '+ISNULL(A.KODAB,'')
										   ELSE 'Ref panjohur.'
									  END, 
						 ErrorOrder = @ErrorOrd+'/02 1',
						 TableName  = @TableName,
						 A.NRRENDOR  
					FROM BANKA A Inner Join #LMTestBA A1 On A.NRRENDOR = A1.NRRENDOR
				   WHERE (NOT EXISTS (SELECT KOD FROM BANKAT B  WHERE B.KOD=A.KODAB)) Or
						 (NOT EXISTS (SELECT KOD FROM MONEDHA B WHERE B.KOD=A.KMON))  Or
                         (NOT EXISTS (SELECT KOD FROM BANKAT B  WHERE B.KOD=A.KODAB AND B.NRRENDOR=A.NRRENDORAB))

			   UNION ALL 

				  SELECT Test       = @TableName+'->Ref',
						 ErrorDok   = A.KODAB+' '+TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Reference panjohur /2',
						 ErrorRef   = +B.LLOGARIPK+' / '+
									  CASE WHEN B.TIPKLL='T' THEN 'Llogari '
										   WHEN B.TIPKLL='S' THEN 'Klient   '
										   WHEN B.TIPKLL='F' THEN 'Furnitor '
										   WHEN B.TIPKLL='A' THEN 'Arka '
										   WHEN B.TIPKLL='B' THEN 'Banka '
										   ELSE 'Rrjeshti: '
									  END,
						 ErrorOrder = @ErrorOrd+'/02 2',
						 TableName  = @TableName,
						 A.NRRENDOR  
					FROM BANKA A Inner Join #LMTestBA A1 On A.NRRENDOR = A1.NRRENDOR
								 Inner Join BANKASCR B   On A.NrRendor = B.NrD
				   WHERE ((B.TipKll='T' AND (NOT EXISTS (SELECT KOD FROM LLOGARI  C WHERE C.KOD=B.LLOGARIPK))) Or
						  (B.TipKll='S' AND (NOT EXISTS (SELECT KOD FROM KLIENT   C WHERE C.KOD=B.LLOGARIPK))) Or
						  (B.TipKll='F' AND (NOT EXISTS (SELECT KOD FROM FURNITOR C WHERE C.KOD=B.LLOGARIPK))) Or
						  (B.TipKll='A' AND (NOT EXISTS (SELECT KOD FROM ARKAT C    WHERE C.KOD=B.LLOGARIPK))) Or
						  (B.TipKll='B' AND (NOT EXISTS (SELECT KOD FROM BANKAT C   WHERE C.KOD=B.LLOGARIPK))))
			  ) A

-- B3.					 -- Dokumenta me Nr te perseritur
		  UNION ALL     
			 SELECT @TableName,'','','Nr. perseritur','',@TableName,0,@ErrorOrd+'/03',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (	  SELECT Test       = @TableName+'->Nr',
						 ErrorDok   = MAX(A.KODAB+' '+TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Dok. perseritur',
						 ErrorRef   = A.KODAB+' '+TIPDOK+' nr '+
                                      CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+'/'+
									  CONVERT(nVarchar(10),YEAR(DATEDOK))+' - '+
									  CAST(COUNT(*) AS Varchar)+' here',
						 ErrorOrder = @ErrorOrd+'/03',
						 TableName  = @TableName,
						 NRRENDOR   = MIN(A.NRRENDOR ) 

					FROM BANKA A Inner Join #LMTestBA A1 On A.NRRENDOR = A1.NRRENDOR
				GROUP BY KODAB,YEAR(DATEDOK),NUMDOK,TIPDOK 
				  Having COUNT(*)>=2 
			  ) A

-- B4.					 -- Dokumenta pa rrjeshta
		  UNION ALL      
			 SELECT @TableName,'','','Dok. pa rreshta','',@TableName,0,@ErrorOrd+'/04',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (	  SELECT Test       = @TableName+'->Row',
						 ErrorDok   = MAX(A.KODAB+' '+TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Dok. pa rrjeshta',
						 ErrorRef   = '',
						 ErrorOrder = @ErrorOrd+'/04',
						 TableName  = @TableName,
						 A.NRRENDOR 
					FROM BANKA A Inner Join #LMTestBA A1 On A.NRRENDOR = A1.NRRENDOR
                                 Left  Join BANKASCR B   On A.NRRENDOR = B.NRD
				GROUP BY A.NRRENDOR
				  Having ISNULL(COUNT(*),0)<=0 
			   ) A

-- B5.					 -- Kod Pa Monedhe
		  UNION ALL     
			 SELECT @TableName,'','','Mon ne Scr','',@TableName,0,@ErrorOrd+'/05',0

          UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

               FROM
              (    SELECT Test       = @TableName+'->Row',
		  				 ErrorDok   = A.KODAB+' '+A.TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
		 	             ErrorMsg   = 'Kod pa Mon: '+ISNULL(B.KMON,''),
			             ErrorRef   = 'Kod: '+B.KOD+' / '+B.TIPKLL,
                         ErrorOrder = @ErrorOrd+'/05',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM BANKA A Inner Join #LMTestBA A1 On A.NRRENDOR = A1.NRRENDOR
							     Left  Join BANKASCR B   On A.NRRENDOR = B.NRD
				   WHERE CASE WHEN TipKLL='T' THEN dbo.Isd_SegmentFind(B.KOD,0,5)
						      ELSE                 dbo.Isd_SegmentFind(B.KOD,0,2)
							  END <> ISNULL(B.KMon,'')
              ) A

-- B6.					 -- Vlefta ne rastin Monedhe baze
		  UNION ALL     
			 SELECT @TableName,'','','Vlefta mon baze Scr, TregDK','',@TableName,0,@ErrorOrd+'/06',0

          UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

               FROM
 
              (   SELECT Test       = @TableName+'->Row',
		  				 ErrorDok   = A.KODAB+' '+A.TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
		 	             ErrorMsg   = CASE WHEN ((ISNULL(TREGDK,'')='') AND (ISNULL(B.DB,0)<>0 OR ISNULL(B.KR,0)<>0 OR ISNULL(DBKRMV,0)<>0))
                                           THEN 'TregDK gabim '
                                           ELSE 'Mon baze/vleftat gabim '
                                      END,
			             ErrorRef   = 'Kod: '+B.KOD+' / '+B.TIPKLL,
                         ErrorOrder = @ErrorOrd+'/06',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM BANKA A Inner Join #LMTestBA A1 On A.NRRENDOR = A1.NRRENDOR
							     Left  Join BANKASCR B   On A.NRRENDOR = B.NRD
				   WHERE ((ISNULL(TREGDK,'')='') AND (ISNULL(B.DB,0)<>0 OR ISNULL(B.KR,0)<>0 OR ISNULL(DBKRMV,0)<>0)) 
                         OR
                        ( (B.KURS1=1 AND B.KURS2=1) AND 
                         ((B.TREGDK='D' AND B.DB<>DBKRMV) Or (B.TREGDK='K' AND KR<>0-DBKRMV)))
              ) A

-- B7.					 Rasti SCR me disa rrjeshta tipi Koke RRAB='K'
--        Test mosperputhje Vlere ne Dokument me Rrjeshtin pare te SCR qe mban kontabilizimin e Dokumentit ne Vlefte

		  UNION ALL      
			 SELECT @TableName,'','','Vlera llg.Banke # Vlera Dokumument','',@TableName,0,@ErrorOrd+'/07',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Row',
						 ErrorDok   = MAX(A.KODAB+' '+TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Vl. llg.banke # Vl. Dok',
						 ErrorRef   = 'Kod: '+MAX(B.KOD),
						 ErrorOrder = @ErrorOrd+'/07',
						 TableName  = @TableName,
						 A.NRRENDOR 
					FROM BANKA A Inner Join #LMTestBA A1 On A.NRRENDOR = A1.NRRENDOR
                                 Left  Join BANKASCR B   On A.NRRENDOR = B.NRD
                   WHERE B.RRAB='K'
				GROUP BY A.NRRENDOR
                  Having Abs(MAX(A.VLERA)   - Sum(CASE WHEN TREGDK='D' THEN B.DB     ELSE   B.KR END))    >=@TestVlere Or 
                         Abs(MAX(A.VLERAMV) - Sum(CASE WHEN TREGDK='D' THEN B.DBKRMV ELSE 0-B.DBKRMV END))>=@TestVlere
			  ) A

        END


-- T3 ----------------------        V S       -------------------------

    IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,LM,'+@TableName,'')<>''
        BEGIN

			 SELECT NRRENDOR
			   INTO #LMTestVS
			   FROM VS
			  WHERE DateDok>=@DateKp AND DateDok<=@DateKs

                SET @TableName = 'VS'
				SET @ErrorOrd  = 'Dok '+@TableName+' '

			 INSERT INTO #TestLMDok
				   (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @TableName,'','','','',@TableName,0,@ErrorOrd,-1
          UNION ALL
			 SELECT @TableName,'','','=====    '+@TableName+'    =====','',@TableName,0,@ErrorOrd,-1
          UNION ALL
	         SELECT @TableName,'','','','',@TableName,0,@ErrorOrd,-1

-- C1.                   -- Shumat e Vlerave te Dokumentit me ato te rrjeshtave
		  UNION ALL      
			 SELECT @TableName,'','','Kuadrim rrjeshta','',@TableName,0,@ErrorOrd+'/01',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (	  SELECT Test       = @TableName+'->Detaj',
						 ErrorDok   = MAX('Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Diference vlefta',
						 ErrorRef   = 'Shuma Db-Kr: '+CAST(Sum(B.DBKRMV) AS Varchar),
						 ErrorOrder = @ErrorOrd+'/01',
						 TableName  = @TableName,
						 A.NRRENDOR  
				    FROM VS A Inner Join #LMTestVS A1 On A.NRRENDOR = A1.NRRENDOR
							  Inner Join VSSCR B      On A.NRRENDOR = B.NRD 
			   GROUP BY A.NRRENDOR 
				 Having (ABS(SUM(B.DBKRMV))>=@TestVlere)
			 ) A

-- C2.                   -- Referenca te panjohura Klient,Furnitor,Monedhe,Artikuj,Ardhura,Shpenzime,Sherbime etj.
		  UNION ALL      
			 SELECT @TableName,'','','Referenca panjohura','',@TableName,0,@ErrorOrd+'/02',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Ref',
						 ErrorDok   = 'Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Reference panjohur',
						 ErrorRef   = +B.LLOGARIPK+' / '+
									  CASE WHEN B.TIPKLL='T' THEN 'Llogari '
										   WHEN B.TIPKLL='S' THEN 'Klient   '
										   WHEN B.TIPKLL='F' THEN 'Furnitor '
										   WHEN B.TIPKLL='A' THEN 'Arka '
										   WHEN B.TIPKLL='B' THEN 'Banka '
										   ELSE 'Rrjeshti: '
									  END,
						 ErrorOrder = @ErrorOrd+'/02',
						 TableName  = @TableName,
						 A.NRRENDOR  
					FROM VS A Inner Join #LMTestVS A1 On A.NRRENDOR = A1.NRRENDOR
							  Inner Join VSSCR B      On A.NrRendor = B.NrD
				   WHERE ((B.TipKll='T' AND (NOT EXISTS (SELECT KOD FROM LLOGARI  C WHERE C.KOD=B.LLOGARIPK))) Or
						  (B.TipKll='S' AND (NOT EXISTS (SELECT KOD FROM KLIENT   C WHERE C.KOD=B.LLOGARIPK))) Or
						  (B.TipKll='F' AND (NOT EXISTS (SELECT KOD FROM FURNITOR C WHERE C.KOD=B.LLOGARIPK))) Or
						  (B.TipKll='A' AND (NOT EXISTS (SELECT KOD FROM ARKAT C    WHERE C.KOD=B.LLOGARIPK))) Or
						  (B.TipKll='B' AND (NOT EXISTS (SELECT KOD FROM BANKAT C   WHERE C.KOD=B.LLOGARIPK))))
			  ) A

-- C3.					 -- Dokumenta me Nr te perseritur
		  UNION ALL     
			 SELECT @TableName,'','','Nr. perseritur','',@TableName,0,@ErrorOrd+'/03',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (	  SELECT Test       = @TableName+'->Nr',
						 ErrorDok   = MAX('Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Dok. perseritur',
						 ErrorRef   = 'Nr '+
                                      CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+'/'+
									  CONVERT(nVarchar(10),YEAR(DATEDOK))+' - '+
									  CAST(COUNT(*) AS Varchar)+' here',
						 ErrorOrder = @ErrorOrd+'/03',
						 TableName  = @TableName,
						 NRRENDOR   = MIN(A.NRRENDOR ) 

					FROM VS A Inner Join #LMTestVS A1 On A.NRRENDOR = A1.NRRENDOR
				GROUP BY YEAR(DATEDOK),NRDOK
				  Having COUNT(*)>=2 
			  ) A

-- C4.				     -- Dokumenta pa rrjeshta
		  UNION ALL      
			 SELECT @TableName,'','','Dok. pa rreshta','',@TableName,0,@ErrorOrd+'/04',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (	  SELECT Test       = @TableName+'->Row',
						 ErrorDok   = MAX('Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Dok. pa rrjeshta',
						 ErrorRef   = '',
						 ErrorOrder = @ErrorOrd+'/04',
						 TableName  = @TableName,
						 A.NRRENDOR 
					FROM VS A Inner Join #LMTestVS A1 On A.NRRENDOR = A1.NRRENDOR
                              Left  Join VSSCR B      On A.NRRENDOR = B.NRD
				GROUP BY A.NRRENDOR
				  Having ISNULL(COUNT(*),0)<=0 
			  ) A

-- C5.				     -- Kod Pa Monedhe
		  UNION ALL     
			 SELECT @TableName,'','','Mon ne Scr','',@TableName,0,@ErrorOrd+'/05',0

          UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

               FROM
              (    SELECT Test       = @TableName+'->Row',
		  				 ErrorDok   = 'Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
		 	             ErrorMsg   = 'Kod pa Mon: '+ISNULL(B.KMON,''),
			             ErrorRef   = 'Kod: '+B.KOD+' / '+B.TIPKLL,
                         ErrorOrder = @ErrorOrd+'/05',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM VS A Inner Join #LMTestVS A1 On A.NRRENDOR = A1.NRRENDOR
							  Left  Join VSSCR B      On A.NRRENDOR = B.NRD
				   WHERE CASE WHEN TipKLL='T' THEN dbo.Isd_SegmentFind(B.KOD,0,5)
						      ELSE                 dbo.Isd_SegmentFind(B.KOD,0,2)
							  END <> ISNULL(B.KMon,'')
              ) A

-- C6.					 -- Vlefta ne rastin Monedhe baze
		  UNION ALL     
			 SELECT @TableName,'','','Vlefta mon baze Scr, TregDK','',@TableName,0,@ErrorOrd+'/06',0

          UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

               FROM
              (    SELECT Test       = @TableName+'->Row',
		  				 ErrorDok   = 'Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
		 	             ErrorMsg   = CASE WHEN ((ISNULL(TREGDK,'')='') AND (ISNULL(B.DB,0)<>0 OR ISNULL(B.KR,0)<>0 OR ISNULL(DBKRMV,0)<>0))
                                           THEN 'TregDK gabim '
                                           ELSE 'Mon baze/vleftat gabim '
                                      END,
			             ErrorRef   = 'Kod: '+B.KOD+' / '+B.TIPKLL,
                         ErrorOrder = @ErrorOrd+'/06',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM VS A Inner Join #LMTestVS A1 On A.NRRENDOR = A1.NRRENDOR
							  Left  Join VSSCR B      On A.NRRENDOR = B.NRD
				   WHERE ((ISNULL(TREGDK,'')='') AND (ISNULL(B.DB,0)<>0 OR ISNULL(B.KR,0)<>0 OR ISNULL(DBKRMV,0)<>0)) 
                         OR
                        ( (B.KURS1=1 AND B.KURS2=1) AND 
                         ((B.TREGDK='D' AND B.DB<>DBKRMV) Or (B.TREGDK='K' AND KR<>0-DBKRMV)))
              ) A
        END


-- T4 ----------------------        F K       -------------------------

			 SELECT NRRENDOR
			   INTO #LMTestFK
			   FROM FK
			  WHERE DateDok>=@DateKp AND DateDok<=@DateKs

                SET @TableName = 'FK'
				SET @ErrorOrd  = 'Dok '+@TableName+' '


    IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,LM,'+@TableName,'')<>''
        BEGIN

			 INSERT INTO #TestLMDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @TableName,'','','','',@TableName,0,@ErrorOrd,-1
          UNION ALL		           
			 SELECT @TableName,'','','=====    '+@TableName+'    =====','',@TableName,0,@ErrorOrd,-1
          UNION ALL
	         SELECT @TableName,'','','','',@TableName,0,@ErrorOrd,-1

-- D1.					 -- Shumat e Vlerave te Dokumentit me ato te rrjeshtave
		  UNION ALL      
			 SELECT @TableName,'','','Kuadrim rrjeshta','',@TableName,0,@ErrorOrd+'/01',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (	  SELECT Test       = @TableName+'->Detaj',
						 ErrorDok   = MAX(TIPDOK+
                                          ' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+
                                          ', '  +CONVERT(Varchar,A.DateDok,4)+
                                          CASE WHEN CharIndex(A.ORG,'ABHD')>0 THEN ' /'+REFERDOK ELSE '' END+'    '+
                                          'Fk nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                          ', id ' +CONVERT(nVarchar(20),CAST(A.NrRendor AS BIGINT))),
						 ErrorMsg   = 'Diference vlefta',
						 ErrorRef   = 'Shuma Db-Kr: '+CAST(Sum(B.DBKRMV) AS Varchar),
						 ErrorOrder = @ErrorOrd+'/01',
						 TableName  = @TableName,
						 A.NRRENDOR  
				    FROM FK A Inner Join #LMTestFK A1 On A.NRRENDOR = A1.NRRENDOR
							  Inner Join FKSCR B      On A.NRRENDOR = B.NRD 
			    GROUP BY A.NRRENDOR 
				  Having (ABS(SUM(B.DBKRMV))>=@TestVlere)
			  ) A

-- D2.                   -- Referenca te panjohura Klient,Furnitor,Monedhe,Artikuj,Ardhura,Shpenzime,Sherbime etj.
		  UNION ALL      
			 SELECT @TableName,'','','Referenca panjohura','',@TableName,0,@ErrorOrd+'/02',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Ref',
						 ErrorDok   = TIPDOK+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+
                                      ', '  +CONVERT(Varchar,A.DateDok,4)+
                                      CASE WHEN CharIndex(A.ORG,'ABHD')>0 THEN ' /'+REFERDOK ELSE '' END,
						 ErrorMsg   = 'Reference panjohur',
						 ErrorRef   = +B.LLOGARIPK+' / Llogari ',
						 ErrorOrder = @ErrorOrd+'/02',
						 TableName  = @TableName,
						 A.NRRENDOR  
					FROM FK A Inner Join #LMTestFK A1 On A.NRRENDOR = A1.NRRENDOR
							  Inner Join FKSCR B      On A.NrRendor = B.NrD
				   WHERE (NOT EXISTS (SELECT KOD FROM LLOGARI  C WHERE C.KOD=B.LLOGARIPK))
			  ) A

-- D3.                   -- Dokumenta me Nr te perseritur
		  UNION ALL     
			 SELECT @TableName,'','','Nr. perseritur','',@TableName,0,@ErrorOrd+'/03',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Nr',
						 ErrorDok   = MAX(TIPDOK+
                                         ' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+
                                         ', '  +CONVERT(Varchar,A.DateDok,4)+
                                         CASE WHEN CharIndex(A.ORG,'ABHD')>0 THEN ' /'+REFERDOK ELSE '' END),
						 ErrorMsg   = 'Dok. perseritur',
						 ErrorRef   = 'Nr '+
                                      CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+'/'+
									  CONVERT(nVarchar(10),YEAR(DATEDOK))+' - '+
									  CAST(COUNT(*) AS Varchar)+' here',
						 ErrorOrder = @ErrorOrd+'/03',
						 TableName  = @TableName,
						 NRRENDOR   = MIN(A.NRRENDOR ) 

					FROM FK A Inner Join #LMTestFK A1 On A.NRRENDOR = A1.NRRENDOR
                   WHERE A.ORG='T'
				GROUP BY YEAR(DATEDOK),NRDOK
				  Having COUNT(*)>=2 
			  ) A

-- D4.                   -- Dokumenta pa rrjeshta
		  UNION ALL      
			 SELECT @TableName,'','','Dok. pa rreshta','',@TableName,0,@ErrorOrd+'/04',0
		  UNION ALL

			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Row',
						 ErrorDok   = MAX(TIPDOK+
                                          ' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+
                                          ', '  +CONVERT(Varchar,A.DateDok,4)+
                                          CASE WHEN CharIndex(A.ORG,'ABHD')>0 THEN ' /'+REFERDOK ELSE '' END),
						 ErrorMsg   = 'Dok. pa rrjeshta',
						 ErrorRef   = '',
						 ErrorOrder = @ErrorOrd+'/04',
						 TableName  = @TableName,
						 A.NRRENDOR 
					FROM FK A Inner Join #LMTestFK A1 On A.NRRENDOR = A1.NRRENDOR
                              Left  Join FKSCR B      On A.NRRENDOR = B.NRD
				GROUP BY A.NRRENDOR
				  Having ISNULL(COUNT(*),0)<=0 

			  ) A

-- D5.					 -- Kod Pa Monedhe
		  UNION ALL     
			 SELECT @TableName,'','','Mon ne Scr','',@TableName,0,@ErrorOrd+'/05',0
          UNION ALL

			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

               FROM  
              (    SELECT Test       = @TableName+'->Row',
		  				 ErrorDok   = TIPDOK+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+
                                      ', '+CONVERT(Varchar,A.DateDok,4)+
                                      CASE WHEN CharIndex(A.ORG,'ABHD')>0 THEN ' /'+REFERDOK ELSE '' END,
		 	             ErrorMsg   = 'Kod pa Mon: '+ISNULL(B.KMON,''),
			             ErrorRef   = 'Kod: '+B.KOD,
                         ErrorOrder = @ErrorOrd+'/05',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM FK A Inner Join #LMTestFK A1 On A.NRRENDOR = A1.NRRENDOR
							  Left  Join FKSCR B      On A.NRRENDOR = B.NRD
				   WHERE dbo.Isd_SegmentFind(B.KOD,0,5) <> ISNULL(B.KMon,'')
              ) A

-- D6.					 -- Vlefta ne rastin Monedhe baze
		  UNION ALL     
			 SELECT @TableName,'','','Vlefta mon baze Scr, TregDK','',@TableName,0,@ErrorOrd+'/06',0
          UNION ALL

			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

               FROM
              (    SELECT Test       = @TableName+'->Row',
		  				 ErrorDok   = TIPDOK+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+
                                      ', '+CONVERT(Varchar,A.DateDok,4)+
                                      CASE WHEN CharIndex(A.ORG,'ABHD')>0 THEN ' /'+REFERDOK ELSE '' END,
		 	             ErrorMsg   = CASE WHEN ((ISNULL(TREGDK,'')='') AND (ISNULL(B.DB,0)<>0 OR ISNULL(B.KR,0)<>0 OR ISNULL(DBKRMV,0)<>0))
                                           THEN 'TregDK gabim '
                                           ELSE 'Mon baze/vleftat gabim '
                                      END,
			             ErrorRef   = 'Kod: '+B.KOD,
                         ErrorOrder = @ErrorOrd+'/06',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM FK A Inner Join #LMTestFK A1 On A.NRRENDOR = A1.NRRENDOR
							  Left  Join FKSCR B      On A.NRRENDOR = B.NRD
				   WHERE ((ISNULL(TREGDK,'')='') AND (ISNULL(B.DB,0)<>0 OR ISNULL(B.KR,0)<>0 OR ISNULL(DBKRMV,0)<>0)) 
                         OR
                        ( (B.KURS1=1 AND B.KURS2=1) AND 
                         ((B.TREGDK='D' AND B.DB<>DBKRMV) Or (B.TREGDK='K' AND KR<>0-DBKRMV))) 
              ) A

-- D7.					 -- FK pa dokument origjine
		  UNION ALL     
			 SELECT @TableName,'','','FK pa dokument origjine','',@TableName,0,@ErrorOrd+'/07',0
          UNION ALL

			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

               FROM
              (   SELECT Test       = @TableName+'->Row',
		  				 ErrorDok   = TIPDOK+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+
                                      ', '+CONVERT(Varchar,A.DateDok,4)+
                                      CASE WHEN CharIndex(A.ORG,'ABHD')>0 THEN ' /'+REFERDOK ELSE '' END,
		 	             ErrorMsg   = 'Mongon dok.origjine',
			             ErrorRef   = 'Fk: Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      ', ' +CONVERT(Varchar,A.DateDok,4),
                         ErrorOrder = @ErrorOrd+'/07',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM FK A Inner Join #LMTestFK A1 On A.NRRENDOR = A1.NRRENDOR
                   WHERE ((A.ORG='S' AND (NOT EXISTS (SELECT NRDFK FROM FJ C    WHERE C.NRDFK=A.NRRENDOR))) Or
						  (A.ORG='F' AND (NOT EXISTS (SELECT NRDFK FROM FF C    WHERE C.NRDFK=A.NRRENDOR))) Or
                          (A.ORG='H' AND (NOT EXISTS (SELECT NRDFK FROM FH C    WHERE C.NRDFK=A.NRRENDOR))) Or
                          (A.ORG='D' AND (NOT EXISTS (SELECT NRDFK FROM FD C    WHERE C.NRDFK=A.NRRENDOR))) Or
                          (A.ORG='G' AND (NOT EXISTS (SELECT NRDFK FROM DG C    WHERE C.NRDFK=A.NRRENDOR))) Or
						  (A.ORG='A' AND (NOT EXISTS (SELECT NRDFK FROM ARKA C  WHERE C.NRDFK=A.NRRENDOR))) Or
						  (A.ORG='B' AND (NOT EXISTS (SELECT NRDFK FROM BANKA C WHERE C.NRDFK=A.NRRENDOR))) Or
                          (A.ORG='E' AND (NOT EXISTS (SELECT NRDFK FROM VS C    WHERE C.NRDFK=A.NRRENDOR))))
              ) A
        END



-- T5 ---------------------      V S S T     -------------------------

			 SELECT NRRENDOR
			   INTO #LMTestVT
			   FROM VSST

                SET @TableName = 'VSST'
				SET @ErrorOrd  = 'Dok '+@TableNAme+' '

    IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,LM,'+@TableName,'')<>''
        BEGIN

			 INSERT INTO #TestLMDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @TableName,'','','','',@TableName,0,@ErrorOrd,-1
          UNION ALL		           
			 SELECT @TableName,'','','=====    '+@TableName+'    =====','',@TableName,0,@ErrorOrd,-1
          UNION ALL
	         SELECT @TableName,'','','','',@TableName,0,@ErrorOrd,-1

-- E1.					 -- Shumat e Vlerave te Dokumentit me ato te rrjeshtave
		  UNION ALL      
			 SELECT @TableName,'','','Kuadrim rrjeshta','',@TableName,0,@ErrorOrd+'/01',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (	  SELECT Test       = @TableName+'->Detaj',
						 ErrorDok   = MAX('Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))),
						 ErrorMsg   = 'Diference vlefta',
						 ErrorRef   = 'Shuma Db-Kr: '+CAST(Sum(B.DBKRMV) AS Varchar),
						 ErrorOrder = @ErrorOrd+'/01',
						 TableName  = @TableName,
						 A.NRRENDOR  
				    FROM VSST A Inner Join #LMTestVT A1 On A.NRRENDOR = A1.NRRENDOR
							    Inner Join VSSTSCR B    On A.NRRENDOR = B.NRD 
			   GROUP BY A.NRRENDOR 
				 Having (ABS(SUM(B.DBKRMV))>=@TestVlere)
			  ) A

-- E2.					 -- Referenca te panjohura Klient,Furnitor,Monedhe,Artikuj,Ardhura,Shpenzime,Sherbime etj.
		  UNION ALL      
			 SELECT @TableName,'','','Referenca panjohura','',@TableName,0,@ErrorOrd+'/02',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Ref',
						 ErrorDok   = 'Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT)),
						 ErrorMsg   = 'Reference panjohur',
						 ErrorRef   = +B.LLOGARIPK+' / '+
									  CASE WHEN B.TIPKLL='T' THEN 'Llogari '
										   WHEN B.TIPKLL='S' THEN 'Klient   '
										   WHEN B.TIPKLL='F' THEN 'Furnitor '
										   WHEN B.TIPKLL='A' THEN 'Arka '
										   WHEN B.TIPKLL='B' THEN 'Banka '
										   ELSE 'Rrjeshti: '
									  END,
						 ErrorOrder = @ErrorOrd+'/02',
						 TableName  = @TableName,
						 A.NRRENDOR  
					FROM VSST A Inner Join #LMTestVT A1 On A.NRRENDOR = A1.NRRENDOR
							    Inner Join VSSTSCR B    On A.NrRendor = B.NrD
				   WHERE ((B.TipKll='T' AND (NOT EXISTS (SELECT KOD FROM LLOGARI  C WHERE C.KOD=B.LLOGARIPK))) Or
						  (B.TipKll='S' AND (NOT EXISTS (SELECT KOD FROM KLIENT   C WHERE C.KOD=B.LLOGARIPK))) Or
						  (B.TipKll='F' AND (NOT EXISTS (SELECT KOD FROM FURNITOR C WHERE C.KOD=B.LLOGARIPK))) Or
						  (B.TipKll='A' AND (NOT EXISTS (SELECT KOD FROM ARKAT C    WHERE C.KOD=B.LLOGARIPK))) Or
						  (B.TipKll='B' AND (NOT EXISTS (SELECT KOD FROM BANKAT C   WHERE C.KOD=B.LLOGARIPK))))
			 ) A

-- E3.					 -- Dokumenta me Nr te perseritur
		  UNION ALL     
			 SELECT @TableName,'','','Nr. perseritur','',@TableName,0,@ErrorOrd+'/03',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Nr',
						 ErrorDok   = MAX('Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))),
						 ErrorMsg   = 'Dok. perseritur',
						 ErrorRef   = 'Nr '+
                                      CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+'/'+
									  CONVERT(nVarchar(10),YEAR(DATEDOK))+' - '+
									  CAST(COUNT(*) AS Varchar)+' here',
						 ErrorOrder = @ErrorOrd+'/03',
						 TableName  = @TableName,
						 NRRENDOR   = MIN(A.NRRENDOR ) 

					FROM VSST A Inner Join #LMTestVT A1 On A.NRRENDOR = A1.NRRENDOR
				GROUP BY YEAR(DATEDOK),NRDOK
				  Having COUNT(*)>=2 
			  ) A

-- E4.					 -- Dokumenta pa rrjeshta
		  UNION ALL      
			 SELECT @TableName,'','','Dok. pa rreshta','',@TableName,0,@ErrorOrd+'/04',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Row',
						 ErrorDok   = MAX('Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))),
						 ErrorMsg   = 'Dok. pa rrjeshta',
						 ErrorRef   = '',
						 ErrorOrder = @ErrorOrd+'/04',
						 TableName  = @TableName,
						 A.NRRENDOR 
					FROM VSST A Inner Join #LMTestVT A1 On A.NRRENDOR = A1.NRRENDOR
                                Left  Join VSSTSCR B    On A.NRRENDOR = B.NRD
				GROUP BY A.NRRENDOR
				  Having ISNULL(COUNT(*),0)<=0 
			  ) A

-- E5.					 -- Kod Pa Monedhe
		  UNION ALL     
			 SELECT @TableName,'','','Mon ne Scr','',@TableName,0,@ErrorOrd+'/05',0

          UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

               FROM
              (    SELECT Test       = @TableName+'->Row',
		  				 ErrorDok   = 'Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT)),
		 	             ErrorMsg   = 'Kod pa Mon: '+ISNULL(B.KMON,''),
			             ErrorRef   = 'Kod: '+B.KOD+' / '+B.TIPKLL,
                         ErrorOrder = @ErrorOrd+'/05',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM VSST A Inner Join #LMTestVT A1 On A.NRRENDOR = A1.NRRENDOR
							    Left  Join VSSTSCR B    On A.NRRENDOR = B.NRD
				   WHERE CASE WHEN TipKLL='T' THEN dbo.Isd_SegmentFind(B.KOD,0,5)
						      ELSE                 dbo.Isd_SegmentFind(B.KOD,0,2)
							  END <> ISNULL(B.KMon,'')
              ) A

-- E6.					 -- Vlefta ne rastin Monedhe baze
		  UNION ALL     
			 SELECT @TableName,'','','Vlefta mon baze Scr, TregDK','',@TableName,0,@ErrorOrd+'/06',0

          UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

               FROM
              (   SELECT Test       = @TableName+'->Row',
		  				 ErrorDok   = 'Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT)),
		 	             ErrorMsg   = CASE WHEN ((ISNULL(TREGDK,'')='') AND (ISNULL(B.DB,0)<>0 OR ISNULL(B.KR,0)<>0 OR ISNULL(DBKRMV,0)<>0))
                                           THEN 'TregDK gabim '
                                           ELSE 'Mon baze/vleftat gabim '
                                      END,
			             ErrorRef   = 'Kod: '+B.KOD+' / '+B.TIPKLL,
                         ErrorOrder = @ErrorOrd+'/06',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM VSST A Inner Join #LMTestVT A1 On A.NRRENDOR = A1.NRRENDOR
							    Left  Join VSSTSCR B    On A.NRRENDOR = B.NRD
				   WHERE ((ISNULL(TREGDK,'')='') AND (ISNULL(B.DB,0)<>0 OR ISNULL(B.KR,0)<>0 OR ISNULL(DBKRMV,0)<>0)) 
                         OR
                        ( (B.KURS1=1 AND B.KURS2=1) AND 
                         ((B.TREGDK='D' AND B.DB<>DBKRMV) Or (B.TREGDK='K' AND KR<>0-DBKRMV)))
              ) A
        END



-- T6 ----------------------      F K S T     -------------------------

			 SELECT NRRENDOR
			   INTO #LMTestFT
			   FROM FKST

                SET @TableName = 'FKST'
				SET @ErrorOrd  = 'Dok '+@TableName+' '

    IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,LM,'+@TableName,'')<>''
        BEGIN

			 INSERT INTO #TestLMDok
				   (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @TableName,'','','','',@TableName,0,@ErrorOrd,-1
          UNION ALL		           
			 SELECT @TableName,'','','=====    '+@TableName+'    =====','',@TableName,0,@ErrorOrd,-1
          UNION ALL
	         SELECT @TableName,'','','','',@TableName,0,@ErrorOrd,-1

-- F1.					 -- Shumat e Vlerave te Dokumentit me ato te rrjeshtave
		  UNION ALL      
			 SELECT @TableName,'','','Kuadrim rrjeshta','',@TableName,0,@ErrorOrd+'/01',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (	  SELECT Test       = @TableName+'->Detaj',
						 ErrorDok   = MAX('Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Diference vlefta',
						 ErrorRef   = 'Shuma Db-Kr: '+CAST(Sum(B.DBKRMV) AS Varchar),
						 ErrorOrder = @ErrorOrd+'/01',
						 TableName  = @TableName,
						 A.NRRENDOR  
				    FROM FKST A Inner Join #LMTestFT A1 On A.NRRENDOR = A1.NRRENDOR
							    Inner Join FKSTSCR B    On A.NRRENDOR = B.NRD 
			    GROUP BY A.NRRENDOR 
				  Having (ABS(SUM(B.DBKRMV))>=@TestVlere)
			  ) A

-- F2.					 -- Referenca te panjohura Klient,Furnitor,Monedhe,Artikuj,Ardhura,Shpenzime,Sherbime etj.
		  UNION ALL      
			 SELECT @TableName,'','','Referenca panjohura','',@TableName,0,@ErrorOrd+'/02',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (	  SELECT Test       = @TableName+'->Ref',
						 ErrorDok   = 'Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Reference panjohur',
						 ErrorRef   = +B.LLOGARIPK+' / Llogari ',
						 ErrorOrder = @ErrorOrd+'/02',
						 TableName  = @TableName,
						 A.NRRENDOR  
					FROM FKST A Inner Join #LMTestFT A1 On A.NRRENDOR = A1.NRRENDOR
							    Inner Join FKSTSCR B    On A.NrRendor = B.NrD
				   WHERE (NOT EXISTS (SELECT KOD FROM LLOGARI  C WHERE C.KOD=B.LLOGARIPK))
			  ) A

-- F3.					 -- Dokumenta me Nr te perseritur
		  UNION ALL     
			 SELECT @TableName,'','','Nr. perseritur','',@TableName,0,@ErrorOrd+'/03',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Nr',
						 ErrorDok   = MAX('Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Dok. perseritur',
						 ErrorRef   = 'Nr '+
                                      CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+'/'+
									  CONVERT(nVarchar(10),YEAR(DATEDOK))+' - '+
									  CAST(COUNT(*) AS Varchar)+' here',
						 ErrorOrder = @ErrorOrd+'/03',
						 TableName  = @TableName,
						 NRRENDOR   = MIN(A.NRRENDOR ) 

					FROM FKST A Inner Join #LMTestFT A1 On A.NRRENDOR = A1.NRRENDOR
				GROUP BY YEAR(DATEDOK),NRDOK
				  Having COUNT(*)>=2 
			  ) A

-- F4.					 -- Dokumenta pa rrjeshta
		  UNION ALL      
			 SELECT @TableName,'','','Dok. pa rreshta','',@TableName,0,@ErrorOrd+'/04',0

		  UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Row',
						 ErrorDok   = MAX('Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Dok. pa rrjeshta',
						 ErrorRef   = '',
						 ErrorOrder = @ErrorOrd+'/04',
						 TableName  = @TableName,
						 A.NRRENDOR 
					FROM FKST A Inner Join #LMTestFT A1 On A.NRRENDOR = A1.NRRENDOR
                                Left  Join FKSTSCR B    On A.NRRENDOR = B.NRD
				GROUP BY A.NRRENDOR
				  Having ISNULL(COUNT(*),0)<=0 
			  ) A

-- F5.					 -- Kod Pa Monedhe
		  UNION ALL     
			 SELECT @TableName,'','','Mon ne Scr','',@TableName,0,@ErrorOrd+'/05',0

          UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

               FROM
              (   SELECT Test       = @TableName+'->Row',
		  				 ErrorDok   = 'Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
		 	             ErrorMsg   = 'Kod pa Mon: '+ISNULL(B.KMON,''),
			             ErrorRef   = 'Kod: '+B.KOD,
                         ErrorOrder = @ErrorOrd+'/05',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM FKST A Inner Join #LMTestFT A1 On A.NRRENDOR = A1.NRRENDOR
							  Left    Join FKSTSCR B    On A.NRRENDOR = B.NRD
				   WHERE dbo.Isd_SegmentFind(B.KOD,0,5) <> ISNULL(B.KMon,'')
             ) A

-- F6.					 -- Vlefta ne rastin Monedhe baze
		  UNION ALL     
			 SELECT @TableName,'','','Vlefta mon baze Scr, TregDK','',@TableName,0,@ErrorOrd+'/06',0

          UNION ALL
			 SELECT @TableName,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

               FROM
              (   SELECT Test       = @TableName+'->Row',
		  				 ErrorDok   = 'Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
		 	             ErrorMsg   = CASE WHEN ((ISNULL(TREGDK,'')='') AND (ISNULL(B.DB,0)<>0 OR ISNULL(B.KR,0)<>0 OR ISNULL(DBKRMV,0)<>0))
                                           THEN 'TregDK gabim '
                                           ELSE 'Mon baze/vleftat gabim '
                                      END,
			             ErrorRef   = 'Kod: '+B.KOD,
                         ErrorOrder = @ErrorOrd+'/06',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM FKST A Inner Join #LMTestVT A1 On A.NRRENDOR = A1.NRRENDOR
							    Left  Join FKSTSCR B    On A.NRRENDOR = B.NRD
				   WHERE ((ISNULL(TREGDK,'')='') AND (ISNULL(B.DB,0)<>0 OR ISNULL(B.KR,0)<>0 OR ISNULL(DBKRMV,0)<>0)) 
                         OR
                        ( (B.KURS1=1 AND B.KURS2=1) AND 
                         ((B.TREGDK='D' AND B.DB<>DBKRMV) Or (B.TREGDK='K' AND KR<>0-DBKRMV)))
              ) A
        END;



-------------------------- A f i s h i m i ----------------

          IF OBJECT_ID('TempDB..#LMTestAR') IS NOT NULL
             DROP TABLE #LMTestAR; 
          IF OBJECT_ID('TempDB..#LMTestBA') IS NOT NULL
             DROP TABLE #LMTestBA; 
          IF OBJECT_ID('TempDB..#LMTestVS') IS NOT NULL
             DROP TABLE #LMTestVS; 
          IF OBJECT_ID('TempDB..#LMTestFK') IS NOT NULL
             DROP TABLE #LMTestFK; 
          IF OBJECT_ID('TempDB..#LMTestVT') IS NOT NULL
             DROP TABLE #LMTestVT; 
          IF OBJECT_ID('TempDB..#LMTestFT') IS NOT NULL
             DROP TABLE #LMTestFT;


          IF @TestTable<>''      -- Mbush nje tabele qe mund te afishohet me vone ....
             BEGIN
               SET  @sSql = '
              INSERT INTO '+@TestTable+'
                    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
              SELECT ISNULL(Dok,''''),      ISNULL(Test,''''),     ISNULL(ErrorDok,''''),
                     ISNULL(ErrorMsg,''''), ISNULL(ErrorRef,''''), ISNULL(TableName,''''),
                     ISNULL(NrRendor,0),    ErrorOrder,            ErrorRowNr
                FROM #TestLMDok

                DROP TABLE #TestLMDok; ';
               EXEC (@sSql);
             END  
          ELSE
             BEGIN
               SELECT * FROM #TestLMDok ORDER BY ErrorOrder,ErrorRowNr,TableName;
             END;


GO
