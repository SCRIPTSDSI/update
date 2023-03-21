SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   procedure [dbo].[Isd_TestLibra]
(
  @PTNames   Varchar(1000),
  @TestTable Varchar(30)
)
AS

--        IF OBJECT_ID('TempDB..#TestDok') IS NOT NULL
--                   DROP TABLE #TestDok;
--    SELECT Dok      = REPLICATE('',20),  Test      = REPLICATE('',30),  ErrorDok   = REPLICATE('',100), ErrorMsg   = REPLICATE('',100),
--           ErrorRef = REPLICATE('',100), TableName = REPLICATE('',100), ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(0 AS BIGINT), NrRendor = 0
--      INTO #TestDok     
--     WHERE 1=2;
--      EXEC dbo.Isd_TestLibra 'LIB','#TestDok';

-- Test  1.    LM
-- Test  2.    LMG
-- Test  3.    LAR
-- Test  4.    LBA
-- Test  5.    LKL
-- Test  6.    LFU
-- Test  7.    LAQ


     DECLARE @ErrorOrd    Varchar(100),
             @TableName   Varchar(30),
             @Dok         Varchar(20),
             @sSql        Varchar(MAX);

         IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,LIB','')=''
             RETURN;

-- Inicializimi
       
          IF OBJECT_ID('TempDB..#TestLib') IS NOT NULL
             DROP TABLE #TestLib;

      SELECT Dok      = REPLICATE('',20),  Test      = REPLICATE('',30),  ErrorDok   = REPLICATE('',100), ErrorMsg   = REPLICATE('',100),
             ErrorRef = REPLICATE('',100), TableName = REPLICATE('',100), ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(0 AS BIGINT), NrRendor = 0
        INTO #TestLib
       WHERE 1=2;

         SET @ErrorOrd  = 'Lib';
         SET @Dok       = 'LIB'; 

	  INSERT INTO #TestLib
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	  SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
   UNION ALL
	  SELECT @Dok,'','','=====   LIBRA   =====','',@TableName,0,@ErrorOrd,-1
   UNION ALL
	  SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1;
         


-- T1 ----------------------       L M       -------------------------
         SET  @TableName = 'LM';
         SET  @ErrorOrd  = 'Lib 01'+LEFT(@TableName,3)+' '; 
         
      INSERT  INTO #TestLib  
		    ( Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT  @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0

   UNION ALL
      SELECT  @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

        FROM
	  (SELECT Test       = @TableName,
			  ErrorDok,    
			  ErrorMsg   = 'Kod perseritur',
              ErrorRef,
              ErrorOrder = @ErrorOrd + '/1', 
              ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			  TableName  = @TableName,
			  NrRendor   = CAST(A1.NrRendor AS INT)
		 FROM 
			  ( SELECT ErrorDok  = MAX(LEFT(ISNULL(A.KOD,'')+' / '+ISNULL(A.PERSHKRIM,''),100)),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM LM A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
                     ) A1

    UNION ALL
	   SELECT Test       = @TableName,
			  ErrorDok,    
			  ErrorMsg   = 'Ref gabuar',
              ErrorRef,
              ErrorOrder = @ErrorOrd+'/2', 
              ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			  TableName  = @TableName,
			  NrRendor   = A1.NrRendor
		 FROM 
			  ( SELECT ErrorDok  = LEFT(ISNULL(A.KOD,'')+' / '+ISNULL(A.PERSHKRIM,''),100),
                       ErrorRef  = CASE WHEN ISNULL(A.SG1,'')<>'' AND (NOT EXISTS (SELECT KOD FROM LLOGARI     B WHERE B.KOD=A.SG1)) THEN 'Llg: '+ISNULL(A.SG1,'')
                                        WHEN ISNULL(A.SG2,'')<>'' AND (NOT EXISTS (SELECT KOD FROM DEPARTAMENT B WHERE B.KOD=A.SG2)) THEN 'Dep: '+ISNULL(A.SG2,'')
                                        WHEN ISNULL(A.SG3,'')<>'' AND (NOT EXISTS (SELECT KOD FROM LISTE       B WHERE B.KOD=A.SG3)) THEN 'Lis: '+ISNULL(A.SG3,'')
                                        WHEN ISNULL(A.SG4,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MAGAZINA    B WHERE B.KOD=A.SG4)) THEN 'Mag: '+ISNULL(A.SG4,'')
                                        WHEN ISNULL(A.SG5,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MONEDHA     B WHERE B.KOD=A.SG5)) THEN 'Mon: '+ISNULL(A.SG5,'')
                                   END,
					   NrRendor  = A.NRRENDOR
				  FROM LM A
                 WHERE (ISNULL(A.SG1,'')<>'' AND (NOT EXISTS (SELECT KOD FROM LLOGARI     B WHERE B.KOD=A.SG1))) OR
                       (ISNULL(A.SG2,'')<>'' AND (NOT EXISTS (SELECT KOD FROM DEPARTAMENT B WHERE B.KOD=A.SG2))) OR
                       (ISNULL(A.SG3,'')<>'' AND (NOT EXISTS (SELECT KOD FROM LISTE       B WHERE B.KOD=A.SG3))) OR
                       (ISNULL(A.SG4,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MAGAZINA    B WHERE B.KOD=A.SG4))) OR
                       (ISNULL(A.SG5,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MONEDHA     B WHERE B.KOD=A.SG5)))
              ) A1
       ) B ;


-- T2 ----------------------      L M G      -------------------------
         SET  @TableName = 'LMG';
         SET  @ErrorOrd  = 'Lib 02'+LEFT(@TableName,3)+' ';

      INSERT  INTO #TestLib  
		     (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT  @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0

   UNION ALL
      SELECT  @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  (SELECT Test       = @TableName,
			  ErrorDok,    
			  ErrorMsg   = 'Kod perseritur',
              ErrorRef,
              ErrorOrder = @ErrorOrd + '/1', 
              ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			  TableName  = @TableName,
			  NrRendor   = CAST(A1.NrRendor AS INT)
		 FROM 
			  ( SELECT ErrorDok  = MAX(LEFT(ISNULL(A.KOD,'')+' / '+ISNULL(A.PERSHKRIM,''),100)),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM LMG A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
                     ) A1

    UNION ALL
	   SELECT Test       = @TableName,
			  ErrorDok,    
			  ErrorMsg   = 'Ref gabuar',
              ErrorRef,
              ErrorOrder = @ErrorOrd+'/2', 
              ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			  TableName  = @TableName,
			  NrRendor   = A1.NrRendor
		 FROM 
			  ( SELECT ErrorDok  = LEFT(ISNULL(A.KOD,'')+' / '+ISNULL(A.PERSHKRIM,''),100),
                       ErrorRef  = CASE WHEN ISNULL(A.SG1,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MAGAZINA    B WHERE B.KOD=A.SG1)) THEN 'Mag: '+ISNULL(A.SG1,'')
                                        WHEN ISNULL(A.SG2,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ARTIKUJ     B WHERE B.KOD=A.SG2)) THEN 'Art: '+ISNULL(A.SG2,'')
                                        WHEN ISNULL(A.SG3,'')<>'' AND (NOT EXISTS (SELECT KOD FROM DEPARTAMENT B WHERE B.KOD=A.SG3)) THEN 'Dep: '+ISNULL(A.SG3,'')
                                        WHEN ISNULL(A.SG4,'')<>'' AND (NOT EXISTS (SELECT KOD FROM LISTE       B WHERE B.KOD=A.SG4)) THEN 'Lis: '+ISNULL(A.SG4,'')
                                   END,
					   NrRendor  = A.NRRENDOR
				  FROM LMG A
                 WHERE (ISNULL(A.SG1,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MAGAZINA    B WHERE B.KOD=A.SG1))) OR
                       (ISNULL(A.SG2,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ARTIKUJ     B WHERE B.KOD=A.SG2))) OR
                       (ISNULL(A.SG3,'')<>'' AND (NOT EXISTS (SELECT KOD FROM DEPARTAMENT B WHERE B.KOD=A.SG3))) OR
                       (ISNULL(A.SG4,'')<>'' AND (NOT EXISTS (SELECT KOD FROM LISTE       B WHERE B.KOD=A.SG4)))
              ) A1

       ) B ;


-- T3 ----------------------      L A R      -------------------------
         SET  @TableName = 'LAR';
         SET  @ErrorOrd  = 'Lib 03'+LEFT(@TableName,3)+' ';

      INSERT  INTO #TestLib  
		     (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT  @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0

   UNION ALL
      SELECT  @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

        FROM
	  (SELECT Test       = @TableName,
			  ErrorDok,    
			  ErrorMsg   = 'Kod perseritur',
              ErrorRef,
              ErrorOrder = @ErrorOrd + '/1', 
              ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			  TableName  = @TableName,
			  NrRendor   = CAST(A1.NrRendor AS INT)
		 FROM 
			  ( SELECT ErrorDok  = MAX(LEFT(ISNULL(A.KOD,'')+' / '+ISNULL(A.PERSHKRIM,''),100)),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM LAR A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

    UNION ALL
	   SELECT Test       = @TableName,
			  ErrorDok,    
			  ErrorMsg   = 'Ref gabuar',
              ErrorRef,
              ErrorOrder = @ErrorOrd+'/2', 
              ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			  TableName  = @TableName,
			  NrRendor   = A1.NrRendor
		 FROM 
			  ( SELECT ErrorDok  = LEFT(ISNULL(A.KOD,'')+' / '+ISNULL(A.PERSHKRIM,''),100),
                       ErrorRef  = CASE WHEN ISNULL(A.SG1,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ARKAT   B WHERE B.KOD=A.SG1)) THEN 'Ark: '+ISNULL(A.SG1,'')
                                        WHEN ISNULL(A.SG2,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MONEDHA B WHERE B.KOD=A.SG2)) THEN 'Mon: '+ISNULL(A.SG2,'')
                                   END,
					   NrRendor  = A.NRRENDOR
				  FROM LAR A
                 WHERE (ISNULL(A.SG1,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ARKAT   B WHERE B.KOD=A.SG1))) OR
                       (ISNULL(A.SG2,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MONEDHA B WHERE B.KOD=A.SG2))) 
              ) A1
       ) B ;


-- T4 ----------------------      L B A      -------------------------
         SET  @TableName = 'LBA';
         SET  @ErrorOrd  = 'Lib 04'+LEFT(@TableName,3)+' ';

      INSERT  INTO #TestLib  
		     (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT  @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0

   UNION ALL
      SELECT  @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  (SELECT Test       = @TableName,
			  ErrorDok,    
			  ErrorMsg   = 'Kod perseritur',
              ErrorRef,
              ErrorOrder = @ErrorOrd + '/1', 
              ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			  TableName  = @TableName,
			  NrRendor   = CAST(A1.NrRendor AS INT)
		 FROM 
			  ( SELECT ErrorDok  = MAX(LEFT(ISNULL(A.KOD,'')+' / '+ISNULL(A.PERSHKRIM,''),100)),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM LBA A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

  UNION ALL
	   SELECT Test       = @TableName,
			  ErrorDok,    
			  ErrorMsg   = 'Ref gabuar',
              ErrorRef,
              ErrorOrder = @ErrorOrd+'/2', 
              ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			  TableName  = @TableName,
			  NrRendor   = A1.NrRendor
		 FROM 
			  ( SELECT ErrorDok  = LEFT(ISNULL(A.KOD,'')+' / '+ISNULL(A.PERSHKRIM,''),100),
                       ErrorRef  = CASE WHEN ISNULL(A.SG1,'')<>'' AND (NOT EXISTS (SELECT KOD FROM BANKAT  B WHERE B.KOD=A.SG1)) THEN 'Ban: '+ISNULL(A.SG1,'')
                                        WHEN ISNULL(A.SG2,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MONEDHA B WHERE B.KOD=A.SG2)) THEN 'Mon: '+ISNULL(A.SG2,'')
                                   END,
					   NrRendor  = A.NRRENDOR
				  FROM LBA A
                 WHERE (ISNULL(A.SG1,'')<>'' AND (NOT EXISTS (SELECT KOD FROM BANKAT  B WHERE B.KOD=A.SG1))) OR
                       (ISNULL(A.SG2,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MONEDHA B WHERE B.KOD=A.SG2))) 
              ) A1
       ) B ;



-- T5 ----------------------      L K L      -------------------------
         SET  @TableName = 'LKL';
         SET  @ErrorOrd  = 'Lib 05'+LEFT(@TableName,3)+' ';

      INSERT  INTO #TestLib  
		     (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT  @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0

   UNION ALL
      SELECT  @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

        FROM
	  (SELECT Test       = @TableName,
			  ErrorDok,    
			  ErrorMsg   = 'Kod perseritur',
              ErrorRef,
              ErrorOrder = @ErrorOrd + '/1', 
              ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			  TableName  = @TableName,
			  NrRendor   = CAST(A1.NrRendor AS INT)
		 FROM 
			  ( SELECT ErrorDok  = MAX(LEFT(ISNULL(A.KOD,'')+' / '+ISNULL(A.PERSHKRIM,''),100)),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM LKL A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

    UNION ALL
	   SELECT Test       = @TableName,
			  ErrorDok,    
			  ErrorMsg   = 'Ref gabuar',
              ErrorRef,
              ErrorOrder = @ErrorOrd+'/2', 
              ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			  TableName  = @TableName,
			  NrRendor   = A1.NrRendor
		 FROM 
			  ( SELECT ErrorDok  = LEFT(ISNULL(A.KOD,'')+' / '+ISNULL(A.PERSHKRIM,''),100),
                       ErrorRef  = CASE WHEN ISNULL(A.SG1,'')<>'' AND (NOT EXISTS (SELECT KOD FROM KLIENT  B WHERE B.KOD=A.SG1)) THEN 'Kli: '+ISNULL(A.SG1,'')
                                        WHEN ISNULL(A.SG2,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MONEDHA B WHERE B.KOD=A.SG2)) THEN 'Mon: '+ISNULL(A.SG2,'')
                                   END,
					   NrRendor  = A.NRRENDOR
				  FROM LKL A
                 WHERE (ISNULL(A.SG1,'')<>'' AND (NOT EXISTS (SELECT KOD FROM KLIENT  B WHERE B.KOD=A.SG1))) OR
                       (ISNULL(A.SG2,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MONEDHA B WHERE B.KOD=A.SG2))) 
              ) A1
       ) B ;


-- T6 ----------------------      L F U      -------------------------
         SET  @TableName = 'LFU';
         SET  @ErrorOrd  = 'Lib 06'+LEFT(@TableName,3)+' ';

      INSERT  INTO #TestLib  
		     (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
       SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0

    UNION ALL
       SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

         FROM
	  (SELECT Test       = @TableName,
			  ErrorDok,    
			  ErrorMsg   = 'Kod perseritur',
              ErrorRef,
              ErrorOrder = @ErrorOrd + '/1', 
              ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			  TableName  = @TableName,
			  NrRendor   = CAST(A1.NrRendor AS INT)
		 FROM 
			  ( SELECT ErrorDok  = MAX(LEFT(ISNULL(A.KOD,'')+' / '+ISNULL(A.PERSHKRIM,''),100)),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM LFU A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

    UNION ALL
	   SELECT Test       = @TableName,
			  ErrorDok,    
			  ErrorMsg   = 'Ref gabuar',
              ErrorRef,
              ErrorOrder = @ErrorOrd+'/2', 
              ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			  TableName  = @TableName,
			  NrRendor   = A1.NrRendor
		 FROM 
			  ( SELECT ErrorDok  = LEFT(ISNULL(A.KOD,'')+' / '+ISNULL(A.PERSHKRIM,''),100),
                       ErrorRef  = CASE WHEN ISNULL(A.SG1,'')<>'' AND (NOT EXISTS (SELECT KOD FROM FURNITOR B WHERE B.KOD=A.SG1)) THEN 'Fur: '+ISNULL(A.SG1,'')
                                        WHEN ISNULL(A.SG2,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MONEDHA  B WHERE B.KOD=A.SG2)) THEN 'Mon: '+ISNULL(A.SG2,'')
                                   END,
					   NrRendor  = A.NRRENDOR
				  FROM LFU A
                 WHERE (ISNULL(A.SG1,'')<>'' AND (NOT EXISTS (SELECT KOD FROM FURNITOR B WHERE B.KOD=A.SG1))) OR
                       (ISNULL(A.SG2,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MONEDHA  B WHERE B.KOD=A.SG2))) 
              ) A1
       ) B ;


-- T7 ----------------------       L A Q     -------------------------
         SET  @TableName = 'LAQ';
         SET  @ErrorOrd  = 'Lib 07'+LEFT(@TableName,3)+' '; 
         
      INSERT  INTO #TestLib  
		     (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT  @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0

   UNION ALL
      SELECT  @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

        FROM
	  (SELECT Test       = @TableName,
			  ErrorDok,    
			  ErrorMsg   = 'Kod perseritur',
              ErrorRef,
              ErrorOrder = @ErrorOrd + '/1', 
              ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			  TableName  = @TableName,
			  NrRendor   = CAST(A1.NrRendor AS INT)
		 FROM 
			  ( SELECT ErrorDok  = MAX(LEFT(ISNULL(A.KOD,'')+' / '+ISNULL(A.PERSHKRIM,''),100)),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM LAQ A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

    UNION ALL
	   SELECT Test       = @TableName,
			  ErrorDok,    
			  ErrorMsg   = 'Ref gabuar',
              ErrorRef,
              ErrorOrder = @ErrorOrd+'/2', 
              ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			  TableName  = @TableName,
			  NrRendor   = A1.NrRendor
		 FROM 
			  ( SELECT ErrorDok  = LEFT(ISNULL(A.KOD,'')+' / '+ISNULL(A.PERSHKRIM,''),100),
                       ErrorRef  = CASE WHEN ISNULL(A.SG1,'')<>'' AND (NOT EXISTS (SELECT KOD FROM AQKARTELA   B WHERE B.KOD=A.SG1)) THEN 'Akt: '+ISNULL(A.SG1,'')
                                        WHEN ISNULL(A.SG2,'')<>'' AND (NOT EXISTS (SELECT KOD FROM DEPARTAMENT B WHERE B.KOD=A.SG2)) THEN 'Dep: '+ISNULL(A.SG2,'')
                                        WHEN ISNULL(A.SG3,'')<>'' AND (NOT EXISTS (SELECT KOD FROM LISTE       B WHERE B.KOD=A.SG3)) THEN 'Lis: '+ISNULL(A.SG3,'')
                                        WHEN ISNULL(A.SG4,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MAGAZINA    B WHERE B.KOD=A.SG4)) THEN 'Mag: '+ISNULL(A.SG4,'')
                                        WHEN ISNULL(A.SG5,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MONEDHA     B WHERE B.KOD=A.SG5)) THEN 'Mon: '+ISNULL(A.SG5,'')
                                   END,
					   NrRendor  = A.NRRENDOR
				  FROM LAQ A
                 WHERE (ISNULL(A.SG1,'')<>'' AND (NOT EXISTS (SELECT KOD FROM AQKARTELA   B WHERE B.KOD=A.SG1))) OR
                       (ISNULL(A.SG2,'')<>'' AND (NOT EXISTS (SELECT KOD FROM DEPARTAMENT B WHERE B.KOD=A.SG2))) OR
                       (ISNULL(A.SG3,'')<>'' AND (NOT EXISTS (SELECT KOD FROM LISTE       B WHERE B.KOD=A.SG3))) OR
                       (ISNULL(A.SG4,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MAGAZINA    B WHERE B.KOD=A.SG4))) OR
                       (ISNULL(A.SG5,'')<>'' AND (NOT EXISTS (SELECT KOD FROM MONEDHA     B WHERE B.KOD=A.SG5)))
              ) A1
       ) B ;





-- -------------------------  A f i s h i m i -------------------------

     IF @TestTable<>''       -- Mbush nje tabele qe mund te afishohet me vone ....
        BEGIN
        
          SET   @sSql = '
            INSERT INTO '+@TestTable+'
                 (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
           SELECT ISNULL(Dok,''''),       ISNULL(Test,''''),     ISNULL(ErrorDok,''''),
                  ISNULL(ErrorMsg,''''),  ISNULL(ErrorRef,''''), ISNULL(TableName,''''),
                  ISNULL(NrRendor,0),     ErrorOrder,            ErrorRowNr
             FROM #TestLib

             DROP TABLE #TestLib;  -- SELECT * FROM '+@TestTable+' ORDER BY ErrorOrder,ErrorRowNr,TableName; ';
          EXEC (@sSql);
          
        END
        
     ELSE
        BEGIN
        
          SELECT * FROM #TestLib ORDER BY ErrorOrder,ErrorRowNr,TableName;
          
        END;
GO
