SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE   procedure [dbo].[Isd_TestDokFk]
(
  @pDateKp      Varchar(20),
  @pDateKs      Varchar(20),
  @pTNames      Varchar(1000),
  @pTestVlere   Float,
  @pOperacion   Varchar(100),
  @pTestTable   Varchar(30)
)
AS

--    SELECT Dok      = REPLICATE('',20),  Test      = REPLICATE('',30), ErrorDok   = REPLICATE('',100), ErrorMsg   = REPLICATE('',100),
--           ErrorRef = REPLICATE('',100), TableName = REPLICATE('',100),ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(0 AS BIGINT), NrRendor = 0
--      INTO #TestDok     
--     WHERE 1=2;
--      EXEC dbo.Isd_TestDokFk '01/01/2010','31/12/2012','ALL',0.01,'','#TestDok'


-- T1.	Shumat e Vlerave te Dokumentit me ato te rrjeshtave
-- T2.  Referenca te panjohura Llogari.
-- T3.  Dokumenta pa rrjeshta
-- T4.	FK pa dokument origjine
-- T5.  Dokumenta pa kaluar ne LM, ose lidhje gabuar

          IF dbo.Isd_ListFields2Lists(@PTNames,'ALL,FK','')=''
             RETURN

     DECLARE @DateKp      DateTime,
             @DateKs      DateTime,
             @TestVlere   Float,
             @TestTable   Varchar(30),
             @Operacion   Varchar(100),
             @ErrorOrd    Varchar(100),
             @TableName   Varchar(30),
          -- @Operacion   Varchar(100),
             @Dok         Varchar(20),
             @sSql        Varchar(MAX);

-- Inicializimi
          IF OBJECT_ID('TempDB..#TestFkDok') IS NOT NULL
             DROP TABLE #TestFkDok; 
          IF OBJECT_ID('TempDB..#ARTestFk')  IS NOT NULL
             DROP TABLE #ARTestFk; 
          IF OBJECT_ID('TempDB..#BATestFk')  IS NOT NULL
             DROP TABLE #BATestFk; 
          IF OBJECT_ID('TempDB..#VSTestFk')  IS NOT NULL
             DROP TABLE #VSTestFk; 
          IF OBJECT_ID('TempDB..#FkTestFk')  IS NOT NULL
             DROP TABLE #FkTestFk; 
          IF OBJECT_ID('TempDB..#FJTestFk')  IS NOT NULL
             DROP TABLE #FJTestFk; 
          IF OBJECT_ID('TempDB..#FFTestFk')  IS NOT NULL
             DROP TABLE #FFTestFk; 
          IF OBJECT_ID('TempDB..#FHTestFk')  IS NOT NULL
             DROP TABLE #FHTestFk; 
          IF OBJECT_ID('TempDB..#FDTestFk')  IS NOT NULL
             DROP TABLE #FDTestFk; 
          IF OBJECT_ID('TempDB..#DGTestFk')  IS NOT NULL
             DROP TABLE #DGTestFk;
          IF OBJECT_ID('TempDB..#AQTestFk')  IS NOT NULL
             DROP TABLE #AQTestFk;

         SET @DateKp    = dbo.DateValue(@PDateKp);
         SET @DateKs    = dbo.DateValue(@PDateKs);
         SET @TestVlere = @pTestVlere;
         SET @TestTable = @pTestTable;
         SET @Operacion = @pOperacion;
          IF @TestVlere<=0
             SET @TestVlere = 0.01;

             SELECT Dok      = REPLICATE('',20),  Test      = REPLICATE('',30), ErrorDok   = REPLICATE('',100), ErrorMsg   = REPLICATE('',100),
                    ErrorRef = REPLICATE('',100), TableName = REPLICATE('',100),ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(0 AS BIGINT), NrRendor = 0
               INTO #TestFkDok    
              WHERE 1=2;

			 SELECT NRRENDOR,REFERDOK,          TIPDOK,     NRDOK=NUMDOK,DATEDOK,NRDFK=NRRENDOR,ORG
			   INTO #FkTestFk
			   FROM FK
			  WHERE DateDok>=@DateKp AND DateDok<=@DateKs;

			 SELECT NRRENDOR,REFERDOK=KODAB,    TIPDOK,     NRDOK=NUMDOK,DATEDOK,NRDFK,  ORG='A'
			   INTO #ARTestFk
			   FROM ARKA
			  WHERE DateDok>=@DateKp AND DateDok<=@DateKs;

			 SELECT NRRENDOR,REFERDOK=KODAB,    TIPDOK,     NRDOK=NUMDOK,DATEDOK,NRDFK,  ORG='B'
			   INTO #BATestFk
			   FROM BANKA
			  WHERE DateDok>=@DateKp AND DateDok<=@DateKs;

			 SELECT NRRENDOR,REFERDOK=SPACE(10),TIPDOK='VS',NRDOK,       DATEDOK,NRDFK,  ORG='E'
			   INTO #VSTestFk
			   FROM VS
			  WHERE DateDok>=@DateKp AND DateDok<=@DateKs;

			 SELECT NRRENDOR,REFERDOK=KODFKL,   TIPDOK='FJ',NRDOK,       DATEDOK,NRDFK,  ORG='S'
			   INTO #FJTestFk
			   FROM FJ
			  WHERE DateDok>=@DateKp AND DateDok<=@DateKs;

			 SELECT NRRENDOR,REFERDOK=KODFKL,   TIPDOK='FF',NRDOK,       DATEDOK,NRDFK,  ORG='F'
			   INTO #FFTestFk
			   FROM FF
			  WHERE DateDok>=@DateKp AND DateDok<=@DateKs;

			 SELECT NRRENDOR,REFERDOK=KOD,      TIPDOK='DG',NRDOK,       DATEDOK,NRDFK,  ORG='G'
			   INTO #DGTestFk
			   FROM DG
			  WHERE DateDok>=@DateKp AND DateDok<=@DateKs

			 SELECT NRRENDOR,REFERDOK=KMAG,     TIPDOK='AQ',NRDOK,       DATEDOK,NRDFK,  ORG='X'
			   INTO #AQTestFk
			   FROM AQ
			  WHERE DateDok>=@DateKp AND DateDok<=@DateKs;

			 SELECT NRRENDOR,REFERDOK=KMAG,     TIPDOK='FH',NRDOK,       DATEDOK,NRDFK,  ORG='H'
			   INTO #FHTestFk
			   FROM FH
			  WHERE DateDok>=@DateKp AND DateDok<=@DateKs;

			 SELECT NRRENDOR,REFERDOK=KMAG,     TIPDOK='FD',NRDOK,       DATEDOK,NRDFK,  ORG='D'
			   INTO #FDTestFk
			   FROM FD
			  WHERE DateDok>=@DateKp AND DateDok<=@DateKs;


                SET @TableName = 'FK';
				SET @ErrorOrd  = 'Dok '+@TableName+' ';
                SET @Dok       = 'DOK';
              --SET @Operacion = 'NRDNULL,NOTSCR,ORGFK,NOTDOC,FKDIF,NOTFK';   -- Fut Test

                SET @TableName = 'FK';
			 INSERT INTO #TestFkDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
          UNION ALL		           
			 SELECT @Dok,'','','=====    '+@TableName+'    =====','',@TableName,0,@ErrorOrd,-1
          UNION ALL
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1;


-- T1.					 -- Shumat e Vlerave Debi-Kredi te rrjeshtave

   IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,FK','')<>'' AND dbo.Isd_ListFields2Lists(@Operacion,'ALL,FKDIF','')<>''
       BEGIN
                SET @TableName = 'FK';
			 INSERT INTO #TestFkDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
			 SELECT @Dok,'','','Kuadrim rrjeshta','',@TableName,0,@ErrorOrd+'/01',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)
			   FROM
			  (	  SELECT Test       = @TableName+'->Detaj',
						 ErrorDok   = MAX(A.TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+
                                                   ', '  +CONVERT(Varchar,A.DateDok,4)+
                                                   CASE WHEN CHARINDEX(A.ORG,'ABHD')>0 THEN ' /'+A.REFERDOK ELSE '' END),
						 ErrorMsg   = 'Diference vlefta',
						 ErrorRef   = 'Shuma Db-Kr: '+CAST(SUM(B.DBKRMV) AS Varchar),
						 ErrorOrder = @ErrorOrd+'/01',
						 TableName  = @TableName,
						 A.NRRENDOR  
				    FROM FK A INNER JOIN #FkTestFk A1 ON A.NRRENDOR = A1.NRRENDOR
							  INNER JOIN FKSCR B      ON A.NRRENDOR = B.NRD 
			    GROUP BY A.NRRENDOR 
				  HAVING (ABS(SUM(B.DBKRMV))>=@TestVlere)
			  ) A
       END;


-- T2.                   -- Referenca te panjohura Llogari.
   IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,FK','')<>'' AND dbo.Isd_ListFields2Lists(@Operacion,'ALL,FKREF','')<>''
       BEGIN
                SET @TableName = 'FK';
			 INSERT INTO #TestFkDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
			 SELECT @Dok,'','','Referenca panjohura','',@TableName,0,@ErrorOrd+'/02',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)
			   FROM
			  (   SELECT Test       = @TableName+'->Ref',
						 ErrorDok   = A.TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+
                                               ', '  +CONVERT(Varchar,A.DateDok,4)+
                                               CASE WHEN CHARINDEX(A.ORG,'ABHD')>0 THEN ' /'+A.REFERDOK ELSE '' END,
						 ErrorMsg   = 'Reference panjohur',
						 ErrorRef   = +B.LLOGARIPK+' / Llogari ',
						 ErrorOrder = @ErrorOrd+'/02',
						 TableName  = @TableName,
						 A.NRRENDOR  
					FROM FK A INNER JOIN #FkTestFk A1 ON A.NRRENDOR = A1.NRRENDOR
							  INNER JOIN FKSCR B      ON A.NrRendor = B.NrD
				   WHERE (NOT EXISTS (SELECT KOD FROM LLOGARI  C WHERE C.KOD=B.LLOGARIPK))
			  ) A
       END;


-- T3.                   -- Dokumenta pa rrjeshta
   IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,FK','')<>'' AND dbo.Isd_ListFields2Lists(@Operacion,'ALL,NOTSCR','')<>''
       BEGIN
                SET @TableName = 'FK';
			 INSERT INTO #TestFkDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
			 SELECT @Dok,'','','Dok. pa rreshta','',@TableName,0,@ErrorOrd+'/04',0

		  UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)
			   FROM
			  (   SELECT Test       = @TableName+'->Row',
						 ErrorDok   = MAX(A.TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NumDok AS BIGINT))+
                                                   ', '  +CONVERT(Varchar,A.DateDok,4)+
                                                   CASE WHEN CHARINDEX(A.ORG,'ABHD')>0 THEN ' /'+A.REFERDOK ELSE '' END),
						 ErrorMsg   = 'Dok. pa rrjeshta',
						 ErrorRef   = '',
						 ErrorOrder = @ErrorOrd+'/04',
						 TableName  = @TableName,
						 A.NRRENDOR 
					FROM FK A INNER JOIN #FkTestFk A1 ON A.NRRENDOR = A1.NRRENDOR
                              LEFT  JOIN FKSCR B      ON A.NRRENDOR = B.NRD
				GROUP BY A.NRRENDOR
				  HAVING ISNULL(COUNT(*),0)<=0 
			  ) A
       END;


-- T4.					 -- FK pa dokument origjine
   IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,FK','')<>'' AND dbo.Isd_ListFields2Lists(@Operacion,'ALL,ORGFK,NOTDOC','')<>''
       BEGIN
                SET @TableName = 'FK';
			 INSERT INTO #TestFkDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
		  UNION ALL     
			 SELECT @Dok,'','','FK me dok. origjine gabim','',@TableName,0,@ErrorOrd+'/07',0

          UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)
               FROM
              (   SELECT Test       = @TableName+'->Row',
		  				 ErrorDok   = A.TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+
                                               ', '  +CONVERT(Varchar,A.DateDok,4)+
                                               CASE WHEN CHARINDEX(A.ORG,'ABHD')>0 THEN ' /'+A.REFERDOK ELSE '' END,
		 	             ErrorMsg   = 'Gabim dok.origjine',
			             ErrorRef   = 'Fk: Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
                         ErrorOrder = @ErrorOrd+'/07',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM #FkTestFk A 
                   WHERE CHARINDEX(ISNULL(A.ORG,''),'SFHDGABEX')=0
                         OR
                        (A.ORG='S' AND (NOT EXISTS (SELECT NRDFK 
                                                       FROM #FJTestFk C 
                                                      WHERE C.NRDFK=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))) 
                         OR
						(A.ORG='F' AND (NOT EXISTS (SELECT NRDFK 
                                                      FROM #FFTestFk C 
                                                     WHERE C.NRDFK=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))) 
                         OR
                        (A.ORG='H' AND (NOT EXISTS (SELECT NRDFK 
                                                      FROM #FHTestFk C 
                                                     WHERE C.NRDFK=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))) 
                         OR
                        (A.ORG='D' AND (NOT EXISTS (SELECT NRDFK 
                                                      FROM #FDTestFk C 
                                                     WHERE C.NRDFK=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))) 
                         OR
                        (A.ORG='G' AND (NOT EXISTS (SELECT NRDFK 
                                                      FROM #DGTestFk C 
                                                     WHERE C.NRDFK=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))) 
                         OR
                        (A.ORG='X' AND (NOT EXISTS (SELECT NRDFK 
                                                      FROM #AQTestFk C 
                                                     WHERE C.NRDFK=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))) 
                         OR
						(A.ORG='A' AND (NOT EXISTS (SELECT NRDFK 
                                                      FROM #ARTestFk C 
                                                     WHERE C.NRDFK=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))) 
                         OR
						(A.ORG='B' AND (NOT EXISTS (SELECT NRDFK 
                                                      FROM #BATestFk C 
                                                     WHERE C.NRDFK=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))) 
                         OR
                        (A.ORG='E' AND (NOT EXISTS (SELECT NRDFK 
                                                      FROM #VSTestFk C 
                                                     WHERE C.NRDFK=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK)))
              ) A
       END;

   

-- T5.                  Dokumenta pa kaluar ne LM, ose lidhje gabuar

   -- T5.1  FJ
   IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,FJ','')<>'' AND dbo.Isd_ListFields2Lists(@Operacion,'ALL,NOTFK','')<>''
       BEGIN
                SET @TableName = 'FJ';
			 INSERT INTO #TestFkDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
		  UNION ALL     
			 SELECT @Dok,'','','Dokument FK mungon/gabuar','',@TableName,0,@ErrorOrd+'/20',0

          UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)
               FROM
              (   SELECT Test       = @TableName+'->Fk',
		  				 ErrorDok   = A.TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NRDOK AS BIGINT))+
                                               ', '+CONVERT(Varchar,A.DateDok,4)+
                                               CASE WHEN CHARINDEX(A.ORG,'ABHD')>0 THEN ' /'+A.REFERDOK ELSE '' END,
		 	             ErrorMsg   = CASE WHEN ISNULL(A.NRDFK,0)=0 THEN 'Pa kaluar LM' ELSE 'Lidhje Fk gabim' END,
			             ErrorRef   = A.TIPDOK+': Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
                         ErrorOrder = @ErrorOrd+'/20',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM #FJTestFk A 
                   WHERE (ISNULL(A.NRDFK,0)=0) 
                          OR 
                         (NOT EXISTS (SELECT C.NRRENDOR 
                                        FROM #FkTestFk C
                                       WHERE C.NRDFk=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))
              ) A
       END;


   --  T5.2  FF
   IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,FF','')<>'' AND dbo.Isd_ListFields2Lists(@Operacion,'ALL,NOTFK','')<>''
       BEGIN
                SET @TableName = 'FF';
			 INSERT INTO #TestFkDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
		  UNION ALL     
			 SELECT @Dok,'','','Dokument FK mungon/gabuar','',@TableName,0,@ErrorOrd+'/21',0

          UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)
               FROM
              (   SELECT Test       = @TableName+'->Fk',
		  				 ErrorDok   = A.TIPDOK+
                                      ' nr '+CONVERT(nVarchar(20),CAST(A.NRDOK AS BIGINT))+
                                      ', '+CONVERT(Varchar,A.DateDok,4)+
                                      CASE WHEN CHARINDEX(A.ORG,'ABHD')>0 THEN ' /'+A.REFERDOK ELSE '' END,
		 	             ErrorMsg   = CASE WHEN ISNULL(A.NRDFK,0)=0 THEN 'Pa kaluar LM' ELSE 'Lidhje Fk gabim' END,
			             ErrorRef   = A.TIPDOK+': Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
                         ErrorOrder = @ErrorOrd+'/21',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM #FFTestFk A 
                   WHERE (ISNULL(A.NRDFK,0)=0) 
                          OR 
                         (NOT EXISTS (SELECT C.NRRENDOR 
                                         FROM #FkTestFk C
                                        WHERE C.NRDFk=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))
              ) A
       END;


   --  T5.3  DG
   IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,DG','')<>'' AND dbo.Isd_ListFields2Lists(@Operacion,'ALL,NOTFK','')<>''
       BEGIN
                SET @TableName = 'DG';
			 INSERT INTO #TestFkDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
		  UNION ALL     
			 SELECT @Dok,'','','Dokument FK mungon/gabuar','',@TableName,0,@ErrorOrd+'/22',0

          UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)
               FROM
              (   SELECT Test       = @TableName+'->Fk',
		  				 ErrorDok   = A.TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NRDOK AS BIGINT))+
                                               ', '+CONVERT(Varchar,A.DateDok,4)+
                                               CASE WHEN CHARINDEX(A.ORG,'ABHD')>0 THEN ' /'+A.REFERDOK ELSE '' END,
		 	             ErrorMsg   = CASE WHEN ISNULL(A.NRDFK,0)=0 THEN 'Pa kaluar LM' ELSE 'Lidhje Fk gabim' END,
			             ErrorRef   = A.TIPDOK+': Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
                         ErrorOrder = @ErrorOrd+'/22',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM #DGTestFk A 
                   WHERE (ISNULL(A.NRDFK,0)=0) 
                          OR 
                         (NOT EXISTS (SELECT C.NRRENDOR 
                                        FROM #FkTestFk C
                                       WHERE C.NRDFK=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))
              ) A
       END;

   --  T5.4  FH
   IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,FH','')<>'' AND dbo.Isd_ListFields2Lists(@Operacion,'ALL,NOTFK','')<>''
       BEGIN
                SET @TableName = 'FH';
			 INSERT INTO #TestFkDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
		  UNION ALL     
			 SELECT @Dok,'','','Dokument FK mungon/gabuar','',@TableName,0,@ErrorOrd+'/23',0

          UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)
               FROM
              (   SELECT Test       = @TableName+'->Fk',
		  				 ErrorDok   = A.TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NRDOK AS BIGINT))+
                                               ', '+CONVERT(Varchar,A.DateDok,4)+
                                               CASE WHEN CHARINDEX(A.ORG,'ABHD')>0 THEN ' /'+A.REFERDOK ELSE '' END,
		 	             ErrorMsg   = CASE WHEN ISNULL(A.NRDFK,0)=0 THEN 'Pa kaluar LM' ELSE 'Lidhje Fk gabim' END,
			             ErrorRef   = A.TIPDOK+': Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
                         ErrorOrder = @ErrorOrd+'/23',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM #FHTestFk A 
                   WHERE (ISNULL(A.NRDFK,0)=0) 
                          OR 
                         (NOT EXISTS (SELECT C.NRRENDOR 
                                        FROM #FkTestFk C
                                       WHERE C.NRDFK=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))
              ) A
       END;

   --  T5.5  FD
   IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,FD','')<>'' AND dbo.Isd_ListFields2Lists(@Operacion,'ALL,NOTFK','')<>''
       BEGIN
                SET @TableName = 'FD';
			 INSERT INTO #TestFkDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
		  UNION ALL     
			 SELECT @Dok,'','','Dokument FK mungon/gabuar','',@TableName,0,@ErrorOrd+'/24',0

          UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)
               FROM
              (   SELECT Test       = @TableName+'->Fk',
		  				 ErrorDok   = A.TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NRDOK AS BIGINT))+
                                               ', '+CONVERT(Varchar,A.DateDok,4)+
                                               CASE WHEN CHARINDEX(A.ORG,'ABHD')>0 THEN ' /'+A.REFERDOK ELSE '' END,
		 	             ErrorMsg   = CASE WHEN ISNULL(A.NRDFK,0)=0 THEN 'Pa kaluar LM' ELSE 'Lidhje Fk gabim' END,
			             ErrorRef   = A.TIPDOK+': Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
                         ErrorOrder = @ErrorOrd+'/24',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM #FDTestFk A 
                   WHERE (ISNULL(A.NRDFK,0)=0) 
                          OR 
                         (NOT EXISTS (SELECT C.NRRENDOR 
                                        FROM #FkTestFk C
                                       WHERE C.NRDFK=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))
              ) A
       END;


   --  T5.6  Arka
   IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,ARKA','')<>'' AND dbo.Isd_ListFields2Lists(@Operacion,'ALL,NOTFK','')<>''
       BEGIN
                SET @TableName = 'ARKA';
			 INSERT INTO #TestFkDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
		  UNION ALL     
			 SELECT @Dok,'','','Dokument FK mungon/gabuar','',@TableName,0,@ErrorOrd+'/25',0

          UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)
               FROM
              (   SELECT Test       = @TableName+'->Fk',
		  				 ErrorDok   = A.TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NRDOK AS BIGINT))+
                                               ', '+CONVERT(Varchar,A.DateDok,4)+
                                               CASE WHEN CHARINDEX(A.ORG,'ABHD')>0 THEN ' /'+A.REFERDOK ELSE '' END,
		 	             ErrorMsg   = CASE WHEN ISNULL(A.NRDFK,0)=0 THEN 'Pa kaluar LM' ELSE 'Lidhje Fk gabim' END,
			             ErrorRef   = A.TIPDOK+': Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
                         ErrorOrder = @ErrorOrd+'/25',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM #ARTestFk A 
                   WHERE (ISNULL(A.NRDFK,0)=0) 
                          OR 
                         (NOT EXISTS (SELECT C.NRRENDOR 
                                         FROM #FkTestFk C
                                        WHERE C.NRDFk=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))
              ) A
       END;


   --  T5.7  Banka
   IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,BANKA','')<>'' AND dbo.Isd_ListFields2Lists(@Operacion,'ALL,NOTFK','')<>''
       BEGIN
                SET @TableName = 'BANKA';
			 INSERT INTO #TestFkDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
		  UNION ALL     
			 SELECT @Dok,'','','Dokument FK mungon/gabuar','',@TableName,0,@ErrorOrd+'/26',0

          UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)
               FROM
              (   SELECT Test       = @TableName+'->Fk',
		  				 ErrorDok   = A.TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NRDOK AS BIGINT))+
                                               ', '+CONVERT(Varchar,A.DateDok,4)+
                                               CASE WHEN CHARINDEX(A.ORG,'ABHD')>0 THEN ' /'+A.REFERDOK ELSE '' END,
		 	             ErrorMsg   = CASE WHEN ISNULL(A.NRDFK,0)=0 THEN 'Pa kaluar LM' ELSE 'Lidhje Fk gabim' END,
			             ErrorRef   = A.TIPDOK+': Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
                         ErrorOrder = @ErrorOrd+'/26',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM #BATestFk A 
                   WHERE (ISNULL(A.NRDFK,0)=0) 
                          OR 
                         (NOT EXISTS (
                                       SELECT C.NRRENDOR 
                                         FROM #FkTestFk C
                                        WHERE C.NRDFK=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))
              ) A
       END;


   --  T5.8  VS
   
   IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,VS','')<>'' AND dbo.Isd_ListFields2Lists(@Operacion,'ALL,NOTFK','')<>''
       BEGIN
                SET @TableName = 'VS';
			 INSERT INTO #TestFkDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
		  UNION ALL     
			 SELECT @Dok,'','','Dokument FK mungon/gabuar','',@TableName,0,@ErrorOrd+'/27',0

          UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)
               FROM
              (   SELECT Test       = @TableName+'->Fk',
		  				 ErrorDok   = A.TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NRDOK AS BIGINT))+
                                               ', '+CONVERT(Varchar,A.DateDok,4)+
                                               CASE WHEN CHARINDEX(A.ORG,'ABHD')>0 THEN ' /'+A.REFERDOK ELSE '' END,
		 	             ErrorMsg   = CASE WHEN ISNULL(A.NRDFK,0)=0 THEN 'Pa kaluar LM' ELSE 'Lidhje Fk gabim' END,
			             ErrorRef   = A.TIPDOK+': Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
                         ErrorOrder = @ErrorOrd+'/27',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM #VSTestFk A 
                   WHERE (ISNULL(A.NRDFK,0)=0) 
                          OR 
                         (NOT EXISTS (
                                       SELECT C.NRRENDOR 
                                         FROM #FkTestFk C
                                        WHERE C.NRDFK=A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))
              ) A
       END;


   --  T5.9  AQ
   IF  dbo.Isd_ListFields2Lists(@PTNames,'ALL,AQ','')<>'' AND dbo.Isd_ListFields2Lists(@Operacion,'ALL,NOTFK','')<>''
       BEGIN
                SET @TableName = 'AQ';
			 INSERT INTO #TestFkDok
				   (Dok,       Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	         SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
		  UNION ALL     
			 SELECT @Dok,'','','Dokument FK mungon/gabuar','',@TableName,0,@ErrorOrd+'/28',0

          UNION ALL
			 SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,
					ErrorRowNr=ROW_NUMBER() OVER (ORDER BY NrRendor ASC)
               FROM
              (   SELECT Test       = @TableName+'->Fk',
		  				 ErrorDok   = A.TIPDOK+' nr '+CONVERT(nVarchar(20),CAST(A.NRDOK AS BIGINT))+
                                               ', '+CONVERT(Varchar,A.DateDok,4)+
                                               CASE WHEN CHARINDEX(A.ORG,'ABHD')>0 THEN ' /'+A.REFERDOK ELSE '' END,
		 	             ErrorMsg   = CASE WHEN ISNULL(A.NRDFK,0)=0 THEN 'Pa kaluar LM' ELSE 'Lidhje Fk gabim' END,
			             ErrorRef   = A.TIPDOK+': Nr '+CONVERT(nVarchar(20),CAST(A.NrDok AS BIGINT))+', '+CONVERT(Varchar,A.DateDok,4),
                         ErrorOrder = @ErrorOrd+'/28',
			             TableName  = @TableName,
                         A.NRRENDOR 
					FROM #AQTestFk A 
                   WHERE (ISNULL(A.NRDFK,0)=0) 
                          OR 
                         (NOT EXISTS ( 
                                       SELECT C.NRRENDOR 
                                         FROM #FkTestFk C
                                        WHERE C.NRDFK= A.NRDFK AND C.ORG=A.ORG AND C.TIPDOK=A.TIPDOK AND C.NRDOK=A.NRDOK AND C.REFERDOK=A.REFERDOK AND C.DATEDOK=A.DATEDOK))
              ) A
       END;
       
       
-------------------------- A f i s h i m i ----------------

          IF OBJECT_ID('TempDB..#ARTestFk') IS NOT NULL
             DROP TABLE #ARTestFk; 
          IF OBJECT_ID('TempDB..#BATestFk') IS NOT NULL
             DROP TABLE #BATestFk; 
          IF OBJECT_ID('TempDB..#VSTestFk') IS NOT NULL
             DROP TABLE #VSTestFk; 
          IF OBJECT_ID('TempDB..#FkTestFk') IS NOT NULL
             DROP TABLE #FkTestFk; 
          IF OBJECT_ID('TempDB..#FJTestFk') IS NOT NULL
             DROP TABLE #FJTestFk; 
          IF OBJECT_ID('TempDB..#FFTestFk') IS NOT NULL
             DROP TABLE #FFTestFk;  
          IF OBJECT_ID('TempDB..#FkTestFk') IS NOT NULL
             DROP TABLE #FkTestFk; 
          IF OBJECT_ID('TempDB..#FHTestFk') IS NOT NULL
             DROP TABLE #FHTestFk; 
          IF OBJECT_ID('TempDB..#FDTestFk') IS NOT NULL
             DROP TABLE #FDTestFk; 
          IF OBJECT_ID('TempDB..#DGTestFk') IS NOT NULL
             DROP TABLE #DGTestFk;
          IF OBJECT_ID('TempDB..#AQTestFk') IS NOT NULL
             DROP TABLE #AQTestFk;
                 

          IF @TestTable<>''      -- Mbush nje tabele qe mund te afishohet me vone ....
             BEGIN
             
               SET   @sSql = '
               
           INSERT INTO '+@TestTable+'
                 (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
           SELECT ISNULL(Dok,''''),      ISNULL(Test,''''),     ISNULL(ErrorDok,''''),
                  ISNULL(ErrorMsg,''''), ISNULL(ErrorRef,''''), ISNULL(TableName,''''),
                  ISNULL(NrRendor,0),    ErrorOrder,            ErrorRowNr
             FROM #TestFkDok;

             DROP TABLE #TestFkDok; ';
             
               EXEC (@sSql);
               
             END
             
          ELSE
         
             BEGIN

               SELECT * FROM #TestFkDok ORDER BY ErrorOrder,ErrorRowNr,TableName;

             END;
GO
