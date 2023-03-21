SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   procedure [dbo].[Isd_TestDokFJ]
(
  @pDateKp    Varchar(20),
  @pDateKs    Varchar(20),
  @pTNames    Varchar(1000),
  @pTestVlere Float,
  @pTestTable Varchar(30)
)
AS

--         IF OBJECT_ID('TempDB..#TestDok') IS NOT NULL
--            DROP TABLE #TestDok; 
--     SELECT Dok      = REPLICATE('',20),  Test      = REPLICATE('',30),  ErrorDok   = REPLICATE('',100), ErrorMsg   = REPLICATE('',100),
--            ErrorRef = REPLICATE('',100), TableName = REPLICATE('',100), ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(0 AS BIGINT), NrRendor = 0
--       INTO #TestDok     
--      WHERE 1=2;
--       EXEC dbo.Isd_TestDokFJ '01/01/2010','31/12/2012','FJ',0.01,'#TestDok';

-- Test 1.     Lidhja e Fatures me Dokumentin Magazine
-- Test 2.     Elementet e Fatures me ato te dokumentit magazine --
-- Test 3.     Shumat e Vlerave te Fatures me ato te rrjeshtave
-- Test 4.     Referenca te panjohura Klient,Furnitor,Monedhe,Artikuj,Ardhura,Shpenzime,Sherbime,Aktive etj.
-- Test 5.     Dokumenta me Nr te perseritur
-- Test 6.     Dokumenta pa rrjeshta
-- Test 7.     Test per KMag, KMon dhe Artikull ne KOD tek rrjeshtat
-- Test 8.     Test per Kod, KMon ne dokument, Monvendi dhe kurse ne dokument
-- Test 9.     Test per Kod, KMon ne Ditar, Monvendi dhe kurse ne Ditar (Njesoj si Testi 8)


     DECLARE @DateKp      DateTime,
             @DateKs      DateTime,
             @TestVlere   Float,
             @TestTable   Varchar(30),
             @ErrorOrd    Varchar(100),
             @ErrorMsg    Varchar(100),
             @TableName   Varchar(30),
             @DitarName   Varchar(30),
             @Dok         Varchar(20),
             @sSql        Varchar(MAX);

         SET @DateKp    = dbo.DateValue(@PDateKp);
         SET @DateKs    = dbo.DateValue(@PDateKs);
         SET @TestTable = @pTestTable;
         SET @TestVlere = @pTestVlere;
         SET @TableName = 'FJ'
         SET @DitarName = 'DKL';

         IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,SH,'+@TableName,'')=''
             RETURN

-- Inicializimi
          IF OBJECT_ID('TempDB..#TestFtFJ') IS NOT NULL
             DROP TABLE #TestFtFJ; 
          IF OBJECT_ID('TempDB..#TestFJ')   IS NOT NULL
             DROP TABLE #TestFJ; 
          IF OBJECT_ID('TempDB..#TestDtFJ') IS NOT NULL
             DROP TABLE #TestDtFJ; 

      SELECT NRRENDOR
        INTO #TestFJ
        FROM FJ
       WHERE DateDok>=@DateKp AND DateDok<=@DateKs;

      SELECT NRRENDOR
        INTO #TestDtFJ
        FROM DKL
       WHERE DateDok>=@DateKp AND DateDok<=@DateKs;

          IF @TestVlere<=0
             SET @TestVlere = 0.01;

      SELECT Dok      = REPLICATE('',20),  Test      = REPLICATE('',30),  ErrorDok   = REPLICATE('',100), ErrorMsg   = REPLICATE('',100),
             ErrorRef = REPLICATE('',100), TableName = REPLICATE('',100), ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(0 AS BIGINT), NrRendor = 0
        INTO #TestFtFJ    
       WHERE 1=2;

         SET @ErrorOrd = 'Dok  '+@TableName+' ';
         SET @Dok      = 'DOK';

	  INSERT INTO #TestFtFJ
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
		           
	  SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
   UNION ALL
	  SELECT @Dok,'','','=====   '+@TableName+'   =====','',@TableName,0,@ErrorOrd,-1
   UNION ALL
	  SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1;


-- T1.                           Lidhja e Fatures me Dokumentin Magazine
      INSERT INTO #TestFtFJ  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','','Lidhje Ft - Mag','',@TableName,0,@ErrorOrd+'/01',0

   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/01',
             ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

       FROM
	   (SELECT Test      = @TableName+'->FD',
			   ErrorDok  = @TableName+' '+CONVERT(nVarchar(20),CAST(A1.NrDokFt AS BIGINT))+', '+CONVERT(Varchar,A1.DateDokFt,4),
			   ErrorMsg  = CASE WHEN B1.NrRendorMg IS NULL        THEN 'Mungon dok mag.'
							    WHEN A1.KMagFt<>B1.KMagMg         THEN 'Magazina gabim'+ISNULL(A1.KMagFt,'')+'/'+ISNULL(B1.KMagMg,'')
							    WHEN A1.NrDokFtMg<>B1.NrDokMg OR
							 		 A1.FrDokFtMg<>B1.FrDokMg     THEN 'Nr dok gabim'
							    WHEN A1.DateDokFtMg<>B1.DateDokMg THEN 'Data gabim'
							    WHEN A1.NrRowFt<>B1.NrRowMg       THEN 'Perberes gabim'
							    WHEN B1.DokJBMg<>1                THEN 'Dok mag jo fature'
							    ELSE                                   'Gabim lidhje.'
						   END,
			   ErrorRef  = 'Dokumenti Ft',
			   TableName = @TableName,
			   NrRendor  = CAST(A1.NrRendorFt AS INT)
		  FROM 
			  ( SELECT                              NrDokFt   = MAX(A.NRDOK),  DateDokFt   = MAX(A.DATEDOK), 
					   KMagFt       = MAX(A.KMAG),  NrDokFtMg = MAX(A.NRDMAG), DateDokFtMg = MAX(A.DTDMAG), FrDokFtMg = MAX(ISNULL(A.FRDMAG,0)),
					   NrRendorFtMg = MAX(A.NRRENDDMG),
					   NrRowFt      = COUNT(C.NRD),
					   NrRendorFt   = A.NRRENDOR
				  FROM FJ A INNER JOIN #TestFJ A1 ON A.NRRENDOR = A1.NRRENDOR
                            LEFT  JOIN FJSCR C    ON A.NRRENDOR = C.NRD AND C.TIPKLL='K'
				 WHERE ISNULL(A.KMAG,'')<>'' 
			  GROUP BY A.NRRENDOR ) A1
		        
			   LEFT JOIN 

			  ( SELECT KMagMg       = MAX(A.KMAG),    NrDokMg   = MAX(A.NRDOK),  DateDokMg = MAX(A.DATEDOK),FrDokMg   = MAX(ISNULL(A.NRFRAKS,0)),
					   NrRowMg      = COUNT(C.NRD),
					   DokJBMg      = MAX(CAST(DOK_JB AS INT)),
					   NrRendorMg   = CAST(A.NRRENDOR AS INT)
				  FROM FD A LEFT JOIN FDSCR C ON A.NRRENDOR=C.NRD AND ISNULL(C.GJENROWAUT,0)=0
			     WHERE DateDok>=@DateKp AND DateDok<=@DateKs
			  GROUP BY A.NRRENDOR ) B1

			   ON A1.NrRendorFtMg = B1.NrRendorMg

		   WHERE (B1.NrRendorMg IS NULL)    OR 
				 (A1.KMagFt<>B1.KMagMg)     OR (A1.NrDokFtMg<>B1.NrDokMg) OR 
				 (A1.FrDokFtMg<>B1.FrDokMg) OR (A1.DateDokFtMg<>B1.DateDokMg) OR
				 (A1.NrRowFt<>NrRowMg)
       ) B;


-- T2                            Elementet e Fatures me ato te dokumentit magazine
     INSERT INTO #TestFtFJ  
		   (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
     SELECT @Dok,'','','Lidhje Ft-Mag,perberes','',@TableName,0,@ErrorOrd+'/02',0

  UNION ALL
     SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/02',
            ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

       FROM
	  ( SELECT Test       = @TableName+'->FD Detaj',
			   ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A1.NrDokFt AS BIGINT))+', '+CONVERT(Varchar,A1.DateDokFt,4),
			   ErrorMsg   = CASE --WHEN B1.NrRendorMg IS NULL  THEN 'Mungon dok mag.'
						 		 WHEN B1.ArtikMg IS NULL              THEN 'ndryshim artik.'
						 		 WHEN A1.NrRowFt<>B1.NrRowMg          THEN 'nr art. ndryshem'
						 		 WHEN ABS(SasiFt-SasiMg)>=@TestVlere  THEN 'Sasi te ndryshem'
								 ELSE                                      'Gabim lidhje.'
						    END,
			   ErrorRef   = 'Artikulli '+A1.ArtikFt,--CASE WHEN B1.NrRendorMg IS NULL  THEN '' ELSE 'Artikulli '+A1.ArtikFt END,
			   TableName  = @TableName,
		       NrRendor   = A1.NrRendorFt
		  FROM 
			 (  SELECT NrDokFt      = MAX(A.NRDOK), DateDokFt = MAX(A.DATEDOK), 
					   KMagFt       = MAX(A.KMAG),

					   ArtikFt      = C.KARTLLG,
					   SASIFt       = SUM(C.SASI), 
					   NrRowFt      = COUNT(C.NRD), 

					   NrRendorFtMg = MAX(A.NRRENDDMG),
					   NrRendorFt   = A.NRRENDOR
				  FROM FJ A INNER JOIN #TestFJ A1 ON A.NRRENDOR = A1.NRRENDOR
                            INNER JOIN FJSCR C    ON A.NRRENDOR = C.NRD
  				 WHERE (NOT ((A.KMAG IS NULL) OR (A.KMag=''))) AND C.TIPKLL='K'
			  GROUP BY A.NRRENDOR, C.KARTLLG 
             ) A1
		        
			   LEFT JOIN 

			 (  SELECT KMagMg     = MAX(A.KMAG), 
					   NrDokMg    = MAX(A.NRDOK), 
					   FrDokMg    = MAX(A.NRFRAKS), 
					   DateDokMg  = MAX(A.DATEDOK), 

					   ArtikMg    = C.KARTLLG,
					   SasiMg     = SUM(C.SASI),
					   NrRowMg    = COUNT(C.NRD), 
		               
					   NrRendorMg = A.NRRENDOR
				  FROM FD A INNER JOIN FDSCR C ON A.NRRENDOR=C.NRD
				 WHERE DateDok>=@DateKp AND DateDok<=@DateKs AND ISNULL(GJENROWAUT,0)=0
			  GROUP BY A.NRRENDOR, C.KARTLLG 
             ) B1

			   ON A1.NrRendorFtMg = B1.NrRendorMg AND A1.ArtikFt=B1.ArtikMg

		   WHERE (B1.NrRendorMg IS NULL) OR (B1.ArtikMg IS NULL) OR (A1.NrRowFt<>B1.NrRowMg) OR (SasiFt<>SasiMg)
      ) B;


-- T3.                           Shumat e Vlerave te Fatures me ato te rrjeshtave
     INSERT INTO #TestFtFJ  
		   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
     SELECT @Dok,'','','Kuadrim rrjeshta Ft','',@TableName,0,@ErrorOrd+'/03',0

  UNION ALL
     SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/03',
            ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

       FROM
	( 	  SELECT Test       = @TableName+'->Detaj',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(MAX(A.NrDok) AS BIGINT))+', '+CONVERT(Varchar,MAX(A.DateDok),4),
			     ErrorMsg   = CASE WHEN ABS(SUM(B.VLPATVSH)-MAX(A.VLPATVSH))>=@TestVlere THEN 'Vlefta pa Tvsh.'
						 		   WHEN ABS(SUM(B.VLTVSH)  -MAX(A.VLTVSH))  >=@TestVlere THEN 'Vleft Tvsh.'
								   ELSE                                                       'Diference vlefta'
						      END,
			     ErrorRef   = 'Shuma Vl.PaTvsh/Tvsh',
			     TableName  = @TableName,
                 A.NRRENDOR  
		   FROM FJ A INNER JOIN #TestFJ A1 ON A.NRRENDOR = A1.NRRENDOR
                     INNER JOIN FJSCR B    ON A.NRRENDOR = B.NRD 
		  WHERE ISNULL(A.VLERZBR,0)=0 
	   GROUP BY A.NRRENDOR 
		 HAVING (ABS(SUM(B.VLPATVSH)-MAX(A.VLPATVSH))>=@TestVlere) OR (ABS(SUM(B.VLTVSH)-MAX(A.VLTVSH))>=@TestVlere)
     ) A;


-- T4.                           Referenca te panjohura Klient,Furnitor,Monedhe,Artikuj,Ardhura,Shpenzime,Sherbime etj.
     INSERT INTO #TestFtFJ  
		   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
     SELECT @Dok,'','','Referenca panjohura Ft','',@TableName,0,@ErrorOrd+'/04',0

  UNION ALL
     SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM

	( 	  SELECT Test       = @TableName+'->Ref',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			     ErrorMsg   = 'Ref panjohur /1',
			     ErrorRef   = CASE WHEN (NOT EXISTS (SELECT KOD FROM KLIENT   B WHERE B.KOD=A.KODFKL)) THEN 'Kli.: '+ISNULL(A.KODFKL,'')
                                   WHEN (NOT EXISTS (SELECT KOD FROM MONEDHA  B WHERE B.KOD=A.KMON))   THEN 'Mon : '+ISNULL(A.KMON,'')
                                   WHEN ((ISNULL(A.KMAG,'')<>'') AND (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAG AND B.NRRENDOR=A.NRMAG)))
                                                                                                       THEN 'Mg/Id.Mg : '+ISNULL(A.KMAG,'')
                              END, 
                 ErrorOrder = @ErrorOrd+'/04 1',
                 ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			     TableName  = @TableName,
                 A.NRRENDOR  
		    FROM FJ A INNER JOIN #TestFJ A1 ON A.NRRENDOR = A1.NRRENDOR
		   WHERE (NOT EXISTS (SELECT KOD FROM KLIENT   B WHERE B.KOD=A.KODFKL)) OR
                 (NOT EXISTS (SELECT KOD FROM MONEDHA  B WHERE B.KOD=A.KMON)) OR
                ((ISNULL(A.KMAG,'')<>'') AND (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAG AND B.NRRENDOR=A.NRMAG)))

       UNION ALL 

          SELECT Test       = @TableName+'->Ref',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			     ErrorMsg   = 'Ref panjohur /2',
			     ErrorRef   = +B.KARTLLG+' / '+
                              CASE WHEN B.TIPKLL='K' THEN 'Art '
                                   WHEN B.TIPKLL='L' THEN 'Ardh '
                                   WHEN B.TIPKLL='R' THEN 'Shrb '
                                   WHEN B.TIPKLL='S' THEN 'Kli '
                                   WHEN B.TIPKLL='F' THEN 'Fur '
                                   WHEN B.TIPKLL='X' THEN 'Akt '
                                   ELSE                   'Rrjeshti: '
                              END,
                 ErrorOrder = @ErrorOrd+'/04 2',
                 ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			     TableName  = @TableName,
                 A.NRRENDOR  

		    FROM FJ A INNER JOIN #TestFJ A1 ON A.NRRENDOR = A1.NRRENDOR
                      INNER JOIN FJSCR B    ON A.NrRendor = B.NrD
		   WHERE 
		 	    ((B.TipKll='K' AND (NOT EXISTS (SELECT KOD FROM ARTIKUJ   C WHERE C.KOD=B.KARTLLG))) OR
				 (B.TipKll='R' AND (NOT EXISTS (SELECT KOD FROM SHERBIM   C WHERE C.KOD=B.KARTLLG))) OR
				 (B.TipKll='L' AND (NOT EXISTS (SELECT KOD FROM LLOGARI   C WHERE C.KOD=B.KARTLLG))) OR
				 (B.TipKll='S' AND (NOT EXISTS (SELECT KOD FROM KLIENT    C WHERE C.KOD=B.KARTLLG))) OR
				 (B.TipKll='F' AND (NOT EXISTS (SELECT KOD FROM FURNITOR  C WHERE C.KOD=B.KARTLLG))) OR
				 (B.TipKll='X' AND (NOT EXISTS (SELECT KOD FROM AQKARTELA C WHERE C.KOD=B.KARTLLG))))
     ) A;


-- T5.                           Dokumenta me Nr te perseritur
     INSERT INTO #TestFtFJ  
		   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
     SELECT @Dok,'','','Nr. dok. perseritur','',@TableName,0,@ErrorOrd+'/05',0

  UNION ALL
     SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/05',
            ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

       FROM
	( 	  SELECT Test       = @TableName+'->Nr',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,MIN(A.DateDok),4),
			     ErrorMsg   = 'Dok. perseritur',
			     ErrorRef   = 'Figuron '+CAST(COUNT(*) AS Varchar),
			     TableName  = @TableName,
                 NRRENDOR   = MIN(A.NRRENDOR ) 

		    FROM FJ A INNER JOIN #TestFJ A1 ON A.NRRENDOR = A1.NRRENDOR
        GROUP BY YEAR(DATEDOK),NRDOK 
          HAVING COUNT(*)>=2 
     ) A;


-- T6.                           Dokumenta pa rrjeshta
     INSERT INTO #TestFtFJ  
		   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
     SELECT @Dok,'','','Dok. pa rrjeshta','',@TableName,0,@ErrorOrd+'/06',0

  UNION ALL
     SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/06',
            ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

       FROM
	( 	  SELECT Test       = @TableName+'->Row',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(MAX(A.NrDok) AS BIGINT))+', '+CONVERT(Varchar,MAX(A.DateDok),4),
			     ErrorMsg   = 'Dok. pa rrjeshta',
			     ErrorRef   = '',
			     TableName  = @TableName,
                 A.NRRENDOR 
		    FROM FJ A INNER JOIN #TestFJ A1 ON A.NRRENDOR = A1.NRRENDOR
                      LEFT  JOIN FJSCR B    ON A.NRRENDOR=B.NRD
        GROUP BY A.NRRENDOR
          HAVING ISNULL(COUNT(*),0)<=0 
     ) A;


-- T7.                           Test per KMag, KMon dhe Artikull ne KOD tek rrjeshtat
     INSERT INTO #TestFtFJ  
		   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
     SELECT @Dok,'','','Mag / Mon ne rrjeshta','',@TableName,0,@ErrorOrd+'/07',0

  UNION ALL
     SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM

	( 	  SELECT Test       = @TableName+'->Row',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			     ErrorMsg   = CASE WHEN dbo.Isd_SegmentFind(B.KOD,0,1)<>A.KMag    THEN 'Kod pa Mag: '+ISNULL(A.KMAG,'')
                                   WHEN dbo.Isd_SegmentFind(B.KOD,0,2)<>B.KARTLLG THEN 'Kod pa Art: '+ISNULL(B.KARTLLG,'')
                                   ELSE                                                'Kod: '+B.KOD
                              END, 
			     ErrorRef   = 'Kod: '+B.KOD,
                 ErrorOrder = @ErrorOrd+'/07 1',
                 ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			     TableName  = @TableName,
                 A.NRRENDOR 
		    FROM FJ A INNER JOIN #TestFJ A1 ON A.NRRENDOR = A1.NRRENDOR
                      LEFT  JOIN FJSCR B    ON A.NRRENDOR = B.NRD
		   WHERE B.TIPKLL='K' AND 
                (dbo.Isd_SegmentFind(B.KOD,0,1)<>A.KMag OR dbo.Isd_SegmentFind(B.KOD,0,2)<>B.KARTLLG)

       UNION ALL

          SELECT Test       = @TableName+'->Row',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			     ErrorMsg   = 'Kod pa Mon: '+ISNULL(A.KMON,''),
			     ErrorRef   = 'Kod: '+B.KOD+' /'+B.TIPKLL,
                 ErrorOrder = @ErrorOrd+'/07 2',
                 ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			     TableName  = @TableName,
                 A.NRRENDOR 
		    FROM FJ A INNER JOIN #TestFJ A1 ON A.NRRENDOR = A1.NRRENDOR
                      LEFT  JOIN FJSCR B    ON A.NRRENDOR = B.NRD
		   WHERE ISNULL(A.KMon,'')<>'' AND 
                (CASE WHEN CHARINDEX(TipKLL,'KLX')>0 THEN dbo.Isd_SegmentFind(B.KOD,0,5)
                      ELSE                                dbo.Isd_SegmentFind(B.KOD,0,2)
                 END) <> A.KMon
     ) A;



-- T8.                           Test per Kod, KMon nr dokument, Monvendi dhe kurse ne dokument
     INSERT INTO #TestFtFJ
		   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
     SELECT @Dok,'','','Kod / Mon ne dokument','',@TableName,0,@ErrorOrd+'/08',0

  UNION ALL
     SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr
            
       FROM

	( 	  SELECT Test       = @TableName+'',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			     ErrorMsg   = 'Kod pa Mon: '+ISNULL(A.KOD,'')+' - '+ISNULL(A.KMON,''), 
			     ErrorRef   = 'Dokumenti Ft',
                 ErrorOrder = @ErrorOrd+'/08 1',
                 ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			     TableName  = @TableName,
                 A.NRRENDOR 
		    FROM FJ A INNER JOIN #TestFJ A1 ON A.NRRENDOR = A1.NRRENDOR
		   WHERE A.KOD<>A.KODFKL+'.'+ISNULL(A.KMON,'')

       UNION ALL

          SELECT Test       = @TableName+'',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			     ErrorMsg   = 'MonVend dhe Kurs: '+CAST(A.KURS1 AS Varchar)+' - '+CAST(A.KURS2 AS Varchar),
			     ErrorRef   = 'Dokumenti Ft',
                 ErrorOrder = @ErrorOrd+'/08 2',
                 ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			     TableName  = @TableName,
                 A.NRRENDOR 
		    FROM FJ A INNER JOIN #TestFJ A1 ON A.NRRENDOR = A1.NRRENDOR
		   WHERE ISNULL(A.KMon,'')='' AND (A.KURS1<>1 OR A.KURS2<>1)
     ) A;


-- T9.                           Test per Kod, KMon ne Ditar, Monvendi dhe kurse ne Ditar (Njesoj si Testi 8)
     INSERT INTO #TestFtFJ  
		   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
     SELECT @Dok,'','','Kod / Mon ne ditar','',@TableName,0,@ErrorOrd+'/09',0

  UNION ALL
     SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor=0,ErrorOrder,ErrorRowNr
            
       FROM

	( 	  SELECT Test       = @DitarName+' - Ditar',
			     ErrorDok   = 'Ditar - '+A.KOD+': '+A.TIPDOK+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			     ErrorMsg   = 'Kod pa Mon: '+ISNULL(A.KOD,'')+' - '+ISNULL(A.KMON,''), 
			     ErrorRef   = 'Ditar dokumenti',
                 ErrorOrder = @ErrorOrd+'/09 1',
                 ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			     TableName  = @TableName,
                 A.NRRENDOR 
		    FROM DKL A INNER JOIN #TestDtFJ A1 ON A.NRRENDOR = A1.NRRENDOR
		   WHERE CHARINDEX('.'+ISNULL(A.KMON,''),A.KOD)=0

       UNION ALL

          SELECT Test       = @DitarName+' - Ditar',
			     ErrorDok   = 'Ditar - '+A.KOD+': '+A.TIPDOK+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			     ErrorMsg   = CASE WHEN A.VLEFTA<>A.VLEFTAMV     THEN 'MonVend dhe Vleftat: '+CAST(A.VLEFTA AS Varchar)+' - '+CAST(A.VLEFTAMV AS Varchar)
                                   WHEN A.KURS1<>1 OR A.KURS2<>1 THEN 'MonVend dhe Kurs: '   +CAST(A.KURS1  AS Varchar)+' - '+CAST(A.KURS2    AS Varchar)
                                   ELSE                               'MonVend dhe Kurs/Vleftat: '
                              END,
			     ErrorRef   = 'Ditar dokumenti',
                 ErrorOrder = @ErrorOrd+'/09 2',
                 ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			     TableName  = @TableName,
                 A.NRRENDOR 
		    FROM DKL A INNER JOIN #TestDtFJ A1 ON A.NRRENDOR = A1.NRRENDOR
		   WHERE ISNULL(A.KMon,'')='' AND (A.KURS1<>1 OR A.KURS2<>1 OR A.VLEFTA<>A.VLEFTAMV)
     ) A;

-- T10.                           Test per Kod me Mag,Artikull,Dep,List,Mon ne rrjeshtat
     INSERT INTO #TestFtFJ  
		   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
     SELECT @Dok,'','','Test Kod me Mag.Art.Dep.List.Mon','',@TableName,0,@ErrorOrd+'/10',0

  UNION ALL
     SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM

	( 	  SELECT Test       = @TableName+'->Row',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			     ErrorMsg   = 'Kod jo i sakte (Kod me Mag.Art.Dp.Ls.Mon)', 
			     ErrorRef   = 'kod:'+ISNULL(B.KOD,'')+
                              ' - duhet:'+ISNULL(A.KMAG,'')+'.'+
                                          dbo.Isd_SegmentFind(B.KODAF,0,1)+'.'+
                                          dbo.Isd_SegmentFind(B.KODAF,0,2)+'.'+
                                          dbo.Isd_SegmentFind(B.KODAF,0,3)+'.'+
                                          ISNULL(A.KMON,''),
                 ErrorOrder = @ErrorOrd+'/10 1',
                 ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			     TableName  = @TableName,
                 A.NRRENDOR 
		    FROM FJ A INNER JOIN #TestFJ A1 ON A.NRRENDOR = A1.NRRENDOR
                      LEFT  JOIN FJSCR B    ON A.NRRENDOR = B.NRD
		   WHERE B.TIPKLL='K' AND
                (B.KOD <> ISNULL(A.KMAG,'')+'.'+
                          dbo.Isd_SegmentFind(B.KODAF,0,1)+'.'+
                          dbo.Isd_SegmentFind(B.KODAF,0,2)+'.'+
                          dbo.Isd_SegmentFind(B.KODAF,0,3)+'.'+
                          ISNULL(A.KMON,''))


       UNION ALL

          SELECT Test       = @TableName+'->Row',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			     ErrorMsg   = 'Kod jo i sakte (Kod me Ardh.Dp.Ls.Mg.Mon)', 
			     ErrorRef   = 'kod:'+ISNULL(B.KOD,'')+
                              ' - duhet:'+dbo.Isd_SegmentFind(B.KODAF,0,1)+'.'+
                                          dbo.Isd_SegmentFind(B.KODAF,0,2)+'.'+
                                          dbo.Isd_SegmentFind(B.KODAF,0,3)+'.'+
                                          ISNULL(A.KMAG,'')               +'.'+
                                          ISNULL(A.KMON,''),
                 ErrorOrder = @ErrorOrd+'/10 2',
                 ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			     TableName  = @TableName,
                 A.NRRENDOR 
		    FROM FJ A INNER JOIN #TestFJ A1 ON A.NRRENDOR = A1.NRRENDOR
                      LEFT  JOIN FJSCR B    ON A.NRRENDOR = B.NRD
		   WHERE CHARINDEX(B.TIPKLL,'LX')>0 AND
                (B.KOD <> dbo.Isd_SegmentFind(B.KODAF,0,1)+'.'+
                          dbo.Isd_SegmentFind(B.KODAF,0,2)+'.'+
                          dbo.Isd_SegmentFind(B.KODAF,0,3)+'.'+
                          ISNULL(A.KMAG,'')               +'.'+
                          ISNULL(A.KMON,''))
     ) A;



-------------------------- A f i s h i m i --------------------------

          IF OBJECT_ID('TempDB..#TestFJ')   IS NOT NULL
             DROP TABLE #TestFJ; 
          IF OBJECT_ID('TempDB..#TestDtFJ') IS NOT NULL
             DROP TABLE #TestDtFJ;
              

          IF @TestTable<>''       -- Mbush nje tabele qe mund te afishohet me vone ....
             BEGIN
               SET   @sSql = '
              INSERT INTO '+@TestTable+'
                    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
              SELECT ISNULL(Dok,''''),      ISNULL(Test,''''),     ISNULL(ErrorDok,''''),
                     ISNULL(ErrorMsg,''''), ISNULL(ErrorRef,''''), ISNULL(TableName,''''), 
                     ISNULL(NrRendor,0),    ErrorOrder,            ErrorRowNr
                FROM #TestFtFJ;

                DROP TABLE #TestFtFJ; ';
                
               EXEC (@sSql);
               
             END
          ELSE
             BEGIN
               SELECT * FROM #TestFtFJ ORDER BY ErrorOrder,ErrorRowNr,TableName;
             END;
GO
