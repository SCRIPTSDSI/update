SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   procedure [dbo].[Isd_TestDokORK]
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
--      EXEC dbo.Isd_TestDokORK '01/01/2010','31/12/2012','ORK',0.01,'#TestDok';

-- Test 1.     
-- Test 2.     
-- Test 3.     Shumat e Vlerave te Fatures me ato te rrjeshtave
-- Test 4.     Referenca te panjohura Klient,Furnitor,Monedhe,Artikuj,Ardhura,Shpenzime,Sherbime etj.
-- Test 5.     Dokumenta me Nr te perseritur
-- Test 6.     Dokumenta pa rrjeshta
-- Test 7.     Test per KMag, KMon dhe Artikull ne KOD tek rrjeshtat
-- Test 8.     Test per Kod, KMon ne dokument, Monvendi dhe kurse ne dokument
-- Test 9.     

     DECLARE @ErrorOrd    Varchar(100),
             @ErrorMsg    Varchar(100),
             @TableName   Varchar(30),
             @TestVlere   Float,
             @TestTable   Varchar(30),
             @Dok         Varchar(20),
             @sSql        Varchar(MAX);

         SET @TableName = 'ORK';
         SET @TestVlere = @pTestVlere;
         SET @TestTable = @pTestTable;

          IF dbo.Isd_ListFields2Lists(@PTNames,'ALL,SH,'+@TableName,'')=''
             RETURN;

-- Inicializimi
          IF OBJECT_ID('TempDB..#TestFtORK') IS NOT NULL
             DROP TABLE #TestFtORK; 
          IF OBJECT_ID('TempDB..#TestORK') IS NOT NULL
             DROP TABLE #TestORK; 

      SELECT NRRENDOR
        INTO #TestORK
        FROM ORK
       WHERE DateDok>=dbo.DateValue(@PDateKp) AND DateDok<=dbo.DateValue(@PDateKs);

          IF @TestVlere<=0
             SET @TestVlere = 0.01;

      SELECT Dok      = REPLICATE('',20),  Test      = REPLICATE('',30),  ErrorDok   = REPLICATE('',100), ErrorMsg   = REPLICATE('',100),
             ErrorRef = REPLICATE('',100), TableName = REPLICATE('',100), ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(0 AS BIGINT), NrRendor = 0
        INTO #TestFtORK    
       WHERE 1=2;

         SET @ErrorOrd  = 'Dok '+@TableName;
         SET @Dok       = 'DOK';

	  INSERT INTO #TestFtORK
		    (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	  SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
   UNION ALL
	  SELECT @Dok,'','','=====   '+@TableName+'   =====','',@TableName,0,@ErrorOrd,-1
   UNION ALL
	  SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1

-- A1.                           Lidhja e Fatures me Dokumentin Magazine
-- A2.                           Elementet e Fatures me ato te dokumentit magazine 


-- A3.                           Shumat e Vlerave te Fatures me ato te rrjeshtave
  UNION ALL
     SELECT @Dok,'','','Kuadrim rrjeshta','',@TableName,0,@ErrorOrd+'/03',0

  UNION ALL
     SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/03',
            ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

       FROM
	    ( SELECT Test       = @TableName+'->Detaj',
		         ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(MAX(A.NrDok) AS BIGINT))+', '+CONVERT(Varchar,MAX(A.DateDok),4),
			     ErrorMsg   = CASE WHEN ABS(SUM(B.VLPATVSH)-MAX(A.VLPATVSH))>=@TestVlere THEN 'Vlefta pa Tvsh.'
			 			 	 	   WHEN ABS(SUM(B.VLTVSH)  -MAX(A.VLTVSH))  >=@TestVlere   THEN 'Vleft Tvsh.'
								   Else 'Diference vlefta'
						      END,
			     ErrorRef   = 'Shuma Vl.PaTvsh/Tvsh',
			     TableName  = @TableName,
                 A.NRRENDOR  
		    FROM ORK A Inner Join #TestORK A1 On A.NRRENDOR = A1.NRRENDOR
                       Inner Join ORKSCR B    On A.NRRENDOR = B.NRD 
		   WHERE ISNULL(A.VLERZBR,0)=0 
	    GROUP BY A.NRRENDOR 
		  Having (Abs(Sum(B.VLPATVSH)-MAX(A.VLPATVSH))>=@TestVlere) OR (Abs(Sum(B.VLTVSH)  -MAX(A.VLTVSH))  >=@TestVlere)
        ) A


-- A4.                       Referenca te panjohura Klient,Furnitor,Monedhe,Artikuj,Magazine,Ardhura,Shpenzime,Sherbime etj.
  UNION ALL
     SELECT @Dok,'','','Referenca panjohura','',@TableName,0,@ErrorOrd+'/04',0

  UNION ALL
     SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM

	    ( SELECT Test       = @TableName+'->Ref',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			     ErrorMsg   = 'Ref panjohur /1',
			     ErrorRef   = CASE WHEN (NOT EXISTS (SELECT KOD FROM FURNITOR B WHERE B.KOD=A.KODFKL)) THEN 'Furnitor: '+ISNULL(A.KODFKL,'')
                                   WHEN (NOT EXISTS (SELECT KOD FROM MONEDHA  B WHERE B.KOD=A.KMON))   THEN 'Monedhe : '+ISNULL(A.KMON,'')
                                   WHEN ((ISNULL(A.KMAG,'')<>'') AND 
                                        (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAG AND B.NRRENDOR=A.NRMAG)))
                                         THEN 'Mg/Id.Mg : '+ISNULL(A.KMAG,'')
                              END, 
                 ErrorOrder = @ErrorOrd+'/04 1',
                 ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			     TableName  = @TableName,
                 A.NRRENDOR  
		    FROM ORK A Inner Join #TestORK A1 On A.NRRENDOR = A1.NRRENDOR
		   WHERE (NOT EXISTS (SELECT KOD FROM FURNITOR B WHERE B.KOD=A.KODFKL)) Or
                 (NOT EXISTS (SELECT KOD FROM MONEDHA  B WHERE B.KOD=A.KMON)) Or
                ((ISNULL(A.KMAG,'')<>'') AND 
                 (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAG AND B.NRRENDOR=A.NRMAG)))

       UNION ALL 

          SELECT Test       = @TableName+'->Ref',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			     ErrorMsg   = 'Ref panjohur /2',
			     ErrorRef   = +B.KARTLLG+' / '+
                              CASE WHEN B.TIPKLL='K' THEN 'Art '
                                   WHEN B.TIPKLL='L' THEN 'Shpz '
                                   WHEN B.TIPKLL='R' THEN 'Shrb '
                                   WHEN B.TIPKLL='S' THEN 'Kli '
                                   WHEN B.TIPKLL='F' THEN 'Fur '
                                   WHEN B.TIPKLL='X' THEN 'Akt '
                              END,
                 ErrorOrder = @ErrorOrd+'/04 2',
                 ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			     TableName  = @TableName,
                 A.NRRENDOR  
		    FROM ORK A Inner Join #TestORK A1 On A.NRRENDOR = A1.NRRENDOR
                       Inner Join ORKSCR B    On A.NrRendor = B.NrD
		   WHERE ((B.TipKll='K' AND (NOT EXISTS (SELECT KOD FROM ARTIKUJ   C WHERE C.KOD=B.KARTLLG))) Or
				  (B.TipKll='R' AND (NOT EXISTS (SELECT KOD FROM SHERBIM   C WHERE C.KOD=B.KARTLLG))) Or
				  (B.TipKll='L' AND (NOT EXISTS (SELECT KOD FROM LLOGARI   C WHERE C.KOD=B.KARTLLG))) Or
			 	  (B.TipKll='S' AND (NOT EXISTS (SELECT KOD FROM KLIENT    C WHERE C.KOD=B.KARTLLG))) Or
				  (B.TipKll='F' AND (NOT EXISTS (SELECT KOD FROM FURNITOR  C WHERE C.KOD=B.KARTLLG))) Or
				  (B.TipKll='X' AND (NOT EXISTS (SELECT KOD FROM AQKARTELA C WHERE C.KOD=B.KARTLLG))))
        ) A


-- A5.                           Dokumenta me Nr te perseritur
  UNION ALL
     SELECT @Dok,'','','Nr. dok. perseritur','',@TableName,0,@ErrorOrd+'/05',0

  UNION ALL
     SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/05',
            ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

       FROM
	    ( SELECT Test       = @TableName+'->Nr',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,MIN(A.DateDok),4),
			     ErrorMsg   = 'Dok. perseritur',
			     ErrorRef   = 'Figuron '+CAST(COUNT(*) AS Varchar),
			     TableName  = @TableName,
                 NRRENDOR   = MIN(A.NRRENDOR ) 

		    FROM ORK A Inner Join #TestORK A1 On A.NRRENDOR = A1.NRRENDOR
        GROUP BY YEAR(DATEDOK),NRDOK 
          Having COUNT(*)>=2 
        ) A


-- A6.                           Dokumenta pa rrjeshta
  UNION ALL
     SELECT @Dok,'','','Dok. pa rrjeshta','',@TableName,0,@ErrorOrd+'/06',0

  UNION ALL
     SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/06',
            ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

       FROM
	    ( SELECT Test       = @TableName+'->Row',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(MAX(A.NrDok) AS BIGINT))+', '+CONVERT(Varchar,MAX(A.DateDok),4),
			     ErrorMsg   = 'Dok. pa rrjeshta',
			     ErrorRef   = '',
			     TableName  = @TableName,
                 A.NRRENDOR 
		    FROM ORK A Inner Join #TestORK A1 On A.NRRENDOR = A1.NRRENDOR
                       Left  Join ORKSCR B    On A.NRRENDOR=B.NRD
        GROUP BY A.NRRENDOR
          Having ISNULL(COUNT(*),0)<=0 
        ) A


-- A7.                           Test per KMag, KMon dhe Artikull ne KOD tek rrjeshtat
  UNION ALL
     SELECT @Dok,'','','Mag / Mon ne rrjeshta','',@TableName,0,@ErrorOrd+'/07',0

  UNION ALL
     SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM

	    ( SELECT Test       = @TableName+'->Row',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			     ErrorMsg   = CASE WHEN dbo.Isd_SegmentFind(B.KOD,0,1)<>A.KMag    THEN 'Kod pa Mag: '+ISNULL(A.KMAG,'')
                                   WHEN dbo.Isd_SegmentFind(B.KOD,0,2)<>B.KARTLLG THEN 'Kod pa Art: '+ISNULL(B.KARTLLG,'')
                                   Else 'Kod: '+B.KOD
                              END, 
			     ErrorRef   = 'Kod: '+B.KOD,
                 ErrorOrder = @ErrorOrd+'/07 1',
                 ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			     TableName  = @TableName,
                 A.NRRENDOR 
		    FROM ORK A Inner Join #TestORK A1 On A.NRRENDOR = A1.NRRENDOR
                       Left  Join ORKSCR B    On A.NRRENDOR = B.NRD
		   WHERE B.TIPKLL='K' AND 
                (dbo.Isd_SegmentFind(B.KOD,0,1)<>A.KMag or 
                 dbo.Isd_SegmentFind(B.KOD,0,2)<>B.KARTLLG)

       UNION ALL

          SELECT Test       = @TableName+'->Row',
			     ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			     ErrorMsg   = 'Kod pa Mon: '+ISNULL(A.KMON,''),
			     ErrorRef   = 'Kod: '+B.KOD+' /'+B.TIPKLL,
                 ErrorOrder = @ErrorOrd+'/07 2',
                 ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			     TableName  = @TableName,
                 A.NRRENDOR 
		    FROM ORK A Inner Join #TestORK A1 On A.NRRENDOR = A1.NRRENDOR
                       Left  Join ORKSCR B    On A.NRRENDOR = B.NRD
		   WHERE ISNULL(A.KMon,'')<>'' AND 
                (CASE WHEN TipKLL='K' Or TipKll='L' THEN dbo.Isd_SegmentFind(B.KOD,0,5)
                      Else                               dbo.Isd_SegmentFind(B.KOD,0,2)
                      END) <> A.KMon
        ) A


-- T8.                           Test per Kod, KMon nr dokument
  UNION ALL
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
		    FROM ORK A Inner Join #TestORK A1 On A.NRRENDOR = A1.NRRENDOR
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
		    FROM ORK A Inner Join #TestORK A1 On A.NRRENDOR = A1.NRRENDOR
		   WHERE ISNULL(A.KMon,'')='' AND (A.KURS1<>1 Or A.KURS2<>1)
     ) A;


-- Test 9.     Test per Kod, KMon ne Ditar, Monvendi dhe kurse ne Ditar (Njesoj si Testi 8)


-------------------------- A f i s h i m i --------------------------

          IF OBJECT_ID('TempDB..#TestORK') IS NOT NULL
             DROP TABLE #TestORK; 

          IF @TestTable<>''      -- Mbush nje tabele qe mund te afishohet me vone ....
             BEGIN
               SET @sSql = '
              INSERT INTO '+@TestTable+'
                    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
              SELECT ISNULL(Dok,''''),       ISNULL(Test,''''),      ISNULL(ErrorDok,''''),
                     ISNULL(ErrorMsg,''''),  ISNULL(ErrorRef,''''),  ISNULL(TableName,''''),
                     ISNULL(NrRendor,0),     ErrorOrder,             ErrorRowNr
                FROM #TestFtORK

                DROP TABLE #TestFtORK ';
             END   
          else
             BEGIN
               SELECT * FROM #TestFtORK ORDER BY ErrorOrder,ErrorRowNr,TableName;
             END;
GO
