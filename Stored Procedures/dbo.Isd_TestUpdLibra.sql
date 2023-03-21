SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   procedure [dbo].[Isd_TestUpdLibra]
(
  @pDateKp          Varchar(20),
  @pDateKs          Varchar(20),
  @pDocNames        Varchar(1000),
  @pTestVlere       Float,
  @pOperacion       Varchar(100),
  @pTestTable       Varchar(30)
)
AS

--     EXEC dbo.[Isd_TestUpdLibra] '01/01/2010','31/12/2012','ARKA,BANKA',0.01,'SISTLB,SISTLBFR,SISTLBCM',''
--     @POperacion = 'REFDBL,SISTLB,SISTLBFR,SISTLBCM'

-- 1.  Fshirje Referenca te dublikuara....
-- 2.  Sistemim ne Tabelat e Librave....

     DECLARE @DocNames         Varchar(1000),
             @Operacion        Varchar(100),

             @Ind1             Int,
             @Nr1              Int,
             @TblList          Varchar(MAX),
             @SQLFilter00      Varchar(MAX),
             @SQLFilter01      Varchar(MAX),
             @ListTables       Varchar(MAX),
             @TName            Varchar(50);

         SET @DocNames       = @pDocNames;
         SET @Operacion      = @pOperacion;  -- 'REFDBL,SISTLB,SISTLBFR,SISTLBCM';
         
         SET @ListTables     = dbo.Isd_ListTables('','');

         IF  OBJECT_ID('TempDB..#TempLiber') IS NOT NULL
             DROP TABLE #TempLiber;

	  SELECT KMAG,KOD,PERSHKRIM,KODAF,KARTLLG,
             KMON=SPACE(10), SG1=SPACE(60), SG2=SPACE(60), SG3=SPACE(60), SG4=SPACE(60), SG5=SPACE(60)
        INTO #TempLiber
	    FROM LEVIZJEHD
       WHERE 1=2;



-- 1.    Fshirje Referenca te dublikuara....

		  IF dbo.Isd_ListFields2Lists(@Operacion,'ALL,REFDBL','')<>''
		     BEGIN 

	 	   --  SET   @TblList    = dbo.Isd_ListTablesDR('','REF')+',LAR,LBA,LKL,LFU,LMG,LM,LAQ'
           --  Per   Tabelat Reference eshte procedura Isd_TestReference

               SET   @TblList     = 'LAR,LBA,LKL,LFU,LMG,LM,LAQ';
		 	   SET   @Nr1         = LEN(@TblList)-LEN(REPLACE(@TblList,',',''))+1;
		 	   SET   @SqlFilter00 = '
			 	    DELETE A
				 	  FROM ARTIKUJ A
					 WHERE (SELECT COUNT(*)        FROM ARTIKUJ B WHERE UPPER(LTRIM(RTRIM(B.KOD)))=UPPER(LTRIM(RTRIM(A.KOD))))>1 AND
					 	   (SELECT MAX(B.NRRENDOR) FROM ARTIKUJ B WHERE UPPER(LTRIM(RTRIM(B.KOD)))=UPPER(LTRIM(RTRIM(A.KOD))))>A.NRRENDOR; ';
					 	   
			   SET   @Ind1  = 1;
			   
			   WHILE @Ind1 <= @Nr1
			 	 BEGIN
			 	
				    SET @TName = LTRIM(RTRIM(dbo.Isd_StringInListStr(@TblList,@Ind1,',')));     
				    SET @TName = LTRIM(RTRIM(REPLACE(@TName,' ','')));  
				    IF  dbo.Isd_StringInListExs(@ListTables,@TName)>0 
					    BEGIN
						  SET   @SqlFilter01 = REPLACE(@SQLFilter00,'ARTIKUJ',@TName);
						  EXEC (@SqlFilter01);  
					    END;
					    
				    SET @Ind1 = @Ind1 + 1;
				 END;
				
		     END;



-- 2.  Sistemim ne Tabelat e Librave....

		  IF dbo.Isd_ListFields2Lists(@Operacion,'ALL,SISTLB,SISTLBFR,SISTLBCM','')<>''
			 BEGIN 

		      --  Fillim LAR, LBA, LKL, LFU
		  
			   SET  @TblList     = 'LAR,LBA,LKL,LFU';
			   SET  @Nr1         = LEN(@TblList)-LEN(REPLACE(@TblList,',',''))+1;
			   SET  @SqlFilter00 = '
			        DECLARE @Force     Int;
					    SET @Force   = 11;

					     IF @Force = 1           -- Me force
					        BEGIN
						      DELETE FROM LKL;
						      UPDATE DKL SET NRLIBER=0; 
						    END

					     IF @Force = 2           -- Kompakt Libra
					        BEGIN  
						      DELETE A
						        FROM LKL A
						 	  WHERE NOT EXISTS (SELECT KOD FROM DKL B WHERE A.KOD=B.KOD);
						    END;


					 INSERT LKL (KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5)

					 SELECT      Dbo.Isd_SegmentFind(KOD,0,1)+''.''+ISNULL(KMON,''''),
					             PERSHKRIM + CASE WHEN ISNULL(KMON,'''')='''' THEN ''/'' ELSE '''' END + ISNULL(KMON,''''),
								 ISNULL(KMON,''''),
								 Dbo.Isd_SegmentFind(KOD,0,1),
								 ISNULL(KMON,''''),'''','''',''''
					   FROM DKL A
					  WHERE NOT EXISTS (SELECT KOD 
					   			 	      FROM LKL B 
										 WHERE B.KOD=Dbo.Isd_SegmentFind(KOD,0,1)+''.''+ISNULL(KMON,'''')); 

                     UPDATE A
                        SET A.NRLIBER=B.NRRENDOR
                       FROM DKL A INNER JOIN LKL B ON A.KOD=B.KOD
                      WHERE A.NRLIBER<>B.NRRENDOR; ';
                      
			   SET   @Ind1  = 1;
			  
			   WHILE @Ind1 <= @Nr1
				  BEGIN
				
				    SET @TName = LTRIM(RTRIM(dbo.Isd_StringInListStr(@TblList,@Ind1,',')));     
				    SET @TName = LTRIM(RTRIM(REPLACE(@TName,' ','')));

					IF  dbo.Isd_StringInListExs(@ListTables,@TName)>0 AND dbo.Isd_ListFields2Lists(@DocNames,'ALL,'+@TName,'')<>''
						BEGIN
						  SET   @SqlFilter01 = @SQLFilter00;
						  IF    dbo.Isd_ListFields2Lists(@Operacion,'SISTLBFR','')<>''
						 	    SET @SqlFilter01 = REPLACE(@SQLFilter01,'11','1')
						  ELSE
						  IF    dbo.Isd_ListFields2Lists(@Operacion,'SISTLBCM','')<>''
								SET @SqlFilter01 = REPLACE(@SQLFilter01,'11','2');

						  SET   @SqlFilter01 = REPLACE(@SQLFilter01,'LKL',@TName);
						  SET   @SqlFilter01 = REPLACE(@SQLFilter01,'DKL','D'+SUBSTRING(@TName,2,2));

						  EXEC (@SqlFilter01);  --PRINT @SqlFilter01
						END;
						
					SET @Ind1 = @Ind1 + 1;
					  
				  END;
				 
              --  Fund   LAR, LBA, LKL, LFU



		      --  Fillim LMG

			  IF  dbo.Isd_StringInListExs(@ListTables,'LMG')>0 AND dbo.Isd_ListFields2Lists(@DocNames,'ALL,LMG','')<>''
				  BEGIN

				-- Temporare u fut sepse vononte shume kerkimi ne LEVIZJEHD
						Delete FROM #TempLiber;
																
						INSERT INTO #TempLiber                   -- LMG nga FH/FD
							  (KMAG,KOD,KODAF,KARTLLG)
						SELECT KMAG,KOD,KODAF,KARTLLG
  						  FROM LEVIZJEHD A
						 WHERE ISNULL(A.KOD,'')<>'' 
					  GROUP BY A.KOD,KMAG,KODAF,KARTLLG;


				-- Zerim me Force ose Kompaktesim
							IF dbo.Isd_ListFields2Lists(@Operacion,'SISTLBFR','')<>''

							   BEGIN
							     Delete FROM LMG;
							   END  

							ELSE
							
							IF dbo.Isd_ListFields2Lists(@Operacion,'SISTLBCM','')<>''
                               BEGIN
							     Delete A
								   FROM LMG A
								  WHERE NOT EXISTS (SELECT KOD FROM #TempLiber B WHERE A.KOD=B.KOD);
							   END;

				-- Ndertimi perfundimtar i librit ne Temporare
						UPDATE A
						   SET KOD  = LTRIM(RTRIM(KMAG))+'.'+LTRIM(RTRIM(KARTLLG))+'.'+Dbo.Isd_SegmentFind(KODAF,0,2)+'.'+Dbo.Isd_SegmentFind(KODAF,0,3)+'.'+'',
							   KMON = '',
							   SG1  = LTRIM(RTRIM(KMAG)), 
							   SG2  = LTRIM(RTRIM(KARTLLG)),
							   SG3  = Dbo.Isd_SegmentFind(KODAF,0,2),
							   SG4  = Dbo.Isd_SegmentFind(KODAF,0,3),
							   SG5  = ''
						  FROM #TempLiber A;

						Delete A
						  FROM #TempLiber A
						 WHERE EXISTS (SELECT KOD 
										 FROM LMG B 
										WHERE B.KOD=A.KOD  AND
											  A.SG1=ISNULL(B.SG1,'') AND A.SG2=ISNULL(B.SG2,'') AND	A.SG3=ISNULL(B.SG3,'') AND A.SG4=ISNULL(B.SG4,'') AND A.SG5=ISNULL(B.SG5,'') )

						UPDATE A
						   SET PERSHKRIM = CASE WHEN A.SG2<>'' 
												THEN       ISNULL((SELECT Top 1 LTRIM(RTRIM(PERSHKRIM)) FROM ARTIKUJ     B WHERE B.KOD=A.SG2),'') 
												ELSE '' 
										   END+
										   CASE WHEN A.SG3<>'' 
												THEN ' / '+ISNULL((SELECT Top 1 LTRIM(RTRIM(PERSHKRIM)) FROM DEPARTAMENT B WHERE B.KOD=A.SG3),'') 
												ELSE '' 
										   END+
										   CASE WHEN A.SG4<>'' 
												THEN ' / '+ISNULL((SELECT Top 1 LTRIM(RTRIM(PERSHKRIM)) FROM LISTE       B WHERE B.KOD=A.SG4),'') 
												ELSE '' 
										   END
						  FROM #TempLiber A;

						INSERT LMG 
							  (KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5)
						SELECT KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5
						  FROM #TempLiber A
						 WHERE NOT (EXISTS (SELECT KOD FROM LMG B WHERE A.KOD=B.KOD));

				  END;
              --  Fund   LMG



			  --  Fillim LM

			  IF  dbo.Isd_StringInListExs(@ListTables,'LM')>0 AND dbo.Isd_ListFields2Lists(@DocNames,'ALL,LM','')<>'' 
				  BEGIN
					   Delete FROM #TempLiber; 
																
					   INSERT INTO #TempLiber                    -- LM nga FK
							 (KOD,KODAF,KMON,KMAG)
					   SELECT KOD,LLOGARI,ISNULL(KMON,''),'FK'
  						 FROM FKSCR A
						WHERE ISNULL(A.KOD,'')<>'' 
					 GROUP BY A.KOD,A.LLOGARI,A.KMON;

																 -- LM nga ARKA,BANKA,VS
				          SET @SqlFilter00 = '
					   INSERT INTO #TempLiber 
							 (KOD,KODAF,KMON)
					   SELECT KOD,KODAF,ISNULL(KMON,'''')
  						 FROM ARKASCR A
						WHERE ISNULL(A.KOD,'''')<>'''' AND TIPKLL=''T'' AND 
							 (NOT EXISTS (SELECT KOD FROM #TempLiber B WHERE A.KOD=B.KOD))
					 GROUP BY A.KOD,A.KODAF,A.KMON; '

						  SET  @SqlFilter01 = @SQLFilter00;
						 EXEC (@SqlFilter01);

						  SET  @SqlFilter01 = REPLACE(@SQLFilter00,'ARKA','BANKA');
						 EXEC (@SqlFilter01);

						  SET  @SqlFilter01 = REPLACE(@SQLFilter00,'ARKA','VS');
						 EXEC (@SqlFilter01);

																 -- LM nga FF,FJ
				          SET  @SqlFilter00 = '
					   INSERT INTO #TempLiber 
							 (KOD,KODAF,KMON)
					   SELECT B.KOD,B.KODAF,ISNULL(A.KMON,'''')
						 FROM FF A INNER JOIN FFSCR B ON A.NRRENDOR=B.NRD
						WHERE TIPKLL=''L'' AND (NOT EXISTS (SELECT KOD FROM #TempLiber C WHERE C.KOD=B.KOD)); '

						  SET  @SqlFilter01 = @SQLFilter00;
						 EXEC (@SqlFilter01);
						  SET  @SqlFilter01 = REPLACE(@SQLFilter00,' FF',' FJ');
						 EXEC (@SqlFilter01);

				-- Zerim me Force ose Kompaktesim

					   IF    dbo.Isd_ListFields2Lists(@Operacion,'SISTLBFR','')<>''
					         BEGIN
							   Delete FROM LM;
							 END  
					   ELSE
					   IF    dbo.Isd_ListFields2Lists(@Operacion,'SISTLBCM','')<>''
					         BEGIN
							   Delete A
							     FROM LM A
							    WHERE NOT EXISTS (SELECT KOD FROM #TempLiber B WHERE A.KOD=B.KOD);
							 END; 

				-- Ndertimi perfundimtar i librit ne Temporare
						UPDATE A
						   SET KOD  = Dbo.Isd_SegmentFind(KODAF,0,1)+'.'+Dbo.Isd_SegmentFind(KODAF,0,2)+'.'+Dbo.Isd_SegmentFind(KODAF,0,3)+'.'+Dbo.Isd_SegmentFind(KOD,0,4)+'.'+ISNULL(KMON,''),
							   KMON = ISNULL(KMON,''),
							   SG1  = Dbo.Isd_SegmentFind(KODAF,0,1), 
							   SG2  = Dbo.Isd_SegmentFind(KODAF,0,2),
							   SG3  = Dbo.Isd_SegmentFind(KODAF,0,3),
							   SG4  = Dbo.Isd_SegmentFind(KOD,0,4),
							   SG5  = ISNULL(KMON,'')
						  FROM #TempLiber A;

						Delete A
						  FROM #TempLiber A
						 WHERE EXISTS (SELECT KOD 
										 FROM LM B 
										WHERE B.KOD=A.KOD  AND A.SG1=ISNULL(B.SG1,'') AND A.SG2=ISNULL(B.SG2,'') AND A.SG3=ISNULL(B.SG3,'') AND A.SG4=ISNULL(B.SG4,'') AND A.SG5=ISNULL(B.SG5,'') );
										
						UPDATE A
						   SET PERSHKRIM = CASE WHEN A.SG1<>'' 
												THEN       ISNULL((SELECT Top 1 LTRIM(RTRIM(PERSHKRIM)) FROM LLOGARI     B WHERE B.KOD=A.SG1),'') 
												ELSE '' 
										   END+
										   CASE WHEN A.SG2<>'' 
												THEN ' / '+ISNULL((SELECT Top 1 LTRIM(RTRIM(PERSHKRIM)) FROM DEPARTAMENT B WHERE B.KOD=A.SG2),'') 
												ELSE '' 
										   END+
										   CASE WHEN A.SG3<>'' 
												THEN ' / '+ISNULL((SELECT Top 1 LTRIM(RTRIM(PERSHKRIM)) FROM LISTE       B WHERE B.KOD=A.SG3),'') 
												ELSE '' 
										   END+
										   CASE WHEN A.SG4<>'' 
												THEN ' / '+ISNULL((SELECT Top 1 LTRIM(RTRIM(PERSHKRIM)) FROM MAGAZINA    B WHERE B.KOD=A.SG4),'') 
												ELSE '' 
										   END+
										   CASE WHEN A.SG5<>'' 
												THEN ' / '+ISNULL((SELECT Top 1 LTRIM(RTRIM(PERSHKRIM)) FROM MONEDHA     B WHERE B.KOD=A.SG5),'') 
												ELSE '' 
										   END
						  FROM #TempLiber A;

						INSERT LM 
							  (KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5)
						SELECT KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5
						  FROM #TempLiber A
						 WHERE NOT (EXISTS (SELECT KOD FROM LM B WHERE A.KOD=B.KOD));

				  END;
			  --  Fund   LM  



			  --  Fillim AQ

			  IF  dbo.Isd_StringInListExs(@ListTables,'AQ')>0 AND dbo.Isd_ListFields2Lists(@DocNames,'ALL,AQ','')<>'' 
				  BEGIN
				  
					   Delete FROM #TempLiber; 
																
					   INSERT INTO #TempLiber                    -- LAQ nga AQ
							 (KOD,KODAF,KMON,KMAG)
					   SELECT KOD,KODAF,ISNULL(KMON,''),''
  						 FROM AQSCR A
						WHERE ISNULL(A.KOD,'')<>'' 
					 GROUP BY A.KOD,A.KODAF,A.KMON;

																 -- LAQ nga FF,FJ
				          SET  @SqlFilter00 = '
					   INSERT INTO #TempLiber 
							 (KOD,KODAF,KMON,KMAG)
					   SELECT B.KOD,B.KODAF,KMON=ISNULL(A.KMON,''''),KMAG+''''
						 FROM FF A INNER JOIN FFSCR B ON A.NRRENDOR=B.NRD
						WHERE TIPKLL=''X'' AND (NOT EXISTS (SELECT KOD FROM #TempLiber C WHERE C.KOD=B.KOD)); '

						  SET  @SqlFilter01 = @SQLFilter00;
						 EXEC (@SqlFilter01);
						  SET  @SqlFilter01 = REPLACE(@SQLFilter00,' FF',' FJ');
						 EXEC (@SqlFilter01);




				-- Zerim me Force ose Kompaktesim

					   IF    dbo.Isd_ListFields2Lists(@Operacion,'SISTLBFR','')<>''
					         BEGIN
							   Delete FROM LAQ;
							 END  
					   ELSE
					   IF    dbo.Isd_ListFields2Lists(@Operacion,'SISTLBCM','')<>''
					         BEGIN
							   Delete A
							     FROM LAQ A
							    WHERE NOT EXISTS (SELECT KOD FROM #TempLiber B WHERE A.KOD=B.KOD);
							 END; 

				-- Ndertimi perfundimtar i librit ne Temporare
						UPDATE A
						   SET KOD  = Dbo.Isd_SegmentFind(KODAF,0,1)+'.'+Dbo.Isd_SegmentFind(KODAF,0,2)+'.'+Dbo.Isd_SegmentFind(KODAF,0,3)+'.'+Dbo.Isd_SegmentFind(KOD,0,4)+'.'+ISNULL(KMON,''),
							   KMON = ISNULL(KMON,''),
							   SG1  = Dbo.Isd_SegmentFind(KODAF,0,1), 
							   SG2  = Dbo.Isd_SegmentFind(KODAF,0,2),
							   SG3  = Dbo.Isd_SegmentFind(KODAF,0,3),
							   SG4  = Dbo.Isd_SegmentFind(KOD,0,4),
							   SG5  = ISNULL(KMON,'')
						  FROM #TempLiber A;


						Delete A
						  FROM #TempLiber A
						 WHERE EXISTS (SELECT KOD 
										 FROM LAQ B 
										WHERE B.KOD=A.KOD  AND A.SG1=ISNULL(B.SG1,'') AND A.SG2=ISNULL(B.SG2,'') AND A.SG3=ISNULL(B.SG3,'') AND A.SG4=ISNULL(B.SG4,'') AND A.SG5=ISNULL(B.SG5,'') );
										
						UPDATE A
						   SET PERSHKRIM = LTRIM(RTRIM(ISNULL(B.PERSHKRIM,''))) +
										   CASE WHEN A.SG2='' THEN '' ELSE ' /'+LTRIM(RTRIM(ISNULL(C.PERSHKRIM,''))) END +
										   CASE WHEN A.SG3='' THEN '' ELSE ' /'+LTRIM(RTRIM(ISNULL(D.PERSHKRIM,''))) END +
										   CASE WHEN A.SG4='' THEN '' ELSE ' /'+LTRIM(RTRIM(ISNULL(E.PERSHKRIM,''))) END +
										   CASE WHEN A.SG5='' THEN '' ELSE ' /'+LTRIM(RTRIM(ISNULL(F.PERSHKRIM,''))) END
--				           SET PERSHKRIM = CASE WHEN A.SG1<>'' THEN       ISNULL((SELECT Top 1 LTRIM(RTRIM(PERSHKRIM)) FROM AQKARTELA   B WHERE B.KOD=A.SG1),'') ELSE '' END +
--								           CASE WHEN A.SG2<>'' THEN ' / '+ISNULL((SELECT Top 1 LTRIM(RTRIM(PERSHKRIM)) FROM DEPARTAMENT B WHERE B.KOD=A.SG2),'') ELSE '' END +
--										   CASE WHEN A.SG3<>'' THEN ' / '+ISNULL((SELECT Top 1 LTRIM(RTRIM(PERSHKRIM)) FROM LISTE       B WHERE B.KOD=A.SG3),'') ELSE '' END +
--										   CASE WHEN A.SG4<>'' THEN ' / '+ISNULL((SELECT Top 1 LTRIM(RTRIM(PERSHKRIM)) FROM MAGAZINA    B WHERE B.KOD=A.SG4),'') ELSE '' END +
--										   CASE WHEN A.SG5<>'' THEN ' / '+ISNULL((SELECT Top 1 LTRIM(RTRIM(PERSHKRIM)) FROM MONEDHA     B WHERE B.KOD=A.SG5),'') ELSE '' END
						  FROM #TempLiber A  LEFT JOIN AQKARTELA    B ON A.SG1 = B.KOD  
                                             LEFT JOIN DEPARTAMENT  C ON A.SG2 = C.KOD  
                                             LEFT JOIN LISTE        D ON A.SG3 = D.KOD  
                                             LEFT JOIN MAGAZINA     E ON A.SG4 = E.KOD  
                                             LEFT JOIN MONEDHA      F ON A.SG5 = F.KOD;

						INSERT LAQ 
							  (KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5)
						SELECT KOD,PERSHKRIM,KMON,SG1,SG2,SG3,SG4,SG5
						  FROM #TempLiber A
						 WHERE NOT (EXISTS (SELECT KOD FROM LAQ B WHERE A.KOD=B.KOD));

				  END;
			  --  Fund   LAQ

		    END;
		    
		    

          IF OBJECT_ID('TempDB..#TempLiber') IS NOT NULL
             DROP TABLE #TempLiber;

GO
