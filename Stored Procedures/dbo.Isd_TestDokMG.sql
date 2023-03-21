SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   procedure [dbo].[Isd_TestDokMG]
(
  @pDateKp    Varchar(20),
  @pDateKs    Varchar(20),
  @pTNames    Varchar(1000),
  @pTestVlere Float,
  @pTestTable Varchar(30)
)
AS

--        IF OBJECT_ID('#TestDok') IS NOT NULL
--           DROP TABLE #TestDok;
--    SELECT Dok      = REPLICATE('',20),  Test      = REPLICATE('',30),  ErrorDok   = REPLICATE('',100), ErrorMsg   = REPLICATE('',100),
--           ErrorRef = REPLICATE('',100), TableName = REPLICATE('',100), ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(0 AS BIGINT), NrRendor = 0
--      INTO #TestDok     
--     WHERE 1=2;
--      EXEC dbo.Isd_TestDokMG '01/01/2010','31/12/2012','FH,FD',0.01,'#TestDok';

-- Test 1.     Test FH
-- Test 2.     Test FD

     DECLARE @DateKp      DateTime,
             @DateKs      DateTime,
             @TestTable   Varchar(30),
             @ErrorOrd    Varchar(100),
             @ErrorMsg    Varchar(100),
             @TableName   Varchar(30),
             @sSql        Varchar(MAX),
             @Dok         Varchar(20);

         SET @DateKp    = dbo.DateValue(@PDateKp);
         SET @DateKs    = dbo.DateValue(@PDateKs);
         SET @TestTable = @pTestTable;

         IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,MG,FH,FD','')=''
             RETURN;

-- Inicializimi
          IF OBJECT_ID('TempDB..#TestMGDok') IS NOT NULL
             DROP TABLE #TestMGDok; 
          IF OBJECT_ID('TempDB..#MGTestFH') IS NOT NULL
             DROP TABLE #MGTestFH; 
          IF OBJECT_ID('TempDB..#MGTestFD') IS NOT NULL
             DROP TABLE #MGTestFD;

      SELECT Dok      = REPLICATE('',20),  Test      = REPLICATE('',30),  ErrorDok   = REPLICATE('',100), ErrorMsg   = REPLICATE('',100),
             ErrorRef = REPLICATE('',100), TableName = REPLICATE('',100), ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(0 AS BIGINT), NrRendor = 0
        INTO #TestMGDok    
       WHERE 1=2;


-- -------------------------        F H       -------------------------

      SELECT NRRENDOR
        INTO #MGTestFH
        FROM FH
       WHERE DateDok>=@DateKp AND DateDok<=@DateKs;

         SET @TableName = 'FH';
         SET @ErrorOrd  = 'Dok '+@TableName+' ';
         SET @Dok       = 'DOK';

    IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,LM,'+@TableName,'')<>''
        BEGIN

			 INSERT INTO #TestMGDok
				   (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
          UNION ALL		           
			 SELECT @Dok,'','','=====    '+@TableName+'    =====','',@TableName,0,@ErrorOrd,-1
          UNION ALL
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1

-- A1.					 -- Referenca te panjohura KMag,KMagLNK,KMagRF, Artikuj ne Scr etj.
		  UNION ALL      
			 SELECT @Dok,'','','Referenca panjohura','',@TableName,0,@ErrorOrd+'/01',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

			   FROM
			  (   SELECT Test       = @TableName+'->Ref',
						 ErrorDok   = A.KMAG+', '+@TableName+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      CASE WHEN ISNULL(NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) Else '' END+
                                      ', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Mag/IdMg panjohur',
						 ErrorRef   = CASE WHEN                               (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAG))    THEN 'Mag : '   +ISNULL(A.KMAG,'')
                                           WHEN                               (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAG AND B.NRRENDOR=A.NRMAG)) THEN 'Id.Mg: '+ISNULL(A.KMAG,'')
										   WHEN (ISNULL(A.KMAGRF,'')<>''  AND (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAGRF)))  THEN 'Mag RF: ' +ISNULL(A.KMAGRF,'')
										   WHEN (ISNULL(A.KMAGLNK,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAGLNK))) THEN 'Mag Lnk: '+ISNULL(A.KMAGLNK,'')
									  END, 
						 ErrorOrder = @ErrorOrd+'/01 1',
                         ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
						 TableName  = @TableName,
						 A.NRRENDOR  
					FROM FH A Inner Join #MGTestFH A1 On A.NRRENDOR = A1.NRRENDOR
				   WHERE                               (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAG))   Or
                                                       (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAG AND B.NRRENDOR=A.NRMAG)) Or
						 (ISNULL(A.KMAGRF,'')<>''  AND (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAGRF))) Or
						 (ISNULL(A.KMAGLNK,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAGLNK)))
			   UNION ALL 
				  SELECT Test       = @TableName+'->Ref',
						 ErrorDok   = A.KMAG+' '+@TableName+' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      CASE WHEN ISNULL(NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) Else '' END+ 
                                      ', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Art panjohur',
						 ErrorRef   = 'Art: '+B.KARTLLG,
						 ErrorOrder = @ErrorOrd+'/01 2',
                         ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
						 TableName  = @TableName,
						 A.NRRENDOR  
					FROM FH A Inner Join #MGTestFH A1 On A.NRRENDOR = A1.NRRENDOR
							  Inner Join FHSCR B      On A.NrRendor = B.NrD
				   WHERE NOT EXISTS (SELECT KOD FROM ARTIKUJ C WHERE C.KOD=B.KARTLLG)
			  ) A

-- A2.					 -- Dokumenta me Nr te perseritur
		  UNION ALL     
			 SELECT @Dok,'','','Nr. perseritur','',@TableName,0,@ErrorOrd+'/02',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/02',
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Nr',
						 ErrorDok   = MAX(A.KMAG+', '+@TableName+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      CASE WHEN ISNULL(NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) Else '' END+
                                      ', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Dok. perseritur',
						 ErrorRef   = A.KMAG+', '+@TableName+' nr '+
                                      CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      CASE WHEN ISNULL(NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) Else '' END+'/'+
									  CONVERT(nVarchar(10),YEAR(DATEDOK))+' - '+
									  CAST(COUNT(*) AS Varchar)+' here',
						 TableName  = @TableName,
						 NRRENDOR   = MIN(A.NRRENDOR ) 

					FROM FH A Inner Join #MGTestFH A1 On A.NRRENDOR = A1.NRRENDOR
				GROUP BY KMAG,YEAR(DATEDOK),NRDOK,NRFRAKS 
				  Having COUNT(*)>=2 
			  ) A

-- A3.					 -- Dokumenta pa rrjeshta
		  UNION ALL      
			 SELECT @Dok,'','','Dok. pa rreshta','',@TableName,0,@ErrorOrd+'/03',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/03',
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Row',
						 ErrorDok   = MAX(A.KMAG+', '+@TableName+
                                         ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                         CASE WHEN ISNULL(NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) Else '' END+
                                         ', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Dok. pa rrjeshta',
						 ErrorRef   = '',
						 TableName  = @TableName,
						 A.NRRENDOR 
					FROM FH A Inner Join #MGTestFH A1 On A.NRRENDOR = A1.NRRENDOR
                              Left  Join FHSCR B      On A.NRRENDOR = B.NRD
				GROUP BY A.NRRENDOR
				  Having ISNULL(COUNT(*),0)<=0 
			 ) A
  
-- A4.					 -- Mungese Dokumenti fature
		  UNION ALL     
			 SELECT @Dok,'','','Mung. dok. fature','',@TableName,0,@ErrorOrd+'/04',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/04',
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Nr',
						 ErrorDok   = A.KMAG+', '+@TableName+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      CASE WHEN ISNULL(NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) Else '' END+
                                      ', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Mung. Dok.fature',
						 ErrorRef   = '',
						 TableName  = @TableName,
						 NRRENDOR   = A.NRRENDOR 
					FROM FH A Inner Join #MGTestFH A1 On A.NRRENDOR = A1.NRRENDOR
                   WHERE ISNULL(A.DOK_JB,0)=1 AND (NOT EXISTS (SELECT NRRENDOR FROM FF C WHERE C.NRRENDDMG=A.NRRENDOR))
			  ) A

 -- A5.					 -- Mosperputhje Kod me KMag+KodAF ne rrjeshta
		  UNION ALL      
			 SELECT @Dok,'','','Test Kod - Mag.Art.Dep.List.','',@TableName,0,@ErrorOrd+'/05',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/05',
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Row',
						 ErrorDok   = A.KMAG+', '+@TableName+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      CASE WHEN ISNULL(NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) Else '' END+
                                      ', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Kod jo i sakte (Kod me Mag.Art.Dp.Ls.)',
						 ErrorRef   = 'kod:'+ISNULL(B.KOD,'')+
                                      ' - duhet:'+A.KMAG+'.'+
                                                  dbo.Isd_SegmentFind(B.KODAF,0,1)+'.'+
                                                  dbo.Isd_SegmentFind(B.KODAF,0,2)+'.'+
                                                  dbo.Isd_SegmentFind(B.KODAF,0,3)+'.',
						 TableName  = @TableName,
						 A.NRRENDOR 
					FROM FH A Inner Join #MGTestFH A1 On A.NRRENDOR = A1.NRRENDOR
                              Left  Join FHSCR B      On A.NRRENDOR = B.NRD
                   WHERE ISNULL(B.KOD,'')<>A.KMAG+'.'+dbo.Isd_SegmentFind(B.KODAF,0,1)+'.'+
                                                      dbo.Isd_SegmentFind(B.KODAF,0,2)+'.'+
                                                      dbo.Isd_SegmentFind(B.KODAF,0,3)+'.'
				--GROUP BY A.NRRENDOR,B.NRRENDOR
				--Having ISNULL(COUNT(*),0)<=0 
			 ) A

        END


-- -------------------------        F D       -------------------------

      SELECT NRRENDOR
        INTO #MGTestFD
        FROM FD
       WHERE DateDok>=@DateKp AND DateDok<=@DateKs;

         SET @TableName = 'FD';
         SET @ErrorOrd  = 'Dok '+@TableName+' ';

    IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,LM,'+@TableName,'')<>''
        BEGIN

			 INSERT INTO #TestMGDok
				   (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
		  UNION ALL         
			 SELECT @Dok,'','','=====    '+@TableName+'    =====','',@TableName,0,@ErrorOrd,-1
          UNION ALL
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1

-- B1.					 -- Referenca te panjohura KMag,KMagLNK,KMagRF, Artikuj ne Scr etj.
		  UNION ALL      
			 SELECT @Dok,'','','Referenca panjohura','',@TableName,0,@ErrorOrd+'/01',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

			   FROM
			  (   SELECT Test       = @TableName+'->Ref',
						 ErrorDok   = A.KMAG+', '+@TableName+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      CASE WHEN ISNULL(NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) Else '' END+
                                      ', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Mag/IdMg panjohur',
						 ErrorRef   = CASE WHEN                               (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAG))     THEN 'Mag : '   +ISNULL(A.KMAG,'')
                                           WHEN                               (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAG AND B.NRRENDOR=A.NRMAG)) THEN 'Id.Mg: '+ISNULL(A.KMAG,'')
										   WHEN (ISNULL(A.KMAGRF,'')<>''  AND (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAGRF)))  THEN 'Mag RF: ' +ISNULL(A.KMAGRF,'')
										   WHEN (ISNULL(A.KMAGLNK,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAGLNK))) THEN 'Mag Lnk: '+ISNULL(A.KMAGLNK,'')
									  END, 
						 ErrorOrder = @ErrorOrd+'/01 1',
                         ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
						 TableName  = @TableName,
						 A.NRRENDOR  
					FROM FD A Inner Join #MGTestFD A1 On A.NRRENDOR = A1.NRRENDOR
				   WHERE                               (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAG))   Or
                                                       (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAG AND B.NRRENDOR=A.NRMAG)) Or
						 (ISNULL(A.KMAGRF,'')<>''  AND (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAGRF))) Or
						 (ISNULL(A.KMAGLNK,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAGLNK)))

			   UNION ALL 

				  SELECT Test       = @TableName+'->Ref',
						 ErrorDok   = A.KMAG+' '+@TableName+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      CASE WHEN ISNULL(NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) Else '' END+
                                      ', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Art panjohur',
						 ErrorRef   = 'Art: '+B.KARTLLG,
						 ErrorOrder = @ErrorOrd+'/01 2',
                         ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
						 TableName  = @TableName,
						 A.NRRENDOR  
					FROM FD A Inner Join #MGTestFD A1 On A.NRRENDOR = A1.NRRENDOR
							  Inner Join FDSCR B      On A.NrRendor = B.NrD
				   WHERE NOT EXISTS (SELECT KOD FROM ARTIKUJ C WHERE C.KOD=B.KARTLLG)
			 ) A

-- B2.					 -- Dokumenta me Nr te perseritur
		  UNION ALL     
			 SELECT @Dok,'','','Nr. perseritur','',@TableName,0,@ErrorOrd+'/02',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/02',
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Nr',
						 ErrorDok   = MAX(A.KMAG+', '+@TableName+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      CASE WHEN ISNULL(NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) Else '' END+
                                      ', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Dok. perseritur',
						 ErrorRef   = A.KMAG+', '+@TableName+' nr '+
                                      CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+'/'+
                                      CASE WHEN ISNULL(NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) Else '' END+
									  CONVERT(nVarchar(10),YEAR(DATEDOK))+' - '+
									  CAST(COUNT(*) AS Varchar)+' here',
						 TableName  = @TableName,
						 NRRENDOR   = MIN(A.NRRENDOR ) 
					FROM FD A Inner Join #MGTestFD A1 On A.NRRENDOR = A1.NRRENDOR
				GROUP BY KMAG,YEAR(DATEDOK),NRDOK,NRFRAKS 
				  Having COUNT(*)>=2 
			 ) A

-- B3.					 -- Dokumenta pa rrjeshta
		  UNION ALL      
			 SELECT @Dok,'','','Dok. pa rreshta','',@TableName,0,@ErrorOrd+'/03',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/03',
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Row',
						 ErrorDok   = MAX(A.KMAG+', '+@TableName+
                                         ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                         CASE WHEN ISNULL(NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) Else '' END+
                                         ', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Dok. pa rrjeshta',
						 ErrorRef   = '',
						 TableName  = @TableName,
						 A.NRRENDOR 
					FROM FD A Inner Join #MGTestFD A1 On A.NRRENDOR = A1.NRRENDOR
                              Left  Join FDSCR B      On A.NRRENDOR = B.NRD
				GROUP BY A.NRRENDOR
				  Having ISNULL(COUNT(*),0)<=0 
			 ) A

-- B4.					 -- Mungese Dokumenti fature
		  UNION ALL     
			 SELECT @Dok,'','','Mung. dok. fature','',@TableName,0,@ErrorOrd+'/04',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/04',
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Nr',
						 ErrorDok   = A.KMAG+', '+@TableName+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      CASE WHEN ISNULL(NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) Else '' END+
                                      ', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Mung. Dok.fature',
						 ErrorRef   = '',
						 TableName  = @TableName,
						 NRRENDOR   = A.NRRENDOR 
					FROM FD A Inner Join #MGTestFD A1 On A.NRRENDOR = A1.NRRENDOR
                   WHERE ISNULL(A.DOK_JB,0)=1 AND (NOT EXISTS (SELECT NRRENDOR FROM FJ C WHERE C.NRRENDDMG=A.NRRENDOR))
			 ) A

 -- B5.					 -- Mosperputhje Kod me KMag+KodAF ne rrjeshta
		  UNION ALL      
			 SELECT @Dok,'','','Test Kod - Mag.Art.Dep.List ','',@TableName,0,@ErrorOrd+'/05',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/05',
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Row',
						 ErrorDok   = A.KMAG+', '+@TableName+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      CASE WHEN ISNULL(NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) Else '' END+
                                      ', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Kod jo i sakte (Kod me Mag.Art.Dp.Ls.)',
						 ErrorRef   = 'kod:'+B.KOD+
                                      ' - duhet:'+A.KMAG+'.'+
                                                  dbo.Isd_SegmentFind(B.KODAF,0,1)+'.'+
                                                  dbo.Isd_SegmentFind(B.KODAF,0,2)+'.'+
                                                  dbo.Isd_SegmentFind(B.KODAF,0,3)+'.',
						 TableName  = @TableName,
						 A.NRRENDOR 
					FROM FD A Inner Join #MGTestFD A1 On A.NRRENDOR = A1.NRRENDOR
                              Left  Join FDSCR B      On A.NRRENDOR = B.NRD
                   WHERE ISNULL(B.KOD,'')<>A.KMAG+'.'+dbo.Isd_SegmentFind(B.KODAF,0,1)+'.'+
                                                      dbo.Isd_SegmentFind(B.KODAF,0,2)+'.'+
                                                      dbo.Isd_SegmentFind(B.KODAF,0,3)+'.'
				--GROUP BY A.NRRENDOR,B.NRRENDOR
				--Having ISNULL(COUNT(*),0)<=0 
			 ) A

        END;

-------------------------- A f i s h i m i ----------------

          IF OBJECT_ID('TempDB..#MGTestFH') IS NOT NULL
             DROP TABLE #MGTestFH; 
          IF OBJECT_ID('TempDB..#MGTestFD') IS NOT NULL
             DROP TABLE #MGTestFD;

          IF @TestTable<>''      -- Mbush nje tabele qe mund te afishohet me vone ....
             BEGIN
               SET  @sSql = '
           INSERT INTO '+@TestTable+'
                 (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
           SELECT ISNULL(Dok,''''),      ISNULL(Test,''''),     ISNULL(ErrorDok,''''),
                  ISNULL(ErrorMsg,''''), ISNULL(ErrorRef,''''), ISNULL(TableName,''''),
                  ISNULL(NrRendor,0),    ErrorOrder,            ErrorRowNr
             FROM #TestMGDok;

             DROP TABLE #TestMGDok; ';
               EXEC (@sSql);
             END
          else
             BEGIN
               SELECT * FROM #TestMGDok ORDER BY ErrorOrder,ErrorRowNr,TableName;
             END;
GO
