SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   procedure [dbo].[Isd_TestReference]
(
  @pTestTip         Varchar(1000),
  @pTestTableName   Varchar(30)
)
AS

--         IF OBJECT_ID('TempDB..#TestRef') IS NOT NULL
--            DROP TABLE #TestRef;
--     SELECT Dok      = REPLICATE('',20),  Test      = REPLICATE('',30),  ErrorDok   = REPLICATE('',100), ErrorMsg   = REPLICATE('',100),
--            ErrorRef = REPLICATE('',100), TableName = REPLICATE('',100), ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(0 AS BIGINT), NrRendor = 0
--       INTO #TestDok     
--      WHERE 1=2;
--       EXEC dbo.Isd_TestReference 'REF','#TestDok'

-- Test  1.    Monedha
-- Test  2.    Llogari
-- Test  3.    Artikuj
-- Test  4.    Magazina
-- Test  5.    Tatim
-- Test  6.    Njesi

-- Test  7.    Klient
-- Test  8.    Furnitore

-- Test  9.    Arkat
-- Test 10.    Bankat
-- Test 11.    Departament
-- Test 12.    Liste
-- Test 13.    SkemeLM

-- Test 14.    Sherbim
-- Test 15.    Zbritje
-- Test 16.    Kase
-- Test 17.    Kategori
-- Test 18.    Rajon
-- Test 19.    Vendndodhje
-- Test 20.    Agjent Shtije
-- Test 21.    Aktivet
-- Test 22.    Lista e FA (e pa perfunduar)




     DECLARE @ErrorOrd    Varchar(100),
             @TableName   Varchar(30),
             @Dok         Varchar(20),
             @sSql        Varchar(MAX);

         IF  dbo.Isd_ListFields2Lists(@pTestTip,'ALL,REF','')=''
             RETURN;


-- Inicializimi

          IF OBJECT_ID('TempDB..#TestRef') IS NOT NULL
             DROP TABLE #TestRef;
             
             
      SELECT Dok        = REPLICATE('',20),  Test       = REPLICATE('',30),
             ErrorDok   = REPLICATE('',100), ErrorMsg   = REPLICATE('',100),
             ErrorRef   = REPLICATE('',100), TableName  = REPLICATE('',100),
             ErrorOrder = REPLICATE('',100), ErrorRowNr = CAST(0 AS BIGINT),
             NrRendor   = 0
        INTO #TestRef
       WHERE 1=2;

         SET @ErrorOrd  = 'Ref';
         SET @Dok       = 'REF';

	  INSERT INTO #TestRef
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
	  SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1
   UNION ALL
	  SELECT @Dok,'','','=====   REFERENCA   =====','',@TableName,0,@ErrorOrd,-1
   UNION ALL
	  SELECT @Dok,'','','','',@TableName,0,@ErrorOrd,-1;
         


-- T1 ----------------------  M O N E D H A  -------------------------

         SET @TableName = 'MONEDHA';
         SET @ErrorOrd  = ' 01'+LEFT(@TableName,3)+' '; 
         
      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0

   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Kod perseritur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1', 
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+MIN(A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM MONEDHA A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

     UNION ALL

		SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Mon vendi',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/2',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(MAX(A.KOD+' / '+A.PERSHKRIM),100),
                       ErrorRef  = 'Disa mon baze '+' / '+CAST(COUNT(A.MONVEND) AS Varchar),
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM MONEDHA A
                 WHERE ISNULL(A.MONVEND,0)=1
			  GROUP BY A.MONVEND
                HAVING ISNULL(COUNT(A.MONVEND),0)>=2 
              ) A1

     UNION ALL

		SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Kurset gabim',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/3',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Kurset :'+CAST(ISNULL(A.KURS1,0) AS Varchar)+' / '+CAST(ISNULL(A.KURS2,0) AS Varchar),
					   NrRendor  = A.NRRENDOR
				  FROM MONEDHA A
                 WHERE ISNULL(A.KURS1,0)<=0 OR ISNULL(A.KURS2,0)<=0
              ) A1
       ) B ;



-- T2 ----------------------  L L O G A R I  -------------------------

         SET @TableName = 'LLOGARI';
         SET @ErrorOrd  = 'Ref 02'+'LLG ';

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0

   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Kod perseritur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1', 
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(MIN(A.KOD+' / '+A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM TATIM A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

     UNION ALL

		SELECT Test       = @TableName,
			   ErrorDok   = 'Llog. jo Aktiv/Pasiv',    
			   ErrorMsg   = 'Llg. jo A/P',
               ErrorRef   = CAST(A1.NrNotAP AS Varchar)+' llg. papercaktuar',
               ErrorOrder = @ErrorOrd + '/2',
               ErrorRowNr = 1,
			   TableName  = @TableName,
			   NrRendor   = 0
		  FROM 
			  ( SELECT NrNotAP   = ISNULL(COUNT(A.AKTPASIV),0)
				  FROM LLOGARI A
                 WHERE ISNULL(A.POZIC,0)=1 AND (NOT (ISNULL(A.AKTPASIV,'') In ('A','P'))) 
              ) A1
         WHERE A1.NrNotAP>=1
         
       ) B ;



-- T3 -------------------------  A R T I K U J  -------------------------

         SET @TableName = 'ARTIKUJ';
         SET @ErrorOrd  = 'Ref 03'+LEFT(@TableName,3)+' ';

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0

   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    --  = LEFT(A1.KOD+' / '+A1.Pershkrim,100),
			   ErrorMsg   = 'Figuron disa here',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(MIN(A.KOD+' / '+A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM ARTIKUJ A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

     UNION ALL		        

		SELECT Test       = @TableName,
			   ErrorDok,    --  = LEFT(A1.KOD+' / '+A1.Pershkrim,100),
			   ErrorMsg   = 'Ref. panjohur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/2',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Njesi   : '+ISNULL(A.NJESI, ''),
					   NrRendor  = A.NRRENDOR
				  FROM ARTIKUJ A
                 WHERE                            (NOT EXISTS (SELECT KOD FROM NJESI      B WHERE B.KOD=A.NJESI ))
                       
             UNION ALL 
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Njesi Bl: '+ISNULL(A.NJESB, ''),
					   NrRendor  = A.NRRENDOR
				  FROM ARTIKUJ A
                 WHERE                            (NOT EXISTS (SELECT KOD FROM NJESI      B WHERE B.KOD=A.NJESB ))
                       
             UNION ALL 
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Njesi Sh: '+ISNULL(A.NJESSH,''),
					   NrRendor  = A.NRRENDOR
				  FROM ARTIKUJ A
                 WHERE                            (NOT EXISTS (SELECT KOD FROM NJESI      B WHERE B.KOD=A.NJESSH))
                       
             UNION ALL 
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Sk.LM : '  +ISNULL(A.KODLM,''),
					   NrRendor  = A.NRRENDOR
				  FROM ARTIKUJ A
                 WHERE                            (NOT EXISTS (SELECT KOD FROM SKEMELM     B WHERE B.KOD=A.KODLM))
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Dep   : '+ISNULL(A.DEP, ''),
					   NrRendor  = A.NRRENDOR
				  FROM ARTIKUJ A
                 WHERE (ISNULL(A.DEP,'') <>'' AND (NOT EXISTS (SELECT KOD FROM DEPARTAMENT B WHERE B.KOD=A.DEP )))

             UNION ALL 
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'List  : '+ISNULL(A.LIST, ''),
					   NrRendor  = A.NRRENDOR
				  FROM ARTIKUJ A
                 WHERE (ISNULL(A.LIST,'')<>'' AND (NOT EXISTS (SELECT KOD FROM LISTE       B WHERE B.KOD=A.LIST)))
                  
              ) A1

     UNION ALL		        

		SELECT Test       = @TableName,
			   ErrorDok,  --= LEFT(A1.KOD+' / '+A1.Pershkrim,100),
			   ErrorMsg   = 'Prodhim pa perbersa',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/3',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'pa perberesa ',
					   NrRendor  = A.NRRENDOR
				  FROM ARTIKUJ A
                 WHERE TIP='P' AND 
                      (NOT EXISTS (SELECT NRRENDOR FROM ARTIKUJSCR B WHERE B.NRD=A.NRRENDOR))
            
              ) A1

     UNION ALL		        

		SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Zbr. panjohur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/4', 
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = CASE WHEN (ISNULL(A.DSCNTKLA,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLA))) THEN 'Zbr A: '+ISNULL(A.DSCNTKLA,'')
                                        WHEN (ISNULL(A.DSCNTKLB,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLB))) THEN 'Zbr B: '+ISNULL(A.DSCNTKLB,'')
                                        WHEN (ISNULL(A.DSCNTKLC,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLC))) THEN 'Zbr C: '+ISNULL(A.DSCNTKLC,'')
                                        WHEN (ISNULL(A.DSCNTKLD,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLD))) THEN 'Zbr D: '+ISNULL(A.DSCNTKLD,'')
                                        WHEN (ISNULL(A.DSCNTKLE,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLE))) THEN 'Zbr E: '+ISNULL(A.DSCNTKLE,'')
                                        WHEN (ISNULL(A.DSCNTKLF,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLF))) THEN 'Zbr F: '+ISNULL(A.DSCNTKLF,'')
                                        WHEN (ISNULL(A.DSCNTKLG,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLG))) THEN 'Zbr G: '+ISNULL(A.DSCNTKLG,'')
                                        WHEN (ISNULL(A.DSCNTKLH,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLE))) THEN 'Zbr H: '+ISNULL(A.DSCNTKLH,'')
                                        WHEN (ISNULL(A.DSCNTKLI,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLF))) THEN 'Zbr I: '+ISNULL(A.DSCNTKLI,'')
                                        WHEN (ISNULL(A.DSCNTKLJ,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLG))) THEN 'Zbr J: '+ISNULL(A.DSCNTKLJ,'')
                                        ELSE ''
                                   END,
					   NrRendor  = A.NRRENDOR

				  FROM ARTIKUJ A
                 WHERE (ISNULL(A.DSCNTKLA,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLA))) OR
                       (ISNULL(A.DSCNTKLB,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLB))) OR
                       (ISNULL(A.DSCNTKLC,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLC))) OR
                       (ISNULL(A.DSCNTKLD,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLD))) OR
                       (ISNULL(A.DSCNTKLE,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLE))) OR
                       (ISNULL(A.DSCNTKLF,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLF))) OR
                       (ISNULL(A.DSCNTKLG,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLG))) OR
                       (ISNULL(A.DSCNTKLH,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLH))) OR
                       (ISNULL(A.DSCNTKLI,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLI))) OR
                       (ISNULL(A.DSCNTKLJ,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLJ)))
              ) A1

     UNION ALL		        

		SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Cmime',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/5', 
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = CASE WHEN ISNULL(A.CMSH ,0)   <=0 THEN 'CmSh A: '+CAST(ISNULL(A.CMSH ,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH1,0)   <=0 THEN 'CmSh B: '+CAST(ISNULL(A.CMSH1,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH2,0)   <=0 THEN 'CmSh C: '+CAST(ISNULL(A.CMSH2,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH3,0)   <=0 THEN 'CmSh D: '+CAST(ISNULL(A.CMSH3,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH4,0)   <=0 THEN 'CmSh E: '+CAST(ISNULL(A.CMSH4,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH5,0)   <=0 THEN 'CmSh F: '+CAST(ISNULL(A.CMSH5,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH6,0)   <=0 THEN 'CmSh G: '+CAST(ISNULL(A.CMSH6,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH7,0)   <=0 THEN 'CmSh H: '+CAST(ISNULL(A.CMSH7,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH8,0)   <=0 THEN 'CmSh I: '+CAST(ISNULL(A.CMSH8,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH9,0)   <=0 THEN 'CmSh J: '+CAST(ISNULL(A.CMSH9,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH10,0)  <=0 THEN 'CmSh K: '+CAST(ISNULL(A.CMSH10,0)   AS Varchar)
                                        WHEN ISNULL(A.CMSH11,0)  <=0 THEN 'CmSh L: '+CAST(ISNULL(A.CMSH11,0)   AS Varchar)
                                        WHEN ISNULL(A.CMSH12,0)  <=0 THEN 'CmSh M: '+CAST(ISNULL(A.CMSH12,0)   AS Varchar)
                                        WHEN ISNULL(A.CMSH13,0)  <=0 THEN 'CmSh N: '+CAST(ISNULL(A.CMSH13,0)   AS Varchar)
                                        WHEN ISNULL(A.CMSH14,0)  <=0 THEN 'CmSh O: '+CAST(ISNULL(A.CMSH14,0)   AS Varchar)
                                        WHEN ISNULL(A.CMSH15,0)  <=0 THEN 'CmSh P: '+CAST(ISNULL(A.CMSH15,0)   AS Varchar)
                                        WHEN ISNULL(A.CMSH16,0)  <=0 THEN 'CmSh Q: '+CAST(ISNULL(A.CMSH16,0)   AS Varchar)
                                        WHEN ISNULL(A.CMSH17,0)  <=0 THEN 'CmSh R: '+CAST(ISNULL(A.CMSH17,0)   AS Varchar)
                                        WHEN ISNULL(A.CMSH18,0)  <=0 THEN 'CmSh S: '+CAST(ISNULL(A.CMSH18,0)   AS Varchar)
                                        WHEN ISNULL(A.CMSH19,0)  <=0 THEN 'CmSh T: '+CAST(ISNULL(A.CMSH19,0)   AS Varchar)

                                        WHEN ISNULL(A.KOSTMES,0) <=0 THEN 'CmMes : '+CAST(ISNULL(A.KOSTMES,0)  AS Varchar)
                                        WHEN ISNULL(A.KOSTPLAN,0)<=0 THEN 'CmPla : '+CAST(ISNULL(A.KOSTPLAN,0) AS Varchar)
                                        WHEN ISNULL(A.CMB,0)     <=0 THEN 'CmBl  : '+CAST(ISNULL(A.CMB,0)      AS Varchar)
                                        ELSE ''
                                   END,
					   NrRendor  = A.NRRENDOR

				  FROM ARTIKUJ A
                 WHERE 101=205 AND 
                      ((ISNULL(A.CMSH ,0)<=0)   OR (ISNULL(A.CMSH1,0)<=0)    OR (ISNULL(A.CMSH2,0)<=0)  OR
                       (ISNULL(A.CMSH3,0)<=0)   OR (ISNULL(A.CMSH4,0)<=0)    OR (ISNULL(A.CMSH5,0)<=0)  OR
                       (ISNULL(A.CMSH6,0)<=0)   OR (ISNULL(A.CMSH7,0)<=0)    OR (ISNULL(A.CMSH8,0)<=0)  OR (ISNULL(A.CMSH9,0)<=0)  OR
                       (ISNULL(A.CMSH10,0)<=0)  OR (ISNULL(A.CMSH11,0)<=0)   OR (ISNULL(A.CMSH12,0)<=0) OR
                       (ISNULL(A.CMSH13,0)<=0)  OR (ISNULL(A.CMSH14,0)<=0)   OR (ISNULL(A.CMSH15,0)<=0) OR
                       (ISNULL(A.CMSH16,0)<=0)  OR (ISNULL(A.CMSH17,0)<=0)   OR (ISNULL(A.CMSH18,0)<=0) OR (ISNULL(A.CMSH19,0)<=0) OR

                       (ISNULL(A.KOSTMES,0)<=0) OR (ISNULL(A.KOSTPLAN,0)<=0) OR (ISNULL(A.CMB  ,0)<=0))
              ) A1
       ) B ;



-- T4 ---------------------  M A G A Z I N A -------------------------

         SET @TableName = 'MAGAZINA';
         SET @ErrorOrd  = 'Ref 04'+LEFT(@TableName,3)+' '; 

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0
         
   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Figuron disa here',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1', 
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(MIN(A.KOD+' / '+A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM MAGAZINA A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

     UNION ALL		        

		SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Ref panjohur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/2',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Dep  : '  +ISNULL(A.DEP, ''),
					   NrRendor  = A.NRRENDOR
				  FROM MAGAZINA A
                 WHERE (ISNULL(A.DEP,'') <>'' AND (NOT EXISTS (SELECT KOD FROM DEPARTAMENT B WHERE B.KOD=A.DEP )))
			  
		     UNION ALL	  
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'List : '  +ISNULL(A.LIST, ''),
					   NrRendor  = A.NRRENDOR
				  FROM MAGAZINA A
                 WHERE (ISNULL(A.LIST,'')<>'' AND (NOT EXISTS (SELECT KOD FROM LISTE       B WHERE B.KOD=A.LIST)))

              ) A1
       ) B ;



-- T5 ----------------------    T A T I M    -------------------------

         SET @TableName = 'TATIM';
         SET @ErrorOrd  = 'Ref 05'+LEFT(@TableName,3)+' ';

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0
         
  UNION ALL
     SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Kod perseritur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(MIN(A.KOD+' / '+A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM TATIM A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

     UNION ALL		        

		SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Ref panjohur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/2',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Llg Db: '+ISNULL(A.LLOGARIDB,''),
					   NrRendor  = A.NRRENDOR
				  FROM TATIM A
                 WHERE (NOT EXISTS (SELECT KOD FROM LLOGARI B WHERE B.KOD=A.LLOGARIDB))
                       
             UNION ALL 
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Llg Kr: '+ISNULL(A.LLOGARIKR,''),
					   NrRendor  = A.NRRENDOR
				  FROM TATIM A
                 WHERE (NOT EXISTS (SELECT KOD FROM LLOGARI B WHERE B.KOD=A.LLOGARIKR))
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Perq  : '+CAST(ISNULL(A.PERQINDJE,0) AS VARCHAR),
					   NrRendor  = A.NRRENDOR
				  FROM TATIM A
                 WHERE (ISNULL(A.PERQINDJE,0) < 0)
    
              ) A1
       ) B ;



-- T6 ----------------------    N J E S I    -------------------------

         SET @TableName = 'NJESI';
         SET @ErrorOrd  = 'Ref 06'+LEFT(@TableName,3)+' ';

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0
         
   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Kod perseritur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(MIN(A.KOD+' / '+A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM TATIM A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1
       ) B ;



-- T7 ----------------------   K L I E N T   -------------------------

         SET @TableName = 'KLIENT';
         SET @ErrorOrd  = 'Ref 07'+LEFT(@TableName,3)+' ';

      INSERT INTO #TestRef  
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
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+MIN(A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM KLIENT A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

     UNION ALL		        

		SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Nipt perseritur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/2', 
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = MIN(LEFT(A.KOD+' / '+A.PERSHKRIM,100)),
                       ErrorRef  = 'Nipt '+A.NIPT+' / '+CAST(COUNT(A.NIPT) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM KLIENT A
                 WHERE ISNULL(A.NIPT,'')<>''
			  GROUP BY A.NIPT
                HAVING ISNULL(COUNT(A.NIPT),0)>=2 
              ) A1

     UNION ALL

		SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Ref panjohur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/3', 
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  (
			  
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Llg    : '+ISNULL(A.LLOGARI,''),
					   NrRendor  = A.NRRENDOR
				  FROM KLIENT A
                 WHERE                                    (NOT EXISTS (SELECT KOD FROM LLOGARI      B  WHERE B.KOD=A.LLOGARI))
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Mag    : '+ISNULL(A.KMAG,''),
					   NrRendor  = A.NRRENDOR
				  FROM KLIENT A
                 WHERE (ISNULL(A.KMAG,'')<>''         AND (NOT EXISTS (SELECT KOD FROM MAGAZINA     B  WHERE B.KOD=A.KMAG))) 

             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Mon    : '+ISNULL(A.KMON,''),
					   NrRendor  = A.NRRENDOR
				  FROM KLIENT A
                 WHERE (ISNULL(A.KMON,'')<>''         AND (NOT EXISTS (SELECT KOD FROM MONEDHA      B  WHERE B.KOD=A.KMON))) 
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Dep    : '+ISNULL(A.DEP, ''),
					   NrRendor  = A.NRRENDOR
				  FROM KLIENT A
                 WHERE (ISNULL(A.DEP,'') <>''         AND (NOT EXISTS (SELECT KOD FROM DEPARTAMENT  B  WHERE B.KOD=A.DEP ))) 
                       
             UNION ALL                          
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'List   : '+ISNULL(A.LISTE, ''),
					   NrRendor  = A.NRRENDOR
				  FROM KLIENT A
                 WHERE (ISNULL(A.LISTE,'')<>''        AND (NOT EXISTS (SELECT KOD FROM LISTE        B  WHERE B.KOD=A.LISTE))) 

             UNION ALL                          
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Vend   : '+ISNULL(A.VENDNDODHJE, ''),
					   NrRendor  = A.NRRENDOR
				  FROM KLIENT A
                 WHERE (ISNULL(A.VENDNDODHJE,'')<>''  AND (NOT EXISTS (SELECT KOD FROM VENDNDODHJE  B  WHERE B.KOD=A.VENDNDODHJE))) 			  
			  
             UNION ALL                          
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'AgjSh  : '+ISNULL(A.AGJENTSHITJE, ''),
					   NrRendor  = A.NRRENDOR
				  FROM KLIENT A
                 WHERE (ISNULL(A.AGJENTSHITJE,'')<>'' AND (NOT EXISTS (SELECT KOD FROM AGJENTSHITJE B  WHERE B.KOD=A.AGJENTSHITJE))) 			  

             UNION ALL                          
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'LidhKl : '+ISNULL(A.LINKKLIENT, ''),
					   NrRendor  = A.NRRENDOR
				  FROM KLIENT A
                 WHERE (ISNULL(A.LINKKLIENT,'')<>''  AND (NOT EXISTS (SELECT KOD FROM KLIENT        B  WHERE B.KOD=A.LINKKLIENT))) 			  

              ) A1
       ) B ;



-- T8 --------------------  F U R N T I T O R  -----------------------

         SET @TableName = 'FURNITOR';
         SET @ErrorOrd  = 'Ref 08'+LEFT(@TableName,3)+' ';

      INSERT INTO #TestRef  
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
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+MIN(A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM FURNITOR A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

     UNION ALL		        

		SELECT Test       = @TableName,
			   ErrorDok,   
			   ErrorMsg   = 'Nipt perseritur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/2',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = MIN(LEFT(A.KOD+' / '+A.PERSHKRIM,100)),
                       ErrorRef  = 'Nipt '+A.NIPT+' / '+CAST(COUNT(A.NIPT) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM FURNITOR A
                 WHERE ISNULL(A.NIPT,'')<>''
			  GROUP BY A.NIPT
                HAVING ISNULL(COUNT(A.NIPT),0)>=2 
              ) A1

     UNION ALL

		SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Ref panjohur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/3',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( 
			  
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Llg    : '+ISNULL(A.LLOGARI,''),
					   NrRendor  = A.NRRENDOR
				  FROM FURNITOR A
                 WHERE                             (NOT EXISTS (SELECT KOD FROM LLOGARI B     WHERE B.KOD=A.LLOGARI))
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Mon    : '+ISNULL(A.KMON,''),
					   NrRendor  = A.NRRENDOR
				  FROM FURNITOR A
                 WHERE (ISNULL(A.KMON,'')<>''  AND (NOT EXISTS (SELECT KOD FROM MONEDHA     B WHERE B.KOD=A.KMON))) 
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Dep    : '+ISNULL(A.DEP, ''),
					   NrRendor  = A.NRRENDOR
				  FROM FURNITOR A
                 WHERE (ISNULL(A.DEP,'') <>''  AND (NOT EXISTS (SELECT KOD FROM DEPARTAMENT B WHERE B.KOD=A.DEP ))) 
                       
             UNION ALL                          
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'List   : '+ISNULL(A.LISTE, ''),
					   NrRendor  = A.NRRENDOR
				  FROM FURNITOR A
                 WHERE (ISNULL(A.LISTE,'')<>'' AND (NOT EXISTS (SELECT KOD FROM LISTE       B WHERE B.KOD=A.LISTE))) 

             UNION ALL                          
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Vend   : '+ISNULL(A.VENDNDODHJE, ''),
					   NrRendor  = A.NRRENDOR
				  FROM FURNITOR A
                 WHERE (ISNULL(A.LISTE,'')<>'' AND (NOT EXISTS (SELECT KOD FROM LISTE       B WHERE B.KOD=A.LISTE))) 			  
			  
              ) A1
       ) B ;



-- T9 ----------------------    A R K A T    -------------------------

         SET @TableName = 'ARKAT';
         SET @ErrorOrd  = 'Ref 09'+LEFT(@TableName,3)+' ';

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0
         
   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Figuron disa here',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+MIN(A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM ARKAT A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

     UNION ALL		        

		SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Ref panjohur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/2',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Llogari: '+ISNULL(A.LLOGARI,''),
					   NrRendor  = A.NRRENDOR
				  FROM ARKAT A
                 WHERE                             (NOT EXISTS (SELECT KOD FROM LLOGARI     B WHERE B.KOD=A.LLOGARI))
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Mon    : '+ISNULL(A.KMON,''),
					   NrRendor  = A.NRRENDOR
				  FROM ARKAT A
                 WHERE (ISNULL(A.KMON,'')<>''  AND (NOT EXISTS (SELECT KOD FROM MONEDHA     B WHERE B.KOD=A.KMON))) 
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Dep    : '+ISNULL(A.DEP, ''),
					   NrRendor  = A.NRRENDOR
				  FROM ARKAT A
                 WHERE (ISNULL(A.DEP,'') <>''  AND (NOT EXISTS (SELECT KOD FROM DEPARTAMENT B WHERE B.KOD=A.DEP ))) 
                       
             UNION ALL                          
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'List   : '+ISNULL(A.LISTE, ''),
					   NrRendor  = A.NRRENDOR
				  FROM ARKAT A
                 WHERE (ISNULL(A.LISTE,'')<>'' AND (NOT EXISTS (SELECT KOD FROM LISTE       B WHERE B.KOD=A.LISTE))) 

              ) A1
       ) B ;



-- T10 ---------------------   B A N K A T   -------------------------

         SET @TableName = 'BANKAT';
         SET @ErrorOrd  = 'Ref 10'+LEFT(@TableName,3)+' ';

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0
         
   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Figuron disa here',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+MIN(A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM BANKAT A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

     UNION ALL		        

		SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Ref panjohur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/2',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Llogari: '+ISNULL(A.LLOGARI,''),
					   NrRendor  = A.NRRENDOR
				  FROM BANKAT A
                 WHERE                             (NOT EXISTS (SELECT KOD FROM LLOGARI     B WHERE B.KOD=A.LLOGARI))
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Mon    : '+ISNULL(A.KMON,''),
					   NrRendor  = A.NRRENDOR
				  FROM BANKAT A
                 WHERE (ISNULL(A.KMON,'')<>''  AND (NOT EXISTS (SELECT KOD FROM MONEDHA     B WHERE B.KOD=A.KMON))) 
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Dep    : '+ISNULL(A.DEP, ''),
					   NrRendor  = A.NRRENDOR
				  FROM BANKAT A
                 WHERE (ISNULL(A.DEP,'') <>''  AND (NOT EXISTS (SELECT KOD FROM DEPARTAMENT B WHERE B.KOD=A.DEP ))) 
                       
             UNION ALL                          
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'List   : '+ISNULL(A.LISTE, ''),
					   NrRendor  = A.NRRENDOR
				  FROM BANKAT A
                 WHERE (ISNULL(A.LISTE,'')<>'' AND (NOT EXISTS (SELECT KOD FROM LISTE       B WHERE B.KOD=A.LISTE))) 

              ) A1
       ) B ;



-- T11 ---------------------   DEPARTAMENT   -------------------------

         SET @TableName = 'DEPARTAMENT';
         SET @ErrorOrd  = 'Ref 11'+LEFT(@TableName,3)+' '; 

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0
         
   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Figuron disa here',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+MIN(A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM DEPARTAMENT A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1
       ) B ;



-- T12 ---------------------    L I S T E    -------------------------

         SET @TableName = 'LISTE';
         SET @ErrorOrd  = 'Ref 12'+LEFT(@TableName,3)+' ';

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0
         
   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Figuron disa here',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+MIN(A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM LISTE A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1
       ) B ;



-- T13 --------------------- S K E M E  L M -------------------------

         SET @TableName = 'SKEMELM';
         SET @ErrorOrd  = 'Ref 13'+'SLM'+' ';

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0
         
   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Kod perseritur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(MIN(A.KOD+' / '+A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM SKEMELM A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

     UNION ALL

		SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Llg panjohur/jo analize',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/2',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Llg Inv: '   +ISNULL(A.LLOGINV,''),
					   NrRendor  = A.NRRENDOR
				  FROM SKEMELM A
                 WHERE (NOT EXISTS (SELECT KOD FROM LLOGARI B WHERE B.KOD=A.LLOGINV    AND B.POZIC=1))
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Llg shpz : ' +ISNULL(A.NDRGJEND,''),
					   NrRendor  = A.NRRENDOR
				  FROM SKEMELM A
                 WHERE (NOT EXISTS (SELECT KOD FROM LLOGARI B WHERE B.KOD=A.NDRGJEND   AND B.POZIC=1))
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Llg shpBl: ' +ISNULL(A.LLOGB,''),
					   NrRendor  = A.NRRENDOR
				  FROM SKEMELM A
                 WHERE (NOT EXISTS (SELECT KOD FROM LLOGARI B WHERE B.KOD=A.LLOGB      AND B.POZIC=1))
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Llg ardh : ' +ISNULL(A.LLOGSH,''),
					   NrRendor  = A.NRRENDOR
				  FROM SKEMELM A
                 WHERE (NOT EXISTS (SELECT KOD FROM LLOGARI B WHERE B.KOD=A.LLOGSH     AND B.POZIC=1))
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Llg shpsh : '+ISNULL(A.LLOGSHPZ01,''),
					   NrRendor  = A.NRRENDOR
				  FROM SKEMELM A
                 WHERE (NOT EXISTS (SELECT KOD FROM LLOGARI B WHERE B.KOD=A.LLOGSHPZ01 AND B.POZIC=1))

              ) A1
       ) B ;



-- T14 ---------------------  S H E R B I M  -------------------------

         SET @TableName = 'SHERBIM';
         SET @ErrorOrd  = 'Ref 14'+'SHR'+' ';

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0
         
   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Figuron disa here',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+MIN(A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM SHERBIM A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

     UNION ALL		        

		SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Ref panjohur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/2',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Llogari: '+ISNULL(A.LLOGSH,''),
					   NrRendor  = A.NRRENDOR
				  FROM SHERBIM A
                 WHERE                             (NOT EXISTS (SELECT KOD FROM LLOGARI     B WHERE B.KOD=A.LLOGSH)) 

             UNION ALL          
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Njesi: '  +ISNULL(A.NJESI,''),
					   NrRendor  = A.NRRENDOR
				  FROM SHERBIM A
                 WHERE                             (NOT EXISTS (SELECT KOD FROM NJESI       B WHERE B.KOD=A.NJESI ))

             UNION ALL                       
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Dep  : '  +ISNULL(A.DEP, ''),
					   NrRendor  = A.NRRENDOR
				  FROM SHERBIM A
                 WHERE (ISNULL(A.DEP,'') <>''  AND (NOT EXISTS (SELECT KOD FROM DEPARTAMENT B WHERE B.KOD=A.DEP )))

             UNION ALL                       
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'List : '  +ISNULL(A.LISTE, ''),
					   NrRendor  = A.NRRENDOR
				  FROM SHERBIM A
                 WHERE (ISNULL(A.LISTE,'')<>'' AND (NOT EXISTS (SELECT KOD FROM LISTE       B WHERE B.KOD=A.LISTE))) 

              ) A1

     UNION ALL		        

		SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Zbr. panjohur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/3',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = CASE WHEN (ISNULL(A.DSCNTKLA,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLA))) THEN 'Zbr A: '+ISNULL(A.DSCNTKLA,'')
                                        WHEN (ISNULL(A.DSCNTKLB,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLB))) THEN 'Zbr B: '+ISNULL(A.DSCNTKLB,'')
                                        WHEN (ISNULL(A.DSCNTKLC,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLC))) THEN 'Zbr C: '+ISNULL(A.DSCNTKLC,'')
                                        WHEN (ISNULL(A.DSCNTKLD,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLD))) THEN 'Zbr D: '+ISNULL(A.DSCNTKLD,'')
                                        WHEN (ISNULL(A.DSCNTKLE,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLE))) THEN 'Zbr E: '+ISNULL(A.DSCNTKLE,'')
                                        WHEN (ISNULL(A.DSCNTKLF,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLF))) THEN 'Zbr F: '+ISNULL(A.DSCNTKLF,'')
                                        WHEN (ISNULL(A.DSCNTKLG,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLG))) THEN 'Zbr G: '+ISNULL(A.DSCNTKLG,'')
                                        WHEN (ISNULL(A.DSCNTKLH,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLE))) THEN 'Zbr H: '+ISNULL(A.DSCNTKLH,'')
                                        WHEN (ISNULL(A.DSCNTKLI,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLF))) THEN 'Zbr I: '+ISNULL(A.DSCNTKLI,'')
                                        WHEN (ISNULL(A.DSCNTKLJ,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLG))) THEN 'Zbr J: '+ISNULL(A.DSCNTKLJ,'')
                                        ELSE ''
                                   END,
					   NrRendor  = A.NRRENDOR

				  FROM SHERBIM A
                 WHERE (ISNULL(A.DSCNTKLA,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLA))) OR
                       (ISNULL(A.DSCNTKLB,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLB))) OR
                       (ISNULL(A.DSCNTKLC,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLC))) OR
                       (ISNULL(A.DSCNTKLD,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLD))) OR
                       (ISNULL(A.DSCNTKLE,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLE))) OR
                       (ISNULL(A.DSCNTKLF,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLF))) OR
                       (ISNULL(A.DSCNTKLG,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLG))) OR
                       (ISNULL(A.DSCNTKLH,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLH))) OR
                       (ISNULL(A.DSCNTKLI,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLI))) OR
                       (ISNULL(A.DSCNTKLJ,'')<>'' AND (NOT EXISTS (SELECT KOD FROM ZBRITJE B WHERE B.KOD=A.DSCNTKLJ)))
              ) A1

     UNION ALL		        

		SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Cmime',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/4',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = CASE WHEN ISNULL(A.CMSH ,0)   <=0 THEN 'CmSh A: '+CAST(ISNULL(A.CMSH ,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH1,0)   <=0 THEN 'CmSh B: '+CAST(ISNULL(A.CMSH1,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH2,0)   <=0 THEN 'CmSh C: '+CAST(ISNULL(A.CMSH2,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH3,0)   <=0 THEN 'CmSh D: '+CAST(ISNULL(A.CMSH3,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH4,0)   <=0 THEN 'CmSh E: '+CAST(ISNULL(A.CMSH4,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH5,0)   <=0 THEN 'CmSh F: '+CAST(ISNULL(A.CMSH5,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH6,0)   <=0 THEN 'CmSh G: '+CAST(ISNULL(A.CMSH6,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH7,0)   <=0 THEN 'CmSh H: '+CAST(ISNULL(A.CMSH7,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH8,0)   <=0 THEN 'CmSh I: '+CAST(ISNULL(A.CMSH8,0)    AS Varchar)
                                        WHEN ISNULL(A.CMSH9,0)   <=0 THEN 'CmSh J: '+CAST(ISNULL(A.CMSH9,0)    AS Varchar)
                                        ELSE ''
                                   END,
					   NrRendor  = A.NRRENDOR

				  FROM SHERBIM A
                 WHERE (ISNULL(A.CMSH ,0)<=0)   OR (ISNULL(A.CMSH1,0)<=0)    OR (ISNULL(A.CMSH2,0)<=0) OR
                       (ISNULL(A.CMSH3,0)<=0)   OR (ISNULL(A.CMSH4,0)<=0)    OR (ISNULL(A.CMSH5,0)<=0) OR
                       (ISNULL(A.CMSH6,0)<=0)   OR (ISNULL(A.CMSH7,0)<=0)    OR (ISNULL(A.CMSH8,0)<=0) OR (ISNULL(A.CMSH9,0)<=0) 
              ) A1
       ) B ;



-- T15 ---------------------   Z B R I T J E  -------------------------

         SET @TableName = 'ZBRITJE';
         SET @ErrorOrd  = 'Ref 15'+LEFT(@TableName,3)+' ';

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0
         
   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Figuron disa here',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(MIN(A.KOD+' / '+A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM ZBRITJE A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1
       ) B ;



-- T16 ---------------------     K A S E     -------------------------

         SET @TableName = 'KASE';
         SET @ErrorOrd  = 'Ref 16'+LEFT(@TableName,3)+' ';

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0
         
   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Figuron disa here',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+MIN(A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM KASE A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

     UNION ALL		        

		SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Ref panjohur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/2',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Klient  : '+ISNULL(A.KODKL,''),
					   NrRendor  = A.NRRENDOR
				  FROM KASE A
                 WHERE (NOT EXISTS (SELECT KOD FROM KLIENT   B WHERE B.KOD=A.KODKL)) 
                       
             UNION ALL          
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Mag     : '   +ISNULL(A.KMAG,''),
					   NrRendor  = A.NRRENDOR
				  FROM KASE A
                 WHERE (NOT EXISTS (SELECT KOD FROM MAGAZINA B WHERE B.KOD=A.KMAG)) 

              ) A1
       ) B ;



-- T17 ---------------------  K A T E G O R I -------------------------

         SET @TableName = 'KATEGORI';
         SET @ErrorOrd  = 'Ref 17'+'KTG'+' ';

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0
         
   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Figuron disa here',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(MIN(A.KOD+' / '+A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM KATEGORI A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1
       ) B ;



-- T18 ---------------------     R A J O N    -------------------------

         SET @TableName = 'RAJON';
         SET @ErrorOrd  = 'Ref 18'+LEFT(@TableName,3)+' ';

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0
         
   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Figuron disa here',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(MIN(A.KOD+' / '+A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM MAGAZINA A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1
       ) B ;



-- T19 ---------------------   VENNNDODHJE    -------------------------

         SET @TableName = 'VENDNDODHJE';
         SET @ErrorOrd  = 'Ref 19'+'VND'+' ';

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0
         
   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Figuron disa here',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1', 
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(MIN(A.KOD+' / '+A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM VENDNDODHJE A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1
       ) B ;



-- T20 -------------------------  A K T I V E T  -------------------------

         SET @TableName = 'AQKARTELA';
         SET @ErrorOrd  = 'Ref 20'+'Aktivet'+' ';

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0

   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    --  = LEFT(A1.KOD+' / '+A1.Pershkrim,100),
			   ErrorMsg   = 'Figuron disa here',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(MIN(A.KOD+' / '+A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM AQKARTELA A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1

     UNION ALL		        

		SELECT Test       = @TableName,
			   ErrorDok,    --  = LEFT(A1.KOD+' / '+A1.Pershkrim,100),
			   ErrorMsg   = 'Ref. panjohur',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/2',
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Njesi   : '+ISNULL(A.NJESI, ''),
					   NrRendor  = A.NRRENDOR
				  FROM AQKARTELA A
                 WHERE                                 (NOT EXISTS (SELECT KOD FROM NJESI       B WHERE B.KOD=A.NJESI )) 
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Skeme LM: '  +ISNULL(A.KODLM,''),
					   NrRendor  = A.NRRENDOR
				  FROM AQKARTELA A
                 WHERE                                 (NOT EXISTS (SELECT KOD FROM AQSKEMELM   B WHERE B.KOD=A.KODLM ))

             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Kateg   : '+ISNULL(A.KATEGORI, ''),
					   NrRendor  = A.NRRENDOR
				  FROM AQKARTELA A
                 WHERE (ISNULL(A.KATEGORI,'') <>'' AND (NOT EXISTS (SELECT KOD FROM AQKATEGORI  B WHERE B.KOD=A.KATEGORI )))
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Grup   : '+ISNULL(A.GRUP, ''),
					   NrRendor  = A.NRRENDOR
				  FROM AQKARTELA A
                 WHERE (ISNULL(A.GRUP,'')     <>'' AND (NOT EXISTS (SELECT KOD FROM AQGRUP      B WHERE B.KOD=A.GRUP )))
                       
             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Dep   : '+ISNULL(A.DEP, ''),
					   NrRendor  = A.NRRENDOR
				  FROM AQKARTELA A
                 WHERE (ISNULL(A.DEP,'')      <>'' AND (NOT EXISTS (SELECT KOD FROM DEPARTAMENT B WHERE B.KOD=A.DEP ))) 

             UNION ALL
                SELECT ErrorDok  = LEFT(A.KOD+' / '+A.PERSHKRIM,100),
			           ErrorRef  = 'Liste : '+ISNULL(A.LIST, ''),
					   NrRendor  = A.NRRENDOR
				  FROM AQKARTELA A
                 WHERE (ISNULL(A.LIST,'')     <>'' AND (NOT EXISTS (SELECT KOD FROM LISTE       B WHERE B.KOD=A.LIST))) 
 
              ) A1

       ) B ;
       
       

-- T21 ---------------------   AGJENTSHITJE   -------------------------

         SET @TableName = 'AGJENTSHITJE'
         SET @ErrorOrd  = 'Ref 21'+LEFT(@TableName,3)+' '

      INSERT INTO #TestRef  
		    (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
      SELECT @Dok,'','',@TableName,'',@TableName,0,@ErrorOrd,0
         
   UNION ALL
      SELECT @Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr

       FROM
	  ( SELECT Test       = @TableName,
			   ErrorDok,    
			   ErrorMsg   = 'Figuron disa here',
               ErrorRef,
               ErrorOrder = @ErrorOrd + '/1', 
               ErrorRowNr = ROW_NUMBER() OVER (ORDER BY A1.NrRendor ASC),
			   TableName  = @TableName,
			   NrRendor   = CAST(A1.NrRendor AS INT)
		  FROM 
			  ( SELECT ErrorDok  = LEFT(MIN(A.KOD+' / '+A.PERSHKRIM),100),
                       ErrorRef  = 'Kod '+A.KOD+' / '+CAST(COUNT(A.KOD) AS Varchar)+' here.',
					   NrRendor  = MIN(A.NRRENDOR)
				  FROM AGJENTSHITJE A
			  GROUP BY A.KOD
                HAVING ISNULL(COUNT(A.KOD),0)>=2 
              ) A1
       ) B ;



-- T22 ---------------------    Grupi i FA    -------------------------  





-- -------------------------  A f i s h i m i -------------------------

    IF @pTestTableName<>''       -- Mbush nje tabele qe mund te afishohet me vone ....
       BEGIN
       
         SET @sSql = '
         INSERT INTO ' + @pTestTableName + '
               (Dok,Test,ErrorDok,ErrorMsg,ErrorRef,TableName,NrRendor,ErrorOrder,ErrorRowNr)
         SELECT ISNULL(Dok,''''),       ISNULL(Test,''''),     ISNULL(ErrorDok,''''),
                ISNULL(ErrorMsg,''''),  ISNULL(ErrorRef,''''), ISNULL(TableName,''''),
                ISNULL(NrRendor,0),     ErrorOrder,            ErrorRowNr
           FROM #TestRef;

           DROP TABLE #TestRef;  -- SELECT * FROM ' + @pTestTableName + ' ORDER BY ErrorOrder,ErrorRowNr,TableName; ';
           
         EXEC (@sSql);
         
       END
       
   ELSE
   
       BEGIN
       
         SELECT * FROM #TestRef ORDER BY ErrorOrder,ErrorRowNr,TableName;
         
       END;
GO
