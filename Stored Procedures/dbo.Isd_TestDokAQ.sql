SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   procedure [dbo].[Isd_TestDokAQ]
(
  @pDateKp          Varchar(20),
  @pDateKs          Varchar(20),
  @pTestTip         Varchar(1000),
  @pTestVlere       Float,
  @pTestTableName   Varchar(30)
)
AS

--        IF OBJECT_ID('TempDB..#TestDok') IS NOT NULL
--           DROP TABLE #TestDok;
--    SELECT Dok      = REPLICATE('',20),  Test      = REPLICATE('',30),  ErrorDok   = REPLICATE('',100), ErrorMsg   = REPLICATE('',100),
--           ErrorRef = REPLICATE('',100), TableName = REPLICATE('',100), ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(0 AS BIGINT), NrRendor = 0
--      INTO #TestDok     
--     WHERE 1=2;
--      EXEC dbo.Isd_TestDokAQ '01/01/2010','31/12/2012','AQ',0.01,'#TestDok';

-- Test 1.     Test AQ


     DECLARE @DateKp      DateTime,
             @DateKs      DateTime,
             @ErrorOrd    Varchar(100),
             @ErrorMsg    Varchar(100),
             @TableName   Varchar(30),
             @Dok         Varchar(20),
             @sSql        Varchar(MAX);

         SET @DateKp    = dbo.DateValue(@pDateKp);
         SET @DateKs    = dbo.DateValue(@pDateKs);

         IF  dbo.Isd_ListFields2Lists(@pTestTip,'ALL,AQ','')=''
             RETURN;


-- Inicializimi

         IF  OBJECT_ID('TempDB..#TestAQDok') IS NOT NULL
             DROP TABLE #TestAQDok; 

         IF  OBJECT_ID('TempDB..#TestAQ') IS NOT NULL
             DROP TABLE #TestAQ;

      SELECT Dok      = REPLICATE('',20),  Test      = REPLICATE('',30), ErrorDok   = REPLICATE('',100), ErrorMsg   = REPLICATE('',100),
             ErrorRef = REPLICATE('',100), TableName = REPLICATE('',100),ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(0 AS BIGINT), NrRendor = 0
        INTO #TestAQDok    
       WHERE 1=2;


-- -------------------------        A Q       -------------------------

      SELECT NRRENDOR
        INTO #TestAQ
        FROM AQ
       WHERE DateDok>=@DateKp AND DateDok<=@DateKs;

         SET @TableName = 'AQ';
		 SET @ErrorOrd  = 'Dok '+@TableName+' ';
         SET @Dok       = 'DOK';

    IF  dbo.Isd_ListFields2Lists(@pTestTip,'ALL,LM,'+@TableName,'')<>''
        BEGIN

			 INSERT INTO #TestAQDok
				   (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
          UNION ALL		           
			 SELECT @Dok,'','','=====    '+@TableName+'    =====','',@TableName,0,@ErrorOrd,-1
          UNION ALL
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1

-- A1.					 -- Referenca te panjohura Kartele aktivi,Departament,List,Magazine,Monedhe ne Scr etj.
		  UNION ALL      
			 SELECT @Dok,'','','Referenca panjohura','',@TableName,0,@ErrorOrd+'/01',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

			   FROM
			  (   SELECT Test       = @TableName+'->Ref',
						 ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Kart panjohur',
						 ErrorRef   = 'Kart: '+B.KARTLLG,
						 ErrorOrder = @ErrorOrd+'/01 1',
                         ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
						 TableName  = @TableName,
						 A.NRRENDOR  
					FROM AQ A INNER JOIN #TestAQ A1  ON A.NRRENDOR = A1.NRRENDOR
							  INNER JOIN AQSCR   B   ON A.NrRendor = B.NrD
				   WHERE NOT EXISTS (SELECT KOD FROM AQKARTELA C WHERE C.KOD=B.KARTLLG)
            -- 
               UNION ALL 
                  SELECT Test       = @TableName+'->Ref',
			             ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			             ErrorMsg   = 'Dep panjohur /01 2',
			             ErrorRef   = B.KODAF+' / Dep: '+dbo.Isd_SegmentFind(B.KODAF,0,2),
                         ErrorOrder = @ErrorOrd+'/01 2',
                         ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			             TableName  = @TableName,
                         A.NRRENDOR  
		            FROM AQ A INNER JOIN #TestAQ A1 ON A.NRRENDOR = A1.NRRENDOR
                              INNER JOIN AQSCR   B  ON A.NrRendor = B.NrD
                   WHERE dbo.Isd_SegmentFind(B.KODAF,0,2)<>'' AND (NOT EXISTS (SELECT KOD FROM DEPARTAMENT  C WHERE C.KOD=dbo.Isd_SegmentFind(B.KODAF,0,2)))

            -- 
               UNION ALL 
                  SELECT Test       = @TableName+'->Ref',
			             ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			             ErrorMsg   = 'List panjohur /01 3',
			             ErrorRef   = B.KODAF+' / List: '+dbo.Isd_SegmentFind(B.KODAF,0,3),
                         ErrorOrder = @ErrorOrd+'/01 3',
                         ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			             TableName  = @TableName,
                         A.NRRENDOR  
		            FROM AQ A INNER JOIN #TestAQ A1 ON A.NRRENDOR = A1.NRRENDOR
                              INNER JOIN AQSCR   B  ON A.NrRendor = B.NrD
                   WHERE dbo.Isd_SegmentFind(B.KODAF,0,3)<>'' AND (NOT EXISTS (SELECT KOD FROM LISTE C WHERE C.KOD=dbo.Isd_SegmentFind(B.KODAF,0,3)))

            -- 
               UNION ALL 
                  SELECT Test       = @TableName+'->Ref',
			             ErrorDok   = @TableName+' '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
			             ErrorMsg   = 'Mag panjohur /01 4',
			             ErrorRef   = B.KODAF+' / Mag: '+dbo.Isd_SegmentFind(B.KODAF,0,4),
                         ErrorOrder = @ErrorOrd+'/01 4',
                         ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A.NrRendor ASC),
			             TableName  = @TableName,
                         A.NRRENDOR  
		            FROM AQ A INNER JOIN #TestAQ A1 ON A.NRRENDOR = A1.NRRENDOR
                              INNER JOIN AQSCR   B  ON A.NrRendor = B.NrD
                   WHERE dbo.Isd_SegmentFind(B.KODAF,0,4)<>'' AND (NOT EXISTS (SELECT KOD FROM MAGAZINA  C WHERE C.KOD=dbo.Isd_SegmentFind(B.KODAF,0,4)))
                   
			  ) A



-- A3.					 -- Dokumenta me Nr te perseritur
		  UNION ALL     
			 SELECT @Dok,'','','Nr. perseritur','',@TableName,0,@ErrorOrd+'/03',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/03',
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Nr',
						 ErrorDok   = MAX(@TableName+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      CASE WHEN ISNULL(A.NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) ELSE '' END+
                                      ', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Dok. perseritur',
						 ErrorRef   = @TableName+' nr '+
                                      CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      CASE WHEN ISNULL(A.NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) ELSE '' END+'/'+
									  CONVERT(nVarchar(10),YEAR(DATEDOK))+' - '+
									  CAST(COUNT(*) AS Varchar)+' here',
						 TableName  = @TableName,
						 NRRENDOR   = MIN(A.NRRENDOR ) 

					FROM AQ A INNER JOIN #TestAQ A1 ON A.NRRENDOR = A1.NRRENDOR
				GROUP BY YEAR(DATEDOK),NRDOK,NRFRAKS 
				  HAVING COUNT(*)>=2 
			  ) A

-- A4.					 -- Dokumenta pa rrjeshta
		  UNION ALL      
			 SELECT @Dok,'','','Dok. pa rreshta','',@TableName,0,@ErrorOrd+'/04',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/04',
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Row',
						 ErrorDok   = MAX(@TableName+
                                         ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                          CASE WHEN ISNULL(A.NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) ELSE '' END+
                                         ', '+CONVERT(Varchar,A.DateDok,4)),
						 ErrorMsg   = 'Dok. pa rrjeshta',
						 ErrorRef   = '',
						 TableName  = @TableName,
						 A.NRRENDOR 
					FROM AQ A INNER JOIN #TestAQ   A1 ON A.NRRENDOR = A1.NRRENDOR
                              LEFT  JOIN AQSCR B      ON A.NRRENDOR = B.NRD
				GROUP BY A.NRRENDOR
				  HAVING ISNULL(COUNT(*),0)<=0 
			 ) A
  
-- A5.					 -- Mungese Dokumenti fature
		  UNION ALL     
			 SELECT @Dok,'','','Mung. dok. fature','',@TableName,0,@ErrorOrd+'/05',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/05',
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Nr',
						 ErrorDok   = @TableName+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      CASE WHEN ISNULL(A.NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) ELSE '' END+
                                      ', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Mung. fature blerje',
						 ErrorRef   = '',
						 TableName  = @TableName,
						 NRRENDOR   = A.NRRENDOR 
					FROM AQ A INNER JOIN #TestAQ A1 ON A.NRRENDOR = A1.NRRENDOR
					          LEFT  JOIN FF      F  ON A.NRRENDORFAT=F.NRRENDOR
                   WHERE ISNULL(A.DOK_JB,0)=1 AND ISNULL(A.TIPFAT,'')='F' AND ISNULL(F.NRRENDOR,0)=0

               UNION ALL 
                  SELECT Test       = @TableName+'->Nr',
						 ErrorDok   = @TableName+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      CASE WHEN ISNULL(A.NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) ELSE '' END+
                                      ', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Mung. fature shitje',
						 ErrorRef   = '',
						 TableName  = @TableName,
						 NRRENDOR   = A.NRRENDOR 
					FROM AQ A INNER JOIN #TestAQ A1 ON A.NRRENDOR = A1.NRRENDOR
					          LEFT  JOIN FJ      F  ON A.NRRENDORFAT=F.NRRENDOR
                   WHERE ISNULL(A.DOK_JB,0)=1 AND ISNULL(A.TIPFAT,'')='S' AND ISNULL(F.NRRENDOR,0)=0
                          
			  ) A

 -- A6.					 -- Mosperputhje Kod me Kod me KodAF ne rrjeshta
		  UNION ALL      
			 SELECT @Dok,'','','Test Kod - Kart.Dep.List.Mg.Mon','',@TableName,0,@ErrorOrd+'/06',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,@ErrorOrd+'/06',
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)

			   FROM
			  (   SELECT Test       = @TableName+'->Row',
						 ErrorDok   = @TableName+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                      CASE WHEN ISNULL(NRFRAKS,0)<>0 THEN '.'+CAST(A.NrFraks AS Varchar) ELSE '' END+
                                      ', '+CONVERT(Varchar,A.DateDok,4),
						 ErrorMsg   = 'Kod jo i sakte (Kod me Kart.Dp.Ls.Mg.Mon)',
						 ErrorRef   = 'kod:'+ISNULL(B.KOD,'')+
                                      ' - duhet:'+dbo.Isd_SegmentFind(B.KODAF,0,1)+'.'+dbo.Isd_SegmentFind(B.KODAF,0,2)+'.'+
                                                  dbo.Isd_SegmentFind(B.KODAF,0,3)+'.'+dbo.Isd_SegmentFind(B.KODAF,0,4)+'.'+ISNULL(B.KMON,''),
						 TableName  = @TableName,
						 A.NRRENDOR 
					FROM AQ A INNER JOIN #TestAQ  A1 ON A.NRRENDOR = A1.NRRENDOR
                              LEFT  JOIN AQSCR    B  ON A.NRRENDOR = B.NRD
                   WHERE ISNULL(B.KOD,'')<>dbo.Isd_SegmentFind(B.KODAF,0,1)+'.'+dbo.Isd_SegmentFind(B.KODAF,0,2)+'.'+
                                           dbo.Isd_SegmentFind(B.KODAF,0,3)+'.'+dbo.Isd_SegmentFind(B.KODAF,0,4)+'.'+ISNULL(B.KMON,'')
                                           
			 ) A

        END;



-------------------------- A f i s h i m i ----------------

          IF OBJECT_ID('TempDB..#TestAQ') IS NOT NULL
             DROP TABLE #TestAQ; 


          IF @pTestTableName<>''      -- Mbush nje tabele qe mund te afishohet me vone ....
             BEGIN
             
               SET   @sSql = '
               
           INSERT INTO '+@pTestTableName+'
                 (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
           SELECT ISNULL(Dok,''''),      ISNULL(Test,''''),     ISNULL(ErrorDok,''''),
                  ISNULL(ErrorMsg,''''), ISNULL(ErrorRef,''''), ISNULL(TableName,''''),
                  ISNULL(NrRendor,0),    ErrorOrder,            ErrorRowNr
             FROM #TestAQDok;

             DROP TABLE #TestAQDok;      -- SELECT * FROM '+@pTestTableName+' ORDER BY ErrorOrder,ErrorRowNr,TableName; ';

               EXEC (@sSql);

             END 

          ELSE
          
             BEGIN
             
               SELECT * FROM #TestAQDok ORDER BY ErrorOrder,ErrorRowNr,TableName;
               
             END;
GO
