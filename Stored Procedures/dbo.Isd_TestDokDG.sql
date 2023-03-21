SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   procedure [dbo].[Isd_TestDokDG]
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
--      EXEC dbo.Isd_TestDokMG '01/01/2010','31/12/2012','DG',0.01,'#TestDok';

    DECLARE @DateKp      DateTime,
            @DateKs      DateTime,
            @TestTable   Varchar(30),
            @ErrorOrd    Varchar(100),
            @TableName   Varchar(30),
            @Dok         Varchar(20),
            @sSql        Varchar(MAX);

        SET @DateKp    = dbo.DateValue(@pDateKp);
        SET @DateKs    = dbo.DateValue(@pDateKs);
        SET @TestTable = @pTestTable;

        IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,BL,DG','')=''
            RETURN;

-- Inicializimi
          IF OBJECT_ID('TempDB..#TestFtDG') IS NOT NULL
             DROP TABLE #TestFtDG; 
          IF OBJECT_ID('TempDB..#TestDG')   IS NOT NULL
             DROP TABLE #TestDG;

     SELECT Dok      = REPLICATE('',20),  Test      = REPLICATE('',30),  ErrorDok   = REPLICATE('',100), ErrorMsg   = REPLICATE('',100),
            ErrorRef = REPLICATE('',100), TableName = REPLICATE('',100), ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(0 AS BIGINT), NrRendor = 0
       INTO #TestFtDG    
      WHERE 1=2;

-- T1 ----------------------        DG        -------------------------

      SELECT NRRENDOR
        INTO #TestDG
        FROM DG
       WHERE DateDok>=@DateKp AND DateDok<=@DateKs;

         SET @TableName = 'DG';
		 SET @ErrorOrd  = 'Dok '+@TableName+' ';
         SET @Dok       = 'DOK';

      INSERT INTO #TestFtDG
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	  SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
   UNION ALL		           
	  SELECT @Dok,'','','=====    '+@TableName+'    =====','',@TableName,0,@ErrorOrd,-1
   UNION ALL
	  SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1


-- A1.					 -- Referenca te panjohura KMon,Kod Klient/Furnitor, Tatim, Artikuj, Aktive ne Scr etj.
		  UNION ALL      
			 SELECT @Dok,'','','Referenca panjohura','',@TableName,0,@ErrorOrd+'/01',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

			   FROM
			  (   SELECT Test       = @TableName+'->Ref',
						 ErrorDok   = @TableName+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      ', '  +CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Ref panjohur /Dok',
						 ErrorRef   = CASE WHEN (ISNULL(A.KMONDG,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MONEDHA  B WHERE B.KOD=A.KMONDG))) THEN 'Mon : '   +ISNULL(A.KMONDG,'')
                                           WHEN (ISNULL(A.TIPFT,'')='F'  AND (NOT EXISTS (SELECT KOD FROM FURNITOR B WHERE B.KOD=A.KOD)))    THEN 'Furn: '   +ISNULL(A.KOD,'')
                                           WHEN (ISNULL(A.TIPFT,'')='S'  AND (NOT EXISTS (SELECT KOD FROM KLIENT   B WHERE B.KOD=A.KOD)))    THEN 'Kli : '   +ISNULL(A.KOD,'')
									  END, 
						 ErrorOrder = @ErrorOrd+'/01 1',
                         ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
						 TableName  = @TableName,
						 A.NRRENDOR  
					FROM DG A Inner Join #TestDG A1 On A.NRRENDOR = A1.NRRENDOR
				   WHERE (ISNULL(A.KMONDG,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MONEDHA  B WHERE B.KOD=A.KMONDG))) Or
                         (ISNULL(A.TIPFT,'')='F'  AND (NOT EXISTS (SELECT KOD FROM FURNITOR B WHERE B.KOD=A.KOD)))    Or
						 (ISNULL(A.TIPFT,'')='S'  AND (NOT EXISTS (SELECT KOD FROM KLIENT   B WHERE B.KOD=A.KOD)))

			   UNION ALL 

				  SELECT Test       = @TableName+'->Ref',
						 ErrorDok   = @TableName+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      ', '  +CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Ref panjohur /Scr',
						 ErrorRef   = CASE WHEN  ISNULL(B.TATIM,'')='' Or 
                                                (NOT EXISTS (SELECT KOD FROM TATIM     C WHERE C.KOD=B.TATIM))   THEN 'Tat: '  +ISNULL(B.TATIM,'')
                                           WHEN  ISNULL(B.KARTLLG,'')<>'' AND B.TIPKLL='K' AND
                                                (NOT EXISTS (SELECT KOD FROM ARTIKUJ   C WHERE C.KOD=B.KARTLLG)) THEN 'Art: '  +B.KARTLLG+'/'+B.TIPKLL
                                           WHEN  ISNULL(B.KARTLLG,'')<>'' AND B.TIPKLL='L' AND 
                                                (NOT EXISTS (SELECT KOD FROM LLOGARI   C WHERE C.KOD=B.KARTLLG)) THEN 'Llog: ' +B.KARTLLG+'/'+B.TIPKLL
                                           WHEN  ISNULL(B.KARTLLG,'')<>'' AND B.TIPKLL='X' AND 
                                                (NOT EXISTS (SELECT KOD FROM AQKARTELA C WHERE C.KOD=B.KARTLLG)) THEN 'Akt: '  +B.KARTLLG+'/'+B.TIPKLL
                                           WHEN  ISNULL(B.NJESI,'')<>'' AND 
                                                (NOT EXISTS (SELECT KOD FROM NJESI     C WHERE C.KOD=B.NJESI))   THEN 'Njesi: '+B.NJESI
                                      END,
						 ErrorOrder = @ErrorOrd+'/01 2',
                         ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
						 TableName  = @TableName,
						 A.NRRENDOR  
					FROM DG A Inner Join #TestDG A1 On A.NRRENDOR = A1.NRRENDOR
							  Inner Join DGSCR B    On A.NrRendor = B.NrD
				   WHERE  ISNULL(B.TATIM,'')='' Or 
                         (NOT EXISTS (SELECT KOD FROM TATIM C WHERE C.KOD=B.TATIM)) Or
                         (ISNULL(B.KARTLLG,'')<>'' AND B.TIPKLL='K' AND (NOT EXISTS (SELECT KOD FROM ARTIKUJ   C WHERE C.KOD=B.KARTLLG))) Or
                         (ISNULL(B.KARTLLG,'')<>'' AND B.TIPKLL='L' AND (NOT EXISTS (SELECT KOD FROM LLOGARI   C WHERE C.KOD=B.KARTLLG))) Or
                         (ISNULL(B.KARTLLG,'')<>'' AND B.TIPKLL='X' AND (NOT EXISTS (SELECT KOD FROM AQKARTELA C WHERE C.KOD=B.KARTLLG))) Or
                         (ISNULL(B.NJESI,'')<>''   AND (NOT EXISTS (SELECT KOD FROM NJESI   C WHERE C.KOD=B.NJESI)))
			  ) A

-- A2.					 -- Dokumenta me Nr te perseritur
		  UNION ALL     
			 SELECT @Dok,'','','Nr. perseritur','',@TableName,0,@ErrorOrd+'/02',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/02',
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Nr',
						 ErrorDok   = MAX(@TableName+
                                          ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                          ', '  +CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Dok. perseritur',
						 ErrorRef   = @TableName+' nr '+
                                      CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
									  CONVERT(nVarchar(10),YEAR(DATEDOK))+' - '+
									  CAST(COUNT(*) AS Varchar)+' here',
						 TableName  = @TableName,
						 NRRENDOR   = MIN(A.NRRENDOR ) 

					FROM DG A Inner Join #TestDG A1 On A.NRRENDOR = A1.NRRENDOR
				GROUP BY YEAR(DATEDOK),NRDOK 
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
						 ErrorDok   = MAX(@TableName+
                                         ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                         ', '  +CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Dok. pa rrjeshta',
						 ErrorRef   = '',
						 TableName  = @TableName,
						 A.NRRENDOR 
					FROM DG A Inner Join #TestDG A1 On A.NRRENDOR = A1.NRRENDOR
                              Left  Join DGSCR B    On A.NRRENDOR = B.NRD
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
						 ErrorDok   = @TableName+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      ', '  +CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Mung. Dok.fature',
						 ErrorRef   = CASE WHEN A.TIPFT='F' THEN 'Fat. Blerje'
                                           WHEN A.TIPFT='S' THEN 'Fat. Shitje'
                                      END,
						 TableName  = @TableName,
						 NRRENDOR   = A.NRRENDOR 

					FROM DG A Inner Join #TestDG A1 On A.NRRENDOR = A1.NRRENDOR
                   WHERE ISNULL(A.NRRENDORFAT,0)<>0 AND
                        ((A.TIPFT='F' AND (NOT EXISTS (SELECT NRRENDOR FROM FF C WHERE C.NRRENDOR=A.NRRENDORFAT))) Or
                         (A.TIPFT='S' AND (NOT EXISTS (SELECT NRRENDOR FROM FJ C WHERE C.NRRENDOR=A.NRRENDORFAT))))
			  ) A;


-------------------------- A f i s h i m i ----------------

          IF OBJECT_ID('TempDB..#TestDG') IS NOT NULL
             DROP TABLE #TestDG;

          IF @TestTable<>''      -- Mbush nje tabele qe mund te afishohet me vone ....
             BEGIN
               SET @sSql = '
              INSERT INTO '+@TestTable+'
                    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
              SELECT ISNULL(Dok,''''),      ISNULL(Test,''''),     ISNULL(ErrorDok,''''),
                     ISNULL(ErrorMsg,''''), ISNULL(ErrorRef,''''), ISNULL(TableName,''''),
                     ISNULL(NrRendor,0),    ErrorOrder,            ErrorRowNr
                FROM #TestFtDG;

             DROP TABLE #TestFtDG; ';
               EXEC (@sSql);
             END  
         else
            BEGIN
              SELECT * FROM #TestFtDG ORDER BY ErrorOrder,ErrorRowNr,TableName;
            END;
GO
